import 'package:flutter/material.dart';

import '../db/database.dart';
import '../l10n/app_localizations.dart';
import '../state/library_state.dart';
import '../theme/app_spacing.dart';
import '../widgets/month_grouped_asset_grid.dart';
import '../widgets/pin_dialogs.dart';
import '../widgets/selection_action_bar.dart';
import 'asset_viewer_screen.dart';

/// Jahresübersicht: eine Kachel pro Jahr mit Titelbild (neuestes Foto des
/// Jahres) und Foto-/Videoanzahl – zum schnellen Einstieg in ein bestimmtes
/// Jahr, ohne die komplette Timeline durchscrollen zu müssen.
class CalendarScreen extends StatelessWidget {
  final LibraryState library;
  const CalendarScreen({super.key, required this.library});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<int, int>>(
      stream: library.db.watchAssetCountsByYear(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final countByYear = snapshot.data!;
        if (countByYear.isEmpty) {
          return Center(child: Text(AppTexte.of(context).kalenderLeer));
        }

        final years = countByYear.keys.toList()..sort((a, b) => b.compareTo(a));

        return GridView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 320,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.3,
          ),
          itemCount: years.length,
          itemBuilder: (context, index) {
            final year = years[index];
            return _YearCard(
              year: year,
              assetCount: countByYear[year]!,
              library: library,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => YearDetailScreen(library: library, year: year),
              )),
            );
          },
        );
      },
    );
  }
}

/// Lädt sein Titelbild (neuestes Foto des Jahres) einmalig selbst, statt es
/// von [CalendarScreen] vorgeladen zu bekommen – so muss dessen
/// Jahresübersicht nur noch die günstige Zählung (`watchAssetCountsByYear`)
/// laden, nicht mehr die komplette Bibliothek, nur um pro Jahr das neueste
/// Foto herauszusuchen.
class _YearCard extends StatefulWidget {
  final int year;
  final int assetCount;
  final LibraryState library;
  final VoidCallback onTap;

  const _YearCard({
    required this.year,
    required this.assetCount,
    required this.library,
    required this.onTap,
  });

  @override
  State<_YearCard> createState() => _YearCardState();
}

class _YearCardState extends State<_YearCard> {
  late final Future<AssetData?> _coverFuture =
      widget.library.db.newestAssetForYear(widget.year);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey.shade900,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            FutureBuilder<AssetData?>(
              future: _coverFuture,
              builder: (context, snapshot) {
                final thumbPath = snapshot.data?.thumbnailRelativePath;
                if (thumbPath == null) return const SizedBox.shrink();
                return Image.file(
                  widget.library.paths.absolute(thumbPath),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                );
              },
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                  stops: [0.35, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.year}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppTexte.of(context).kalenderAnzahlFotos(widget.assetCount),
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Alle Fotos/Videos eines einzelnen Jahres, gruppiert nach Monat – wie die
/// Timeline, nur auf ein Jahr eingeschränkt (Einstieg über [CalendarScreen]).
class YearDetailScreen extends StatefulWidget {
  final LibraryState library;
  final int year;
  const YearDetailScreen({super.key, required this.library, required this.year});

  @override
  State<YearDetailScreen> createState() => _YearDetailScreenState();
}

class _YearDetailScreenState extends State<YearDetailScreen> {
  final Set<String> _selected = {};

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

  void _openViewer(List<AssetData> assets, AssetData asset) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AssetViewerScreen(
        assets: assets,
        initialIndex: assets.indexOf(asset),
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
      AppTexte.of(context).loeschenTitel(ids.length),
      AppTexte.of(context).loeschenHinweis(ids.length),
    );
    if (!confirmed) return;
    await widget.library.db.moveToTrash(ids);
    if (mounted) setState(_selected.clear);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.year}')),
      body: StreamBuilder<List<AssetData>>(
        stream: widget.library.db.watchTimelineForYear(widget.year),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final yearAssets = snapshot.data!;
          if (yearAssets.isEmpty) {
            return Center(child: Text(AppTexte.of(context).kalenderJahrLeer));
          }
          return Stack(
            children: [
              MonthGroupedAssetGrid(
                assets: yearAssets,
                paths: widget.library.paths,
                selectedIds: _selected,
                onLongPress: (asset) => _toggle(asset.id),
                onHeaderTap: _toggleGroup,
                onTap: (asset) => _selected.isNotEmpty ? _toggle(asset.id) : _openViewer(yearAssets, asset),
              ),
              if (_selected.isNotEmpty)
                SelectionActionBar(
                  count: _selected.length,
                  onClear: () => setState(_selected.clear),

                  onPasteDevelop: widget.library.hatKopierteEntwicklung

                      ? () async {

                          await runBatchPasteDevelop(context, widget.library, _selected.toList());

                          if (mounted) setState(_selected.clear);

                        }

                      : null,
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
                    final selectedAssets = yearAssets.where((a) => _selected.contains(a.id)).toList();
                    await runBatchExport(context, widget.library, selectedAssets);
                    if (mounted) setState(_selected.clear);
                  },
                  onDelete: _deleteSelected,
                ),
            ],
          );
        },
      ),
    );
  }
}
