import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../services/develop_color.dart';
import '../services/native_image_converter.dart';

/// Pfad des Shaders (siehe pubspec.yaml, Abschnitt `shaders:`).
const developShaderAsset = 'shaders/develop_adjustments.frag';

/// Reihenfolge der Uniforms nach `uSize` – muss zur Deklarations-
/// reihenfolge in develop_adjustments.frag passen. Als benannte Konstanten,
/// damit eine Änderung im Shader hier auffällt statt still falsche Werte zu
/// setzen.
const _iExposure = 2;
const _iTemperature = 3;
const _iTint = 4;
const _iContrast = 5;
const _iShadows = 6;
const _iApplyWhiteBalance = 7;
const _iCurveActive = 8;
const _iMixerActive = 9;
const _iCubeSize = 10;

/// Reihenfolge der Bildabtaster – eigener Indexraum, ebenfalls nach
/// Deklarationsreihenfolge.
const _sTexture = 0;
const _sCurveLut = 1;
const _sColorCube = 2;

/// Übersetzt [a] in die Uniform-Werte des Shaders – **ohne** Größe, die
/// setzt der Painter.
///
/// Reine Funktion, damit sich die Zuordnung ohne GPU testen lässt. Der
/// Rückgabewert ist nach Uniform-Index geordnet, beginnend hinter `uSize`
/// (Index 0 und 1).
///
/// `temperature == null` heißt automatischer Weißabgleich – dann bleibt der
/// Weißabgleich im Shader aus, statt einen Standardwert zu erzwingen.
///
/// [wuerfelKante] ist die tatsächlich hochgeladene Kantenlänge des
/// Farbwürfels; die Vorschau benutzt eine gröbere als der gespeicherte
/// Render (siehe [colorCubePreviewSize]).
List<double> developUniforms(
  DevelopAdjustments a, {
  int wuerfelKante = colorCubePreviewSize,
}) {
  final automatisch = a.temperature == null;
  return [
    a.exposure,
    a.temperature ?? 6500.0,
    a.tint ?? 0.0,
    a.contrast,
    a.shadows,
    automatisch ? 0.0 : 1.0,
    a.toneCurve.istNeutral ? 0.0 : 1.0,
    a.colorMixer.istNeutral ? 0.0 : 1.0,
    wuerfelKante.toDouble(),
  ];
}

/// Zeichnet [image] durch den Entwickeln-Shader.
class DevelopPreviewPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final ui.Image image;
  final DevelopAdjustments adjustments;

  /// Tonwertkurve und Farbmischer als Textur. Beide sind Pflicht, auch wenn
  /// das jeweilige Werkzeug neutral ist: Ein Shader mit einem nicht
  /// gesetzten Bildabtaster zeichnet gar nicht. Für den neutralen Fall
  /// genügt ein 1×1-Platzhalter, den `uCurveActive`/`uMixerActive` dann
  /// ohnehin nie liest.
  final ui.Image curveLut;
  final ui.Image colorCube;
  final int wuerfelKante;

  DevelopPreviewPainter({
    required this.shader,
    required this.image,
    required this.adjustments,
    required this.curveLut,
    required this.colorCube,
    required this.wuerfelKante,
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
    final werte = developUniforms(adjustments, wuerfelKante: wuerfelKante);
    shader
      ..setFloat(_iExposure, werte[0])
      ..setFloat(_iTemperature, werte[1])
      ..setFloat(_iTint, werte[2])
      ..setFloat(_iContrast, werte[3])
      ..setFloat(_iShadows, werte[4])
      ..setFloat(_iApplyWhiteBalance, werte[5])
      ..setFloat(_iCurveActive, werte[6])
      ..setFloat(_iMixerActive, werte[7])
      ..setFloat(_iCubeSize, werte[8]);
    shader
      ..setImageSampler(_sTexture, image)
      ..setImageSampler(_sCurveLut, curveLut)
      ..setImageSampler(_sColorCube, colorCube);

    canvas.save();
    canvas.translate(links, oben);
    canvas.drawRect(Offset.zero & Size(breite, hoehe), Paint()..shader = shader);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant DevelopPreviewPainter alt) =>
      alt.adjustments != adjustments ||
      !identical(alt.image, image) ||
      !identical(alt.curveLut, curveLut) ||
      !identical(alt.colorCube, colorCube);
}

