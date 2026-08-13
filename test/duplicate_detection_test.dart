import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:photo_vault/services/embedding_similarity.dart';

Float32List _randomUnitVector(math.Random rand, int dim) {
  final v = Float32List(dim);
  var normSq = 0.0;
  for (var i = 0; i < dim; i++) {
    final x = rand.nextDouble() * 2 - 1;
    v[i] = x;
    normSq += x * x;
  }
  final norm = math.sqrt(normSq);
  for (var i = 0; i < dim; i++) {
    v[i] = v[i] / norm;
  }
  return v;
}

Float32List _nearDuplicateOf(Float32List base, math.Random rand, {double noiseScale = 0.02}) {
  final dim = base.length;
  final v = Float32List(dim);
  var normSq = 0.0;
  for (var i = 0; i < dim; i++) {
    final x = base[i] + (rand.nextDouble() * 2 - 1) * noiseScale;
    v[i] = x;
    normSq += x * x;
  }
  final norm = math.sqrt(normSq);
  for (var i = 0; i < dim; i++) {
    v[i] = v[i] / norm;
  }
  return v;
}

double _cosine(Float32List a, Float32List b) {
  var dot = 0.0;
  for (var i = 0; i < a.length; i++) {
    dot += a[i] * b[i];
  }
  return dot;
}

/// Referenz-Implementierung (Alle-gegen-alle) für den Korrektheitsvergleich –
/// bewusst unabhängig von der Produktionslogik in duplicates_screen.dart neu
/// geschrieben, damit ein Fehler dort sich nicht selbst bestätigt.
List<Set<String>> _exhaustiveDuplicateGroups(Map<String, Float32List> embeddings, double threshold) {
  final ids = embeddings.keys.toList();
  final parent = {for (final id in ids) id: id};
  String find(String x) {
    while (parent[x] != x) {
      x = parent[x]!;
    }
    return x;
  }

  void union(String a, String b) {
    final ra = find(a), rb = find(b);
    if (ra != rb) parent[ra] = rb;
  }

  for (var i = 0; i < ids.length; i++) {
    for (var j = i + 1; j < ids.length; j++) {
      if (_cosine(embeddings[ids[i]]!, embeddings[ids[j]]!) >= threshold) {
        union(ids[i], ids[j]);
      }
    }
  }
  final clusters = <String, Set<String>>{};
  for (final id in ids) {
    clusters.putIfAbsent(find(id), () => {}).add(id);
  }
  return clusters.values.where((g) => g.length >= 2).toList();
}

