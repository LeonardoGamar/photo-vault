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
import 'cr3_gps.dart';
import 'dateikennung.dart';
import 'exif_camera.dart';
import 'exif_gps.dart';
import 'native_image_converter.dart';
import 'raw_formats.dart';
import 'raw_identify_parser.dart';
import 'storage_paths.dart';
import 'video_gps.dart';
import 'video_metadaten.dart';

const _imageExtensions = {
  '.jpg',
  '.jpeg',
  '.png',
  '.heic',
  '.heif',
  '.avif',
  '.avifs',
  '.webp',
  '.gif',
  '.bmp',
  '.tiff',
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
/// Kantenlänge, in der das Standbild eines Videos geholt wird.
///
/// Dieselbe Zahl wie bei den Vorschauen für HEIC und RAW – aus demselben
/// Grund: Darauf laufen Gesichtserkennung, Texterkennung, CLIP und die
/// Bildbeschreibung. Die Miniatur (400 Punkte) entsteht daraus und nicht
/// umgekehrt.
const int videoStandbildKante = 2048;

({Uint8List jpegBytes, int width, int height})? decodeAndResizeThumbnail(
    Uint8List bytes) {
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
        return ImportResult(filePath, ImportOutcome.failed,
            error: 'Nicht unterstütztes Format');
      }
      final sourceFile = File(filePath);
      // **Die Bytes schlagen den Namen.** In der Prüfbibliothek trugen 31
      // von 440 als Video geführten Aufnahmen in Wahrheit ein JPEG oder
      // HEIC – Standbilder, die unter einem `.mov`-Namen ankamen. Als
      // Video geführt fielen sie aus jeder Auswertung heraus (23 Abfragen
      // filtern `type = 'IMAGE'`), ihr Ort wurde nie gelesen, und die
      // Vollbildansicht setzte einen Abspieler davor, der nichts
      // abspielen konnte.
      //
      // Geprüft wird nur diese eine Richtung: [inhaltskennung] beantwortet
      // die Frage „welches BILDformat" und schweigt zu Videomarken. Ein
      // Name, der ein Bild behauptet, bleibt deshalb unangetastet – dort
      // gäbe es kein Signal, das widerspräche.
      final istBildNachName = _imageExtensions.contains(ext);
      final isImage = istBildNachName ||
          (await inhaltskennung(sourceFile, null)) != null;

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
      final exifMeta = isImage
          ? await _readExifMetadata(bytes!, sourceFile, ext)
          : const _ExifMetadata(null, null, CameraInfo());
      // Videos haben keine EXIF-Daten, aber sehr wohl einen Ort, einen
      // Aufnahmezeitpunkt und eine Kamera – alles drei steht im
      // `moov`-Kasten und kostet ein paar Sprünge, keinen Durchlauf durch
      // die Datei (siehe [leseVideoMetadaten]). In EINEM Lesevorgang, weil
      // `moov` bei Videos oft hinter den Rohdaten steht: dreimal einzeln
      // hiesse dreimal durch die Kastenkette einer Gigabyte-Datei.
      //
      // Ohne das käme nichts davon je an. In der Prüfbibliothek: 216 Orte
      // und 309 Aufnahmezeitpunkte, die in der Datei standen und nie in
      // der Datenbank ankamen – kein einziges der 440 Videos war richtig
      // datiert.
      final videoMeta =
          isImage ? leereVideometadaten : await leseVideoMetadaten(sourceFile);
      final videoOrt = _alsGps(videoMeta.ort);
      // Der Zeitstempel der Datei ist der letzte Ausweg, nicht der zweite:
      // Er ist nach jedem Kopieren, Sichern und Zurückholen der Zeitpunkt
      // eben dieses Vorgangs.
      final fileCreatedAt = exifMeta.date ??
          videoMeta.zeit?.zeitpunkt ??
          await sourceFile.lastModified();

      final relativePath =
          _paths.originalRelativePath(fileCreatedAt, assetId, ext);
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
          ? await generateThumbnailAndPreview(targetFile, assetId, ext,
              alreadyReadBytes: bytes)
          : await generateVideoThumbnail(targetFile, assetId);

      await _db.insertAsset(AssetsCompanion.insert(
        id: assetId,
        originalFileName: p.basename(filePath),
        relativePath: relativePath,
        checksum: checksum,
        type: isImage ? 'IMAGE' : 'VIDEO',
        // Aus DEM Namen, unter dem die Datei kam - nicht aus dem
        // Ablagepfad. Der Ablagepfad traegt eine vereinheitlichte Endung,
        // und dann stuende bei jedem Foto dasselbe Format.
        dateiformat: Value(dateiformatAus(p.basename(filePath))),
        fileCreatedAt: fileCreatedAt,
        importedAt: DateTime.now(),
        thumbnailRelativePath: Value(thumbResult.thumbnailRelativePath),
        previewRelativePath: Value(thumbResult.previewRelativePath),
        widthPx: Value(thumbResult.width),
        heightPx: Value(thumbResult.height),
        durationSeconds: Value(thumbResult.durationSeconds),
        fileSizeBytes: Value(fileSizeBytes),
        latitude: Value(exifMeta.gps?.latitude ?? videoOrt?.latitude),
        longitude: Value(exifMeta.gps?.longitude ?? videoOrt?.longitude),
        cameraMake: Value(exifMeta.camera.make ?? videoMeta.hersteller),
        cameraModel: Value(exifMeta.camera.model ?? videoMeta.geraet),
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
    // Die Endung sagt das eine, die ersten Bytes sagen unter Umständen
    // etwas anderes – dann zählen die Bytes. Siehe [kennungAus]: In der
    // Bibliothek liegt eine HEIC-Datei unter dem Namen `.jpg`, und ohne
    // diese Zeile bekäme sie weder Vorschaubild noch Bildmasse.
    final inhalt = await inhaltskennung(sourceFile, alreadyReadBytes);
    final needsNativeConversion = heicAndRawExtensions.contains(ext) ||
        (inhalt != null && heicAndRawExtensions.contains(inhalt));

    Uint8List? convertedBytes;
    if (needsNativeConversion) {
      convertedBytes = await NativeImageConverter.convertToJpegBytes(sourceFile,
          maxDimension: 2048);
    }

    final bytesToDecode =
        convertedBytes ?? alreadyReadBytes ?? await sourceFile.readAsBytes();
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
  /// Erzeugt Miniatur **und Vorschau** aus einem Standbild des Videos.
  ///
  /// **Warum ein Video eine Vorschau bekommt.** Vorschaudateien gab es
  /// bisher nur für Formate, die Flutter nicht selbst zeichnen kann. Sie
  /// sind aber zugleich das, worauf jede Auswertung schaut (siehe
  /// `LibraryState._decodableFile`) – und die Videos schauten deshalb aus
  /// jeder Stufe heraus: In der Prüfbibliothek hatten 440 Videos null
  /// Beschreibungen, null Schlagwörter, null Gesichter, null Einbettungen.
  /// Mit dem Standbild als Vorschau nehmen sie an allem teil, ohne dass
  /// eine einzige Auswertungsstufe etwas von Videos wissen muss.
  ///
  /// Das Standbild wird deshalb in [videoStandbildKante] geholt statt in
  /// Miniaturgrösse: Die Miniatur entsteht daraus, die Vorschau bleibt
  /// gross genug für Gesichtserkennung und Texterkennung.
  Future<ThumbnailResult> generateVideoThumbnail(
      File sourceFile, String assetId) async {
    final native = await NativeImageConverter.generateVideoThumbnail(
        sourceFile,
        maxDimension: videoStandbildKante);
    if (native == null) return const ThumbnailResult();

    final result = await compute(decodeAndResizeThumbnail, native.jpegBytes);
    if (result == null) {
      // Frame-Extraktion lieferte kein dekodierbares Bild – Videolänge
      // trotzdem übernehmen, falls AVFoundation sie ermitteln konnte.
      return ThumbnailResult(durationSeconds: native.durationSeconds);
    }

    final thumbRelativePath = _paths.thumbnailRelativePath(assetId);
    await _paths.absolute(thumbRelativePath).writeAsBytes(result.jpegBytes);

    final previewRelativePath = _paths.previewRelativePath(assetId);
    await _paths.absolute(previewRelativePath).writeAsBytes(native.jpegBytes);

    return ThumbnailResult(
      thumbnailRelativePath: thumbRelativePath,
      previewRelativePath: previewRelativePath,
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
  Future<({double latitude, double longitude})?> readGpsLocation(
      File file) async {
    final endung = p.extension(file.path).toLowerCase();
    // CR3 zuerst, und dann nicht weiter: `package:exif` liest dort
    // nachweislich gar nichts, ein `readAsBytes` über 31 MB wäre also
    // aufgewendet für ein sicheres `null`. [leseCr3Gps] kommt mit dem
    // Kopf der Datei aus.
    if (await _istCr3(file, null, endung)) {
      return _alsGps(await leseCr3Gps(file));
    }

    // Videos: derselbe Container, dieselbe Krankheit. `package:exif` liest
    // weder MOV noch MP4; in der Prüfbibliothek trugen 43 von 60 zufällig
    // geprüften Videos einen Ort in der Datei und **keines von 440** einen
    // in der Datenbank. Siehe [leseVideoGps].
    //
    // Massgeblich sind die Bytes, nicht die Endung: Ein als `.mov`
    // benanntes JPEG geht unten durch die EXIF-Tür. Und umgekehrt darf ein
    // echtes Video **nie** dorthin gelangen – `readAsBytes` zöge sonst
    // mehrere Gigabyte in den Speicher, für ein sicheres `null`.
    if (_videoExtensions.contains(endung) &&
        (await inhaltskennung(file, null)) == null) {
      return _alsGps(await leseVideoGps(file));
    }

    try {
      final tags = await readExifFromBytes(await file.readAsBytes());
      return parseExifGps(tags);
    } catch (_) {
      return null;
    }
  }

  /// Ob [datei] eine CR3 ist – nach Endung **oder** nach den ersten Bytes.
  ///
  /// Beides, weil beides vorkommt: die gewöhnliche `.cr3`, und die Datei,
  /// deren Name etwas anderes behauptet (siehe [inhaltskennung]).
  static Future<bool> _istCr3(
          File datei, Uint8List? bytes, String endung) async =>
      endung == '.cr3' || (await inhaltskennung(datei, bytes)) == '.cr3';

  static ({double latitude, double longitude})? _alsGps(
          ({double breite, double laenge})? ort) =>
      ort == null ? null : (latitude: ort.breite, longitude: ort.laenge);

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

  /// Das Format, das die ersten Bytes von [datei] behaupten – oder
  /// `null`, wenn sie zu keiner bekannten Signatur passen.
  ///
  /// Liegen die Bytes ohnehin schon im Speicher (beim Import ist das so),
  /// kostet die Auskunft nichts. Sonst werden [kennungBytes] Bytes
  /// gelesen und nicht die ganze Datei: Beim nachträglichen Erzeugen der
  /// Vorschaubilder geht das über tausende Dateien.
  ///
  /// Öffentlich, weil ausser dem Prüfstand inzwischen auch
  /// `LibraryState.repariereDateiarten` diese Weiche braucht: Sie ist die
  /// einzige Stelle, die „welches Format steckt wirklich drin" beantwortet.
  static Future<String?> inhaltskennung(File datei, Uint8List? schon) async {
    if (schon != null) return kennungAus(schon);
    try {
      final griff = await datei.open();
      try {
        return kennungAus(await griff.read(kennungBytes));
      } finally {
        await griff.close();
      }
    } on FileSystemException {
      // Die Datei fehlt oder ist nicht lesbar. Das ist nicht die Frage,
      // die hier gestellt wurde – der Aufrufer läuft ohnehin gleich
      // darauf zu und meldet es dort.
      return null;
    }
  }

  /// Liest Aufnahmedatum, GPS-Ort und Kamera-/Objektiv-Angaben in einem
  /// Durchlauf aus den EXIF-Daten eines Fotos (alles steckt im selben
  /// `readExifFromBytes`-Ergebnis).
  Future<_ExifMetadata> _readExifMetadata(
      Uint8List bytes, File datei, String endung) async {
    Map<String, IfdTag> tags = const {};
    try {
      tags = await readExifFromBytes(bytes);
    } catch (_) {
      // Bleibt leer – der Rückfall unten greift.
    }
    final datum = exifDatumAusText(_rohesExifDatum(tags));
    final kamera = parseExifCameraInfo(tags);
    // Der Ort kommt aus den EXIF-Tags – ausser bei CR3, wo keine da sind.
    // Der native Rückfall unten hilft hier nicht: ImageIO wurde nie nach
    // dem GPS-Wörterbuch gefragt, und `raw-identify` gibt gar keines aus.
    // Siehe [leseCr3Gps].
    final gps = parseExifGps(tags) ??
        (await _istCr3(datei, bytes, endung)
            ? _alsGps(await leseCr3Gps(datei))
            : null);

    // Nur nachfassen, wenn wirklich nichts ankam UND es sich um ein
    // RAW-Format handelt. Ein Screenshot ohne EXIF ist der Normalfall und
    // soll keinen Prozessstart je Datei auslösen; eine RAW-Datei ohne
    // jeden Tag dagegen ist ein Hinweis auf ein Format, das
    // `package:exif` nicht kennt – gemessen: CR3 liefert dort NULL Tags.
    // Zweiter Grund nachzufassen: Der Name behauptet ein Format, das die
    // Bytes nicht bestätigen. Dann hat `package:exif` mit ziemlicher
    // Sicherheit deshalb nichts gefunden, weil es im falschen Format
    // gesucht hat. Nur bei einem echten WIDERSPRUCH, nicht bei jeder
    // HEIC-Datei ohne Tags: Sonst löste ein Screenshot ohne EXIF-Daten
    // einen Prozessstart je Datei aus.
    final widerspruch = datum == null &&
        kamera.isEmpty &&
        !heicAndRawExtensions.contains(endung) &&
        heicAndRawExtensions.contains(kennungAus(bytes) ?? endung);
    if (widerspruch ||
        (datum == null &&
            kamera.isEmpty &&
            rawImageExtensions.contains(endung))) {
      final nativ = await NativeImageConverter.readCameraMetadata(datei);
      if (!nativ.isEmpty) {
        return _ExifMetadata(nativ.zeitpunkt, gps, nativ.kamera);
      }
    }
    return _ExifMetadata(datum, gps, kamera);
  }

  /// Liest nur die Kamera-/Objektiv-Angaben aus den EXIF-Daten einer bereits
  /// importierten Foto-Datei – für das nachträgliche Einlesen in den
  /// Werkzeugen (Fotos, die vor Einführung dieser Funktion importiert
  /// wurden). Gibt eine leere [CameraInfo] zurück, wenn nichts gefunden wird
  /// oder die Datei nicht gelesen werden kann.
  Future<CameraInfo> readCameraInfo(File file) async =>
      (await readAufnahmedaten(file)).kamera;

  /// Kamera-/Objektivangaben UND Aufnahmezeitpunkt einer bereits
  /// importierten Datei – für das nachträgliche Einlesen in den
  /// Werkzeugen.
  ///
  /// Denselben Rückfall wie beim Import: Liefert `package:exif` bei einer
  /// RAW-Datei gar nichts, wird der native Weg gefragt.
  Future<Aufnahmedaten> readAufnahmedaten(File file) async {
    // Videos zuerst, und dann nicht weiter. Zwei Gründe: `package:exif`
    // liest MOV und MP4 ohnehin nicht, und ein `readAsBytes` auf eine
    // 1,7-GB-Aufnahme zöge die ganze Datei in den Speicher, um sicher
    // nichts zu finden. Massgeblich sind die Bytes und nicht die Endung –
    // in dieser Bibliothek tragen 31 Standbilder einen `.mov`-Namen, und
    // die gehören durch die EXIF-Tür.
    final endung = p.extension(file.path).toLowerCase();
    if (_videoExtensions.contains(endung) &&
        (await inhaltskennung(file, null)) == null) {
      final meta = await leseVideoMetadaten(file);
      return Aufnahmedaten(
        CameraInfo(make: meta.hersteller, model: meta.geraet),
        meta.zeit?.zeitpunkt,
      );
    }

    Map<String, IfdTag> tags = const {};
    try {
      tags = await readExifFromBytes(await file.readAsBytes());
    } catch (_) {
      // Bleibt leer – der Rückfall unten greift.
    }
    final kamera = parseExifCameraInfo(tags);
    final datum = exifDatumAusText(_rohesExifDatum(tags));
    if (kamera.isEmpty && datum == null && rawImageExtensions.contains(endung)) {
      final nativ = await NativeImageConverter.readCameraMetadata(file);
      if (!nativ.isEmpty) return nativ;
    }
    return Aufnahmedaten(kamera, datum);
  }

  /// Der Zeitstempel, wie er in den Tags steht – umgewandelt wird er von
  /// [exifDatumAusText], damit der native Weg dieselbe Umwandlung nutzt.
  ///
  /// Die Reihenfolge ist die Rangfolge:
  ///
  /// - `DateTimeOriginal` ist der Auslösezeitpunkt und damit die Antwort.
  /// - `DateTimeDigitized` ist der Zeitpunkt der Digitalisierung – bei
  ///   einer Kamera derselbe, bei einem Scan der des Scans. Immer noch
  ///   näher an der Wahrheit als das Letzte.
  /// - `Image DateTime` ist der Zeitpunkt der letzten **Änderung**. Wer
  ///   ein Foto 2019 in einem Bildbearbeiter gespeichert hat, findet es
  ///   sonst unter 2019 statt unter dem Aufnahmejahr.
  ///
  /// `DateTimeDigitized` fehlte bis Fassung 2.5. In der Prüfbibliothek
  /// änderte das Nachtragen an keinem einzigen Foto etwas – dort trägt
  /// jedes Bild mit einem Digitalisierungsdatum auch ein Aufnahmedatum.
  /// Es steht trotzdem hier, weil der Sprung von der ersten auf die dritte
  /// Wahl der teuerste im ganzen Feld ist.
  String? _rohesExifDatum(Map<String, IfdTag> tags) =>
      tags['EXIF DateTimeOriginal']?.printable ??
      tags['EXIF DateTimeDigitized']?.printable ??
      tags['Image DateTime']?.printable;
}

class _ExifMetadata {
  final DateTime? date;
  final ({double latitude, double longitude})? gps;
  final CameraInfo camera;
  const _ExifMetadata(this.date, this.gps, this.camera);
}
