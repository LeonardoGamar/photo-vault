import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../db/database.dart';
import '../state/library_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/month_grouped_asset_grid.dart';
import '../widgets/pin_dialogs.dart';
import '../widgets/selection_action_bar.dart';
import 'asset_viewer_screen.dart';
import 'import_progress_sheet.dart';

class TimelineScreen extends StatefulWidget {
  final LibraryState library;

  /// Siehe [MonthGroupedAssetGrid.highlightAssetId].
  final String? highlightAssetId;

  const TimelineScreen({super.key, required this.library, this.highlightAssetId});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  // Wachsendes Ladefenster statt auf einen Schlag die komplette Bibliothek zu
  // laden: `watchTimeline(limit: _windowSize)` bleibt dank
  // `idx_assets_trashed_locked_created` auch für ein großes Fenster ein
  // günstiger Index-Walk statt eines vollen Tabellen-Scans (SQLite kann die
  // ersten N Zeilen in Sortierreihenfolge direkt aus dem Index lesen). Wird
  // beim Scrollen nahe ans Ende erweitert (siehe [_maybeGrowWindow]) und bei
  // Bedarf vorab für "Foto in der Timeline anzeigen" (siehe
  // [_resolveHighlight]).
  static const _initialWindowSize = 600;
  static const _windowGrowth = 600;
  int _windowSize = _initialWindowSize;
  bool _resolvingHighlight = false;

  final Set<String> _selected = {};

  @override
  void initState() {
    super.initState();
    final id = widget.highlightAssetId;
    if (id != null) _resolveHighlight(id);
  }

  @override
  void didUpdateWidget(covariant TimelineScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final id = widget.highlightAssetId;
    if (id != null && id != oldWidget.highlightAssetId) _resolveHighlight(id);
  }

  /// Öffnet das Ladefenster VORAB weit genug, um das Ziel-Foto zu enthalten
  /// (auch wenn es weit "unten" in einer sehr großen Bibliothek liegt) –
  /// muss abgeschlossen sein, BEVOR [MonthGroupedAssetGrid] mit gesetztem
  /// `highlightAssetId` baut, sonst würde dessen eigene (nur einmal pro ID
  /// ausgeführte) Scroll-Logik das Foto in einem noch zu schmalen Ausschnitt
  /// nicht finden und fälschlich "nicht gefunden" melden.
  Future<void> _resolveHighlight(String assetId) async {
    setState(() => _resolvingHighlight = true);
    final rank = await widget.library.db.timelineRankOfAsset(assetId);
    if (!mounted) return;
    setState(() {
      if (rank != null) _windowSize = math.max(_windowSize, rank + 1 + _windowGrowth);
      _resolvingHighlight = false;
    });
  }

  /// Nur erweitern, wenn das Fenster tatsächlich voll ausgeschöpft ist – bei
  /// weniger geladenen Fotos als [_windowSize] ist die Bibliothek bereits
  /// vollständig geladen, es gibt nichts mehr nachzuladen.
  void _maybeGrowWindow(int loadedCount) {
    if (loadedCount < _windowSize) return;
    setState(() => _windowSize += _windowGrowth);
  }

  void _toggle(String id) => setState(() {
        if (!_selected.remove(id)) _selected.add(id);
      });

  /// Auf die Monatsüberschrift getippt: alle Fotos/Videos des Monats
  /// auswählen – oder, falls bereits alle ausgewählt sind, wieder abwählen.
  void _toggleGroup(List<AssetData> groupAssets) => setState(() {
        final allSelected = groupAssets.every((a) => _selected.contains(a.id));
        for (final a in groupAssets) {
          if (allSelected) {
            _selected.remove(a.id);
          } else {
            _selected.add(a.id);
          }
        }
      });

