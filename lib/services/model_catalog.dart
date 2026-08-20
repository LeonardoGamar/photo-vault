/// Katalog aller lokal nutzbaren, quelloffenen KI-Modelle. Ähnlich wie
/// digiKam (das seine Gesichtserkennungs- und Objekterkennungs-Modelle
/// automatisch von einem KDE-Server lädt), lädt PhotoVault diese Dateien
/// bei Bedarf direkt aus offiziellen, öffentlichen Repositories – es werden
/// keine Modellgewichte mit der App selbst ausgeliefert (zu groß, und so
/// bleibt immer nachvollziehbar, woher sie stammen und unter welcher
/// Lizenz sie stehen).
///
/// Alle Modelle hier sind quelloffen und stammen aus etablierten,
/// öffentlichen Projekten:
///   - YuNet / SFace: Teil von OpenCV Zoo (Apache-2.0)
///   - CLIP: OpenAI-Originalgewichte (MIT), hier als von der Community
///     bereitgestellte ONNX-Exporte (Xenova/transformers.js-Projekt, MIT)
///
/// Falls sich die Downloadpfade auf HuggingFace/GitHub ändern, reicht es,
/// die URLs in dieser Datei anzupassen.
library;

import '../l10n/app_localizations.dart';

class ModelFile {
  final String fileName; // Zieldateiname im models-Ordner
  final String url;

  /// SHA-256-Prüfsumme der Datei am [url] (kleingeschrieben, hex). Wird nach
  /// jedem Download verglichen (siehe ModelDownloadService) – schlägt der
  /// Vergleich fehl, wird die heruntergeladene Datei verworfen. Schützt vor
  /// stillschweigend veränderten/kompromittierten Downloads, da hier ONNX-
  /// Modelldateien direkt in die App-Inferenz geladen werden.
  final String sha256;

  const ModelFile(this.fileName, this.url, this.sha256);
}

class ModelCatalogEntry {
  final String id;

  /// Herkunft der Gewichte – dokumentiert, nicht angezeigt.
  final String sourceUrl;
  final List<ModelFile> files;

  const ModelCatalogEntry({
    required this.id,
    required this.sourceUrl,
    required this.files,
  });
}

/// Titel, Beschreibung und Lizenz eines Katalogeintrags in der
/// Oberflächensprache.
///
/// Sie stehen nicht in [ModelCatalogEntry] selbst: Die Einträge sind `const`,
/// ein übersetzter Text braucht aber den Kontext. Stünden sie doppelt – hier
/// deutsch und in den Sprachdateien nochmal – liefen beide Fassungen früher
/// oder später auseinander. Die Zuordnung läuft über die
/// [ModelCatalogEntry.id], dieselbe Kennung, unter der die Dateien im
/// Modellordner liegen.
String modellTitel(AppTexte t, String id) => switch (id) {
      'face_detection_yunet' => t.modellYunetTitel,
      'face_recognition_sface' => t.modellSfaceTitel,
      'clip_vit_b32' => t.modellClipTitel,
      'segmentation_sam_vit_base' => t.modellSamTitel,
      'captioning_florence2_base_ft' => t.modellCaptionTitel,
      'eye_state_ocec' => t.modellOcecTitel,
      'neural_restore_real_esrgan_x4' => t.modellEsrganTitel,
      'inpainting_lama' => t.modellLamaTitel,
      'translation_en_de' => t.modellEnDeTitel,
      'translation_de_en' => t.modellDeEnTitel,
      // Lieber die Kennung als eine leere Karte: Ein neu aufgenommenes
      // Modell fällt so sofort auf, statt still ohne Namen dazustehen.
      _ => id,
    };

String modellBeschreibung(AppTexte t, String id) => switch (id) {
      'face_detection_yunet' => t.modellYunetText,
      'face_recognition_sface' => t.modellSfaceText,
      'clip_vit_b32' => t.modellClipText,
      'segmentation_sam_vit_base' => t.modellSamText,
      'captioning_florence2_base_ft' => t.modellCaptionText,
      'eye_state_ocec' => t.modellOcecText,
      'neural_restore_real_esrgan_x4' => t.modellEsrganText,
      'inpainting_lama' => t.modellLamaText,
      'translation_en_de' => t.modellEnDeText,
      'translation_de_en' => t.modellDeEnText,
      _ => '',
    };

