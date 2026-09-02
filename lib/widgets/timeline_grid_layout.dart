import '../db/database.dart';
import '../services/bildreihen.dart';
import '../services/rasterstufen.dart';

export '../services/bildreihen.dart'
    show Bildreihe, Bildplatz, reihenGesamthoehe, seitenverhaeltnisVorgabe;
export '../services/rasterstufen.dart';

/// Geschätzte Maße des von [MonthGroupedAssetGrid] erzeugten Scroll-Inhalts
/// (Monats-Überschrift, Grid-Kachelgröße/-abstände) – gemeinsam von
/// [TimelineScrubber] (Sprung zu einem Monat) und [MonthGroupedAssetGrid]
/// selbst (Sprung zu einem bestimmten Foto, siehe "Foto in der Timeline
/// anzeigen") genutzt, damit beide von denselben Annahmen ausgehen statt die
/// Formel zweimal leicht unterschiedlich zu pflegen. Muss nicht pixelgenau
/// sein (das Ziel wird nach dem Scrollen ohnehin sichtbar), soll aber grob
/// genug stimmen, damit sich Scrubber und Sprung-Funktion nicht "falsch
/// anfühlen".
///
/// **Bei den bündigen Reihen ist es keine Schätzung mehr.** Dort steht die
/// Anordnung als Rechnung in `bildreihen.dart`, und dieselbe Rechnung
/// liefert dem Zeitstrahl die Höhe. Was das Raster zeichnet und was der
/// Zeitstrahl annimmt, kann dann gar nicht mehr auseinanderlaufen.
const double timelineHeaderHeight = 64.0;
const double timelineTrailingHeight = 40.0;
const double timelineGridMaxCrossAxisExtent = 160.0;
const double timelineGridSpacing = 4.0;
const double timelineGridHorizontalPadding = 24.0; // 12px links + rechts (SliverPadding)

int timelineColumnsForWidth(double gridWidth,
    {double kachelbreite = timelineGridMaxCrossAxisExtent}) {
  final availableWidth = gridWidth - timelineGridHorizontalPadding;
  final count = (availableWidth / (kachelbreite + timelineGridSpacing)).ceil();
  return count < 1 ? 1 : count;
}

double timelineRowHeightForWidth(double gridWidth,
    {double kachelbreite = timelineGridMaxCrossAxisExtent}) {
  final availableWidth = gridWidth - timelineGridHorizontalPadding;
  final columns = timelineColumnsForWidth(gridWidth, kachelbreite: kachelbreite);
  final usable = availableWidth - timelineGridSpacing * (columns - 1);
  final tileExtent = usable / columns;
  return tileExtent + timelineGridSpacing;
}

/// Das Seitenverhältnis (Breite ÷ Höhe) einer Aufnahme.
///
/// Die Masse liegen in der Datenbank und sind bereits nach der
/// EXIF-Ausrichtung gedreht – an der echten Bibliothek gegengeprüft: 27 %
/// Hochformat, was ohne Drehung nicht herauskäme. Fehlen sie (2 von 8098),
/// gilt das Kleinbildformat.
double seitenverhaeltnisVon(AssetData a) {
  final b = a.widthPx;
  final h = a.heightPx;
  if (b == null || h == null || b <= 0 || h <= 0) {
    return seitenverhaeltnisVorgabe;
  }
  return b / h;
}

/// Die bündigen Reihen einer Monatsgruppe.
///
/// [kachelbreite] – die eingestellte Kachelstufe – wirkt hier als
/// **Zielhöhe** der Reihen. So bleibt der vorhandene Zoom sinnvoll, statt
/// dass die neue Form einen zweiten Regler braucht.
List<Bildreihe> zeitleisteReihen(List<AssetData> gruppe, double gridWidth,
    {double kachelbreite = timelineGridMaxCrossAxisExtent}) {
  return bildreihen(
    seitenverhaeltnisse: [for (final a in gruppe) seitenverhaeltnisVon(a)],
    breite: gridWidth - timelineGridHorizontalPadding,
    zielhoehe: kachelbreite,
    abstand: timelineGridSpacing,
  );
}

double timelineMonthGroupHeight(
  List<AssetData> gruppe,
  double gridWidth, {
  double kachelbreite = timelineGridMaxCrossAxisExtent,
  Zeitleistenform form = zeitleisteFormVorgabe,
}) {
  if (form == Zeitleistenform.reihen) {
    final reihen =
        zeitleisteReihen(gruppe, gridWidth, kachelbreite: kachelbreite);
    return timelineHeaderHeight +
        reihenGesamthoehe(reihen, timelineGridSpacing);
  }
  final columns = timelineColumnsForWidth(gridWidth, kachelbreite: kachelbreite);
  final rows = (gruppe.length / columns).ceil();
  return timelineHeaderHeight +
      rows * timelineRowHeightForWidth(gridWidth, kachelbreite: kachelbreite);
}

/// Geschätzter Scroll-Offset, um [assetId] an den oberen Rand der Ansicht zu
/// bringen (Beginn der Zeile, die es enthält) – oder `null`, wenn es in
/// keiner der übergebenen Gruppen vorkommt.
double? timelineOffsetForAsset(
  List<int> orderedKeys,
  Map<int, List<AssetData>> groups,
  double gridWidth,
  String assetId, {
  double kachelbreite = timelineGridMaxCrossAxisExtent,
  Zeitleistenform form = zeitleisteFormVorgabe,
}) {
  var offset = 0.0;
  for (final key in orderedKeys) {
    final group = groups[key]!;
    final indexInGroup = group.indexWhere((a) => a.id == assetId);
    if (indexInGroup != -1) {
      return offset +
          timelineHeaderHeight +
          _abstandBisZeile(group, indexInGroup, gridWidth, kachelbreite, form);
    }
    offset += timelineMonthGroupHeight(group, gridWidth,
        kachelbreite: kachelbreite, form: form);
  }
  return null;
}

/// Wie weit die Zeile, in der [indexInGroup] steht, unterhalb der
/// Monatsüberschrift beginnt.
double _abstandBisZeile(List<AssetData> gruppe, int indexInGroup,
    double gridWidth, double kachelbreite, Zeitleistenform form) {
  if (form == Zeitleistenform.reihen) {
    final reihen =
        zeitleisteReihen(gruppe, gridWidth, kachelbreite: kachelbreite);
    var oben = 0.0;
    for (final r in reihen) {
      if (indexInGroup <= r.letzterIndex) return oben;
      oben += r.hoehe + timelineGridSpacing;
    }
    return oben;
  }
  final columns = timelineColumnsForWidth(gridWidth, kachelbreite: kachelbreite);
  final zeile = indexInGroup ~/ columns;
  return zeile *
      timelineRowHeightForWidth(gridWidth, kachelbreite: kachelbreite);
}
