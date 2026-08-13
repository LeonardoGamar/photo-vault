import 'dart:io';

import 'package:flutter/services.dart';

import 'raw_formats.dart';

/// Formate, die Flutter (Skia) selbst nicht rendern kann und die das
/// Dart-Paket `image` auch nicht dekodieren kann – für diese wird immer
/// versucht, über [NativeImageConverter] eine JPEG-Vorschau zu erzeugen,
/// unabhängig davon, ob ein direkter Dekodierversuch zufällig teilweise
/// klappen würde.
const heicAndRawExtensions = {'.heic', '.heif', ...rawImageExtensions};

/// Wrapper um einen MethodChannel zur nativen macOS-Bildkonvertierung via
/// ImageIO (siehe native/macos_image_convert/ImageConverter.swift). Deckt
/// Formate ab, die Flutter selbst nicht anzeigen kann: HEIC/HEIF (Apples
/// Standardformat für iPhone-Fotos) und die meisten RAW-Formate wie DNG.
class NativeImageConverter {
  static const _channel = MethodChannel('photo_vault/image_convert');

  static bool? _supported;

  /// Prüft (und cached), ob der native Kanal verfügbar ist (Swift-Datei
  /// muss dafür manuell ins Xcode-Projekt eingebunden sein, siehe README).
  static Future<bool> isSupported() async {
    if (_supported != null) return _supported!;
    if (!Platform.isMacOS) {
      _supported = false;
      return false;
    }
    try {
      await _channel.invokeMethod('ping');
      _supported = true;
    } catch (_) {
      _supported = false;
    }
    return _supported!;
  }

