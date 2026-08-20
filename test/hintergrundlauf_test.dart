import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:photo_vault/db/database.dart';
import 'package:photo_vault/services/storage_paths.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:photo_vault/state/hintergrundlauf.dart';
import 'package:photo_vault/state/library_state.dart';

/// Die Aufgabenübersicht öffnete bisher je Vorgang ein Fortschrittsfenster,
/// das den Bildschirm sperrte. Diese Tests halten fest, was der Ersatz
/// können muss: weiterlaufen, sich abbrechen lassen, und dieselbe Arbeit
/// nicht zweimal gleichzeitig anstossen.
void main() {
  late LibraryState library;

  setUp(() => library = LibraryState());

  /// Ein Nachholvorgang, der sich von aussen steuern lässt – so wie die
  /// echten ein `async*`-Generator sind, der zwischen den Fotos wartet.
  ({Stream<ImportProgress> Function() strom, void Function(int) schritt, Future<void> Function() schliessen, bool Function() abgeraeumt})
      steuerbarerLauf(int gesamt) {
    final regler = StreamController<ImportProgress>();
    var abgeraeumt = false;
    regler.onCancel = () => abgeraeumt = true;
    return (
      strom: () => regler.stream,
      schritt: (n) => regler.add(ImportProgress(n, gesamt, currentFile: 'foto_$n.jpg')),
      schliessen: () => regler.close(),
      abgeraeumt: () => abgeraeumt,
    );
  }

  test('ein Lauf meldet seinen Fortschritt und bleibt nach dem Ende stehen', () async {
    final quelle = steuerbarerLauf(3);
    final fertig = library.starteAufgabe(
        schluessel: 'ocr', titel: 'Erkenne Text …', leermeldung: 'nichts zu tun', strom: quelle.strom);
    await pumpEventQueue();

    expect(library.lauf('ocr')!.titel, 'Erkenne Text …');
    expect(library.lauf('ocr')!.laeuft, isTrue);
    expect(library.etwasLaeuft, isTrue);

    quelle.schritt(2);
    await pumpEventQueue();
    expect(library.lauf('ocr')!.erledigt, 2);
    expect(library.lauf('ocr')!.gesamt, 3);
    expect(library.lauf('ocr')!.datei, 'foto_2.jpg');
    expect(library.lauf('ocr')!.anteil, closeTo(2 / 3, 1e-9));

    await quelle.schliessen();
    await fertig;

    // Der Eintrag verschwindet NICHT von selbst: Sonst wäre nach einem Lauf
    // über Stunden nirgends zu sehen, dass er überhaupt fertig wurde.
    expect(library.lauf('ocr')!.beendet, isTrue);
    expect(library.lauf('ocr')!.abgebrochen, isFalse);
    expect(library.etwasLaeuft, isFalse);

    library.verwerfeLauf('ocr');
    expect(library.lauf('ocr'), isNull);
  });

  test('Abbrechen kündigt das Abonnement – der Generator räumt auf', () async {
    final quelle = steuerbarerLauf(100);
    final fertig = library.starteAufgabe(
        schluessel: 'beschreibungen', titel: 'Erzeuge …', leermeldung: 'nichts zu tun', strom: quelle.strom);
    await pumpEventQueue();
    quelle.schritt(7);
    await pumpEventQueue();

    library.brichAufgabeAb('beschreibungen');
    await fertig;
    await pumpEventQueue();

    // Das Kündigen ist der Punkt: Nur dadurch laufen die finally-Blöcke der
    // Nachholvorgänge, die dort ihre geliehenen KI-Modelle zurückgeben.
    expect(quelle.abgeraeumt(), isTrue);
    expect(library.lauf('beschreibungen')!.abgebrochen, isTrue);
    expect(library.lauf('beschreibungen')!.erledigt, 7);
    expect(library.etwasLaeuft, isFalse);

    await quelle.schliessen();
  });

  test('dieselbe Aufgabe startet nicht zweimal gleichzeitig', () async {
    final erste = steuerbarerLauf(10);
    var zweiteAngefasst = false;
    final fertig = library.starteAufgabe(
        schluessel: 'kitags', titel: 'erster Lauf', leermeldung: 'nichts zu tun', strom: erste.strom);
    await pumpEventQueue();

    await library.starteAufgabe(
      schluessel: 'kitags',
      titel: 'zweiter Lauf',
      leermeldung: 'nichts zu tun',
      strom: () {
        zweiteAngefasst = true;
        return const Stream<ImportProgress>.empty();
      },
    );

    expect(zweiteAngefasst, isFalse, reason: 'der Strom darf gar nicht erst entstehen');
    expect(library.lauf('kitags')!.titel, 'erster Lauf');

    await erste.schliessen();
    await fertig;

    // Nach dem Ende ist der Platz wieder frei.
    await library.starteAufgabe(
        schluessel: 'kitags',
        titel: 'dritter Lauf',
        leermeldung: 'nichts zu tun',
        strom: () => const Stream<ImportProgress>.empty());
    expect(library.lauf('kitags')!.titel, 'dritter Lauf');
  });

  test('ein Fehler im Strom beendet den Lauf, statt ihn hängen zu lassen', () async {
    await library.starteAufgabe(
      schluessel: 'xmp',
      titel: 'Schreibe …',
      leermeldung: 'nichts zu tun',
      strom: () => Stream<ImportProgress>.error(StateError('Modell fehlt')),
    );

    expect(library.lauf('xmp')!.beendet, isTrue);
    expect(library.lauf('xmp')!.fehler, isA<StateError>());
    expect(library.etwasLaeuft, isFalse);
  });

  test('ein beendeter Lauf lässt sich wegräumen, ein laufender nicht', () async {
    final quelle = steuerbarerLauf(5);
    final fertig = library.starteAufgabe(
        schluessel: 'orte', titel: 'Lese Orte …', leermeldung: 'nichts zu tun', strom: quelle.strom);
    await pumpEventQueue();

    library.verwerfeLauf('orte');
    expect(library.lauf('orte'), isNotNull, reason: 'ein laufender Vorgang bleibt sichtbar');

    await quelle.schliessen();
    await fertig;
    library.verwerfeLauf('orte');
    expect(library.lauf('orte'), isNull);
  });

  group('teure Auswertungen laufen einzeln', () {
    // Seit die Aufgaben kein Fenster mehr sperren, genügten vier Klicks, um
    // Gesichter, Bildbeschreibung, Einbettung und Übersetzung gleichzeitig
    // anzustossen – vier KI-Modelle im Speicher und dieselben Fotos vierfach
    // dekodiert. Das war eine Nebenwirkung des Umbaus, nicht Absicht.

    test('eine zweite teure Aufgabe wird abgewiesen, eine billige nicht', () async {
      final erste = steuerbarerLauf(100);
      final fertig = library.starteAufgabe(
        schluessel: 'beschreibungen',
        titel: 'Erzeuge …',
        leermeldung: 'nichts zu tun',
        strom: erste.strom,
        rechenintensiv: true,
      );
      await pumpEventQueue();

      expect(
        await library.starteAufgabe(
          schluessel: 'embeddings',
          titel: 'Berechne …',
          leermeldung: 'nichts zu tun',
          strom: () => const Stream<ImportProgress>.empty(),
          rechenintensiv: true,
        ),
        Startabweisung.andereAufgabe,
      );
      expect(library.lauf('embeddings'), isNull);

      // Orte einlesen, XMP schreiben und Ähnliches kosten nichts, was sich
      // in die Quere käme – die dürfen nebenher laufen.
      expect(
        await library.starteAufgabe(
          schluessel: 'orte',
          titel: 'Lese Orte …',
          leermeldung: 'nichts zu tun',
          strom: () => const Stream<ImportProgress>.empty(),
        ),
        isNull,
      );
      expect(library.lauf('orte'), isNotNull);

      await erste.schliessen();
      await fertig;

      // Danach ist der Platz wieder frei.
      expect(library.pruefeStart('embeddings', rechenintensiv: true), isNull);
    });

    test('eine angefragte Analyse wird nachgeholt statt verworfen', () async {
      final quelle = steuerbarerLauf(50);
      final fertig = library.starteAufgabe(
        schluessel: 'kitags',
        titel: 'Berechne KI-Tags …',
        leermeldung: 'nichts zu tun',
        strom: quelle.strom,
        rechenintensiv: true,
      );
      await pumpEventQueue();

      // So kommt die Anfrage im Betrieb: automatisch nach einem Import.
      await library.starteHintergrundanalyse();
      expect(library.analyseLaeuft, isFalse);
      expect(library.analyseZurueckgestellt, isTrue,
          reason: 'verworfen wäre schlimmer – frisch importierte Fotos '
              'blieben bis zum nächsten Programmstart ohne Auswertung');

      // Ein zweiter Anlauf schadet nicht.
      expect(library.pruefeStart('embeddings', rechenintensiv: true),
          Startabweisung.andereAufgabe);

      await quelle.schliessen();
      await fertig;
      await pumpEventQueue();

      // Ohne Modelle im Test läuft die Analyse sofort durch; entscheidend
      // ist, dass sie überhaupt angestossen wurde und die Merkung fällt.
      expect(library.analyseZurueckgestellt, isFalse);
    });

    test('während die Analyse läuft, startet keine teure Aufgabe', () async {
      // Die Analyse braucht Arbeit, sonst ist sie durch, bevor man
      // hinsehen kann: eine echte (leere) Datenbank mit einem Foto, dem die
      // Texterkennung noch fehlt.
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final tempRoot = Directory.systemTemp.createTempSync('pv_lauf_analyse_');
      addTearDown(() => tempRoot.deleteSync(recursive: true));
      library
        ..db = db
        ..paths = await StoragePaths.forTesting(Directory(p.join(tempRoot.path, 'lib')));

      for (var i = 0; i < 40; i++) {
        await db.into(db.assets).insert(AssetsCompanion.insert(
              id: 'a$i',
              originalFileName: 'a$i.jpg',
              relativePath: 'originals/a$i.jpg',
              checksum: 'a$i',
              fileCreatedAt: DateTime(2024, 5, 1),
              importedAt: DateTime(2024, 5, 2),
              type: 'IMAGE',
            ));
      }

      final analyse = library.starteHintergrundanalyse();

      // Warten, bis sie wirklich läuft – ohne Wanduhr, nur über die
      // Ereignisschlange.
      var gesehen = false;
      for (var i = 0; i < 200 && !gesehen; i++) {
        await pumpEventQueue();
        if (library.analyseLaeuft) gesehen = true;
      }
      expect(gesehen, isTrue, reason: 'die Analyse kam gar nicht erst in Gang');

      expect(
        library.pruefeStart('beschreibungen', rechenintensiv: true),
        Startabweisung.analyseLaeuft,
      );
      // Billige Aufgaben bleiben auch daneben erlaubt.
      expect(library.pruefeStart('xmp', rechenintensiv: false), isNull);

      library.brichHintergrundanalyseAb();
      await analyse;
      expect(library.pruefeStart('beschreibungen', rechenintensiv: true), isNull);
    });
  });
}
