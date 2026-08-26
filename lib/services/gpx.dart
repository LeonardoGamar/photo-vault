/// GPX einlesen – und Aufnahmen nachträglich verorten.
///
/// Der eigentliche Gewinn liegt nicht bei den Wanderungen, sondern hier:
/// Eine GPX-Spur trägt Zeitstempel. Damit lassen sich Fotos aus Kameras
/// **ohne** GPS nachträglich verorten, indem man Aufnahmezeit gegen Spur
/// legt. An der echten Bibliothek gemessen tragen nur 1092 von 7988
/// Aufnahmen eine Koordinate – 86 % sind für Karte, Globus und
/// Reiseerkennung unsichtbar.
///
/// Reine Funktionen, ohne Datenbank und ohne Dateizugriff: Ob ein Foto
/// an der richtigen Stelle landet, ist eine Rechnung und keine
/// Ansichtssache.
library;

import 'package:xml/xml.dart';

/// Ein Punkt einer aufgezeichneten Spur.
typedef Spurpunkt = ({DateTime zeit, double breite, double laenge});

/// Warum eine Datei unbrauchbar war.
enum GpxAbbruch {
  /// Kein `<gpx>`-Wurzelelement – das ist keine GPX-Datei.
  keinGpx,

  /// Punkte ja, aber keiner mit Zeitstempel. Ohne Zeit lässt sich nichts
  /// zuordnen; die Spur wäre nur eine Linie.
  ohneZeit,

  /// Gar keine Punkte.
  leer,
}

class GpxFehler implements Exception {
  final GpxAbbruch grund;
  const GpxFehler(this.grund);

  @override
  String toString() => 'GpxFehler($grund)';
}

/// Die Punkte, die für eine Zuordnung taugen.
///
/// Gelesen werden `trkpt` (Spur), `rtept` (geplante Route) und `wpt`
/// (einzelne Marken) – alle drei tragen dieselben Angaben, und welches
/// Programm welches schreibt, ist nicht vorherzusehen.
///
/// **Punkte ohne `<time>` fallen weg.** Sie sind für die Linie brauchbar,
/// für das Zuordnen nicht, und eine Liste, in der die Hälfte keine Zeit
/// hat, brächte jede Suche durcheinander.
List<Spurpunkt> liesGpx(String inhalt) {
  final XmlDocument urkunde;
  try {
    urkunde = XmlDocument.parse(inhalt);
  } on XmlException {
    throw const GpxFehler(GpxAbbruch.keinGpx);
  }
  final wurzel = urkunde.rootElement;
  if (wurzel.localName.toLowerCase() != 'gpx') {
    throw const GpxFehler(GpxAbbruch.keinGpx);
  }

  var punkte = 0;
  final spur = <Spurpunkt>[];
  for (final art in ['trkpt', 'rtept', 'wpt']) {
    for (final e in wurzel.findAllElements(art)) {
      final breite = double.tryParse(e.getAttribute('lat') ?? '');
      final laenge = double.tryParse(e.getAttribute('lon') ?? '');
      if (breite == null || laenge == null) continue;
      punkte++;
      final zeitText = e.getElement('time')?.innerText.trim();
      if (zeitText == null || zeitText.isEmpty) continue;
      final zeit = DateTime.tryParse(zeitText);
      if (zeit == null) continue;
      spur.add((zeit: zeit.toUtc(), breite: breite, laenge: laenge));
    }
  }

  if (punkte == 0) throw const GpxFehler(GpxAbbruch.leer);
  if (spur.isEmpty) throw const GpxFehler(GpxAbbruch.ohneZeit);

  spur.sort((a, b) => a.zeit.compareTo(b.zeit));
  return spur;
}

/// Wie weit zwei aufeinanderfolgende Punkte auseinanderliegen dürfen,
/// damit dazwischen noch gerechnet wird.
///
/// Eine halbe Stunde. Bei einer längeren Lücke stand das Gerät entweder
/// still oder hatte keinen Empfang – dazwischen zu rechnen hiesse, eine
/// Bewegung zu erfinden, die niemand aufgezeichnet hat.
const Duration gpxHoechsteLuecke = Duration(minutes: 30);

/// Wie weit vor dem ersten und nach dem letzten Punkt noch zugeordnet
/// wird.
///
/// Fünf Minuten: Das Foto vom Start, bevor die Uhr des Empfängers lief.
const Duration gpxRandtoleranz = Duration(minutes: 5);

