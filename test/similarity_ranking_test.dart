import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:photo_vault/services/clip_service.dart';
import 'package:photo_vault/services/similarity_ranking.dart';

void main() {
  final kandidaten = <String, Float32List>{
    'schwach': Float32List.fromList([0.1, 0]),
    'gleich_a': Float32List.fromList([0.7, 0]),
    'staerkste': Float32List.fromList([0.9, 0]),
    'gleich_b': Float32List.fromList([0.7, 0]),
  };

  test('Top-K-Heap behält nur die besten Treffer in stabiler Reihenfolge', () {
    final rang = ClipService.rankBySimilarity(
      Float32List.fromList([1, 0]),
      kandidaten,
      topK: 3,
    );

    expect(rang.map((e) => e.key), ['staerkste', 'gleich_a', 'gleich_b']);
  });

  test('Ranking läuft mit demselben Ergebnis im Hintergrund-Isolate', () async {
    final rang = await rankBySimilarityOffMain(
      Float32List.fromList([1, 0]),
      kandidaten,
      topK: 2,
    );

    expect(rang.map((e) => e.$1), ['staerkste', 'gleich_a']);
  });
}
