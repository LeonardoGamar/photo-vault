import '../db/database.dart';

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

double timelineMonthGroupHeight(int itemCount, double gridWidth,
    {double kachelbreite = timelineGridMaxCrossAxisExtent}) {
  final columns = timelineColumnsForWidth(gridWidth, kachelbreite: kachelbreite);
  final rows = (itemCount / columns).ceil();
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
}) {
  var offset = 0.0;
  final columns = timelineColumnsForWidth(gridWidth, kachelbreite: kachelbreite);
  final rowHeight =
      timelineRowHeightForWidth(gridWidth, kachelbreite: kachelbreite);
  for (final key in orderedKeys) {
    final group = groups[key]!;
    final indexInGroup = group.indexWhere((a) => a.id == assetId);
    if (indexInGroup != -1) {
      final row = indexInGroup ~/ columns;
      return offset + timelineHeaderHeight + row * rowHeight;
    }
    offset += timelineMonthGroupHeight(group.length, gridWidth,
        kachelbreite: kachelbreite);
  }
  return null;
}
