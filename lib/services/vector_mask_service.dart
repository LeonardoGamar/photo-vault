import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Offset;

import 'package:image/image.dart' as img;

/// Editierbare Vektor-Maskenform (Ergänzung zu den per SAM-Punkt-Prompt
/// erzeugten KI-Masken, siehe DevelopMasks.shapeDefinitionJson) – alle
/// Koordinaten sind auf [0,1] normalisiert (relativ zur Bildbreite/-höhe),
/// damit dieselbe Form unabhängig von der tatsächlichen Renderauflösung
/// (Vorschau- vs. Originalgröße) exakt reproduzierbar bleibt und beim
/// erneuten Öffnen wieder bearbeitbar ist.
sealed class MaskShapeDefinition {
  const MaskShapeDefinition();

  Map<String, dynamic> toJson();

  static MaskShapeDefinition fromJson(Map<String, dynamic> json) => switch (json['type']) {
        'freehand' => FreehandShape.fromJson(json),
        'ellipse' => EllipseShape.fromJson(json),
        'gradient' => GradientShape.fromJson(json),
        _ => throw ArgumentError('Unbekannter Maskenform-Typ: ${json['type']}'),
      };

  /// Wie [AppDatabase.decodeSavedSearchFilters] fürs Wiederherstellen aus
  /// [shapeDefinitionJson].
  static MaskShapeDefinition decode(String source) =>
      fromJson(jsonDecode(source) as Map<String, dynamic>);

  String encode() => jsonEncode(toJson());
}

/// Freihand-Pinsel: eine Punktfolge (Tipp-/Zieh-Reihenfolge), verbunden zu
/// einem durchgehenden Band fester Breite – für unregelmäßige Bereiche
/// (Muster: der SAM-Punktauswahl-Fluss in develop_screen.dart, hier aber
/// direkt gemalt statt vom Modell vorhergesagt). Bewusst harte Kante (keine
/// Weichzeichnung) wie die bestehenden SAM-Masken, siehe
/// maskToOriginalResolution in segmentation_service.dart.
class FreehandShape extends MaskShapeDefinition {
  final List<Offset> points;

  /// Strichbreite, normalisiert relativ zur längeren Bildkante.
  final double strokeWidth;

  const FreehandShape({required this.points, this.strokeWidth = 0.03});

  @override
  Map<String, dynamic> toJson() => {
        'type': 'freehand',
        'points': [for (final p in points) [p.dx, p.dy]],
        'strokeWidth': strokeWidth,
      };

  factory FreehandShape.fromJson(Map<String, dynamic> json) => FreehandShape(
        points: [
          for (final p in json['points'] as List<dynamic>)
            Offset((p[0] as num).toDouble(), (p[1] as num).toDouble()),
        ],
        strokeWidth: (json['strokeWidth'] as num?)?.toDouble() ?? 0.03,
      );
}

/// Ellipse/Kreis mit optionaler Rotation und Randweichzeichnung – klassisch
/// für Vignettierung oder Porträt-Bereiche.
class EllipseShape extends MaskShapeDefinition {
  final double centerX;
  final double centerY;
  final double radiusX;
  final double radiusY;

  /// Rotation in Radiant.
  final double rotation;

  /// Weichzeichnung am Rand: 0 = harte Kante, 1 = Verlauf von der Mitte bis
  /// zum Rand.
  final double feather;

  const EllipseShape({
    required this.centerX,
    required this.centerY,
    required this.radiusX,
    required this.radiusY,
    this.rotation = 0,
    this.feather = 0.3,
  });

  @override
  Map<String, dynamic> toJson() => {
        'type': 'ellipse',
        'cx': centerX,
        'cy': centerY,
        'rx': radiusX,
        'ry': radiusY,
        'rotation': rotation,
        'feather': feather,
      };

  factory EllipseShape.fromJson(Map<String, dynamic> json) => EllipseShape(
        centerX: (json['cx'] as num).toDouble(),
        centerY: (json['cy'] as num).toDouble(),
        radiusX: (json['rx'] as num).toDouble(),
        radiusY: (json['ry'] as num).toDouble(),
        rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
        feather: ((json['feather'] as num?)?.toDouble() ?? 0.3).clamp(0.0, 1.0),
      );
}