String modellLizenz(AppTexte t, String id) => switch (id) {
      'face_detection_yunet' => t.modellYunetLizenz,
      'face_recognition_sface' => t.modellSfaceLizenz,
      'clip_vit_b32' => t.modellClipLizenz,
      'segmentation_sam_vit_base' => t.modellSamLizenz,
      'captioning_florence2_base_ft' => t.modellCaptionLizenz,
      'eye_state_ocec' => t.modellOcecLizenz,
      'neural_restore_real_esrgan_x4' => t.modellEsrganLizenz,
      'inpainting_lama' => t.modellLamaLizenz,
      'translation_en_de' => t.modellEnDeLizenz,
      'translation_de_en' => t.modellDeEnLizenz,
      _ => '',
    };

class ModelCatalog {
  static const faceDetection = ModelCatalogEntry(
    id: 'face_detection_yunet',
    sourceUrl: 'https://github.com/opencv/opencv_zoo/tree/main/models/face_detection_yunet',
    files: [
      ModelFile(
        'face_detection_yunet.onnx',
        'https://github.com/opencv/opencv_zoo/raw/main/models/face_detection_yunet/face_detection_yunet_2023mar.onnx',
        '8f2383e4dd3cfbb4553ea8718107fc0423210dc964f9f4280604804ed2552fa4',
      ),
    ],
  );

  static const faceRecognition = ModelCatalogEntry(
    id: 'face_recognition_sface',
    sourceUrl: 'https://github.com/opencv/opencv_zoo/tree/main/models/face_recognition_sface',
    files: [
      ModelFile(
        'face_recognition_sface.onnx',
        'https://github.com/opencv/opencv_zoo/raw/main/models/face_recognition_sface/face_recognition_sface_2021dec.onnx',
        '0ba9fbfa01b5270c96627c4ef784da859931e02f04419c829e83484087c34e79',
      ),
    ],
  );

  static const clip = ModelCatalogEntry(
    id: 'clip_vit_b32',
    sourceUrl: 'https://huggingface.co/Xenova/clip-vit-base-patch32',
    files: [
      ModelFile(
        'clip_image_encoder.onnx',
        'https://huggingface.co/Xenova/clip-vit-base-patch32/resolve/main/onnx/vision_model.onnx',
        'fd6e1402a588279d1723c7534d4bcba5bc0b14b47dfab0e46f8c47b8270d7d40',
      ),
      ModelFile(
        'clip_text_encoder.onnx',
        'https://huggingface.co/Xenova/clip-vit-base-patch32/resolve/main/onnx/text_model.onnx',
        '3f6571f5bad13a97c469c1622e1cfc4d9aef78b79fdbfcff804ca357bfada8cc',
      ),
      ModelFile(
        'vocab.json',
        'https://huggingface.co/openai/clip-vit-base-patch32/resolve/main/vocab.json',
        '5047b556ce86ccaf6aa22b3ffccfc52d391ea4accdab9c2f2407da5b742d4363',
      ),
      ModelFile(
        'merges.txt',
        'https://huggingface.co/openai/clip-vit-base-patch32/resolve/main/merges.txt',
        'f526393189112391ce6f9795d4695f704121ce452c3aad1f5335cc41337eba85',
      ),
    ],
  );

