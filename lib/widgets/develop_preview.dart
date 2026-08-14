import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../services/native_image_converter.dart';

/// Pfad des Shaders (siehe pubspec.yaml, Abschnitt `shaders:`).
const developShaderAsset = 'shaders/develop_adjustments.frag';

/// Reihenfolge der Uniforms nach `uSize` – muss zur `layout(location = …)`-
/// Reihenfolge in develop_adjustments.frag passen. Als benannte Konstanten,
/// damit eine Änderung im Shader hier auffällt statt still falsche Werte zu
/// setzen.
const _iExposure = 2;
const _iTemperature = 3;
const _iTint = 4;
const _iContrast = 5;
const _iShadows = 6;
const _iApplyWhiteBalance = 7;

/// Übersetzt [a] in die Uniform-Werte des Shaders – **ohne** Größe, die
/// setzt der Painter.
///
/// Reine Funktion, damit sich die Zuordnung ohne GPU testen lässt. Der
/// Rückgabewert ist nach Uniform-Index geordnet, beginnend hinter `uSize`
/// (Index 0 und 1).
///
/// `temperature == null` heißt automatischer Weißabgleich – dann bleibt der
/// Weißabgleich im Shader aus, statt einen Standardwert zu erzwingen.
List<double> developUniforms(DevelopAdjustments a) {
  final automatisch = a.temperature == null;
  return [
    a.exposure,
    a.temperature ?? 6500.0,
    a.tint ?? 0.0,
    a.contrast,
    a.shadows,
    automatisch ? 0.0 : 1.0,
  ];
}

/// Zeichnet [image] durch den Entwickeln-Shader.
class DevelopPreviewPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final ui.Image image;
  final DevelopAdjustments adjustments;

  DevelopPreviewPainter({
    required this.shader,
    required this.image,
    required this.adjustments,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Seitenverhältnis wahren (wie BoxFit.contain beim bisherigen
    // Image.memory), sonst verzerrt die Live-Vorschau gegenüber dem
    // nativen Render.
    final skalierung = (size.width / image.width) < (size.height / image.height)
        ? size.width / image.width
        : size.height / image.height;
    final breite = image.width * skalierung;
    final hoehe = image.height * skalierung;
    final links = (size.width - breite) / 2;
    final oben = (size.height - hoehe) / 2;

    shader
      ..setFloat(0, breite)
      ..setFloat(1, hoehe);
    final werte = developUniforms(adjustments);
    shader
      ..setFloat(_iExposure, werte[0])
      ..setFloat(_iTemperature, werte[1])
      ..setFloat(_iTint, werte[2])
      ..setFloat(_iContrast, werte[3])
      ..setFloat(_iShadows, werte[4])
      ..setFloat(_iApplyWhiteBalance, werte[5]);
    shader.setImageSampler(0, image);

    canvas.save();
    canvas.translate(links, oben);
    canvas.drawRect(Offset.zero & Size(breite, hoehe), Paint()..shader = shader);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant DevelopPreviewPainter alt) =>
      alt.adjustments != adjustments || !identical(alt.image, image);
}

/// Live-Vorschau der Entwickeln-Regler auf der GPU.
///
/// Bewusst nur für die Zeit des Regler-Ziehens gedacht: maßgeblich für das
/// gespeicherte Ergebnis bleibt der native Renderpfad (siehe
/// develop_adjustments.frag). Kann der Shader nicht geladen werden, zeigt
/// das Widget das unveränderte Basisbild – dann fehlt nur die
/// Live-Rückmeldung, nichts stürzt ab.
class DevelopShaderPreview extends StatelessWidget {
  final ui.FragmentShader? shader;
  final ui.Image image;
  final DevelopAdjustments adjustments;

  const DevelopShaderPreview({
    super.key,
    required this.shader,
    required this.image,
    required this.adjustments,
  });

  @override
  Widget build(BuildContext context) {
    final s = shader;
    if (s == null) return RawImage(image: image, fit: BoxFit.contain);
    return CustomPaint(
      painter: DevelopPreviewPainter(shader: s, image: image, adjustments: adjustments),
      size: Size.infinite,
    );
  }
}

/// Lädt das Shader-Programm einmalig. Gibt `null` zurück, wenn das
/// fehlschlägt (z.B. Plattform ohne Shader-Unterstützung) – die Aufrufer
/// fallen dann auf die bisherige Anzeige zurück.
Future<ui.FragmentShader?> ladeDevelopShader() async {
  try {
    final program = await ui.FragmentProgram.fromAsset(developShaderAsset);
    return program.fragmentShader();
  } catch (_) {
    return null;
  }
}
