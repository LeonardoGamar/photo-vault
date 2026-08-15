import 'dart:async';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../services/ai_tagging_service.dart';
import '../services/backup_service.dart';
import '../services/blur_detection.dart';
import '../services/captioning_service.dart';
import '../services/clip_service.dart';
import '../services/embedding_codec.dart';
import '../services/eye_state_service.dart';
import '../services/face_engine_service.dart';
import '../services/geo_data_download_service.dart';
import '../services/import_service.dart';
import '../services/library_location.dart';
import '../services/model_catalog.dart';
import '../services/model_download_service.dart';
import '../services/native_image_converter.dart';
import '../services/restore_queue_service.dart';
import '../services/restore_service.dart';
import '../services/reverse_geocoder.dart';
import '../services/segmentation_service.dart';
import '../services/storage_paths.dart';
import '../services/vault_crypto.dart';
import '../services/xmp_writer.dart';

/// Fortschritt der Hintergrundanalyse (siehe
/// [LibraryState.starteHintergrundanalyse]).
class AnalyseFortschritt {
  final String stufe;
  final int stufeNummer;
  final int stufenGesamt;
  final int erledigt;
  final int gesamt;
  const AnalyseFortschritt({
    required this.stufe,
    required this.stufeNummer,
    required this.stufenGesamt,
    required this.erledigt,
    required this.gesamt,
  });
}

class ImportProgress {
  final int done;
  final int total;
  final String? currentFile;

  /// Gesetzt, sobald diese Fortschritts-Meldung eine tatsächlich neu
  /// importierte Datei betrifft (nicht bei Duplikaten/Fehlern) – für Aufrufer
  /// wie [ImportProgressSheet], die nach dem Import direkt in den
  /// Sichtungs-Modus (Culling) springen wollen, ohne die importierten Fotos
  /// erneut aus der DB abfragen zu müssen.
  final String? assetId;
  ImportProgress(this.done, this.total, {this.currentFile, this.assetId});
}

/// Reine Top-Level-Funktion für `compute()` (siehe [LibraryState._decodeAsset]
/// – dasselbe Muster wie `decodeAndResizeThumbnail` in `import_service.dart`).
/// Das Decodieren einer vollen JPEG/HEIC-Vorschau ist für große Fotos die mit
/// Abstand teuerste Einzeloperation vor Gesichtserkennung/CLIP-Einbettung
/// (oft 100+ ms) – lief bisher synchron auf dem Haupt-Isolate und blockierte
/// damit beim Import oder Backfill vieler Fotos hintereinander spürbar die
/// UI. Gibt `null` zurück, wenn die Bytes nicht dekodierbar sind (z.B.
/// beschädigte Datei).
img.Image? decodeImageBytes(Uint8List bytes) {
  try {
    return img.decodeImage(bytes);
  } catch (_) {
    return null;
  }
}

/// Zentraler App-Zustand: hält Datenbank- und Service-Instanzen bereit und
/// bündelt zusammengesetzte Abläufe (Import inkl. Gesichtserkennung +
/// CLIP-Embedding). Alle KI-Modelle sind quelloffen und laufen komplett
/// lokal (siehe ModelCatalog) – ähnlich wie digiKam lädt die App sie bei
/// Bedarf von offiziellen Open-Source-Quellen herunter, statt sie
/// mitzuliefern oder auf proprietäre Betriebssystem-APIs zu setzen.
class LibraryState extends ChangeNotifier {
  late final AppDatabase db;
  late final StoragePaths paths;
  late final ImportService importService;
  late final BackupService backupService;
  late final ModelDownloadService modelDownloadService;
  late final GeoDataDownloadService geoDataDownloadService;
  late final RestoreQueueService restoreQueue;

  ClipService? clipService;
  AiTaggingService? aiTaggingService;
  FaceEngineService? faceEngine;
  EyeStateService? eyeStateService;
  SegmentationService? segmentationService;
  CaptioningService? captioningService;
  ReverseGeocoder? geocoder;
  bool _ready = false;
  bool get isReady => _ready;

  // Cache für AppDatabase.allEmbeddings() (KI-Suche, Ähnliche Fotos,
  // Duplikatsuche) – bei einer großen Bibliothek ein potenziell sehr großes
  // Ergebnis (mehrere hundert MB an CLIP-Vektoren), das bisher bei JEDEM
  // Öffnen einer dieser drei Ansichten neu aus der DB geladen wurde. Statt
  // eines aktiv nachgeführten (Timer/Stream-basierten) Caches – der auch bei
  // völlig unrelated Mutationen wie einem einzelnen Favoriten-Toggle ständig
  // im Hintergrund neu laden würde – wird hier nur EINMALIG geladen und beim
  // nächsten Zugriff über AppDatabase.embeddingsGeneration (siehe dort)
  // günstig geprüft, ob sich seitdem überhaupt etwas Relevantes geändert hat.
  Map<String, Float32List>? _embeddingsCache;
  int? _embeddingsCacheGeneration;

  Future<Map<String, Float32List>> cachedEmbeddings() async {
    if (_embeddingsCache != null && _embeddingsCacheGeneration == db.embeddingsGeneration) {
      return _embeddingsCache!;
    }
    final result = await db.allEmbeddings();
    _embeddingsCache = result;
    _embeddingsCacheGeneration = db.embeddingsGeneration;
    return result;
  }
  Timer? _autoBackupTimer;
  bool _autoBackupRunning = false;
  Timer? _trashPurgeTimer;
  bool _trashPurgeRunning = false;

  /// Schwelle für "Ähnliche mit auswählen" (Personen-Tab) – zentral hier
  /// statt lokal im Screen gehalten, damit sie auch im "Werkzeuge"-Bereich
  /// eingestellt werden kann. 0.363 ist der von OpenCV Zoo für SFace
  /// dokumentierte Kosinus-Ähnlichkeits-Schwellwert für "gleiche Person"
  /// (gilt seit der Landmark-Ausrichtung vor dem Embedding, siehe
  /// FaceEngineService.alignFace – mit dem vorherigen reinen
  /// Bounding-Box-Crop lagen die Werte auf einer anderen, unkalibrierten
  /// Skala).
  double faceSimilarityThreshold = 0.363;

  void setFaceSimilarityThreshold(double value) {
    faceSimilarityThreshold = value;
    notifyListeners();
  }

  String? _modelsDir;
  String get modelsDir => _modelsDir!;

  /// Einmalige Anfrage von "Foto in der Timeline anzeigen" (Kontextmenü der
  /// Vollbildansicht): [HomeShell] wechselt beim nächsten Build auf den
  /// Timeline-Tab und reicht die ID an [MonthGroupedAssetGrid] weiter, das
  /// dorthin scrollt und das Foto kurz hervorhebt. Absichtlich ohne eigenen
  /// `notifyListeners()`-Aufruf beim Zurücksetzen (siehe
  /// [clearTimelineHighlightRequest]) – der einmalige Verbrauch reicht, ein
  /// zusätzlicher Rebuild dafür wäre unnötig.
  String? _timelineHighlightAssetId;
  String? get timelineHighlightAssetId => _timelineHighlightAssetId;

  void requestTimelineHighlight(String assetId) {
    _timelineHighlightAssetId = assetId;
    notifyListeners();
  }

  void clearTimelineHighlightRequest() {
    _timelineHighlightAssetId = null;
  }

  Future<void> initialize() async {
    db = await AppDatabase.open();
    paths = await StoragePaths.instance();
    importService = ImportService(db, paths);
    backupService = BackupService(db, paths);
    restoreQueue = RestoreQueueService(db, paths);

    final supportDir = await getApplicationSupportDirectory();
    _modelsDir = p.join(supportDir.path, 'PhotoVault', 'models');
    await Directory(_modelsDir!).create(recursive: true);
    modelDownloadService = ModelDownloadService(_modelsDir!);

    final geoDataDir = p.join(supportDir.path, 'PhotoVault', 'geodata');
    await Directory(geoDataDir).create(recursive: true);
    geoDataDownloadService = GeoDataDownloadService(geoDataDir);

    await _loadModelsIfPresent();
    await _loadGeoDataIfPresent();
    await clearDecryptCache();

    // Crash-Safety: ein Restaurierungs-Auftrag, der beim letzten Beenden
    // noch "running" war (App wurde mitten in der Verarbeitung beendet/ist
    // abgestürzt), zurück auf "queued" setzen und die Warteschlange dann
    // fortsetzen – siehe AppDatabase.resetStuckRunningRestoreJobs.
    await db.resetStuckRunningRestoreJobs();
    unawaited(restoreQueue.resume());

    // Automatisches Backup läuft nur, während die App offen ist (kein
    // Hintergrunddienst) – einmal direkt beim Start prüfen (falls das
    // Intervall während der App war geschlossen abgelaufen ist) und danach
    // regelmäßig, damit es auch bei einer lange offenen Sitzung nicht erst
    // beim nächsten Neustart nachgeholt wird.
    unawaited(runAutoBackupIfDue());
    _autoBackupTimer = Timer.periodic(const Duration(minutes: 30), (_) => runAutoBackupIfDue());

    // Automatischer Papierkorb-Ablauf – aus demselben Grund (kein
    // Hintergrunddienst) ebenfalls einmal direkt beim Start geprüft und
    // danach regelmäßig. Ein gröberes Intervall als beim Backup reicht hier,
    // da "nach N Tagen" ohnehin keine Sekundengenauigkeit braucht.
    unawaited(purgeExpiredTrashIfDue());
    _trashPurgeTimer = Timer.periodic(const Duration(hours: 6), (_) => purgeExpiredTrashIfDue());

    _ready = true;
    notifyListeners();

    // Eine beim letzten Beenden unfertige Hintergrundanalyse fortsetzen.
    // Sie ist nach einem Import mit mehreren tausend Fotos stundenlang
    // unterwegs – die App zwischendurch zu schließen ist der Normalfall,
    // und ohne diesen Aufruf bliebe die Bibliothek halb ausgewertet, bis
    // der nächste Import läuft oder jemand den Knopf in den Werkzeugen
    // findet (Audit-Fund). Ein eigener Fortschrittsstand ist dafür nicht
    // nötig: Jede Stufe ermittelt selbst, welche Fotos ihr noch fehlen,
    // und ist damit gefahrlos wiederholbar. Erst NACH `_ready`, damit der
    // Start der Oberfläche nicht darauf wartet.
    if (await db.autoAnalyzeAfterImportEnabled()) {
      unawaited(starteHintergrundanalyse());
    }
  }

