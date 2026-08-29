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
