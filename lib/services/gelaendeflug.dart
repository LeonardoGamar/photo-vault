/// Der Kameraflug entlang einer GPX-Spur – samt der Zahlen dazu.
///
/// Die Geländeansicht zeigt die Spur seit jeher als Linie im Raum, aber
/// die Kamera stand still: Wer sehen wollte, wie der Weg verläuft, musste
/// ihn mit der Maus abdrehen. Dieser Flug führt die Kamera selbst an der
/// Spur entlang und sagt dabei, wo man ist, wie hoch, wie schnell und wie
/// steil.
///
/// Reine Rechnung, ohne Flutter und ohne Uhr – der Fortschritt kommt von
/// aussen. So lässt sich jeder Punkt des Fluges prüfen, ohne ein Fenster
/// zu öffnen und ohne eine Sekunde zu warten.
library;

import 'dart:math' as math;

import 'gelaendesicht.dart';

/// Was zu einem Spurpunkt gehört, aber nicht in den Raum passt.
///
/// **Die Höhe hier ist die echte, in Metern über dem Meer.** Die des
/// [Raumpunkt] ist es nicht: Sie ist um den Mittelwert verschoben und mit
/// [gelaendeUeberhoehung] multipliziert, damit man das Tal als Tal sieht.
/// Wer sie anzeigte, zeigte eine Zahl, die es nirgends gibt.
typedef Flugwert = ({double? hoehe, DateTime? zeit});

/// Wo die Kamera bei einem bestimmten Fortschritt steht – und was dort
/// gilt.
typedef Flugstand = ({
  /// Der Punkt auf der Spur, um den die Kamera kreist.
  Raumpunkt blickpunkt,

  /// Die Drehung, die [Gelaendekamera] braucht, damit die Laufrichtung
  /// in die Tiefe des Bildes zeigt.
  double drehung,

  /// Der zurückgelegte Weg in Metern.
  double gefahrenMeter,

  /// Höhe über dem Meer, `null` wenn die Spur dort keine führt.
  double? hoeheMeter,

  /// Tempo aus den Zeitstempeln der Aufzeichnung, `null` ohne Zeiten.
  double? tempoMeterJeSekunde,

  /// Steigung in Prozent – positiv bergauf.
  double? steigungProzent,

  /// Wie lange man an dieser Stelle schon unterwegs war.
  Duration? seitStart,
});

/// Ein Flug über eine Spur.
///
/// **Der Weg wird nach Metern abgetastet, nicht nach Punkten.** Eine
/// GPX-Datei zeichnet dort dicht auf, wo jemand langsam war, und dünn auf
/// der geraden Strecke. Liefe der Fortschritt über den Index, kröche die
/// Kamera durch das Dorf und schösse über die Landstrasse. Deshalb wird
/// erst die aufsummierte Länge gebildet und darin gesucht.
///
/// **Gemessen wird waagerecht.** Die Höhe steckt in [Raumpunkt.z], dort
/// aber bereits mit [gelaendeUeberhoehung] multipliziert – sie in die
/// Wegstrecke einzurechnen hiesse, die Übertreibung mitzurechnen. „Zwölf
/// Kilometer" meint ohnehin die Strecke auf der Karte.
class Gelaendeflug {
  /// Die Spur in Netz-Metern, wie sie auch gezeichnet wird.
  final List<Raumpunkt> spur;

  /// Echte Höhe und Zeit zu jedem Punkt aus [spur], in derselben
  /// Reihenfolge. Darf leer sein – dann gibt es die Ansicht ohne Zahlen.
  final List<Flugwert> werte;

  /// Über wie viele Meter Laufrichtung, Tempo und Steigung geglättet
  /// werden.
  ///
  /// Ohne Glättung reisst jedes Zickzack die Kamera herum: Zwei
  /// aufeinanderfolgende GPX-Punkte liegen wenige Meter auseinander, und
  /// die Messungenauigkeit eines Geräts ist genauso gross. Dasselbe gilt
  /// für die Zahlen: Ein Tempo aus zwei Punkten im Sekundenabstand
  /// springt zwischen 0 und 20 km/h, und eine Steigung daraus zwischen
  /// −40 und +40 Prozent. Keine der beiden Zahlen wäre falsch, und
  /// keine wäre zu gebrauchen.
  final double glaettung;

