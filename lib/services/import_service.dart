import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' show Value;
import 'package:exif/exif.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import 'exif_camera.dart';
import 'exif_gps.dart';
import 'native_image_converter.dart';
import 'raw_formats.dart';
import 'storage_paths.dart';

const _imageExtensions = {
  '.jpg', '.jpeg', '.png', '.heic', '.heif', '.avif', '.avifs', '.webp', '.gif', '.bmp', '.tiff',
  ...rawImageExtensions,
};
const _videoExtensions = {'.mp4', '.mov', '.avi', '.mkv', '.m4v'};

/// Dekodieren + Verkleinern + JPEG-Encodieren eines Thumbnails sind reine,
/// aber für große Fotos spürbar CPU-intensive Operationen (oft 100+ ms) –
/// als Top-Level-Funktion über `compute()` in einem Hintergrund-Isolate
/// ausgeführt (siehe [ImportService.generateThumbnailAndPreview]/
/// [ImportService.generateVideoThumbnail]), statt beim Import oder
/// Backfill vieler Fotos den Haupt-Isolate (und damit die UI) zu blockieren.
/// Gibt `null` zurück, wenn die Bytes nicht dekodierbar sind.
({Uint8List jpegBytes, int width, int height})? decodeAndResizeThumbnail(Uint8List bytes) {
  img.Image? decoded;
  try {
    decoded = img.decodeImage(bytes);
  } catch (_) {
    decoded = null;
  }
  if (decoded == null) return null;

  final thumb = img.copyResize(
    decoded,
    width: decoded.width >= decoded.height ? 400 : null,
    height: decoded.height > decoded.width ? 400 : null,
  );
  return (
    jpegBytes: Uint8List.fromList(img.encodeJpg(thumb, quality: 80)),
    width: decoded.width,
    height: decoded.height,
  );
}

enum ImportOutcome { imported, duplicateSkipped, failed }

class ImportResult {
  final String filePath;
  final ImportOutcome outcome;
  final String? error;
  final String? assetId;
  ImportResult(this.filePath, this.outcome, {this.error, this.assetId});
}

/// Ergebnis der Thumbnail-/Vorschau-Erzeugung für ein einzelnes Bild bzw.
/// Video. [durationSeconds] ist nur für Videos gesetzt.
class ThumbnailResult {
  final String? thumbnailRelativePath;
  final String? previewRelativePath;
  final int? width;
  final int? height;
  final double? durationSeconds;
  const ThumbnailResult({
    this.thumbnailRelativePath,
    this.previewRelativePath,
    this.width,
    this.height,
    this.durationSeconds,
  });

  bool get hasThumbnail => thumbnailRelativePath != null;
}

/// Übernimmt Dateien von der Festplatte in die verwaltete Bibliothek:
/// Prüfsumme berechnen (Duplikate überspringen), Datei in `originals/`
/// kopieren, Thumbnail erzeugen, EXIF-Aufnahmedatum lesen und einen
/// Datenbank-Eintrag anlegen.
class ImportService {
  ImportService(this._db, this._paths);

  final AppDatabase _db;
  final StoragePaths _paths;
  final _uuid = const Uuid();

  bool isSupported(String filePath) {
    final ext = p.extension(filePath).toLowerCase();
    return _imageExtensions.contains(ext) || _videoExtensions.contains(ext);
  }

