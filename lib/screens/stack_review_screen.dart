import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../services/embedding_similarity.dart';
import '../state/library_state.dart';
import '../theme/app_spacing.dart';
import '../widgets/asset_thumbnail_tile.dart';

/// Gruppiert Fotos, die sich sowohl visuell ähneln ALS AUCH zeitlich nah
/// beieinander aufgenommen wurden ([findBurstGroups]) – z.B. Serienbilder
/// vom Fotoapparat oder mehrere Smartphone-Aufnahmen derselben Szene kurz
/// hintereinander. Muster wie [DuplicatesScreen], aber statt "löschen"
/// fasst "Übernehmen" eine Gruppe zu einem Stapel zusammen (ein Titelbild
/// bleibt in Timeline & Co. sichtbar, siehe AppDatabase.createStack) statt
/// Fotos zu entfernen – nichts geht dabei verloren, "Serie auflösen" im
/// Info-Panel macht die Gruppierung jederzeit rückgängig.
class StackReviewScreen extends StatefulWidget {
  final LibraryState library;
  const StackReviewScreen({super.key, required this.library});

  @override
  State<StackReviewScreen> createState() => _StackReviewScreenState();
}

class _StackReviewScreenState extends State<StackReviewScreen> {
  bool _loading = true;
  String? _error;
  List<List<AssetData>> _groups = [];

  /// Gewählter Titelbild-Index je Gruppe (Index in [_groups]) – defaultmäßig
  /// das Foto mit dem höchsten Unschärfe-Score (siehe [_defaultCoverIndex]),
  /// vom Nutzer per Antippen änderbar.
  final Map<int, int> _coverIndexByGroup = {};

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
      final knownAssets = await widget.library.db.assetsByIds(embeddings.keys.toList());
      final fileCreatedAt = {for (final a in knownAssets) a.id: a.fileCreatedAt};

      // Der paarweise Vergleich läuft in einem eigenen Isolate (siehe
      // findBurstGroups), damit die UI bei größeren Bibliotheken
      // währenddessen nicht einfriert.
      final groupIdLists = await compute(
        findBurstGroups,
        BurstSearchParams(embeddings, fileCreatedAt),
      );

      final groups = <List<AssetData>>[];
      for (final idList in groupIdLists) {
        final groupAssets = await widget.library.db.assetsByIds(idList);
        if (groupAssets.length >= 2) groups.add(groupAssets);
      }

      setState(() {
        _groups = groups;
        _error = null;
        _coverIndexByGroup
          ..clear()
          ..addEntries(groups.indexed.map((e) => MapEntry(e.$1, _defaultCoverIndex(e.$2))));
      });
    } catch (e) {
      setState(() => _error = 'Suche fehlgeschlagen: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Schärfstes Foto der Gruppe (siehe blur_detection.dart) als
  /// Titelbild-Vorschlag – Fotos ohne berechneten Score gelten als am
  /// unschärfsten, damit ein tatsächlich vermessenes Foto immer Vorrang hat.
  int _defaultCoverIndex(List<AssetData> group) {
    var bestIndex = 0;
    var bestScore = group.first.sharpnessScore ?? -1;
    for (var i = 1; i < group.length; i++) {
      final score = group[i].sharpnessScore ?? -1;
      if (score > bestScore) {
        bestScore = score;
        bestIndex = i;
      }
    }
    return bestIndex;
  }

  Future<void> _applyStack(int groupIndex) async {
    final group = _groups[groupIndex];
    final coverIndex = _coverIndexByGroup[groupIndex] ?? 0;
    await widget.library.db.createStack(
      const Uuid().v4(),
      group.map((a) => a.id).toList(),
      group[coverIndex].id,
    );
    setState(() {
      _groups.removeAt(groupIndex);
      _reindexCovers();
    });
  }

  void _discardGroup(int groupIndex) => setState(() {
        _groups.removeAt(groupIndex);
        _reindexCovers();
      });

  void _reindexCovers() {
    final reindexed = <int, int>{};
    for (var i = 0; i < _groups.length; i++) {
      reindexed[i] = _coverIndexByGroup[i] ?? 0;
    }
    _coverIndexByGroup
      ..clear()
      ..addAll(reindexed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Serienbilder gruppieren')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
            child: Text(
              'Fotos, die sich ähneln UND innerhalb weniger Sekunden aufgenommen wurden, werden hier '
              'als Serie vorgeschlagen. "Übernehmen" fasst eine Gruppe zu einem Stapel zusammen – nur '
              'das Titelbild bleibt danach in der Übersicht sichtbar, nichts wird gelöscht.',
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
          child: Text('Keine Serienbilder gefunden.', textAlign: TextAlign.center),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _groups.length,
      itemBuilder: (context, groupIndex) {
        final group = _groups[groupIndex];
        final coverIndex = _coverIndexByGroup[groupIndex] ?? 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Serie ${groupIndex + 1} · ${group.length} Fotos',
                        style: Theme.of(context).textTheme.titleSmall),
                  ),
                  TextButton(
                    onPressed: () => _discardGroup(groupIndex),
                    child: const Text('Verwerfen'),
                  ),
                  FilledButton(
                    onPressed: () => _applyStack(groupIndex),
                    child: const Text('Übernehmen'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: group.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final asset = group[index];
                    final isCover = index == coverIndex;
                    return SizedBox(
                      width: 140,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                border: isCover
                                    ? Border.all(color: Theme.of(context).colorScheme.primary, width: 3)
                                    : null,
                              ),
                              child: AssetThumbnailTile(
                                asset: asset,
                                paths: widget.library.paths,
                                onTap: () => setState(() => _coverIndexByGroup[groupIndex] = index),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 4,
                            top: 4,
                            child: Material(
                              color: Colors.black54,
                              shape: const CircleBorder(),
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.xs),
                                child: Icon(
                                  isCover ? Icons.star : Icons.star_border,
                                  color: isCover ? Colors.amber : Colors.white70,
                                  size: 16,
                                ),
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