  /// Bei einem Serien-Titelbild (siehe StackReviewScreen) werden nur die
  /// Stapel-Mitglieder geöffnet statt der vollen Timeline-Liste – sonst
  /// ließe sich eine gestapelte Serie nie durchblättern, da alle anderen
  /// Mitglieder ja absichtlich aus der Rasteransicht ausgeblendet sind.
  Future<void> _openViewer(List<AssetData> assets, AssetData asset) async {
    final viewerAssets = (asset.isStackCover && asset.stackId != null)
        ? await widget.library.db.assetsInStack(asset.stackId!)
        : assets;
    if (!mounted) return;
    final initialIndex = viewerAssets.indexOf(asset);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AssetViewerScreen(
        assets: viewerAssets,
        initialIndex: initialIndex < 0 ? 0 : initialIndex,
        paths: widget.library.paths,
        db: widget.library.db,
        library: widget.library,
        onToggleFavorite: (a) => widget.library.db.setFavorite(a.id, !a.isFavorite),
        onDelete: (a) => widget.library.db.moveToTrash([a.id]),
        onLock: (a) async {
          if (await ensureVaultUnlocked(context, widget.library)) {
            await widget.library.lockAsset(a);
          }
        },
      ),
    ));
  }

  Future<void> _deleteSelected() async {
    final ids = _selected.toList();
    final confirmed = await confirmDialog(
      context,
      '${ids.length} Foto(s) löschen?',
      'Diese Fotos werden in den Papierkorb verschoben.',
    );
    if (!confirmed) return;
    await widget.library.db.moveToTrash(ids);
    if (mounted) setState(_selected.clear);
  }

  @override
  Widget build(BuildContext context) {
    if (_resolvingHighlight) return const Center(child: CircularProgressIndicator());
    return StreamBuilder<List<AssetData>>(
      stream: widget.library.db.watchTimeline(limit: _windowSize),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final assets = snapshot.data!;
        if (assets.isEmpty) {
          return EmptyState(
            icon: Icons.photo_outlined,
            message: 'Noch keine Fotos in der Bibliothek.',
            actionLabel: 'Fotos/Videos importieren',
            onAction: () => showImportSheet(context, widget.library),
          );
        }

        return Stack(
          children: [
            MonthGroupedAssetGrid(
              assets: assets,
              paths: widget.library.paths,
              highlightAssetId: widget.highlightAssetId,
              selectedIds: _selected,
              onLongPress: (asset) => _toggle(asset.id),
              onHeaderTap: _toggleGroup,
              onTap: (asset) => _selected.isNotEmpty ? _toggle(asset.id) : _openViewer(assets, asset),
              onScrollNearEnd: () => _maybeGrowWindow(assets.length),
            ),
            if (_selected.isNotEmpty)
              SelectionActionBar(
                count: _selected.length,
                onClear: () => setState(_selected.clear),
                onFavorite: () async {
                  await runBatchFavorite(widget.library, _selected.toList());
                  if (mounted) setState(_selected.clear);
                },
                onAddToAlbum: () async {
                  await runBatchAddToAlbumDialog(context, widget.library, _selected.toList());
                  if (mounted) setState(_selected.clear);
                },
                onTag: () async {
                  await runBatchTagDialog(context, widget.library, _selected.toList());
                  if (mounted) setState(_selected.clear);
                },
                onSetRating: () async {
                  await runBatchSetRating(context, widget.library, _selected.toList());
                  if (mounted) setState(_selected.clear);
                },
                onSetColorLabel: () async {
                  await runBatchSetColorLabel(context, widget.library, _selected.toList());
                  if (mounted) setState(_selected.clear);
                },
                onEditMetadata: () async {
                  await runBatchEditMetadataDialog(context, widget.library, _selected.toList());
                  if (mounted) setState(_selected.clear);
                },
                onExport: () async {
                  final selectedAssets = assets.where((a) => _selected.contains(a.id)).toList();
                  await runBatchExport(context, widget.library, selectedAssets);
                  if (mounted) setState(_selected.clear);
                },
                onDelete: _deleteSelected,
              ),
          ],
        );
      },
    );
  }
}