  /// Prüft, welche Modelldateien bereits im models-Ordner liegen, und lädt
  /// die entsprechenden Engines. Wird auch nach einem Download in den
  /// Einstellungen erneut aufgerufen.
  Future<void> _loadModelsIfPresent() async {
    if (FaceEngineService.isDetectionAvailable(_modelsDir!)) {
      try {
        faceEngine = await FaceEngineService.load(_modelsDir!);
      } catch (e) {
        debugPrint('Gesichts-Engine konnte nicht geladen werden: $e');
        faceEngine = null;
      }
    } else {
      faceEngine = null;
    }

    if (EyeStateService.isAvailable(_modelsDir!)) {
      try {
        eyeStateService = await EyeStateService.load(_modelsDir!);
      } catch (e) {
        debugPrint('Augen-Zustands-Modell konnte nicht geladen werden: $e');
        eyeStateService = null;
      }
    } else {
      eyeStateService = null;
    }

    if (ClipService.isAvailable(_modelsDir!)) {
      try {
        clipService = await ClipService.load(_modelsDir!);
        aiTaggingService = AiTaggingService(clipService!);
      } catch (e) {
        debugPrint('CLIP-Modell konnte nicht geladen werden: $e');
        clipService = null;
        aiTaggingService = null;
      }
    } else {
      clipService = null;
      aiTaggingService = null;
    }

    if (SegmentationService.isAvailable(_modelsDir!)) {
      try {
        segmentationService = await SegmentationService.load(_modelsDir!);
      } catch (e) {
        debugPrint('Segmentierungs-Modell konnte nicht geladen werden: $e');
        segmentationService = null;
      }
    } else {
      segmentationService = null;
    }

    if (CaptioningService.isAvailable(_modelsDir!)) {
      try {
        captioningService = await CaptioningService.load(_modelsDir!);
      } catch (e) {
        debugPrint('Bildbeschreibungs-Modell konnte nicht geladen werden: $e');
        captioningService = null;
      }
    } else {
      captioningService = null;
    }

    // Während ein Auftrag läuft, wird restoreService bewusst NICHT ersetzt
    // (siehe reloadModels()) – sonst würde das Feld auf eine neue,
    // ungenutzte Sitzung zeigen, während der laufende Auftrag noch seine
    // eigene, dann vom Feld losgelöste Referenz auf die alte Sitzung
    // benutzt, die anschließend nie disposed würde (Ressourcen-Leck). Beim
    // nächsten Aufruf (nach Abschluss des Auftrags) wird ganz normal neu
    // geladen.
    if (!restoreQueue.isProcessing) {
      if (RestoreService.isAvailable(_modelsDir!)) {
        try {
          restoreQueue.restoreService = await RestoreService.load(_modelsDir!);
        } catch (e) {
          debugPrint('KI-Restaurierungs-Modell konnte nicht geladen werden: $e');
          restoreQueue.restoreService = null;
        }
      } else {
        restoreQueue.restoreService = null;
      }
    }
  }

  Future<void> reloadModels() async {
    await faceEngine?.dispose();
    await eyeStateService?.dispose();
    await clipService?.dispose();
    await segmentationService?.dispose();
    await captioningService?.dispose();
    // Ein Restaurierungs-Auftrag läuft oft mehrere Minuten (anders als die
    // kurzen SAM/CLIP-Aufrufe der übrigen Modelle) – die ONNX-Sitzung
    // während eines laufenden Auftrags zu disposen würde die Inferenz
    // mitten im Lauf zum Absturz bringen. In diesem (seltenen) Fall bleibt
    // die alte Sitzung weiter in Benutzung; ein erneutes Herunterladen des
    // Restaurierungs-Modells wirkt dann erst beim nächsten Aufruf von
    // reloadModels(), nicht sofort.
    if (!restoreQueue.isProcessing) {
      await restoreQueue.restoreService?.dispose();
    }
    await _loadModelsIfPresent();
    notifyListeners();
    unawaited(restoreQueue.resume());
  }

  /// Lädt den GeoNames-Datensatz (falls bereits heruntergeladen) in den
  /// Speicher – das Parsen der ca. 150.000 Städte kostet ein-, zweistellig
  /// viele hundert Millisekunden, läuft deshalb einmalig hier statt bei jeder
  /// einzelnen Umkehr-Geokodierung erneut.
  Future<void> _loadGeoDataIfPresent() async {
    if (!geoDataDownloadService.isInstalled) {
      geocoder = null;
      return;
    }
    try {
      geocoder = await ReverseGeocoder.loadFromFiles(
        citiesFile: geoDataDownloadService.citiesFile,
        admin1File: geoDataDownloadService.admin1File,
        countryFile: geoDataDownloadService.countryFile,
      );
    } catch (e) {
      debugPrint('GeoNames-Datensatz konnte nicht geladen werden: $e');
      geocoder = null;
    }
  }

  /// Wird nach einem Download/Löschen des GeoNames-Datensatzes in den
  /// Einstellungen aufgerufen.
  Future<void> reloadGeoData() async {
    await _loadGeoDataIfPresent();
    notifyListeners();
  }

  bool get clipAvailable => clipService != null;
  bool get faceDetectionAvailable => faceEngine != null;
  bool get faceRecognitionAvailable => faceEngine?.canEmbed ?? false;
  bool get segmentationAvailable => segmentationService != null;
  bool get captioningAvailable => captioningService != null;
  bool get geoDataAvailable => geocoder != null;

  bool isModelInstalled(ModelCatalogEntry entry) =>
      modelDownloadService.isEntryInstalled(entry);

  /// Importiert eine Liste von Dateipfaden und liefert währenddessen
  /// Fortschritts-Updates. Führt pro Bild zusätzlich Gesichtserkennung
  /// (falls Modell vorhanden), CLIP-Embedding (falls Modell vorhanden) und
  /// den Live-Photo-Abgleich (Foto <-> Video mit gleichem Dateinamen) aus.
  Stream<ImportProgress> importFiles(List<String> filePaths) async* {
    var done = 0;
    yield ImportProgress(0, filePaths.length);
    for (final filePath in filePaths) {
      final result = await importService.importFile(filePath);
      if (result.outcome == ImportOutcome.imported && result.assetId != null) {
        await _postProcessNewAsset(result.assetId!);
      }
      done++;
      yield ImportProgress(
        done,
        filePaths.length,
        currentFile: p.basename(filePath),
        assetId: result.outcome == ImportOutcome.imported ? result.assetId : null,
      );
    }

    // Erst NACH dem Import: die rechenintensiven Auswertungen laufen im
    // Hintergrund nach, statt jeden einzelnen Import auszubremsen. Bewusst
    // nicht abgewartet – der Import gilt als fertig, sobald die Dateien in
    // der Bibliothek sind.
    if (await db.autoAnalyzeAfterImportEnabled()) {
      unawaited(starteHintergrundanalyse());
    }
  }

  /// Datei, die tatsächlich dekodiert werden kann: die konvertierte
  /// Vorschau, falls das Originalformat (HEIC/DNG & Co.) von Flutter bzw.
  /// dem `image`-Paket nicht direkt gelesen werden kann – sonst das
  /// Original selbst.
  File _decodableFile(AssetData asset) =>
      paths.absolute(asset.previewRelativePath ?? asset.relativePath);

