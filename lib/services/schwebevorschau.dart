/// **Wenn die Maus einen Augenblick stehen bleibt.**
///
/// Ein Video und ein Live Photo sind in einer Kachelwand nicht
/// voneinander zu unterscheiden – beide sind ein Standbild mit einem
/// kleinen Abzeichen. Was darin passiert, sieht man erst, wenn man es
/// öffnet. Bleibt die Maus einen Augenblick darauf stehen, läuft es hier
/// von selbst an.
///
/// **Warum die Entscheidung hier steht und nicht in der Kachel.** Sie ist
/// reine Rechnung: aus einem Datensatz wird eine Kennung oder nichts. So
/// lässt sie sich mit Zahlen prüfen, statt einen Zeiger über ein
/// gerendertes Raster führen zu müssen – dieselbe Trennung wie bei
/// [bildreihen] und dem Zeitstrahl.
library;

import '../db/database.dart';

/// Wie lange die Maus stehen bleiben muss, bevor das Video anläuft.
///
/// Kurz genug, dass es sich nach „hinsehen" anfühlt und nicht nach
/// warten; lang genug, dass ein Zeiger, der quer über die Wand fährt,
/// keine Spur von anlaufenden Videos hinter sich herzieht. Bei 40
/// Kacheln in der Breite wären das sonst 40 Startvorgänge in einer
/// Sekunde.
const Duration schwebeVerzoegerung = Duration(milliseconds: 450);

/// Welcher Datensatz das Video zu [asset] trägt – oder `null`, wenn es
/// keines gibt.
///
/// Drei Fälle:
/// * ein Video: es selbst,
/// * ein Live Photo (Standbild mit verknüpfter Hälfte): die Hälfte,
/// * alles andere: nichts.
///
/// **Der Tresor bleibt zu.** Eine gesperrte Aufnahme liegt verschlüsselt
/// auf der Platte; sie abzuspielen hiesse, sie vorher im Klartext
/// abzulegen – und das ausgerechnet nebenbei, weil ein Zeiger
/// vorbeikam. Wer ein gesperrtes Video sehen will, öffnet es (siehe
/// `LibraryState.decryptForViewing`).
String? schwebeVideoId(AssetData asset) {
  if (asset.isLocked) return null;
  if (asset.type == 'VIDEO') return asset.id;
  if (asset.type == 'IMAGE' && asset.linkedAssetId != null) {
    return asset.linkedAssetId;
  }
  return null;
}

/// Ob die Schwebe-Vorschau eingeschaltet ist.
///
/// Als Wert für die ganze App und nicht je Bildschirm durchgereicht:
/// Die Einstellung steht in derselben Zeile, die `main.dart` ohnehin
/// beobachtet, und wird von dort gesetzt – genau wie der CARTO-Schlüssel
/// und die doppelte Kartenauflösung. So wirkt das Umlegen des Schalters
/// sofort und nicht erst beim nächsten Start.
bool get schwebevorschauAn => _an;
bool _an = true;

void setzeSchwebevorschau(bool an) => _an = an;
