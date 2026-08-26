import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:photo_vault/db/database.dart';
import 'package:photo_vault/services/reverse_geocoder.dart';
import 'package:photo_vault/services/storage_paths.dart';
import 'package:photo_vault/state/library_state.dart';

/// Die ganze Kette: Ortsname aus dem Lebenslauf zu einer Koordinate auf
/// der Karte.
///
/// Die Einzelteile haben eigene Tests – die Ortssuche in
/// `ortssuche_test.dart`, die Spalten in `ereignisorte_test.dart`. Hier
/// läuft beides zusammen, denn genau dazwischen sitzen die
/// Entscheidungen: welcher Ort bei Mehrdeutigkeit gewinnt, und was
/// unangetastet bleibt.
void main() {
  late Directory temp;
  late AppDatabase db;
  late LibraryState lib;

  Future<ReverseGeocoder> geocoder() async {
    final cities = File(p.join(temp.path, 'cities1000.txt'));
    await cities.writeAsString(
      '1\tBerlin\tBerlin\t\t52.52437\t13.41053\tP\tPPLC\tDE\t\t16\t\t\t\t3426354\t\t74\tEurope/Berlin\t2023\n'
      '2\tSpringfield\tSpringfield\t\t39.79172\t-89.64371\tP\tPPLA\tUS\t\tIL\t167\t\t\t114230\t\t180\tAmerica/Chicago\t2023\n'
      '3\tSpringfield\tSpringfield\t\t37.21533\t-93.29824\tP\tPPLA2\tUS\t\tMO\t077\t\t\t169176\t\t395\tAmerica/Chicago\t2023\n',
    );
    final admin1 = File(p.join(temp.path, 'admin1.txt'));
    await admin1.writeAsString('DE.16\tBerlin\tBerlin\t1\nUS.IL\tIllinois\tIllinois\t2\nUS.MO\tMissouri\tMissouri\t3\n');
    final laender = File(p.join(temp.path, 'countryInfo.txt'));
    await laender.writeAsString(
      'DE\tDEU\t276\tDE\tDeutschland\tBerlin\t357021\t82927922\tEU\t.de\tEUR\tEuro\t49\t\t\tde-DE\t2921044\t\t\n'
      'US\tUSA\t840\tUS\tVereinigte Staaten\tWashington\t9629091\t327167434\tNA\t.us\tUSD\tDollar\t1\t\t\ten-US\t6252001\t\t\n',
    );
    return ReverseGeocoder.loadFromFiles(
        citiesFile: cities, admin1File: admin1, countryFile: laender);
  }

  setUp(() async {
    temp = Directory.systemTemp.createTempSync('pv_ereignisorte_');
    db = AppDatabase(NativeDatabase.memory());
    final paths =
        await StoragePaths.forTesting(Directory(p.join(temp.path, 'lib')));
    lib = LibraryState()
      ..db = db
      ..paths = paths;
    await db.createPerson(PeopleCompanion.insert(id: 'p1', name: 'Anna'));
  });

  tearDown(() async {
    await db.close();
    temp.deleteSync(recursive: true);
  });

  Future<void> ereignis(String id, {String? ort}) =>
      db.fuegeEreignisHinzu(LebensereignisseCompanion.insert(
        id: id,
        personId: 'p1',
        art: 'umzug',
        ort: Value(ort),
      ));

  test('ohne Ortsverzeichnis geschieht nichts – und nichts bricht',
      () async {
    // Der GeoNames-Datensatz ist ein optionaler Download. Ohne ihn muss
    // der Lauf schweigend nichts tun, nicht werfen.
    await ereignis('e1', ort: 'Berlin');
    lib.geocoder = null;
    await lib.trageEreignisorteNach();
    expect(await db.ereignisseMitKoordinate(), isEmpty);
  });

  test('ein bekannter Ort bekommt seine Koordinate', () async {
    await ereignis('e1', ort: 'Berlin');
    lib.geocoder = await geocoder();
    await lib.trageEreignisorteNach();

    final mit = await db.ereignisseMitKoordinate();
    expect(mit, hasLength(1));
    expect(mit.single.ortBreite, closeTo(52.524, 0.001));
    expect(mit.single.ort, 'Berlin',
        reason: 'der aufgeschriebene Name bleibt unangetastet');
  });

  test('ein unbekannter Ort bleibt als Text stehen', () async {
    // Der wichtigste Fall der Stufe: Ein untergegangenes Dorf, ein
    // Gutshof, eine alte Schreibweise. Der Eintrag darf nicht
    // verschwinden, nur weil ihn kein Verzeichnis kennt.
    await ereignis('e1', ort: 'Gut Hohenrode');
    lib.geocoder = await geocoder();
    await lib.trageEreignisorteNach();

    expect(await db.ereignisseMitKoordinate(), isEmpty);
    final offen = await db.ereignisseOhneKoordinate();
    expect(offen.single.ort, 'Gut Hohenrode');
  });

  test('eine von Hand gesetzte Koordinate wird nicht ueberschrieben',
      () async {
    // Die Zuordnung ist eine Vermutung, und der Nutzer darf sie
    // umstossen. Ein zweiter Lauf – etwa beim naechsten Programmstart –
    // darf die Berichtigung nicht wieder wegraeumen.
    await ereignis('e1', ort: 'Berlin');
    await db.setzeEreignisort('e1', breite: 1.0, laenge: 2.0);
    lib.geocoder = await geocoder();
    await lib.trageEreignisorteNach();

    final mit = await db.ereignisseMitKoordinate();
    expect(mit.single.ortBreite, 1.0,
        reason: 'die eigene Angabe gilt, nicht die geratene');
  });

  test('bei Mehrdeutigkeit entscheidet der Schwerpunkt der Fotos',
      () async {
    // Der Grund, warum das Nachtragen im LibraryState sitzt und nicht in
    // der Datenbankschicht: Nur hier sind die verorteten Fotos greifbar.
    await ereignis('e1', ort: 'Springfield');
    // Das Foto liegt bei Springfield/ILLINOIS - und das ist mit 114.230
    // Einwohnern das KLEINERE der beiden. Genau deshalb steht es hier:
    // Läge das Foto in Missouri, gewänne dieses ohnehin nach
    // Einwohnerzahl, und der Test bestünde, ohne den Schwerpunkt je
    // gebraucht zu haben.
    await db.insertAsset(AssetsCompanion.insert(
      id: 'a1',
      relativePath: 'originals/a1.jpg',
      originalFileName: 'a1.jpg',
      type: 'IMAGE',
      fileSizeBytes: const Value(1),
      checksum: 'a1',
      fileCreatedAt: DateTime(2026),
      importedAt: DateTime(2026),
      latitude: const Value(39.8),
      longitude: const Value(-89.6),
    ));
    lib.geocoder = await geocoder();
    await lib.trageEreignisorteNach();

    final mit = await db.ereignisseMitKoordinate();
    expect(mit.single.ortBreite, closeTo(39.792, 0.001),
        reason: 'Springfield/Illinois liegt beim Foto, obwohl Missouri '
            'mehr Einwohner hat');
  });

  test('ohne verortete Fotos entscheidet die Einwohnerzahl', () async {
    // Die Gegenprobe zum Test darueber: Ohne Schwerpunkt gibt es keinen
    // Anhaltspunkt ausser der Groesse.
    await ereignis('e1', ort: 'Springfield');
    lib.geocoder = await geocoder();
    await lib.trageEreignisorteNach();

    final mit = await db.ereignisseMitKoordinate();
    expect(mit.single.ortBreite, closeTo(37.215, 0.001),
        reason: 'Springfield/MO hat 169.176 Einwohner, /IL nur 114.230');
  });
}