  /// SAM (Segment Anything) ViT-Base, quantisiert – für KI-Objektmasken im
  /// Entwickeln-Screen (siehe SegmentationService, DevelopMasks). Zwei
  /// Teilmodelle wie bei CLIP: ein schwerer Bild-Encoder (einmal pro Foto
  /// berechnet) und ein leichter, promptbarer Masken-Decoder (ein einzelner
  /// Forward-Pass pro Klick, kein Mehrschritt-Loop). Derselbe Anbieter
  /// (Xenova/transformers.js) wie beim CLIP-Export oben, daher dieselbe
  /// Vertrauensbasis. Exakte Ein-/Ausgabe-Tensoren gegen die echten
  /// ONNX-Dateien verifiziert: Encoder nimmt `pixel_values`
  /// [1,3,1024,1024] entgegen (Skalierung auf Faktor 1/255, Normalisierung
  /// mit Mittel [0.485,0.456,0.406]/Standardabweichung
  /// [0.229,0.224,0.225], längste Kante auf 1024px, danach auf 1024x1024
  /// aufgefüllt), liefert `image_embeddings`/`image_positional_embeddings`
  /// [1,256,64,64]. Der Decoder nimmt zusätzlich `input_points`
  /// [1,1,n,2]/`input_labels` [1,1,n] (int64; 1=Vordergrund, 0=Hintergrund)
  /// entgegen – NUR Punkt-Prompts, kein Box-Prompt-Eingang in diesem Export
  /// – und liefert `iou_scores`/`pred_masks` (3 Kandidatenmasken, 256x256,
  /// höchster IoU-Wert gewinnt).
  static const segmentation = ModelCatalogEntry(
    id: 'segmentation_sam_vit_base',
    sourceUrl: 'https://huggingface.co/Xenova/sam-vit-base',
    files: [
      ModelFile(
        'sam_vision_encoder.onnx',
        'https://huggingface.co/Xenova/sam-vit-base/resolve/main/onnx/vision_encoder_quantized.onnx',
        'd9d7bca3b256ab71b3b7cdc35839983bc8ebaf68ea9022f15805ac43955cd247',
      ),
      ModelFile(
        'sam_prompt_mask_decoder.onnx',
        'https://huggingface.co/Xenova/sam-vit-base/resolve/main/onnx/prompt_encoder_mask_decoder_quantized.onnx',
        'cb90b279f549d2cab7fd6e20c38522438c65d84bdcca3d2a764cff7d857fdce2',
      ),
    ],
  );

