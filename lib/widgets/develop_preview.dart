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
const _iHighlights = 7;
const _iApplyWhiteBalance = 8;
const _iCurveActive = 9;
const _iMixerActive = 10;
const _iCubeSize = 11;
const _iClipWarn = 12;

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
  bool beschneidungZeigen = false,
}) {
  final automatisch = a.temperature == null;
  return [
    a.exposure,
    a.temperature ?? 6500.0,
    a.tint ?? 0.0,
    a.contrast,
    a.shadows,
    a.highlights,
    automatisch ? 0.0 : 1.0,
    a.toneCurve.istNeutral ? 0.0 : 1.0,
    a.colorMixer.istNeutral ? 0.0 : 1.0,
    wuerfelKante.toDouble(),
    beschneidungZeigen ? 1.0 : 0.0,
  ];
}

/// Belegt alle Uniforms und Abtaster des Entwickeln-Shaders.
///
/// Eine Stelle für beide Wege – die Live-Vorschau (siehe
/// [DevelopPreviewPainter]) und das gespeicherte Ergebnis (siehe
/// DevelopRender). Zwei Fassungen davon wären die naheliegendste Art, dass
/// Vorschau und Ergebnis auseinanderlaufen, ohne dass es jemandem auffällt:
/// Ein hier vergessener Regler wirkt dann in der Vorschau und im Bild
/// unterschiedlich.
///
/// [beschneidungZeigen] ist bewusst mit `false` vorbelegt und nicht
/// erforderlich: Der Renderpfad (DevelopRender) gibt es gar nicht erst an
/// und kann die Markierungen damit auch nicht versehentlich in eine
/// gespeicherte Datei schreiben. Sicher durch Weglassen, nicht durch
/// Sorgfalt.
void setzeDevelopUniforms(
  ui.FragmentShader shader, {
  required DevelopAdjustments adjustments,
  required double breite,
  required double hoehe,
  required ui.Image bild,
  required ui.Image curveLut,
  required ui.Image colorCube,
  required int wuerfelKante,
  bool beschneidungZeigen = false,
}) {
  final werte = developUniforms(adjustments,
      wuerfelKante: wuerfelKante, beschneidungZeigen: beschneidungZeigen);
  shader
    ..setFloat(0, breite)
    ..setFloat(1, hoehe)
    ..setFloat(_iExposure, werte[0])
    ..setFloat(_iTemperature, werte[1])
    ..setFloat(_iTint, werte[2])
    ..setFloat(_iContrast, werte[3])
    ..setFloat(_iShadows, werte[4])
    ..setFloat(_iHighlights, werte[5])
    ..setFloat(_iApplyWhiteBalance, werte[6])
    ..setFloat(_iCurveActive, werte[7])
    ..setFloat(_iMixerActive, werte[8])
    ..setFloat(_iCubeSize, werte[9])
    ..setFloat(_iClipWarn, werte[10]);
  shader
    ..setImageSampler(_sTexture, bild)
    ..setImageSampler(_sCurveLut, curveLut)
    ..setImageSampler(_sColorCube, colorCube);
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

  /// Ob beschnittene Stellen im Bild markiert werden. Nur Anzeige – siehe
  /// [setzeDevelopUniforms].
  final bool beschneidungZeigen;

  DevelopPreviewPainter({
    required this.shader,
    required this.image,
    required this.adjustments,
    required this.curveLut,
    required this.colorCube,
    required this.wuerfelKante,
    this.beschneidungZeigen = false,
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

    setzeDevelopUniforms(
      shader,
      adjustments: adjustments,
      breite: breite,
      hoehe: hoehe,
      bild: image,
      curveLut: curveLut,
      colorCube: colorCube,
      wuerfelKante: wuerfelKante,
      beschneidungZeigen: beschneidungZeigen,
    );

    canvas.save();
    canvas.translate(links, oben);
    canvas.drawRect(Offset.zero & Size(breite, hoehe), Paint()..shader = shader);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant DevelopPreviewPainter alt) =>
      alt.adjustments != adjustments ||
      alt.beschneidungZeigen != beschneidungZeigen ||
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

  /// Ob beschnittene Stellen markiert werden – reine Anzeige, wandert nie
  /// in eine gespeicherte Datei (siehe [setzeDevelopUniforms]).
  final bool beschneidungZeigen;

  const DevelopShaderPreview({
    super.key,
    required this.shader,
    required this.image,
    required this.adjustments,
    this.beschneidungZeigen = false,
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

    _platzhalter ??= await texturVonBytes(Uint8List.fromList([0, 0, 0, 255]), 1, 1);

    final kurve = widget.adjustments.toneCurve;
    final mischer = widget.adjustments.colorMixer;

    final neueKurve = kurve.istNeutral
        ? null
        : await texturVonBytes(
            packCurveLutForTexture(buildCurveLut(kurve)), curveLutSize, 1);

    final neuerWuerfel = mischer.istNeutral
        ? null
        : await texturVonBytes(
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
        beschneidungZeigen: widget.beschneidungZeigen,
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
Future<ui.Image> texturVonBytes(Uint8List bytes, int breite, int hoehe) {
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