  /// Aufsummierte waagerechte Länge bis zu jedem Punkt.
  final List<double> _bisHier;

  Gelaendeflug(this.spur, {this.werte = const [], this.glaettung = 120})
      : _bisHier = _laengenSumme(spur),
        assert(werte.isEmpty || werte.length == spur.length,
            'Zu jedem Raumpunkt gehört genau ein Wert oder gar keiner.');

  static List<double> _laengenSumme(List<Raumpunkt> spur) {
    final summe = <double>[if (spur.isNotEmpty) 0];
    for (var i = 1; i < spur.length; i++) {
      final dx = spur[i].x - spur[i - 1].x;
      final dy = spur[i].y - spur[i - 1].y;
      summe.add(summe[i - 1] + math.sqrt(dx * dx + dy * dy));
    }
    return summe;
  }

  /// Die waagerechte Gesamtlänge in Metern.
  double get laengeMeter => _bisHier.isEmpty ? 0 : _bisHier.last;

  /// Die aufsummierte Strecke bis zu jedem Stützpunkt.
  ///
  /// Für den Maler: Er soll die Spur an der Stelle teilen, an der die
  /// Kamera gerade steht – zurückgelegt in voller Farbe, was noch kommt
  /// blass. Ohne diese Liste müsste er dieselbe Summe ein zweites Mal
  /// bilden, und zwar bei jedem Bild.
  List<double> get streckeJePunkt => _bisHier;

  /// Ob sich ein Flug überhaupt lohnt.
  ///
  /// Zwei Punkte an derselben Stelle ergeben keine Richtung, und über
  /// eine Spur ohne Ausdehnung zu fliegen zeigt nichts.
  bool get moeglich => spur.length >= 2 && laengeMeter > 1;

  /// Zwischen welchen beiden Stützpunkten [meter] liegt, und wie weit
  /// dazwischen.
  ({int tief, int hoch, double anteil}) _stelleBei(double meter) {
    if (spur.length < 2) return (tief: 0, hoch: 0, anteil: 0);
    if (meter <= 0) return (tief: 0, hoch: 0, anteil: 0);
    if (meter >= laengeMeter) {
      final letzt = spur.length - 1;
      return (tief: letzt, hoch: letzt, anteil: 0);
    }
    // Binäre Suche: Eine Spur kann zehntausend Punkte haben, und dieser
    // Aufruf kommt mehrfach je Bild.
    var tief = 0;
    var hoch = _bisHier.length - 1;
    while (hoch - tief > 1) {
      final mitte = (tief + hoch) ~/ 2;
      if (_bisHier[mitte] <= meter) {
        tief = mitte;
      } else {
        hoch = mitte;
      }
    }
    final abschnitt = _bisHier[hoch] - _bisHier[tief];
    return (
      tief: tief,
      hoch: hoch,
      anteil: abschnitt <= 0 ? 0.0 : (meter - _bisHier[tief]) / abschnitt,
    );
  }

  /// Der Punkt, der [meter] weit auf der Spur liegt – zwischen den
  /// Stützpunkten geradlinig gemittelt.
  Raumpunkt punktBei(double meter) {
    if (spur.isEmpty) return Gelaendekamera.nullpunkt;
    final s = _stelleBei(meter);
    final a = spur[s.tief];
    final b = spur[s.hoch];
    return (
      x: a.x + (b.x - a.x) * s.anteil,
      y: a.y + (b.y - a.y) * s.anteil,
      z: a.z + (b.z - a.z) * s.anteil,
    );
  }