  /// Konvertiert eine Bilddatei (z.B. HEIC oder DNG) zu JPEG-Bytes, skaliert
  /// auf maximal [maxDimension] Pixel an der längeren Seite. Gibt `null`
  /// zurück, falls die native Anbindung fehlt oder die Datei nicht
  /// dekodiert werden konnte.
  static Future<Uint8List?> convertToJpegBytes(
    File file, {
    int maxDimension = 2048,
    double quality = 0.9,
  }) async {
    if (!await isSupported()) return null;
    try {
      final result = await _channel.invokeMethod<Uint8List>('convertToJpeg', {
        'path': file.path,
        'maxDimension': maxDimension,
        'quality': quality,
      });
      return result;
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  /// Rendert eine Bilddatei mit nicht-destruktiven Entwicklungs-Anpassungen
  /// (siehe DevelopScreen) zu JPEG-Bytes. Für RAW-Dateien über
  /// CIRAWFilter-Eigenschaften, für alle anderen Formate über eine
  /// äquivalente CIFilter-Kette – beides in [ImageConverter.swift]s
  /// `developImage`. [masks] (siehe MaskEditor/DevelopMasks) werden NACH
  /// [adjustments] der Reihe nach übereinandergelegt, jede wirksam nur
  /// innerhalb ihrer eigenen Alphamaske. Gibt `null` zurück, falls die
  /// native Anbindung fehlt oder die Datei nicht gerendert werden konnte.
  static Future<Uint8List?> developImage(
    File file, {
    required DevelopAdjustments adjustments,
    List<MaskAdjustmentLayer> masks = const [],
    int maxDimension = 2048,
    double quality = 0.9,
  }) async {
    if (!await isSupported()) return null;
    try {
      return await _channel.invokeMethod<Uint8List>('developImage', {
        'path': file.path,
        'maxDimension': maxDimension,
        'quality': quality,
        ...adjustments.toChannelMap(),
        'masks': masks.map((m) => m.toChannelMap()).toList(),
      });
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  /// Extrahiert einen Frame aus einer Videodatei (über AVFoundation) als
  /// JPEG-Thumbnail, inklusive der Videolänge. Gibt `null` zurück, falls die
  /// native Anbindung fehlt oder das Video nicht gelesen werden konnte.
  static Future<VideoThumbnailResult?> generateVideoThumbnail(
    File file, {
    int maxDimension = 800,
  }) async {
    if (!await isSupported()) return null;
    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>('videoThumbnail', {
        'path': file.path,
        'maxDimension': maxDimension,
      });
      if (result == null) return null;
      final jpeg = result['jpeg'] as Uint8List?;
      if (jpeg == null) return null;
      final duration = (result['durationSeconds'] as num?)?.toDouble();
      return VideoThumbnailResult(jpeg, (duration != null && duration > 0) ? duration : null);
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  /// Erkennt Text in einer Bilddatei über Apples Vision-Framework (rein
  /// on-device, siehe `ImageConverter.swift`s `recognizeText`). Gibt bei
  /// keinem gefundenen Text einen leeren String zurück, `null` nur, wenn die
  /// native Anbindung fehlt oder die Erkennung selbst fehlgeschlagen ist.
  static Future<String?> recognizeText(File file) async {
    if (!await isSupported()) return null;
    try {
      return await _channel.invokeMethod<String>('recognizeText', {'path': file.path});
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  /// Schneidet ein Video nicht-destruktiv auf [startSeconds, endSeconds] zu
  /// (über AVAssetExportSession, siehe `ImageConverter.swift`s `trimVideo`)
  /// und schreibt das Ergebnis nach [outputPath]. Gibt `true` bei Erfolg
  /// zurück, `false` falls die native Anbindung fehlt oder der Export
  /// fehlgeschlagen ist – der Export selbst kann je nach Videolänge einige
  /// Sekunden dauern, es gibt bewusst keine Fortschrittsanzeige (MVP).
  static Future<bool> trimVideo(
    File file, {
    required double startSeconds,
    required double endSeconds,
    required String outputPath,
  }) async {
    if (!await isSupported()) return false;
    try {
      final success = await _channel.invokeMethod<bool>('trimVideo', {
        'path': file.path,
        'outputPath': outputPath,
        'startSeconds': startSeconds,
        'endSeconds': endSeconds,
      });
      return success ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}

/// Ergebnis der nativen Video-Frame-Extraktion: das Thumbnail als JPEG-Bytes
/// plus die Videolänge (falls vom Betriebssystem ermittelbar).
class VideoThumbnailResult {
  final Uint8List jpegBytes;
  final double? durationSeconds;
  const VideoThumbnailResult(this.jpegBytes, this.durationSeconds);
}

/// Regler-Werte des DevelopScreen für [NativeImageConverter.developImage] –
/// unveränderlich, damit sich ein Satz Einstellungen einfach speichern/
/// zurücksetzen lässt. `temperature`/`tint` sind bewusst nullable (statt
/// eines Zahlen-Default): `null` bedeutet "Kamera-Weißabgleich
/// unverändert lassen", nicht "auf 0 setzen" – anders als bei den übrigen
/// Reglern gibt es hier keinen sinnvollen neutralen Zahlenwert.
class DevelopAdjustments {
  final double exposure; // -3..3 EV
  final double? temperature; // 2000..12000 K, null = Kamera-Weißabgleich
  final double? tint; // -100..100, null = Kamera-Weißabgleich
  final double contrast; // -1..1
  final double shadows; // -1..1
  final double sharpness; // 0..1
  final double noiseReduction; // 0..1
  final bool lensCorrectionEnabled;

  const DevelopAdjustments({
    this.exposure = 0,
    this.temperature,
    this.tint,
    this.contrast = 0,
    this.shadows = 0,
    this.sharpness = 0,
    this.noiseReduction = 0,
    this.lensCorrectionEnabled = true,
  });

  /// Alle Regler auf "unverändert" – DevelopScreen zeigt bei fehlenden
  /// gespeicherten Einstellungen bewusst direkt die vorhandene Vorschau-/
  /// Originaldatei an, statt hierfür extra nativ neu zu rendern (siehe
  /// DevelopScreen._init).
  static const neutral = DevelopAdjustments();

  Map<String, Object?> toChannelMap() => {
        'exposure': exposure,
        'temperature': temperature,
        'tint': tint,
        'contrast': contrast,
        'shadows': shadows,
        'sharpness': sharpness,
        'noiseReduction': noiseReduction,
        'lensCorrectionEnabled': lensCorrectionEnabled,
      };
}

/// Eine KI-Objektmaske (siehe MaskEditor/DevelopMasks) für
/// [NativeImageConverter.developImage]: [maskFilePath] zeigt auf eine
/// Grauwert-PNG-Alphamaske, [adjustments] gilt nur innerhalb dieser Maske.
class MaskAdjustmentLayer {
  final String maskFilePath;
  final DevelopAdjustments adjustments;

  const MaskAdjustmentLayer({required this.maskFilePath, required this.adjustments});

  Map<String, Object?> toChannelMap() => {
        'path': maskFilePath,
        ...adjustments.toChannelMap(),
      };
}