  /// Lädt und dekodiert das Bild eines Assets einmalig – wird sowohl für
  /// die Gesichtserkennung als auch für die CLIP-Einbettung wiederverwendet
  /// (siehe [_postProcessNewAsset]), statt dieselbe JPEG/HEIC-Vorschau für
  /// jeden Verarbeitungsschritt erneut von der Platte zu lesen und zu
  /// dekodieren. Gibt `null` zurück, wenn die Datei fehlt oder nicht
  /// dekodierbar ist (z.B. beschädigt).
  Future<img.Image?> _decodeAsset(AssetData asset) async {
    try {
      return await compute(decodeImageBytes, await _decodableFile(asset).readAsBytes());
    } catch (_) {
      return null;
    }
  }

  static const _livePhotoImageExts = {'.heic', '.heif', '.jpg', '.jpeg'};
  static const _livePhotoVideoExt = '.mov';

  /// Prüft, ob es zu diesem frisch importierten Asset schon einen
  /// unverknüpften Partner mit demselben Dateinamen (ohne Endung) gibt –
  /// z.B. das HEIC-Standbild zu einem bereits importierten MOV oder
  /// umgekehrt – und verknüpft die beiden als Live Photo.
  Future<void> _tryLinkLivePhoto(AssetData asset) async {
    final ext = p.extension(asset.originalFileName).toLowerCase();
    final isImage = asset.type == 'IMAGE';
    if (isImage && !_livePhotoImageExts.contains(ext)) return;
    if (!isImage && ext != _livePhotoVideoExt) return;

    final stem = p.basenameWithoutExtension(asset.originalFileName).toLowerCase();
    final candidates = await db.unlinkedAssetsOfType(isImage ? 'VIDEO' : 'IMAGE');
    for (final candidate in candidates) {
      if (candidate.id == asset.id) continue;
      final candidateExt = p.extension(candidate.originalFileName).toLowerCase();
      if (isImage && candidateExt != _livePhotoVideoExt) continue;
      if (!isImage && !_livePhotoImageExts.contains(candidateExt)) continue;
      final candidateStem = p.basenameWithoutExtension(candidate.originalFileName).toLowerCase();
      if (candidateStem == stem) {
        await db.linkAssets(asset.id, candidate.id);
        return;
      }
    }
  }

  /// Wendet ein evtl. für die erkannte Kamera hinterlegtes Preset an
  /// (Zielalbum, Tags, automatisches Favorisieren) – siehe
  /// CameraPresetsScreen. Für Videos (keine EXIF-Kamera) und Fotos ohne
  /// passendes Preset ein günstiges No-Op (siehe AppDatabase.cameraPresetFor).
  /// Öffentlich (statt privat) nur wegen [visibleForTesting]: ein Test über
  /// den vollen Importpfad bräuchte eine echte EXIF-tragende JPEG-Datei
  /// (siehe camera_metadata_test.dart, das aus demselben Grund
  /// setCameraMetadata statt eines echten Imports nutzt) – hier lässt sich
  /// die Anwendungslogik stattdessen direkt mit einer bereits bekannten
  /// Kamera testen.
  @visibleForTesting
  Future<void> applyCameraPreset(
    String assetId, {
    required String? cameraMake,
    required String? cameraModel,
  }) async {
    final preset = await db.cameraPresetFor(cameraMake, cameraModel);
    if (preset == null) return;
    if (preset.targetAlbumId != null) {
      await db.addAssetsToAlbum(preset.targetAlbumId!, [assetId]);
    }
    if (preset.autoFavorite) {
      await db.setFavorite(assetId, true);
    }
    final tagIds = await db.tagIdsForCameraPreset(preset.id);
    for (final tagId in tagIds) {
      await db.tagAssetById(assetId, tagId);
    }
  }

  // --- Hintergrundanalyse nach dem Import -------------------------------

  /// Beschreibt, was die Hintergrundanalyse gerade tut – für den Hinweis in
  /// [HomeShell].
  AnalyseFortschritt? _analyse;
  AnalyseFortschritt? get analyse => _analyse;
  bool get analyseLaeuft => _analyse != null;
  bool _analyseAbbruch = false;

  /// Arbeitet die rechenintensiven Auswertungen nacheinander ab – jede
  /// überspringt selbst die Fotos, die sie schon hat, und tut nichts, wenn
  /// ihr Modell fehlt. Deshalb ist ein erneuter Aufruf gefahrlos.
  ///
  /// Reihenfolge nach steigendem Aufwand: Zuerst das, was schnell fertig
  /// ist und sofort nutzbar, zuletzt die Bildbeschreibung – die erzeugt
  /// ihren Satz Wort für Wort und ist damit mit Abstand die teuerste Stufe.
  ///
  /// Unschärfe, Gesichter und CLIP brauchen DASSELBE dekodierte Bild und
  /// laufen deshalb als ein gemeinsamer Durchlauf ([_bildinhaltsAnalyse]),
  /// der je Foto nur einmal dekodiert. Vorher ging jede Stufe die
  /// Bibliothek für sich durch und dekodierte erneut – bei gemessenen
  /// ~85 ms je Dekodiervorgang war das der größte vermeidbare Posten
  /// (Audit-Fund).
  ///
  /// Die Bildbeschreibung bleibt bewusst eine eigene, letzte Stufe, obwohl
  /// sie dasselbe Bild bräuchte: Sie ist um ein Vielfaches teurer als die
  /// anderen drei zusammen. Zöge man sie in den gemeinsamen Durchlauf,
  /// zahlte jedes einzelne Foto sofort ihren vollen Preis, und ein Abbruch
  /// nach der halben Zeit ließe die halbe Bibliothek gänzlich unausgewertet
  /// zurück – statt, wie jetzt, vollständig bis auf die Bildbeschreibung.
  /// Die Texterkennung wiederum arbeitet nativ auf der Datei und hat vom
  /// dekodierten Bild ohnehin nichts.
  Future<void> starteHintergrundanalyse() async {
    if (_analyse != null) return; // läuft bereits
    _analyseAbbruch = false;

    final stufen = <({String name, Stream<ImportProgress> Function() lauf})>[
      (name: 'Bildanalyse', lauf: () => _bildinhaltsAnalyse()),
      (name: 'Texterkennung', lauf: () => backfillOcrText()),
      // Kein eigener CLIP-Schritt mehr – die Embeddings entstehen bereits in
      // der Bildanalyse. [backfillClipEmbeddings] bleibt für den manuellen
      // Aufruf in den Werkzeugen erhalten.
      (name: 'Schlagwörter', lauf: () => backfillAiTags(onlyUntagged: true)),
      (name: 'Bildbeschreibung', lauf: () => backfillCaptions()),
    ];

    try {
      for (var i = 0; i < stufen.length; i++) {
        if (_analyseAbbruch) break;
        final stufe = stufen[i];
        // Jede Stufe für sich absichern: Wirft eine (z.B. weil ein einzelnes
        // Foto beschädigt ist oder ein Modell fehlschlägt), sollen die
        // FOLGENDEN Stufen trotzdem noch laufen. Vorher umschloss ein
        // einziges try/catch die ganze Schleife – ein Fehler in Stufe 1 ließ
        // die Stufen 2-6 stillschweigend ausfallen (Audit-Fund).
        try {
          await for (final p in stufe.lauf()) {
            if (_analyseAbbruch) break;
            _analyse = AnalyseFortschritt(
              stufe: stufe.name,
              stufeNummer: i + 1,
              stufenGesamt: stufen.length,
              erledigt: p.done,
              gesamt: p.total,
            );
            notifyListeners();
          }
        } catch (e) {
          debugPrint('Analysestufe "${stufe.name}" fehlgeschlagen, weiter mit der nächsten: $e');
        }
      }
    } finally {
      _analyse = null;
      _analyseAbbruch = false;
      notifyListeners();
    }
  }

  /// Bricht nach der laufenden Datei ab – kein harter Abbruch mitten in
  /// einer Modell-Inferenz.
  void brichHintergrundanalyseAb() {
    if (_analyse == null) return;
    _analyseAbbruch = true;
  }

  /// Nachbereitung direkt beim Import – bewusst NUR ressourcenschonende
  /// Schritte: reine Datenbankarbeit und ein Nachschlagen im bereits
  /// geladenen Ortsverzeichnis. Kein Dekodieren, keine Modell-Inferenz.
  ///
  /// Alles Rechenintensive (Gesichter, Unschärfe, Texterkennung, CLIP,
  /// Bildbeschreibung) läuft NACH dem Import als Hintergrundaufgabe, siehe
  /// [starteHintergrundanalyse]. Vorher lief es hier inline und machte den
  /// Import bei mehreren tausend Fotos unzumutbar langsam: fünf schwere
  /// Durchläufe je Foto, nacheinander.
  Future<void> _postProcessNewAsset(String assetId) async {
    final asset = await db.assetById(assetId);
    if (asset == null) return;

    await _tryLinkLivePhoto(asset);
    await applyCameraPreset(asset.id, cameraMake: asset.cameraMake, cameraModel: asset.cameraModel);

    if (asset.type != 'IMAGE') return;

    // Ortsauflösung bleibt hier: reines Nachschlagen im bereits im
    // Speicher liegenden GeoNames-Verzeichnis, kein Bild wird angefasst.
    if (geocoder != null && asset.latitude != null && asset.longitude != null) {
      final result = geocoder!.lookup(asset.latitude!, asset.longitude!);
      if (result != null) {
        await db.setLocationNames(asset.id, country: result.country, state: result.state, city: result.city);
      }
    }
  }