  /// Florence-2 (base-ft) – das Beschreibungsmodell seit Version 1.4.
  ///
  /// **Warum der Wechsel weg von ViT-GPT2.** An 40 echten Fotos einer
  /// gewachsenen Bibliothek von Hand beurteilt: ViT-GPT2 traf 11, traf
  /// halb 18, lag 11 Mal falsch. Florence-2 traf 27, halb 11, falsch 2.
  /// An einer zweiten, überschneidungsfreien Stichprobe dasselbe Bild
  /// (7 gegen 27). ViT-GPT2 ist auf COCO trainiert und griff deshalb zu
  /// COCO-Gegenständen: Katze, Hydrant, Fernbedienung und Krawatte
  /// standen in Beschreibungen von Fotos, auf denen nichts davon zu
  /// sehen war.
  ///
  /// Florence-2 liest zudem Schrift im Bild – Ladenschilder, Ortstafeln,
  /// Aufschriften kamen in der Prüfstichprobe wörtlich richtig heraus.
  ///
  /// **Warum nicht gleich mehrsprachig?** Weil es dafür nichts in dieser
  /// Grössenordnung gibt. Geprüft wurden BLIP (nur Gemeinschaftskopien
  /// mit zweistelligen Downloadzahlen, die Kopie von onnx-community
  /// enthält gar keine Modelldatei) und die mehrsprachigen
  /// Seh-Sprach-Modelle, die alle im Gigabyte-Bereich liegen. Der Umweg
  /// über [translationEnDe] ist ausgemessen und gut: Die Übersetzung
  /// liefert flüssiges Deutsch und kostet 0,07 s je Satz. Sie war nie das
  /// Problem – sie bekam nur schlechtes Englisch.
  ///
  /// **Der Preis:** vier Dateien statt zwei (275 statt 246 MB) und rund
  /// fünfmal so viel Rechenzeit je Foto.
  ///
  /// Ein-/Ausgabetensoren real gegen die heruntergeladenen Dateien
  /// geprüft (Python `onnx`/`onnxruntime`) und mit einem
  /// End-zu-End-Lauf über 80 Fotos bestätigt:
  /// `vision_encoder` nimmt `pixel_values` [1,3,768,768] (ImageNet-
  /// Statistik, **kein** mittiger Zuschnitt) und liefert `image_features`
  /// [1,577,768]; `embed_tokens` bildet `input_ids` auf `inputs_embeds`
  /// ab; der Encoder nimmt `inputs_embeds` + `attention_mask`; der
  /// zusammengeführte Decoder zusätzlich 24 `past_key_values.{0..5}.
  /// {decoder,encoder}.{key,value}` und ein `use_cache_branch`-Flag.
  static const captioningFlorence = ModelCatalogEntry(
    id: 'captioning_florence2_base_ft',
    sourceUrl: 'https://huggingface.co/onnx-community/Florence-2-base-ft',
    files: [
      ModelFile(
        'florence_vision.onnx',
        'https://huggingface.co/onnx-community/Florence-2-base-ft/resolve/main/onnx/vision_encoder_quantized.onnx',
        '3b79d54f23f666f731549db23cb070c35a979ce19cbd9720e90e67a78dc9768c',
      ),
      ModelFile(
        'florence_embed.onnx',
        'https://huggingface.co/onnx-community/Florence-2-base-ft/resolve/main/onnx/embed_tokens_quantized.onnx',
        '6b2258db1c8ee9b160576ccde3cd3814d83a2edaed0dd1c6ca9ff3c38fa62214',
      ),
      ModelFile(
        'florence_encoder.onnx',
        'https://huggingface.co/onnx-community/Florence-2-base-ft/resolve/main/onnx/encoder_model_quantized.onnx',
        'f4ad7a68f1fb875d3bcf735ea14a7021b7ba7e83baf7cf10289881b4ed6d9b85',
      ),
      ModelFile(
        'florence_decoder.onnx',
        'https://huggingface.co/onnx-community/Florence-2-base-ft/resolve/main/onnx/decoder_model_merged_quantized.onnx',
        'f22f52f980c33df0efa15932c2f3db6d9d3595ce6387eca938b8cfe23dc4c641',
      ),
      ModelFile(
        'florence_vocab.json',
        'https://huggingface.co/onnx-community/Florence-2-base-ft/resolve/main/vocab.json',
        '394fdc63c71aabe0a9b97117f5d62fb5fcc4d59b2b3ea929a3929e6a53217b3c',
      ),
      ModelFile(
        'florence_merges.txt',
        'https://huggingface.co/onnx-community/Florence-2-base-ft/resolve/main/merges.txt',
        '1ce1664773c50f3e0cc8842619a93edc4624525b728b188a9e0be33b7726adc5',
      ),
    ],
  );

  /// OCEC ("Open Closed Eyes Classification"), Variante "n" – für die
  /// Geschlossene-Augen-Erkennung im Sichtungs-Modus (siehe
  /// EyeStateService). Nimmt einen kleinen Augen-Ausschnitt entgegen
  /// (Zentren aus den bereits vorhandenen YuNet-Landmarks abgeleitet, siehe
  /// FaceEngineService) und liefert eine Sigmoid-Wahrscheinlichkeit "Augen
  /// offen". Ein-/Ausgabetensoren real gegen die heruntergeladene ONNX-Datei
  /// verifiziert (Python `onnx`-Paket): Eingabe `images` [1,3,24,40] float32
  /// (BGR, Werte 0..1 – kein Mittelwert/Std wie bei CLIP/SAM), Ausgabe
  /// `prob_open` [1] float32. Kleinste sinnvolle Variante der 6 verfügbaren
  /// Größen (n: 176 KB, F1 0.9933) – die kleinste (p, 112 KB) hat einen
  /// minimal niedrigeren F1-Wert (0.9924) für einen kaum spürbaren
  /// Geschwindigkeitsvorteil bei <1ms Inferenzzeit ohnehin.
  static const eyeState = ModelCatalogEntry(
    id: 'eye_state_ocec',
    sourceUrl: 'https://github.com/PINTO0309/OCEC',
    files: [
      ModelFile(
        'eye_state_ocec_n.onnx',
        'https://github.com/PINTO0309/OCEC/releases/download/onnx/ocec_n.onnx',
        'c1e2af08ad822cb3d685babe0221499cdbf4952c0272cc66e5ed76c4007ef54e',
      ),
    ],
  );

