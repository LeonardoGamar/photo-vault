import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../db/database.dart';
import '../services/storage_paths.dart';
import '../theme/app_spacing.dart';
import 'asset_thumbnail_tile.dart';
import 'timeline_grid_layout.dart';
import 'timeline_scrubber.dart';

const double _scrubberWidth = 64.0;

/// Rendert eine Liste von Assets gruppiert nach Monat (Überschrift + darunter
/// ein Foto-Grid) – gemeinsame Darstellung für die Timeline und die
/// Jahres-Detailansicht (Kalender). Gruppierung passiert client-seitig auf
/// der übergebenen (bereits absteigend nach Datum sortierten) Liste.
///
/// Rechts eingeblendet: ein [TimelineScrubber] zum schnellen Springen zu
/// einem Jahr/Monat (nur wenn es mindestens 2 Monatsgruppen gibt).
class MonthGroupedAssetGrid extends StatefulWidget {
  final List<AssetData> assets;
  final StoragePaths paths;
  final void Function(AssetData asset) onTap;

  /// Startet/erweitert die Mehrfachauswahl per langem Druck (siehe
  /// SelectionActionBar). Ohne diesen Callback verhält sich das Grid wie
  /// zuvor (keine Auswahl möglich).
  final void Function(AssetData asset)? onLongPress;

  /// Wird aufgerufen, wenn auf die Monatsüberschrift getippt wird – der
  /// Aufrufer entscheidet (siehe [_MonthGroupedAssetGridState]'s Nutzer),
  /// ob das die komplette Monatsgruppe zur Auswahl hinzufügt oder wieder
  /// entfernt. Ohne diesen Callback ist die Überschrift nicht antippbar.
  final void Function(List<AssetData> groupAssets)? onHeaderTap;

  /// IDs der aktuell ausgewählten Fotos – rendert das Auswahl-Overlay auf
  /// den entsprechenden Kacheln (siehe [AssetThumbnailTile.selected]) sowie
  /// das Auswahl-Symbol vor der Monatsüberschrift.
  final Set<String>? selectedIds;

  /// Springt einmalig zu diesem Foto und hebt es kurz hervor (siehe
  /// "Foto in der Timeline anzeigen" im Kontextmenü der Vollbildansicht).
  /// Wird pro neuem Wert nur einmal verarbeitet, auch wenn der übergeordnete
  /// Widget-Baum zwischenzeitlich mehrfach neu baut.
  final String? highlightAssetId;

  /// Wird aufgerufen, sobald nahe genug ans Ende des aktuell geladenen
  /// Ausschnitts gescrollt wurde – der Aufrufer entscheidet, ob und wie viel
  /// mehr nachgeladen wird (siehe TimelineScreens wachsendes Ladefenster).
  /// Ohne diesen Callback (z.B. wenn [assets] ohnehin schon die komplette
  /// Bibliothek enthält) passiert nichts Zusätzliches.
  final VoidCallback? onScrollNearEnd;

  const MonthGroupedAssetGrid({
    super.key,
    required this.assets,
    required this.paths,
    required this.onTap,
    this.onLongPress,
    this.onHeaderTap,
    this.selectedIds,
    this.highlightAssetId,
    this.onScrollNearEnd,
  });

  @override
  State<MonthGroupedAssetGrid> createState() => _MonthGroupedAssetGridState();
}

class _MonthGroupedAssetGridState extends State<MonthGroupedAssetGrid> {
  final _scrollController = ScrollController();
  String? _handledHighlightId;
  String? _flashingAssetId;

  // Von build() bei jedem Durchlauf aktuell gehalten (siehe LayoutBuilder
  // unten) – [_scrollToAndFlash] läuft außerhalb von build() (per
  // Post-Frame-Callback) und braucht dieselben Werte, die das Grid für sein
  // eigenes Layout verwendet, statt sie separat (und für große Bibliotheken
  // spürbar teuer) ein zweites Mal aus der kompletten Asset-Liste
  // herzuleiten.
  double? _lastGridWidth;
  Map<int, List<AssetData>>? _lastGroups;
  List<int>? _lastOrderedKeys;

