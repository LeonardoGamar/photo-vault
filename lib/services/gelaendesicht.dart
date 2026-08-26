/// Die Kamera für die Geländeansicht – von Hand gerechnet.
///
/// **Warum ohne 3D-Bibliothek.** Bei MapLibre trug ein Paket auf pub.dev
/// einen grünen Haken für Linux und scheiterte dort trotzdem. Hier kommt
/// nichts dazu, was scheitern könnte: Gezeichnet wird mit
/// `Canvas.drawVertices`, und das ist Flutter selbst. Was fehlt, ist
/// allein die Kamera – und die sind zwei Drehungen und eine Division.
///
/// Reine Rechnung ohne Flutter-Abhängigkeit ausser `Offset`, damit sich
/// jede Drehung prüfen lässt, ohne ein Fenster zu öffnen.
library;

import 'dart:math' as math;
import 'dart:ui' show Offset;

/// Wie stark die Höhe gegenüber der Fläche übertrieben wird.
///
/// **Dreifach, und das ist eine Entscheidung, keine Messung.** Massstäblich
/// wäre eine Zwölf-Kilometer-Wanderung mit dreihundert Höhenmetern eine
/// ebene Platte: Der Höhenunterschied ist zweieinhalb Prozent der Breite.
/// Jede Geländedarstellung überhöht deshalb; wer es nicht tut, zeigt
/// nichts. Zwei ist zurückhaltend – Kartenprogramme nehmen oft drei bis
/// fünf.
const double gelaendeUeberhoehung = 3;

/// Ein Punkt im Raum, in Metern: x nach Osten, y nach Norden, z nach oben.
typedef Raumpunkt = ({double x, double y, double z});

/// Wohin ein Raumpunkt auf dem Bildschirm fällt.
typedef Bildpunkt = ({Offset stelle, double tiefe});

/// Kippen, Drehen, Zoomen – und die Umrechnung auf den Bildschirm.
class Gelaendekamera {
  /// Drehung um die Hochachse, im Bogenmass. 0 heisst: von Süden aus.
  final double drehung;

  /// Neigung, im Bogenmass. 0 wäre senkrecht von oben (eine Karte),
  /// π/2 wäre auf Augenhöhe (nichts als ein Strich).
  final double neigung;

  /// Wie weit die Kamera vom Mittelpunkt weg steht, in Metern.
  final double entfernung;

  /// Brennweite in Bildpunkten – bestimmt, wie stark die Perspektive
  /// wirkt.
  final double brennweite;

  /// Die Mitte des Bildes.
  final Offset mitte;

  const Gelaendekamera({
    required this.drehung,
    required this.neigung,
    required this.entfernung,
    required this.brennweite,
    required this.mitte,
  });

  Gelaendekamera kopieMit({
    double? drehung,
    double? neigung,
    double? entfernung,
    double? brennweite,
    Offset? mitte,
  }) =>
      Gelaendekamera(
        drehung: drehung ?? this.drehung,
        neigung: neigung ?? this.neigung,
        entfernung: entfernung ?? this.entfernung,
        brennweite: brennweite ?? this.brennweite,
        mitte: mitte ?? this.mitte,
      );

  /// Rechnet einen Raumpunkt auf den Bildschirm.
  ///
  /// Erst um die Hochachse drehen, dann kippen, dann die Kamera nach
  /// hinten schieben, dann teilen. Punkte hinter der Kamera bekommen
  /// eine [Bildpunkt.tiefe] ≤ 0 – wer sie zeichnet, bekommt Unsinn, und
  /// deshalb steht die Zahl dabei.
  Bildpunkt projiziere(Raumpunkt p) {
    final cd = math.cos(drehung);
    final sd = math.sin(drehung);
    final x1 = p.x * cd - p.y * sd;
    final y1 = p.x * sd + p.y * cd;

    final cn = math.cos(neigung);
    final sn = math.sin(neigung);
    // Nach dem Kippen zeigt y2 in die Tiefe und z2 nach oben im Bild.
    final y2 = y1 * cn - p.z * sn;
    final z2 = y1 * sn + p.z * cn;

    final tiefe = y2 + entfernung;
    if (tiefe <= 1) {
      return (stelle: Offset(mitte.dx, mitte.dy), tiefe: tiefe);
    }
    final f = brennweite / tiefe;
    // Das Minus vor z2: Auf dem Bildschirm wächst y nach unten, in der
    // Landschaft wächst die Höhe nach oben.
    return (
      stelle: Offset(mitte.dx + x1 * f, mitte.dy - z2 * f),
      tiefe: tiefe,
    );
  }
}

/// Wie viele Meter ein Grad Länge auf einer Breite misst.
double meterJeGradLaenge(double breite) =>
    111320 * math.cos(breite * math.pi / 180);

/// Und wie viele ein Grad Breite – nahezu überall gleich.
const double meterJeGradBreite = 110540;

/// Die Schattierung einer Dreiecksfläche: 0 (im Schatten) bis 1 (voll
/// beleuchtet).
///
/// Ein einfaches Lambert-Modell mit fester Sonne aus Nordwesten, wie es
/// auf jeder Reliefkarte üblich ist. **Aus Nordwesten und nicht aus
/// Südosten**, obwohl die Sonne dort nie steht: Das Auge liest eine von
/// links oben beleuchtete Fläche als erhaben und eine von rechts unten
/// beleuchtete als vertieft. Wer physikalisch richtig beleuchtet, dreht
/// jedes Tal zum Berg.
double schattierung(Raumpunkt normale) {
  // Sonne aus Nordwesten, 45° hoch.
  const lx = -0.5;
  const ly = 0.5;
  const lz = 0.707;
  final laenge = math.sqrt(normale.x * normale.x +
      normale.y * normale.y +
      normale.z * normale.z);
  if (laenge == 0) return 1;
  final punktprodukt =
      (normale.x * lx + normale.y * ly + normale.z * lz) / laenge;
  // **Viel Grundhelligkeit, wenig Richtungslicht.** Liegt eine Karte
  // darauf, multipliziert die Schattierung sie: Bei 0,45 Grundhelligkeit
  // war die halbe Karte am Bildschirm nicht mehr zu lesen. Und nicht bis
  // auf null abdunkeln – eine schwarze Nordflanke sieht aus wie ein Loch
  // im Gitter.
  return (0.72 + 0.28 * punktprodukt).clamp(0.5, 1.0);
}

/// Die Flächennormale eines Dreiecks.
Raumpunkt normale(Raumpunkt a, Raumpunkt b, Raumpunkt c) {
  final ux = b.x - a.x;
  final uy = b.y - a.y;
  final uz = b.z - a.z;
  final vx = c.x - a.x;
  final vy = c.y - a.y;
  final vz = c.z - a.z;
  return (
    x: uy * vz - uz * vy,
    y: uz * vx - ux * vz,
    z: ux * vy - uy * vx,
  );
}