  /// Führt die Gesichtserkennung für ein Asset aus, dessen Bild bereits
  /// dekodiert vorliegt (siehe [_postProcessNewAsset], wo dasselbe Bild auch
  /// für die CLIP-Einbettung dekodiert wird), und markiert es als gescannt.
  ///
  /// [decoded] darf `null` sein (z.B. wenn die Datei beschädigt ist) – dann
  /// werden schlicht keine Gesichter gefunden, das Asset aber trotzdem als
  /// gescannt markiert (kein endloses Wiederholen bei kaputten Dateien).
  ///
  /// [deleteExistingUnassigned] löscht vorher alle noch nicht einer Person
  /// zugeordneten Gesichter dieses Assets (relevant beim "alle Fotos erneut
  /// scannen", damit sich Erkennungen nicht endlos aufsummieren) – bereits
  /// manuell zugeordnete Gesichter bleiben davon unberührt.
  Future<void> _scanFacesForDecodedAsset(
    AssetData asset,
    img.Image? decoded, {
    required bool deleteExistingUnassigned,
  }) async {
    final engine = faceEngine;
    if (engine == null) return;

    if (deleteExistingUnassigned) {
      await db.deleteUnassignedFacesForAsset(asset.id);
    }

    try {
      if (decoded != null) {
        final boxes = await engine.detectFaces(decoded);
        for (final box in boxes) {
          final faceId = const Uuid().v4();
          final cropFile = paths.absolute(paths.faceRelativePath(faceId));
          final croppedThumb = FaceEngineService.cropFaceImage(decoded, box);
          await FaceEngineService.saveFaceCrop(croppedThumb, cropFile);

          Float32List? embedding;
          if (engine.canEmbed) {
            embedding = await engine.embedFace(decoded, box);
          }

          // Nutzt dieselben Landmarks weiter, die YuNet für diese Box schon
          // geliefert hat (siehe FaceEngineService.detectFaces) – keine
          // erneute Erkennung nötig, nur ein kleiner Zusatz-Klassifikator
          // auf zwei winzigen Augen-Ausschnitten.
          double? eyeOpenScore;
          if (eyeStateService != null) {
            try {
              eyeOpenScore = await eyeStateService!.eyeOpenScore(decoded, box);
            } catch (e) {
              debugPrint('Augen-Zustand-Erkennung fehlgeschlagen für ${asset.originalFileName}: $e');
            }
          }

          await db.insertFace(FacesCompanion.insert(
            id: faceId,
            assetId: asset.id,
            boxX: box.x,
            boxY: box.y,
            boxW: box.width,
            boxH: box.height,
            cropRelativePath: Value(paths.faceRelativePath(faceId)),
            embedding: embedding != null ? Value(blobFromEmbeddingFloats(embedding)) : const Value.absent(),
            eyeOpenScore: eyeOpenScore != null ? Value(eyeOpenScore) : const Value.absent(),
          ));
        }
      }
      await db.markFacesScanned([asset.id]);
    } catch (e) {
      debugPrint('Gesichtserkennung fehlgeschlagen für ${asset.originalFileName}: $e');
    }
  }

  /// Dekodiert das Bild eines Assets und führt die Gesichtserkennung aus –
  /// für Aufrufer, die (anders als [_postProcessNewAsset]) noch kein
  /// dekodiertes Bild vorliegen haben (manueller Rescan über die Werkzeuge).
  Future<void> _scanFacesForAsset(AssetData asset, {required bool deleteExistingUnassigned}) async {
    if (faceEngine == null) return;
    final decoded = await _decodeAsset(asset);
    await _scanFacesForDecodedAsset(asset, decoded, deleteExistingUnassigned: deleteExistingUnassigned);
  }

  /// Manueller (Re-)Scan der Gesichtserkennung, z.B. nachdem das YuNet-Modell
  /// erst nachträglich installiert wurde oder ein Erkennungs-Bug (wie die
  /// BGR/RGB-Verwechslung) behoben wurde.
  ///
  /// [onlyNewPhotos] = true: nur Fotos, die noch nie gescannt wurden.
  /// [onlyNewPhotos] = false: ALLE Fotos erneut scannen (dauert entsprechend
  /// länger bei großen Bibliotheken).
  Stream<ImportProgress> rescanFaces({required bool onlyNewPhotos}) async* {
    if (faceEngine == null) {
      yield ImportProgress(0, 0);
      return;
    }
    final assets = await db.assetsForFaceScan(onlyNew: onlyNewPhotos);
    var done = 0;
    yield ImportProgress(0, assets.length);
    for (final asset in assets) {
      await _scanFacesForAsset(asset, deleteExistingUnassigned: !onlyNewPhotos);
      done++;
      yield ImportProgress(done, assets.length, currentFile: asset.originalFileName);
    }
  }

  /// Manuelles (Re-)Erzeugen von Thumbnails/Vorschauen, z.B. nachdem die
  /// native Bildkonvertierung für HEIC/DNG oder die Video-Thumbnail-
  /// Erzeugung erst nachträglich eingerichtet wurde. [onlyMissing] = true
  /// verarbeitet nur Assets ohne Thumbnail.
  Stream<ImportProgress> regenerateThumbnails({required bool onlyMissing}) async* {
    final assets = await db.assetsForThumbnailRegen(onlyMissing: onlyMissing);
    var done = 0;
    yield ImportProgress(0, assets.length);
    for (final asset in assets) {
      try {
        final result = asset.type == 'IMAGE'
            ? await importService.generateThumbnailAndPreview(
                paths.absolute(asset.relativePath),
                asset.id,
                p.extension(asset.originalFileName),
              )
            : await importService.generateVideoThumbnail(
                paths.absolute(asset.relativePath),
                asset.id,
              );
        if (result.hasThumbnail || result.durationSeconds != null) {
          await db.updateThumbnailInfo(
            asset.id,
            thumbnailRelativePath: result.thumbnailRelativePath,
            previewRelativePath: result.previewRelativePath,
            widthPx: result.width,
            heightPx: result.height,
            durationSeconds: result.durationSeconds,
          );
        }
      } catch (e) {
        debugPrint('Vorschau-Erzeugung fehlgeschlagen für ${asset.originalFileName}: $e');
      }
      done++;
      yield ImportProgress(done, assets.length, currentFile: asset.originalFileName);
    }
  }

  /// Rendert alle bereits entwickelten Fotos (siehe DevelopScreen) mit
  /// ihren gespeicherten Einstellungen neu – z.B. sinnvoll nach einer
  /// Änderung an der nativen Render-Logik selbst. Die Einstellungen bleiben
  /// dabei unverändert, nur das gerenderte Bild wird neu erzeugt.
  Stream<ImportProgress> redevelopAll() async* {
    final entries = await db.assetsWithDevelopSettings();
    var done = 0;
    yield ImportProgress(0, entries.length);
    for (final (asset, settings) in entries) {
      try {
        final adjustments = DevelopAdjustments(
          exposure: settings.exposure,
          temperature: settings.temperature,
          tint: settings.tint,
          contrast: settings.contrast,
          shadows: settings.shadows,
          sharpness: settings.sharpness,
          noiseReduction: settings.noiseReduction,
          lensCorrectionEnabled: settings.lensCorrectionEnabled,
        );
        final masks = await db.masksForAsset(asset.id);
        final bytes = await NativeImageConverter.developImage(
          paths.absolute(asset.relativePath),
          adjustments: adjustments,
          masks: [
            for (final mask in masks)
              MaskAdjustmentLayer(
                maskFilePath: paths.absolute(mask.maskRelativePath).path,
                adjustments: DevelopAdjustments(
                  exposure: mask.exposure,
                  temperature: mask.temperature,
                  tint: mask.tint,
                  contrast: mask.contrast,
                  shadows: mask.shadows,
                  sharpness: mask.sharpness,
                  noiseReduction: mask.noiseReduction,
                ),
              ),
          ],
          maxDimension: 4096,
          quality: 0.92,
        );
        if (bytes != null) {
          final developedRelativePath = paths.developedRelativePath(asset.id);
          final targetFile = paths.absolute(developedRelativePath);
          await targetFile.parent.create(recursive: true);
          await targetFile.writeAsBytes(bytes);
          await db.saveDevelopResult(
            asset.id,
            settings: DevelopSettingsCompanion.insert(
              assetId: asset.id,
              exposure: Value(settings.exposure),
              temperature: Value(settings.temperature),
              tint: Value(settings.tint),
              contrast: Value(settings.contrast),
              shadows: Value(settings.shadows),
              sharpness: Value(settings.sharpness),
              noiseReduction: Value(settings.noiseReduction),
              lensCorrectionEnabled: Value(settings.lensCorrectionEnabled),
              updatedAt: DateTime.now(),
            ),
            developedRelativePath: developedRelativePath,
          );
        }
      } catch (e) {
        debugPrint('Neu-Rendern fehlgeschlagen für ${asset.originalFileName}: $e');
      }
      done++;
      yield ImportProgress(done, entries.length, currentFile: asset.originalFileName);
    }
  }

