import 'dart:io';

import 'package:flutter/widgets.dart';

/// Die Obergrenze, in der ein Foto zur Anzeige dekodiert wird.
///
/// **Warum es sie geben muss.** Eine Vorschaudatei entsteht nur für
/// Formate, die Flutter selbst nicht zeichnen kann – HEIC und RAW. In
/// einer echten Bibliothek waren das 1146 von 6930 Aufnahmen; die
/// übrigen **5784 werden im Original angezeigt**, und ein Original ist
/// so gross, wie die Kamera es gemacht hat. Die grösste dort misst
/// 20383 × 4077 Punkte. Als Bitmap im Speicher sind das **317 MB** – für
/// ein Bild, das auf einen Bildschirm von vielleicht 2000 Punkten Breite
/// gezeichnet wird.
///
/// 4096 ist keine gerechnete Grenze, sondern die, die die
/// Vollbildansicht seit jeher benutzt. Sie hier zu wiederholen wäre der
/// Fehler gewesen, den die 17. Prüfrunde gefunden hat: Drei weitere
/// Stellen zeigten dieselben Dateien ohne Deckel, weil die Zahl nur an
/// einer davon stand.
const maxDekodierKante = 4096;

/// **Was hier noch offen ist: der Bildschirm.**
///
/// Seit der Umstellung tragen Vorschau, Miniatur und Export ihren
/// Farbraum bei sich – Display P3, wo die Aufnahme mehr als sRGB hergibt.
/// Gezeichnet wird davon trotzdem in sRGB: Flutter rendert sein Fenster
/// auf allen drei Plattformen in sRGB, und daran ändert kein Profil in
/// der Datei etwas.
///
/// Der Unterschied ist damit dort behoben, wo die Datei weitergegeben
/// wird (Export, XMP-Beilage, fremde Programme), und bleibt dort offen,
/// wo sie angesehen wird. Das ist die kleinere Hälfte, aber es ist die
/// sichtbare – und sie kostet, anders als diese Umstellung, eine
/// Auseinandersetzung mit dem Fensterfarbraum aller drei Plattformen.

/// Ein Bild aus [datei], das höchstens [kante] Punkte je Seite belegt.
///
/// `fit` statt `exact`: Das Seitenverhältnis bleibt, die längere Kante
/// bestimmt. `allowUpscaling: false`, damit ein kleines Foto nicht
/// künstlich aufgeblasen wird – das kostete Speicher, ohne einen Punkt
/// mehr zu zeigen.
ImageProvider begrenztesBild(File datei, {int kante = maxDekodierKante}) =>
    ResizeImage(
      FileImage(datei),
      width: kante,
      height: kante,
      policy: ResizeImagePolicy.fit,
      allowUpscaling: false,
    );

/// Auf welche Stufen die Zielbreite eines Vorschaubildes gerundet wird.
///
/// **Warum überhaupt gerundet wird.** Ein Raster mit `maxCrossAxisExtent`
/// teilt den vorhandenen Platz gleichmässig auf – die Kachelbreite ist
/// damit eine Zahl, die sich mit **jedem** Punkt Fensterbreite ändert.
/// Aus `cacheWidth` wird so bei jedem Zwischenschritt eines Ziehens am
/// Fenster ein anderer Schlüssel im Bildspeicher: Jede sichtbare Kachel
/// wird neu dekodiert, und der Speicher füllt sich mit fast gleichen
/// Fassungen desselben Bildes.
///
/// Gemessen an einem Vorschaubild von 400 × 300 Punkten:
///
/// ```
/// ein Dekodiervorgang auf 148 Punkte      0,68 ms, 65.712 Bytes
/// Fensterbreiten 1000..1400 Punkte    ->  21 verschiedene Zielbreiten
/// dieselben, auf 32 gerundet          ->   1
/// ```
///
/// Bei fünfzig sichtbaren Kacheln sind das 21 × 50 × 0,68 ms ≈ 0,7
/// Sekunden Dekodierarbeit für ein einziges Ziehen am Fensterrand – und
/// einundzwanzig Einträge je Foto in einem Speicher, der insgesamt 100 MB
/// fasst.
const int dekodierstufe = 32;

