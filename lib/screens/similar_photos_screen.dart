import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';

import '../db/database.dart';
import '../services/clip_service.dart';
import '../state/library_state.dart';
import '../theme/app_spacing.dart';
import '../widgets/asset_thumbnail_tile.dart';
import '../widgets/pin_dialogs.dart';
import 'asset_viewer_screen.dart';

typedef _RankArgs = ({Float32List query, Map<String, Float32List> candidates, int topK});

/// Läuft über `compute()` in einem Hintergrund-Isolate: der brute-force
/// Kosinus-Vergleich gegen alle gespeicherten Embeddings (O(N×512)
/// Multiplikationen plus eine vollständige Sortierung) ist bei mehreren
/// zehntausend Fotos spürbar – ohne Auslagerung friert das Öffnen von
/// "Ähnliche Fotos" die UI kurz ein. Gibt Tupel statt `MapEntry` zurück, da
/// Records nachweislich (siehe decodeAndResizeThumbnail in
/// import_service.dart) sicher über die Isolate-Grenze übertragen werden.
List<(String, double)> _rankBySimilarityIsolate(_RankArgs args) {
  final ranked = ClipService.rankBySimilarity(args.query, args.candidates, topK: args.topK);
  return [for (final entry in ranked) (entry.key, entry.value)];
}

/// Zeigt Fotos, die dem übergebenen Ausgangsfoto laut CLIP-Bild-Embedding
/// am ähnlichsten sind (Kosinus-Ähnlichkeit, brute-force über alle
/// gespeicherten Embeddings) – aufgerufen über "Ähnliche Bilder anzeigen"
/// im Kontextmenü der Vollbildansicht. Nutzt dieselbe Rangfolge-Logik wie
/// die KI-Bildsuche und die Duplikatsuche, nur mit einem Bild statt einem
/// Text als Anfrage.
class SimilarPhotosScreen extends StatefulWidget {
  final LibraryState library;
  final AssetData sourceAsset;

  const SimilarPhotosScreen({super.key, required this.library, required this.sourceAsset});

  @override
  State<SimilarPhotosScreen> createState() => _SimilarPhotosScreenState();
}

class _SimilarPhotosScreenState extends State<SimilarPhotosScreen> {
  static const _maxResults = 60;

  late final Future<List<AssetData>> _resultsFuture = _computeSimilar();

  Future<List<AssetData>> _computeSimilar() async {
    final sourceEmbedding = await widget.library.db.embeddingForAsset(widget.sourceAsset.id);
    if (sourceEmbedding == null) return [];
    final embeddings = await widget.library.cachedEmbeddings();
    final ranked = await compute(
      _rankBySimilarityIsolate,
      (query: sourceEmbedding, candidates: embeddings, topK: _maxResults + 1),
    );
    final ids = ranked.map((e) => e.$1).where((id) => id != widget.sourceAsset.id).take(_maxResults).toList();
    return widget.library.db.assetsByIds(ids);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.library.clipAvailable) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ähnliche Fotos')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xxl),
            child: Text(
              'KI-Bildsuche nicht verfügbar – CLIP-Modell fehlt (siehe Einstellungen → KI-Modelle).',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ähnliche Fotos')),
      body: FutureBuilder<List<AssetData>>(
        future: _resultsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final results = snapshot.data ?? [];
          if (results.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xxl),
                child: Text(
                  'Für dieses Foto liegt noch kein KI-Embedding vor (siehe Werkzeuge → KI-Bildsuche → '
                  'CLIP-Embeddings berechnen) oder es gibt keine ähnlichen Fotos in der Bibliothek.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 160,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final asset = results[index];
              return AssetThumbnailTile(
                asset: asset,
                paths: widget.library.paths,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => AssetViewerScreen(
                    assets: results,
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
                )),
              );
            },
          );
        },
      ),
    );
  }
}
