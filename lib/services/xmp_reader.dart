import 'dart:io';

import 'package:xml/xml.dart';

/// Aus einem XMP-Sidecar ausgelesene Felder – Gegenstück zu
/// [buildXmpPacket] in xmp_writer.dart. Alle Felder optional, da ein
/// Sidecar (insbesondere eines, das nicht von dieser App selbst stammt,
/// z.B. aus Lightroom) nicht jedes Feld enthalten muss. Bewusst OHNE
/// Gesichts-Regionen: xmp_writer.dart hat solche nie geschrieben (kein
/// MWG-RS/Microsoft-People-Namensraum), es gibt daher nichts Verlässliches
/// zum Zurücklesen.
class XmpFields {
  final int? rating;
  final String? colorLabel;
  final String? description;
  final List<String>? tags;
  final double? latitude;
  final double? longitude;

  const XmpFields({
    this.rating,
    this.colorLabel,
    this.description,
    this.tags,
    this.latitude,
    this.longitude,
  });

  bool get isEmpty =>
      rating == null &&
      colorLabel == null &&
      description == null &&
      tags == null &&
      latitude == null &&
      longitude == null;
}

/// Liest [file] als XMP-Sidecar ein. Gibt `null` zurück, wenn die Datei
/// fehlt oder kein gültiges XML/keine `rdf:Description` enthält.
XmpFields? parseXmpFile(File file) {
  if (!file.existsSync()) return null;
  return parseXmpContent(file.readAsStringSync());
}

/// Reine Parsing-Funktion ohne Dateizugriff (Muster: [buildXmpPacket]) –
/// gut isoliert testbar. Sammelt Attribute/Elemente über ALLE
/// `rdf:Description`-Blöcke hinweg (nicht nur den ersten): reale, z.B. aus
/// Lightroom stammende XMP-Dateien verteilen Namensräume häufig auf
/// mehrere Description-Blöcke statt (wie xmp_writer.dart) alles in einen
/// einzigen zu schreiben.
XmpFields? parseXmpContent(String xmlContent) {
  final XmlDocument doc;
  try {
    doc = XmlDocument.parse(xmlContent);
  } catch (_) {
    return null;
  }

  final descriptions = doc.findAllElements('rdf:Description').toList();
  if (descriptions.isEmpty) return null;

  String? findAttribute(String name) {
    for (final d in descriptions) {
      final value = d.getAttribute(name);
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  XmlElement? findChild(String name) {
    for (final d in descriptions) {
      final match = d.findElements(name).firstOrNull;
      if (match != null) return match;
    }
    return null;
  }

  final ratingRaw = findAttribute('xmp:Rating');
  final rating = ratingRaw != null ? int.tryParse(ratingRaw) : null;

  final labelRaw = findAttribute('xmp:Label');
  final colorLabel = labelRaw != null ? _internalColorLabel(labelRaw) : null;

  final latRaw = findAttribute('exif:GPSLatitude');
  final lngRaw = findAttribute('exif:GPSLongitude');
  final latitude = latRaw != null ? _parseXmpGps(latRaw, isLatitude: true) : null;
  final longitude = lngRaw != null ? _parseXmpGps(lngRaw, isLatitude: false) : null;

  String? description;
  final descriptionElement = findChild('dc:description');
  if (descriptionElement != null) {
    final li = descriptionElement.findAllElements('rdf:li').firstOrNull;
    final text = li?.innerText.trim();
    if (text != null && text.isNotEmpty) description = text;
  }

  List<String>? tags;
  final subjectElement = findChild('dc:subject');
  if (subjectElement != null) {
    final items = subjectElement
        .findAllElements('rdf:li')
        .map((e) => e.innerText.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    if (items.isNotEmpty) tags = items;
  }

  final fields = XmpFields(
    rating: rating,
    colorLabel: colorLabel,
    description: description,
    tags: tags,
    latitude: latitude,
    longitude: longitude,
  );
  return fields.isEmpty ? null : fields;
}

/// Umkehrung von `_xmpLabelName` in xmp_writer.dart. `null` bei einem
/// unbekannten Label-Namen (z.B. eine in Lightroom frei vergebene
/// zusätzliche Farbe, die photo_vaults feste 5er-Palette nicht kennt) statt
/// eines rätselhaften internen Werts.
String? _internalColorLabel(String xmpLabel) => switch (xmpLabel) {
      'Red' => 'red',
      'Yellow' => 'yellow',
      'Green' => 'green',
      'Blue' => 'blue',
      'Purple' => 'purple',
      _ => null,
    };

/// Umkehrung von `_toXmpGps` in xmp_writer.dart (Format
/// `"Grad,Minuten.mmmmmmR"`, R = Himmelsrichtung N/S/E/W). Gibt `null` bei
/// nicht parsbaren Werten zurück, statt zu werfen – ein einzelnes
/// kaputtes GPS-Feld soll nicht den ganzen Sidecar unbrauchbar machen.
double? _parseXmpGps(String value, {required bool isLatitude}) {
  final match = RegExp(r'^(\d+),(\d+(?:\.\d+)?)([NSEW])$').firstMatch(value.trim());
  if (match == null) return null;
  final degrees = double.tryParse(match.group(1)!);
  final minutes = double.tryParse(match.group(2)!);
  final ref = match.group(3)!;
  if (degrees == null || minutes == null) return null;
  final expectedRefs = isLatitude ? const {'N', 'S'} : const {'E', 'W'};
  if (!expectedRefs.contains(ref)) return null;
  final decimal = degrees + minutes / 60;
  return (ref == 'S' || ref == 'W') ? -decimal : decimal;
}
