import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:image/image.dart' as img;

import 'caption_tokenizer.dart';

/// Standard-ViT-Bildvorverarbeitung des gebündelten Xenova/vit-gpt2-image
/// -captioning-Exports (`preprocessor_config.json`) – einfacher als
/// CLIP/SAM: fester Mittelwert/Standardabweichung 0,5 statt
/// ImageNet-Statistiken.
const _captionMean = [0.5, 0.5, 0.5];
const _captionStd = [0.5, 0.5, 0.5];
const _captionImageSize = 224;

const _numDecoderLayers = 12;
const _numAttentionHeads = 12;
const _headDim = 64;
const _vocabSize = 50257;

/// Kapselt On-Device-Inferenz mit einem ViT-GPT2-Bildbeschreibungs-Modell
/// (Bild-Encoder + autoregressiver Text-Decoder als zwei separate
/// ONNX-Dateien) für automatische (englische) Bildunterschriften.
///
/// Anders als [ClipService]/[SegmentationService] ist der Decoder KEIN
/// einzelner Forward-Pass, sondern ein Greedy-Decoding-Loop: pro erzeugtem
/// Wort ein weiterer `session.run()`-Aufruf, der den bisherigen KV-Cache
/// (`past_key_values.*` rein / `present.*` raus) weiterreicht. Der Decoder
/// ist ein "merged" Optimum-Export: ein `use_cache_branch`-Flag schaltet
/// zwischen "erster Schritt ohne Cache" und "Folgeschritt mit Cache" um,
/// statt zwei getrennte ONNX-Dateien zu benötigen. Ein-/Ausgabenamen sind
/// fest gegen die tatsächlichen ONNX-Dateien verifiziert (siehe
/// model_catalog.dart und ein realer Python-onnxruntime-Smoke-Test), nicht
/// geraten.
class CaptioningService {
  CaptioningService._(this._encoderSession, this._decoderSession, this._tokenizer);

  final OrtSession _encoderSession;
  final OrtSession _decoderSession;
  final CaptionTokenizer _tokenizer;

  /// Im Smoke-Test reichten 16 Schritte für eine vollständige Caption;
  /// deutlicher Sicherheitsaufschlag als harte Obergrenze.
  static const _maxNewTokens = 30;

  static bool _filesPresent(String modelsDir) {
    for (final name in ['caption_encoder.onnx', 'caption_decoder.onnx', 'caption_vocab.json']) {
      if (!File('$modelsDir/$name').existsSync()) return false;
    }
    return true;
  }

  static bool isAvailable(String modelsDir) => _filesPresent(modelsDir);

  static Future<CaptioningService> load(String modelsDir) async {
    final ort = OnnxRuntime();
    final encoderSession = await ort.createSession('$modelsDir/caption_encoder.onnx');
    final decoderSession = await ort.createSession('$modelsDir/caption_decoder.onnx');
    final tokenizer = await CaptionTokenizer.loadFromFile('$modelsDir/caption_vocab.json');
    return CaptioningService._(encoderSession, decoderSession, tokenizer);
  }