/// Live-Vorschau der Entwickeln-Regler auf der GPU.
///
/// Bewusst nur für die Zeit des Regler-Ziehens gedacht: maßgeblich für das
/// gespeicherte Ergebnis bleibt der native Renderpfad (siehe
/// develop_adjustments.frag). Kann der Shader nicht geladen werden, zeigt
/// das Widget das unveränderte Basisbild – dann fehlt nur die
/// Live-Rückmeldung, nichts stürzt ab.
class DevelopShaderPreview extends StatefulWidget {
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
  State<DevelopShaderPreview> createState() => _DevelopShaderPreviewState();
}

class _DevelopShaderPreviewState extends State<DevelopShaderPreview> {
  ui.Image? _platzhalter;
  ui.Image? _curveLut;
  ui.Image? _colorCube;

  /// Verwirft spät fertig gewordene Texturen, wenn die Regler inzwischen
  /// weitergezogen wurden – dasselbe Muster wie `_requestToken` im
  /// Entwickeln-Bildschirm.
  int _token = 0;

  @override
  void initState() {
    super.initState();
    _baueTexturen();
  }

  @override
  void didUpdateWidget(DevelopShaderPreview alt) {
    super.didUpdateWidget(alt);
    // Nur neu bauen, wenn sich Kurve oder Mischer tatsächlich geändert
    // haben – der Würfelbau kostet Millisekunden, die Belichtung zu ziehen
    // darf ihn nicht auslösen.
    if (alt.adjustments.toneCurve != widget.adjustments.toneCurve ||
        alt.adjustments.colorMixer != widget.adjustments.colorMixer) {
      _baueTexturen();
    }
  }

  Future<void> _baueTexturen() async {
    final token = ++_token;

    _platzhalter ??= await _texturVon(Uint8List.fromList([0, 0, 0, 255]), 1, 1);

    final kurve = widget.adjustments.toneCurve;
    final mischer = widget.adjustments.colorMixer;

    final neueKurve = kurve.istNeutral
        ? null
        : await _texturVon(
            packCurveLutForTexture(buildCurveLut(kurve)), curveLutSize, 1);

    final neuerWuerfel = mischer.istNeutral
        ? null
        : await _texturVon(
            packColorCubeForTexture(
              buildColorCube(mischer, size: colorCubePreviewSize),
              size: colorCubePreviewSize,
            ),
            colorCubeStripWidth(colorCubePreviewSize),
            colorCubePreviewSize,
          );

    if (!mounted || token != _token) {
      neueKurve?.dispose();
      neuerWuerfel?.dispose();
      return;
    }

    final alteKurve = _curveLut;
    final alterWuerfel = _colorCube;
    setState(() {
      _curveLut = neueKurve;
      _colorCube = neuerWuerfel;
    });
    alteKurve?.dispose();
    alterWuerfel?.dispose();
  }

  @override
  void dispose() {
    _platzhalter?.dispose();
    _curveLut?.dispose();
    _colorCube?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shader = widget.shader;
    final platzhalter = _platzhalter;
    // Solange der Platzhalter fehlt (ein Bildaufbau lang), gibt es noch
    // keinen vollständigen Satz Abtaster – dann lieber das Basisbild als
    // eine leere Fläche.
    if (shader == null || platzhalter == null) {
      return RawImage(image: widget.image, fit: BoxFit.contain);
    }
    return CustomPaint(
      painter: DevelopPreviewPainter(
        shader: shader,
        image: widget.image,
        adjustments: widget.adjustments,
        curveLut: _curveLut ?? platzhalter,
        colorCube: _colorCube ?? platzhalter,
        wuerfelKante: colorCubePreviewSize,
      ),
      size: Size.infinite,
    );
  }
}

/// Erzeugt eine Textur aus rohen RGBA-Bytes.
///
/// 8 Bit je Kanal, nicht Fliesskomma. Die Sorge war, dass eine steile
/// Tonwertkurve dadurch in der Live-Vorschau sichtbar abstuft – die
/// Tabelle hat dann nur 256 Stützstellen, aus denen der Verlauf entsteht.
/// Am Bild geprüft (steile Kurve auf einem weichen Himmelsverlauf): keine
/// Streifen erkennbar, weder beim Ziehen noch im Vergleich zum nativen
/// Render danach. Es bleibt deshalb bei 8 Bit; `rgbaFloat32` wäre die
/// Nachbesserung, falls sich das an anderem Material doch zeigt.
Future<ui.Image> _texturVon(Uint8List bytes, int breite, int hoehe) {
  final fertig = Completer<ui.Image>();
  ui.decodeImageFromPixels(
    bytes,
    breite,
    hoehe,
    ui.PixelFormat.rgba8888,
    fertig.complete,
  );
  return fertig.future;
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
