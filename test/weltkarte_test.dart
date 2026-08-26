import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:photo_vault/db/database.dart';
import 'package:photo_vault/l10n/app_localizations.dart';
import 'package:photo_vault/screens/weltkarte_screen.dart';
import 'package:photo_vault/services/reverse_geocoder.dart';
import 'package:photo_vault/services/storage_paths.dart';
import 'package:photo_vault/state/library_state.dart';

/// Die Weltkarte: Steht für jedes belegte Land ein Punkt, sieht man einer
/// Marke an, woher sie stammt, und lässt sich von Hand markieren?
Future<ReverseGeocoder> _geokodierer(Directory wurzel) async {
  final staedte = File(p.join(wurzel.path, 'cities1000.txt'));
  await staedte.writeAsString(
    // Berlin ist Hauptstadt und hat weniger Einwohner als Hamburg – der
    // Landpunkt muss trotzdem Berlin sein.
    '2950159\tBerlin\tBerlin\t\t52.52437\t13.41053\tP\tPPLC\tDE\t\t16\t\t\t\t100\t\t74\tEurope/Berlin\t2023\n'
    '2911298\tHamburg\tHamburg\t\t53.55073\t9.99302\tP\tPPLA\tDE\t\t04\t\t\t\t1739117\t\t6\tEurope/Berlin\t2023\n'
    '3169070\tRoma\tRoma\t\t41.89193\t12.51133\tP\tPPLC\tIT\t\t07\t\t\t\t2318895\t\t20\tEurope/Rome\t2023\n',
  );
  final regionen = File(p.join(wurzel.path, 'admin1CodesASCII.txt'));
  await regionen.writeAsString('DE.16\tBerlin\tBerlin\t2950157\n'
      'DE.04\tHamburg\tHamburg\t2911297\n'
      'IT.07\tLazio\tLazio\t3174976\n');
  final laender = File(p.join(wurzel.path, 'countryInfo.txt'));
  await laender.writeAsString(
    '# Kopfzeile\n'
    'DE\tDEU\t276\tDE\tDeutschland\tBerlin\t357021\t82927922\tEU\t.de\tEUR\tEuro\t49\t\t\tde-DE\t2921044\t\t\n'
    'IT\tITA\t380\tIT\tItalien\tRom\t301230\t60431283\tEU\t.it\tEUR\tEuro\t39\t\t\tit-IT\t3175395\t\t\n',
  );
  return ReverseGeocoder.loadFromFiles(
      citiesFile: staedte, admin1File: regionen, countryFile: laender);
}

