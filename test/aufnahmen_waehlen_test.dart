import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:photo_vault/db/database.dart';
import 'package:photo_vault/l10n/app_localizations.dart';
import 'package:photo_vault/screens/aufnahmen_waehlen_screen.dart';
import 'package:photo_vault/services/backup_service.dart';
import 'package:photo_vault/services/storage_paths.dart';
import 'package:photo_vault/state/library_state.dart';
import 'package:photo_vault/theme/app_theme.dart';
import 'package:photo_vault/widgets/asset_thumbnail_tile.dart';

/// Das Raster, in dem man die Fotos einer Reise oder Aktivität anhakt.
void main() {
  late Directory wurzel;
  late AppDatabase db;
  late LibraryState bib;

  setUp(() async {
    wurzel = Directory.systemTemp.createTempSync('pv_wahl_');
    db = AppDatabase(NativeDatabase.memory());
    final pfade = await StoragePaths.forTesting(Directory(p.join(wurzel.path, 'lib')));
    bib = LibraryState()
      ..db = db
      ..paths = pfade
      ..backupService = BackupService(db, pfade);
    // Drei am 14. Juni, eines eine Woche vorher.
    for (final (id, tag, stunde) in [
      ('a0', 14, 9),
      ('a1', 14, 10),
      ('a2', 14, 11),
      ('alt', 7, 9),
    ]) {
      await db.into(db.assets).insert(AssetsCompanion.insert(
            id: id,
            originalFileName: '$id.jpg',
            relativePath: 'originals/$id.jpg',
            checksum: 'c-$id',
            type: 'IMAGE',
            fileCreatedAt: DateTime(2026, 6, tag, stunde),
            importedAt: DateTime(2026),
          ));
    }
  });

  tearDown(() async {
    await db.close();
    wurzel.deleteSync(recursive: true);
  });

  /// Ein Behälter für das Ergebnis: Der Bildschirm gibt es erst
  /// zurück, wenn er verlassen wird – lange nachdem [zeige] fertig ist.
  final ergebnisse = <String, Set<String>?>{};

  Future<void> zeige(WidgetTester tester,
      {required Set<String> vorhanden}) async {
    ergebnisse.clear();
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('de'),
      localizationsDelegates: AppTexte.localizationsDelegates,
      supportedLocales: AppTexte.supportedLocales,
      theme: buildDarkTheme(),
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                ergebnisse['wahl'] = await Navigator.of(context).push<Set<String>>(
                  MaterialPageRoute(
                    builder: (_) => AufnahmenWaehlenScreen(
                      library: bib,
                      titel: 'Fotos',
                      vorhanden: vorhanden,
                      von: DateTime(2026, 6, 14, 9),
                      bis: DateTime(2026, 6, 14, 11),
                    ),
                  ),
                );
              },
              child: const Text('auf'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('auf'));
    // Bis der Übergang durch ist: Während die Seite hereinschiebt,
    // liegt ihre Leiste noch neben dem Fenster, und ein Tipp darauf
    // ginge ins Leere.
    await tester.pumpAndSettle();
  }

  Future<void> raeumeAb(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  }

  testWidgets('der Zeitraum ist die Voreinstellung, nicht die Grenze',
      (tester) async {
    await zeige(tester, vorhanden: {'a0', 'a1'});
    // Drei aus dem Zeitraum – das alte Foto ist nicht dabei.
    expect(find.byType(AssetThumbnailTile), findsNWidgets(3));

    await tester.tap(find.text('Alle Fotos'));
    await tester.pumpAndSettle();
    expect(find.byType(AssetThumbnailTile), findsNWidgets(4));
    await raeumeAb(tester);
  });

  testWidgets('Antippen hakt an und wieder ab', (tester) async {
    await zeige(tester, vorhanden: {'a0'});
    expect(find.textContaining('1 Foto gewählt'), findsOneWidget);

    await tester.tap(find.byType(AssetThumbnailTile).at(1));
    await tester.pump();
    expect(find.textContaining('2 Fotos gewählt'), findsOneWidget);

    await tester.tap(find.byType(AssetThumbnailTile).at(1));
    await tester.pump();
    expect(find.textContaining('1 Foto gewählt'), findsOneWidget);
    await raeumeAb(tester);
  });

  testWidgets('was nicht im Bild steht, fällt nicht heraus', (tester) async {
    // DIE Eigenschaft. Das alte Foto gehört dazu, liegt aber ausserhalb
    // des gezeigten Zeitraums. Würde die Ansicht ihre Auswahl aus dem
    // Sichtbaren bilden, verschwände es beim Sichern still.
    await zeige(tester, vorhanden: {'a0', 'alt'});
    expect(find.textContaining('2 Fotos gewählt'), findsOneWidget);
    expect(find.textContaining('1 davon ausserhalb'), findsOneWidget);

    await tester.tap(find.text('Fertig'));
    await tester.pumpAndSettle();
    expect(ergebnisse['wahl'], {'a0', 'alt'});
    await raeumeAb(tester);
  });

  testWidgets('Zurück ohne Fertig gibt nichts zurück', (tester) async {
    // Ein Zurück darf die Zuordnung nicht leeren: Der Aufrufer bekommt
    // `null` und lässt alles, wie es war.
    await zeige(tester, vorhanden: {'a0'});
    await tester.tap(find.byType(AssetThumbnailTile).first);
    await tester.pump();
    // Nicht `pageBack()`: Das sucht den Knopf über seinen englischen
    // Kurzhinweis, und diese Ansicht läuft auf Deutsch.
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(ergebnisse['wahl'], isNull);
    await raeumeAb(tester);
  });
}
