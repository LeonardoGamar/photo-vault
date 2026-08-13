import 'dart:math' as math;
import 'dart:typed_data';

import 'face_engine_service.dart';

/// Eingabe für [clusterFaces] – als eigene Klasse statt loser Parameter,
/// damit sich der Aufruf sauber an `compute()` übergeben lässt (top-level
/// Funktion + ein einzelnes Argument, isolate-fähig).
class FaceClusterInput {
  final Map<String, Float32List> embeddingsByFaceId;
  final double threshold;
  const FaceClusterInput(this.embeddingsByFaceId, this.threshold);
}

/// Gruppiert unzugeordnete Gesichter anhand ihrer SFace-Embeddings zu
/// Vorschlags-Clustern (mind. 2 Gesichter – einzelne Gesichter ohne
/// ähnliches Gegenstück bleiben im normalen "Unbenannte Gesichter"-Raster).
///
/// Exaktes (nicht LSH-vorgefiltertes) Alle-gegen-alle-Clustering über
/// Union-Find, bewusst OHNE die Zufallsprojektions-Vorfilterung aus
/// duplicates_screen.dart: exaktes statt approximiertes Clustering ist für
/// identitätssensitive Gruppierung die richtige Wahl, und bei der
/// *typischen* Nutzung (regelmäßig zwischendurch triagieren, dadurch
/// hunderte bis niedrige Tausende unzugeordnete Gesichter) ist O(n²)
/// schnell genug – hochgerechnet aus dem Duplikatsuche-Benchmark
/// (`test/duplicate_detection_test.dart`, n=5000/dim=64: 501ms exhaustive)
/// auf die tatsächliche SFace-Embedding-Dimension (128, nicht 64) liegt
/// n=5000 eher bei ~1s. Bei sehr großen, noch nie triagierten Bibliotheken
/// (mehrere Zehntausend unzugeordnete Gesichter) kann ein Lauf dagegen
/// spürbar länger dauern (grob quadratisch, siehe Warnschwelle beim Aufruf
/// in people_screen.dart) – bewusst kein Deckel hier in der reinen
/// Algorithmus-Funktion, damit nie ein Teil der Gesichter stillschweigend
/// ignoriert wird.
List<List<String>> clusterFaces(FaceClusterInput input) {
  final ids = input.embeddingsByFaceId.keys.toList(growable: false);
  final n = ids.length;
  final vectors = List<Float32List>.generate(n, (i) => input.embeddingsByFaceId[ids[i]]!, growable: false);

  final parent = List<int>.generate(n, (i) => i, growable: false);
  int find(int x) {
    while (parent[x] != x) {
      x = parent[x];
    }
    return x;
  }

  void union(int a, int b) {
    final ra = find(a), rb = find(b);
    if (ra != rb) parent[ra] = rb;
  }

  for (var i = 0; i < n; i++) {
    for (var j = i + 1; j < n; j++) {
      if (FaceEngineService.cosineSimilarity(vectors[i], vectors[j]) >= input.threshold) {
        union(i, j);
      }
    }
  }

  final clusters = <int, List<int>>{};
  for (var i = 0; i < n; i++) {
    clusters.putIfAbsent(find(i), () => []).add(i);
  }
  return clusters.values
      .where((g) => g.length >= 2) // Singletons bleiben im normalen Raster
      .map((g) => g.map((i) => ids[i]).toList())
      .toList()
    ..sort((a, b) => b.length.compareTo(a.length));
}

/// Mittelwert mehrerer bereits L2-normalisierter Embeddings, danach ERNEUT
/// auf Einheitslänge normiert – der Mittelwert normierter Vektoren ist
/// selbst nicht normiert, ohne diesen Schritt wären Kosinus-Vergleiche
/// gegen den Centroid verfälscht. Für den "ähnlich zu bestehender Person"-
/// Vorschlag beim Gesichts-Clustering (Centroid einer Person bzw. eines
/// neuen Clusters).
Float32List meanNormalizedEmbedding(Iterable<Float32List> vectors) {
  final list = vectors.toList(growable: false);
  final dim = list.first.length;
  final sum = Float32List(dim);
  for (final v in list) {
    for (var i = 0; i < dim; i++) {
      sum[i] += v[i];
    }
  }
  var normSq = 0.0;
  for (var i = 0; i < dim; i++) {
    sum[i] /= list.length;
    normSq += sum[i] * sum[i];
  }
  final norm = math.sqrt(normSq);
  if (norm == 0) return sum;
  for (var i = 0; i < dim; i++) {
    sum[i] /= norm;
  }
  return sum;
}
