/// Die Landschaft – Dreiecke aus einem Höhengitter, mit `drawVertices`.
///
/// **Ohne 3D-Bibliothek und ohne Shader.** `Canvas.drawVertices` ist
/// Flutter selbst; was fehlt, ist allein die Kamera, und die steht als
/// reine Rechnung in `gelaendesicht.dart`. Bei MapLibre trug ein Paket
/// auf pub.dev einen grünen Haken für Linux und scheiterte dort trotzdem
/// – hier kommt nichts dazu, was scheitern könnte.
///
/// Die Karte liegt als Textur darauf: Geländehöhen sind keine Karte, und
/// eine Wanderung vor einer namenlosen Landschaft beantwortet keine
/// Frage.
library;

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../services/gelaendekacheln.dart';
import '../services/gelaendesicht.dart';

/// Höchstens so viele Gitterpunkte je Seite.
///
/// **Gemessen, nicht geschätzt** (`gelaende_messung_test.dart`, auf
/// einem Mac):
///
/// ```
/// Kante | Dreiecke | Zeichnen
///    32 |    1.922 |  0,24 ms
///    64 |    7.938 |  0,46 ms
///    96 |   18.050 |  0,86 ms
///   128 |   32.258 |  1,83 ms
///   192 |   72.962 |  2,82 ms
///   256 |  130.050 |  4,71 ms
/// ```
///
/// Gemessen ist dabei **nur die Rechnung in Dart** – das Aufzeichnen der
/// Dreiecke. Was die Grafikkarte daraus macht, steht hier nicht; das
/// zeigt erst die laufende App. Deshalb nicht 256, obwohl 4,71 ms in ein
/// Bild von 16,7 ms passen: Auf einer langsameren Maschine ist das ein
/// Vielfaches, und die Grafikkarte kommt obendrauf. 96 lässt Luft und
/// war am Bildschirm nicht von 192 zu unterscheiden.
const int gelaendeGitterkante = 96;

/// Die Farbe des Geländes **ohne** Karte darauf – ein sandiges Braun,
/// wie es Reliefkarten benutzen.
///
/// Liegt eine Karte darüber, muss stattdessen Weiss genommen werden:
/// `modulate` multipliziert Karte und Eckpunktfarbe, und eine gefärbte
/// Grundlage dunkelte die Karte ein zweites Mal ab. Am Bildschirm sah
/// das aus wie eine Landschaft bei Nacht.
const Color gelaendeGrundfarbe = Color(0xFFB0A99A);

/// Ein Punkt der Spur, wie die Landschaft ihn braucht.
typedef Gelaendespurpunkt = ({double breite, double laenge, double? hoehe});

/// Die fertig gerechneten Dreiecke – einmal je Gitter, nicht je Bild.
///
/// Getrennt vom Zeichnen, weil sich beim Drehen nur die Kamera ändert
/// und nicht das Gelände: Das Gitter in jedem Bild neu abzutasten wäre
/// der teuerste Teil, und er ist unnötig.
class Gelaendenetz {
  /// Je Eckpunkt drei Zahlen: Ost, Nord, Höhe – alles in Metern,
  /// bezogen auf die Mitte des Ausschnitts.
  final Float32List ecken;

  /// Je Eckpunkt zwei Zahlen: die Stelle auf der Textur, in Bildpunkten.
  final Float32List texturstellen;

  /// Je Eckpunkt eine Farbe – die Schattierung.
  final Int32List farben;

  /// Die Ausdehnung in Metern – für den Anfangsabstand der Kamera.
  final double breiteMeter;
  final double hoeheMeter;

  int get dreiecke => ecken.length ~/ 9;

  const Gelaendenetz({
    required this.ecken,
    required this.texturstellen,
    required this.farben,
    required this.breiteMeter,
    required this.hoeheMeter,
  });
}

