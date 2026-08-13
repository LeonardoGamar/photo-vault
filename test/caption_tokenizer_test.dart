import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:photo_vault/services/caption_tokenizer.dart';

/// Prüft den Byte-Level-BPE-Decoder gegen echte, in einem Python-
/// `onnxruntime`-Smoke-Test erzeugte Token-IDs (Xenova/vit-gpt2-image
/// -captioning, greedy decoding gegen ein reales Testfoto) – keine
/// erfundenen Fixture-Werte.
void main() {
  late Directory tempDir;
  late String vocabPath;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('caption_tokenizer_test');
    vocabPath = '${tempDir.path}/vocab.json';
    // Minimaler Ausschnitt aus dem echten GPT-2-Vokabular (Xenova/vit-gpt2
    // -image-captioning vocab.json), nur die für die Test-Fixture nötigen
    // Einträge – reale Token-Strings/IDs, nicht erfunden.
    final vocab = {
      'a': 64,
      'Ġlarge': 1588,
      'Ġwhite': 2330,
      'Ġand': 290,
      'Ġblack': 2042,
      'Ġwall': 3355,
      'Ġwith': 351,
      'Ġa': 257,
      'Ġpicture': 4286,
      'Ġof': 286,
      'Ġman': 582,
      'Ġon': 319,
      'Ġit': 340,
      'Ġ': 220,
      '<|endoftext|>': 50256,
    };
    await File(vocabPath).writeAsString(jsonEncode(vocab));
  });

  tearDownAll(() async {
    await tempDir.delete(recursive: true);
  });

  test('decode() rekonstruiert eine echte, im Smoke-Test erzeugte Caption', () async {
    final tokenizer = await CaptionTokenizer.loadFromFile(vocabPath);

    // Reale, vom Modell erzeugte ID-Sequenz – endet auf das
    // Leerzeichen-Token 'Ġ' (220) vor dem End-Token; das Trimmen des
    // Ergebnisses ist Aufgabe von CaptioningService, nicht des reinen
    // Decoders (siehe dort).
    final ids = [64, 1588, 2330, 290, 2042, 3355, 351, 257, 4286, 286, 257, 582, 319, 340, 220];

    expect(tokenizer.decode(ids), 'a large white and black wall with a picture of a man on it ');
  });

  test('decode() überspringt Start-/Ende-Token an beliebiger Position', () async {
    final tokenizer = await CaptionTokenizer.loadFromFile(vocabPath);

    expect(tokenizer.decode([50256, 64, 1588, 50256]), 'a large');
  });

  test('decode() liefert leeren String für eine leere oder reine Marker-Sequenz', () async {
    final tokenizer = await CaptionTokenizer.loadFromFile(vocabPath);

    expect(tokenizer.decode([]), '');
    expect(tokenizer.decode([50256, 50256]), '');
  });
}
