import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import 'import_service.dart';
import 'storage_paths.dart';
import 'vault_crypto.dart';
import 'xmp_writer.dart';

class BackupProgress {
  final int done;
  final int total;
  final String? currentFile;
  BackupProgress(this.done, this.total, {this.currentFile});
}

/// Kopiert die Bibliothek manuell in einen vom Nutzer gewählten Ordner.
/// Das ist bewusst kein automatischer Cloud-Upload: der Nutzer wählt selbst
/// einen Ordner (z.B. den lokalen Dropbox- oder Google-Drive-Sync-Ordner),
/// und der jeweilige Desktop-Client kümmert sich um die eigentliche
/// Cloud-Synchronisierung.
///
/// Optional (siehe [encryptionKey]) wird das Backup mit AES-256-GCM
/// verschlüsselt – derselbe Mechanismus wie beim gesperrten Ordner
/// (VaultCrypto), aber mit einem eigenen, von der Backup-Passphrase
/// abgeleiteten Master-Key (siehe LibraryState). Der verpackte Schlüssel
/// wird zusätzlich als `vault.key`-Datei INS Backup selbst geschrieben,
/// damit sich ein verschlüsseltes Backup auch auf einem komplett anderen
/// Rechner allein mit der Passphrase wiederherstellen lässt.
class BackupService {
  BackupService(this._db, this._paths);

  final AppDatabase _db;
  final StoragePaths _paths;
  final _uuid = const Uuid();

  static const _backupFolderName = 'PhotoVault-Backup';