  /// Real-ESRGAN x4, ONNX-Export – für KI-Restaurierung (Hochskalieren +
  /// Entrauschen in einem Durchgang, siehe RestoreService/RestoreJobs).
  /// Anders als die übrigen Modelle hier KEIN kleines, promptbares Modell,
  /// sondern ein rechenintensives Bild-zu-Bild-Netz: eine 512×512-Kachel
  /// dauert real gemessen ~4,8s mit CoreML-Beschleunigung (~20,1s rein auf
  /// der CPU) – ein typisches 12-MP-Foto (~63 Kacheln) liegt damit bei
  /// mehreren Minuten, läuft daher als Hintergrund-Warteschlange statt
  /// interaktiv. Eingabe `input` [1,3,h,w] float32 RGB 0..1 (dynamische
  /// Höhe/Breite), Ausgabe `output` [1,3,4h,4w] float32 RGB – real per
  /// Python `onnx`/`onnxruntime` gegen die heruntergeladene Datei
  /// verifiziert. Original-Gewichte (Real-ESRGAN, BSD-3-Clause), 1:1-Export
  /// ohne Modifikation.
  static const neuralRestore = ModelCatalogEntry(
    id: 'neural_restore_real_esrgan_x4',
    sourceUrl: 'https://huggingface.co/SceneWorks/real-esrgan-onnx',
    files: [
      ModelFile(
        'real_esrgan_x4.onnx',
        'https://huggingface.co/SceneWorks/real-esrgan-onnx/resolve/main/real_esrgan_x4.onnx',
        '5c586662929cbc686c1a5c38d9c060dbdb4ea5863a1f7672b8c0761e6b89c033',
      ),
    ],
  );

  /// Gemeinsames Wörterbuch beider Übersetzungsrichtungen.
  ///
  /// Die `tokenizer.json` von `Xenova/opus-mt-en-de` und
  /// `Xenova/opus-mt-de-en` sind Byte für Byte identisch (geprüft) – OPUS-MT
  /// nutzt für ein Sprachpaar ein gemeinsames SentencePiece-Wörterbuch.
  /// Deshalb steht sie in beiden Einträgen unter demselben Zielnamen und
  /// wird nur einmal geladen, egal welche Richtung zuerst installiert wird.
  static const _uebersetzungsVokabular = ModelFile(
    'translate_vocab.json',
    'https://huggingface.co/Xenova/opus-mt-en-de/resolve/main/tokenizer.json',
    '8e0fcf45621ea87fa680c7f9969c37a7f819c1f4c7658a2e6e0879b866a14b17',
  );

  /// Englisch → Deutsch, für die Bildbeschreibungen.
  ///
  /// **Warum Übersetzen und nicht gleich ein deutsches Modell?** Weil es
  /// kein vergleichbar kleines gibt (siehe [captioning]). Der naheliegende
  /// Weg für die Suche – ein mehrsprachiger CLIP-Text-Encoder, der in
  /// denselben Bildraum abbildet – scheitert an der Vertrauensfrage: Von
  /// `clip-ViT-B-32-multilingual-v1` existieren als ONNX nur
  /// Gemeinschaftskopien mit zweistelligen Downloadzahlen, weder bei Xenova
  /// noch bei onnx-community.
  ///
  /// **Kein Zwischenspeicher für die Aufmerksamkeit.** Anders als beim
  /// Beschreibungsmodell wird hier der Decoder OHNE `past_key_values`
  /// benutzt, also bei jedem Wort die ganze bisherige Folge neu gerechnet.
  /// Zwei Gründe, beide gemessen:
  ///
  ///  * Der zusammengeführte Decoder (`decoder_model_merged_quantized`)
  ///    lässt sich im ersten Schritt gar nicht ausführen – die
  ///    Kreuz-Aufmerksamkeit stolpert über den leeren Cache
  ///    (`encoder_attn/Reshape_4`, „dimension with value zero"). Das gilt
  ///    für leere wie für volllange Nulltensoren.
  ///  * Gebraucht werden hier Bildunterschriften und Suchbegriffe, also
  ///    eine Handvoll Wörter. Ein realer Lauf braucht dafür 0,03–0,05 s
  ///    pro Satz. Der Cache würde Rechenzeit sparen, die es nicht zu
  ///    sparen gibt, und dafür eine dritte Modelldatei und 24 Tensoren
  ///    Buchführung je Schritt kosten.
  static const translationEnDe = ModelCatalogEntry(
    id: 'translation_en_de',
    sourceUrl: 'https://huggingface.co/Xenova/opus-mt-en-de',
    files: [
      ModelFile(
        'translate_en_de_encoder.onnx',
        'https://huggingface.co/Xenova/opus-mt-en-de/resolve/main/onnx/encoder_model_quantized.onnx',
        '15834b45fabd2dfb8c6c029b3ca3e7289aeefd90ece798ce42bcf548d1bd3b8d',
      ),
      ModelFile(
        'translate_en_de_decoder.onnx',
        'https://huggingface.co/Xenova/opus-mt-en-de/resolve/main/onnx/decoder_model_quantized.onnx',
        '75ef79aa9bde9e3dce9ca584c29507be5f464973f6c600c89ff419bc8de29ebc',
      ),
      _uebersetzungsVokabular,
    ],
  );