  /// Prüft die komplette Bibliothek erneut auf Live-Photo-Paare – für
  /// Fotos/Videos, die bereits vor Einführung dieser Funktion importiert
  /// wurden.
  Stream<ImportProgress> relinkLivePhotos() async* {
    final images = await db.unlinkedAssetsOfType('IMAGE');
    var done = 0;
    yield ImportProgress(0, images.length);
    for (final asset in images) {
      await _tryLinkLivePhoto(asset);
      done++;
      yield ImportProgress(done, images.length, currentFile: asset.originalFileName);
    }
  }

  /// Liest GPS-Orte nachträglich aus Fotos ein, die vor Einführung dieser
  /// Funktion importiert wurden (siehe Werkzeuge → Orte). Fotos ohne
  /// EXIF-GPS-Daten bleiben unverändert – nur ein Fund führt zu einem
  /// DB-Update.
  Stream<ImportProgress> backfillLocations() async* {
    final assets = await db.assetsForLocationBackfill();
    var done = 0;
    yield ImportProgress(0, assets.length);
    for (final asset in assets) {
      final gps = await importService.readGpsLocation(paths.absolute(asset.relativePath));
      if (gps != null) {
        await db.setLocation(asset.id, gps.latitude, gps.longitude);
      }
      done++;
      yield ImportProgress(done, assets.length, currentFile: asset.originalFileName);
    }
  }

  /// Löst für Fotos mit bekanntem GPS-Ort, aber noch ohne Land/Bundesland/
  /// Stadt, die lokale/offline Umkehr-Geokodierung aus (siehe Werkzeuge →
  /// Ort) – z.B. für Fotos, die vor dem Herunterladen des GeoNames-
  /// Datensatzes importiert wurden. Braucht keinen Dateizugriff: Breiten-
  /// und Längengrad liegen bereits in der Datenbank.
  Stream<ImportProgress> backfillLocationNames() async* {
    final engine = geocoder;
    if (engine == null) {
      yield ImportProgress(0, 0);
      return;
    }
    final assets = await db.assetsForLocationNameBackfill();
    var done = 0;
    yield ImportProgress(0, assets.length);
    for (final asset in assets) {
      final result = engine.lookup(asset.latitude!, asset.longitude!);
      if (result != null) {
        await db.setLocationNames(asset.id, country: result.country, state: result.state, city: result.city);
      }
      done++;
      yield ImportProgress(done, assets.length, currentFile: asset.originalFileName);
    }
  }

  /// Liest Kamera-/Objektiv-Angaben nachträglich aus Fotos ein, die vor
  /// Einführung dieser Funktion importiert wurden (siehe Werkzeuge →
  /// Kamera). Fotos ohne entsprechende EXIF-Daten bleiben unverändert.
  Stream<ImportProgress> backfillCameraMetadata() async* {
    final assets = await db.assetsForCameraMetadataBackfill();
    var done = 0;
    yield ImportProgress(0, assets.length);
    for (final asset in assets) {
      final info = await importService.readCameraInfo(paths.absolute(asset.relativePath));
      if (!info.isEmpty) {
        await db.setCameraMetadata(asset.id, info);
        await applyCameraPreset(asset.id, cameraMake: info.make, cameraModel: info.model);
      }
      done++;
      yield ImportProgress(done, assets.length, currentFile: asset.originalFileName);
    }
  }

  /// Erkennt Text nachträglich für Fotos, die vor Einführung der OCR-Suche
  /// importiert wurden (siehe [_postProcessNewAsset], wo dasselbe seit
  /// diesem Feature automatisch bei jedem Import läuft).
  Stream<ImportProgress> backfillOcrText() async* {
    final assets = await db.assetsForOcrBackfill();
    var done = 0;
    yield ImportProgress(0, assets.length);
    for (final asset in assets) {
      // Pro Foto abgesichert: Ein einzelner Fehlschlag (beschädigte Datei,
      // Fehler im nativen Aufruf) darf nicht den ganzen Lauf abbrechen.
      try {
        final text = await NativeImageConverter.recognizeText(_decodableFile(asset));
        if (text != null) {
          await db.setOcrResult(asset.id, text);
        }
      } catch (e) {
        debugPrint('Texterkennung fehlgeschlagen für ${asset.originalFileName}: $e');
      }
      done++;
      yield ImportProgress(done, assets.length, currentFile: asset.originalFileName);
    }
  }

  /// Erzeugt KI-Bildbeschreibungen nachträglich für Fotos, die vor
  /// Installation des Modells importiert wurden (Captions entstehen sonst
  /// nur automatisch beim Import, siehe [_postProcessNewAsset]).
  Stream<ImportProgress> backfillCaptions() async* {
    final service = captioningService;
    if (service == null) {
      yield ImportProgress(0, 0);
      return;
    }
    final assets = await db.assetsForCaptionBackfill();
    var done = 0;
    yield ImportProgress(0, assets.length);
    for (final asset in assets) {
      try {
        final decoded = await _decodeAsset(asset);
        if (decoded == null) throw Exception('Bild konnte nicht dekodiert werden.');
        final caption = await service.generateCaption(decoded);
        await db.setAiCaption(asset.id, caption);
      } catch (e) {
        debugPrint('KI-Bildbeschreibung fehlgeschlagen für ${asset.originalFileName}: $e');
      }
      done++;
      yield ImportProgress(done, assets.length, currentFile: asset.originalFileName);
    }
  }

  /// Gemeinsamer Durchlauf für die drei Auswertungen, die dasselbe
  /// dekodierte Bild brauchen: Unschärfe, Gesichter und CLIP-Embedding.
  /// Jedes Foto wird EINMAL dekodiert (gemessen ~85 ms) statt bis zu
  /// dreimal – siehe [starteHintergrundanalyse].
  ///
  /// Je Foto wird nur nachgeholt, was tatsächlich fehlt, und nur, wenn das
  /// zugehörige Modell da ist. Ein Foto, dem keine der drei Auswertungen
  /// mehr fehlt, wird gar nicht erst dekodiert.
  ///
  /// Fehler bleiben pro Foto UND pro Auswertung eingegrenzt: Ein
  /// fehlschlagendes CLIP-Modell darf weder die Unschärfe desselben Fotos
  /// noch die folgenden Fotos verhindern.
  Stream<ImportProgress> _bildinhaltsAnalyse() async* {
    final kandidaten = await db.assetsForCombinedImageAnalysis();
    // Einmal festhalten: Die Modelle können zwischendurch nachgeladen
    // werden, der Durchlauf soll aber mit einem stabilen Stand arbeiten.
    final clip = clipService;
    final gesichter = faceEngine;
    var done = 0;
    yield ImportProgress(0, kandidaten.length);

    for (final k in kandidaten) {
      final asset = k.asset;
      final brauchtUnschaerfe = asset.sharpnessScore == null;
      final brauchtGesichter = !asset.facesScanned && gesichter != null;
      final brauchtEmbedding = !k.hatEmbedding && clip != null;

      if (brauchtUnschaerfe || brauchtGesichter || brauchtEmbedding) {
        final decoded = await _decodeAsset(asset);
        if (decoded != null) {
          if (brauchtUnschaerfe) {
            try {
              await db.setSharpnessScore(asset.id, await compute(computeBlurScore, decoded));
            } catch (e) {
              debugPrint('Unschärfe fehlgeschlagen für ${asset.originalFileName}: $e');
            }
          }
          if (brauchtGesichter) {
            try {
              await _scanFacesForDecodedAsset(asset, decoded, deleteExistingUnassigned: false);
            } catch (e) {
              debugPrint('Gesichtserkennung fehlgeschlagen für ${asset.originalFileName}: $e');
            }
          }
          if (brauchtEmbedding) {
            try {
              await db.saveEmbedding(asset.id, await clip.embedImage(decoded));
            } catch (e) {
              debugPrint('CLIP-Embedding fehlgeschlagen für ${asset.originalFileName}: $e');
            }
          }
        }
      }

      done++;
      yield ImportProgress(done, kandidaten.length, currentFile: asset.originalFileName);
    }
  }

