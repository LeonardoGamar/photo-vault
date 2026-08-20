import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:photo_vault/db/database.dart';
import 'package:photo_vault/l10n/app_localizations.dart';
import 'package:photo_vault/services/storage_paths.dart';
import 'package:photo_vault/widgets/asset_info_sheet.dart';

/// Die deutschen KI-Bildunterschriften wurden zwar erzeugt und mitdurchsucht,
/// aber nirgends angezeigt – die Info-Ansicht zeigte immer das englische
/// Original. Und wer die Übersetzung erst nachträglich einschaltete, hatte
/// keinen Weg, die vorhandenen Sätze zu übertragen, ohne das
/// Beschreibungsmodell über die ganze Bibliothek erneut laufen zu lassen.
void main() {
  late Directory tempRoot;
  late AppDatabase db;
  late StoragePaths paths;

  setUp(() async {
    tempRoot = Directory.systemTemp.createTempSync('pv_caption_de_');
    db = AppDatabase(NativeDatabase.memory());
    paths = await StoragePaths.forTesting(Directory(p.join(tempRoot.path, 'lib')));
  });

  tearDown(() async {
    await db.close();
    tempRoot.deleteSync(recursive: true);
  });

  Future<AssetData> lege(String id,
      {String? englisch, String? deutsch, bool gesperrt = false}) async {
    await db.into(db.assets).insert(AssetsCompanion.insert(
          id: id,
          originalFileName: '$id.heic',
          relativePath: 'originals/$id.heic',
          checksum: id,
          fileCreatedAt: DateTime(2024, 5, 1),
          importedAt: DateTime(2024, 5, 2),
          type: 'IMAGE',
          aiCaption: Value(englisch),
          aiCaptionDe: Value(deutsch),
          aiCaptionScanned: Value(englisch != null),
          isLocked: Value(gesperrt),
        ));
    return (await db.assetById(id))!;
  }

  test('zu übersetzen ist genau das, was englisch vorliegt und noch kein Deutsch hat',
      () async {
    await lege('a', englisch: 'a dog on a beach');
    await lege('b', englisch: 'a cat', deutsch: 'eine Katze');
    await lege('c'); // noch gar keine Beschreibung
    await lege('d', englisch: ''); // leerer Satz zählt nicht als vorhanden
    await lege('e', englisch: 'a locked photo', gesperrt: true);

    final offen = await db.assetsForCaptionTranslation();
    expect(offen.map((a) => a.id), ['a']);

    // Die Zählung muss exakt zur Liste passen – dieselbe Zusicherung wie für
    // alle anderen Aufgaben (siehe background_task_counts_test.dart).
    expect(await db.countCaptionTranslation(), 1);

    // Nach einem Modellwechsel will man alles neu übersetzen.
    final alle = await db.assetsForCaptionTranslation(alle: true);
    expect(alle.map((a) => a.id).toList()..sort(), ['a', 'b']);
  });

  test('setAiCaptionDe lässt das englische Original und das Merkmal unberührt', () async {
    await lege('a', englisch: 'a dog on a beach');
    await db.setAiCaptionDe('a', 'ein Hund am Strand');

    final nachher = (await db.assetById('a'))!;
    expect(nachher.aiCaptionDe, 'ein Hund am Strand');
    expect(nachher.aiCaption, 'a dog on a beach',
        reason: 'das Original bleibt, sonst wäre ein Abschalten der '
            'Übersetzung nur über einen neuen Modelldurchlauf rückgängig zu machen');
    expect(nachher.aiCaptionScanned, isTrue);
    expect(await db.countCaptionTranslation(), 0);
  });

  Future<void> zeigeInfo(WidgetTester tester, AssetData asset, Locale sprache) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      locale: sprache,
      localizationsDelegates: AppTexte.localizationsDelegates,
      supportedLocales: AppTexte.supportedLocales,
      home: Scaffold(
        body: AssetInfoSheet(
          asset: asset,
          db: db,
          paths: paths,
          onUpdated: (_) {},
          onClose: () {},
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
  }

  testWidgets('bei deutscher Oberfläche steht die deutsche Fassung da', (tester) async {
    final asset = await lege('a', englisch: 'a dog on a beach', deutsch: 'ein Hund am Strand');
    await zeigeInfo(tester, asset, const Locale('de'));

    expect(find.text('ein Hund am Strand'), findsOneWidget);
    expect(find.text('a dog on a beach'), findsNothing);
    expect(find.text('KI-Beschreibung'), findsOneWidget);
  });

  testWidgets('ohne Übersetzung sagt die Beschriftung, dass der Satz englisch ist',
      (tester) async {
    final asset = await lege('a', englisch: 'a dog on a beach');
    await zeigeInfo(tester, asset, const Locale('de'));

    expect(find.text('a dog on a beach'), findsOneWidget);
    expect(find.text('KI-Beschreibung · Englisch'), findsOneWidget);
  });

  testWidgets('bei englischer Oberfläche bleibt es beim Original', (tester) async {
    final asset = await lege('a', englisch: 'a dog on a beach', deutsch: 'ein Hund am Strand');
    await zeigeInfo(tester, asset, const Locale('en'));

    expect(find.text('a dog on a beach'), findsOneWidget);
    expect(find.text('ein Hund am Strand'), findsNothing);
  });
}
