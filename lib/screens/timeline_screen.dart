import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../db/database.dart';
import '../l10n/app_localizations.dart';
import '../services/asset_grouping.dart';
import '../theme/app_spacing.dart';
import '../state/library_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/asset_list_view.dart';
import '../widgets/month_grouped_asset_grid.dart';
import '../widgets/pin_dialogs.dart';
import '../widgets/rasterbedienung.dart';
import '../widgets/selection_action_bar.dart';
import 'asset_viewer_screen.dart';
import 'import_progress_sheet.dart';

class TimelineScreen extends StatefulWidget {
  final LibraryState library;

  /// Siehe [MonthGroupedAssetGrid.highlightAssetId].
  final String? highlightAssetId;

  /// Jede Änderung springt zu den neuesten Fotos – ausgelöst vom Tippen
  /// auf das Zeitleisten-Symbol in der Navigation.
  final ValueListenable<int>? nachObenSignal;

  const TimelineScreen({
    super.key,
    required this.library,
    this.highlightAssetId,
    this.nachObenSignal,
  });

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> with Rasterbedienung<TimelineScreen> {
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

  /// Was der Datenstrom zuletzt geliefert hat, plus die Spaltenzahl, die das
  /// Raster daraus gemacht hat – beides braucht [Rasterbedienung] beim
  /// Tastendruck, also ausserhalb von `build`.
  List<AssetData> _geladen = const [];
  int _spalten = 1;

  @override
  Set<String> get auswahl => _selected;

  @override
  AppDatabase get rasterDb => widget.library.db;

  @override
  List<AssetData> get rasterAssets => _geladen;

  @override
  int get rasterSpalten => _spalten;

  /// In der Listenansicht steht alles untereinander – eine Spalte, eine
  /// Gruppe. Sonst die Monatsgruppen, die das Raster auch malt.
  @override
  List<List<String>> get rasterGruppen {
    if (_alsListe) return [[for (final a in _geladen) a.id]];
    final m = monatsgruppen(_geladen);
    return [for (final k in m.schluessel) [for (final a in m.gruppen[k]!) a.id]];
  }

  @override
  void rasterOeffne(AssetData asset) => _openViewer(_geladen, asset);

  /// Raster oder Liste, und wonach die Liste gegliedert wird.
  ///
  /// Nur für diese Sitzung: In den Einstellungen abgelegt wäre es eine
  /// Datenbankspalte für eine Wahl, die man im Lauf einer Sichtung
  /// mehrfach umlegt.
  bool _alsListe = false;
  ListenGruppierung _gruppierung = ListenGruppierung.monat;

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
      AppTexte.of(context).loeschenTitel(ids.length),
      AppTexte.of(context).loeschenHinweis(ids.length),
    );
    if (!confirmed) return;
    await widget.library.db.moveToTrash(ids);
    if (mounted) setState(_selected.clear);
  }



  /// Die schmale Leiste über der Ansicht: Raster oder Liste, und – nur bei
  /// der Liste – wonach gegliedert wird.
  ///
  /// Die Gliederung erscheint erst mit der Liste, weil das Raster
  /// grundsätzlich nach Monaten gegliedert ist; ein Wahlfeld daneben, das
  /// nichts bewirkt, wäre irreführend.
  Widget _ansichtsLeiste(BuildContext context) {
    final t = AppTexte.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.xs, AppSpacing.md, 0),
      child: Row(
        children: [
          SegmentedButton<bool>(
            style: const ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            segments: [
              ButtonSegment(
                value: false,
                icon: const Icon(Icons.grid_view, size: 16),
                tooltip: t.ansichtRaster,
              ),
              ButtonSegment(
                value: true,
                icon: const Icon(Icons.view_list_outlined, size: 16),
                tooltip: t.ansichtListe,
              ),
            ],
            selected: {_alsListe},
            showSelectedIcon: false,
            onSelectionChanged: (s) => setState(() => _alsListe = s.first),
          ),
          if (_alsListe) ...[
            const SizedBox(width: AppSpacing.md),
            DropdownButton<ListenGruppierung>(
              value: _gruppierung,
              isDense: true,
              underline: const SizedBox.shrink(),
              items: [
                DropdownMenuItem(
                    value: ListenGruppierung.monat, child: Text(t.gruppeMonat)),
                DropdownMenuItem(
                    value: ListenGruppierung.kamera, child: Text(t.gruppeKamera)),
                DropdownMenuItem(
                    value: ListenGruppierung.keine, child: Text(t.gruppeKeine)),
              ],
              onChanged: (wahl) =>
                  setState(() => _gruppierung = wahl ?? ListenGruppierung.monat),
            ),
          ],
          const Spacer(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_resolvingHighlight) return const Center(child: CircularProgressIndicator());
    return StreamBuilder<List<AssetData>>(
      stream: widget.library.db.watchTimeline(limit: _windowSize),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final assets = snapshot.data!;
        _geladen = assets;
        if (assets.isEmpty) {
          return EmptyState(
            icon: Icons.photo_outlined,
            message: AppTexte.of(context).timelineLeer,
            actionLabel: AppTexte.of(context).importierenTooltip,
            onAction: () => showImportSheet(context, widget.library),
          );
        }

        return mitTastatur(
            kind: Stack(
          children: [
            Column(
              children: [
                _ansichtsLeiste(context),
                Expanded(
                  // Die Spaltenzahl steht nur hier fest, wird aber beim
                  // Tastendruck gebraucht – dort gibt es keine Constraints.
                  child: LayoutBuilder(builder: (context, constraints) {
                    _spalten = _alsListe
                        ? 1
                        : rasterSpaltenzahl(
                            constraints.maxWidth,
                            mitZeitstrahl:
                                rasterMitZeitstrahl(monatsgruppen(assets).schluessel.length),
                          );
                    return _alsListe
                        ? AssetListView(
                            assets: assets,
                            paths: widget.library.paths,
                            gruppierung: _gruppierung,
                            selectedIds: _selected,
                            highlightAssetId: widget.highlightAssetId,
                            nachObenSignal: widget.nachObenSignal,
                            onLongPress: (asset) => _toggle(asset.id),
                            onTap: rasterKlick,
                          )
                        : MonthGroupedAssetGrid(
                            assets: assets,
                            paths: widget.library.paths,
                            highlightAssetId: widget.highlightAssetId,
                            aktiveKachelId: aktiveKachel,
                            nachObenSignal: widget.nachObenSignal,
                            selectedIds: _selected,
                            onLongPress: (asset) => _toggle(asset.id),
                            onHeaderTap: _toggleGroup,
                            onTap: rasterKlick,
                            onScrollNearEnd: () => _maybeGrowWindow(assets.length),
                          );
                  }),
                ),
              ],
            ),
            if (_selected.isNotEmpty)
              SelectionActionBar(
                count: _selected.length,
                onClear: () => setState(_selected.clear),
                onCompare: vergleichsAktion(context, widget.library, _selected.toList()),
                // Nur sichtbar, wenn tatsächlich Einstellungen kopiert
                // wurden – ein Knopf, der meistens nichts tun kann, wäre
                // in einer Leiste mit neun Symbolen nur Rauschen.
                onPasteDevelop: widget.library.hatKopierteEntwicklung
                    ? () async {
                        await runBatchPasteDevelop(context, widget.library, _selected.toList());
                        if (mounted) setState(_selected.clear);
                      }
                    : null,
                onApplyPreset: () =>
                    runBatchApplyPreset(context, widget.library, _selected.toList()),
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
        ));
      },
    );
  }
}