  /// Berechnet Unschärfe-Scores nachträglich für Fotos, die vor Einführung
  /// dieses Features importiert wurden (siehe [_postProcessNewAsset]).
  /// Wird von der Hintergrundanalyse nicht mehr direkt aufgerufen (dort
  /// erledigt das [_bildinhaltsAnalyse] mit), bleibt aber für den manuellen
  /// Lauf in den Werkzeugen erhalten.
  Stream<ImportProgress> backfillBlurScores() async* {
    final assets = await db.assetsForBlurBackfill();
    var done = 0;
    yield ImportProgress(0, assets.length);
    for (final asset in assets) {
      // Pro Foto abgesichert, analog zu [backfillOcrText].
      try {
        final decoded = await _decodeAsset(asset);
        if (decoded != null) {
          await db.setSharpnessScore(asset.id, await compute(computeBlurScore, decoded));
        }
      } catch (e) {
        debugPrint('Unschärfe-Berechnung fehlgeschlagen für ${asset.originalFileName}: $e');
      }
      done++;
      yield ImportProgress(done, assets.length, currentFile: asset.originalFileName);
    }
  }

  /// Schreibt für jedes Asset in der Bibliothek eine `.xmp`-Sidecar-Datei
  /// neben das Original (Interoperabilität mit Lightroom/darktable/digiKam,
  /// siehe xmp_writer.dart) – läuft absichtlich immer über ALLE Assets neu
  /// (kein "bereits geschrieben"-Tracking wie bei OCR/Unschärfe): das
  /// Schreiben ist günstig und idempotent, und so bleiben Sidecars nach
  /// nachträglichen Metadaten-Änderungen (Tag/Bewertung/Beschreibung) bei
  /// erneutem Lauf konsistent. Gesperrte Assets werden ausgeschlossen (siehe
  /// AppDatabase.assetsForXmpExport).
  Stream<ImportProgress> writeXmpSidecars() async* {
    final assets = await db.assetsForXmpExport();
    final tagsByAssetId = await db.allTagNamesByAssetId();
    var done = 0;
    yield ImportProgress(0, assets.length);
    for (final asset in assets) {
      final xmp = buildXmpPacket(asset, tagsByAssetId[asset.id] ?? const []);
      final sidecarFile = paths.absolute(paths.xmpSidecarPath(asset.relativePath));
      await sidecarFile.writeAsString(xmp);
      done++;
      yield ImportProgress(done, assets.length, currentFile: asset.originalFileName);
    }
  }

  /// Setzt den Speicherort zurück auf den Standard-App-Support-Ordner.
  /// Schließt dafür die aktuelle Datenbankverbindung – die App muss danach
  /// neu gestartet werden, damit sie den Standardordner wieder lädt (siehe
  /// [LibraryLocation] für die Details zur Sandbox-Zugriffsproblematik).
  Future<void> resetLibraryLocation() async {
    await db.close();
    await LibraryLocation.resetToDefault();
  }

  /// Löscht die GESAMTE Bibliothek unwiderruflich: die Datenbank (Fotos-
  /// Metadaten, Alben, Personen, Tags, Orte, Favoriten, gesperrter Ordner,
  /// Papierkorb, gespeicherte Suchen, Backup-/Trash-Einstellungen, …) sowie
  /// alle Mediendateien (Originale, Thumbnails, Vorschauen, Gesichts-Crops,
  /// physischer Papierkorb). Heruntergeladene KI-Modelle und Geodaten (siehe
  /// [_modelsDir]/`geoDataDir` in [initialize]) bleiben bewusst erhalten –
  /// sie enthalten keine persönlichen Daten und müssten sonst erneut
  /// heruntergeladen werden. Ein abweichender Speicherort (siehe
  /// [LibraryLocation]) bleibt als Einstellung ebenfalls bestehen, nur dessen
  /// Inhalt wird geleert. Schließt dafür die aktuelle Datenbankverbindung –
  /// die App muss danach neu gestartet werden (siehe SettingsScreen).
  Future<void> eraseLibraryCompletely() async {
    await db.close();
    final root = await LibraryLocation.currentRoot();
    await eraseLibraryDataAt(root);
  }

  /// Löscht `library.sqlite` (+ WAL/SHM-Nebendateien) und den `library/`-
  /// Ordner unter [root] – die eigentliche Löschlogik hinter
  /// [eraseLibraryCompletely], hier als eigene, mit einem beliebigen
  /// Verzeichnis testbare Funktion, da [LibraryLocation.currentRoot] über
  /// `path_provider`-Plattform-Kanäle läuft und sich in einem reinen
  /// `flutter test` nicht ohne Weiteres auflösen lässt (siehe
  /// `StoragePaths.forTesting` für dasselbe Muster).
  @visibleForTesting
  static Future<void> eraseLibraryDataAt(Directory root) async {
    final dbPath = p.join(root.path, 'library.sqlite');
    for (final suffix in ['', '-wal', '-shm']) {
      final file = File('$dbPath$suffix');
      if (await file.exists()) await file.delete();
    }
    final libraryDir = Directory(p.join(root.path, 'library'));
    if (await libraryDir.exists()) await libraryDir.delete(recursive: true);
  }

  /// Berechnet CLIP-Bild-Embeddings nachträglich für Fotos, die vor
  /// Installation des CLIP-Modells importiert wurden (Embeddings entstehen
  /// sonst nur automatisch beim Import, siehe [_postProcessNewAsset]) –
  /// ohne dieses Werkzeug bliebe die KI-Bildsuche/Duplikatsuche auf die
  /// wenigen danach importierten Fotos beschränkt.
  Stream<ImportProgress> backfillClipEmbeddings() async* {
    final service = clipService;
    if (service == null) {
      yield ImportProgress(0, 0);
      return;
    }
    final assets = await db.assetsForEmbeddingBackfill();
    var done = 0;
    yield ImportProgress(0, assets.length);
    for (final asset in assets) {
      try {
        final decoded = await _decodeAsset(asset);
        if (decoded == null) throw Exception('Bild konnte nicht dekodiert werden.');
        final embedding = await service.embedImage(decoded);
        await db.saveEmbedding(asset.id, embedding);
      } catch (e) {
        debugPrint('CLIP-Embedding fehlgeschlagen für ${asset.originalFileName}: $e');
      }
      done++;
      yield ImportProgress(done, assets.length, currentFile: asset.originalFileName);
    }
  }

  /// Berechnet automatische KI-Tags nachträglich (siehe [AiTaggingService])
  /// – für Fotos, die vor Einführung dieser Funktion importiert wurden oder
  /// wenn das CLIP-Modell erst nachträglich installiert wurde. Nutzt ein
  /// bereits gespeichertes CLIP-Embedding weiter, falls vorhanden, statt es
  /// neu zu berechnen.
  Stream<ImportProgress> backfillAiTags({required bool onlyUntagged}) async* {
    final clip = clipService;
    final tagging = aiTaggingService;
    if (clip == null || tagging == null) {
      yield ImportProgress(0, 0);
      return;
    }
    final assets = await db.assetsForAiTagging(onlyUntagged: onlyUntagged);
    // Einmal pro Lauf statt pro Asset gelesen – das Vokabular ändert sich
    // während eines laufenden Backfills nicht, ein SELECT pro Foto wäre
    // gegenüber der ohnehin pro Foto anfallenden CLIP-Inferenz reine Verschwendung.
    final vocabulary = await db.aiTagVocabularyTerms();
    var done = 0;
    yield ImportProgress(0, assets.length);
    for (final asset in assets) {
      try {
        var embedding = await db.embeddingForAsset(asset.id);
        if (embedding == null) {
          final decoded = await _decodeAsset(asset);
          if (decoded == null) throw Exception('Bild konnte nicht dekodiert werden.');
          embedding = await clip.embedImage(decoded);
          await db.saveEmbedding(asset.id, embedding);
        }
        final tags = await tagging.suggestTags(embedding, vocabulary);
        for (final tag in tags) {
          await db.tagAsset(asset.id, tag);
        }
      } catch (e) {
        debugPrint('KI-Tagging fehlgeschlagen für ${asset.originalFileName}: $e');
      }
      done++;
      yield ImportProgress(done, assets.length, currentFile: asset.originalFileName);
    }
  }

  // -----------------------------------------------------------------------
  // Gesperrter Ordner (PIN-Schutz + echte AES-256-Verschlüsselung)
  // -----------------------------------------------------------------------
  //
  // Der entpackte Master-Key lebt ausschließlich im Prozessspeicher dieser
  // Sitzung ([_vaultKey]) – nie auf der Platte. Er bleibt für den Rest der
  // App-Sitzung gültig, sobald der PIN einmal korrekt eingegeben wurde
  // (siehe [ensureVaultUnlocked] in pin_dialogs.dart), damit weder das
  // Sperren eines weiteren Fotos noch ein erneuter Besuch des gesperrten
  // Ordners jedes Mal wieder nach dem PIN fragen muss. [lockVaultSession]
  // erlaubt, das manuell vorzeitig zu beenden.

  SecretKey? _vaultKey;
  bool get vaultUnlockedThisSession => _vaultKey != null;

  /// Richtet den gesperrten Ordner erstmalig ein: neuer zufälliger
  /// Master-Key, mit [pin] verpackt – und direkt für diese Sitzung
  /// entsperrt.
  Future<void> setupVaultPin(String pin) async {
    final wrapped = await VaultCrypto.createMasterKey(pin);
    await db.saveVaultKey(kdfSalt: wrapped.kdfSalt, nonce: wrapped.nonce, wrapped: wrapped.wrapped);
    _vaultKey = wrapped.masterKey;
  }

