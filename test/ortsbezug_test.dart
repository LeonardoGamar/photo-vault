import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_vault/db/database.dart';

/// Wo eine Reise oder Aktivität stattfand.
///
/// **Der Ort steht nicht an der Reise.** Er steht an ihren Aufnahmen, an
/// jeder einzelnen, und eine Reise hat davon hunderte. Die Übersicht
/// braucht daraus drei Wörter. Diese Prüfung hält fest, welche drei –
/// und was passiert, wenn es gar keine gibt.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  var laufend = 0;

  Future<String> aufnahme({
    String? stadt,
    String? region,
    String? land,
    bool papierkorb = false,
    bool gesperrt = false,
  }) async {
    final id = 'a${laufend++}';
    await db.into(db.assets).insert(AssetsCompanion.insert(
          id: id,
          originalFileName: '$id.jpg',
          relativePath: 'originals/$id.jpg',
          checksum: 'pruef-$id',
          type: 'IMAGE',
          fileCreatedAt: DateTime(2024, 6, 3),
          importedAt: DateTime(2024),
          locationCity: Value(stadt),
          locationState: Value(region),
          locationCountry: Value(land),
          isTrashed: Value(papierkorb),
          isLocked: Value(gesperrt),
        ));
    return id;
  }

  Future<void> reiseMit(String id, List<String> ids) => db.reiseAnlegen(
        ReisenCompanion.insert(
          id: id,
          name: 'Reise $id',
          von: DateTime(2024, 6, 3),
          bis: DateTime(2024, 6, 10),
          angelegtAm: DateTime(2024, 7, 1),
        ),
        ids,
      );

  Future<void> aktivitaetMit(String id, List<String> ids) =>
      db.aktivitaetAnlegen(
        AktivitaetenCompanion.insert(
          id: id,
          name: 'Aktivität $id',
          art: 'wanderung',
          von: DateTime(2024, 6, 3),
          bis: DateTime(2024, 6, 3, 15),
          angelegtAm: DateTime(2024, 7, 1),
        ),
        ids,
      );

  test('der häufigste Ort steht vorn, die übrigen werden gezählt', () async {
    await reiseMit('r1', [
      await aufnahme(stadt: 'Rom', region: 'Latium', land: 'Italien'),
      await aufnahme(stadt: 'Rom', region: 'Latium', land: 'Italien'),
      await aufnahme(stadt: 'Florenz', region: 'Toskana', land: 'Italien'),
      await aufnahme(stadt: 'Siena', region: 'Toskana', land: 'Italien'),
    ]);

    final b = (await db.ortsbezugJeReise())['r1']!;
    expect(b.ort, 'Rom');
    expect(b.region, 'Latium');
    expect(b.land, 'Italien');
    // Zwei weitere, nicht drei: Der genannte zählt nicht als „weiterer".
    expect(b.weitereOrte, 2);
    expect(b.aufnahmen, 4);
  });

  test('bei Gleichstand gewinnt der alphabetisch erste', () async {
    // Nicht weil er der bessere wäre, sondern damit dieselbe Bibliothek
    // zweimal dasselbe anzeigt. Ohne diese Regel entschiede die
    // Reihenfolge, in der SQLite die Gruppen ausgibt.
    await reiseMit('r1', [
      await aufnahme(stadt: 'Verona', land: 'Italien'),
      await aufnahme(stadt: 'Bologna', land: 'Italien'),
    ]);
    expect((await db.ortsbezugJeReise())['r1']!.ort, 'Bologna');
  });

  test('eine Reise ohne verortete Aufnahme hat keinen Ort', () async {
    // Und nicht „Unbekannt": Die Zeile fällt in der Übersicht weg. Wer
    // den GeoNames-Datensatz nicht eingespielt hat, hat für jede Reise
    // diesen Fall - eine Spalte voller Platzhalter wäre das Ergebnis.
    await reiseMit('r1', [await aufnahme(), await aufnahme()]);
    final b = (await db.ortsbezugJeReise())['r1']!;
    expect(b.ort, isNull);
    expect(b.region, isNull);
    expect(b.land, isNull);
    expect(b.weitereOrte, 0);
    // Die Aufnahmen zählen trotzdem - sie sind ja da.
    expect(b.aufnahmen, 2);
  });

  test('unverortete Aufnahmen verdrängen den Ort nicht', () async {
    // Der Fall, der ohne die Regel schiefginge: Drei Bilder ohne Ort
    // wären die grösste Gruppe und machten die Reise ortlos, obwohl zwei
    // Bilder ausdrücklich Rom nennen.
    await reiseMit('r1', [
      await aufnahme(),
      await aufnahme(),
      await aufnahme(),
      await aufnahme(stadt: 'Rom', land: 'Italien'),
      await aufnahme(stadt: 'Rom', land: 'Italien'),
    ]);
    final b = (await db.ortsbezugJeReise())['r1']!;
    expect(b.ort, 'Rom');
    expect(b.aufnahmen, 5);
  });

  test('Papierkorb und gesperrter Ordner zählen nicht mit', () async {
    // Dieselbe Regel wie bei besuchteOrte. Ein gesperrtes Foto soll die
    // Übersicht nicht verraten, ein gelöschtes nicht mehr sprechen.
    await reiseMit('r1', [
      await aufnahme(stadt: 'Rom', land: 'Italien'),
      await aufnahme(stadt: 'Neapel', land: 'Italien', papierkorb: true),
      await aufnahme(stadt: 'Neapel', land: 'Italien', gesperrt: true),
      await aufnahme(stadt: 'Neapel', land: 'Italien', gesperrt: true),
    ]);
    final b = (await db.ortsbezugJeReise())['r1']!;
    expect(b.ort, 'Rom');
    expect(b.weitereOrte, 0, reason: 'Neapel liegt nur in Papierkorb/Tresor');
    expect(b.aufnahmen, 1);
  });

  test('jede Reise bekommt ihren eigenen Ort', () async {
    // Der Sinn der einen Abfrage: Sie liefert alle auf einmal, ohne dass
    // sich zwei Reisen ihre Zeilen teilen.
    await reiseMit('r1', [await aufnahme(stadt: 'Rom', land: 'Italien')]);
    await reiseMit('r2', [await aufnahme(stadt: 'Oslo', land: 'Norwegen')]);
    final alle = await db.ortsbezugJeReise();
    expect(alle['r1']!.ort, 'Rom');
    expect(alle['r2']!.ort, 'Oslo');
    expect(alle.length, 2);
  });

  test('eine Reise ganz ohne Aufnahmen taucht gar nicht auf', () async {
    await reiseMit('r1', const []);
    expect(await db.ortsbezugJeReise(), isEmpty);
  });

  test('Aktivitäten laufen über denselben Weg', () async {
    await aktivitaetMit('k1', [
      await aufnahme(stadt: 'Goslar', region: 'Niedersachsen', land: 'DE'),
      await aufnahme(stadt: 'Goslar', region: 'Niedersachsen', land: 'DE'),
      await aufnahme(stadt: 'Bad Harzburg', land: 'DE'),
    ]);
    final b = (await db.ortsbezugJeAktivitaet())['k1']!;
    expect(b.ort, 'Goslar');
    expect(b.region, 'Niedersachsen');
    expect(b.weitereOrte, 1);
    expect(b.aufnahmen, 3);
  });

  test('Reisen und Aktivitäten kommen sich nicht ins Gehege', () async {
    // Beide Abfragen bauen sich aus derselben Vorlage. Ein vertauschter
    // Tabellenname fiele erst hier auf.
    final gemeinsam = await aufnahme(stadt: 'Rom', land: 'Italien');
    await reiseMit('r1', [gemeinsam]);
    await aktivitaetMit('k1', [gemeinsam]);
    expect((await db.ortsbezugJeReise()).keys, ['r1']);
    expect((await db.ortsbezugJeAktivitaet()).keys, ['k1']);
  });
}