  /// Der Punkt, auf den die Kamera im Flug schaut – **geglättet**.
  ///
  /// **Warum nicht [punktBei].** Richtung, Tempo und Steigung wurden von
  /// Anfang an über [glaettung] gemittelt, der Blickpunkt aber nicht: Die
  /// Kamera sass auf dem rohen Stützpunkt. Zwei aufeinanderfolgende
  /// GPX-Punkte liegen wenige Meter auseinander, und genau so gross ist
  /// die Messungenauigkeit eines Geräts – die Kamera flog also jeden
  /// Zacken der Aufzeichnung mit, während sie schon in die richtige
  /// Richtung blickte. Am Bildschirm war das ein Zittern, das mit der
  /// Landschaft nichts zu tun hatte.
  ///
  /// **Gemittelt wird als Integral, nicht als Stichprobe**, und das war
  /// nicht die erste Fassung. Neun über das Fenster verteilte Proben zu
  /// mitteln sah nach genug aus und war es nicht: Die Proben liegen dann
  /// 30 Meter auseinander, und jede springt für sich von Stützpunkt zu
  /// Stützpunkt, während das Fenster weiterrutscht. Gemessen brachte das
  /// nur den Faktor 2,8 – sichtbar besser, aber immer noch unruhig.
  ///
  /// Der Mittelwert über ein Fenster lässt sich bei einem Streckenzug
  /// **geschlossen** ausrechnen: Über jedes Teilstück ist der Verlauf
  /// geradlinig, also ist sein Beitrag der Mittelpunkt mal die
  /// überdeckte Länge. Das Ergebnis ist stetig differenzierbar – kein
  /// Aliasing, keine Probenzahl zu wählen – und kostet so viel wie die
  /// Zahl der Teilstücke im Fenster (bei 5-Meter-Punkten und 240 Meter
  /// Fenster rund 48 Multiplikationen je Bild).
  ///
  /// Die **gezeichnete** Spur bleibt davon unberührt: Sie ist die
  /// Aufzeichnung und soll aussehen wie die Aufzeichnung.
  Raumpunkt blickpunktBei(double meter) {
    if (spur.isEmpty) return Gelaendekamera.nullpunkt;
    final f = _blickfenster(meter);
    final breite = f.bis - f.von;
    // Ein Fenster ohne Breite – an den beiden Enden – hat nichts zu
    // mitteln und liefert genau den Punkt selbst.
    if (breite <= 0) return punktBei(meter);

    var x = 0.0, y = 0.0, z = 0.0;
    final erst = _stelleBei(f.von).tief;
    for (var i = erst; i < spur.length - 1; i++) {
      final a = _bisHier[i];
      final b = _bisHier[i + 1];
      if (a >= f.bis) break;
      final von = math.max(a, f.von);
      final bis = math.min(b, f.bis);
      final laenge = bis - von;
      if (laenge <= 0) continue;
      // Der Mittelpunkt des überdeckten Stücks – über eine Gerade ist er
      // zugleich deren Mittelwert.
      final pa = punktBei(von);
      final pb = punktBei(bis);
      x += (pa.x + pb.x) / 2 * laenge;
      y += (pa.y + pb.y) / 2 * laenge;
      z += (pa.z + pb.z) / 2 * laenge;
    }
    return (x: x / breite, y: y / breite, z: z / breite);
  }

  /// Das Fenster für den **Blickpunkt** – anders als [_fenster].
  ///
  /// **Es schrumpft an den Enden, statt nach innen zu rutschen**, und der
  /// Unterschied ist der ganze Grund für zwei Fenster. Ein nach innen
  /// gerutschtes Fenster liefert am Anfang den Mittelwert über die
  /// ersten 240 Meter – die Kamera stünde beim Start also 120 Meter
  /// hinter dem Anfang der Spur und flöge am Ende über das Ziel hinaus.
  /// Für Richtung und Tempo ist das richtig (eine Richtung aus zwei
  /// Punkten wäre dort Rauschen), für eine Position ist es schlicht die
  /// falsche Stelle. Die Halbbreite läuft deshalb an beiden Enden auf
  /// null zu: volle Glättung in der Mitte, exakte Enden am Rand.
  ({double von, double bis}) _blickfenster(double meter) {
    final m = meter.clamp(0.0, laengeMeter);
    final halb = math.min(
      math.min(glaettung, laengeMeter / 2),
      math.min(m, laengeMeter - m),
    );
    return (von: m - halb, bis: m + halb);
  }