/// Wo jemand zur Zeit [zeit] war – `null`, wenn die Spur es nicht hergibt.
///
/// Zwischen zwei Punkten wird linear gerechnet. Das ist eine Annahme,
/// aber die einzige, die eine Aufzeichnung überhaupt zulässt – und über
/// eine halbe Stunde hinaus wird sie nicht gemacht.
({double breite, double laenge})? ortZurZeit(
  List<Spurpunkt> spur,
  DateTime zeit, {
  Duration hoechsteLuecke = gpxHoechsteLuecke,
  Duration randtoleranz = gpxRandtoleranz,
}) {
  if (spur.isEmpty) return null;
  final z = zeit.toUtc();

  if (z.isBefore(spur.first.zeit)) {
    return spur.first.zeit.difference(z) <= randtoleranz
        ? (breite: spur.first.breite, laenge: spur.first.laenge)
        : null;
  }
  if (z.isAfter(spur.last.zeit)) {
    return z.difference(spur.last.zeit) <= randtoleranz
        ? (breite: spur.last.breite, laenge: spur.last.laenge)
        : null;
  }

  // Binäre Suche nach dem letzten Punkt, der nicht nach [z] liegt.
  var links = 0;
  var rechts = spur.length - 1;
  while (links < rechts) {
    final mitte = (links + rechts + 1) ~/ 2;
    if (spur[mitte].zeit.isAfter(z)) {
      rechts = mitte - 1;
    } else {
      links = mitte;
    }
  }
  final vor = spur[links];
  if (vor.zeit == z || links == spur.length - 1) {
    return (breite: vor.breite, laenge: vor.laenge);
  }
  final nach = spur[links + 1];
  final luecke = nach.zeit.difference(vor.zeit);
  if (luecke > hoechsteLuecke) return null;
  if (luecke.inMilliseconds == 0) {
    return (breite: vor.breite, laenge: vor.laenge);
  }
  final anteil =
      z.difference(vor.zeit).inMilliseconds / luecke.inMilliseconds;
  return (
    breite: vor.breite + (nach.breite - vor.breite) * anteil,
    laenge: vor.laenge + (nach.laenge - vor.laenge) * anteil,
  );
}

/// Die Schritte, in denen nach dem Zeitversatz gesucht wird.
///
/// Halbe Stunden von −14 bis +14: Alle Zeitzonen der Welt sind ganze oder
/// halbe Stunden von UTC entfernt (die drei Viertelstunden-Zonen –
/// Nepal, Chatham – fallen durch und lassen sich von Hand einstellen).
List<Duration> gpxVersatzkandidaten() => [
      for (var m = -14 * 60; m <= 14 * 60; m += 30) Duration(minutes: m),
    ];

/// Sucht den Zeitversatz, bei dem die meisten Aufnahmen auf die Spur
/// passen.
///
/// **Der Grund, warum es diese Funktion gibt:** EXIF schreibt die
/// Aufnahmezeit ohne Zeitzone, GPX schreibt UTC. Zwischen beiden liegt
/// ein Versatz, den niemand kennt – und er ist nicht einmal immer die
/// Zeitzone: Eine Kamera, deren Uhr seit zwei Jahren falsch geht,
/// verschiebt alles um denselben Betrag. Statt den Nutzer raten zu
/// lassen, wird ausprobiert und gezählt.
///
/// Bei Gleichstand gewinnt der kleinere Versatz – wenn zwei Erklärungen
/// gleich viele Fotos treffen, ist die harmlosere die wahrscheinlichere.
Duration besterVersatz(
  List<Spurpunkt> spur,
  Iterable<DateTime> zeiten, {
  List<Duration>? kandidaten,
  Duration hoechsteLuecke = gpxHoechsteLuecke,
  Duration randtoleranz = gpxRandtoleranz,
}) {
  final liste = zeiten.toList();
  var bester = Duration.zero;
  var meiste = -1;
  for (final versatz in kandidaten ?? gpxVersatzkandidaten()) {
    var treffer = 0;
    for (final z in liste) {
      if (ortZurZeit(spur, z.add(versatz),
              hoechsteLuecke: hoechsteLuecke, randtoleranz: randtoleranz) !=
          null) {
        treffer++;
      }
    }
    if (treffer > meiste ||
        (treffer == meiste && versatz.abs() < bester.abs())) {
      meiste = treffer;
      bester = versatz;
    }
  }
  return bester;
}

/// Eine geplante Zuordnung – Aufnahme zu Koordinate.
typedef Verortung = ({String assetId, double breite, double laenge});

/// Ordnet allen [aufnahmen] eine Koordinate zu, soweit die Spur es
/// hergibt.
List<Verortung> verorteAusSpur(
  List<Spurpunkt> spur,
  Iterable<({String id, DateTime zeit})> aufnahmen, {
  Duration versatz = Duration.zero,
  Duration hoechsteLuecke = gpxHoechsteLuecke,
  Duration randtoleranz = gpxRandtoleranz,
}) =>
    [
      for (final a in aufnahmen)
        if (ortZurZeit(spur, a.zeit.add(versatz),
                hoechsteLuecke: hoechsteLuecke,
                randtoleranz: randtoleranz)
            case final ort?)
          (assetId: a.id, breite: ort.breite, laenge: ort.laenge),
    ];
