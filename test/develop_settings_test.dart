import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_vault/db/database.dart';

/// Prüft die DB-Seite der nicht-destruktiven Bildentwicklung (siehe
/// DevelopScreen): Speichern/Zurücksetzen der Einstellungen samt
/// `Assets.developedRelativePath`, sowie dass der destruktive
/// Bild-Editor (setEditedAssetFile) einen evtl. veralteten entwickelten
/// Cache zurücksetzt.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<String> insertAsset(String id, {bool isLocked = false}) async {
    await db.into(db.assets).insert(AssetsCompanion.insert(
          id: id,
          originalFileName: '$id.jpg',
          relativePath: 'originals/$id.jpg',
          checksum: 'checksum_$id',
          type: 'IMAGE',
          fileCreatedAt: DateTime(2024, 1, 1),
          importedAt: DateTime(2024, 1, 1),
          isLocked: Value(isLocked),
        ));
    return id;
  }

  test('saveDevelopResult speichert Einstellungen und developedRelativePath in einem Zug', () async {
    final assetId = await insertAsset('a');

    await db.saveDevelopResult(
      assetId,
      settings: DevelopSettingsCompanion.insert(
        assetId: assetId,
        exposure: const Value(0.5),
        temperature: const Value(5600),
        tint: const Value(-10),
        contrast: const Value(0.2),
        shadows: const Value(0.3),
        sharpness: const Value(0.4),
        noiseReduction: const Value(0.1),
        lensCorrectionEnabled: const Value(false),
        updatedAt: DateTime(2024, 6, 1),
      ),
      developedRelativePath: 'developed/a.jpg',
    );

    final asset = await db.assetById(assetId);
    expect(asset!.developedRelativePath, 'developed/a.jpg');

    final settings = await db.developSettingsForAsset(assetId);
    expect(settings, isNotNull);
    expect(settings!.exposure, closeTo(0.5, 1e-9));
    expect(settings.temperature, closeTo(5600, 1e-9));
    expect(settings.tint, closeTo(-10, 1e-9));
    expect(settings.contrast, closeTo(0.2, 1e-9));
    expect(settings.shadows, closeTo(0.3, 1e-9));
    expect(settings.sharpness, closeTo(0.4, 1e-9));
    expect(settings.noiseReduction, closeTo(0.1, 1e-9));
    expect(settings.lensCorrectionEnabled, isFalse);
  });

  test('saveDevelopResult auf bereits entwickeltem Asset überschreibt die alten Einstellungen', () async {
    final assetId = await insertAsset('a');
    await db.saveDevelopResult(
      assetId,
      settings: DevelopSettingsCompanion.insert(assetId: assetId, updatedAt: DateTime(2024, 1, 1)),
      developedRelativePath: 'developed/a.jpg',
    );
    await db.saveDevelopResult(
      assetId,
      settings: DevelopSettingsCompanion.insert(
        assetId: assetId,
        exposure: const Value(1.5),
        updatedAt: DateTime(2024, 1, 2),
      ),
      developedRelativePath: 'developed/a.jpg',
    );

    final all = await db.select(db.developSettings).get();
    expect(all, hasLength(1)); // kein zweiter Datensatz für dasselbe Asset
    expect(all.single.exposure, closeTo(1.5, 1e-9));
  });

  test('resetDevelopSettings löscht die Einstellungen und setzt developedRelativePath zurück', () async {
    final assetId = await insertAsset('a');
    await db.saveDevelopResult(
      assetId,
      settings: DevelopSettingsCompanion.insert(assetId: assetId, updatedAt: DateTime(2024, 1, 1)),
      developedRelativePath: 'developed/a.jpg',
    );

    await db.resetDevelopSettings(assetId);

    expect(await db.developSettingsForAsset(assetId), isNull);
    expect((await db.assetById(assetId))!.developedRelativePath, isNull);
  });

  test('resetDevelopSettings auf nie entwickeltem Asset ist ein günstiges No-Op', () async {
    final assetId = await insertAsset('a');
    await db.resetDevelopSettings(assetId); // darf nicht werfen
    expect(await db.developSettingsForAsset(assetId), isNull);
  });

  test('assetsWithDevelopSettings liefert nur entwickelte, nicht gelöschte Assets', () async {
    final developed = await insertAsset('developed');
    await insertAsset('untouched');
    final trashed = await insertAsset('trashed');

    await db.saveDevelopResult(
      developed,
      settings: DevelopSettingsCompanion.insert(assetId: developed, updatedAt: DateTime(2024, 1, 1)),
      developedRelativePath: 'developed/developed.jpg',
    );
    await db.saveDevelopResult(
      trashed,
      settings: DevelopSettingsCompanion.insert(assetId: trashed, updatedAt: DateTime(2024, 1, 1)),
      developedRelativePath: 'developed/trashed.jpg',
    );
    await db.moveToTrash([trashed]);

    final entries = await db.assetsWithDevelopSettings();
    expect(entries.map((e) => e.$1.id), [developed]);
  });

  test('assetsWithDevelopSettings schließt gesperrte Assets aus (kein Rendern aus verschlüsselter Datei)', () async {
    final locked = await insertAsset('locked', isLocked: true);
    final unlocked = await insertAsset('unlocked');

    for (final id in [locked, unlocked]) {
      await db.saveDevelopResult(
        id,
        settings: DevelopSettingsCompanion.insert(assetId: id, updatedAt: DateTime(2024, 1, 1)),
        developedRelativePath: 'developed/$id.jpg',
      );
    }

    final entries = await db.assetsWithDevelopSettings();
    expect(entries.map((e) => e.$1.id), [unlocked]);
  });

  test('saveDevelopResult schiebt beim ERSTEN Speichern noch keinen Verlaufs-Eintrag (kein vorheriger Stand)',
      () async {
    final assetId = await insertAsset('a');
    await db.saveDevelopResult(
      assetId,
      settings: DevelopSettingsCompanion.insert(assetId: assetId, updatedAt: DateTime(2024, 1, 1)),
      developedRelativePath: 'developed/a.jpg',
    );

    expect(await db.developHistoryForAsset(assetId), isEmpty);
  });

  test('saveDevelopResult schiebt beim ZWEITEN Speichern den bisherigen Stand in die Historie', () async {
    final assetId = await insertAsset('a');
    await db.saveDevelopResult(
      assetId,
      settings: DevelopSettingsCompanion.insert(
        assetId: assetId,
        exposure: const Value(0.5),
        updatedAt: DateTime(2024, 1, 1),
      ),
      developedRelativePath: 'developed/a.jpg',
    );
    await db.saveDevelopResult(
      assetId,
      settings: DevelopSettingsCompanion.insert(
        assetId: assetId,
        exposure: const Value(1.5),
        updatedAt: DateTime(2024, 1, 2),
      ),
      developedRelativePath: 'developed/a.jpg',
    );

    final history = await db.developHistoryForAsset(assetId);
    expect(history, hasLength(1));
    expect(history.single.exposure, closeTo(0.5, 1e-9)); // der ERSETZTE (alte) Stand, nicht der neue
  });

  test('developHistoryForAsset kürzt auf die neuesten 10 Einträge pro Asset', () async {
    final assetId = await insertAsset('a');
    // 12 Speicher-Vorgänge → 11 vorherige Stände werden ersetzt/landen in
    // der Historie, davon sollen nur die neuesten 10 überleben.
    for (var i = 0; i < 12; i++) {
      await db.saveDevelopResult(
        assetId,
        settings: DevelopSettingsCompanion.insert(
          assetId: assetId,
          exposure: Value(i.toDouble()),
          updatedAt: DateTime(2024, 1, 1).add(Duration(minutes: i)),
        ),
        developedRelativePath: 'developed/a.jpg',
      );
    }

    final history = await db.developHistoryForAsset(assetId);
    expect(history, hasLength(10));
    // 12 Speicher-Vorgänge ersetzen 11 vorherige Stände (exposure 0..10) –
    // der älteste (exposure 0) wird herausgekürzt, 1..10 bleiben erhalten.
    expect(history.map((h) => h.exposure).toSet(), {1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0});
  });

  test('developHistoryForAsset liefert nur Einträge des angefragten Assets, neueste zuerst', () async {
    final a = await insertAsset('a');
    final b = await insertAsset('b');
    for (final id in [a, b]) {
      await db.saveDevelopResult(
        id,
        settings: DevelopSettingsCompanion.insert(assetId: id, updatedAt: DateTime(2024, 1, 1)),
        developedRelativePath: 'developed/$id.jpg',
      );
      await db.saveDevelopResult(
        id,
        settings: DevelopSettingsCompanion.insert(
          assetId: id,
          exposure: const Value(1),
          updatedAt: DateTime(2024, 1, 2),
        ),
        developedRelativePath: 'developed/$id.jpg',
      );
    }

    final historyA = await db.developHistoryForAsset(a);
    expect(historyA, hasLength(1));
  });

  test('setEditedAssetFile (destruktiver Editor) setzt einen veralteten entwickelten Cache zurück', () async {
    final assetId = await insertAsset('a');
    await db.saveDevelopResult(
      assetId,
      settings: DevelopSettingsCompanion.insert(assetId: assetId, updatedAt: DateTime(2024, 1, 1)),
      developedRelativePath: 'developed/a.jpg',
    );

    await db.setEditedAssetFile(assetId, relativePath: 'originals/a.jpg', checksum: 'new-checksum');

    final asset = await db.assetById(assetId);
    expect(asset!.developedRelativePath, isNull);
    // Die DevelopSettings-Zeile selbst bleibt bestehen (Nutzer müsste sie
    // sonst nach jedem Zuschnitt neu einstellen).
    expect(await db.developSettingsForAsset(assetId), isNotNull);
  });
}