  /// Deutsch → Englisch, für Suchanfragen und das Tag-Vokabular.
  ///
  /// Der CLIP-Text-Encoder versteht nur Englisch. Das Tag-Vokabular
  /// (`defaultAiTagVocabulary`) ist aber durchgehend deutsch – „Sonnen-
  /// untergang", „Geburtstagstorte" – und wurde bisher unübersetzt gegen
  /// einen englischen Encoder gerechnet. Diese Richtung schliesst die
  /// Lücke: Ein realer Lauf übersetzt genau in die Begriffe, die CLIP
  /// erwartet (Sunset, Birthday cake, Screenshot, Playground).
  static const translationDeEn = ModelCatalogEntry(
    id: 'translation_de_en',
    sourceUrl: 'https://huggingface.co/Xenova/opus-mt-de-en',
    files: [
      ModelFile(
        'translate_de_en_encoder.onnx',
        'https://huggingface.co/Xenova/opus-mt-de-en/resolve/main/onnx/encoder_model_quantized.onnx',
        '4cedda8f8c89b72a42b3c6cd1e7a27f2de24457093e3bf80cb3e46829641fcd8',
      ),
      ModelFile(
        'translate_de_en_decoder.onnx',
        'https://huggingface.co/Xenova/opus-mt-de-en/resolve/main/onnx/decoder_model_quantized.onnx',
        'e44c1c4b50e8f51e49d4d5e54a9af1550dc74763d4023644a38af62611e6efc9',
      ),
      _uebersetzungsVokabular,
    ],
  );

  /// LaMa (Large Mask Inpainting), fp32 – füllt eine markierte Stelle aus
  /// der Umgebung neu auf, für die Objektentfernung im Bildeditor.
  ///
  /// **Fest auf 512×512.** Der Export nimmt `image` [1,3,512,512] in 0..1
  /// und `mask` [1,1,512,512] entgegen und liefert `output` in **0..255** –
  /// nachgemessen, nicht angenommen. Weil die Grösse fest ist, arbeitet
  /// [InpaintingService] auf einem Ausschnitt um die markierte Stelle.
  ///
  /// Mit 208 MB das grösste Modell im Katalog und das einzige, das NICHT
  /// quantisiert vorliegt; eine quantisierte Fassung dieses Exports gibt es
  /// beim selben Anbieter nicht.
  static const inpainting = ModelCatalogEntry(
    id: 'inpainting_lama',
    sourceUrl: 'https://huggingface.co/Carve/LaMa-ONNX',
    files: [
      ModelFile(
        'lama_fp32.onnx',
        'https://huggingface.co/Carve/LaMa-ONNX/resolve/main/lama_fp32.onnx',
        '1faef5301d78db7dda502fe59966957ec4b79dd64e16f03ed96913c7a4eb68d6',
      ),
    ],
  );

  static const all = [
    faceDetection,
    faceRecognition,
    clip,
    segmentation,
    captioningFlorence,
    eyeState,
    neuralRestore,
    inpainting,
    translationEnDe,
    translationDeEn,
  ];
}
