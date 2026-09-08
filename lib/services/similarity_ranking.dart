import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;

import 'clip_service.dart';

typedef _RankingArgs = ({
  TransferableTypedData vectors,
  int queryLength,
  List<String> ids,
  List<int> lengths,
  int topK,
});

List<(String, double)> _berechneRanking(_RankingArgs args) {
  final floats = args.vectors.materialize().asFloat32List();
  final query = Float32List.sublistView(floats, 0, args.queryLength);
  var offset = args.queryLength;
  final candidates = <String, Float32List>{};
  for (var i = 0; i < args.ids.length; i++) {
    final end = offset + args.lengths[i];
    candidates[args.ids[i]] = Float32List.sublistView(floats, offset, end);
    offset = end;
  }
  return [
    for (final e in ClipService.rankBySimilarity(
      query,
      candidates,
      topK: args.topK,
    ))
      (e.key, e.value),
  ];
}

/// Bewertet CLIP-Einbettungen außerhalb des UI-Isolates.
///
/// Alle Zahlen werden in einen zusammenhängenden Puffer geschrieben und mit
/// [TransferableTypedData] ohne eine weitere Kopie an das Isolate übergeben.
/// Das vermeidet bei großen Bibliotheken die zweite vollständige
/// Embedding-Map im Arbeitsspeicher.
Future<List<(String, double)>> rankBySimilarityOffMain(
  Float32List query,
  Map<String, Float32List> candidates, {
  required int topK,
}) {
  final ids = candidates.keys.toList(growable: false);
  final lengths = [
    for (final id in ids) candidates[id]!.length,
  ];
  final packed = Float32List(
      query.length + lengths.fold<int>(0, (sum, length) => sum + length));
  packed.setRange(0, query.length, query);
  var offset = query.length;
  for (final id in ids) {
    final vector = candidates[id]!;
    packed.setRange(offset, offset + vector.length, vector);
    offset += vector.length;
  }
  return compute(
    _berechneRanking,
    (
      vectors: TransferableTypedData.fromList([packed.buffer.asUint8List()]),
      queryLength: query.length,
      ids: ids,
      lengths: lengths,
      topK: topK,
    ),
  );
}
