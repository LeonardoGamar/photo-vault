import 'package:exif/exif.dart';

/// Kamera-/Aufnahme-Metadaten aus den EXIF-Daten eines Fotos – rein
/// informativ, für die Info-Ansicht. Jedes Feld ist einzeln nullable, da
/// Kameras/Apps sehr unterschiedlich viel davon tatsächlich schreiben (ein
/// Screenshot oder ein bearbeitetes Foto hat oft gar keine dieser Tags).
class CameraInfo {
  final String? make;
  final String? model;
  final String? lensModel;
  final double? focalLengthMm;
  final double? fNumber;
  final int? iso;
  final double? exposureTimeSeconds;

  const CameraInfo({
    this.make,
    this.model,
    this.lensModel,
    this.focalLengthMm,
    this.fNumber,
    this.iso,
    this.exposureTimeSeconds,
  });

  bool get isEmpty =>
      make == null &&
      model == null &&
      lensModel == null &&
      focalLengthMm == null &&
      fNumber == null &&
      iso == null &&
      exposureTimeSeconds == null;
}

/// Liest Kamera-/Objektiv-/Aufnahme-Angaben aus bereits geparsten EXIF-Tags
/// (siehe `readExifFromBytes` aus `package:exif`). Reine, deterministische
/// Logik – bewusst von [ImportService] getrennt, damit sie ohne echte
/// Bilddateien unit-testbar ist (siehe test/exif_camera_test.dart).
///
/// WICHTIG: Für Brennweite/Blende NICHT `IfdTag.printable` verwenden – das
/// gibt bei `package:exif` den gekürzten Bruch zurück (z.B. "14/5" für ein
/// f/2.8-Objektiv, weil 28/10 auf 14/5 gekürzt wird), keine Dezimalzahl.
/// Stattdessen über `.values` als [IfdRatios] gehen und selbst umrechnen.
CameraInfo parseExifCameraInfo(Map<String, IfdTag> tags) {
  String? readString(String key) {
    final value = tags[key]?.printable.trim();
    return (value == null || value.isEmpty) ? null : value;
  }

  double? readRatio(String key) {
    final values = tags[key]?.values;
    if (values is IfdRatios && values.ratios.isNotEmpty) {
      return values.ratios.first.toDouble();
    }
    return null;
  }

  int? readInt(String key) {
    final values = tags[key]?.values;
    if (values is IfdInts && values.ints.isNotEmpty) return values.ints.first;
    if (values is IfdRatios && values.ratios.isNotEmpty) return values.ratios.first.toInt();
    return null;
  }

  return CameraInfo(
    make: readString('Image Make'),
    model: readString('Image Model'),
    lensModel: readString('EXIF LensModel'),
    focalLengthMm: readRatio('EXIF FocalLength'),
    fNumber: readRatio('EXIF FNumber'),
    iso: readInt('EXIF ISOSpeedRatings') ?? readInt('EXIF ISOSpeed'),
    exposureTimeSeconds: readRatio('EXIF ExposureTime'),
  );
}
