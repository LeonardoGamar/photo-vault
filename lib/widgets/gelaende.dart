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
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../services/gelaendeflug.dart';
import '../theme/app_spacing.dart';

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

/// Ein Punkt der Spur, so wie ihn die Geländeansicht braucht.
///
/// Die Zeit ist seit dem Flug dabei: Ohne sie gibt es kein Tempo, und ein
/// Flug, der nicht sagt, wie schnell jemand unterwegs war, lässt die
/// wichtigste Zahl der Aufzeichnung liegen. Sie darf fehlen – eine
/// geplante Route hat keine.
typedef Gelaendespurpunkt = ({
  double breite,
  double laenge,
  double? hoehe,
  DateTime? zeit,
});

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

  /// Bis wohin die Spur zurückgelegt ist, in Metern – `null` ausserhalb
  /// des Fluges.
  ///
  /// Zurückgelegt wird in voller Farbe gezeichnet, was noch kommt blass.
  /// Ohne diesen Schnitt sieht die Spur im Flug genauso aus wie im
  /// Stillstand, und man verliert, wo auf ihr man gerade ist.
  final double? gefahrenBis;

  /// Die aufsummierte Strecke bis zu jedem Punkt aus [spur] – muss zu
  /// [gefahrenBis] gehören und genauso lang sein wie [spur].
  final List<double>? streckeJePunkt;

  Gelaendemaler({
    required this.netz,
    required this.kamera,
    required this.spur,
    required this.spurfarbe,
    required this.himmel,
    this.karte,
    this.gefahrenBis,
    this.streckeJePunkt,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = himmel);

    final anzahl = netz.ecken.length ~/ 3;
    final flach = Float32List(anzahl * 2);
    // Merkposten je Eckpunkt: Liegt er hinter der Kamera?
    final hinten = List<bool>.filled(anzahl, false);
    for (var i = 0; i < anzahl; i++) {
      final p = kamera.projiziere((
        x: netz.ecken[i * 3],
        y: netz.ecken[i * 3 + 1],
        z: netz.ecken[i * 3 + 2],
      ));
      flach[i * 2] = p.stelle.dx;
      flach[i * 2 + 1] = p.stelle.dy;
      hinten[i] = p.tiefe <= 1;
    }

    // **Dreiecke hinter der Kamera fallen weg.**
    //
    // `projiziere` legt einen Punkt hinter der Kamera auf die Bildmitte –
    // das steht dort ausdrücklich dabei, und für eine Linie ist es
    // richtig, weil die Linie an der Stelle ohnehin abgesetzt wird. Für
    // `drawVertices` ist es verheerend: Flutter schneidet nicht an einer
    // vorderen Ebene, also bleibt das Dreieck stehen und spannt sich vom
    // Bildrand bis in die Mitte. Am Bild sind das Schlieren, die aus
    // einem Punkt herausfächern.
    //
    // In der Übersicht kam das nie vor – dort steht die Kamera immer
    // ausserhalb der Landschaft. Beim Flug steht sie mittendrin, und
    // hinter ihr liegt die halbe Karte.
    //
    // Ein Dreieck zu einem Punkt zusammenzuziehen ist die billigste
    // Fassung von „nicht zeichnen": Es hat dann keine Fläche mehr. Das
    // richtige Beschneiden an der vorderen Ebene würde Dreiecke teilen
    // und neue Eckpunkte erzeugen – Aufwand für einen Rand, den man
    // ohnehin nicht ansieht, weil er hinter einem liegt.
    for (var d = 0; d < anzahl; d += 3) {
      if (hinten[d] || hinten[d + 1] || hinten[d + 2]) {
        for (var k = 1; k < 3; k++) {
          flach[(d + k) * 2] = flach[d * 2];
          flach[(d + k) * 2 + 1] = flach[d * 2 + 1];
        }
      }
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
      // Zwei Pfade statt eines: der zurückgelegte Teil und der, der noch
      // kommt. Getrennt gezeichnet und nicht als ein Pfad mit
      // wechselnder Farbe – ein Path kennt nur eine.
      final pfad = Path();
      final kommtNoch = Path();
      final teilen = gefahrenBis != null &&
          streckeJePunkt != null &&
          streckeJePunkt!.length == spur.length;
      var offen = false;
      var offenNoch = false;
      for (var i = 0; i < spur.length; i++) {
        final b = kamera.projiziere(spur[i]);
        if (b.tiefe <= 1) {
          offen = false;
          offenNoch = false;
          continue;
        }
        final schonDa = !teilen || streckeJePunkt![i] <= gefahrenBis!;
        final ziel = schonDa ? pfad : kommtNoch;
        final warOffen = schonDa ? offen : offenNoch;
        if (!warOffen) {
          ziel.moveTo(b.stelle.dx, b.stelle.dy);
        } else {
          ziel.lineTo(b.stelle.dx, b.stelle.dy);
        }
        if (schonDa) {
          offen = true;
          // Damit die beiden Hälften nicht auseinanderklaffen, beginnt
          // die kommende dort, wo die zurückgelegte endet.
          if (teilen) {
            kommtNoch.moveTo(b.stelle.dx, b.stelle.dy);
            offenNoch = true;
          }
        } else {
          offenNoch = true;
        }
      }
      if (teilen) {
        canvas.drawPath(
          kommtNoch,
          Paint()
            ..color = spurfarbe.withValues(alpha: 0.35)
            ..strokeWidth = 3
            ..style = PaintingStyle.stroke
            ..strokeJoin = StrokeJoin.round,
        );
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
      alt.spur != spur ||
      // Ohne diese Zeile stünde der Schnitt zwischen zurückgelegt und
      // kommend still, sobald die Kamera einmal gleich bleibt – etwa
      // beim Spulen an derselben Stelle.
      alt.gefahrenBis != gefahrenBis;
}

/// Die Landschaft mit Ziehen zum Drehen und Kippen – und dem Flug an der
/// Spur entlang.
class Gelaendeansicht extends StatefulWidget {
  final Gelaendenetz netz;
  final List<Raumpunkt> spur;

  /// Echte Höhe und Zeit zu jedem Punkt aus [spur]. Leer heisst: Flug
  /// ohne Zahlen – möglich, aber wortkarg.
  final List<Flugwert> spurwerte;

  final ui.Image? karte;

  /// Was am unteren Rand über der Flugleiste stehen soll – Bedienung,
  /// Namensnennung.
  ///
  /// **Warum das hier hereingereicht wird und nicht darüber gelegt.**
  /// Die Flugleiste sitzt am unteren Rand dieser Ansicht, und wer
  /// draussen einen zweiten Stapel mit `bottom:` darüberlegt, landet
  /// genau darauf – die Erklärung stand über dem Flugzeugsymbol und
  /// verdeckte den einzigen Knopf, der den Flug startet. Beides in einer
  /// Spalte zu stapeln kann nur die Stelle, die beide kennt.
  final List<Widget> fussnoten;

  const Gelaendeansicht({
    super.key,
    required this.netz,
    this.spur = const [],
    this.spurwerte = const [],
    this.karte,
    this.fussnoten = const [],
  });

  @override
  State<Gelaendeansicht> createState() => _GelaendeansichtState();
}

class _GelaendeansichtState extends State<Gelaendeansicht>
    with SingleTickerProviderStateMixin {
  /// Von Südsüdwest, leicht schräg – die Ansicht, in der man ein Tal als
  /// Tal erkennt. Genau von Süden wirkte die Landschaft flach, weil alle
  /// Kanten parallel zum Bildrand lägen.
  double _drehung = 0.35;

  /// Rund 55°. Senkrecht von oben ist eine Karte, waagerecht ist ein
  /// Strich.
  double _neigung = 0.95;

  double _zoom = 1;

  /// Wie schnell der Flug über Grund geht. Am Bildschirm eingestellt: Bei
  /// 150 m/s wirkt eine Tageswanderung wie eine Diaschau, bei 600 sieht
  /// man das Gelände nicht mehr.
  static const double _flugtempo = 300;

  late final AnimationController _uhr;
  late Gelaendeflug _flug;

  /// Ob geflogen wird – auch angehalten bleibt die Flugkamera stehen, wo
  /// sie ist. Ohne diesen Merker spränge ein Pausieren zurück in die
  /// Übersicht.
  bool _imFlug = false;

  /// Was das Ziehen beim Flug verändert: nicht die Drehung selbst, die
  /// gehört dem Weg, sondern ein Versatz darauf. So kann man sich im
  /// Flug umsehen, ohne dass die Kamera danach den Weg verliert.
  ///
  /// **Die Neigung bleibt dagegen dieselbe wie in der Übersicht.** Die
  /// erste Fassung stellte sie beim Start um, in der Annahme, ein Flug
  /// wolle flacher sehen. An echtem Gelände durchprobiert (Grindelwald,
  /// 547 bis 4035 m) stimmt das nicht: Flacher als etwa 0,8 fliegt man
  /// in einem Alpental gegen eine Wand – bei dreifacher Überhöhung stehen
  /// die Hänge dreimal so steil wie in Wirklichkeit. Zwischen 0,85 und
  /// 1,05 liest sich das Bild gut, und 0,95 liegt mittendrin. Also keine
  /// eigene Zahl, keine Umschaltung und kein Merken – der Blickwinkel
  /// gehört durchweg dem Betrachter.
  double _flugversatz = 0;

  @override
  void initState() {
    super.initState();
    _flug = Gelaendeflug(widget.spur, werte: widget.spurwerte);
    _uhr = AnimationController(vsync: this, duration: _dauer())
      ..addListener(() => setState(() {}))
      ..addStatusListener((stand) {
        // Am Ende stehen bleiben und nicht in die Übersicht springen:
        // Der letzte Blick ist das Ziel, und danach will man es ansehen.
        if (stand == AnimationStatus.completed) setState(() {});
      });
  }

  @override
  void didUpdateWidget(Gelaendeansicht alt) {
    super.didUpdateWidget(alt);
    if (alt.spur != widget.spur || alt.spurwerte != widget.spurwerte) {
      _flug = Gelaendeflug(widget.spur, werte: widget.spurwerte);
      _uhr.duration = _dauer();
    }
  }

  Duration _dauer() => _flug.moeglich
      ? _flug.dauerBei(_flugtempo)
      : const Duration(seconds: 10);

  @override
  void dispose() {
    _uhr.dispose();
    super.dispose();
  }

  void _flugSchalten() {
    setState(() {
      if (!_imFlug) {
        _imFlug = true;
        _flugversatz = 0;
        _uhr.forward(from: 0);
      } else if (_uhr.isAnimating) {
        _uhr.stop();
      } else {
        // Am Ende noch einmal von vorn, sonst weiterlaufen.
        _uhr.forward(from: _uhr.value >= 1 ? 0 : _uhr.value);
      }
    });
  }

  void _flugBeenden() {
    setState(() {
      _uhr.stop();
      _imFlug = false;
    });
  }

  void _spulen(double wert) {
    setState(() {
      _uhr.stop();
      _uhr.value = wert.clamp(0.0, 1.0);
    });
  }

  void _ziehen(DragUpdateDetails d) {
    setState(() {
      if (_imFlug) {
        _flugversatz += d.delta.dx * 0.01;
      } else {
        _drehung += d.delta.dx * 0.01;
      }
      _neigung = (_neigung - d.delta.dy * 0.01).clamp(0.15, 1.45);
    });
  }

  @override
  Widget build(BuildContext context) {
    final farben = Theme.of(context).colorScheme;
    final stand = _imFlug ? _flug.bei(_uhr.value) : null;
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
        final kamera = stand == null
            ? Gelaendekamera(
                drehung: _drehung,
                neigung: _neigung,
                entfernung: ausdehnung * 0.95 / _zoom,
                brennweite: math.min(breite, hoehe) * 1.1,
                // Etwas über der Mitte: Bei gekippter Sicht läuft die
                // Landschaft nach hinten oben aus, der Schwerpunkt liegt
                // also unterhalb des Fluchtpunkts.
                mitte: Offset(breite / 2, hoehe * 0.5),
              )
            : Gelaendekamera(
                drehung: stand.drehung + _flugversatz,
                neigung: _neigung,
                entfernung: Gelaendeflug.flugabstand(
                      ausdehnung: ausdehnung,
                      kante: gelaendeGitterkante,
                      brennweite: math.min(breite, hoehe) * 1.1,
                    ) /
                    _zoom,
                brennweite: math.min(breite, hoehe) * 1.1,
                // Beim Flug höher angesetzt: Der Weg soll im unteren
                // Drittel liegen, damit oben die Landschaft steht, in
                // die er hineinführt.
                mitte: Offset(breite / 2, hoehe * 0.62),
                blickpunkt: stand.blickpunkt,
              );
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onPanUpdate: _ziehen,
                child: Listener(
                  onPointerSignal: (e) {
                    if (e is PointerScrollEvent) {
                      setState(() => _zoom = (_zoom * (1 - e.scrollDelta.dy * 0.002))
                          .clamp(0.4, 6.0));
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
                      // Beim Flug endet die volle Farbe dort, wo man
                      // gerade ist: Was hinter einem liegt, ist
                      // zurückgelegt, was davor liegt, kommt noch. Ohne
                      // diesen Schnitt sieht die Spur im Flug genauso aus
                      // wie im Stillstand, und man verliert, wo man ist.
                      gefahrenBis: stand?.gefahrenMeter,
                      streckeJePunkt: _imFlug ? _flug.streckeJePunkt : null,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.fussnoten.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0,
                          AppSpacing.md, AppSpacing.sm),
                      // Beide biegsam: Die linke Fussnote erklärt die
                      // Bedienung und ist lang, die rechte trägt die
                      // Namensnennung. Auf einem schmalen Fenster passen
                      // sie nicht nebeneinander, und ein starres `Row`
                      // lief dort um 413 Punkte über.
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(child: widget.fussnoten.first),
                          const SizedBox(width: AppSpacing.sm),
                          if (widget.fussnoten.length > 1)
                            Flexible(child: widget.fussnoten[1]),
                        ],
                      ),
                    ),
                  if (_flug.moeglich)
                    Flugleiste(
                      flug: _flug,
                      stand: stand,
                      fortschritt: _uhr.value,
                      laeuft: _uhr.isAnimating,
                      imFlug: _imFlug,
                      beimSchalten: _flugSchalten,
                      beimBeenden: _flugBeenden,
                      beimSpulen: _spulen,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Die Leiste unter dem Flug: Steuerung, Messwerte und das Höhenprofil,
/// das mitläuft.
///
/// **Warum die Zahlen hierher gehören und nicht in eine Ecke.** Ein Flug
/// über eine Landschaft ist schön und sagt nichts. Was er soll, ist die
/// Frage beantworten „wie war der Weg" – und die beantworten Höhe,
/// Steigung und Tempo, nicht die Aussicht. Sie stehen deshalb in der
/// Leseachse unter dem Bild und nicht als Kleingedrucktes am Rand.
///
/// **Warum eine eigene Klasse.** Die Ansicht darüber ist ein
/// `CustomPaint` mit einer selbstgerechneten Kamera; hier sind es
/// Material-Widgets. Beides in einem `build` wäre zweihundert Zeilen, in
/// denen niemand mehr die Kamera findet.
class Flugleiste extends StatelessWidget {
  final Gelaendeflug flug;

  /// Der aktuelle Stand – `null` heisst: Übersicht, es wird nicht
  /// geflogen.
  final Flugstand? stand;

  final double fortschritt;
  final bool laeuft;
  final bool imFlug;
  final VoidCallback beimSchalten;
  final VoidCallback beimBeenden;
  final ValueChanged<double> beimSpulen;

  const Flugleiste({
    super.key,
    required this.flug,
    required this.stand,
    required this.fortschritt,
    required this.laeuft,
    required this.imFlug,
    required this.beimSchalten,
    required this.beimBeenden,
    required this.beimSpulen,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppTexte.of(context);
    final farben = Theme.of(context).colorScheme;
    final sprache = Localizations.localeOf(context).toString();
    final eine = NumberFormat.decimalPatternDigits(
        locale: sprache, decimalDigits: 1);

    return ColoredBox(
      color: farben.surface.withValues(alpha: 0.88),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imFlug) ...[
              _Messwerte(stand: stand!, flug: flug),
              const SizedBox(height: AppSpacing.sm),
              // Das Profil trägt die Stelle mit, an der der Flug steht –
              // und nimmt einen Griff darauf an: Wer hineinfährt, spult.
              // Dieselbe Geste, die es für die Karte schon konnte.
              _Flugprofil(flug: flug, fortschritt: fortschritt,
                  beimSpulen: beimSpulen),
            ],
            Row(
              children: [
                IconButton(
                  tooltip: !imFlug
                      ? t.flugStarten
                      : laeuft
                          ? t.flugAnhalten
                          : (fortschritt >= 1 ? t.flugNochmal : t.flugWeiter),
                  icon: Icon(!imFlug
                      ? Icons.flight_takeoff
                      : laeuft
                          ? Icons.pause_circle_outline
                          : (fortschritt >= 1
                              ? Icons.replay
                              : Icons.play_circle_outline)),
                  onPressed: beimSchalten,
                ),
                if (imFlug)
                  IconButton(
                    tooltip: t.flugBeenden,
                    icon: const Icon(Icons.zoom_out_map),
                    onPressed: beimBeenden,
                  ),
                Expanded(
                  child: Slider(
                    value: fortschritt.clamp(0.0, 1.0),
                    // Nur beim Flug greifbar: In der Übersicht bewegt der
                    // Regler nichts, was zu sehen wäre, und ein Regler
                    // ohne Wirkung ist schlimmer als keiner.
                    onChanged: imFlug ? beimSpulen : null,
                    label: t.flugFortschritt,
                  ),
                ),
                Text(
                  t.flugKm(eine.format(
                      (stand?.gefahrenMeter ?? flug.laengeMeter) / 1000)),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Höhe, Tempo, Steigung, Dauer – in einer Zeile, die umbrechen darf.
class _Messwerte extends StatelessWidget {
  final Flugstand stand;
  final Gelaendeflug flug;
  const _Messwerte({required this.stand, required this.flug});

  @override
  Widget build(BuildContext context) {
    final t = AppTexte.of(context);
    final farben = Theme.of(context).colorScheme;
    final sprache = Localizations.localeOf(context).toString();
    final eine =
        NumberFormat.decimalPatternDigits(locale: sprache, decimalDigits: 1);

    final werte = <({String name, String wert, Color? farbe})>[
      if (stand.hoeheMeter case final h?)
        (name: t.flugHoehe, wert: t.flugMeterProfil(h.round()), farbe: null),
      if (stand.tempoMeterJeSekunde case final v?)
        // In km/h und nicht in m/s: Niemand denkt eine Wanderung in
        // Metern je Sekunde.
        (name: t.flugTempo, wert: t.flugKmH(eine.format(v * 3.6)), farbe: null),
      if (stand.steigungProzent case final st?)
        (
          name: t.flugSteigung,
          wert: t.flugProzent(eine.format(st)),
          // Bergauf und bergab unterscheiden sich schon durch das
          // Vorzeichen; die Farbe macht es auf einen Blick lesbar, ohne
          // die einzige Auskunft zu sein (siehe 18. Prüfrunde).
          farbe: st.abs() < 1
              ? null
              : (st > 0 ? farben.error : farben.primary),
        ),
      if (stand.seitStart case final d?)
        (name: t.flugUnterwegs, wert: _dauertext(d), farbe: null),
    ];

    if (werte.isEmpty) {
      return Text(t.flugOhneZeit,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: farben.onSurfaceVariant));
    }

    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.xs,
      children: [
        for (final w in werte)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(w.name,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: farben.onSurfaceVariant)),
              const SizedBox(width: AppSpacing.xs),
              Text(
                w.wert,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: w.farbe,
                      fontFeatures: const [
                        // Ohne feste Zifferbreite zappelt jede Zahl bei
                        // jedem Bild – zwanzig Mal in der Sekunde.
                        ui.FontFeature.tabularFigures(),
                      ],
                    ),
              ),
            ],
          ),
      ],
    );
  }

  /// `1:04:37` bzw. `4:37` – ohne führende Null bei den Stunden und mit
  /// zweistelligen Minuten, wie man eine Dauer liest.
  static String _dauertext(Duration d) {
    final s = d.inSeconds;
    final st = s ~/ 3600;
    final min = (s % 3600) ~/ 60;
    final sek = s % 60;
    final zwei = sek.toString().padLeft(2, '0');
    return st > 0
        ? '$st:${min.toString().padLeft(2, '0')}:$zwei'
        : '$min:$zwei';
  }
}

/// Das Höhenprofil mit der Stelle, an der der Flug steht.
///
/// Eigener Maler und nicht [Hoehenprofil]: Jenes markiert einen
/// **Stützpunkt** und will angefahren werden, damit die Karte daneben
/// mitgeht. Hier ist die Stelle ein stufenloser Wert zwischen zwei
/// Punkten, sie kommt von der Uhr und nicht vom Zeiger, und der
/// zurückgelegte Teil soll sich vom kommenden abheben. Das ist genug
/// Unterschied für einen eigenen, sehr kurzen Maler – und es hält das
/// vorhandene Profil aus der Wanderansicht unangetastet.
class _Flugprofil extends StatelessWidget {
  final Gelaendeflug flug;
  final double fortschritt;
  final ValueChanged<double> beimSpulen;

  static const double hoehe = 64;

  const _Flugprofil({
    required this.flug,
    required this.fortschritt,
    required this.beimSpulen,
  });

  @override
  Widget build(BuildContext context) {
    final farben = Theme.of(context).colorScheme;
    final punkte = <({double meter, double hoehe})>[
      for (var i = 0; i < flug.werte.length; i++)
        if (flug.werte[i].hoehe case final h?)
          (meter: flug.streckeJePunkt[i], hoehe: h),
    ];
    if (punkte.length < 2) return const SizedBox.shrink();

    return Semantics(
      container: true,
      label: AppTexte.of(context).flugProfilBeschreibung,
      child: LayoutBuilder(
        builder: (context, platz) {
          void spulen(double x) =>
              beimSpulen((x / platz.maxWidth).clamp(0.0, 1.0));
          return GestureDetector(
            onHorizontalDragUpdate: (d) => spulen(d.localPosition.dx),
            onTapDown: (d) => spulen(d.localPosition.dx),
            child: CustomPaint(
              size: Size(platz.maxWidth, hoehe),
              painter: _Flugprofilmaler(
                punkte: punkte,
                gesamt: flug.laengeMeter,
                fortschritt: fortschritt,
                gefahren: farben.primary,
                kommend: farben.outlineVariant,
                marke: farben.error,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Flugprofilmaler extends CustomPainter {
  final List<({double meter, double hoehe})> punkte;
  final double gesamt;
  final double fortschritt;
  final Color gefahren;
  final Color kommend;
  final Color marke;

  _Flugprofilmaler({
    required this.punkte,
    required this.gesamt,
    required this.fortschritt,
    required this.gefahren,
    required this.kommend,
    required this.marke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (punkte.length < 2 || gesamt <= 0) return;
    var tief = punkte.first.hoehe;
    var hoch = punkte.first.hoehe;
    for (final p in punkte) {
      tief = math.min(tief, p.hoehe);
      hoch = math.max(hoch, p.hoehe);
    }
    // **Nicht bei null anfangen** – dieselbe Überlegung wie im
    // Wanderprofil: Eine Runde zwischen 300 und 380 m wäre über einer
    // Nulllinie ein waagerechter Strich. Und mindestens zehn Meter Luft,
    // sonst blähte eine flache Runde ihre Wellen zu Bergen auf.
    final luft = math.max((hoch - tief) * 0.1, 10.0);
    final unten = tief - luft;
    final oben = hoch + luft;

    double x(double meter) => meter / gesamt * size.width;
    double y(double h) =>
        size.height - (h - unten) / (oben - unten) * size.height;

    final linie = Path()..moveTo(x(punkte.first.meter), y(punkte.first.hoehe));
    for (final p in punkte.skip(1)) {
      linie.lineTo(x(p.meter), y(p.hoehe));
    }
    final gefuellt = Path.from(linie)
      ..lineTo(x(punkte.last.meter), size.height)
      ..lineTo(x(punkte.first.meter), size.height)
      ..close();

    // Der zurückgelegte Teil wird durch ein Fenster gefüllt, nicht durch
    // einen zweiten Pfad: So folgt die Kante genau der Höhenlinie,
    // stufenlos zwischen zwei Stützpunkten – ein aus Punkten gebauter
    // Teilpfad spränge von Punkt zu Punkt.
    final xJetzt = size.width * fortschritt.clamp(0.0, 1.0);
    canvas.drawPath(gefuellt, Paint()..color = kommend.withValues(alpha: 0.5));
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, xJetzt, size.height));
    canvas.drawPath(gefuellt, Paint()..color = gefahren.withValues(alpha: 0.35));
    canvas.restore();

    canvas.drawPath(
      linie,
      Paint()
        ..color = gefahren
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.drawLine(Offset(xJetzt, 0), Offset(xJetzt, size.height),
        Paint()..color = marke..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(_Flugprofilmaler alt) =>
      alt.fortschritt != fortschritt ||
      alt.punkte != punkte ||
      alt.gefahren != gefahren;
}