/// Linearer Verlauf zwischen zwei Punkten – für Himmel-/Horizont-Korrekturen
/// (Muster: Verlaufsfilter eines klassischen RAW-Entwicklers).
class GradientShape extends MaskShapeDefinition {
  final double startX;
  final double startY;
  final double endX;
  final double endY;

  /// 0 = reiner linearer Verlauf, 1 = weich ausgerundeter (Smoothstep-)
  /// Verlauf.
  final double feather;

  const GradientShape({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    this.feather = 0.3,
  });

  @override
  Map<String, dynamic> toJson() => {
        'type': 'gradient',
        'x1': startX,
        'y1': startY,
        'x2': endX,
        'y2': endY,
        'feather': feather,
      };

  factory GradientShape.fromJson(Map<String, dynamic> json) => GradientShape(
        startX: (json['x1'] as num).toDouble(),
        startY: (json['y1'] as num).toDouble(),
        endX: (json['x2'] as num).toDouble(),
        endY: (json['y2'] as num).toDouble(),
        feather: ((json['feather'] as num?)?.toDouble() ?? 0.3).clamp(0.0, 1.0),
      );
}

double _smoothstep(double t) {
  final c = t.clamp(0.0, 1.0);
  return c * c * (3 - 2 * c);
}

/// Records-Argument-Wrapper für `compute()` (das nur eine einzelne
/// Callback-Signatur mit genau einem Argument unterstützt): rasterisiert
/// eine Form UND kodiert sie direkt zu PNG-Bytes, analog zu
/// renderMaskPngBytes in segmentation_service.dart – so kann der komplette
/// Rasterisierungs-/Kodierungsaufwand beim Bestätigen einer Vektor-Maske
/// (develop_screen.dart) vom Haupt-Isolate weg verlagert werden.
Uint8List rasterizeMaskShapeToPngBytes((MaskShapeDefinition shape, int width, int height) args) {
  final (shape, width, height) = args;
  return Uint8List.fromList(img.encodePng(rasterizeMaskShape(shape, width, height)));
}

/// Rasterisiert eine [MaskShapeDefinition] als Graustufen-Alphamaske (weiß =
/// ausgewählt, schwarz = nicht ausgewählt, Zwischenwerte an weichgezeichneten
/// Rändern) in [width]x[height] – reine, `compute()`-taugliche Funktion
/// (Muster: maskToOriginalResolution in segmentation_service.dart), sodass
/// dieselbe Rasterisierung sowohl für die native Kompositierung
/// (DevelopMasks.maskRelativePath) als auch für das Live-Overlay im
/// Entwickeln-Screen genutzt wird.
img.Image rasterizeMaskShape(MaskShapeDefinition shape, int width, int height) {
  final mask = img.Image(width: width, height: height);
  switch (shape) {
    case FreehandShape():
      _rasterizeFreehand(mask, shape, width, height);
    case EllipseShape():
      _rasterizeEllipse(mask, shape, width, height);
    case GradientShape():
      _rasterizeGradient(mask, shape, width, height);
  }
  return mask;
}