/// Baut die Dreiecke eines Gitters.
///
/// [ueberhoehung] übertreibt die Höhe; siehe [gelaendeUeberhoehung] für
/// den Grund.
Gelaendenetz baueNetz(
  Hoehengitter gitter, {
  double ueberhoehung = gelaendeUeberhoehung,
  int kante = gelaendeGitterkante,
  Color grundfarbe = gelaendeGrundfarbe,
}) {
  final g = gitter.verkleinert(kante);
  final mitteBreite = (g.nord + g.sued) / 2;
  final mLaenge = meterJeGradLaenge(mitteBreite);
  final breiteMeter = (g.ost - g.west) * mLaenge;
  final hoeheMeter = (g.nord - g.sued) * meterJeGradBreite;
  final spanne = g.spanne;
  final mittlereHoehe = (spanne.tief + spanne.hoch) / 2;

  Raumpunkt punkt(int x, int y) {
    final h = g.bei(x, y);
    return (
      x: (x / (g.spalten - 1) - 0.5) * breiteMeter,
      // Zeile 0 liegt im Norden, und Norden ist +y.
      y: (0.5 - y / (g.zeilen - 1)) * hoeheMeter,
      z: ((h.isNaN ? mittlereHoehe : h) - mittlereHoehe) * ueberhoehung,
    );
  }

  final felder = (g.spalten - 1) * (g.zeilen - 1);
  final ecken = Float32List(felder * 2 * 3 * 3);
  final texturstellen = Float32List(felder * 2 * 3 * 2);
  final farben = Int32List(felder * 2 * 3);
  final texturBreite = (g.spalten - 1).toDouble();
  final texturHoehe = (g.zeilen - 1).toDouble();

  var e = 0;
  var tz = 0;
  var f = 0;
  void lege(Raumpunkt p, int x, int y, int farbe) {
    ecken[e++] = p.x;
    ecken[e++] = p.y;
    ecken[e++] = p.z;
    texturstellen[tz++] = x / texturBreite;
    texturstellen[tz++] = y / texturHoehe;
    farben[f++] = farbe;
  }

  for (var y = 0; y < g.zeilen - 1; y++) {
    for (var x = 0; x < g.spalten - 1; x++) {
      final a = punkt(x, y);
      final b = punkt(x + 1, y);
      final c = punkt(x, y + 1);
      final d = punkt(x + 1, y + 1);
      // Zwei Dreiecke je Feld, jedes mit seiner eigenen Schattierung.
      // Eine Schattierung je Eckpunkt sähe weicher aus und verwischte
      // genau die Kanten, die ein Gelände lesbar machen.
      final f1 = _farbe(grundfarbe, schattierung(normale(a, b, c)));
      lege(a, x, y, f1);
      lege(b, x + 1, y, f1);
      lege(c, x, y + 1, f1);
      final f2 = _farbe(grundfarbe, schattierung(normale(b, d, c)));
      lege(b, x + 1, y, f2);
      lege(d, x + 1, y + 1, f2);
      lege(c, x, y + 1, f2);
    }
  }

  return Gelaendenetz(
    ecken: ecken,
    texturstellen: texturstellen,
    farben: farben,
    breiteMeter: breiteMeter,
    hoeheMeter: hoeheMeter,
  );
}

int _farbe(Color grund, double licht) {
  int kanal(double v) => (v * licht * 255).round().clamp(0, 255);
  return (0xFF << 24) |
      (kanal(grund.r) << 16) |
      (kanal(grund.g) << 8) |
      kanal(grund.b);
}

/// Zeichnet ein Netz mit einer Kamera.
class Gelaendemaler extends CustomPainter {
  final Gelaendenetz netz;
  final Gelaendekamera kamera;

  /// Die Karte als Textur – `null` heisst: nur schattiertes Gelände.
  final ui.Image? karte;

  /// Die Spur, in denselben Metern wie das Netz.
  final List<Raumpunkt> spur;
  final Color spurfarbe;
  final Color himmel;

