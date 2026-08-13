import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:image/image.dart' as img;

import 'clip_tokenizer.dart';

/// Mittelwert/Standardabweichung, mit denen CLIP-Modelle trainiert wurden
/// (Standard für alle offiziellen OpenAI-CLIP-Checkpoints).
const _clipMean = [0.48145466, 0.4578275, 0.40821073];
const _clipStd = [0.26862954, 0.26130258, 0.27577711];
const _imageSize = 224;

/// Kapselt On-Device-Inferenz mit einem CLIP-Modell (Bild- und Text-Encoder
/// als zwei separate ONNX-Dateien), um natürlichsprachliche Bildsuche ohne
/// Cloud-Dienst zu ermöglichen.
///
/// WICHTIG: Diese Klasse benötigt drei vom Nutzer bereitzustellende Dateien
/// (siehe README → "KI-Modelle einrichten"):
///   - clip_image_encoder.onnx
///   - clip_text_encoder.onnx
///   - vocab.json + merges.txt (Tokenizer-Dateien, siehe clip_tokenizer.dart)
///
/// Die Ein-/Ausgabenamen der ONNX-Sitzungen folgen der Konvention des
/// HuggingFace-`optimum`-Exports (`pixel_values` → `image_embeds`,
/// `input_ids`/`attention_mask` → `text_embeds`). Falls dein konkretes
/// Modell andere Namen verwendet (mit z.B. Netron prüfbar), passe die
/// Konstanten unten an.
class ClipService {
  ClipService._(this._imageSession, this._textSession, this._tokenizer);

  final OrtSession _imageSession;
  final OrtSession _textSession;
  final ClipTokenizer _tokenizer;

  // Eingabenamen werden zur Laufzeit dynamisch aus session.inputNames gelesen
  // (siehe embedImage/embedText) statt geraten – das war zuvor eine
  // Fehlerquelle (z.B. schlug "attention_mask" beim Xenova-CLIP-Text-Encoder
  // fehl, weil dieser gar kein solches Eingabefeld hat).
  static const imageOutputName = 'image_embeds'; // bevorzugter Name, mit Fallback
  static const textOutputName = 'text_embeds'; // bevorzugter Name, mit Fallback

  static bool _filesPresent(String modelsDir) {
    for (final name in [
      'clip_image_encoder.onnx',
      'clip_text_encoder.onnx',
      'vocab.json',
      'merges.txt',
    ]) {
      if (!File('$modelsDir/$name').existsSync()) return false;
    }
    return true;
  }

  static bool isAvailable(String modelsDir) => _filesPresent(modelsDir);

  static Future<ClipService> load(String modelsDir) async {
    final ort = OnnxRuntime();
    final imageSession = await ort.createSession('$modelsDir/clip_image_encoder.onnx');
    final textSession = await ort.createSession('$modelsDir/clip_text_encoder.onnx');
    final tokenizer = await ClipTokenizer.loadFromFiles(
      vocabJsonPath: '$modelsDir/vocab.json',
      mergesTxtPath: '$modelsDir/merges.txt',
    );
    return ClipService._(imageSession, textSession, tokenizer);
  }

  /// Berechnet das Bild-Embedding eines bereits dekodierten Fotos. Nimmt
  /// bewusst ein [img.Image] statt einer [File] entgegen: Aufrufer wie
  /// [LibraryState] dekodieren dasselbe Bild ohnehin schon für die
  /// Gesichtserkennung – ein zweites Mal von der Platte zu lesen und zu
  /// dekodieren wäre verschwendete Rechenzeit. Videos werden aktuell nicht
  /// unterstützt (es müsste zunächst ein Frame extrahiert werden).
  Future<Float32List> embedImage(img.Image decoded) async {
    final resized = img.copyResize(decoded, width: _imageSize, height: _imageSize);

    final chw = Float32List(3 * _imageSize * _imageSize);
    var idx = 0;
    for (var c = 0; c < 3; c++) {
      for (var y = 0; y < _imageSize; y++) {
        for (var x = 0; x < _imageSize; x++) {
          final pixel = resized.getPixel(x, y);
          final value = c == 0 ? pixel.r : (c == 1 ? pixel.g : pixel.b);
          final normalized = (value / 255.0 - _clipMean[c]) / _clipStd[c];
          chw[idx++] = normalized;
        }
      }
    }

    final inputTensor = await OrtValue.fromList(chw, [1, 3, _imageSize, _imageSize]);
    final outputs = await _imageSession.run({_imageSession.inputNames.first: inputTensor});
    final outputTensor = outputs[imageOutputName] ?? outputs[_imageSession.outputNames.first]!;
    final raw = await outputTensor.asFlattenedList();
    await inputTensor.dispose();
    for (final v in outputs.values) {
      await v.dispose();
    }
    return _l2Normalize(Float32List.fromList(raw.map((e) => (e as num).toDouble()).toList()));
  }

  Future<Float32List> embedText(String text) async {
    final tokenIds = Int64List.fromList(_tokenizer.encode(text));

    final idsTensor = await OrtValue.fromList(tokenIds, [1, ClipTokenizer.contextLength]);
    final outputs = await _textSession.run({
      _textSession.inputNames.first: idsTensor,
    });
    final outputTensor = outputs[textOutputName] ?? outputs[_textSession.outputNames.first]!;
    final raw = await outputTensor.asFlattenedList();
    await idsTensor.dispose();
    for (final v in outputs.values) {
      await v.dispose();
    }
    return _l2Normalize(Float32List.fromList(raw.map((e) => (e as num).toDouble()).toList()));
  }

  Float32List _l2Normalize(Float32List vector) {
    var sumSq = 0.0;
    for (final v in vector) {
      sumSq += v * v;
    }
    final norm = math.sqrt(sumSq);
    if (norm == 0) return vector;
    final result = Float32List(vector.length);
    for (var i = 0; i < vector.length; i++) {
      result[i] = vector[i] / norm;
    }
    return result;
  }

  /// Sortiert eine Menge gespeicherter Embeddings nach Kosinus-Ähnlichkeit
  /// zu einem Anfrage-Vektor (z.B. aus [embedText]) – Brute-Force, aber für
  /// private Fotobibliotheken ausreichend performant.
  static List<MapEntry<String, double>> rankBySimilarity(
    Float32List query,
    Map<String, Float32List> candidates, {
    int topK = 200,
  }) {
    final scored = candidates.entries.map((e) {
      var dot = 0.0;
      final v = e.value;
      final len = math.min(query.length, v.length);
      for (var i = 0; i < len; i++) {
        dot += query[i] * v[i];
      }
      return MapEntry(e.key, dot); // beide Vektoren sind bereits L2-normalisiert
    }).toList();
    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.take(topK).toList();
  }

  Future<void> dispose() async {
    await _imageSession.close();
    await _textSession.close();
  }
}