void main() {
  late Directory tempRoot;
  late AppDatabase db;
  late LibraryState library;
  late ReverseGeocoder geo;

  setUp(() async {
    tempRoot = Directory.systemTemp.createTempSync('pv_welt_');
    db = AppDatabase(NativeDatabase.memory());
    geo = await _geokodierer(tempRoot);
    library = LibraryState()
      ..db = db
      ..paths =
          await StoragePaths.forTesting(Directory(p.join(tempRoot.path, 'lib')))
      ..geocoder = geo;
  });

  tearDown(() async {
    await db.close();
    tempRoot.deleteSync(recursive: true);
  });

  Future<void> aufnahme(String id,
          {String? land, String? region, String? ort}) =>
      db.into(db.assets).insert(AssetsCompanion.insert(
            id: id,
            originalFileName: '$id.jpg',
            relativePath: 'originals/$id.jpg',
            checksum: 'pruef-$id',
            type: 'IMAGE',
            fileCreatedAt: DateTime(2024, 6, 3),
            importedAt: DateTime(2024),
            latitude: const Value(53.55),
            longitude: const Value(9.99),
            locationCountry: Value(land),
            locationState: Value(region),
            locationCity: Value(ort),
          ));

  Future<void> zeige(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('de'),
      localizationsDelegates: AppTexte.localizationsDelegates,
      supportedLocales: AppTexte.supportedLocales,
      home: WeltkarteScreen(library: library),
    ));
    await tester.pumpAndSettle();
  }

  group('die Punkte des Datensatzes', () {
    test('der Landpunkt ist die Hauptstadt, nicht die groesste Stadt', () {
      // Hamburg hat in diesem Auszug 17-mal so viele Einwohner wie Berlin.
      // Ein Punkt nach Einwohnerzahl saesse also falsch.
      final punkt = geo.landpunkt('DE')!;
      expect(punkt.breite, closeTo(52.524, 0.001));
      expect(punkt.laenge, closeTo(13.410, 0.001));
    });

    test('Kleinschreibung findet dasselbe Land', () {
      expect(geo.landpunkt('de'), geo.landpunkt('DE'));
    });

    test('die Region bekommt ihren groessten bekannten Ort', () {
      final punkt = geo.regionspunkt('DE.04')!;
      expect(punkt.breite, closeTo(53.550, 0.001));
    });

    test('ein Ort liegt auf seiner eigenen Koordinate', () {
      final punkt = geo.ortspunkt('IT', 'Roma')!;
      expect(punkt.breite, closeTo(41.891, 0.001));
    });

    test('was der Datensatz nicht kennt, gibt null statt einer Vermutung', () {
      expect(geo.landpunkt('FR'), isNull);
      expect(geo.regionspunkt('DE.99'), isNull);
      expect(geo.ortspunkt('DE', 'Atlantis'), isNull);
    });
  });

  testWidgets('fuer jedes belegte Land, jede Region und jeden Ort ein Punkt',
      (tester) async {
    await aufnahme('a1',
        land: 'Deutschland', region: 'Hamburg', ort: 'Hamburg');
    await zeige(tester);
    // Land, Region und Ort – drei Ebenen, drei Marken. „Hamburg" zweimal,
    // weil die Stadt zugleich ihre Region ist.
    expect(find.byTooltip('Deutschland'), findsOneWidget);
    expect(find.byTooltip('Hamburg'), findsNWidgets(2));
  });

  testWidgets('die Ebenen lassen sich einzeln abschalten', (tester) async {
    await aufnahme('a1',
        land: 'Deutschland', region: 'Hamburg', ort: 'Hamburg');
    await zeige(tester);
    expect(find.byTooltip('Deutschland'), findsOneWidget);

    // Das erste Kästchen ist „Länder" – die Reihenfolge steht in
    // _Ebenenwahl und ist dieselbe wie auf dem Schirm.
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Deutschland'), findsNothing);
    // Die anderen bleiben.
    expect(find.byTooltip('Hamburg'), findsNWidgets(2));
  });

  testWidgets('eine Marke ohne Foto laesst sich setzen und zuruecknehmen',
      (tester) async {
    await db.setzeOrtsmarke(OrtsmarkenCompanion.insert(
      art: 'land',
      schluessel: 'IT',
      name: 'Italien',
      status: 'besucht',
      angelegtAm: DateTime(2024),
    ));
    await zeige(tester);
    expect(find.byTooltip('Italien'), findsOneWidget);

    await tester.tap(find.byTooltip('Italien'));
    await tester.pumpAndSettle();
    // Ohne ein einziges Foto: Die Karte sagt, dass die Marke von Hand ist.
    expect(find.text('von Hand'), findsOneWidget);
    await tester.tap(find.text('Marke entfernen'));
    await tester.pumpAndSettle();

    expect(await db.alleOrtsmarken(), isEmpty);
    expect(find.byTooltip('Italien'), findsNothing);
  });

  testWidgets('ein geplantes Land steht auf der Karte, ohne belegt zu sein',
      (tester) async {
    await db.setzeOrtsmarke(OrtsmarkenCompanion.insert(
      art: 'land',
      schluessel: 'IT',
      name: 'Italien',
      status: 'geplant',
      angelegtAm: DateTime(2024),
    ));
    await zeige(tester);
    await tester.tap(find.byTooltip('Italien'));
    await tester.pumpAndSettle();
    // „Als besucht markieren" steht bereit – aus geplant wird besucht.
    expect(find.text('Als besucht markieren'), findsOneWidget);
  });

  testWidgets('ohne Datensatz bleibt die Karte leer statt zu werfen',
      (tester) async {
    library.geocoder = null;
    await zeige(tester);
    expect(find.byType(FlutterMap), findsOneWidget);
  });
}