  /// Führt ein inkrementelles Backup durch: nur Originaldateien, die noch
  /// nicht als gesichert markiert sind, werden kopiert. Die Metadaten
  /// (Favoriten, Beschreibung, Tags, Alben) werden bei jedem Lauf komplett
  /// neu als `metadata.json` exportiert, damit der Cloud-Ordner immer den
  /// aktuellen Stand widerspiegelt.
  /// [maxBytesPerRun] begrenzt, wie viel je Lauf ins Ziel geschrieben wird
  /// (0 oder negativ = unbegrenzt). Gedacht für Cloud-Sync-Ordner: Ohne
  /// Grenze landen bei der ersten Sicherung zigtausend Dateien auf einmal
  /// im Sync-Ordner und der Upload läuft tagelang. Was nicht mehr
  /// hineinpasst, bleibt unmarkiert und kommt beim nächsten Lauf dran.
  Stream<BackupProgress> performBackup(
    String destinationRootPath, {
    SecretKey? encryptionKey,
    int maxBytesPerRun = 0,
  }) async* {
    final backupRoot = Directory(p.join(destinationRootPath, _backupFolderName));
    final originalsOut = Directory(p.join(backupRoot.path, 'originals'));
    await originalsOut.create(recursive: true);

    // Lokaler Zwischenspeicher: Verschlüsseln bzw. Kopieren passiert hier,
    // erst die fertige Datei wandert ins Ziel. Zwei Gründe: Cloud-Clients
    // beginnen sonst, halbfertige Dateien hochzuladen; und das Ziel kann
    // ein langsames Netzlaufwerk sein, auf dem man nicht mehrfach schreiben
    // will. Liegt bewusst im System-Temp – geht er verloren (Neustart),
    // wird die betroffene Datei beim nächsten Lauf einfach neu erzeugt,
    // denn markiert wird erst nach erfolgreicher Ablage im Ziel.
    final staging = await Directory.systemTemp.createTemp('pv_backup_stage_');

    final pending = await _db.assetsNotBackedUp();
    var done = 0;
    var totalBytes = 0;
    var geschriebeneBytes = 0;
    var abgebrochenWegenLimit = false;
    final backedUpIds = <String>[];

    // XMP-Sidecars nur für unverschlüsselte Backups: bei einem verschlüsselten
    // Backup (encryptionKey != null) würde eine im Klartext danebenliegende
    // .xmp-Datei genau die Vertraulichkeit unterlaufen, die der Nutzer mit der
    // Backup-Passphrase gerade herstellen wollte.
    final tagsByAssetId = encryptionKey == null ? await _db.allTagNamesByAssetId() : null;

    yield BackupProgress(0, pending.length);

    try {
      for (final asset in pending) {
        if (maxBytesPerRun > 0 && geschriebeneBytes >= maxBytesPerRun) {
          abgebrochenWegenLimit = true;
          break;
        }

        final source = _paths.absolute(asset.relativePath);
        if (await source.exists()) {
          // Verschlüsselt: flach unter data/ mit abgeleitetem Namen, damit
          // weder Aufnahmezeitraum noch Dateiformat sichtbar bleiben.
          // Unverschlüsselt: weiterhin die lesbare Ordnerstruktur, damit
          // sich so ein Backup auch ohne die App durchsehen lässt.
          final target = encryptionKey != null
              ? File(p.join(backupRoot.path, VerschluesselteNamen.ordner,
                  await VerschluesselteNamen.fuerPruefsumme(asset.checksum, encryptionKey)))
              : File(p.join(originalsOut.path,
                  asset.relativePath.replaceFirst('originals${Platform.pathSeparator}', '')));
          await target.parent.create(recursive: true);

          // Erst in den Zwischenspeicher schreiben …
          final zwischen = File(p.join(staging.path, 'teil'));
          if (encryptionKey != null) {
            await VaultCrypto.encryptFile(source, zwischen, encryptionKey);
          } else {
            await source.copy(zwischen.path);
          }
          // … und erst die vollständige Datei ins Ziel legen.
          await _verschiebe(zwischen, target);

          if (encryptionKey == null) {
            final xmp = buildXmpPacket(asset, tagsByAssetId![asset.id] ?? const []);
            await File(_paths.xmpSidecarPath(target.path)).writeAsString(xmp);
          }

          final groesse = await target.length();
          totalBytes += await source.length();
          geschriebeneBytes += groesse;
        }
        backedUpIds.add(asset.id);
        done++;
        yield BackupProgress(done, pending.length, currentFile: asset.originalFileName);
      }
    } finally {
      // Reste immer wegräumen, auch bei Fehlern.
      try {
        await staging.delete(recursive: true);
      } catch (_) {}
    }

    if (backedUpIds.isNotEmpty) {
      await _db.markBackedUp(backedUpIds);
    }

    await _writeMetadataExport(backupRoot, encryptionKey: encryptionKey);
    if (encryptionKey != null) {
      await _writeKeyEnvelope(backupRoot);
    }

    await _db.insertBackupRecord(BackupRecordsCompanion.insert(
      id: _uuid.v4(),
      performedAt: DateTime.now(),
      destinationPath: destinationRootPath,
      // Nur die tatsächlich gesicherten Dateien zählen, nicht die geplanten –
      // sonst behauptet der Bericht bei einem begrenzten Lauf mehr, als er
      // geschafft hat.
      fileCount: backedUpIds.length,
      totalBytes: totalBytes,
    ));

    // Abschließende Meldung macht sichtbar, dass noch etwas aussteht –
    // sonst wirkt ein begrenzter Lauf wie ein vollständiges Backup.
    if (abgebrochenWegenLimit) {
      yield BackupProgress(
        done,
        pending.length,
        currentFile: 'Grenze erreicht – ${pending.length - done} Datei(en) folgen '
            'beim nächsten Lauf',
      );
    }
  }

  /// Verschiebt [von] nach [nach].
  ///
  /// `rename` ist innerhalb desselben Dateisystems atomar – der Cloud-Client
  /// sieht die Datei dann entweder gar nicht oder vollständig, nie halb
  /// geschrieben. Über Dateisystemgrenzen hinweg (Zwischenspeicher im
  /// System-Temp, Ziel auf einem anderen Volume) schlägt `rename` fehl;
  /// dann wird kopiert und die Zwischendatei gelöscht.
  Future<void> _verschiebe(File von, File nach) async {
    try {
      await von.rename(nach.path);
    } on FileSystemException {
      await von.copy(nach.path);
      await von.delete();
    }
  }

