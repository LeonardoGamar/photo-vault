import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:photo_vault/db/database.dart';
import 'package:photo_vault/l10n/app_localizations.dart';
import 'package:photo_vault/screens/reise_detail_screen.dart';
import 'package:photo_vault/screens/laenderliste_screen.dart';
import 'package:photo_vault/screens/reisen_screen.dart';
import 'package:photo_vault/services/backup_service.dart';
import 'package:photo_vault/services/reverse_geocoder.dart';
import 'package:photo_vault/services/storage_paths.dart';
import 'package:photo_vault/state/library_state.dart';
import 'package:photo_vault/theme/app_theme.dart';
import 'package:photo_vault/widgets/asset_thumbnail_tile.dart';

/// Der Weg vom Vorschlag zur bestätigten Reise.
///
/// Die Erkennung ist in reisen_test.dart geprüft, die Datenbank in
/// reisen_db_test.dart. Hier geht es um den Weg dazwischen — den, den
/// Tests, die die Rechnung unmittelbar aufrufen, nicht sehen: Wird der
/// Vorschlag angezeigt, führt der Knopf zur Rückfrage, und steht danach
/// wirklich eine Reise in der Datenbank?
Future<ReverseGeocoder> _geokodierer(Directory wurzel) async {
  final staedte = File(p.join(wurzel.path, 'cities1000.txt'));
  await staedte.writeAsString(
    '2950159\tBerlin\tBerlin\t\t52.52437\t13.41053\tP\tPPLC\tDE\t\t16\t\t\t\t3426354\t\t74\tEurope/Berlin\t2023\n'
    '3169070\tRoma\tRoma\t\t41.89193\t12.51133\tP\tPPLC\tIT\t\t07\tRM\t\t\t2318895\t\t20\tEurope/Rome\t2023\n',
  );
  final regionen = File(p.join(wurzel.path, 'admin1CodesASCII.txt'));
  await regionen.writeAsString(
      'DE.16\tBerlin\tBerlin\t2950157\nIT.07\tLazio\tLazio\t3174976\n');
  final laender = File(p.join(wurzel.path, 'countryInfo.txt'));
  await laender.writeAsString(
    '# Kopfzeile\n'
    'DE\tDEU\t276\tDE\tDeutschland\tBerlin\t357021\t82927922\tEU\t.de\tEUR\tEuro\t49\t\t\tde-DE\t2921044\t\t\n'
    'IT\tITA\t380\tIT\tItalien\tRom\t301230\t60431283\tEU\t.it\tEUR\tEuro\t39\t\t\tit-IT\t3175395\t\t\n'
    'FR\tFRA\t250\tFR\tFrankreich\tParis\t547030\t67059887\tEU\t.fr\tEUR\tEuro\t33\t\t\tfr-FR\t3017382\t\t\n'
    'ES\tESP\t724\tES\tSpanien\tMadrid\t504782\t46723749\tEU\t.es\tEUR\tEuro\t34\t\t\tes-ES\t2510769\t\t\n',
  );
  return ReverseGeocoder.loadFromFiles(
      citiesFile: staedte, admin1File: regionen, countryFile: laender);
}