  @override
  void initState() {
    super.initState();
    _maybeHandleHighlight();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void didUpdateWidget(covariant MonthGroupedAssetGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeHandleHighlight();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Löst [MonthGroupedAssetGrid.onScrollNearEnd] aus, sobald weniger als
  /// eine Bildschirmhöhe (grob geschätzt über einen festen Pixel-Puffer) bis
  /// zum Ende des aktuell geladenen Ausschnitts übrig ist. Der Aufrufer
  /// (TimelineScreen) muss selbst dafür sorgen, dass ein mehrfaches Auslösen
  /// (z.B. bei mehreren Scroll-Events kurz hintereinander) harmlos ist –
  /// hier keine eigene Drosselung, um die Logik nicht doppelt zu halten.
  void _handleScroll() {
    final onNearEnd = widget.onScrollNearEnd;
    if (onNearEnd == null || !_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 2000) {
      onNearEnd();
    }
  }

  void _maybeHandleHighlight() {
    final targetId = widget.highlightAssetId;
    if (targetId == null || targetId == _handledHighlightId) return;
    _handledHighlightId = targetId;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToAndFlash(targetId));
  }

  void _scrollToAndFlash(String assetId) {
    final gridWidth = _lastGridWidth;
    final groups = _lastGroups;
    final orderedKeys = _lastOrderedKeys;
    if (!mounted || !_scrollController.hasClients || gridWidth == null || groups == null || orderedKeys == null) {
      return;
    }
    final offset = timelineOffsetForAsset(orderedKeys, groups, gridWidth, assetId);
    if (offset == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTexte.of(context).rasterFotoNichtGefunden)),
      );
      return;
    }
    final clamped = offset.clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.animateTo(clamped, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    setState(() => _flashingAssetId = assetId);
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted && _flashingAssetId == assetId) setState(() => _flashingAssetId = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Günstiger Integer-Schlüssel (Jahr*100+Monat) statt eines pro Foto neu
    // formatierten Datums-Strings – bei jeder DB-Änderung liefert
    // `watchTimeline()` die komplette Liste neu, wodurch diese Gruppierung
    // bei großen Bibliotheken sonst unnötig oft (kostspielig) neu läuft. Der
    // menschenlesbare Monatsname wird weiterhin nur einmal pro Gruppe für
    // die Überschrift formatiert, nicht pro Foto.
    final groups = <int, List<AssetData>>{};
    for (final a in widget.assets) {
      final key = a.fileCreatedAt.year * 100 + a.fileCreatedAt.month;
      groups.putIfAbsent(key, () => []).add(a);
    }
    final orderedKeys = groups.keys.toList()..sort((a, b) => b.compareTo(a));
    final showScrubber = orderedKeys.length > 1;
    _lastGroups = groups;
    _lastOrderedKeys = orderedKeys;

    return LayoutBuilder(
      builder: (context, constraints) {
        final gridWidth = showScrubber ? constraints.maxWidth - _scrubberWidth : constraints.maxWidth;
        _lastGridWidth = gridWidth;
        return Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: gridWidth,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  for (final key in orderedKeys) ...[
                    SliverToBoxAdapter(
                      child: _MonthHeader(
                        label: DateFormat.yMMMM(
                                Localizations.localeOf(context).toString())
                            .format(groups[key]!.first.fileCreatedAt),
                        groupAssets: groups[key]!,
                        selectedIds: widget.selectedIds,
                        onTap: widget.onHeaderTap,
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 160,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final asset = groups[key]![index];
                            final tile = AssetThumbnailTile(
                              asset: asset,
                              paths: widget.paths,
                              selected: widget.selectedIds?.contains(asset.id) ?? false,
                              onTap: () => widget.onTap(asset),
                              onLongPress: widget.onLongPress == null ? null : () => widget.onLongPress!(asset),
                            );
                            return asset.id == _flashingAssetId ? _FlashHighlight(child: tile) : tile;
                          },
                          childCount: groups[key]!.length,
                        ),
                      ),
                    ),
                  ],
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
            ),
            if (showScrubber)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: _scrubberWidth,
                child: TimelineScrubber(
                  orderedKeys: orderedKeys,
                  groups: groups,
                  controller: _scrollController,
                  gridWidth: gridWidth,
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Monatsüberschrift der Timeline/Jahresansicht. Antippbar (wenn [onTap]
/// gesetzt ist): fügt alle Fotos/Videos dieses Monats auf einen Schlag zur
/// Mehrfachauswahl hinzu bzw. entfernt sie wieder, falls schon alle
/// ausgewählt sind ("Auswahl umschalten" statt reinem "immer hinzufügen" –
/// so lässt sich ein versehentlich ausgewählter Monat genauso einfach per
/// erneutem Antippen wieder abwählen).
class _MonthHeader extends StatelessWidget {
  final String label;
  final List<AssetData> groupAssets;
  final Set<String>? selectedIds;
  final void Function(List<AssetData> groupAssets)? onTap;

  const _MonthHeader({
    required this.label,
    required this.groupAssets,
    required this.selectedIds,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ids = selectedIds;
    final allSelected = ids != null && ids.isNotEmpty && groupAssets.every((a) => ids.contains(a.id));

    return InkWell(
      onTap: onTap == null ? null : () => onTap!(groupAssets),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.sm),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onTap != null) ...[
              Icon(
                allSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 18,
                color: allSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
              ),
              const SizedBox(width: 8),
            ],
            Text(label, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

/// Kurz ausklingender, farbiger Rahmen um eine Kachel – zeigt "hier ist das
/// gesuchte Foto", nachdem "Foto in der Timeline anzeigen" dorthin
/// gescrollt hat.
class _FlashHighlight extends StatelessWidget {
  final Widget child;
  const _FlashHighlight({required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 0.0),
      duration: const Duration(milliseconds: 1600),
      curve: Curves.easeOut,
      builder: (context, value, child) => Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.tealAccent.withValues(alpha: value), width: 3),
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
        child: child,
      ),
      child: child,
    );
  }
}
