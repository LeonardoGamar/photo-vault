import 'dart:math' as math;
import 'dart:typed_data';

/// Eingabe für [findDuplicateGroups] – gebündelt in einer Klasse, da
/// [compute] genau ein Argument an die Isolate-Funktion übergibt.
class DuplicateSearchParams {
  final Map<String, Float32List> embeddings;
  final double threshold;
  const DuplicateSearchParams(this.embeddings, this.threshold);
}

/// Eingabe für [findBurstGroups] – siehe [DuplicateSearchParams].
class BurstSearchParams {
  final Map<String, Float32List> embeddings;
  final Map<String, DateTime> fileCreatedAt;
  final double threshold;
  final Duration maxGap;
  const BurstSearchParams(
    this.embeddings,
    this.fileCreatedAt, {
    this.threshold = 0.92,
    this.maxGap = const Duration(seconds: 30),
  });
}

/// Anzahl unabhängiger Zufalls-Projektionen für die Vorfilterung (siehe
/// [_candidateIndexPairs]) – mehr Projektionen erhöhen die Trefferquote
/// (Recall) auf Kosten von etwas mehr Rechenzeit. 2 ist ein guter Kompromiss:
/// sehr ähnliche Fotos liegen praktisch immer in mindestens einer der beiden
/// projizierten Sortierungen nah beieinander.
const _projectionCount = 2;

/// Feste statt echter Zufalls-Seeds: dieselben Projektionsrichtungen bei
/// jedem Lauf, sonst wäre nicht reproduzierbar, welche Gruppen bei
/// identischen Daten gefunden werden.
const _projectionSeeds = [0x5EED0001, 0x5EED0002];

/// Wie viele Nachbarn in der sortierten Projektions-Reihenfolge jeweils
/// verglichen werden – begrenzt die Vorfilterung auf O(n · Fenster) statt
/// O(n²). 200 ist großzügig bemessen: Duplikat-/Serien-Cluster bestehen in
/// der Praxis fast nie aus mehr als ein paar Dutzend Fotos.
const _slidingWindow = 200;

/// Gruppiert Foto-IDs anhand paarweiser Kosinus-Ähnlichkeit ihrer
/// CLIP-Embeddings (Union-Find über eine vorgefilterte Kandidatenliste, siehe
/// [_candidateIndexPairs]). Bewusst als TOP-LEVEL-Funktion ausgelagert (statt
/// eine Methode auf einem State), damit sie über [compute] in einem eigenen
/// Isolate laufen kann.
///
/// Ein reiner Alle-gegen-alle-Vergleich ist O(n²) – bei 100.000 Fotos wären
/// das ~5 Milliarden Kosinus-Vergleiche (praktisch nie fertig). Die
/// Vorfilterung über zufällige Projektionen (eine Form von Locality-Sensitive
/// Hashing) reduziert das auf O(n · Projektionen · Fenster), auf Kosten
/// einer (bei diesen Parametern in der Praxis vernachlässigbaren, aber nicht
/// mathematisch ausgeschlossenen) Chance, ein Paar zu übersehen, dessen
/// Embeddings in KEINER der Projektionen nah beieinander landen.
List<List<String>> findDuplicateGroups(DuplicateSearchParams params) {
  final embeddings = params.embeddings;
  final ids = embeddings.keys.toList(growable: false);
  final n = ids.length;
  final vectors = List<Float32List>.generate(n, (i) => embeddings[ids[i]]!, growable: false);

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

  for (final packed in _candidateIndexPairs(vectors)) {
    final i = packed ~/ n;
    final j = packed % n;
    if (_cosineSimilarity(vectors[i], vectors[j]) >= params.threshold) union(i, j);
  }

  return _resolveClusters(parent, n, ids);
}

