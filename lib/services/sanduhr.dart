/// Die Anordnung der Sanduhr-Ansicht: Vorfahren nach oben, Nachkommen
/// nach unten, die gewählte Person in der Taille.
///
/// Der Grund, warum das eine eigene Datei ist und nicht im Bildschirm
/// steht: Genau hier lag die Beschränkung, die den Baum bisher auf eine
/// Reihe festnagelte. Mehrere Generationen in flachen Reihen zu zeichnen
/// erzeugt mehrdeutige Linien – welcher Großelternteil zu welchem
/// Elternteil gehört, geht verloren. Die Lösung ist keine andere Grafik,
/// sondern eine andere Rechnung: Jeder Vorfahr bekommt seinen **eigenen
/// Platz über seinem Kind**, rekursiv. Ob das aufgeht, sieht man dem Bild
/// nicht an – man rechnet es nach.
library;

import 'stammbaum.dart';

/// Ein Kasten in der Sanduhr, in Rasterkoordinaten.
///
/// [spalte] und [reihe] sind Vielfache der Kastengröße, nicht Punkte –
/// die Umrechnung in Pixel gehört in die Zeichnung, nicht hierher.
class Sanduhrknoten {
  final String personId;

  /// Waagerechte Lage. Kann gebrochen sein: Ein Elternteil sitzt mittig
  /// über seinen Kindern, und bei zwei Kindern liegt diese Mitte zwischen
  /// zwei Spalten.
  final double spalte;

  /// Reihe, von der Mitte aus gezählt: negativ nach oben (Vorfahren),
  /// 0 für die gewählte Person, positiv nach unten (Nachkommen).
  final int reihe;

  /// Ob dieser Knoten ein Partner ist, der nur wegen der gemeinsamen
  /// Kinder mitgezeichnet wird.
  final bool istPartner;

  const Sanduhrknoten({
    required this.personId,
    required this.spalte,
    required this.reihe,
    this.istPartner = false,
  });

  @override
  String toString() =>
      'Knoten($personId, Reihe $reihe, Spalte ${spalte.toStringAsFixed(2)}'
      '${istPartner ? ", Partner" : ""})';
}

/// Eine Verbindung zwischen zwei Knoten.
class Sanduhrkante {
  final String vonId;
  final String zuId;

  /// Wie die Verbindung zustande kommt – bestimmt, ob sie durchgezogen
  /// (leiblich) oder gestrichelt (Adoption/Pflege) gezeichnet wird und ob
  /// sie überhaupt senkrecht verläuft (Partner: waagerecht).
  final Verwandtschaft art;

  const Sanduhrkante(this.vonId, this.zuId, this.art);
}

/// Das Ergebnis einer Anordnung.
class Sanduhr {
  final List<Sanduhrknoten> knoten;
  final List<Sanduhrkante> kanten;

  const Sanduhr(this.knoten, this.kanten);

  double get vonSpalte =>
      knoten.isEmpty ? 0 : knoten.map((k) => k.spalte).reduce((a, b) => a < b ? a : b);
  double get bisSpalte =>
      knoten.isEmpty ? 0 : knoten.map((k) => k.spalte).reduce((a, b) => a > b ? a : b);
  int get obersteReihe =>
      knoten.isEmpty ? 0 : knoten.map((k) => k.reihe).reduce((a, b) => a < b ? a : b);
  int get untersteReihe =>
      knoten.isEmpty ? 0 : knoten.map((k) => k.reihe).reduce((a, b) => a > b ? a : b);
}

/// Wie viele Generationen die Sanduhr höchstens in jede Richtung zeigt.
///
/// Drei nach oben sind acht Urgroßeltern-Plätze – schon breit. Vier wären
/// sechzehn und damit doppelt so breit wie hoch; wer so weit hinauf will,
/// ist mit dem Fächer besser bedient, der dafür gebaut ist.
const maxSanduhrOben = 3;

/// Nach unten großzügiger: Nachkommen verzweigen unregelmäßig, und ein
/// einzelner langer Ast kostet keine Breite.
const maxSanduhrUnten = 3;