/// Malt jedes Liniensegment nur innerhalb seiner (um die Strichbreite
/// erweiterten) Bounding-Box statt über das komplette Bild zu iterieren –
/// bei einem einzelnen langen Pinselstrich auf einem hochauflösenden Foto
/// macht das den Unterschied zwischen Millisekunden und mehreren Sekunden.
void _rasterizeFreehand(img.Image mask, FreehandShape shape, int width, int height) {
  if (shape.points.isEmpty) return;
  final longerEdge = math.max(width, height).toDouble();
  final radius = (shape.strokeWidth * longerEdge / 2).clamp(0.5, longerEdge);
  final radiusSq = radius * radius;
  final pixelPoints = [for (final p in shape.points) Offset(p.dx * width, p.dy * height)];

  void paintDisc(Offset c) {
    final x0 = math.max(0, (c.dx - radius).floor());
    final x1 = math.min(width - 1, (c.dx + radius).ceil());
    final y0 = math.max(0, (c.dy - radius).floor());
    final y1 = math.min(height - 1, (c.dy + radius).ceil());
    for (var y = y0; y <= y1; y++) {
      for (var x = x0; x <= x1; x++) {
        final dx = x + 0.5 - c.dx;
        final dy = y + 0.5 - c.dy;
        if (dx * dx + dy * dy <= radiusSq) mask.setPixelRgb(x, y, 255, 255, 255);
      }
    }
  }

  void paintSegment(Offset a, Offset b) {
    final x0 = math.max(0, (math.min(a.dx, b.dx) - radius).floor());
    final x1 = math.min(width - 1, (math.max(a.dx, b.dx) + radius).ceil());
    final y0 = math.max(0, (math.min(a.dy, b.dy) - radius).floor());
    final y1 = math.min(height - 1, (math.max(a.dy, b.dy) + radius).ceil());
    final abx = b.dx - a.dx;
    final aby = b.dy - a.dy;
    final abLenSq = abx * abx + aby * aby;
    for (var y = y0; y <= y1; y++) {
      for (var x = x0; x <= x1; x++) {
        final px = x + 0.5 - a.dx;
        final py = y + 0.5 - a.dy;
        final t = abLenSq == 0 ? 0.0 : ((px * abx + py * aby) / abLenSq).clamp(0.0, 1.0);
        final closestX = a.dx + t * abx;
        final closestY = a.dy + t * aby;
        final dx = (x + 0.5) - closestX;
        final dy = (y + 0.5) - closestY;
        if (dx * dx + dy * dy <= radiusSq) mask.setPixelRgb(x, y, 255, 255, 255);
      }
    }
  }

  if (pixelPoints.length == 1) {
    paintDisc(pixelPoints.first);
  } else {
    for (var i = 0; i < pixelPoints.length - 1; i++) {
      paintSegment(pixelPoints[i], pixelPoints[i + 1]);
    }
  }
}

void _rasterizeEllipse(img.Image mask, EllipseShape shape, int width, int height) {
  final cx = shape.centerX * width;
  final cy = shape.centerY * height;
  final rx = math.max(1.0, shape.radiusX * width);
  final ry = math.max(1.0, shape.radiusY * height);
  final cosR = math.cos(shape.rotation);
  final sinR = math.sin(shape.rotation);
  final feather = shape.feather;
  final featherStart = 1 - feather;

  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final dx = x + 0.5 - cx;
      final dy = y + 0.5 - cy;
      final rdx = dx * cosR + dy * sinR;
      final rdy = -dx * sinR + dy * cosR;
      final d = math.sqrt((rdx / rx) * (rdx / rx) + (rdy / ry) * (rdy / ry));
      int value;
      if (d >= 1) {
        value = 0;
      } else if (feather <= 0 || d <= featherStart) {
        value = 255;
      } else {
        final t = (d - featherStart) / feather;
        value = (255 * (1 - _smoothstep(t))).round();
      }
      if (value > 0) mask.setPixelRgb(x, y, value, value, value);
    }
  }
}

void _rasterizeGradient(img.Image mask, GradientShape shape, int width, int height) {
  final startX = shape.startX * width;
  final startY = shape.startY * height;
  final dirX = shape.endX * width - startX;
  final dirY = shape.endY * height - startY;
  final lengthSq = dirX * dirX + dirY * dirY;
  final feather = shape.feather;

  if (lengthSq < 1e-6) {
    // Start-/Endpunkt fallen zusammen – kein sinnvoller Verlauf möglich,
    // stattdessen eine neutrale, gleichmäßig hälftig ausgewählte Maske
    // statt eines Divide-by-Zero.
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        mask.setPixelRgb(x, y, 127, 127, 127);
      }
    }
    return;
  }

  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final px = x + 0.5 - startX;
      final py = y + 0.5 - startY;
      final t = ((px * dirX + py * dirY) / lengthSq).clamp(0.0, 1.0);
      final smoothed = t + (_smoothstep(t) - t) * feather;
      final value = (255 * smoothed).round().clamp(0, 255);
      if (value > 0) mask.setPixelRgb(x, y, value, value, value);
    }
  }
}
