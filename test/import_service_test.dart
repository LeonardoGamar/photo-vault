import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:photo_vault/db/database.dart';
import 'package:photo_vault/services/import_service.dart';
import 'package:photo_vault/services/storage_paths.dart';

void main() {
  late Directory tempRoot;
  late Directory sourceDir;
  late AppDatabase db;
  late StoragePaths paths;
  late ImportService importService;

  setUp(() async {
    tempRoot = Directory.systemTemp.createTempSync('photo_vault_import_test_');
    sourceDir = Directory(p.join(tempRoot.path, 'incoming'))..createSync();
    paths = await StoragePaths.forTesting(Directory(p.join(tempRoot.path, 'library')));
    db = AppDatabase(NativeDatabase.memory());
    importService = ImportService(db, paths);
  });

  tearDown(() async {
    await db.close();
    tempRoot.deleteSync(recursive: true);
  });

  test('isSupported erkennt Bild- und Videoformate unabhängig von Groß-/Kleinschreibung', () {
    expect(importService.isSupported('foto.JPG'), isTrue);
    expect(importService.isSupported('foto.heic'), isTrue);
    expect(importService.isSupported('foto.avif'), isTrue);
    expect(importService.isSupported('foto.AVIFS'), isTrue);
    expect(importService.isSupported('clip.MOV'), isTrue);
    expect(importService.isSupported('dokument.txt'), isFalse);
  });

  test('isSupported erkennt RAW-Formate weiterer Hersteller, nicht nur DNG', () {
    expect(importService.isSupported('foto.dng'), isTrue);
    expect(importService.isSupported('foto.CR2'), isTrue);
    expect(importService.isSupported('foto.cr3'), isTrue);
    expect(importService.isSupported('foto.crw'), isTrue);
    expect(importService.isSupported('foto.nef'), isTrue);
    expect(importService.isSupported('foto.arw'), isTrue);
    expect(importService.isSupported('foto.raf'), isTrue);
    expect(importService.isSupported('foto.orf'), isTrue);
    expect(importService.isSupported('foto.rw2'), isTrue);
    expect(importService.isSupported('foto.pef'), isTrue);
  });

  test('importFile legt einen Asset-Eintrag an und kopiert die Datei in die Bibliothek', () async {
    final file = File(p.join(sourceDir.path, 'a.jpg'))..writeAsBytesSync([1, 2, 3, 4, 5]);

    final result = await importService.importFile(file.path);

    expect(result.outcome, ImportOutcome.imported);
    expect(result.assetId, isNotNull);

    final asset = await db.assetById(result.assetId!);
    expect(asset, isNotNull);
    expect(asset!.originalFileName, 'a.jpg');
    expect(await paths.absolute(asset.relativePath).exists(), isTrue);
  });

  test('identischer Dateiinhalt wird per SHA-256-Prüfsumme als Duplikat erkannt, auch unter anderem Dateinamen', () async {
    final bytes = [10, 20, 30, 40, 50, 60];
    final first = File(p.join(sourceDir.path, 'first.jpg'))..writeAsBytesSync(bytes);
    final second = File(p.join(sourceDir.path, 'second.jpg'))..writeAsBytesSync(bytes);

    final r1 = await importService.importFile(first.path);
    final r2 = await importService.importFile(second.path);

    expect(r1.outcome, ImportOutcome.imported);
    expect(r2.outcome, ImportOutcome.duplicateSkipped);

    final allAssets = await db.select(db.assets).get();
    expect(allAssets, hasLength(1)); // trotz zwei Importversuchen nur ein DB-Eintrag
  });

  test('unterschiedlicher Inhalt mit gleichem Dateinamen wird NICHT als Duplikat behandelt', () async {
    final firstDir = Directory(p.join(sourceDir.path, 'ordner1'))..createSync();
    final secondDir = Directory(p.join(sourceDir.path, 'ordner2'))..createSync();
    File(p.join(firstDir.path, 'foto.jpg')).writeAsBytesSync([1, 1, 1]);
    File(p.join(secondDir.path, 'foto.jpg')).writeAsBytesSync([2, 2, 2]);

    final r1 = await importService.importFile(p.join(firstDir.path, 'foto.jpg'));
    final r2 = await importService.importFile(p.join(secondDir.path, 'foto.jpg'));

    expect(r1.outcome, ImportOutcome.imported);
    expect(r2.outcome, ImportOutcome.imported);
    expect(await db.select(db.assets).get(), hasLength(2));
  });

  test('nicht unterstütztes Format schlägt kontrolliert fehl statt eine Exception zu werfen', () async {
    final file = File(p.join(sourceDir.path, 'notiz.txt'))..writeAsStringSync('hallo welt');

    final result = await importService.importFile(file.path);

    expect(result.outcome, ImportOutcome.failed);
    expect(result.error, contains('Nicht unterstütztes Format'));
    expect(await db.select(db.assets).get(), isEmpty);
  });
}