/// Ordnet die Sanduhr um [wurzel] an.
///
/// [ordnung] legt die Reihenfolge unter Geschwistern und zwischen
/// Elternteilen fest – dieselbe wie überall sonst im Stammbaum.
Sanduhr ordneSanduhr(
  Verwandtschaftsnetz netz,
  String wurzel,
  int Function(String) ordnung, {
  int oben = maxSanduhrOben,
  int unten = maxSanduhrUnten,
}) {
  final knoten = <Sanduhrknoten>[];
  final kanten = <Sanduhrkante>[];
  final gesehen = <String>{wurzel};

  // ------------------------------------------------------------------
  // Nach unten: Die Breite eines Astes ergibt sich aus seinen Kindern.
  // ------------------------------------------------------------------
  double breiteNachUnten(String id, int stufe, Set<String> pfad) {
    if (stufe >= unten || !pfad.add(id)) return 1;
    final kinder = netz.kinder(id).where((k) => !pfad.contains(k)).toList()
      ..sort((a, b) => ordnung(a).compareTo(ordnung(b)));
    if (kinder.isEmpty) {
      pfad.remove(id);
      return 1;
    }
    var summe = 0.0;
    for (final k in kinder) {
      summe += breiteNachUnten(k, stufe + 1, pfad);
    }
    pfad.remove(id);
    return summe;
  }

  void legeNachUnten(String id, double links, int stufe, Set<String> pfad) {
    if (stufe >= unten || !pfad.add(id)) return;
    final kinder = netz.kinder(id).where((k) => !pfad.contains(k)).toList()
      ..sort((a, b) => ordnung(a).compareTo(ordnung(b)));
    var x = links;
    for (final k in kinder) {
      final breite = breiteNachUnten(k, stufe + 1, {...pfad});
      if (gesehen.add(k)) {
        knoten.add(Sanduhrknoten(
          personId: k,
          spalte: x + breite / 2 - 0.5,
          reihe: stufe + 1,
        ));
      }
      kanten.add(Sanduhrkante(
          k, id, netz.elternArt(k, id) ?? Verwandtschaft.elternteil));
      legeNachUnten(k, x, stufe + 1, pfad);
      x += breite;
    }
    pfad.remove(id);
  }

  // ------------------------------------------------------------------
  // Nach oben: Jeder Vorfahr bekommt seinen eigenen Platz über seinem
  // Kind. Die Breite verdoppelt sich mit jeder Stufe – genau das macht
  // die Linien eindeutig.
  // ------------------------------------------------------------------
  void legeNachOben(String id, double mitte, int stufe, double breite) {
    if (stufe >= oben) return;
    final eltern = netz.eltern(id).toList()
      ..sort((a, b) => ordnung(a).compareTo(ordnung(b)));
    // Höchstens zwei – mehr kann eine sich verdoppelnde Anordnung nicht
    // aufnehmen. Welche zwei, entscheidet dieselbe Ordnung; die
    // Reihen-Ansicht zeigt weiterhin alle.
    for (var i = 0; i < eltern.length && i < 2; i++) {
      final e = eltern[i];
      final versatz = (i == 0 ? -1 : 1) * breite / 2;
      final spalte = mitte + versatz;
      if (gesehen.add(e)) {
        knoten.add(Sanduhrknoten(
          personId: e,
          spalte: spalte,
          reihe: -(stufe + 1),
        ));
      }
      kanten.add(Sanduhrkante(
          id, e, netz.elternArt(id, e) ?? Verwandtschaft.elternteil));
      legeNachOben(e, spalte, stufe + 1, breite / 2);
    }
  }

  // Die Wurzel sitzt mittig über ihren Nachkommen.
  final gesamtBreite = breiteNachUnten(wurzel, 0, {});
  knoten.add(Sanduhrknoten(
    personId: wurzel,
    spalte: gesamtBreite / 2 - 0.5,
    reihe: 0,
  ));
  legeNachUnten(wurzel, 0, 0, {});

  // Die Vorfahren spannen sich über der Wurzel auf. Als Ausgangsbreite
  // vier Spalten: Damit stehen die Großeltern zwei Spalten auseinander
  // und überlappen auch dann nicht, wenn unten nur ein Kind steht.
  legeNachOben(wurzel, gesamtBreite / 2 - 0.5, 0, 4);

  // Partner der Wurzel sitzen daneben, nicht darüber oder darunter – sie
  // gehören zu keiner Generation, sondern zu einer Person.
  final partner = netz.partner(wurzel).toList()
    ..sort((a, b) => ordnung(a).compareTo(ordnung(b)));
  var seite = 1.0;
  for (final p in partner) {
    if (!gesehen.add(p)) continue;
    knoten.add(Sanduhrknoten(
      personId: p,
      spalte: gesamtBreite / 2 - 0.5 + seite,
      reihe: 0,
      istPartner: true,
    ));
    kanten.add(Sanduhrkante(wurzel, p, Verwandtschaft.partner));
    seite += 1;
  }

  return Sanduhr(knoten, kanten);
}
