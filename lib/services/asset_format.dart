import 'package:path/path.dart' as p;

import '../db/database.dart';

/// Kurzes, für Menschen lesbares Format-Kürzel eines Assets (z.B. "JPG",
/// "DNG", "CR3", "HEIC") – für kleine Format-Hinweise in Timeline/
/// Rasteransichten und der Vollbildvorschau. Leer für Videos: dort zeigt
/// bereits ein eigenes Icon "Video"/"Live Photo" an (siehe
/// AssetThumbnailTile), ein zusätzliches Format-Kürzel wäre redundant. Für
/// RAW-Formate (siehe raw_formats.dart) genügt die Dateiendung selbst als
/// Antwort auf "welches RAW-Format" – der generische Fallback unten deckt
/// sie automatisch ab, ohne dass hier ein eigener `case` nötig wäre.
String assetFormatLabel(AssetData asset) {
  if (asset.type != 'IMAGE') return '';
  final ext = p.extension(asset.relativePath).toLowerCase();
  switch (ext) {
    case '.jpg':
    case '.jpeg':
      return 'JPG';
    case '.png':
      return 'PNG';
    case '.heic':
    case '.heif':
      return 'HEIC';
    case '.webp':
      return 'WEBP';
    case '.gif':
      return 'GIF';
    case '.bmp':
      return 'BMP';
    case '.tiff':
    case '.tif':
      return 'TIFF';
    case '.dng':
      return 'DNG';
    default:
      return ext.isEmpty ? '' : ext.substring(1).toUpperCase();
  }
}

bool assetHasLocation(AssetData asset) => asset.latitude != null && asset.longitude != null;

/// Ob [asset] ein Panoramafoto ist (sehr breites Seitenverhältnis) – für die
/// Vollbildansicht, die solche Fotos pan-/zoombar statt mit großen
/// Letterbox-Rändern anzeigen soll (siehe AssetViewerScreen). Nutzt die
/// bereits beim Import gespeicherten Originalmaße statt eines eigenen
/// Dekodierens; alte Assets ohne gespeicherte Maße gelten bewusst nicht als
/// Panorama statt eine Annahme zu raten.
bool isPanorama(AssetData asset) {
  final width = asset.widthPx;
  final height = asset.heightPx;
  if (width == null || height == null || height == 0) return false;
  return width / height >= 2.5;
}

/// Enger gefasst als [isPanorama] (>= 2.5): erkennt speziell equirechteckige
/// 360°-Aufnahmen (Seitenverhältnis exakt ~2:1, wie sie 360°-Kameras
/// erzeugen), die eine echte Kugelprojektion statt eines nur horizontal
/// schwenkbaren Streifens brauchen (siehe Panorama360View). Ein solches Foto
/// läge mit 2.0 UNTER der [isPanorama]-Schwelle von 2.5 und würde sonst gar
/// nicht als Sonderfall erkannt.
///
/// Reine Seitenverhältnis-Heuristik – es wird keine GPano-XMP-Metadaten
/// (`GPano:ProjectionType` & Co., das verlässlichere, kamera-geschriebene
/// Signal) ausgewertet, das würde das Extrahieren eingebetteter XMP-Pakete
/// aus JPEGs voraussetzen, was hier (noch) nicht existiert. Bekannte Grenze:
/// ein zufällig exakt 2:1 zugeschnittenes, aber nicht-equirechteckiges Foto
/// würde fälschlich erkannt.
bool isEquirectangular360(AssetData asset) {
  final width = asset.widthPx;
  final height = asset.heightPx;
  if (width == null || height == null || height == 0) return false;
  final ratio = width / height;
  return ratio >= 1.9 && ratio <= 2.1;
}

/// Kamera-Hersteller + -Modell kombiniert – viele Kameras (v.a. Nikon/Canon)
/// wiederholen den Hersteller bereits im Modellnamen (z.B. "Canon EOS R5"),
/// dann reicht die Anzeige des Modells allein.
String? cameraLabel(AssetData asset) {
  final make = asset.cameraMake?.trim();
  final model = asset.cameraModel?.trim();
  if (make == null || make.isEmpty) return (model == null || model.isEmpty) ? null : model;
  if (model == null || model.isEmpty) return make;
  return model.toLowerCase().startsWith(make.toLowerCase()) ? model : '$make $model';
}

String formatFocalLength(double mm) {
  final isWhole = (mm - mm.roundToDouble()).abs() < 0.05;
  return '${isWhole ? mm.toStringAsFixed(0) : mm.toStringAsFixed(1)} mm';
}

String formatFNumber(double f) {
  final isWhole = (f - f.roundToDouble()).abs() < 0.05;
  return 'f/${isWhole ? f.toStringAsFixed(0) : f.toStringAsFixed(1)}';
}

String formatExposureTime(double seconds) {
  if (seconds <= 0) return '$seconds s';
  if (seconds >= 1) {
    final isWhole = (seconds - seconds.roundToDouble()).abs() < 0.01;
    return '${isWhole ? seconds.toStringAsFixed(0) : seconds.toStringAsFixed(1)} s';
  }
  return '1/${(1 / seconds).round()} s';
}

/// Kehrt [formatExposureTime] um – akzeptiert sowohl Brüche ("1/125") als
/// auch Dezimalwerte ("0.5" oder "0,5"), für das Belichtungszeit-Feld im
/// Metadaten-Editor. Gibt `null` zurück, wenn der Text leer oder nicht
/// interpretierbar ist.
double? parseExposureTimeInput(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return null;
  if (trimmed.contains('/')) {
    final parts = trimmed.split('/');
    if (parts.length != 2) return null;
    final a = double.tryParse(parts[0].trim());
    final b = double.tryParse(parts[1].trim());
    if (a == null || b == null || b == 0) return null;
    return a / b;
  }
  return double.tryParse(trimmed.replaceAll(',', '.'));
}