  /// Erzeugt eine englische Bildunterschrift für ein bereits dekodiertes
  /// Foto per Greedy-Decoding (das Modell selbst ist mit `num_beams=1`
  /// konfiguriert, kein Beam-Search nötig). Bricht ab, sobald das
  /// Ende-Token erzeugt wird, spätestens nach [_maxNewTokens] Wörtern.
  ///
  /// [liveTensors] verfolgt alle aktuell nicht-disposed `OrtValue`s über
  /// den gesamten (bis zu 30 Schritte langen) Decoder-Loop hinweg: schlägt
  /// `session.run()`/`asFlattenedList()` irgendwo mitten in der Schleife
  /// fehl (Audit-Fund – vorher gab es hier kein try/finally), disposed der
  /// finally-Block alles, was zu dem Zeitpunkt noch offen war, statt native
  /// Tensor-Handles für immer leaken zu lassen.
  Future<String> generateCaption(img.Image decoded) async {
    final liveTensors = <OrtValue>{};
    Future<void> disposeTracked(OrtValue v) async {
      await v.dispose();
      liveTensors.remove(v);
    }

    try {
      final resized = img.copyResize(decoded, width: _captionImageSize, height: _captionImageSize);
      final chw = Float32List(3 * _captionImageSize * _captionImageSize);
      var idx = 0;
      for (var c = 0; c < 3; c++) {
        for (var y = 0; y < _captionImageSize; y++) {
          for (var x = 0; x < _captionImageSize; x++) {
            final pixel = resized.getPixel(x, y);
            final value = c == 0 ? pixel.r : (c == 1 ? pixel.g : pixel.b);
            chw[idx++] = (value / 255.0 - _captionMean[c]) / _captionStd[c];
          }
        }
      }

      final pixelTensor = await OrtValue.fromList(chw, [1, 3, _captionImageSize, _captionImageSize]);
      liveTensors.add(pixelTensor);
      final encoderOutputs = await _encoderSession.run({'pixel_values': pixelTensor});
      liveTensors.addAll(encoderOutputs.values);
      await disposeTracked(pixelTensor);
      // Wird über den kompletten Decoder-Loop hinweg unverändert wiederver-
      // wendet (nicht pro Schritt neu übertragen) – OrtValue kapselt nur ein
      // natives Handle (siehe unten), Wiederverwendung als Eingabe mehrerer
      // run()-Aufrufe ist unproblematisch.
      final encoderHiddenStates = encoderOutputs['last_hidden_state']!;

      var past = <String, OrtValue>{};
      for (var i = 0; i < _numDecoderLayers; i++) {
        final k = await OrtValue.fromList(Float32List(0), [1, _numAttentionHeads, 0, _headDim]);
        final v = await OrtValue.fromList(Float32List(0), [1, _numAttentionHeads, 0, _headDim]);
        liveTensors.add(k);
        liveTensors.add(v);
        past['past_key_values.$i.key'] = k;
        past['past_key_values.$i.value'] = v;
      }

      final generatedIds = <int>[];
      var nextInputId = CaptionTokenizer.endOfTextId; // Start-Token
      var useCache = false;

      for (var step = 0; step < _maxNewTokens; step++) {
        final inputIdsTensor = await OrtValue.fromList(Int64List.fromList([nextInputId]), [1, 1]);
        final useCacheTensor = await OrtValue.fromList([useCache], [1]);
        liveTensors.add(inputIdsTensor);
        liveTensors.add(useCacheTensor);

        final outputs = await _decoderSession.run({
          'input_ids': inputIdsTensor,
          'encoder_hidden_states': encoderHiddenStates,
          'use_cache_branch': useCacheTensor,
          ...past,
        });
        liveTensors.addAll(outputs.values);

        await disposeTracked(inputIdsTensor);
        await disposeTracked(useCacheTensor);

        final logitsTensor = outputs['logits']!;
        final logitsRaw = await logitsTensor.asFlattenedList();
        await disposeTracked(logitsTensor);

        // input_ids ist in jedem Schritt genau 1 Token lang, die Logits
        // enthalten also immer nur einen einzigen Zeitschritt (Länge
        // _vocabSize) – reiner Argmax, kein Beam-Search.
        var bestId = 0;
        var bestScore = double.negativeInfinity;
        for (var v = 0; v < _vocabSize; v++) {
          final score = (logitsRaw[v] as num).toDouble();
          if (score > bestScore) {
            bestScore = score;
            bestId = v;
          }
        }

        // Alte past_key_values durch die neuen present.*-Ausgaben ersetzen –
        // OrtValue kapselt nur ein natives `valueId`-Handle (siehe
        // ort_session.dart), daher direkte Wiederverwendung als nächste
        // Decoder-Eingabe ohne Umweg über Dart-seitige Float-Listen. Die
        // gerade abgelösten past_key_values werden erst JETZT disposed
        // (nicht pauschal wie bei ClipService/SegmentationService alle
        // Ausgaben eines run()-Aufrufs, da present.* hier weiterlebt).
        for (final v in past.values) {
          await disposeTracked(v);
        }
        past = {
          for (var i = 0; i < _numDecoderLayers; i++) ...{
            'past_key_values.$i.key': outputs['present.$i.key']!,
            'past_key_values.$i.value': outputs['present.$i.value']!,
          },
        };

        if (bestId == CaptionTokenizer.endOfTextId) break;
        generatedIds.add(bestId);
        nextInputId = bestId;
        useCache = true;
      }

      for (final v in past.values) {
        await disposeTracked(v);
      }
      await disposeTracked(encoderHiddenStates);

      return _tokenizer.decode(generatedIds).trim();
    } finally {
      // Sicherheitsnetz für den Fehlerfall: alles, was auf dem Erfolgspfad
      // oben nicht schon disposed+aus liveTensors entfernt wurde, wird hier
      // nachgeholt statt für immer als natives Tensor-Handle zu leaken.
      for (final v in liveTensors) {
        try {
          await v.dispose();
        } catch (_) {
          // Bereits disposed oder Sitzung inzwischen geschlossen – bestmöglich.
        }
      }
    }
  }

  Future<void> dispose() async {
    await _encoderSession.close();
    await _decoderSession.close();
  }
}