  Future<void> _writeMetadataExport(Directory backupRoot, {SecretKey? encryptionKey}) async {
    final allAssets = await _db.select(_db.assets).get();
    final albums = await _db.select(_db.albums).get();
    // Eine einzige Abfrage für alle Tags statt einer pro Foto (N+1-Problem
    // bei großen Bibliotheken – Backups sollen schnell bleiben).
    final tagsByAssetId = await _db.allTagNamesByAssetId();

    final assetsJson = <Map<String, dynamic>>[];
    for (final a in allAssets) {
      assetsJson.add({
        'checksum': a.checksum,
        'originalFileName': a.originalFileName,
        'isFavorite': a.isFavorite,
        'description': a.description,
        'fileCreatedAt': a.fileCreatedAt.toIso8601String(),
        'tags': tagsByAssetId[a.id] ?? const <String>[],
      });
    }

    final albumsJson = <Map<String, dynamic>>[];
    for (final album in albums) {
      final albumAssets = await _db.assetsInAlbumOnce(album.id);
      albumsJson.add({
        'name': album.name,
        'assetChecksums': albumAssets.map((a) => a.checksum).toList(),
      });
    }

    final export = {
      'exportedAt': DateTime.now().toIso8601String(),
      'assets': assetsJson,
      'albums': albumsJson,
    };

    final file = File(p.join(backupRoot.path, 'metadata.json'));
    final jsonBytes = utf8.encode(const JsonEncoder.withIndent('  ').convert(export));

    if (encryptionKey == null) {
      await file.writeAsBytes(jsonBytes);
      return;
    }
    final plainTemp = File('${file.path}.plaintmp');
    await plainTemp.writeAsBytes(jsonBytes);
    try {
      await VaultCrypto.encryptFile(plainTemp, file, encryptionKey);
    } finally {
      await plainTemp.delete();
    }
  }

  /// Schreibt den verpackten Backup-Master-Key als kleine, PIN/Passphrase-
  /// geschützte Datei INS Backup selbst (nicht nur lokal in der
  /// App-Datenbank) – nur dadurch lässt sich ein verschlüsseltes Backup auf
  /// einem komplett anderen Rechner allein mit der Passphrase entschlüsseln.
  Future<void> _writeKeyEnvelope(Directory backupRoot) async {
    final row = await _db.backupSettingsRow();
    final kdfSalt = row?.kdfSalt;
    final nonce = row?.wrappedMasterKeyNonce;
    final wrapped = row?.wrappedMasterKey;
    if (kdfSalt == null || nonce == null || wrapped == null) return;
    final envelope = {
      'kdfSalt': base64Encode(kdfSalt),
      'nonce': base64Encode(nonce),
      'wrapped': base64Encode(wrapped),
    };
    final file = File(p.join(backupRoot.path, 'vault.key'));
    await file.writeAsString(jsonEncode(envelope));
  }