  /// Das Glättungsfenster um [meter] für Richtung, Tempo und Steigung.
  ///
  /// An den Enden rutscht es nach innen, statt zu schrumpfen – sonst
  /// wären Richtung und Tempo ausgerechnet dort am unruhigsten, wo der
  /// Flug beginnt.
  ({double von, double bis}) _fenster(double meter) {
    final halb = math.min(glaettung, laengeMeter / 2);
    var von = meter - halb;
    var bis = meter + halb;
    if (von < 0) {
      bis -= von;
      von = 0;
    }
    if (bis > laengeMeter) {
      von -= bis - laengeMeter;
      bis = laengeMeter;
    }
    return (
      von: math.max(0, von),
      bis: math.min(laengeMeter, bis),
    );
  }

  /// Die echte Höhe bei [meter], `null` wo die Spur keine führt.
  ///
  /// **Ein Loch in den Höhen ist kein Loch im Weg** – dieselbe Regel wie
  /// bei `profilpunkte`. Fehlt an einem der beiden Stützpunkte die
  /// Angabe, gilt die des anderen, statt die Stelle stumm zu machen.
  double? hoeheBei(double meter) {
    if (werte.isEmpty) return null;
    final s = _stelleBei(meter);
    final a = werte[s.tief].hoehe;
    final b = werte[s.hoch].hoehe;
    if (a == null) return b;
    if (b == null) return a;
    return a + (b - a) * s.anteil;
  }

  /// Der Zeitpunkt bei [meter], `null` ohne Zeitstempel.
  DateTime? zeitBei(double meter) {
    if (werte.isEmpty) return null;
    final s = _stelleBei(meter);
    final a = werte[s.tief].zeit;
    final b = werte[s.hoch].zeit;
    if (a == null) return b;
    if (b == null) return a;
    final spanne = b.difference(a).inMilliseconds;
    return a.add(Duration(milliseconds: (spanne * s.anteil).round()));
  }

  /// Der Flugstand bei [fortschritt] zwischen 0 und 1.
  Flugstand bei(double fortschritt) {
    final t = fortschritt.clamp(0.0, 1.0);
    final meter = laengeMeter * t;
    // Der geglättete Punkt, nicht der rohe: siehe [blickpunktBei].
    final hier = blickpunktBei(meter);

    final f = _fenster(meter);
    final von = f.von;
    final bis = f.bis;

    final a = punktBei(von);
    final b = punktBei(bis);
    final dx = b.x - a.x;
    final dy = b.y - a.y;

    final strecke = bis - von;
    final hVon = hoeheBei(von);
    final hBis = hoeheBei(bis);
    final zVon = zeitBei(von);
    final zBis = zeitBei(bis);
    final start = zeitBei(0);
    final jetzt = zeitBei(meter);

    double? tempo;
    if (zVon != null && zBis != null && strecke > 0) {
      final sekunden = zBis.difference(zVon).inMilliseconds / 1000;
      // Eine rückwärts laufende oder stehende Uhr ergibt kein Tempo.
      // Beides kommt in echten Dateien vor.
      if (sekunden > 0) tempo = strecke / sekunden;
    }

    double? steigung;
    if (hVon != null && hBis != null && strecke > 0) {
      steigung = (hBis - hVon) / strecke * 100;
    }

    return (
      blickpunkt: hier,
      // `projiziere` schiebt die Richtung (sin d, cos d) in die Tiefe –
      // also ist d der Winkel, unter dem die Laufrichtung nach hinten
      // zeigt und die Kamera dahinter steht.
      //
      // Der Sprung von +π auf −π an der Südrichtung macht hier nichts:
      // Die Kamera benutzt allein Sinus und Kosinus dieses Winkels, und
      // die sind über den Sprung hinweg stetig.
      drehung: (dx == 0 && dy == 0) ? 0.0 : math.atan2(dx, dy),
      gefahrenMeter: meter,
      hoeheMeter: hoeheBei(meter),
      tempoMeterJeSekunde: tempo,
      steigungProzent: steigung,
      seitStart: (start == null || jetzt == null)
          ? null
          : (jetzt.difference(start).isNegative
              ? Duration.zero
              : jetzt.difference(start)),
    );
  }