  /// Entsperrt den gesperrten Ordner für die laufende Sitzung. Wirft bei
  /// falschem PIN (GCM-Authentifizierung des Master-Keys schlägt fehl).
  Future<void> unlockVaultWithPin(String pin) async {
    final row = await db.privacySettingsRow();
    final kdfSalt = row?.kdfSalt;
    final nonce = row?.wrappedMasterKeyNonce;
    final wrapped = row?.wrappedMasterKey;
    if (kdfSalt == null || nonce == null || wrapped == null) {
      throw StateError('Kein PIN eingerichtet.');
    }
    _vaultKey = await VaultCrypto.unwrapMasterKey(pin, kdfSalt: kdfSalt, nonce: nonce, wrapped: wrapped);
  }

  /// Ändert den PIN, ohne den Master-Key (und damit alle bereits
  /// verschlüsselten Dateien) neu erzeugen zu müssen – nur die "Verpackung"
  /// des Master-Keys ändert sich.
  Future<void> changeVaultPin(String newPin) async {
    final key = _vaultKey;
    if (key == null) throw StateError('Der gesperrte Ordner muss vorher entsperrt sein.');
    final wrapped = await VaultCrypto.wrapMasterKey(key, newPin);
    await db.saveVaultKey(kdfSalt: wrapped.kdfSalt, nonce: wrapped.nonce, wrapped: wrapped.wrapped);
  }

  /// Entfernt den PIN-Schutz und entschlüsselt alle gesperrten Dateien
  /// wieder zurück in Klartext – sonst wären sie über keine UI mehr
  /// erreichbar.
  Future<void> removeVaultPin() async {
    final key = _vaultKey;
    if (key == null) throw StateError('Der gesperrte Ordner muss vorher entsperrt sein.');
    final locked = await db.watchLockedAssets().first;
    for (final asset in locked) {
      await _decryptAssetFiles(asset, key);
      await db.setAssetsLocked([asset.id], false);
    }
    await db.clearVaultKey();
    _vaultKey = null;
  }

  /// Sperrt die laufende Sitzung wieder (z.B. bevor man den Rechner aus der
  /// Hand gibt), ohne die App beenden zu müssen – der Master-Key ist danach
  /// aus dem Speicher entfernt, der nächste Zugriff verlangt wieder den PIN.
  void lockVaultSession() {
    _vaultKey = null;
  }

  Future<void> _cryptFileInPlace(
    String relativePath,
    SecretKey key, {
    required bool encrypt,
  }) async {
    final file = paths.absolute(relativePath);
    if (!await file.exists()) return;
    final tmp = File('${file.path}.vaulttmp');
    if (encrypt) {
      await VaultCrypto.encryptFile(file, tmp, key);
    } else {
      await VaultCrypto.decryptFile(file, tmp, key);
    }
    await tmp.rename(file.path);
  }

  /// Verschlüsselt Original, Thumbnail, Vorschau, ein evtl. entwickeltes
  /// Bild (siehe DevelopScreen), einen evtl. nicht-destruktiven Video-
  /// Zuschnitt (siehe VideoTrimScreen), evtl. gespeicherte KI-Objektmasken
  /// (siehe MaskEditor) und ggf. bereits vorhandene Gesichts-Crops eines
  /// Assets an Ort und Stelle (derselbe relative Pfad, nur der
  /// Dateiinhalt ändert sich von Klartext zu Chiffretext) – wichtig, damit
  /// beim Sperren nie eine unverschlüsselte Kopie einer dieser
  /// Zusatzdateien zurückbleibt (Audit-Fund: `trimmedRelativePath` und
  /// `DevelopMasks.maskRelativePath` fehlten hier ursprünglich).
  Future<void> _encryptAssetFiles(AssetData asset, SecretKey key) async {
    for (final relPath in [
      asset.relativePath,
      asset.thumbnailRelativePath,
      asset.previewRelativePath,
      asset.developedRelativePath,
      asset.restoredRelativePath,
      asset.trimmedRelativePath,
    ]) {
      if (relPath != null) await _cryptFileInPlace(relPath, key, encrypt: true);
    }
    for (final face in await db.facesForAsset(asset.id)) {
      if (face.cropRelativePath != null) {
        await _cryptFileInPlace(face.cropRelativePath!, key, encrypt: true);
      }
    }
    for (final mask in await db.masksForAsset(asset.id)) {
      await _cryptFileInPlace(mask.maskRelativePath, key, encrypt: true);
    }
  }

  Future<void> _decryptAssetFiles(AssetData asset, SecretKey key) async {
    for (final relPath in [
      asset.relativePath,
      asset.thumbnailRelativePath,
      asset.previewRelativePath,
      asset.developedRelativePath,
      asset.restoredRelativePath,
      asset.trimmedRelativePath,
    ]) {
      if (relPath != null) await _cryptFileInPlace(relPath, key, encrypt: false);
    }
    for (final face in await db.facesForAsset(asset.id)) {
      if (face.cropRelativePath != null) {
        await _cryptFileInPlace(face.cropRelativePath!, key, encrypt: false);
      }
    }
    for (final mask in await db.masksForAsset(asset.id)) {
      await _cryptFileInPlace(mask.maskRelativePath, key, encrypt: false);
    }
  }

  /// Verschlüsselt ein Foto/Video und verschiebt es in den gesperrten
  /// Ordner. Setzt voraus, dass der gesperrte Ordner für diese Sitzung
  /// bereits entsperrt ist (siehe [ensureVaultUnlocked] in
  /// pin_dialogs.dart) – wirft sonst. Ein verknüpfter Live-Photo-Partner
  /// (Foto<->Video) wird automatisch mitgesperrt, damit nie nur eine Hälfte
  /// eines Live Photos verschlüsselt ist.
  Future<void> lockAsset(AssetData asset) async {
    final key = _vaultKey;
    if (key == null) throw StateError('Der gesperrte Ordner muss vorher entsperrt sein.');
    await _encryptAssetFiles(asset, key);
    await db.setAssetsLocked([asset.id], true);
    // Auch die aus dem Bildinhalt abgeleiteten Daten müssen weg, sonst
    // bliebe der Inhalt in der unverschlüsselten Datenbank lesbar – siehe
    // [AppDatabase.clearDerivedContentData].
    await db.clearDerivedContentData([asset.id]);
    if (asset.linkedAssetId != null) {
      final partner = await db.assetById(asset.linkedAssetId!);
      if (partner != null && !partner.isLocked) {
        await _encryptAssetFiles(partner, key);
        await db.setAssetsLocked([partner.id], true);
        await db.clearDerivedContentData([partner.id]);
      }
    }
  }

  /// Kehrt [lockAsset] um: entschlüsselt die Dateien wieder in Klartext und
  /// entfernt das Foto (samt Live-Photo-Partner) aus dem gesperrten Ordner.
  Future<void> unlockAsset(AssetData asset) async {
    final key = _vaultKey;
    if (key == null) throw StateError('Der gesperrte Ordner muss vorher entsperrt sein.');
    await _decryptAssetFiles(asset, key);
    await db.setAssetsLocked([asset.id], false);
    if (asset.linkedAssetId != null) {
      final partner = await db.assetById(asset.linkedAssetId!);
      if (partner != null && partner.isLocked) {
        await _decryptAssetFiles(partner, key);
        await db.setAssetsLocked([partner.id], false);
      }
    }
  }

  /// Temporäres Verzeichnis außerhalb der Bibliothek für rein zur Anzeige
  /// entschlüsselte Dateien (Vollbildansicht/Thumbnails im gesperrten
  /// Ordner) – die Originaldatei auf der Platte bleibt verschlüsselt.
  Directory get _decryptCacheDir => Directory(p.join(Directory.systemTemp.path, 'photovault_decrypt'));

  /// Entschlüsselt eine gesperrte Datei in den temporären Zwischenspeicher
  /// (nur beim ersten Zugriff, danach aus dem Cache) und gibt sie zurück.
  /// Setzt einen bereits entsperrten gesperrten Ordner voraus.
  Future<File> decryptForViewing(String relativePath) async {
    final key = _vaultKey;
    if (key == null) throw StateError('Der gesperrte Ordner muss vorher entsperrt sein.');
    final cacheDir = _decryptCacheDir;
    await cacheDir.create(recursive: true);
    final safeName = relativePath.replaceAll(RegExp(r'[\\/]'), '_');
    final target = File(p.join(cacheDir.path, safeName));
    if (!await target.exists()) {
      await VaultCrypto.decryptFile(paths.absolute(relativePath), target, key);
    }
    return target;
  }