  Future<ImportResult> importFile(String filePath) async {
    try {
      final ext = p.extension(filePath).toLowerCase();
      if (!_imageExtensions.contains(ext) && !_videoExtensions.contains(ext)) {
        return ImportResult(filePath, ImportOutcome.failed, error: 'Nicht unterstütztes Format');
      }
      final sourceFile = File(filePath);
      final isImage = _imageExtensions.contains(ext);

      // Für Bilder werden die Bytes ohnehin für EXIF/Thumbnail gebraucht –
      // dort einmalig laden und die Prüfsumme daraus berechnen. Videos sind
      // oft hunderte MB bis mehrere GB groß: dafür lohnt sich das nicht –
      // Prüfsumme streamend berechnen und die Datei vom Betriebssystem
      // kopieren lassen, statt sie komplett in den Dart-Heap zu laden.
      Uint8List? bytes;
      final String checksum;
      if (isImage) {
        bytes = await sourceFile.readAsBytes();
        checksum = sha256.convert(bytes).toString();
      } else {
        checksum = (await sha256.bind(sourceFile.openRead()).first).toString();
      }

      if (await _db.checksumExists(checksum)) {
        return ImportResult(filePath, ImportOutcome.duplicateSkipped);
      }

      final assetId = _uuid.v4();
      final exifMeta =
          isImage ? await _readExifMetadata(bytes!) : const _ExifMetadata(null, null, CameraInfo());
      final fileCreatedAt = exifMeta.date ?? await sourceFile.lastModified();

      final relativePath = _paths.originalRelativePath(fileCreatedAt, assetId, ext);
      final targetFile = _paths.absolute(relativePath);
      await targetFile.parent.create(recursive: true);
      final int fileSizeBytes;
      if (isImage) {
        await targetFile.writeAsBytes(bytes!);
        fileSizeBytes = bytes.length;
      } else {
        await sourceFile.copy(targetFile.path);
        fileSizeBytes = await targetFile.length();
      }

      final thumbResult = isImage
          ? await generateThumbnailAndPreview(targetFile, assetId, ext, alreadyReadBytes: bytes)
          : await generateVideoThumbnail(targetFile, assetId);

      await _db.insertAsset(AssetsCompanion.insert(
        id: assetId,
        originalFileName: p.basename(filePath),
        relativePath: relativePath,
        checksum: checksum,
        type: isImage ? 'IMAGE' : 'VIDEO',
        fileCreatedAt: fileCreatedAt,
        importedAt: DateTime.now(),
        thumbnailRelativePath: Value(thumbResult.thumbnailRelativePath),
        previewRelativePath: Value(thumbResult.previewRelativePath),
        widthPx: Value(thumbResult.width),
        heightPx: Value(thumbResult.height),
        durationSeconds: Value(thumbResult.durationSeconds),
        fileSizeBytes: Value(fileSizeBytes),
        latitude: Value(exifMeta.gps?.latitude),
        longitude: Value(exifMeta.gps?.longitude),
        cameraMake: Value(exifMeta.camera.make),
        cameraModel: Value(exifMeta.camera.model),
        lensModel: Value(exifMeta.camera.lensModel),
        focalLengthMm: Value(exifMeta.camera.focalLengthMm),
        fNumber: Value(exifMeta.camera.fNumber),
        iso: Value(exifMeta.camera.iso),
        exposureTimeSeconds: Value(exifMeta.camera.exposureTimeSeconds),
      ));

      return ImportResult(filePath, ImportOutcome.imported, assetId: assetId);
    } catch (e) {
      return ImportResult(filePath, ImportOutcome.failed, error: e.toString());
    }
  }

  /// Erzeugt Thumbnail (immer, wenn möglich) und – nur für Formate, die
  /// Flutter selbst nicht rendern kann (HEIC/HEIF, DNG & Co., siehe
  /// [heicAndRawExtensions]) – zusätzlich eine größere, konvertierte
  /// JPEG-Vorschau für die Vollbildansicht.
  ///
  /// Wird sowohl beim Import als auch beim manuellen "Vorschaubilder neu
  /// erstellen" in den Werkzeugen verwendet (z.B. für Fotos, die importiert
  /// wurden, bevor die native Bildkonvertierung eingerichtet war).
  Future<ThumbnailResult> generateThumbnailAndPreview(
    File sourceFile,
    String assetId,
    String extension, {
    Uint8List? alreadyReadBytes,
  }) async {
    final ext = extension.toLowerCase();
    final needsNativeConversion = heicAndRawExtensions.contains(ext);

    Uint8List? convertedBytes;
    if (needsNativeConversion) {
      convertedBytes = await NativeImageConverter.convertToJpegBytes(sourceFile, maxDimension: 2048);
    }

    final bytesToDecode = convertedBytes ?? alreadyReadBytes ?? await sourceFile.readAsBytes();
    // Bei kurzen/beschädigten Dateien wirft `image` teils eine Exception
    // (z.B. RangeError beim Format-Sniffing) statt null zurückzugeben – von
    // decodeAndResizeThumbnail bereits abgefangen, `null` bedeutet für uns
    // "nicht dekodierbar". Weder direkt dekodierbar noch (falls versucht)
    // nativ konvertierbar – z.B. weil die native Bildkonvertierung nicht
    // eingerichtet ist, oder weil die Datei beschädigt/unvollständig ist.
    final result = await compute(decodeAndResizeThumbnail, bytesToDecode);
    if (result == null) {
      return const ThumbnailResult();
    }

    final thumbRelativePath = _paths.thumbnailRelativePath(assetId);
    await _paths.absolute(thumbRelativePath).writeAsBytes(result.jpegBytes);

    String? previewRelativePath;
    if (convertedBytes != null) {
      // Original ist für Flutter nicht direkt darstellbar → konvertierte
      // Version zusätzlich in Originalgröße (bis 2048px) für die
      // Vollbildansicht sichern.
      previewRelativePath = _paths.previewRelativePath(assetId);
      await _paths.absolute(previewRelativePath).writeAsBytes(convertedBytes);
    }

    return ThumbnailResult(
      thumbnailRelativePath: thumbRelativePath,
      previewRelativePath: previewRelativePath,
      width: result.width,
      height: result.height,
    );
  }

