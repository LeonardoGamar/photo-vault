import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../db/database.dart';
import '../services/embedding_similarity.dart';
import '../services/duplicate_selection.dart';
import '../state/library_state.dart';
import '../theme/app_spacing.dart';
import '../widgets/asset_thumbnail_tile.dart';
import '../widgets/pin_dialogs.dart';
import 'asset_viewer_screen.dart';
import 'second_library_compare_screen.dart';

/// Gruppiert Fotos, deren CLIP-Bild-Embeddings sich sehr ähnlich sind
/// (Kosinus-Ähnlichkeit über einer einstellbaren Schwelle). Das findet nicht
/// nur exakte Duplikate (die werden beim Import bereits per Prüfsumme
/// ausgeschlossen), sondern auch inhaltlich sehr ähnliche Aufnahmen, z.B.
/// mehrere Fotos derselben Szene in Serie.
class DuplicatesScreen extends StatefulWidget {
  final LibraryState library;
  const DuplicatesScreen({super.key, required this.library});

  @override
  State<DuplicatesScreen> createState() => _DuplicatesScreenState();
}

class _DuplicatesScreenState extends State<DuplicatesScreen> {
  double _threshold = 0.92;
  bool _loading = true;
  String? _error;
  List<List<AssetData>> _groups = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      if (!widget.library.clipAvailable) {
        setState(() {
          _error = 'Benötigt das CLIP-Modell (Einstellungen → KI-Modelle).';
          _groups = [];
        });
        return;
      }

      final embeddings = await widget.library.cachedEmbeddings();
      // Der paarweise Vergleich läuft in einem eigenen Isolate (siehe
      // [findDuplicateGroups]), damit die UI bei größeren Bibliotheken
      // währenddessen nicht einfriert.
      final groupIdLists = await compute(
        findDuplicateGroups,
        DuplicateSearchParams(embeddings, _threshold),
      );

      final groups = <List<AssetData>>[];
      for (final idList in groupIdLists) {
        final assets = await widget.library.db.assetsByIds(idList);
        if (assets.length >= 2) groups.add(assets);
      }

      setState(() {
        _groups = groups;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = 'Suche fehlgeschlagen: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Behält je Gruppe das beste Foto und verschiebt den Rest in den
  /// Papierkorb – erst nach Vorschau und Bestätigung. Die Regeln stehen in
  /// services/duplicate_selection.dart; Gruppen mit mehreren favorisierten
  /// oder bewerteten Fotos bleiben bewusst unangetastet.
  Future<void> _alleKopienLoeschen() async {
    final vorschau = berechneLoeschVorschau(_groups);

    if (vorschau.zuLoeschen.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(vorschau.uebersprungeneGruppen > 0
            ? 'Nichts automatisch löschbar: In allen Gruppen sind mehrere Fotos '
                'favorisiert oder bewertet – die bitte von Hand durchsehen.'
            : 'Nichts zu löschen.'),
      ));
      return;
    }

    final bestaetigt = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kopien in den Papierkorb?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${vorschau.zuLoeschen.length} Foto(s) aus '
                '${_groups.length} Gruppe(n) werden in den Papierkorb verschoben.'),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Behalten wird je Gruppe: Favorit, sonst höchste Bewertung, '
              'sonst das schärfste, sonst das mit der höchsten Auflösung.',
              style: TextStyle(fontSize: 12),
            ),
            if (vorschau.uebersprungeneGruppen > 0) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${vorschau.uebersprungeneGruppen} Gruppe(n) bleiben unangetastet, '
                'weil dort mehrere Fotos favorisiert oder bewertet sind.',
                style: const TextStyle(fontSize: 12),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Rückgängig: über den Papierkorb wiederherstellbar.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('In den Papierkorb'),
          ),
        ],
      ),
    );
    if (bestaetigt != true) return;

    await widget.library.db.moveToTrash(vorschau.zuLoeschen.map((a) => a.id).toList());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${vorschau.zuLoeschen.length} Foto(s) in den Papierkorb verschoben.'),
    ));
    await _load();
  }

  Future<void> _moveToTrash(AssetData asset, List<AssetData> group) async {
    await widget.library.db.moveToTrash([asset.id]);
    setState(() {
      group.remove(asset);
      if (group.length < 2) _groups.remove(group);
    });
  }

  Future<void> _moveToLocked(AssetData asset, List<AssetData> group) async {
    if (!await ensureVaultUnlocked(context, widget.library)) return;
    await widget.library.lockAsset(asset);
    setState(() {
      group.remove(asset);
      if (group.length < 2) _groups.remove(group);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Duplikate & ähnliche Fotos'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => SecondLibraryCompareScreen(library: widget.library),
            )),
            icon: const Icon(Icons.folder_copy_outlined),
            label: const Text('Zweite Bibliothek'),
          ),
          if (_groups.isNotEmpty)
            TextButton.icon(
              onPressed: _alleKopienLoeschen,
              icon: const Icon(Icons.auto_delete_outlined),
              label: const Text('Alle Kopien löschen'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
            child: Row(
              children: [
                const Text('Ähnlichkeit:'),
                Expanded(
                  child: Slider(
                    value: _threshold,
                    min: 0.80,
                    max: 0.99,
                    divisions: 19,
                    label: _threshold.toStringAsFixed(2),
                    onChanged: (v) => setState(() => _threshold = v),
                    onChangeEnd: (_) => _load(),
                  ),
                ),
                Text(_threshold.toStringAsFixed(2)),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              'Höhere Werte = nur sehr ähnliche Fotos werden als Gruppe erkannt. '
              'Niedrigere Werte finden mehr, aber auch weniger sichere Treffer.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          const Divider(height: 16),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Text(_error!, textAlign: TextAlign.center),
        ),
      );
    }
    if (_groups.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Text('Keine ähnlichen Fotogruppen gefunden.', textAlign: TextAlign.center),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _groups.length,
      itemBuilder: (context, groupIndex) {
        final group = _groups[groupIndex];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Gruppe ${groupIndex + 1} · ${group.length} Fotos',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: group.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final asset = group[index];
                    return SizedBox(
                      width: 140,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            child: AssetThumbnailTile(
                              asset: asset,
                              paths: widget.library.paths,
                              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => AssetViewerScreen(
                                  assets: group,
                                  initialIndex: index,
                                  paths: widget.library.paths,
                                  db: widget.library.db,
                                  library: widget.library,
                                  onToggleFavorite: (a) =>
                                      widget.library.db.setFavorite(a.id, !a.isFavorite),
                                  onDelete: (a) => _moveToTrash(a, group),
                                  onLock: (a) => _moveToLocked(a, group),
                                ),
                              )),
                            ),
                          ),
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Material(
                              color: Colors.black54,
                              shape: const CircleBorder(),
                              child: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.white, size: 18),
                                tooltip: 'In den Papierkorb verschieben',
                                onPressed: () => _moveToTrash(asset, group),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
