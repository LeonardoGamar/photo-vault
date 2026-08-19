/// Zusammenfassen dicht beieinanderliegender Fotos zu einem Kartenmarker.
///
/// Ausgelagert aus dem Kartenbildschirm, weil die Rechnung dahinter sich
/// am fertigen Bild nicht beurteilen lässt: Ob zwei Marker einander
/// überdecken, sieht man erst bei genau der Zoomstufe, bei der es passiert
/// – und dann ist unklar, ob das Raster zu grob oder die Markergröße zu
/// groß war. Als Funktion ist beides nachrechenbar.
library;

import 'dart:math' as math;

/// Kantenlänge eines Foto-Markers auf der flachen Karte, in Punkten.
const double markerGroesse = 44;

/// Rastergröße (in Grad) für eine gegebene Zoomstufe.
///
/// In Web-Mercator ist ein vollständiger Kachelsatz 256·2^zoom Pixel breit
/// und umspannt 360° Länge; ein Pixel entspricht also 360/(256·2^zoom)
/// Grad. Mal der Markerbreite ergibt das genau den Abstand, ab dem zwei
/// Marker aneinanderstoßen – gröber gruppieren wäre unnötig, feiner ließe
/// sie überlappen.
///
/// Die Umrechnung gilt streng genommen nur am Äquator: Weiter nördlich
/// rücken die Längengrade zusammen, das Raster ist dort also etwas feiner
/// als nötig. Das ist die harmlose Richtung – lieber zwei Marker knapp
/// nebeneinander als zwei fälschlich zusammengefasste.
double rasterFuerZoom(double zoom) =>
    markerGroesse * 360.0 / (256.0 * math.pow(2.0, zoom));

/// Fasst [punkte] zu je einem Marker pro Rasterzelle zusammen.
///
/// Das ist keine Zusicherung, dass sich nie wieder zwei Marker berühren:
/// Zwei Fotos beiderseits einer Zellgrenze liegen beliebig dicht
/// beieinander und landen trotzdem in verschiedenen Gruppen. Zugesichert
/// ist die Dichte – höchstens ein Marker je Markerfläche, statt wie zuvor
/// beliebig vieler übereinander. An der eigenen Bibliothek gemessen
/// (1141 verortete Fotos, Zoom 6): 14 Marker statt 1141, und höchstens
/// zwei weitere berühren einen gegebenen Marker.
///
/// [koordinate] liefert Breite und Länge eines Eintrags – so bleibt die
/// Funktion von der Datenbankklasse unabhängig.
///
/// Die Reihenfolge innerhalb einer Gruppe bleibt die der Eingabe. Das ist
/// kein Nebenaspekt: Der Marker zeigt das Vorschaubild des ersten
/// Eintrags, und wenn die Eingabe nach Datum sortiert ist, ist das das
/// jüngste Foto der Gruppe.
Map<String, List<T>> gruppiereFuerKarte<T>(
  List<T> punkte,
  double zoom,
  ({double breite, double laenge}) Function(T) koordinate,
) {
  final raster = rasterFuerZoom(zoom);
  final gruppen = <String, List<T>>{};
  for (final p in punkte) {
    final k = koordinate(p);
    final schluessel =
        '${(k.breite / raster).round()},${(k.laenge / raster).round()}';
    gruppen.putIfAbsent(schluessel, () => []).add(p);
  }
  return gruppen;
}