  Gelaendemaler({
    required this.netz,
    required this.kamera,
    required this.spur,
    required this.spurfarbe,
    required this.himmel,
    this.karte,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = himmel);

    final anzahl = netz.ecken.length ~/ 3;
    final flach = Float32List(anzahl * 2);
    for (var i = 0; i < anzahl; i++) {
      final p = kamera.projiziere((
        x: netz.ecken[i * 3],
        y: netz.ecken[i * 3 + 1],
        z: netz.ecken[i * 3 + 2],
      ));
      flach[i * 2] = p.stelle.dx;
      flach[i * 2 + 1] = p.stelle.dy;
    }

    final ecken = ui.Vertices.raw(
      ui.VertexMode.triangles,
      flach,
      colors: netz.farben,
      textureCoordinates: karte == null ? null : _texturInBildpunkten(),
    );
    if (karte == null) {
      canvas.drawVertices(ecken, BlendMode.dst, Paint());
    } else {
      // `modulate` multipliziert die Karte mit der Schattierung: Man
      // sieht die Wege *und* das Relief. Nur die Karte wäre eine flache
      // Karte in Schräglage, nur die Schattierung wären Berge ohne Wege.
      canvas.drawVertices(
        ecken,
        BlendMode.modulate,
        Paint()
          ..shader = ui.ImageShader(karte!, TileMode.clamp, TileMode.clamp,
              Matrix4.identity().storage)
          ..filterQuality = FilterQuality.low,
      );
    }
    ecken.dispose();

    if (spur.length > 1) {
      final pfad = Path();
      var offen = false;
      for (final p in spur) {
        final b = kamera.projiziere(p);
        if (b.tiefe <= 1) {
          offen = false;
          continue;
        }
        if (!offen) {
          pfad.moveTo(b.stelle.dx, b.stelle.dy);
          offen = true;
        } else {
          pfad.lineTo(b.stelle.dx, b.stelle.dy);
        }
      }
      canvas.drawPath(
        pfad,
        Paint()
          ..color = spurfarbe
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  /// Die Texturstellen liegen als Anteil vor; `ImageShader` erwartet
  /// Bildpunkte.
  Float32List _texturInBildpunkten() {
    final bild = karte!;
    final aus = Float32List(netz.texturstellen.length);
    for (var i = 0; i < aus.length; i += 2) {
      aus[i] = netz.texturstellen[i] * bild.width;
      aus[i + 1] = netz.texturstellen[i + 1] * bild.height;
    }
    return aus;
  }

  @override
  bool shouldRepaint(Gelaendemaler alt) =>
      alt.netz != netz ||
      alt.kamera != kamera ||
      alt.karte != karte ||
      alt.spur != spur;
}

/// Die Landschaft mit Ziehen zum Drehen und Kippen.
class Gelaendeansicht extends StatefulWidget {
  final Gelaendenetz netz;
  final List<Raumpunkt> spur;
  final ui.Image? karte;

  const Gelaendeansicht({
    super.key,
    required this.netz,
    this.spur = const [],
    this.karte,
  });

  @override
  State<Gelaendeansicht> createState() => _GelaendeansichtState();
}

class _GelaendeansichtState extends State<Gelaendeansicht> {
  /// Von Südsüdwest, leicht schräg – die Ansicht, in der man ein Tal als
  /// Tal erkennt. Genau von Süden wirkte die Landschaft flach, weil alle
  /// Kanten parallel zum Bildrand lägen.
  double _drehung = 0.35;

  /// Rund 55°. Senkrecht von oben ist eine Karte, waagerecht ist ein
  /// Strich.
  double _neigung = 0.95;

  double _zoom = 1;

  void _ziehen(DragUpdateDetails d) {
    setState(() {
      _drehung += d.delta.dx * 0.01;
      _neigung = (_neigung - d.delta.dy * 0.01).clamp(0.15, 1.45);
    });
  }

  @override
  Widget build(BuildContext context) {
    final farben = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, platz) {
        final breite = platz.maxWidth;
        final hoehe = platz.maxHeight;
        // Der Abstand richtet sich nach der Ausdehnung: Eine
        // Zwölf-Kilometer-Wanderung und ein Mittelgebirge sollen beide
        // ins Bild passen, ohne dass jemand zoomt.
        final ausdehnung =
            math.max(widget.netz.breiteMeter, widget.netz.hoeheMeter);
        // Am Bildschirm eingestellt: Mit dem Faktor 1,6 lag die
        // Landschaft als Briefmarke in der Mitte eines schwarzen
        // Fensters.
        final kamera = Gelaendekamera(
          drehung: _drehung,
          neigung: _neigung,
          entfernung: ausdehnung * 0.95 / _zoom,
          brennweite: math.min(breite, hoehe) * 1.1,
          // Etwas über der Mitte: Bei gekippter Sicht läuft die
          // Landschaft nach hinten oben aus, der Schwerpunkt liegt also
          // unterhalb des Fluchtpunkts.
          mitte: Offset(breite / 2, hoehe * 0.5),
        );
        return GestureDetector(
          onPanUpdate: _ziehen,
          child: Listener(
            onPointerSignal: (e) {
              if (e is PointerScrollEvent) {
                setState(() => _zoom =
                    (_zoom * (1 - e.scrollDelta.dy * 0.002)).clamp(0.4, 6.0));
              }
            },
            child: CustomPaint(
              size: Size(breite, hoehe),
              painter: Gelaendemaler(
                netz: widget.netz,
                kamera: kamera,
                spur: widget.spur,
                karte: widget.karte,
                spurfarbe: farben.error,
                himmel: farben.surfaceContainerLowest,
              ),
            ),
          ),
        );
      },
    );
  }
}
