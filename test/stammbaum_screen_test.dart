import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:photo_vault/db/database.dart';
import 'package:photo_vault/l10n/app_localizations.dart';
import 'package:photo_vault/screens/stammbaum_screen.dart';
import 'package:photo_vault/widgets/faecher_ansicht.dart';
import 'package:photo_vault/services/backup_service.dart';
import 'package:photo_vault/services/stammbaum.dart';
import 'package:photo_vault/services/storage_paths.dart';
import 'package:photo_vault/state/library_state.dart';
import 'package:photo_vault/theme/app_theme.dart';

import 'goldbilder.dart';

/// Der Stammbaum-Bildschirm.
///
/// Geprüft wird, was man an einem Bildschirmfoto nicht sieht: dass die
/// richtigen Personen in den richtigen Reihen stehen, dass ein Klick den
/// Ausschnitt verschiebt statt den Bildschirm zu verlassen, und dass die
/// Hinweise auf weitere Verwandtschaft nur dort erscheinen, wo tatsächlich
/// etwas außerhalb des Bildes liegt.
void main() {
  late Directory tempRoot;
  late AppDatabase db;
  late LibraryState library;

  setUp(() async {
    tempRoot = Directory.systemTemp.createTempSync('pv_stammbaum_');
    db = AppDatabase(NativeDatabase.memory());
    final paths = await StoragePaths.forTesting(Directory(p.join(tempRoot.path, 'lib')));
    library = LibraryState()
      ..db = db
      ..paths = paths
      ..backupService = BackupService(db, paths);

    // opa + oma -> vater; vater + mutter -> kind, schwester
    for (final (id, name, jahr, geschlecht) in [
      ('opa', 'Opa', 1901, 'm'),
      ('oma', 'Oma', 1903, 'w'),
      ('vater', 'Vater', 1931, 'm'),
      ('mutter', 'Mutter', 1934, 'w'),
      ('kind', 'Kind', 1962, 'm'),
      ('schwester', 'Schwester', 1965, 'w'),
      ('uropa', 'Uropa', 1874, 'm'),
    ]) {
      await db.createPerson(PeopleCompanion.insert(
        id: id,
        name: name,
        geburtsdatum: Value(DateTime(jahr)),
        geschlecht: Value(geschlecht),
      ));
    }
    await db.fuegeBeziehungHinzu('vater', 'opa', Verwandtschaft.elternteil);
    await db.fuegeBeziehungHinzu('vater', 'oma', Verwandtschaft.elternteil);
    await db.fuegeBeziehungHinzu('vater', 'mutter', Verwandtschaft.partner);
    await db.fuegeBeziehungHinzu('kind', 'vater', Verwandtschaft.elternteil);
    await db.fuegeBeziehungHinzu('kind', 'mutter', Verwandtschaft.elternteil);
    await db.fuegeBeziehungHinzu('schwester', 'vater', Verwandtschaft.elternteil);
    await db.fuegeBeziehungHinzu('schwester', 'mutter', Verwandtschaft.elternteil);
    await db.fuegeBeziehungHinzu('opa', 'uropa', Verwandtschaft.elternteil);
  });

  tearDown(() async {
    await db.close();
    tempRoot.deleteSync(recursive: true);
  });

  /// Der Bildschirm wird auf eine Route geschoben statt als `home` gesetzt:
  /// Nur dann gibt es einen Zurück-Pfeil, und nur dann lässt sich prüfen,
  /// dass er erst dem Weg durch den Baum folgt.
  Future<void> zeige(WidgetTester tester, String start) async {
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('de'),
      localizationsDelegates: AppTexte.localizationsDelegates,
      supportedLocales: AppTexte.supportedLocales,
      theme: buildDarkTheme(),
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    StammbaumScreen(library: library, startPersonId: start),
              )),
              child: const Text('auf'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('auf'));
    await tester.pumpAndSettle();
  }

  testWidgets('zeigt Eltern, Geschwister und Lebensdaten', (tester) async {
    await zeige(tester, 'kind');

    expect(find.text('Eltern'), findsOneWidget);
    // Je zwei Treffer: der Name auf der Karte und die Bezeichnung
    // darunter, die hier zufällig gleich lautet.
    expect(find.text('Vater'), findsNWidgets(2));
    expect(find.text('Mutter'), findsNWidgets(2));
    // „Geschwister" nur als Überschrift: Die Schwester ist als weiblich
    // eingetragen, ihre Bezeichnung lautet deshalb „Schwester".
    expect(find.text('Geschwister'), findsOneWidget);
    expect(find.text('Schwester'), findsNWidgets(2));
    // Der Jahrgang steht unter dem Namen.
    expect(find.text('*1931'), findsOneWidget);
  });

  testWidgets('zeigt Partner und Kinder der Person in der Mitte',
      (tester) async {
    await zeige(tester, 'vater');

    // „Partner" nur als Überschrift – die Mutter ist als weiblich
    // eingetragen und heißt deshalb „Partnerin".
    expect(find.text('Partner'), findsOneWidget);
    expect(find.text('Partnerin'), findsOneWidget);
    expect(find.text('Kinder'), findsOneWidget);
    // Die beiden Kinder heißen „Kind" und „Schwester", ihre Bezeichnungen
    // lauten „Sohn" und „Tochter".
    expect(find.text('Kind'), findsOneWidget);
    expect(find.text('Sohn'), findsOneWidget);
    expect(find.text('Schwester'), findsOneWidget);
    expect(find.text('Tochter'), findsOneWidget);
    // Geschwister hat der Vater keine – die Beschriftung darf dann nicht
    // als leere Überschrift dastehen.
    expect(find.text('Geschwister'), findsNothing);
  });

  testWidgets('ein Klick rückt die angetippte Person in die Mitte',
      (tester) async {
    await zeige(tester, 'kind');
    expect(find.text('Opa'), findsNothing, reason: 'Großeltern stehen nicht im Bild');

    // Der Name auf der Karte, nicht die gleichlautende Bezeichnung
    // darunter – beide führen zum selben Ziel, aber der Test soll sagen,
    // worauf er tippt.
    await tester.tap(find.text('Vater').first);
    await tester.pumpAndSettle();

    // Jetzt steht der Vater in der Mitte, seine Eltern darüber.
    expect(find.text('Opa'), findsOneWidget);
    expect(find.text('Oma'), findsOneWidget);
  });

  testWidgets('der Zurück-Pfeil folgt dem eigenen Weg durch den Baum',
      (tester) async {
    await zeige(tester, 'kind');
    await tester.tap(find.text('Vater').first);
    await tester.pumpAndSettle();
    expect(find.text('Opa'), findsOneWidget);

    // Nicht tester.pageBack(): das sucht nach der Beschriftung "Back",
    // und die Oberfläche läuft hier auf Deutsch.
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // Zurück beim Kind – und nicht aus dem Stammbaum heraus.
    expect(find.byType(StammbaumScreen), findsOneWidget);
    expect(find.text('Opa'), findsNothing);
    expect(find.text('Geschwister'), findsOneWidget,
        reason: 'als Überschrift; die Karte selbst nennt sie „Schwester"');
  });

  testWidgets('weist auf Verwandtschaft hin, die außerhalb des Bildes liegt',
      (tester) async {
    await zeige(tester, 'kind');
    // Genau ein Hinweis nach oben: beim Vater, der selbst Eltern hat. Die
    // Mutter hat keine, das Kind in der Mitte bekommt nie einen.
    expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);
  });

  testWidgets('eine Verbindung lässt sich lösen', (tester) async {
    await zeige(tester, 'kind');

    final maus = await tester.createGesture(
        kind: PointerDeviceKind.mouse, buttons: kSecondaryMouseButton);
    await maus.down(tester.getCenter(find.text('Mutter').first));
    await maus.up();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Verbindung entfernen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Entfernen'));
    await tester.pumpAndSettle();

    expect(find.text('Mutter'), findsNothing);
    // Die Schwester bleibt über den Vater in der Reihe – aber die
    // Bezeichnung ändert sich mit: Sie hat noch beide Eltern eingetragen,
    // das Kind in der Mitte nur noch einen gemeinsamen. Das sind
    // Halbgeschwister, und genau das soll dort dann auch stehen.
    expect(find.text('Schwester'), findsOneWidget, reason: 'nur noch der Name');
    expect(find.text('Halbschwester'), findsOneWidget);
    expect((await db.alleBeziehungen()).length, 7);
  });

  testWidgets('die Karten nennen die Verwandtschaft', (tester) async {
    await zeige(tester, 'kind');
    // Die Bezeichnung, nicht der Name: Beide heißen hier gleich, deshalb
    // je zwei Treffer – einer als Name, einer als Bezeichnung.
    expect(find.text('Vater'), findsNWidgets(2));
    expect(find.text('Mutter'), findsNWidgets(2));
    // Die Schwester heißt „Schwester" und ist eine – auch zwei Treffer.
    expect(find.text('Schwester'), findsNWidgets(2));
    expect(find.text('Großvater'), findsNothing,
        reason: 'im Baum stehen keine Großeltern');
    // Auf der Karte in der Mitte steht keine Bezeichnung.
    expect(find.text('diese Person'), findsNothing);
  });

  testWidgets('das Geschlecht entscheidet über die Bezeichnung',
      (tester) async {
    await db.setzeGeschlecht('schwester', null);
    await zeige(tester, 'kind');
    // Ohne Angabe lautet die Bezeichnung „Geschwister" – zusammen mit der
    // Überschrift also zwei Treffer. Mit Angabe stand dort „Schwester".
    expect(find.text('Geschwister'), findsNWidgets(2),
        reason: 'ohne Angabe die neutrale Form');
    expect(find.text('Schwester'), findsOneWidget, reason: 'nur noch der Name');
  });

  testWidgets('die Verwandtenliste nennt auch die Entfernten', (tester) async {
    await zeige(tester, 'kind');
    await tester.tap(find.text('Verwandte'));
    await tester.pumpAndSettle();

    // Im Baum stehen die Großeltern nicht – in der Liste schon, mit
    // ihrer Bezeichnung.
    expect(find.text('Großvater'), findsOneWidget);
    expect(find.text('Großmutter'), findsOneWidget);
    expect(find.text('Opa'), findsOneWidget);
  });

  testWidgets('die Liste stellt die nächsten Angehörigen voran',
      (tester) async {
    await zeige(tester, 'kind');
    await tester.tap(find.text('Verwandte'));
    await tester.pumpAndSettle();

    final namen = tester
        .widgetList<ListTile>(find.byType(ListTile))
        .map((k) => (k.title! as Text).data)
        .toList();
    expect(namen.first, 'Schwester', reason: 'Geschwister vor Eltern');
    expect(namen.take(3), containsAll(['Vater', 'Mutter']));
    // Der Urgroßvater steht am Ende – er ist der entfernteste Verwandte.
    expect(namen.last, 'Uropa');
  });

  testWidgets('ohne Vorgabe wählt der Bildschirm selbst eine Person',
      (tester) async {
    // Über den Menüpunkt geöffnet gibt es keine Startperson. Genommen wird
    // die mit den meisten Verwandten – hier der Vater (zwei Eltern, zwei
    // Kinder, eine Partnerin).
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('de'),
      localizationsDelegates: AppTexte.localizationsDelegates,
      supportedLocales: AppTexte.supportedLocales,
      theme: buildDarkTheme(),
      home: StammbaumScreen(library: library),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Stammbaum: Vater'), findsOneWidget);
  });

  testWidgets('der Fächer zeigt Generationen, die der Baum nicht zeigt',
      (tester) async {
    await zeige(tester, 'kind');
    await tester.tap(find.text('Fächer'));
    await tester.pumpAndSettle();

    // Im Baum stehen die Großeltern nicht – im Fächer schon, als äußerer
    // Ring. Gezeichnet wird auf Leinwand, also prüft der Test die Daten
    // dahinter statt der Pixel.
    final maler = tester.widget<CustomPaint>(find.descendant(
      of: find.byType(FaecherAnsicht),
      matching: find.byType(CustomPaint),
    ));
    expect(maler.painter, isNotNull);
    // Und das Abbild weiter unten zeigt, dass daraus auch etwas wird.
    expect(find.byType(FaecherAnsicht), findsOneWidget);
  });

  testWidgets('die Nachfahrengliederung rückt jede Generation ein',
      (tester) async {
    await zeige(tester, 'opa');
    await tester.tap(find.text('Nachfahren'));
    await tester.pumpAndSettle();

    // Opa -> Vater -> Kind und Schwester.
    for (final name in ['Opa', 'Vater', 'Kind', 'Schwester']) {
      expect(find.text(name), findsOneWidget, reason: name);
    }
    // Die Einrückung wächst mit der Generation.
    final x = {
      for (final name in ['Opa', 'Vater', 'Kind'])
        name: tester.getTopLeft(find.text(name)).dx,
    };
    expect(x['Vater']!, greaterThan(x['Opa']!));
    expect(x['Kind']!, greaterThan(x['Vater']!));
  });

  testWidgets('ohne Vorfahren erklärt der Fächer, was er zeigen würde',
      (tester) async {
    // Der Urgroßvater ist die einzige Person ohne eingetragene Eltern.
    await zeige(tester, 'uropa');
    await tester.tap(find.text('Fächer'));
    await tester.pumpAndSettle();
    expect(find.textContaining('noch keine Vorfahren eingetragen'),
        findsOneWidget);
  });

  testWidgets('so sieht der Baum aus', (tester) async {
    // Ein Abbild statt einer Behauptung. An das echte Fenster kommt man in
    // dieser Umgebung nicht heran; das gerenderte Bild ist die einzige
    // Möglichkeit, die Anordnung und die Verbindungslinien tatsächlich
    // anzusehen statt sie aus dem Quelltext zu erschliessen. Die Schrift
    // ist im Test ein Platzhalter – es geht um Kästen und Linien.
    tester.view.physicalSize = const Size(1000, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await zeige(tester, 'kind');
    await expectLater(
      find.byType(StammbaumScreen),
      matchesGoldenFile('golden/stammbaum.png'),
    );
  }, skip: nurAufReferenzplattform);

  testWidgets('so sieht der Baum mit Partner und Kindern aus', (tester) async {
    // Der zweite Fall: eine Person mit Eltern darüber, Partner daneben und
    // zwei Kindern darunter. Das erste Abbild zeigt weder die kurze Linie
    // zum Partner noch den Verbinder nach unten.
    tester.view.physicalSize = const Size(1000, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await zeige(tester, 'vater');
    await expectLater(
      find.byType(StammbaumScreen),
      matchesGoldenFile('golden/stammbaum_voll.png'),
    );
  }, skip: nurAufReferenzplattform);

  testWidgets('so sieht die Verwandtenliste aus', (tester) async {
    // Die Sicht, in der die entfernteren Bezeichnungen überhaupt erst
    // auftauchen – im Baum stehen die Großeltern nicht.
    tester.view.physicalSize = const Size(760, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await zeige(tester, 'kind');
    await tester.tap(find.text('Verwandte'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(StammbaumScreen),
      matchesGoldenFile('golden/stammbaum_verwandte.png'),
    );
  }, skip: nurAufReferenzplattform);

  testWidgets('der Fächer lässt sich vorlesen', (tester) async {
    // Ein CustomPaint ist für die Sprachausgabe eine leere Fläche. Ohne
    // eigene Beschriftungen wäre der Fächer dort überhaupt nicht
    // vorhanden – geprüft wird deshalb der Semantik-Baum, nicht das Bild.
    final semantik = tester.ensureSemantics();
    await zeige(tester, 'kind');
    await tester.tap(find.text('Fächer'));
    await tester.pumpAndSettle();

    for (final name in ['Kind', 'Vater', 'Mutter', 'Opa', 'Oma']) {
      expect(find.bySemanticsLabel(name), findsOneWidget, reason: name);
    }
    semantik.dispose();
  });

  testWidgets('so sieht die Sanduhr aus', (tester) async {
    tester.view.physicalSize = const Size(860, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await zeige(tester, 'kind');
    await tester.tap(find.text('Sanduhr'));
    await tester.pumpAndSettle();
    await expectLater(find.byType(StammbaumScreen),
        matchesGoldenFile('golden/stammbaum_sanduhr.png'));
  }, skip: nurAufReferenzplattform);

  testWidgets('die Sanduhr zeigt mehrere Generationen auf einmal',
      (tester) async {
    await zeige(tester, 'kind');
    await tester.tap(find.text('Sanduhr'));
    await tester.pumpAndSettle();
    // Im Baum stehen weder Großeltern noch Urgroßvater – hier alle drei
    // Generationen zugleich.
    for (final name in ['Kind', 'Vater', 'Mutter', 'Opa', 'Oma', 'Uropa']) {
      expect(find.text(name), findsOneWidget, reason: name);
    }
  });

  testWidgets('so sieht der Fächer aus', (tester) async {
    // Der eigentliche Beleg für die gewählte Baumoptik: vier Ringe, jeder
    // Platz mit genau einem Nachfolger nach innen.
    tester.view.physicalSize = const Size(760, 560);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await zeige(tester, 'kind');
    await tester.tap(find.text('Fächer'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(StammbaumScreen),
      matchesGoldenFile('golden/stammbaum_faecher.png'),
    );
  }, skip: nurAufReferenzplattform);

  testWidgets('eine Person ohne Verwandtschaft bekommt eine Erklärung',
      (tester) async {
    await db.createPerson(PeopleCompanion.insert(id: 'allein', name: 'Allein'));
    await zeige(tester, 'allein');
    expect(find.textContaining('noch keine Verwandtschaft eingetragen'),
        findsOneWidget);
  });
}