/// Prüft die vorgefilterte Duplikatsuche (`findDuplicateGroups`, siehe
/// duplicates_screen.dart) gegen eine unabhängige Alle-gegen-alle-Referenz:
/// gezielt eingestreute Fast-Duplikate müssen zuverlässig gefunden werden
/// (Recall), und bei größeren Bibliotheken muss die Vorfilterung spürbar
/// schneller sein als der volle O(n²)-Vergleich.
void main() {
  test('findet gezielt eingestreute Fast-Duplikate zuverlässig', () {
    final rand = math.Random(42);
    const dim = 64;
    const noiseCount = 3000;
    final embeddings = <String, Float32List>{
      for (var i = 0; i < noiseCount; i++) 'noise_$i': _randomUnitVector(rand, dim),
    };

    final plantedPairs = <(String, String)>[];
    for (var g = 0; g < 5; g++) {
      final base = _randomUnitVector(rand, dim);
      final aId = 'planted_${g}_a';
      final bId = 'planted_${g}_b';
      embeddings[aId] = base;
      embeddings[bId] = _nearDuplicateOf(base, rand);
      plantedPairs.add((aId, bId));
    }

    const threshold = 0.92;
    final groups = findDuplicateGroups(DuplicateSearchParams(embeddings, threshold));

    for (final (a, b) in plantedPairs) {
      final found = groups.any((g) => g.contains(a) && g.contains(b));
      expect(found, isTrue, reason: 'Geplantes Duplikat-Paar $a/$b wurde nicht gefunden.');
    }
  });

  test('stimmt bei den geplanten Duplikaten mit der Alle-gegen-alle-Referenz überein', () {
    final rand = math.Random(99);
    const dim = 64;
    final embeddings = <String, Float32List>{
      for (var i = 0; i < 800; i++) 'noise_$i': _randomUnitVector(rand, dim),
    };
    final base = _randomUnitVector(rand, dim);
    embeddings['dup_a'] = base;
    embeddings['dup_b'] = _nearDuplicateOf(base, rand);

    const threshold = 0.92;
    final reference = _exhaustiveDuplicateGroups(embeddings, threshold);
    final actual = findDuplicateGroups(DuplicateSearchParams(embeddings, threshold));

    final referenceGroup = reference.singleWhere((g) => g.contains('dup_a'));
    final actualGroup = actual.singleWhere((g) => g.contains('dup_a'));
    expect(actualGroup.toSet(), referenceGroup);
  });

  test('ist bei größeren Bibliotheken deutlich schneller als der volle Alle-gegen-alle-Vergleich', () {
    final rand = math.Random(7);
    const dim = 64;
    const n = 5000;
    final embeddings = <String, Float32List>{
      for (var i = 0; i < n; i++) 'a_$i': _randomUnitVector(rand, dim),
    };
    const threshold = 0.92;

    final filteredStopwatch = Stopwatch()..start();
    findDuplicateGroups(DuplicateSearchParams(embeddings, threshold));
    filteredStopwatch.stop();

    final exhaustiveStopwatch = Stopwatch()..start();
    _exhaustiveDuplicateGroups(embeddings, threshold);
    exhaustiveStopwatch.stop();

    // ignore: avoid_print
    print('Vorfilterung: ${filteredStopwatch.elapsedMilliseconds} ms, '
        'Alle-gegen-alle: ${exhaustiveStopwatch.elapsedMilliseconds} ms '
        '(n=$n)');

    // Konservativ nur mindestens 3x schneller verlangt (statt der in der
    // Praxis deutlich größeren Differenz), um auf einer ausgelasteten
    // CI-Maschine nicht flaky zu werden.
    expect(filteredStopwatch.elapsedMilliseconds * 3,
        lessThanOrEqualTo(exhaustiveStopwatch.elapsedMilliseconds));
  });

  group('findBurstGroups', () {
    test('gruppiert nur Fotos, die sowohl ähnlich sind ALS AUCH zeitlich nah beieinander liegen', () {
      final rand = math.Random(11);
      const dim = 64;
      final base = _randomUnitVector(rand, dim);
      final anchor = DateTime(2026, 6, 1, 12, 0, 0);

      final embeddings = <String, Float32List>{
        'burst_a': base,
        'burst_b': _nearDuplicateOf(base, rand), // ähnlich + nah dran
        'far_away_but_similar': _nearDuplicateOf(base, rand), // ähnlich, aber weit weg in der Zeit
      };
      final fileCreatedAt = <String, DateTime>{
        'burst_a': anchor,
        'burst_b': anchor.add(const Duration(seconds: 2)),
        'far_away_but_similar': anchor.add(const Duration(days: 30)),
      };

      final groups = findBurstGroups(BurstSearchParams(embeddings, fileCreatedAt, maxGap: const Duration(seconds: 30)));

      expect(groups, hasLength(1));
      expect(groups.single.toSet(), {'burst_a', 'burst_b'});
    });

    test('Fotos ohne bekanntes Aufnahmedatum werden nie gruppiert', () {
      final rand = math.Random(12);
      const dim = 64;
      final base = _randomUnitVector(rand, dim);

      final embeddings = <String, Float32List>{
        'a': base,
        'b': _nearDuplicateOf(base, rand),
      };
      // 'b' hat kein Datum in der Map.
      final fileCreatedAt = <String, DateTime>{'a': DateTime(2026, 1, 1)};

      final groups = findBurstGroups(BurstSearchParams(embeddings, fileCreatedAt));

      expect(groups, isEmpty);
    });

    test('ähnliche, aber zu weit auseinanderliegende Fotos bilden keine Gruppe', () {
      final rand = math.Random(13);
      const dim = 64;
      final base = _randomUnitVector(rand, dim);
      final anchor = DateTime(2026, 6, 1);

      final embeddings = <String, Float32List>{
        'a': base,
        'b': _nearDuplicateOf(base, rand),
      };
      final fileCreatedAt = <String, DateTime>{
        'a': anchor,
        'b': anchor.add(const Duration(minutes: 5)),
      };

      final groups = findBurstGroups(BurstSearchParams(embeddings, fileCreatedAt, maxGap: const Duration(seconds: 30)));

      expect(groups, isEmpty);
    });
  });
}