  /// Leert den Entschlüsselungs-Zwischenspeicher – beim App-Start (Reste
  /// einer abgestürzten vorigen Sitzung) und beim Verlassen des gesperrten
  /// Ordners, damit keine entschlüsselten Kopien länger als nötig auf der
  /// Platte liegen bleiben.
  Future<void> clearDecryptCache() async {
    final dir = _decryptCacheDir;
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  // -----------------------------------------------------------------------
  // Backup-Verschlüsselung (eigener Master-Key, eigene Passphrase – bewusst
  // getrennt vom PIN des gesperrten Ordners, siehe BackupSettings)
  // -----------------------------------------------------------------------

  SecretKey? _backupKey;
  bool get backupKeyAvailableThisSession => _backupKey != null;

  Future<void> setupBackupPassphrase(String passphrase) async {
    final wrapped = await VaultCrypto.createMasterKey(passphrase);
    await db.saveBackupKey(kdfSalt: wrapped.kdfSalt, nonce: wrapped.nonce, wrapped: wrapped.wrapped);
    _backupKey = wrapped.masterKey;
  }

  Future<void> unlockBackupKeyWithPassphrase(String passphrase) async {
    final row = await db.backupSettingsRow();
    final kdfSalt = row?.kdfSalt;
    final nonce = row?.wrappedMasterKeyNonce;
    final wrapped = row?.wrappedMasterKey;
    if (kdfSalt == null || nonce == null || wrapped == null) {
      throw StateError('Keine Backup-Passphrase eingerichtet.');
    }
    _backupKey = await VaultCrypto.unwrapMasterKey(passphrase, kdfSalt: kdfSalt, nonce: nonce, wrapped: wrapped);
  }

  Future<void> changeBackupPassphrase(String newPassphrase) async {
    final key = _backupKey;
    if (key == null) throw StateError('Die Backup-Passphrase muss vorher entsperrt sein.');
    final wrapped = await VaultCrypto.wrapMasterKey(key, newPassphrase);
    await db.saveBackupKey(kdfSalt: wrapped.kdfSalt, nonce: wrapped.nonce, wrapped: wrapped.wrapped);
  }

  /// Entfernt nur die lokale Backup-Verschlüsselungs-Einrichtung – bereits
  /// bestehende verschlüsselte Backups am Zielort bleiben unangetastet
  /// (anders als beim gesperrten Ordner gibt es hier nichts "zu
  /// entschlüsseln", die Originaldateien in der Bibliothek selbst waren nie
  /// verschlüsselt).
  Future<void> removeBackupEncryption() async {
    await db.clearBackupKey();
    _backupKey = null;
  }

  /// Führt ein manuelles Backup aus – bei [encrypt] mit dem für diese
  /// Sitzung entsperrten Backup-Schlüssel (siehe [ensureBackupKeyAvailable]
  /// in pin_dialogs.dart, das der Aufrufer vorher ausgeführt haben muss).
  Stream<BackupProgress> runManualBackup(String destination, {required bool encrypt}) async* {
    final grenze = await _backupGrenzeBytes();
    yield* backupService.performBackup(destination,
        encryptionKey: encrypt ? _backupKey : null, maxBytesPerRun: grenze);
  }

  /// Portionsgrenze je Sicherungslauf in Bytes, 0 = unbegrenzt (siehe
  /// BackupSettings.autoBackupMaxMbPerRun).
  Future<int> _backupGrenzeBytes() async {
    final config = await db.backupSettingsRow();
    final mb = config?.autoBackupMaxMbPerRun ?? 0;
    return mb > 0 ? mb * 1024 * 1024 : 0;
  }

  /// Löst das automatische Backup unabhängig vom Intervall manuell aus
  /// (z.B. über den "Jetzt synchronisieren"-Button in den Einstellungen).
  /// Setzt voraus, dass die Backup-Passphrase für diese Sitzung bereits
  /// entsperrt ist.
  Stream<BackupProgress> runAutoBackupNow(String destination) async* {
    final key = _backupKey;
    if (key == null) throw StateError('Die Backup-Passphrase muss vorher entsperrt sein.');
    yield* backupService.performAutoBackup(destination, key,
        maxBytesPerRun: await _backupGrenzeBytes());
    await db.setLastAutoBackupAt(DateTime.now());
  }

  /// Prüft, ob das automatische Backup fällig ist (aktiviert, Ziel gesetzt,
  /// Intervall abgelaufen) und der Backup-Schlüssel für diese Sitzung
  /// bereits vorliegt – wenn nicht, wird NICHT nach der Passphrase gefragt
  /// (das würde unerwartet mitten in der Nutzung passieren), sondern der
  /// Lauf einfach übersprungen; die Einstellungen zeigen dann an, dass eine
  /// erneute Passphrase-Eingabe nötig ist. Läuft nur, solange die App offen
  /// ist – kein Hintergrunddienst, siehe Klassenkommentar in
  /// [BackupService.performAutoBackup].
  Future<void> runAutoBackupIfDue() async {
    if (_autoBackupRunning) return;
    final config = await db.backupSettingsRow();
    if (config == null || !config.autoBackupEnabled) return;
    final destination = config.autoBackupDestination;
    if (destination == null || destination.isEmpty) return;

    final lastRun = config.lastAutoBackupAt;
    if (lastRun != null) {
      final due = lastRun.add(Duration(hours: config.autoBackupIntervalHours));
      if (DateTime.now().isBefore(due)) return;
    }

    final key = _backupKey;
    if (key == null) return; // Passphrase muss erst wieder manuell entsperrt werden.

    _autoBackupRunning = true;
    try {
      await backupService
          .performAutoBackup(destination, key,
              maxBytesPerRun: (config.autoBackupMaxMbPerRun > 0)
                  ? config.autoBackupMaxMbPerRun * 1024 * 1024
                  : 0)
          .drain<void>();
      await db.setLastAutoBackupAt(DateTime.now());
    } catch (e) {
      debugPrint('Automatisches Backup fehlgeschlagen: $e');
    } finally {
      _autoBackupRunning = false;
    }
  }

  /// Löscht alle zu einem Asset gehörenden Dateien von der Platte (Original,
  /// Thumbnail, Vorschau, entwickeltes Bild, Video-Zuschnitt, KI-Objekt-
  /// masken, Gesichts-Crops) – zentrale Stelle für "endgültig löschen",
  /// genutzt von allen drei Aufrufstellen (normaler Papierkorb,
  /// automatisches Ablaufen, gesperrter Papierkorb). Vorher pflegte jede
  /// Stelle ihre eigene Kopie dieser Liste, wodurch z.B.
  /// [previewRelativePath] beim automatischen Ablaufen jahrelang vergessen
  /// wurde (orphaned Dateien) – ein Audit-Fund, den diese Konsolidierung
  /// strukturell ausschließen soll; ein späterer Audit-Fund war, dass
  /// [trimmedRelativePath]/[DevelopMasks.maskRelativePath] bei Einführung
  /// dieser Features hier nicht ergänzt wurden. Löscht bewusst NICHT die
  /// DB-Zeile selbst; das bleibt Sache des Aufrufers (unterschiedliche
  /// Batch-Strategien).
  Future<void> deleteAssetFilesFromDisk(AssetData asset) async {
    for (final relPath in [
      asset.relativePath,
      asset.thumbnailRelativePath,
      asset.previewRelativePath,
      asset.developedRelativePath,
      asset.restoredRelativePath,
      asset.trimmedRelativePath,
    ]) {
      if (relPath != null) await paths.deletePermanently(relPath);
    }
    for (final face in await db.facesForAsset(asset.id)) {
      if (face.cropRelativePath != null) {
        await paths.deletePermanently(face.cropRelativePath!);
      }
    }
    for (final mask in await db.masksForAsset(asset.id)) {
      await paths.deletePermanently(mask.maskRelativePath);
    }
  }

  /// Prüft, ob im Papierkorb liegende Assets älter als das eingestellte
  /// Ablaufdatum sind, und löscht diese dann endgültig (Datei + DB-Zeile) –
  /// deaktiviert per Default (siehe [TrashSettings]). Läuft, wie das
  /// automatische Backup, nur während die App geöffnet ist.
  Future<void> purgeExpiredTrashIfDue() async {
    if (_trashPurgeRunning) return;
    final config = await db.trashSettingsRow();
    if (config == null || !config.autoDeleteEnabled) return;

    _trashPurgeRunning = true;
    try {
      final cutoff = DateTime.now().subtract(Duration(days: config.autoDeleteAfterDays));
      final expired = await db.expiredTrashAssets(cutoff);
      for (final asset in expired) {
        await deleteAssetFilesFromDisk(asset);
      }
      if (expired.isNotEmpty) {
        await db.deleteAssetRows(expired.map((a) => a.id).toList());
      }
      await db.setLastTrashPurgeAt(DateTime.now());
    } catch (e) {
      debugPrint('Automatisches Leeren des Papierkorbs fehlgeschlagen: $e');
    } finally {
      _trashPurgeRunning = false;
    }
  }

  @override
  void dispose() {
    _autoBackupTimer?.cancel();
    _trashPurgeTimer?.cancel();
    super.dispose();
  }
}