void main() {
  late Directory tempRoot;
  late AppDatabase db;
  late LibraryState library;

  setUp(() async {
    tempRoot = Directory.systemTemp.createTempSync('pv_reisen_');
    db = AppDatabase(NativeDatabase.memory());
    final paths =
        await StoragePaths.forTesting(Directory(p.join(tempRoot.path, 'lib')));
    library = LibraryState()
      ..db = db
      ..paths = paths
      ..backupService = BackupService(db, paths)
      // Ein winziger GeoNames-Auszug: Ohne ihn gibt es keine Laenderzahl,
      // gegen die sich zaehlen liesse.
      ..geocoder = await _geokodierer(tempRoot);

    Future<void> aufnahme(String id, DateTime zeit, double b, double l,
            String stadt, String land) =>
        db.into(db.assets).insert(AssetsCompanion.insert(
              id: id,
              originalFileName: '$id.jpg',
              relativePath: 'originals/$id.jpg',
              checksum: 'pruef-$id',
              type: 'IMAGE',
              fileCreatedAt: zeit,
              importedAt: DateTime(2024),
              latitude: Value(b),
              longitude: Value(l),
              locationCity: Value(stadt),
              locationCountry: Value(land),
            ));

    // Hamburg als Wohnort: sechzig verschiedene Tage.
    for (var t = 0; t < 60; t++) {
      await aufnahme('h$t', DateTime(2024, 1, 1).add(Duration(days: t)), 53.55,
          9.99, 'Hamburg', 'Deutschland');
    }
    // Sechs Tage Rom, je vier Aufnahmen.
    for (var t = 0; t < 6; t++) {
      for (var i = 0; i < 4; i++) {
        await aufnahme('r$t-$i',
            DateTime(2024, 6, 3, 9, i * 10).add(Duration(days: t)), 41.90,
            12.50, 'Roma', 'Italien');
      }
    }
  });

  tearDown(() async {
    await db.close();
    tempRoot.deleteSync(recursive: true);
  });

  Future<void> zeige(WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('de'),
      localizationsDelegates: AppTexte.localizationsDelegates,
      supportedLocales: AppTexte.supportedLocales,
      theme: buildDarkTheme(),
      home: ReisenScreen(library: library),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('der Vorschlag steht da, bevor jemand etwas eintippt',
      (tester) async {
    await zeige(tester);
    expect(find.text('Roma'), findsOneWidget);
    // Zeitraum, Nächte und Zahl der Aufnahmen in einer Zeile.
    expect(find.textContaining('5 Nächte'), findsOneWidget);
    expect(find.textContaining('24 Aufnahmen'), findsOneWidget);
    expect(find.text('War eine Reise'), findsOneWidget);
  });

  testWidgets('vom Vorschlag zur bestaetigten Reise', (tester) async {
    await zeige(tester);
    await tester.tap(find.text('War eine Reise'));
    await tester.pumpAndSettle();

    // Der vorgeschlagene Name steht schon im Feld – meistens stimmt er.
    expect(find.text('Reise benennen'), findsOneWidget);
    expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Roma');
    await tester.enterText(find.byType(TextField), 'Rom im Juni');
    await tester.tap(find.text('Übernehmen'));
    await tester.pumpAndSettle();

    final reisen = await db.alleReisen();
    expect(reisen.single.name, 'Rom im Juni');
    expect(await db.zugeordneteReiseAufnahmen(), hasLength(24));

    // Und der Vorschlag ist weg, weil seine Aufnahmen jetzt zugeordnet sind.
    expect(find.text('War eine Reise'), findsNothing);
    expect(find.text('Rom im Juni'), findsOneWidget);
  });

  testWidgets('abgelehnt heisst abgelehnt', (tester) async {
    // Ein Vorschlag, den man dreimal wegwischen muss, ist eine
    // Belaestigung.
    await zeige(tester);
    await tester.tap(find.text('Keine Reise'));
    await tester.pumpAndSettle();
    expect(find.text('Roma'), findsNothing);
    expect(await db.verworfeneReisevorschlaege(), hasLength(1));

    // Auch nach erneutem Suchen.
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();
    expect(find.text('Roma'), findsNothing);
  });

  testWidgets('eine bestaetigte Reise laesst sich oeffnen', (tester) async {
    await zeige(tester);
    await tester.tap(find.text('War eine Reise'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Übernehmen'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Roma'));
    await tester.pumpAndSettle();
    expect(find.byType(ReiseDetailScreen), findsOneWidget);
    expect(find.text('Besuchte Orte'), findsOneWidget);
    // Der Ort steht als Chip und als Titel – deshalb mehrfach.
    expect(find.text('Roma'), findsWidgets);
  });

  testWidgets('eine Notiz laesst sich schreiben und wieder loeschen',
      (tester) async {
    // „Bewertung, Notizen, Tags" gab es bisher je Foto, nicht je Reise.
    await zeige(tester);
    await tester.tap(find.text('War eine Reise'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Übernehmen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Roma'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.notes_outlined));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Mit dem Nachtzug hin.');
    await tester.tap(find.text('Übernehmen'));
    await tester.pumpAndSettle();
    expect(find.text('Mit dem Nachtzug hin.'), findsOneWidget);

    // Leerer Text heisst „keine Notiz" – so nimmt man sie wieder weg.
    await tester.tap(find.byIcon(Icons.notes_outlined));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.text('Übernehmen'));
    await tester.pumpAndSettle();
    expect(find.text('Mit dem Nachtzug hin.'), findsNothing);
    expect((await db.alleReisen()).single.notiz, isNull);
  });

  testWidgets('die Reiseansicht zeigt Route und Tageskapitel',
      (tester) async {
    await zeige(tester);
    await tester.tap(find.text('War eine Reise'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Übernehmen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Roma'));
    await tester.pumpAndSettle();

    // Sechs Tage, sechs Kapitel – ein durchgehendes Raster von 24 Bildern
    // beantwortet die Frage nicht, die man an eine Reise stellt. Gezählt
    // wird nicht auf sechs: Die Kapitel weiter unten sind noch gar nicht
    // gebaut, und ein Test, der das übersieht, prüft die Bildschirmhöhe
    // statt die Gliederung.
    expect(find.text('Montag, 3. Juni 2024 · Roma'), findsOneWidget);
    expect(find.textContaining('4 Aufnahmen'), findsWidgets);

    // Alle Aufnahmen liegen an derselben Stelle – dann gibt es keine
    // Strecke, und das steht auch da.
    expect(find.text('Ohne verortete Aufnahme gibt es keine Strecke.'),
        findsOneWidget);

    // Und das letzte Kapitel ist erreichbar.
    await tester.scrollUntilVisible(
        find.text('Samstag, 8. Juni 2024 · Roma'), 300);
  });

  testWidgets('bei mehreren Orten wird eine Strecke gezeichnet',
      (tester) async {
    // Florenz dazu: Erst wenn sich die Orte unterscheiden, gibt es eine
    // Linie zu zeichnen.
    for (var i = 0; i < 4; i++) {
      await db.into(db.assets).insert(AssetsCompanion.insert(
            id: 'f$i',
            originalFileName: 'f$i.jpg',
            relativePath: 'originals/f$i.jpg',
            checksum: 'pruef-f$i',
            type: 'IMAGE',
            fileCreatedAt: DateTime(2024, 6, 5, 14, i * 10),
            importedAt: DateTime(2024),
            latitude: const Value(43.77),
            longitude: const Value(11.26),
            locationCity: const Value('Firenze'),
            locationCountry: const Value('Italien'),
          ));
    }
    await zeige(tester);
    await tester.tap(find.text('War eine Reise'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Übernehmen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Roma – Firenze'));
    await tester.pumpAndSettle();

    expect(find.text('Route'), findsOneWidget);
    expect(find.byType(PolylineLayer), findsOneWidget);
    expect(find.text('Ohne verortete Aufnahme gibt es keine Strecke.'),
        findsNothing);
  });

  testWidgets('ein langer Druck macht ein Bild zum Titelbild', (tester) async {
    await zeige(tester);
    await tester.tap(find.text('War eine Reise'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Übernehmen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Roma'));
    await tester.pumpAndSettle();

    await tester.longPress(find.byType(AssetThumbnailTile).first);
    await tester.pumpAndSettle();
    // Ein Menue und keine stille Aenderung: Eine Geste, die etwas tut,
    // ohne es zu sagen, findet man nur durch Zufall wieder.
    await tester.tap(find.text('Als Titelbild'));
    await tester.pumpAndSettle();
    expect(find.text('Titelbild gesetzt.'), findsOneWidget);
    expect((await db.alleReisen()).single.titelbildAssetId, isNotNull);
  });

  testWidgets('der Laenderzaehler steht ueber den Reisen', (tester) async {
    // „41 von 252 Laendern" ist der Zaehler, den andere Tagebuecher von
    // Hand fuettern lassen. Hier stand er laengst in der Datenbank.
    await zeige(tester);
    expect(find.text('2 von 4 Ländern'), findsOneWidget);
    // Zwei Orte, aber keine Region: Die Aufnahmen dieses Tests tragen
    // keine, und das kommt auch echt vor – bei Stadtstaaten und
    // Kleinstaaten laesst die Umkehr-Geokodierung sie leer. Ein Ort ohne
    // Region bleibt trotzdem ein besuchter Ort.
    expect(find.textContaining('2 Orte'), findsOneWidget);
    expect(find.textContaining('0 Regionen'), findsOneWidget);
  });

  testWidgets('der Zaehler fuehrt zur Laenderliste', (tester) async {
    await zeige(tester);
    await tester.tap(find.text('2 von 4 Ländern'));
    await tester.pumpAndSettle();
    expect(find.byType(LaenderlisteScreen), findsOneWidget);
    // Alle vier Laender des Datensatzes, nicht nur die besuchten: Ein
    // Zaehler „2 von 4" ohne die anderen zwei waere eine halbe Auskunft.
    for (final name in ['Deutschland', 'Italien', 'Frankreich', 'Spanien']) {
      expect(find.text(name), findsOneWidget);
    }
    // Und die Zahl, gegen die gezaehlt wird, wird erklaert statt
    // behauptet.
    expect(find.textContaining('195 souveränen Staaten'), findsOneWidget);
  });

  testWidgets('ohne verortete Aufnahmen erklaert der Bildschirm sich selbst',
      (tester) async {
    await db.delete(db.assets).go();
    await zeige(tester);
    expect(find.textContaining('erkennt sie'), findsOneWidget);
  });

  testWidgets('jeder Aufenthaltsort bekommt eine Bildmarke auf der Karte',
      (tester) async {
    // Punkt 5 der Wunschliste: nicht nackte Kreise, sondern das Bild, das
    // dort entstanden ist – und die Zahl, wie viele es sind.
    //
    // Rom liegt schon aus dem setUp bereit (24 Aufnahmen an sechs Tagen).
    // Dazu ein Bild aus Florenz, 230 km entfernt: Das muss ein zweiter
    // Ort werden, sonst faende die Zusammenfassung ueberhaupt keine
    // Grenze.
    await db.into(db.assets).insert(AssetsCompanion.insert(
          id: 'flo',
          originalFileName: 'flo.jpg',
          relativePath: 'originals/flo.jpg',
          checksum: 'pruef-flo',
          type: 'IMAGE',
          fileCreatedAt: DateTime(2024, 6, 12, 10),
          importedAt: DateTime(2024),
          latitude: const Value(43.7696),
          longitude: const Value(11.2558),
          locationCity: const Value('Firenze'),
          locationCountry: const Value('Italien'),
        ));
    await db.reiseAnlegen(
      ReisenCompanion.insert(
        id: 'r1',
        name: 'Italien',
        von: DateTime(2024, 6, 3),
        bis: DateTime(2024, 6, 12),
        angelegtAm: DateTime(2024, 7, 1),
      ),
      [
        for (var t = 0; t < 6; t++)
          for (var i = 0; i < 4; i++) 'r$t-$i',
        'flo',
      ],
    );

    tester.view.physicalSize = const Size(900, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('de'),
      localizationsDelegates: AppTexte.localizationsDelegates,
      supportedLocales: AppTexte.supportedLocales,
      theme: buildDarkTheme(),
      home: ReiseDetailScreen(
          library: library, reise: (await db.alleReisen()).single),
    ));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Roma · 24 Aufnahmen'), findsOneWidget);
    expect(find.byTooltip('Firenze · eine Aufnahme'), findsOneWidget);
    // Die Zahl steht an der Marke – aber nur, wo mehr als eine ist.
    expect(find.text('24'), findsOneWidget);
  });
}