/// Wie [findDuplicateGroups], verlangt beim Zusammenfassen zusätzlich, dass
/// die beiden Fotos zeitlich höchstens [BurstSearchParams.maxGap]
/// auseinanderliegen ("Serie"/Burst statt inhaltlich ähnlicher, aber
/// zeitlich unabhängiger Aufnahmen) – Fotos ohne bekanntes Aufnahmedatum
/// werden nie gruppiert (sicherer Default statt einer geratenen Zeit).
List<List<String>> findBurstGroups(BurstSearchParams params) {
  final embeddings = params.embeddings;
  final ids = embeddings.keys.toList(growable: false);
  final n = ids.length;
  final vectors = List<Float32List>.generate(n, (i) => embeddings[ids[i]]!, growable: false);
  final timestamps = List<DateTime?>.generate(n, (i) => params.fileCreatedAt[ids[i]], growable: false);

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

  for (final packed in _candidateIndexPairs(vectors)) {
    final i = packed ~/ n;
    final j = packed % n;
    final ti = timestamps[i], tj = timestamps[j];
    if (ti == null || tj == null) continue;
    if (ti.difference(tj).abs() > params.maxGap) continue;
    if (_cosineSimilarity(vectors[i], vectors[j]) >= params.threshold) union(i, j);
  }

  return _resolveClusters(parent, n, ids);
}

List<List<String>> _resolveClusters(List<int> parent, int n, List<String> ids) {
  int find(int x) {
    while (parent[x] != x) {
      x = parent[x];
    }
    return x;
  }

  final clusters = <int, List<int>>{};
  for (var i = 0; i < n; i++) {
    clusters.putIfAbsent(find(i), () => []).add(i);
  }
  return clusters.values
      .where((g) => g.length >= 2)
      .map((g) => g.map((i) => ids[i]).toList())
      .toList()
    ..sort((a, b) => b.length.compareTo(a.length));
}

/// Sortiert die Embeddings [_projectionCount]-mal nach ihrer Projektion auf
/// eine feste Zufallsrichtung und bildet aus jeweils benachbarten Einträgen
/// (innerhalb von [_slidingWindow]) Kandidaten-Indexpaare – siehe
/// [findDuplicateGroups] für die Begründung. Jedes Paar wird als einzelner
/// `int` gepackt (`kleinerIndex * n + größerIndex`) statt als Tupel, damit
/// das deduplizierende `Set` reine Integer- statt String-Hashes nutzt.
Set<int> _candidateIndexPairs(List<Float32List> vectors) {
  final n = vectors.length;
  if (n < 2) return {};
  final dim = vectors.first.length;

  final pairs = <int>{};
  for (var p = 0; p < _projectionCount; p++) {
    final direction = _randomDirection(dim, _projectionSeeds[p]);
    final projValues = Float64List(n);
    for (var i = 0; i < n; i++) {
      projValues[i] = _cosineSimilarity(vectors[i], direction);
    }
    final order = List<int>.generate(n, (i) => i)
      ..sort((a, b) => projValues[a].compareTo(projValues[b]));

    for (var i = 0; i < n; i++) {
      final end = math.min(i + _slidingWindow, n);
      for (var j = i + 1; j < end; j++) {
        final a = order[i], b = order[j];
        final lo = math.min(a, b), hi = math.max(a, b);
        pairs.add(lo * n + hi);
      }
    }
  }
  return pairs;
}

/// Deterministische "Zufalls"-Richtung (fester Seed, siehe [_projectionSeeds])
/// derselben Dimension wie die CLIP-Embeddings, für [_candidateIndexPairs].
Float32List _randomDirection(int dim, int seed) {
  final rand = math.Random(seed);
  final v = Float32List(dim);
  var normSq = 0.0;
  for (var i = 0; i < dim; i++) {
    final x = rand.nextDouble() * 2 - 1;
    v[i] = x;
    normSq += x * x;
  }
  final norm = math.sqrt(normSq);
  if (norm > 0) {
    for (var i = 0; i < dim; i++) {
      v[i] = v[i] / norm;
    }
  }
  return v;
}

/// Öffentlich, weil auch SecondLibraryScanService dieselbe Kosinus-
/// Ähnlichkeit für einzelne Paare braucht (nicht nur die Gruppenbildung
/// hier) – z.B. um einer gefundenen externen Übereinstimmung einen
/// konkreten Ähnlichkeitswert für die Anzeige mitzugeben.
double cosineSimilarity(Float32List a, Float32List b) => _cosineSimilarity(a, b);

double _cosineSimilarity(Float32List a, Float32List b) {
  var dot = 0.0;
  final len = math.min(a.length, b.length);
  for (var i = 0; i < len; i++) {
    dot += a[i] * b[i];
  }
  return dot; // Embeddings sind bereits L2-normalisiert
}
