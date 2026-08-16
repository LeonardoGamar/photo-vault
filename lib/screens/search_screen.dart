import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../services/clip_service.dart';
import '../services/search_filters.dart';
import '../state/library_state.dart';
import '../theme/app_spacing.dart';
import '../widgets/asset_thumbnail_tile.dart';
import '../widgets/pin_dialogs.dart';
import '../widgets/search_options_sheet.dart';
import '../widgets/selection_action_bar.dart';
import 'asset_viewer_screen.dart';

class SearchScreen extends StatefulWidget {
  final LibraryState library;
  const SearchScreen({super.key, required this.library});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _queryCtrl = TextEditingController();
  SearchFilters _filters = const SearchFilters();
  bool _loading = false;
  /// Erklärt eine ungewöhnlich lange Wartezeit – bisher nur das
  /// einmalige Laden des Bildsuche-Modells. Null, solange es nichts
  /// zu erklären gibt.
  String? _statusText;
  bool _searched = false;
  List<AssetData> _results = [];
  String? _error;
  final Set<String> _selected = {};

  void _toggleSelected(String id) => setState(() {
        if (!_selected.remove(id)) _selected.add(id);
      });

  void _openViewer(int index) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AssetViewerScreen(
        assets: _results,
        initialIndex: index,
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

  /// Fragt einen Namen ab und speichert die aktuellen Filter als
  /// "Intelligentes Album" (siehe AppDatabase.createSavedSearch) – läuft bei
  /// jedem Antippen live gegen die aktuelle Bibliothek, statt (wie ein
  /// normales Album) eine feste Foto-Liste festzuhalten.
  Future<void> _saveCurrentSearch() async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suche speichern'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
          FilledButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('Speichern')),
        ],
      ),
    );
    ctrl.dispose();
    if (name == null || name.isEmpty) return;
    await widget.library.db.createSavedSearch(const Uuid().v4(), name, _filters);
  }

  Future<void> _loadSavedSearch(SearchFilters filters) async {
    setState(() {
      _filters = filters;
      _queryCtrl.text = filters.query;
    });
    await _runSearch();
  }

  Future<void> _openSearchOptions() async {
    final result = await showModalBottomSheet<SearchFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SearchOptionsSheet(library: widget.library, initialFilters: _filters),
    );
    if (result == null || !mounted) return;
    setState(() {
      _filters = result;
      _queryCtrl.text = result.query;
    });
    await _runSearch();
  }

  Future<void> _runSearch() async {
    if (_filters.isEmpty) return;
    setState(() {
      _loading = true;
      _searched = true;
      _error = null;
    });
    try {
      final query = _filters.query.trim();
      List<AssetData> results;
      final kontextSuche = _filters.textMode == SearchTextMode.context && query.isNotEmpty;

      Float32List? queryVector;
      if (kontextSuche) {
        // Nur der Text-Encoder – der Bildteil wird für eine Suchanfrage
        // nicht gebraucht (siehe LibraryState.clipTextHalter).
        final halter = widget.library.clipTextHalter;
        if (!halter.installiert) {
          // Ohne diese Meldung fiel die Suche stillschweigend auf eine
          // Suche ohne Suchbegriff zurück und lieferte einfach die
          // neuesten Fotos – für den Nutzer nicht von einem Treffer zu
          // unterscheiden (Audit-Fund).
          setState(() => _error = 'Für die Kontext-Suche fehlt das Bildsuche-Modell. '
              'Es lässt sich in den Einstellungen unter "KI-Modelle" laden.');
          return;
        }
        // Beim ersten Mal wird ein mehrere hundert MB grosses Modell
        // geladen; das dauert spürbar und soll nicht wie eine langsame
        // Suche aussehen.
        if (!halter.istGeladen) {
          setState(() => _statusText = 'Modell für die Bildsuche wird geladen …');
        }
        queryVector = await halter.mit((c) => c.embedText(query));
        if (mounted) setState(() => _statusText = null);
      }

      if (queryVector != null) {
        final embeddings = await widget.library.cachedEmbeddings();

        // Reihenfolge ist entscheidend: ERST die übrigen Filter anwenden,
        // DANN innerhalb dieser Treffermenge nach Ähnlichkeit ranken.
        // Andersherum (Audit-Fund) entschied das bibliotheksweite Top-200
        // darüber, was der Filter überhaupt noch zu sehen bekam: Wer
        // "Sonnenuntergang" sucht und zusätzlich auf ein Album einschränkt,
        // verlor damit jeden Treffer, der es global nicht unter die besten
        // 200 geschafft hatte – auch wenn das Album nur fünf Fotos umfasst.
        // Ohne gesetzte Filter bleibt das Ergebnis dasselbe wie zuvor.
        final gefiltert = await widget.library.db.searchAssets(_filters);
        final byId = {for (final a in gefiltert) a.id: a};
        final kandidaten = <String, Float32List>{
          for (final e in embeddings.entries)
            if (byId.containsKey(e.key)) e.key: e.value,
        };
        final ranked = ClipService.rankBySimilarity(queryVector, kandidaten, topK: 200);
        // searchAssets sortiert nach Datum – hier zählt die Ähnlichkeit.
        results = [for (final e in ranked) byId[e.key]!];
      } else {
        results = await widget.library.db.searchAssets(_filters);
      }
      setState(() => _results = results);
    } catch (e) {
      setState(() => _error = 'Suche fehlgeschlagen: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _statusText = null;
        });
      }
    }
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: TextField(
            controller: _queryCtrl,
            decoration: InputDecoration(
              hintText: switch (_filters.textMode) {
                SearchTextMode.context => 'z.B. "Sonnenuntergang am Meer", "Hund im Schnee" …',
                SearchTextMode.filename => 'Dateiname …',
                SearchTextMode.description => 'Beschreibung …',
                SearchTextMode.ocr => 'Text im Foto …',
                SearchTextMode.caption => 'z.B. "dog", "sunset" (Englisch) …',
              },
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_filters.isEmpty)
                    IconButton(
                      icon: const Icon(Icons.bookmark_add_outlined),
                      tooltip: 'Suche speichern',
                      onPressed: _saveCurrentSearch,
                    ),
                  IconButton(
                    icon: Badge(isLabelVisible: !_filters.isEmpty, child: const Icon(Icons.tune)),
                    tooltip: 'Suchoptionen',
                    onPressed: _openSearchOptions,
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    tooltip: 'Suchen',
                    onPressed: _loading ? null : _runSearch,
                  ),
                ],
              ),
            ),
            onChanged: (v) => setState(() => _filters = _filters.copyWith(query: v)),
            onSubmitted: (_) => _runSearch(),
          ),
        ),
        StreamBuilder<List<SavedSearchData>>(
          stream: widget.library.db.watchSavedSearches(),
          builder: (context, snapshot) {
            final saved = snapshot.data ?? [];
            if (saved.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(left: AppSpacing.lg, right: AppSpacing.lg, bottom: AppSpacing.md),
              child: SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: saved.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final entry = saved[index];
                    return InputChip(
                      avatar: const Icon(Icons.bookmark, size: 18),
                      label: Text(entry.name),
                      onPressed: () => _loadSavedSearch(widget.library.db.decodeSavedSearchFilters(entry.filtersJson)),
                      onDeleted: () => widget.library.db.deleteSavedSearch(entry.id),
                    );
                  },
                ),
              ),
            );
          },
        ),
        if (_loading) const LinearProgressIndicator(),
        if (_statusText != null)
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            child: Text(
              _statusText!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        if (_error != null) Padding(padding: const EdgeInsets.all(AppSpacing.sm), child: Text(_error!)),
        Expanded(
          child: !_searched
              ? const Center(child: Text('Gib einen Suchbegriff ein oder wähle Suchoptionen.'))
              : _results.isEmpty && !_loading
                  ? const Center(child: Text('Keine Treffer.'))
                  : Stack(
                      children: [
                        GridView.builder(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 160,
                            mainAxisSpacing: 4,
                            crossAxisSpacing: 4,
                          ),
                          itemCount: _results.length,
                          itemBuilder: (context, index) {
                            final asset = _results[index];
                            return AssetThumbnailTile(
                              asset: asset,
                              paths: widget.library.paths,
                              selected: _selected.contains(asset.id),
                              onLongPress: () => _toggleSelected(asset.id),
                              onTap: () => _selected.isNotEmpty ? _toggleSelected(asset.id) : _openViewer(index),
                            );
                          },
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
                              final selectedAssets = _results.where((a) => _selected.contains(a.id)).toList();
                              await runBatchExport(context, widget.library, selectedAssets);
                              if (mounted) setState(_selected.clear);
                            },
                            onDelete: _deleteSelected,
                          ),
                      ],
                    ),
        ),
      ],
    );
  }
}