  /// Die Summe aller Anstiege, in Metern – `null` ohne Höhen.
  ///
  /// **Nur Anstiege, und nur echte.** Die reine Differenz zwischen
  /// Anfangs- und Endhöhe sagt bei einer Rundtour null, obwohl man
  /// tausend Meter gestiegen ist. Und jeder Zentimeter Rauschen zählte
  /// mit, wenn man alles addierte – deshalb erst ab [_rauschen] Metern.
  ///
  /// Die Höhen stammen aus der Aufzeichnung, nicht aus dem Gelände: Was
  /// das Gerät gemessen hat, ist die Aussage.
  double? get aufstiegMeter {
    if (werte.length != spur.length || werte.isEmpty) return null;
    const rauschen = 3.0;
    double? letzte;
    var summe = 0.0;
    var gesehen = false;
    for (final w in werte) {
      final h = w.hoehe;
      if (h == null) continue;
      gesehen = true;
      if (letzte == null) {
        letzte = h;
        continue;
      }
      final d = h - letzte;
      if (d > rauschen) {
        summe += d;
        letzte = h;
      } else if (d < -rauschen) {
        letzte = h;
      }
    }
    return gesehen ? summe : null;
  }

  /// Wie lange man unterwegs war – `null` ohne Zeitstempel.
  Duration? get gesamtdauer {
    DateTime? erste;
    DateTime? letzte;
    for (final w in werte) {
      final z = w.zeit;
      if (z == null) continue;
      erste ??= z;
      letzte = z;
    }
    if (erste == null || letzte == null) return null;
    final d = letzte.difference(erste);
    // Eine rückwärts laufende Uhr kommt in echten Dateien vor.
    return d.isNegative ? null : d;
  }

  /// Wie lange der ganze Flug dauern soll.
  ///
  /// Feste Geschwindigkeit über Grund statt fester Dauer: Ein
  /// Zwei-Kilometer-Spaziergang und eine Hundert-Kilometer-Radtour sind
  /// nicht gleich lang, und beide in dreissig Sekunden abzufliegen hiesse,
  /// bei der einen zu kriechen und bei der anderen nichts zu sehen. Die
  /// Grenzen fangen die Ausreisser: Unter zehn Sekunden ist es vorbei,
  /// bevor man hinsieht, über drei Minuten sitzt niemand es aus.
  Duration dauerBei(double meterJeSekunde) {
    final sekunden = (laengeMeter / meterJeSekunde).clamp(10.0, 180.0);
    return Duration(milliseconds: (sekunden * 1000).round());
  }

  /// Wie weit die Kamera beim Flug hinter dem Blickpunkt stehen muss.
  ///
  /// **Nicht nach der Länge der Spur, sondern nach der Maschenweite des
  /// Geländes.** Die erste Fassung setzte die Kamera auf ein paar hundert
  /// Meter – „tief fliegen" klang richtig. Am Bild sah man daraufhin
  /// zwei graue Dreiecke: Das Netz hat [kante] Maschen über die ganze
  /// geladene Landschaft, bei neun Kilometern also rund 94 Meter je
  /// Masche. Aus 480 Metern Abstand ist eine solche Masche 176
  /// Bildpunkte breit, und das Bild besteht aus drei Flächen.
  ///
  /// Es hilft auch nicht, das Netz feiner zu machen: Die Höhen kommen aus
  /// Kacheln mit eigener Auflösung, und feiner als die Daten wird es
  /// nicht. Also muss der Abstand mit: Bei rund [maschenpunkte]
  /// Bildpunkten je Masche sieht man die Facetten und liest die
  /// Landschaft trotzdem.
  ///
  /// Die Grenzen halten das Ergebnis zwischen „Flug" und „Übersicht" –
  /// näher als ein Siebtel der Ausdehnung wird es wieder grau, weiter als
  /// vier Fünftel ist es die Übersicht, die es schon gibt.
  static double flugabstand({
    required double ausdehnung,
    required int kante,
    required double brennweite,
    double maschenpunkte = 30,
  }) {
    if (kante <= 0 || ausdehnung <= 0) return ausdehnung;
    final masche = ausdehnung / kante;
    return (masche * brennweite / maschenpunkte)
        .clamp(ausdehnung * 0.15, ausdehnung * 0.8);
  }
}