/// Die Zielbreite in Bildpunkten für etwas, das [punkte] Punkte breit
/// angezeigt wird.
///
/// **Aufgerundet, nie abgerundet.** Eine Stufe zu klein hiesse, ein Bild
/// hochskaliert anzuzeigen – sichtbar unscharf. Der Preis der Rundung ist
/// höchstens eine Stufe zu viel an Pixeln.
int dekodierbreite(double punkte, double pixelverhaeltnis) {
  if (!punkte.isFinite || punkte <= 0) return dekodierstufe;
  final roh = punkte * pixelverhaeltnis;
  return (roh / dekodierstufe).ceil() * dekodierstufe;
}

/// Die Formate, die Flutter selbst dekodiert.
///
/// Gebraucht dort, wo eine **beliebige** Datei aus der Bibliothek
/// angezeigt werden soll und nicht feststeht, ob es überhaupt ein Bild
/// ist – die Integritätsprüfung etwa hält eine verwaiste Datei in den
/// Händen und kennt nur ihren Pfad. HEIC und RAW sind nicht dabei: Dort
/// bliebe ein leeres Feld stehen, und ein leeres Feld sagt weniger als
/// kein Feld.
const flutterDekodierbareEndungen = [
  '.jpg',
  '.jpeg',
  '.png',
  '.webp',
  '.gif',
  '.bmp',
];

/// Ob Flutter diese Datei nach ihrer Endung anzeigen kann.
bool flutterKannAnzeigen(String pfad) {
  final punkt = pfad.lastIndexOf('.');
  if (punkt < 0) return false;
  return flutterDekodierbareEndungen.contains(pfad.substring(punkt).toLowerCase());
}

/// Vergisst alle zwischengespeicherten Bilder.
///
/// **Wozu.** Flutter merkt sich dekodierte Bilder unter einem Schlüssel
/// aus Datei und Zielgrösse. Wer ein Foto **an Ort und Stelle**
/// überschreibt – Bearbeiten speichert ein gedrehtes JPEG unter genau
/// demselben Pfad, und Vorschau und Vorschaubild werden ebenso ersetzt –,
/// ändert die Datei, nicht den Schlüssel. Danach zeigen Vollbild,
/// Zeitleiste und jede Kachel weiter das alte Bild, bis die App neu
/// startet. Gemeldet als „Vorschau nach dem Speichern nicht aktualisiert".
///
/// **Warum alles und nicht gezielt.** Ein Bild liegt unter so vielen
/// Schlüsseln im Speicher, wie es Kachelgrössen gibt, unter denen es
/// gezeichnet wurde (siehe [dekodierbreite]) – und der Speicher lässt
/// sich nicht danach durchsuchen. Alles zu verwerfen kostet einmal das
/// erneute Dekodieren der sichtbaren Kacheln; einen Schlüssel zu
/// übersehen kostet ein falsches Bild, das niemand als Fehler erkennt.
///
/// `clearLiveImages` gehört dazu: Bilder, die gerade gezeichnet werden,
/// liegen in einer zweiten Liste, die `clear` nicht anfasst – ohne sie
/// bliebe ausgerechnet das Bild stehen, auf das man sieht.
///
/// Ohne laufende Zeichenmaschine passiert nichts: Aufrufer sind seit der
/// 23. Prüfrunde auch Wege ohne Oberfläche (Sperren, Aufräumen des
/// Entschlüsselungs-Zwischenspeichers), und die laufen in reinen
/// Sachtests ohne Bindung.
void vergissAlleBilder() {
  try {
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();
  } on FlutterError {
    // Keine Zeichenmaschine, also auch kein Bildspeicher.
  }
}