  /// Stellt eine Bibliothek aus einem zuvor erstellten Backup-Ordner wieder
  /// her: importiert alle gefundenen Originaldateien (Duplikate werden über
  /// die Prüfsumme automatisch übersprungen) und wendet anschließend, sofern
  /// vorhanden, `metadata.json` an (Favoriten, Beschreibung, Tags, Alben).
  /// Personen/Gesichter werden bewusst NICHT wiederhergestellt, da Immichs
  /// bzw. dieser Apps Gesichts-Crops nicht Teil des Backups sind.
  ///
  /// Ist das Backup verschlüsselt (erkennbar an einer `vault.key`-Datei im
  /// Backup-Ordner), wird [passphrase] benötigt – der Schlüssel dafür kommt
  /// ausschließlich aus dieser Datei, nicht aus der lokalen App-Datenbank,
  /// damit die Wiederherstellung auch auf einem fremden Rechner funktioniert.
  Stream<BackupProgress> restoreFromBackup(
    String backupRootPath,
    ImportService importService, {
    String? passphrase,
  }) async* {
    final keyFile = File(p.join(backupRootPath, 'vault.key'));
    SecretKey? decryptionKey;
    if (await keyFile.exists()) {
      if (passphrase == null) {
        throw StateError('Dieses Backup ist verschlüsselt – eine Passphrase wird benötigt.');
      }
      final envelope = jsonDecode(await keyFile.readAsString()) as Map<String, dynamic>;
      decryptionKey = await VaultCrypto.unwrapMasterKey(
        passphrase,
        kdfSalt: base64Decode(envelope['kdfSalt'] as String),
        nonce: base64Decode(envelope['nonce'] as String),
        wrapped: base64Decode(envelope['wrapped'] as String),
      );
    }

    // Metadaten früh einlesen: Beim neuen, namenlosen Format sind sie die
    // EINZIGE Quelle dafür, welche Dateien es gibt und welche Endung sie
    // hatten – aus dem Ordner selbst lässt sich das nicht mehr ablesen.
    final metadataFile = File(p.join(backupRootPath, 'metadata.json'));
    List<Map<String, dynamic>> metaAssets = const [];
    File? entschluesselteMetadaten;
    if (await metadataFile.exists()) {
      File zuLesen = metadataFile;
      if (decryptionKey != null) {
        entschluesselteMetadaten = File(
            p.join(Directory.systemTemp.path, 'photovault_restore_${_uuid.v4()}.json'));
        await VaultCrypto.decryptFile(metadataFile, entschluesselteMetadaten, decryptionKey);
        zuLesen = entschluesselteMetadaten;
      }
      try {
        final inhalt = jsonDecode(await zuLesen.readAsString()) as Map<String, dynamic>;
        metaAssets = (inhalt['assets'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
      } catch (e) {
        // Beschädigte Metadaten dürfen den Restore NICHT abbrechen: Beim
        // alten Format werden die Dateien ohnehin über ihre Endung
        // gefunden, die Fotos kommen also trotzdem zurück (nur ohne
        // Favoriten/Tags). Beim neuen, namenlosen Format sind sie die
        // einzige Quelle – dann bleibt die Liste eben leer, statt zu
        // scheitern.
        debugPrint('metadata.json unlesbar, Restore läuft ohne Metadaten weiter: $e');
      }
    }

    // Was wiederhergestellt werden soll: Pfad plus die Endung, die die Datei
    // im Original hatte (beim neuen Format steckt sie nicht mehr im Namen).
    final files = <({String pfad, String endung})>[];

    final datenOrdner = Directory(p.join(backupRootPath, VerschluesselteNamen.ordner));
    final originalsIn = Directory(p.join(backupRootPath, 'originals'));

    if (await datenOrdner.exists() && decryptionKey != null) {
      // Neues Format: flach und namenlos. Die Zuordnung entsteht durch
      // Nachrechnen des Namens aus der Prüfsumme – ohne Schlüssel ist das
      // nicht möglich, genau das ist der Zweck.
      for (final eintrag in metaAssets) {
        final pruefsumme = eintrag['checksum'] as String?;
        if (pruefsumme == null) continue;
        final name = await VerschluesselteNamen.fuerPruefsumme(pruefsumme, decryptionKey);
        final datei = File(p.join(datenOrdner.path, name));
        if (await datei.exists()) {
          files.add((
            pfad: datei.path,
            endung: p.extension((eintrag['originalFileName'] as String?) ?? '.jpg'),
          ));
        }
      }
    } else if (await originalsIn.exists()) {
      // Altes Format: nach Endung durchsuchen. Bei verschlüsselten Backups
      // sind die Bytes zwar Chiffretext, die Endung im Pfad blieb aber die
      // des Originals.
      await for (final entity in originalsIn.list(recursive: true, followLinks: false)) {
        if (entity is File && importService.isSupported(entity.path)) {
          files.add((pfad: entity.path, endung: p.extension(entity.path)));
        }
      }
    } else {
      // Fallback: falls direkt der "originals"-Ordner selbst ausgewählt wurde.
      for (final f in await importService.collectSupportedFilesInFolder(backupRootPath)) {
        files.add((pfad: f, endung: p.extension(f)));
      }
    }

    var done = 0;
    yield BackupProgress(0, files.length);
    for (final eintrag in files) {
      final filePath = eintrag.pfad;
      if (decryptionKey == null) {
        await importService.importFile(filePath);
      } else {
        // In eine temporäre Datei mit derselben Endung entschlüsseln (für
        // Bild-/Videotyp-Erkennung beim Import), dann importieren und die
        // Zwischenkopie sofort wieder löschen. Der ursprüngliche Dateiname
        // ist ohnehin nur die Asset-UUID (siehe StoragePaths) – der echte,
        // von Menschen lesbare Name kommt gleich aus metadata.json über den
        // Prüfsummen-Abgleich zurück, unabhängig vom Namen dieser
        // Zwischenkopie.
        final tempFile = File(p.join(
          Directory.systemTemp.path,
          'photovault_restore_${_uuid.v4()}${eintrag.endung}',
        ));
        try {
          await VaultCrypto.decryptFile(File(filePath), tempFile, decryptionKey);
          await importService.importFile(tempFile.path);
        } finally {
          if (await tempFile.exists()) await tempFile.delete();
        }
      }
      done++;
      yield BackupProgress(done, files.length, currentFile: p.basename(filePath));
    }

    // Metadaten anwenden – die Datei wurde oben bereits (ggf. entschlüsselt)
    // eingelesen, deshalb hier keine zweite Entschlüsselung.
    try {
      if (await metadataFile.exists()) {
        await _applyMetadataExport(entschluesselteMetadaten ?? metadataFile);
      }
    } finally {
      if (entschluesselteMetadaten != null && await entschluesselteMetadaten.exists()) {
        await entschluesselteMetadaten.delete();
      }
    }
  }

  /// Wendet den Inhalt einer `metadata.json` an. Läuft pro Asset-/Album-
  /// Eintrag in einem eigenen Try/Catch: ein einzelner unerwarteter/defekter
  /// Eintrag (z.B. aus einem von Hand bearbeiteten oder von einer älteren
  /// App-Version stammenden Backup) bricht damit nicht den gesamten Restore
  /// ab, sondern wird übersprungen.
  Future<void> _applyMetadataExport(File metadataFile) async {
    final Map<String, dynamic> content;
    try {
      content = jsonDecode(await metadataFile.readAsString()) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('metadata.json konnte nicht gelesen werden, überspringe Metadaten-Import: $e');
      return;
    }

    final assetsJson = (content['assets'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();

    final byChecksum = <String, String>{}; // checksum -> assetId in dieser DB
    for (final row in await _db.select(_db.assets).get()) {
      byChecksum[row.checksum] = row.id;
    }

    for (final entry in assetsJson) {
      try {
        final checksum = entry['checksum'] as String?;
        final assetId = checksum != null ? byChecksum[checksum] : null;
        if (assetId == null) continue;
        // Der Reimport aus dem Backup-Ordner kennt nur den Pfad
        // originals/{yyyy}/{mm}/{assetId}.ext und übernimmt dessen Basename
        // (also die Asset-UUID) als originalFileName – hier den echten,
        // von Menschen lesbaren Namen aus metadata.json wiederherstellen.
        // p.basename() schützt vor einer präparierten metadata.json (z.B.
        // aus einem fremden/geteilten Backup-Ordner), die einen Namen mit
        // Pfad-Traversal ("../../...") enthält – der wiederhergestellte Name
        // wird später beim Exportieren 1:1 als Ziel-Dateiname verwendet
        // (siehe ExportService).
        final originalFileName = entry['originalFileName'] as String?;
        if (originalFileName != null && originalFileName.isNotEmpty) {
          await _db.setOriginalFileName(assetId, p.basename(originalFileName));
        }
        if (entry['isFavorite'] == true) {
          await _db.setFavorite(assetId, true);
        }
        if (entry['description'] is String && (entry['description'] as String).isNotEmpty) {
          await _db.setDescription(assetId, entry['description'] as String);
        }
        for (final tag in (entry['tags'] as List<dynamic>? ?? [])) {
          await _db.tagAsset(assetId, tag as String);
        }
      } catch (e) {
        debugPrint('Metadaten-Eintrag konnte nicht angewendet werden, überspringe: $e');
      }
    }

    final albumsJson = (content['albums'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    for (final albumEntry in albumsJson) {
      try {
        final name = albumEntry['name'] as String? ?? 'Wiederhergestelltes Album';
        final checksums = (albumEntry['assetChecksums'] as List<dynamic>? ?? []).cast<String>();
        final assetIds = checksums.map((c) => byChecksum[c]).whereType<String>().toList();
        if (assetIds.isEmpty) continue;
        final albumId = const Uuid().v4();
        await _db.createAlbum(AlbumsCompanion.insert(id: albumId, name: name, createdAt: DateTime.now()));
        await _db.addAssetsToAlbum(albumId, assetIds);
      } catch (e) {
        debugPrint('Album-Eintrag konnte nicht wiederhergestellt werden, überspringe: $e');
      }
    }
  }

  // -----------------------------------------------------------------------
  // Automatisches Backup
  // -----------------------------------------------------------------------

  static const _autoBackupFolderName = 'PhotoVault-AutoBackup';

  /// Automatisches, verschlüsseltes Backup – läuft nur, während die App
  /// offen ist (kein Hintergrunddienst, siehe LibraryState.runAutoBackupIfDue).
  /// Anders als [performBackup] sichert es zusätzlich einen konsistenten
  /// Schnappschuss der kompletten Datenbank (nicht nur eine Teilmenge der
  /// Felder in metadata.json) – das automatische Backup soll eine
  /// vollständige, eigenständige Kopie des Bibliothek-Zustands sein
  /// ("Source of Truth"), aus der sich bei Datenverlust alles außer den
  /// Rohdateien selbst wiederherstellen lässt (Gesichter, Personen, Orte,
  /// Tags, Alben, Favoriten, gesperrt-Status – alles, was in der Datenbank
  /// steht).
  ///
  /// WICHTIG: löscht am Zielort NIE etwas. Ein automatisches Backup, das
  /// lokale Löschungen nachvollzieht, wäre kein verlässliches Sicherheitsnetz
  /// mehr (eine versehentliche oder böswillige lokale Löschung würde sonst
  /// das Backup mitreißen). Dateien werden nur ergänzt, der DB-Schnappschuss
  /// nur ersetzt (er beschreibt ohnehin immer den kompletten aktuellen
  /// Zustand, nicht nur eine Differenz).
  /// [maxBytesPerRun] siehe [performBackup] – hier besonders wichtig, weil
  /// das automatische Backup typischerweise auf einen Cloud-Sync-Ordner
  /// zeigt und ungefragt im Hintergrund läuft.
  Stream<BackupProgress> performAutoBackup(
    String destinationRootPath,
    SecretKey encryptionKey, {
    int maxBytesPerRun = 0,
  }) async* {
    final backupRoot = Directory(p.join(destinationRootPath, _autoBackupFolderName));
    final originalsOut = Directory(p.join(backupRoot.path, 'originals'));
    await originalsOut.create(recursive: true);

    await _writeEncryptedDatabaseSnapshot(backupRoot, encryptionKey);
    await _writeKeyEnvelope(backupRoot);

    final staging = await Directory.systemTemp.createTemp('pv_autobackup_stage_');
    final pending = await _db.assetsNotAutoBackedUp();
    var done = 0;
    var geschriebeneBytes = 0;
    var abgebrochenWegenLimit = false;
    final autoBackedUpIds = <String>[];
    yield BackupProgress(0, pending.length);

    try {
      for (final asset in pending) {
        if (maxBytesPerRun > 0 && geschriebeneBytes >= maxBytesPerRun) {
          abgebrochenWegenLimit = true;
          break;
        }
        final source = _paths.absolute(asset.relativePath);
        if (await source.exists()) {
          // Automatische Backups sind immer verschlüsselt – daher stets die
          // flache, namenlose Ablage (siehe VerschluesselteNamen).
          final target = File(p.join(backupRoot.path, VerschluesselteNamen.ordner,
              await VerschluesselteNamen.fuerPruefsumme(asset.checksum, encryptionKey)));
          await target.parent.create(recursive: true);
          final zwischen = File(p.join(staging.path, 'teil'));
          await VaultCrypto.encryptFile(source, zwischen, encryptionKey);
          await _verschiebe(zwischen, target);
          geschriebeneBytes += await target.length();
        }
        autoBackedUpIds.add(asset.id);
        done++;
        yield BackupProgress(done, pending.length, currentFile: asset.originalFileName);
      }
    } finally {
      try {
        await staging.delete(recursive: true);
      } catch (_) {}
    }

    if (autoBackedUpIds.isNotEmpty) {
      await _db.markAutoBackedUp(autoBackedUpIds);
    }

    if (abgebrochenWegenLimit) {
      yield BackupProgress(done, pending.length,
          currentFile: 'Grenze erreicht – ${pending.length - done} Datei(en) folgen '
              'beim nächsten Lauf');
    }
  }

  /// Erzeugt über SQLites `VACUUM INTO` einen konsistenten Schnappschuss der
  /// laufenden Datenbank (funktioniert korrekt auch während die App
  /// gleichzeitig weiterschreibt, anders als ein simples Kopieren der
  /// `.sqlite`-Datei, das einen halbgeschriebenen Zustand einfangen könnte)
  /// und verschlüsselt ihn anschließend.
  Future<void> _writeEncryptedDatabaseSnapshot(Directory backupRoot, SecretKey encryptionKey) async {
    final snapshotPath = p.join(
      Directory.systemTemp.path,
      'photovault_db_snapshot_${_uuid.v4()}.sqlite',
    );
    final snapshotFile = File(snapshotPath);
    try {
      await _db.customStatement('VACUUM INTO ?', [snapshotPath]);
      final target = File(p.join(backupRoot.path, 'library.sqlite.enc'));
      await VaultCrypto.encryptFile(snapshotFile, target, encryptionKey);
    } finally {
      if (await snapshotFile.exists()) await snapshotFile.delete();
    }
  }
}

/// Ableitung der Dateinamen für verschlüsselte Backups.
///
/// Bei einem verschlüsselten Backup sollen die Dateien im Zielordner nichts
/// über den Inhalt verraten. Bisher blieb trotz verschlüsselter Bytes
/// sichtbar: der Aufnahmezeitraum (Ordner nach Jahr/Monat), das Dateiformat
/// (Endung) und über die Prüfsumme im Namen sogar, OB eine bestimmte,
/// anderweitig bekannte Datei enthalten ist.
///
/// Deshalb liegen verschlüsselte Backups flach unter `data/` mit einem
/// Namen, der sich nur MIT dem Schlüssel berechnen lässt: HMAC-SHA256 über
/// die Prüfsumme des Fotos. Deterministisch, damit ein erneuter Lauf
/// dieselbe Datei überschreibt statt eine zweite anzulegen.
class VerschluesselteNamen {
  VerschluesselteNamen._();

  /// Unterordner für die verschlüsselten Dateien.
  static const ordner = 'data';

  static Future<String> fuerPruefsumme(String pruefsumme, SecretKey schluessel) async {
    final mac = await Hmac.sha256().calculateMac(
      utf8.encode(pruefsumme),
      secretKey: schluessel,
    );
    return mac.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