  /// Erzeugt ein Video-Thumbnail (ein extrahierter Frame) plus Videolänge
  /// über die native macOS-Anbindung (AVFoundation, siehe
  /// NativeImageConverter). Ohne diese native Anbindung bleibt es beim
  /// Platzhalter-Icon in der Kachelansicht ([AssetThumbnailTile]) – die
  /// restliche App funktioniert davon unabhängig normal weiter.
  ///
  /// Wird sowohl beim Import als auch beim manuellen "Vorschaubilder neu
  /// erstellen" in den Werkzeugen verwendet.
  Future<ThumbnailResult> generateVideoThumbnail(File sourceFile, String assetId) async {
    final native = await NativeImageConverter.generateVideoThumbnail(sourceFile);
    if (native == null) return const ThumbnailResult();

    final result = await compute(decodeAndResizeThumbnail, native.jpegBytes);
    if (result == null) {
      // Frame-Extraktion lieferte kein dekodierbares Bild – Videolänge
      // trotzdem übernehmen, falls AVFoundation sie ermitteln konnte.
      return ThumbnailResult(durationSeconds: native.durationSeconds);
    }

    final thumbRelativePath = _paths.thumbnailRelativePath(assetId);
    await _paths.absolute(thumbRelativePath).writeAsBytes(result.jpegBytes);

    return ThumbnailResult(
      thumbnailRelativePath: thumbRelativePath,
      width: result.width,
      height: result.height,
      durationSeconds: native.durationSeconds,
    );
  }

  /// Liest nur den GPS-Ort aus den EXIF-Daten einer bereits importierten
  /// Foto-Datei – für das nachträgliche Einlesen von Orten in den
  /// Werkzeugen (Fotos, die vor Einführung dieser Funktion importiert
  /// wurden). Gibt `null` zurück, wenn keine GPS-Daten vorhanden sind oder
  /// die Datei nicht gelesen werden kann.
  Future<({double latitude, double longitude})?> readGpsLocation(File file) async {
    try {
      final tags = await readExifFromBytes(await file.readAsBytes());
      return parseExifGps(tags);
    } catch (_) {
      return null;
    }
  }

  /// Importiert rekursiv alle unterstützten Dateien aus einem Ordner
  /// (z.B. beim Einbinden einer externen SSD oder eines Kamera-Backups).
  Future<List<String>> collectSupportedFilesInFolder(String folderPath) async {
    final dir = Directory(folderPath);
    if (!await dir.exists()) return [];
    final result = <String>[];
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File && isSupported(entity.path)) {
        result.add(entity.path);
      }
    }
    return result;
  }

  /// Liest Aufnahmedatum, GPS-Ort und Kamera-/Objektiv-Angaben in einem
  /// Durchlauf aus den EXIF-Daten eines Fotos (alles steckt im selben
  /// `readExifFromBytes`-Ergebnis).
  Future<_ExifMetadata> _readExifMetadata(Uint8List bytes) async {
    try {
      final tags = await readExifFromBytes(bytes);
      return _ExifMetadata(_parseExifDate(tags), parseExifGps(tags), parseExifCameraInfo(tags));
    } catch (_) {
      return const _ExifMetadata(null, null, CameraInfo());
    }
  }

  /// Liest nur die Kamera-/Objektiv-Angaben aus den EXIF-Daten einer bereits
  /// importierten Foto-Datei – für das nachträgliche Einlesen in den
  /// Werkzeugen (Fotos, die vor Einführung dieser Funktion importiert
  /// wurden). Gibt eine leere [CameraInfo] zurück, wenn nichts gefunden wird
  /// oder die Datei nicht gelesen werden kann.
  Future<CameraInfo> readCameraInfo(File file) async {
    try {
      final tags = await readExifFromBytes(await file.readAsBytes());
      return parseExifCameraInfo(tags);
    } catch (_) {
      return const CameraInfo();
    }
  }

  DateTime? _parseExifDate(Map<String, IfdTag> tags) {
    final raw = tags['EXIF DateTimeOriginal']?.printable ?? tags['Image DateTime']?.printable;
    if (raw == null) return null;
    // EXIF-Format: "yyyy:MM:dd HH:mm:ss"
    final parts = raw.split(' ');
    if (parts.length != 2) return null;
    final datePart = parts[0].split(':');
    final timePart = parts[1].split(':');
    if (datePart.length != 3 || timePart.length != 3) return null;
    try {
      return DateTime(
        int.parse(datePart[0]),
        int.parse(datePart[1]),
        int.parse(datePart[2]),
        int.parse(timePart[0]),
        int.parse(timePart[1]),
        int.parse(timePart[2]),
      );
    } catch (_) {
      return null;
    }
  }
}

class _ExifMetadata {
  final DateTime? date;
  final ({double latitude, double longitude})? gps;
  final CameraInfo camera;
  const _ExifMetadata(this.date, this.gps, this.camera);
}
