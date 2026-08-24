import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../l10n/app_localizations.dart';
import '../services/ai_tagging_service.dart';
import '../services/backup_service.dart';
import '../services/blur_detection.dart';
import '../services/florence_captioning_service.dart';
import '../services/clip_service.dart';
import '../services/develop_color.dart';
import '../services/translation_service.dart';
import '../services/embedding_codec.dart';
import '../services/eye_state_service.dart';
import '../services/face_engine_service.dart';
import '../services/face_postprocess.dart';
import '../services/geo_data_download_service.dart';
import '../services/import_service.dart';
import '../services/raw_formats.dart';
import '../services/library_location.dart';
import '../services/model_catalog.dart';
import '../services/model_download_service.dart';
import '../services/ocr_service.dart';
import '../services/modell_halter.dart';
import '../services/platform/folder_access.dart';
import '../services/native_image_converter.dart';
import '../services/restore_queue_service.dart';
import '../services/restore_service.dart';
import '../services/reverse_geocoder.dart';
import '../services/segmentation_service.dart';
import '../services/storage_paths.dart';
import '../services/vault_crypto.dart';
import '../services/xmp_writer.dart';
import 'hintergrundlauf.dart';

/// Die Schritte der Hintergrundanalyse, in der Reihenfolge ihres Ablaufs.
///
/// Eine Aufzählung statt eines fertigen Namens: Dieser Dienst kennt keine
/// Oberflächensprache, und der Name wird an zwei Stellen angezeigt (Leiste
/// oben, Hintergrundaufgaben). Die Zuordnung zum Text steht dort.
enum Analysestufe { bildanalyse, texterkennung, schlagwoerter, bildbeschreibung }

/// Der Name einer Stufe in der Oberflächensprache.
String analysestufeName(AppTexte t, Analysestufe stufe) => switch (stufe) {
      Analysestufe.bildanalyse => t.stufeBildanalyse,
      Analysestufe.texterkennung => t.stufeTexterkennung,
      Analysestufe.schlagwoerter => t.stufeSchlagwoerter,
      Analysestufe.bildbeschreibung => t.stufeBildbeschreibung,
    };

/// Fortschritt der Hintergrundanalyse (siehe
/// [LibraryState.starteHintergrundanalyse]).
class AnalyseFortschritt {
  final Analysestufe stufe;
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

  // Jedes KI-Modell wird erst beim ersten Gebrauch geladen und nach einer
  // Weile Leerlauf wieder freigegeben (siehe ModellHalter, _sweepIdleModels) –
  // vorher lagen hier eager beim App-Start alle sechs Modelle im Speicher
  // (gemessen 1538 MB gegen 213 MB ohne). Nicht `late`, sondern mit einem
  // "nichts installiert"-Platzhalter vorbelegt: Tests bauen LibraryState oft
  // ohne den vollen initialize()-Durchlauf zusammen (siehe
  // audit_optimierungen_test.dart) und dürfen dabei nicht auf ein
  // uninitialisiertes `late`-Feld treffen. _loadModelsIfPresent() ersetzt
  // die Platzhalter beim echten Start durch die tatsächlichen Halter.
  ModellHalter<FaceEngineService> faceEngineHalter = _leererHalter('Gesichtserkennung');
  ModellHalter<EyeStateService> eyeStateHalter = _leererHalter('Augen-Zustand');
  // CLIP getrennt nach Encoder: Der Bildteil (335 MB) arbeitet in der
  // Hintergrundanalyse, der Textteil (242 MB) nur, wenn jemand eine
  // Kontext-Suche eintippt. Zusammen wären es 577 MB, von denen die
  // jeweilige Aufgabe die Hälfte nie anfasst. Einzige Ausnahme ist das
  // KI-Tagging, das beide braucht (Bild-Embedding des Fotos gegen
  // Text-Embeddings der Vokabelbegriffe) und deshalb beide leiht.
  ModellHalter<ClipService> clipBildHalter = _leererHalter('CLIP-Bild');
  ModellHalter<ClipService> clipTextHalter = _leererHalter('CLIP-Text');
  ModellHalter<SegmentationService> segmentationHalter = _leererHalter('Segmentierung');
  ModellHalter<FlorenceCaptioningService> captioningHalter =
      _leererHalter('Bildbeschreibung');

  /// Die beiden Übersetzungsrichtungen – getrennte Halter, weil sie
  /// getrennt installierbar sind und selten gleichzeitig gebraucht werden.
  ModellHalter<TranslationService> uebersetzungEnDeHalter =
      _leererHalter('translate-en-de');
  ModellHalter<TranslationService> uebersetzungDeEnHalter =
      _leererHalter('translate-de-en');

  /// Texterkennung ohne Betriebssystem-Hilfe – nur ausserhalb von macOS
  /// gebraucht, wo Apples Vision-Framework die Arbeit besser und ohne
  /// Download erledigt.
  ModellHalter<OcrService> ocrHalter = _leererHalter('Texterkennung');

  static ModellHalter<T> _leererHalter<T>(String name) => ModellHalter<T>(
        name: name,
        installiert: false,
        laden: () => throw StateError('LibraryState.initialize() wurde noch nicht aufgerufen.'),
        entsorgen: (_) async {},
      );

  /// Halter, die gerade durch einen frischen ersetzt wurden, während sie
  /// noch in Benutzung waren (siehe _loadModelsIfPresent) – ohne diese Liste
  /// gäbe es keine Referenz mehr, über die sie je freigegeben würden. Wird
  /// vom selben Timer wie die übrigen Halter regelmäßig abgeräumt.
  final List<ModellHalter> _retiredHalters = [];
  Timer? _modellFreigabeTimer;

  List<ModellHalter> get _alleHalter => [
        faceEngineHalter,
        eyeStateHalter,
        clipBildHalter,
        clipTextHalter,
        segmentationHalter,
        captioningHalter,
        uebersetzungEnDeHalter,
        uebersetzungDeEnHalter,
        if (restoreQueue.restoreHalter != null) restoreQueue.restoreHalter!,
      ];

  /// Kein eigenes ONNX-Modell (siehe ai_tagging_service.dart) – braucht nur
  /// eine bereits geladene [ClipService]-Sitzung als Parameter, deshalb ohne
  /// eigenen Halter und für die ganze App-Laufzeit unverändert nutzbar.
  final AiTaggingService aiTaggingService = AiTaggingService();
  /// Name der geöffneten Bibliothek – nur gesetzt, wenn überhaupt mehr als
  /// eine bekannt ist. Sonst wäre die Anzeige in der Navigationsleiste ein
  /// Hinweis ohne Aussage.
  String? aktiveBibliothek;

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
  ///
  /// Wird beim Start aus [AppSettings] geladen und beim Ändern dorthin
  /// zurückgeschrieben – vorher lag der Wert nur im Speicher und der
  /// Regler stand nach jedem Programmstart wieder auf dem Ausgangswert,
  /// ohne dass das irgendwo stand.
  double faceSimilarityThreshold = 0.363;

  Future<void> ladeGesichtsSchwelle() async {
    faceSimilarityThreshold = await db.faceSimilarityThresholdWert();
    notifyListeners();
  }

  /// Setzt die allgemeine Schwelle. Die persönlichen Schwellen einzelner
  /// Personen werden dabei mitgezogen (siehe
  /// `AppDatabase.setFaceSimilarityThreshold`).
  Future<void> setFaceSimilarityThreshold(double value) async {
    faceSimilarityThreshold = value;
    notifyListeners();
    await db.setFaceSimilarityThreshold(value);
  }

  /// Die für [personId] geltende Schwelle: die persönliche, sonst die
  /// allgemeine.
  double schwelleFuerPerson(PersonData person) =>
      person.similarityThreshold ?? faceSimilarityThreshold;

  /// Übersetzt [text] ins Englische, sofern das Modell installiert und die
  /// Einstellung eingeschaltet ist – sonst kommt [text] unverändert zurück.
  ///
  /// Gebraucht, weil der CLIP-Text-Encoder nur Englisch versteht, das
  /// Tag-Vokabular aber deutsch ist und die Suche in einer deutschen
  /// Oberfläche stattfindet. An 103 Fotos gemessen trennt die übersetzte
  /// Fassung bei 33 von 56 Vokabelbegriffen schärfer, bei 19 schlechter –
  /// ein realer, aber weder grosser noch durchgängiger Gewinn. Deshalb
  /// eine Einstellung und keine stille Umstellung.
  ///
  /// Schlägt die Übersetzung fehl, gilt der Ausgangstext: Eine Suche, die
  /// mittelmässige Treffer liefert, ist besser als eine, die eine
  /// Fehlermeldung liefert.
  Future<String> insEnglische(String text) async {
    if (text.trim().isEmpty) return text;
    if (!uebersetzungDeEnHalter.installiert) return text;
    if (!await db.uebersetzeSucheUndTags()) return text;
    try {
      // `mit` gibt null zurück, wenn das Modell doch nicht ladbar war.
      final uebersetzt = await uebersetzungDeEnHalter.mit((s) => s.translate(text));
      if (uebersetzt == null || uebersetzt.trim().isEmpty) return text;
      return uebersetzt;
    } catch (e) {
      debugPrint('Übersetzung der Anfrage fehlgeschlagen: $e');
      return text;
    }
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

    // Reste abgebrochener Modell-Downloads wegräumen, bevor irgendetwas
    // den Modellordner ansieht – sie sind nutzlos und können mehrere
    // hundert MB belegen (Audit-Fund).
    unawaited(modelDownloadService.raeumeAbgebrocheneDownloads());
    unawaited(modelDownloadService.raeumeAbgeloesteModelle());
    // Welche Bibliothek ist offen? Nur anzeigen, wenn es eine Wahl gibt.
    try {
      final bekannt = await LibraryLocation.bekannte();
      if (bekannt.length > 1) {
        aktiveBibliothek = bekannt.where((b) => b.istAktiv).map((b) => b.eintrag.name).firstOrNull;
      }
    } catch (e) {
      debugPrint('Bibliotheksliste nicht lesbar: $e');
    }

    await ladeGesichtsSchwelle();
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

    // Überwachter Ordner – einmal beim Start und danach regelmässig, aus
    // demselben Grund wie beim automatischen Backup: Es gibt keinen
    // Hintergrunddienst, der das erledigen könnte.
    unawaited(pruefeUeberwachtenOrdner());
    _ordnerTimer = Timer.periodic(_ordnerIntervall, (_) => pruefeUeberwachtenOrdner());

    // Gibt KI-Modelle frei, die seit dem letzten Durchlauf nicht mehr in
    // Benutzung sind (siehe ModellHalter.freigebenWennUnbenutzt) – das ist
    // der Gegenpart zum bedarfsweisen Laden: ohne das hier bliebe ein einmal
    // benutztes Modell bis zum Beenden der App im Speicher.
    _modellFreigabeTimer = Timer.periodic(const Duration(minutes: 2), (_) => _sweepIdleModels());

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

  /// Prüft, welche Modelldateien bereits im models-Ordner liegen, und legt
  /// dafür je einen [ModellHalter] an (der die eigentliche Engine erst beim
  /// ersten Gebrauch lädt). Wird auch nach einem Download in den
  /// Einstellungen erneut aufgerufen ([reloadModels]) – dann ersetzt ein
  /// frischer Halter den alten, weil `installiert` sich nur beim Anlegen
  /// ermittelt (siehe ModellHalter-Klassenkommentar). Ein alter Halter, der
  /// gerade noch in Benutzung ist, wird nicht zwangsweise entsorgt (das
  /// würde eine laufende Inferenz zum Absturz bringen), sondern in
  /// [_retiredHalters] geparkt und dort vom selben Timer wie die übrigen
  /// Halter abgeräumt, sobald er wieder frei ist – die frühere
  /// Sonderbehandlung von `restoreService` ("während eines Auftrags nicht
  /// ersetzen") ist dadurch nicht mehr nötig, siehe RestoreQueueService.
  Future<void> _loadModelsIfPresent() async {
    // Die Platzhalter aus den Feld-Initialisierern (nichts installiert,
    // nie geladen) landen hier harmlos: _sweepIdleModels() entfernt sie
    // beim nächsten Durchlauf sofort wieder aus _retiredHalters, da
    // `istGeladen` nie true war. _alleHalter liest dieselben (gleich
    // überschriebenen) Felder, daher identisch zu einer eigenen Liste hier.
    _retiredHalters.addAll(_alleHalter);

    faceEngineHalter = ModellHalter<FaceEngineService>(
      name: 'Gesichtserkennung',
      installiert: FaceEngineService.isDetectionAvailable(_modelsDir!),
      // load() ist nullable, weil es intern denselben Dateicheck wie
      // isDetectionAvailable() wiederholt – der ist hier über `installiert`
      // oben bereits als true bekannt, daher unbedenklich entpackt.
      laden: () async => (await FaceEngineService.load(_modelsDir!))!,
      entsorgen: (s) => s.dispose(),
    );
    eyeStateHalter = ModellHalter<EyeStateService>(
      name: 'Augen-Zustand',
      installiert: EyeStateService.isAvailable(_modelsDir!),
      // Gleiches Argument wie bei faceEngineHalter oben.
      laden: () async => (await EyeStateService.load(_modelsDir!))!,
      entsorgen: (s) => s.dispose(),
    );
    // Beide Halter prüfen dieselben Dateien (isAvailable deckt Bild-,
    // Text-Encoder und Tokenizer gemeinsam ab), laden aber jeweils nur
    // ihren Teil – siehe ClipService.load.
    clipBildHalter = ModellHalter<ClipService>(
      name: 'CLIP-Bild',
      installiert: ClipService.isAvailable(_modelsDir!),
      laden: () => ClipService.load(_modelsDir!, bild: true, text: false),
      entsorgen: (s) => s.dispose(),
    );
    clipTextHalter = ModellHalter<ClipService>(
      name: 'CLIP-Text',
      installiert: ClipService.isAvailable(_modelsDir!),
      laden: () => ClipService.load(_modelsDir!, bild: false, text: true),
      entsorgen: (s) => s.dispose(),
    );
    segmentationHalter = ModellHalter<SegmentationService>(
      name: 'Segmentierung',
      installiert: SegmentationService.isAvailable(_modelsDir!),
      laden: () => SegmentationService.load(_modelsDir!),
      entsorgen: (s) => s.dispose(),
    );
    uebersetzungEnDeHalter = ModellHalter<TranslationService>(
      name: 'translate-en-de',
      installiert: TranslationService.isAvailable(_modelsDir!, Uebersetzungsrichtung.enDe),
      laden: () => TranslationService.load(_modelsDir!, Uebersetzungsrichtung.enDe),
      entsorgen: (s) => s.dispose(),
    );
    uebersetzungDeEnHalter = ModellHalter<TranslationService>(
      name: 'translate-de-en',
      installiert: TranslationService.isAvailable(_modelsDir!, Uebersetzungsrichtung.deEn),
      laden: () => TranslationService.load(_modelsDir!, Uebersetzungsrichtung.deEn),
      entsorgen: (s) => s.dispose(),
    );
    ocrHalter = ModellHalter<OcrService>(
      name: 'Texterkennung',
      installiert: OcrService.isAvailable(_modelsDir!),
      laden: () => OcrService.load(_modelsDir!),
      entsorgen: (s) => s.dispose(),
    );
    captioningHalter = ModellHalter<FlorenceCaptioningService>(
      name: 'Bildbeschreibung',
      installiert: FlorenceCaptioningService.isAvailable(_modelsDir!),
      laden: () => FlorenceCaptioningService.load(_modelsDir!),
      entsorgen: (s) => s.dispose(),
    );
    restoreQueue.restoreHalter = ModellHalter<RestoreService>(
      name: 'KI-Restaurierung',
      installiert: RestoreService.isAvailable(_modelsDir!),
      laden: () => RestoreService.load(_modelsDir!),
      entsorgen: (s) => s.dispose(),
    );
  }

  /// Gibt alle aktuellen UND retirierten Halter frei, die gerade nicht in
  /// Benutzung sind (siehe ModellHalter.freigebenWennUnbenutzt) – regelmäßig
  /// per Timer aufgerufen, siehe [initialize].
  Future<void> _sweepIdleModels() async {
    for (final halter in _alleHalter) {
      await halter.freigebenWennUnbenutzt();
    }
    for (final halter in _retiredHalters) {
      await halter.freigebenWennUnbenutzt();
    }
    _retiredHalters.removeWhere((h) => !h.istGeladen && !h.laedtGerade);
  }

  /// Wird nach einem Modell-Download/-Löschen in den Einstellungen
  /// aufgerufen (siehe settings_screen.dart) – legt frische Halter an, damit
  /// neu heruntergeladene Dateien als `installiert` erkannt werden.
  Future<void> reloadModels() async {
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

  // Beide CLIP-Halter prüfen dieselben Dateien – einer genügt als Auskunft.
  bool get clipAvailable => clipBildHalter.installiert;
  bool get faceDetectionAvailable => faceEngineHalter.installiert;
  // Statische Dateiprüfung statt `faceEngine?.canEmbed`: Letzteres brauchte
  // eine dauerhaft geladene Instanz, die es jetzt nicht mehr gibt.
  bool get faceRecognitionAvailable => FaceEngineService.isRecognitionAvailable(_modelsDir!);
  bool get segmentationAvailable => segmentationHalter.installiert;
  bool get captioningAvailable => captioningHalter.installiert;
  bool get uebersetzungEnDeAvailable => uebersetzungEnDeHalter.installiert;

  /// Ob Text erkannt werden kann – über das Betriebssystem (macOS) oder
  /// über das nachgeladene Modell (überall sonst).
  bool get ocrAvailable => Platform.isMacOS || ocrHalter.installiert;
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

  /// Wendet passende Automatisierungsregeln an (Zielalbum, Tags, automatisch
  /// favorisieren) – Verallgemeinerung von [applyCameraPreset] auf Orts-/
  /// Datums-/KI-Tag-Bedingungen statt nur Kamera, siehe AutomationRules in
  /// database.dart. Zwei Aufrufstellen, je nachdem, wann die jeweilige
  /// Bedingung überhaupt geprüft werden kann:
  ///
  /// - [latitude]/[longitude]/[fileCreatedAt] liegen schon beim Import vor
  ///   ([_postProcessNewAsset]) – werten `location`-/`dateRange`-Regeln aus.
  /// - [aiTags] liegen erst nach der KI-Tagging-Stufe der Hintergrundanalyse
  ///   vor ([backfillAiTags]) – wertet `aiTag`-Regeln aus.
  ///
  /// Ein Aufruf mit nur einem Teil der Parameter überspringt die jeweils
  /// nicht auswertbaren Regeltypen folgerichtig (kein Fehler) – so ruft
  /// jede Aufrufstelle dieselbe Methode auf, ohne die andere Bedingungsart
  /// zu kennen.
  ///
  /// [rules] erlaubt Stapelverarbeitungen, die Regeln EINMAL pro Lauf statt
  /// pro Foto zu laden (siehe [backfillAiTags]) – dieselbe Überlegung wie
  /// beim dortigen Vokabular-Laden. Ohne den Parameter werden sie pro
  /// Aufruf frisch geholt, was für den Einzelaufruf beim Import richtig ist
  /// (eine zwischenzeitlich geänderte Regel soll sofort greifen).
  @visibleForTesting
  Future<void> applyAutomationRules(
    String assetId, {
    double? latitude,
    double? longitude,
    DateTime? fileCreatedAt,
    List<String>? aiTags,
    List<AutomationRuleData>? rules,
  }) async {
    for (final rule in rules ?? await db.allAutomationRules()) {
      final bool matches;
      switch (rule.triggerType) {
        case 'location':
          matches = latitude != null &&
              longitude != null &&
              rule.regionCenterLat != null &&
              rule.regionCenterLon != null &&
              rule.regionRadiusKm != null &&
              ReverseGeocoder.haversineKm(latitude, longitude, rule.regionCenterLat!, rule.regionCenterLon!) <=
                  rule.regionRadiusKm!;
        case 'dateRange':
          matches = fileCreatedAt != null &&
              rule.dateFrom != null &&
              rule.dateTo != null &&
              !fileCreatedAt.isBefore(rule.dateFrom!) &&
              !fileCreatedAt.isAfter(rule.dateTo!);
        case 'aiTag':
          matches = aiTags != null && rule.aiTagTerm != null && aiTags.contains(rule.aiTagTerm);
        default:
          matches = false;
      }
      if (!matches) continue;

      if (rule.targetAlbumId != null) {
        await db.addAssetsToAlbum(rule.targetAlbumId!, [assetId]);
      }
      if (rule.autoFavorite) {
        await db.setFavorite(assetId, true);
      }
      final tagIds = await db.tagIdsForAutomationRule(rule.id);
      for (final tagId in tagIds) {
        await db.tagAssetById(assetId, tagId);
      }
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

    // Nicht neben eine rechenintensive Aufgabe legen: Die Analyse arbeitet
    // genau deren Stufen ab – zwei Durchgänge gingen dann dieselbe Liste
    // durch, mit zwei Modellsitzungen im Speicher. Die Anfrage geht nicht
    // verloren, sie wird nachgeholt, sobald die Aufgabe durch ist. Ohne
    // dieses Nachholen bliebe ein direkt nach dem Import gestarteter
    // Durchgang bis zum nächsten Programmstart aus, und frisch importierte
    // Fotos wären ohne Gesichter und ohne Suche.
    if (laufendeSchwerarbeit.isNotEmpty) {
      _analyseZurueckgestellt = true;
      return;
    }
    _analyseZurueckgestellt = false;
    _analyseAbbruch = false;

    final stufen = <({Analysestufe name, Stream<ImportProgress> Function() lauf})>[
      (name: Analysestufe.bildanalyse, lauf: () => _bildinhaltsAnalyse()),
      (name: Analysestufe.texterkennung, lauf: () => backfillOcrText()),
      // Kein eigener CLIP-Schritt mehr – die Embeddings entstehen bereits in
      // der Bildanalyse. [backfillClipEmbeddings] bleibt für den manuellen
      // Aufruf in den Werkzeugen erhalten.
      (name: Analysestufe.schlagwoerter, lauf: () => backfillAiTags(onlyUntagged: true)),
      (name: Analysestufe.bildbeschreibung, lauf: () => backfillCaptions()),
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
          debugPrint('Analysestufe "${stufe.name.name}" fehlgeschlagen, '
              'weiter mit der nächsten: $e');
        }
      }
    } finally {
      _analyse = null;
      _analyseAbbruch = false;
      notifyListeners();
    }
  }

  /// Gesetzt, wenn eine Analyse angefragt wurde, während eine
  /// rechenintensive Aufgabe lief.
  bool _analyseZurueckgestellt = false;

  /// Ob ein zurückgestellter Analysedurchgang aussteht – für die Anzeige.
  bool get analyseZurueckgestellt => _analyseZurueckgestellt;

  /// Holt eine zurückgestellte Analyse nach, sobald die letzte
  /// rechenintensive Aufgabe durch ist.
  void _holeZurueckgestellteAnalyseNach() {
    if (!_analyseZurueckgestellt) return;
    if (laufendeSchwerarbeit.isNotEmpty) return;
    _analyseZurueckgestellt = false;
    unawaited(starteHintergrundanalyse());
  }

  /// Bricht nach der laufenden Datei ab – kein harter Abbruch mitten in
  /// einer Modell-Inferenz.
  void brichHintergrundanalyseAb() {
    if (_analyse == null) return;
    _analyseAbbruch = true;
  }

  // --- Aufgaben, die wirklich im Hintergrund laufen ----------------------

  /// Die laufenden und die eben beendeten Nachholvorgänge, nach ihrer
  /// Kennung.
  ///
  /// Warum hier und nicht im Bildschirm: Die Aufgabenübersicht öffnete
  /// bisher je Aufgabe ein Fortschrittsfenster. Das liess sich weder
  /// verkleinern noch beiseitelegen – wer die Bibliothek während der Arbeit
  /// ansehen wollte, musste den Vorgang abbrechen. Ein Lauf an dieser
  /// Stelle überlebt jeden Bildschirmwechsel.
  final Map<String, Hintergrundlauf> _laeufe = {};

  /// Der Lauf zu einer Kennung, oder `null`, wenn dort gerade nichts steht.
  Hintergrundlauf? lauf(String schluessel) => _laeufe[schluessel];

  /// Alle Läufe, die gerade tatsächlich arbeiten.
  Iterable<Hintergrundlauf> get laufendeAufgaben =>
      _laeufe.values.where((l) => l.laeuft);

  /// Ob überhaupt noch etwas arbeitet – einschliesslich der
  /// Hintergrundanalyse, die ihren eigenen Zustand führt. Grundlage für die
  /// Rückfrage beim Beenden (siehe BeendenWaechter).
  bool get etwasLaeuft => analyseLaeuft || laufendeAufgaben.isNotEmpty;

  /// Die laufenden Aufgaben, die als teure Auswertung gelten – Modell im
  /// Speicher oder dieselbe Arbeit wie eine Stufe der Hintergrundanalyse.
  Iterable<Hintergrundlauf> get laufendeSchwerarbeit =>
      laufendeAufgaben.where((l) => l.rechenintensiv);

  /// Warum eine Aufgabe gerade nicht starten kann – `null` heisst: sie kann.
  ///
  /// Der Grund für diese Prüfung ist eine Nebenwirkung davon, dass die
  /// Aufgaben kein Fenster mehr sperren: Vier Klicks genügten, um
  /// Gesichter, Bildbeschreibung, Einbettung und Übersetzung gleichzeitig
  /// zu starten. Deren Modelle liegen dann zusammen im Speicher (allein
  /// CLIP-Bild 335 MB und die Bildbeschreibung 235 MB, gemessen), und
  /// dieselben Fotos werden vierfach dekodiert. Läuft zusätzlich die
  /// Hintergrundanalyse, arbeiten zwei Durchgänge sogar dieselbe Liste ab
  /// und schreiben einander die Ergebnisse zu.
  ///
  /// Aufgaben ohne Modell (Orte einlesen, XMP schreiben, Live-Photo-Paare)
  /// bleiben davon unberührt – sie kosten nichts, was sich gegenseitig im
  /// Weg stünde.
  Startabweisung? pruefeStart(String schluessel, {required bool rechenintensiv}) {
    if (_laeufe[schluessel]?.laeuft ?? false) return Startabweisung.laeuftBereits;
    if (!rechenintensiv) return null;
    if (analyseLaeuft) return Startabweisung.analyseLaeuft;
    if (laufendeSchwerarbeit.isNotEmpty) return Startabweisung.andereAufgabe;
    return null;
  }

  /// Startet [strom] unter der Kennung [schluessel] und verfolgt seinen
  /// Fortschritt in [lauf].
  ///
  /// Gibt den Grund zurück, wenn nicht gestartet wurde (siehe
  /// [pruefeStart]) – die Oberfläche fragt vorher, prüft hier aber ein
  /// zweites Mal, weil zwischen Frage und Start ein anderer Lauf begonnen
  /// haben kann.
  Future<Startabweisung?> starteAufgabe({
    required String schluessel,
    required String titel,
    required String leermeldung,
    required Stream<ImportProgress> Function() strom,
    bool rechenintensiv = false,
  }) async {
    final abweisung = pruefeStart(schluessel, rechenintensiv: rechenintensiv);
    if (abweisung != null) return abweisung;

    final lauf = Hintergrundlauf(
      schluessel: schluessel,
      titel: titel,
      leermeldung: leermeldung,
      rechenintensiv: rechenintensiv,
    );
    _laeufe[schluessel] = lauf;
    notifyListeners();

    // Auf [Hintergrundlauf.abschluss] warten statt auf ein `await for`:
    // Der Lauf muss von aussen abbrechbar sein, und ein gekündigtes
    // Abonnement meldet kein `onDone` mehr – ein `await for` bliebe dann
    // für immer stehen.
    // Gedrosselt melden. Ein Lauf über 8000 Fotos meldet 8000 Fortschritte,
    // und an diesem ChangeNotifier hängt über den Consumer in main.dart der
    // gesamte Widget-Baum – jede Meldung baut also die ganze App neu auf.
    // Fünf Aktualisierungen je Sekunde sind für eine Zahl, die ein Mensch
    // liest, reichlich.
    var letzteMeldung = DateTime.fromMillisecondsSinceEpoch(0);
    const drosselMs = 200;

    try {
      lauf.abo = strom().listen(
        (p) {
          lauf.erledigt = p.done;
          lauf.gesamt = p.total;
          lauf.datei = p.currentFile;
          final jetzt = DateTime.now();
          // Der letzte Schritt kommt immer durch, sonst bliebe die Anzeige
          // kurz vor der Gesamtzahl stehen.
          if (p.done >= p.total ||
              jetzt.difference(letzteMeldung).inMilliseconds >= drosselMs) {
            letzteMeldung = jetzt;
            notifyListeners();
          }
        },
        onError: (Object e) {
          lauf.fehler = e;
          lauf.schliesseAb();
        },
        onDone: lauf.schliesseAb,
        cancelOnError: true,
      );
      await lauf.abschluss;
    } catch (e) {
      lauf.fehler = e;
    } finally {
      lauf.beendet = true;
      lauf.abo = null;
      notifyListeners();
      // Eine wegen dieser Aufgabe zurückgestellte Analyse jetzt nachholen.
      _holeZurueckgestellteAnalyseNach();
    }
    return null;
  }

  /// Bricht den Lauf zu [schluessel] ab.
  ///
  /// Das Kündigen des Abonnements hält den Generator bei seinem nächsten
  /// `yield` an – also nach der gerade bearbeiteten Datei, nicht mitten in
  /// einer Modell-Inferenz. Die `finally`-Blöcke der Nachholvorgänge laufen
  /// dabei durch und geben ihre geliehenen Modelle zurück.
  void brichAufgabeAb(String schluessel) {
    final lauf = _laeufe[schluessel];
    if (lauf == null || lauf.beendet) return;
    lauf.abgebrochen = true;
    final abo = lauf.abo;
    lauf.abo = null;
    unawaited(abo?.cancel());
    lauf.schliesseAb();
    lauf.beendet = true;
    notifyListeners();
  }

  /// Räumt einen beendeten Lauf weg, damit die Karte wieder ihre Zahlen
  /// zeigt. Ein noch laufender bleibt stehen.
  void verwerfeLauf(String schluessel) {
    if (_laeufe[schluessel]?.laeuft ?? false) return;
    if (_laeufe.remove(schluessel) != null) notifyListeners();
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
    await applyAutomationRules(
      asset.id,
      latitude: asset.latitude,
      longitude: asset.longitude,
      fileCreatedAt: asset.fileCreatedAt,
    );

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
    required FaceEngineService engine,
    EyeStateService? eyeState,
    required bool deleteExistingUnassigned,
  }) async {
    if (deleteExistingUnassigned) {
      // Die Ausschnitte der gelöschten Zeilen müssen mit weg. Sonst
      // hinterlässt jedes „alle Fotos erneut scannen" den kompletten alten
      // Bestand als Dateien ohne Datenbankzeile – siehe
      // [AppDatabase.deleteUnassignedFacesForAsset].
      for (final pfad in await db.deleteUnassignedFacesForAsset(asset.id)) {
        await paths.deletePermanently(pfad);
      }
    }

    // Was beiseitegelegt wurde, darf ein erneuter Scan nicht als neue
    // Erkennung zurückbringen. Das Löschen oben verschont diese Gesichter
    // zwar, aber die Erkennung findet dieselbe Stelle wieder – ohne diesen
    // Abgleich stünde neben jedem ignorierten Plakatgesicht nach dem
    // nächsten Scan ein frisches, unbenanntes.
    final ignorierteBoxen = [
      for (final f in await db.facesForAsset(asset.id))
        if (f.isIgnored) DetectedFace(f.boxX, f.boxY, f.boxW, f.boxH, 1.0),
    ];

    try {
      if (decoded != null) {
        final boxes = await engine.detectFaces(decoded);
        for (final box in boxes) {
          // Dieselbe Schwelle wie die Unterdrückung mehrfacher Erkennungen
          // derselben Stelle (FaceEngineService.detectFaces) – es ist
          // dieselbe Frage: Ist das nochmal dieses Gesicht?
          if (ignorierteBoxen
              .any((alt) => FacePostprocess.iou(alt, box) > 0.3)) {
            continue;
          }
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
          if (eyeState != null) {
            try {
              eyeOpenScore = await eyeState.eyeOpenScore(decoded, box);
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
  Future<void> _scanFacesForAsset(
    AssetData asset, {
    required FaceEngineService engine,
    EyeStateService? eyeState,
    required bool deleteExistingUnassigned,
  }) async {
    final decoded = await _decodeAsset(asset);
    await _scanFacesForDecodedAsset(
      asset,
      decoded,
      engine: engine,
      eyeState: eyeState,
      deleteExistingUnassigned: deleteExistingUnassigned,
    );
  }

  /// Manueller (Re-)Scan der Gesichtserkennung, z.B. nachdem das YuNet-Modell
  /// erst nachträglich installiert wurde oder ein Erkennungs-Bug (wie die
  /// BGR/RGB-Verwechslung) behoben wurde.
  ///
  /// [onlyNewPhotos] = true: nur Fotos, die noch nie gescannt wurden.
  /// [onlyNewPhotos] = false: ALLE Fotos erneut scannen (dauert entsprechend
  /// länger bei großen Bibliotheken).
  Stream<ImportProgress> rescanFaces({required bool onlyNewPhotos}) async* {
    // Erst die Arbeit ermitteln, dann die Modelle holen – siehe
    // [_bildinhaltsAnalyse].
    final assets = await db.assetsForFaceScan(onlyNew: onlyNewPhotos);
    if (assets.isEmpty) {
      yield ImportProgress(0, 0);
      return;
    }
    final engine = await faceEngineHalter.leihen();
    if (engine == null) {
      yield ImportProgress(0, 0);
      return;
    }
    try {
      final eyeState = await eyeStateHalter.leihen();
      try {
        var done = 0;
        yield ImportProgress(0, assets.length);
        for (final asset in assets) {
          await _scanFacesForAsset(
            asset,
            engine: engine,
            eyeState: eyeState,
            deleteExistingUnassigned: !onlyNewPhotos,
          );
          done++;
          yield ImportProgress(done, assets.length, currentFile: asset.originalFileName);
        }
      } finally {
        if (eyeState != null) eyeStateHalter.zurueckgeben();
      }
    } finally {
      faceEngineHalter.zurueckgeben();
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

    // Blockweise schreiben statt je Foto einzeln.
    //
    // Diese Stufe ist die einzige der Nachträge, bei der die eigentliche
    // Arbeit im Hauptspeicher stattfindet – kein Dateizugriff, kein Modell,
    // nur ein Nachschlagen im Ortsraster. Damit wird das Schreiben zum
    // Kostentreiber: Für 5000 Fotos gemessen 2131 ms einzeln gegen 139 ms in
    // Blöcken, bei 359 ms für die Auflösungen selbst.
    //
    // Blöcke statt einer einzigen grossen Transaktion, damit der
    // Fortschrittsbalken weiterläuft und ein Abbruch nicht alles verwirft.
    const blockGroesse = 200;
    var block = <({String id, GeoLookupResult treffer})>[];

    Future<void> blockSchreiben() async {
      if (block.isEmpty) return;
      final zuSchreiben = block;
      block = [];
      await db.transaction(() async {
        for (final e in zuSchreiben) {
          await db.setLocationNames(e.id,
              country: e.treffer.country, state: e.treffer.state, city: e.treffer.city);
        }
      });
    }

    for (final asset in assets) {
      final result = engine.lookup(asset.latitude!, asset.longitude!);
      if (result != null) block.add((id: asset.id, treffer: result));
      if (block.length >= blockGroesse) await blockSchreiben();
      done++;
      yield ImportProgress(done, assets.length, currentFile: asset.originalFileName);
    }
    await blockSchreiben();
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

  /// Trägt Aufnahmedatum, Kamera und Objektiv für RAW-Fotos nach, deren
  /// Metadaten beim Import nicht gelesen werden konnten – und verschiebt
  /// die Datei, wenn sich dadurch der Monat ändert.
  ///
  /// Anlass: `package:exif` liest nur TIFF/JPEG. Bei CR3 (ISO-BMFF, wie
  /// MP4) kamen NULL Tags heraus, und der Import fiel für das Datum auf
  /// den Zeitstempel der Quelldatei zurück. Das ist der teurere Schaden:
  /// In einer Bibliothek mit 909 CR3-Dateien lagen 891 Daten falsch, 517
  /// davon im falschen Monat und 236 im falschen Jahr.
  ///
  /// Reihenfolge beim Verschieben: erst die Datei umhängen, dann die
  /// Datenbank. Scheitert die Datenbank, wird die Datei zurückgelegt.
  /// Andersherum zeigte die Datenbank auf einen Pfad, den es noch nicht
  /// gibt.
  Stream<ImportProgress> korrigiereAufnahmedaten() async* {
    final alle = await db.assetsFuerDatumskorrektur();
    // Nur RAW: Bei JPEG gab es den Rückfall auf den Dateizeitstempel nie,
    // dort kam das Datum immer aus den EXIF-Daten oder gar nicht.
    final kandidaten = [
      for (final a in alle)
        if (rawImageExtensions.contains(p.extension(a.relativePath).toLowerCase())) a,
    ];
    var done = 0;
    yield ImportProgress(0, kandidaten.length);
    for (final asset in kandidaten) {
      final datei = paths.absolute(asset.relativePath);
      if (await datei.exists()) {
        final daten = await importService.readAufnahmedaten(datei);
        if (!daten.kamera.isEmpty) {
          await db.setCameraMetadata(asset.id, daten.kamera);
          await applyCameraPreset(asset.id,
              cameraMake: daten.kamera.make, cameraModel: daten.kamera.model);
        }
        final neu = daten.zeitpunkt;
        // Eine Minute Spielraum: Sekundenbruchteile und Rundungen der
        // verschiedenen Wege sollen keine Verschiebung auslösen.
        if (neu != null &&
            neu.difference(asset.fileCreatedAt).abs() > const Duration(minutes: 1)) {
          await _datumUmschreiben(asset, neu);
        }
      }
      done++;
      yield ImportProgress(done, kandidaten.length,
          currentFile: asset.originalFileName);
    }
  }

  Future<void> _datumUmschreiben(AssetData asset, DateTime neu) async {
    final alterPfad = asset.relativePath;
    final neuerPfad = paths.originalRelativePath(
        neu, asset.id, p.extension(alterPfad).toLowerCase());
    if (neuerPfad == alterPfad) {
      await db.setAufnahmezeitpunkt(asset.id, neu);
      return;
    }
    final quelle = paths.absolute(alterPfad);
    final ziel = paths.absolute(neuerPfad);
    try {
      await ziel.parent.create(recursive: true);
      await quelle.rename(ziel.path);
    } on FileSystemException catch (e) {
      debugPrint('Datumskorrektur: ${asset.id} nicht verschiebbar: $e');
      // Das Datum trotzdem richtigstellen – ein falsch einsortierter
      // Ordner ist das kleinere Übel gegenüber einem falschen Datum in
      // Zeitleiste, Kalender und Suche.
      await db.setAufnahmezeitpunkt(asset.id, neu);
      return;
    }
    try {
      await db.setAufnahmezeitpunkt(asset.id, neu, neuerPfad: neuerPfad);
    } catch (e) {
      // Zurücklegen, sonst zeigt die Datenbank auf eine Datei, die dort
      // nicht mehr liegt.
      try {
        await ziel.rename(quelle.path);
      } catch (_) {}
      rethrow;
    }
  }

  /// Erkennt Text nachträglich für Fotos, die vor Einführung der OCR-Suche
  /// importiert wurden (siehe [_postProcessNewAsset], wo dasselbe seit
  /// diesem Feature automatisch bei jedem Import läuft).
  // -----------------------------------------------------------------------
  // Überwachter Ordner
  // -----------------------------------------------------------------------

  Timer? _ordnerTimer;
  bool _ordnerLaeuft = false;

  /// Wie oft nachgesehen wird. Bewusst Abtastung statt echter
  /// Dateisystem-Ereignisse: Letzteres bräuchte eine weitere Abhängigkeit,
  /// und ein Ordner, in den eine Kamera entlädt, verträgt ein paar Minuten
  /// Verzögerung ohne Weiteres.
  static const _ordnerIntervall = Duration(minutes: 5);

  /// Sieht im überwachten Ordner nach neuen Dateien und importiert sie.
  ///
  /// Gefahrlos wiederholbar: Der Import erkennt bereits vorhandene Dateien
  /// an ihrer Prüfsumme und legt sie kein zweites Mal an. Deshalb genügt
  /// hier schlichtes Nachsehen – es braucht keine Liste dessen, was schon
  /// gesehen wurde, die bei jedem Fehlerfall aus dem Tritt geriete.
  ///
  /// Die Dateien bleiben, wo sie sind. Sie zu verschieben oder zu löschen
  /// wäre ein Eingriff in fremde Ordner, den ein Programm ungefragt nicht
  /// tun sollte – auch wenn andere Programme das so halten.
  Future<int> pruefeUeberwachtenOrdner() async {
    if (_ordnerLaeuft) return 0;
    final eintrag = await db.ueberwachterOrdner();
    if (eintrag == null) return 0;

    _ordnerLaeuft = true;
    try {
      // Unter macOS erlischt der Zugriff auf einen fremden Ordner bei jedem
      // Programmstart und muss aus dem gespeicherten Merkmal wiederhergestellt
      // werden (siehe FolderAccess).
      final zugriff = FolderAccess.forCurrentPlatform();
      var pfad = await zugriff.resolveRoot(path: eintrag.pfad, token: eintrag.token);
      // Ohne Merkmal liefert die macOS-Umsetzung grundsätzlich null – das
      // ist für Ordner ausserhalb des Programmbereichs richtig, schliesst
      // aber auch solche aus, die ohnehin gelesen werden dürfen (innerhalb
      // des eigenen Bereichs, und unter Linux/Windows generell). Deshalb
      // ein Rückfall auf den blossen Pfad: Fehlt der Zugriff tatsächlich,
      // scheitert das Auflisten gleich darauf und wird unten aufgefangen.
      pfad ??= Directory(eintrag.pfad).existsSync() ? eintrag.pfad : null;
      if (pfad == null) {
        debugPrint('Überwachter Ordner nicht erreichbar: ${eintrag.pfad}');
        return 0;
      }

      final dateien = await importService.collectSupportedFilesInFolder(pfad);
      if (dateien.isEmpty) return 0;

      var neue = 0;
      await for (final p in importFiles(dateien)) {
        if (p.assetId != null) neue++;
      }
      return neue;
    } catch (e) {
      debugPrint('Überwachter Ordner konnte nicht geprüft werden: $e');
      return 0;
    } finally {
      _ordnerLaeuft = false;
    }
  }

    // -----------------------------------------------------------------------
  // Entwicklungseinstellungen übertragen
  // -----------------------------------------------------------------------

  /// Zuletzt kopierte Entwicklungseinstellungen – Zwischenablage nach dem
  /// Vorbild von Lightrooms "Einstellungen kopieren/einfügen". Bewusst nur
  /// im Speicher: Sie soll wie eine Zwischenablage wirken und nicht über
  /// einen Programmstart hinaus überraschen.
  DevelopSettingsData? _kopierteEntwicklung;
  DevelopSettingsData? get kopierteEntwicklung => _kopierteEntwicklung;
  bool get hatKopierteEntwicklung => _kopierteEntwicklung != null;

  /// Legt die GESPEICHERTEN Einstellungen eines Fotos in die
  /// Zwischenablage. Gibt `false` zurück, wenn das Foto gar nicht
  /// entwickelt wurde. Für Aufrufer ausserhalb des Entwickeln-Bildschirms,
  /// die nur eine Foto-Kennung haben.
  Future<bool> kopiereEntwicklungVon(String assetId) async {
    final s = await db.developSettingsForAsset(assetId);
    if (s == null) return false;
    _kopierteEntwicklung = s;
    notifyListeners();
    return true;
  }

  /// Legt einen beliebigen Satz Werte in die Zwischenablage – gedacht für
  /// den Entwickeln-Bildschirm, der den AKTUELLEN Reglerstand kopiert.
  ///
  /// Die erste Fassung kopierte dort nur, was schon gespeichert war. Das
  /// klang vorsichtig ("übertragen wird, was das Foto auch zeigt"), führte
  /// aber in eine Sackgasse: Speichern schliesst den Bildschirm, man kam
  /// also nach dem Einstellen gar nicht mehr zum Kopieren
  /// (Fehlerbericht). Wer Werte kopiert, will sie weitergeben – ob er sie
  /// für dieses Foto auch behält, ist eine andere Entscheidung.
  void setzeKopierteEntwicklung(DevelopSettingsData werte) {
    _kopierteEntwicklung = werte;
    notifyListeners();
  }

  void leereEntwicklungsZwischenablage() {
    _kopierteEntwicklung = null;
    notifyListeners();
  }

  /// Überträgt die kopierten Einstellungen auf [zielIds] und rendert jedes
  /// Zielfoto dabei neu – ohne das Rendern bliebe die Änderung unsichtbar,
  /// weil die Anzeige aus der entwickelten Datei kommt und nicht aus den
  /// Reglerwerten.
  ///
  /// Masken werden bewusst NICHT mitübertragen: Sie umschliessen einen Ort
  /// im Quellbild (ein Gesicht, einen Himmel) und hätten im Zielbild keine
  /// Entsprechung – eine Maske um den Kopf auf Foto A liegt auf Foto B
  /// irgendwo im Nichts. Übertragen werden die Werte, die für das ganze
  /// Bild gelten.
  ///
  /// Der bisherige Stand jedes Zielfotos wandert über [saveDevelopResult]
  /// in dessen Verlauf; ein versehentlicher Übertrag lässt sich also je
  /// Foto im Entwickeln-Bildschirm wieder zurückholen.
  Stream<ImportProgress> uebertrageEntwicklung(List<String> zielIds) async* {
    final quelle = _kopierteEntwicklung;
    if (quelle == null) {
      yield ImportProgress(0, 0);
      return;
    }

    // Gesperrte Fotos und Videos scheiden aus: Bei gesperrten läge das
    // Original verschlüsselt vor, Videos kennen keine Entwicklung.
    final ziele = <AssetData>[];
    for (final id in zielIds) {
      final a = await db.assetById(id);
      if (a == null || a.isLocked || a.type != 'IMAGE') continue;
      if (a.id == quelle.assetId) continue;
      ziele.add(a);
    }

    final werte = DevelopAdjustments(
      exposure: quelle.exposure,
      temperature: quelle.temperature,
      tint: quelle.tint,
      contrast: quelle.contrast,
      shadows: quelle.shadows,
      sharpness: quelle.sharpness,
      noiseReduction: quelle.noiseReduction,
      lensCorrectionEnabled: quelle.lensCorrectionEnabled,
      // Kurve und Mischer gehören genauso zur Entwicklung wie die Regler.
      // Ohne diese beiden Zeilen übernähme das Ziel die Belichtung, aber
      // nicht die Gradation – und niemand sähe, dass etwas fehlt.
      toneCurve: toneCurveAus(quelle.toneCurveJson),
      colorMixer: colorMixerAus(quelle.colorMixerJson),
    );

    var done = 0;
    yield ImportProgress(0, ziele.length);
    for (final asset in ziele) {
      try {
        final bytes = await NativeImageConverter.developImage(
          paths.absolute(asset.relativePath),
          adjustments: werte,
          maxDimension: 4096,
          quality: 0.92,
        );
        if (bytes == null) throw Exception('Bild konnte nicht gerendert werden.');

        final zielPfad = paths.developedRelativePath(asset.id);
        final datei = paths.absolute(zielPfad);
        await datei.parent.create(recursive: true);
        await datei.writeAsBytes(bytes);

        await db.saveDevelopResult(
          asset.id,
          settings: DevelopSettingsCompanion.insert(
            assetId: asset.id,
            exposure: Value(werte.exposure),
            temperature: Value(werte.temperature),
            tint: Value(werte.tint),
            contrast: Value(werte.contrast),
            shadows: Value(werte.shadows),
            sharpness: Value(werte.sharpness),
            noiseReduction: Value(werte.noiseReduction),
            lensCorrectionEnabled: Value(werte.lensCorrectionEnabled),
            toneCurveJson: Value(quelle.toneCurveJson),
            colorMixerJson: Value(quelle.colorMixerJson),
            updatedAt: DateTime.now(),
          ),
          developedRelativePath: zielPfad,
        );
      } catch (e) {
        debugPrint('Entwicklung übertragen fehlgeschlagen für ${asset.originalFileName}: $e');
      }
      done++;
      yield ImportProgress(done, ziele.length, currentFile: asset.originalFileName);
    }
  }

  Stream<ImportProgress> backfillOcrText() async* {
    final assets = await db.assetsForOcrBackfill();
    if (assets.isEmpty) {
      yield ImportProgress(0, 0);
      return;
    }

    // Auf macOS erledigt das Vision-Framework die Arbeit ohne Modell und
    // ohne Download; überall sonst braucht es die beiden ONNX-Modelle.
    // Das Modell wird für den ganzen Lauf EINMAL geliehen, nicht je Foto –
    // dasselbe Muster wie bei den Bildbeschreibungen.
    final ueberSystem = Platform.isMacOS;
    OcrService? modell;
    if (!ueberSystem) {
      modell = await ocrHalter.leihen();
      if (modell == null) {
        yield ImportProgress(0, 0);
        return;
      }
    }

    try {
      var done = 0;
      yield ImportProgress(0, assets.length);
      for (final asset in assets) {
        // Pro Foto abgesichert: Ein einzelner Fehlschlag (beschädigte
        // Datei, Fehler im nativen Aufruf) darf nicht den ganzen Lauf
        // abbrechen.
        try {
          String? text;
          if (ueberSystem) {
            text = await NativeImageConverter.recognizeText(_decodableFile(asset));
          } else {
            final bild = await _decodeAsset(asset);
            if (bild != null) text = await modell!.erkenneText(bild);
          }
          if (text != null) {
            await db.setOcrResult(asset.id, text);
          }
        } on LesungLiefertNichts catch (e) {
          // NICHT als leeres Ergebnis speichern: Das Foto würde als
          // durchsucht vermerkt und nach einer Reparatur nie wieder
          // drankommen. Es bleibt offen, der Lauf geht weiter.
          debugPrint('Texterkennung: ${e.stellen} Stellen mit Schrift in '
              '${asset.originalFileName}, keine lesbar – Foto bleibt offen.');
        } catch (e) {
          debugPrint('Texterkennung fehlgeschlagen für ${asset.originalFileName}: $e');
        }
        done++;
        yield ImportProgress(done, assets.length, currentFile: asset.originalFileName);
      }
    } finally {
      if (!ueberSystem) ocrHalter.zurueckgeben();
    }
  }

  /// Erzeugt KI-Bildbeschreibungen nachträglich für Fotos, die vor
  /// Installation des Modells importiert wurden (Captions entstehen sonst
  /// nur automatisch beim Import, siehe [_postProcessNewAsset]).
  /// [alle] beschreibt auch Fotos neu, die schon eine Beschreibung haben –
  /// nach dem Modellwechsel der sinnvolle Weg, siehe
  /// [AppDatabase.assetsForCaptionBackfill].
  Stream<ImportProgress> backfillCaptions({bool alle = false}) async* {
    // Erst die Arbeit ermitteln, dann das Modell holen – siehe
    // [_bildinhaltsAnalyse]. Das Bildbeschreibungs-Modell ist mit 275 MB
    // das zweitgrösste; es für eine leere Liste zu laden war der teuerste
    // Einzelposten des Fehlers.
    final assets = await db.assetsForCaptionBackfill(alle: alle);
    if (assets.isEmpty) {
      yield ImportProgress(0, 0);
      return;
    }
    final service = await captioningHalter.leihen();
    if (service == null) {
      yield ImportProgress(0, 0);
      return;
    }
    // Der Übersetzer wird für den ganzen Lauf einmal geliehen, nicht je
    // Foto – sonst würde ein 100-MB-Modell pro Bild geladen und wieder
    // freigegeben. Null heisst schlicht: nicht installiert oder
    // abgeschaltet, dann bleibt es bei der englischen Beschreibung.
    final uebersetzer = await db.uebersetzeBeschreibungen()
        ? await uebersetzungEnDeHalter.leihen()
        : null;

    try {
      var done = 0;
      yield ImportProgress(0, assets.length);
      for (final asset in assets) {
        try {
          final decoded = await _decodeAsset(asset);
          if (decoded == null) throw Exception('Bild konnte nicht dekodiert werden.');
          final caption = await service.generateCaption(decoded);
          String? deutsch;
          if (uebersetzer != null && caption.isNotEmpty) {
            try {
              deutsch = await uebersetzer.translate(caption);
            } catch (e) {
              // Eine fehlgeschlagene Übersetzung darf die Beschreibung
              // nicht mitreissen – das englische Original ist brauchbar.
              debugPrint('Übersetzung fehlgeschlagen für ${asset.originalFileName}: $e');
            }
          }
          await db.setAiCaption(asset.id, caption, deutsch: deutsch);
        } catch (e) {
          debugPrint('KI-Bildbeschreibung fehlgeschlagen für ${asset.originalFileName}: $e');
        }
        done++;
        yield ImportProgress(done, assets.length, currentFile: asset.originalFileName);
      }
    } finally {
      if (uebersetzer != null) uebersetzungEnDeHalter.zurueckgeben();
      captioningHalter.zurueckgeben();
    }
  }

  /// Übersetzt vorhandene englische Bildunterschriften ins Deutsche, ohne
  /// das Beschreibungsmodell zu bemühen.
  ///
  /// Das ist der Weg für alle, die die Übersetzung erst später einschalten:
  /// Die englischen Sätze stehen längst in der Datenbank, es fehlt nur ihre
  /// Übertragung. Der Umweg über [backfillCaptions] mit `alle: true` würde
  /// dafür das 275-MB-Modell über die gesamte Bibliothek laufen lassen und
  /// dabei ausgerechnet die vorhandenen Sätze wegwerfen.
  ///
  /// [alle] übersetzt auch das, was schon eine deutsche Fassung hat – nach
  /// einem Modellwechsel der sinnvolle Weg.
  Stream<ImportProgress> uebersetzeBildbeschreibungen({bool alle = false}) async* {
    // Erst die Arbeit ermitteln, dann das Modell holen – siehe
    // [_bildinhaltsAnalyse].
    final assets = await db.assetsForCaptionTranslation(alle: alle);
    if (assets.isEmpty) {
      yield ImportProgress(0, 0);
      return;
    }
    final uebersetzer = await uebersetzungEnDeHalter.leihen();
    if (uebersetzer == null) {
      yield ImportProgress(0, 0);
      return;
    }

    try {
      var done = 0;
      yield ImportProgress(0, assets.length);
      for (final asset in assets) {
        final englisch = asset.aiCaption?.trim() ?? '';
        if (englisch.isNotEmpty) {
          try {
            final deutsch = await uebersetzer.translate(englisch);
            if (deutsch.trim().isNotEmpty) await db.setAiCaptionDe(asset.id, deutsch.trim());
          } catch (e) {
            // Ein Satz, an dem sich das Modell verschluckt, darf den Lauf
            // über die ganze Bibliothek nicht beenden.
            debugPrint('Übersetzung fehlgeschlagen für ${asset.originalFileName}: $e');
          }
        }
        done++;
        yield ImportProgress(done, assets.length, currentFile: asset.originalFileName);
      }
    } finally {
      uebersetzungEnDeHalter.zurueckgeben();
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
    // Nichts zu tun? Dann auch nichts laden. Ohne diese Abkürzung lieh sich
    // die Stufe ihre Modelle, sah danach eine leere Liste und gab sie
    // ungenutzt wieder frei – bei jedem Programmstart, weil die Analyse dort
    // automatisch anläuft. Gemessen belegte die App so 1076 MB statt 214 MB,
    // ohne ein einziges Foto anzufassen; der ganze Zweck des bedarfsweisen
    // Ladens war damit für den Normalfall aufgehoben (Audit-Fund).
    if (kandidaten.isEmpty) {
      yield ImportProgress(0, 0);
      return;
    }
    // Einmal für den ganzen Durchlauf geliehen (siehe ModellHalter.leihen)
    // statt bei tausenden Fotos das Modell implizit ständig neu zu laden.
    // Nur der Bild-Encoder: Hier entstehen ausschliesslich Bild-Embeddings.
    final clip = await clipBildHalter.leihen();
    try {
      final gesichter = await faceEngineHalter.leihen();
      try {
        final augenzustand = gesichter != null ? await eyeStateHalter.leihen() : null;
        try {
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
                    await _scanFacesForDecodedAsset(
                      asset,
                      decoded,
                      engine: gesichter,
                      eyeState: augenzustand,
                      deleteExistingUnassigned: false,
                    );
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
        } finally {
          if (augenzustand != null) eyeStateHalter.zurueckgeben();
        }
      } finally {
        if (gesichter != null) faceEngineHalter.zurueckgeben();
      }
    } finally {
      if (clip != null) clipBildHalter.zurueckgeben();
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

  /// Löscht eine einzelne Erkennung samt ihrem Ausschnitt auf der Platte.
  Future<void> loescheGesicht(String faceId) async {
    final pfad = await db.loescheGesicht(faceId);
    if (pfad != null) await paths.deletePermanently(pfad);
  }

  /// Löscht alle unbenannten Gesichts-Erkennungen samt ihrer Ausschnitte
  /// auf der Platte und liefert, wie viele es waren.
  ///
  /// Die Dateien mitzunehmen ist der eigentliche Grund, warum das hier
  /// steht und nicht in der Datenbankschicht: Blieben die Ausschnitte
  /// liegen, wäre der Platz nicht frei – und genau der ist der einzige
  /// Vorteil des Löschens gegenüber dem Beiseitelegen.
  Future<int> loescheAlleUnbenanntenErkennungen() async {
    final ergebnis = await db.loescheAlleUnbenanntenErkennungen();
    for (final pfad in ergebnis.pfade) {
      await paths.deletePermanently(pfad);
    }
    return ergebnis.anzahl;
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
  /// [alle] rechnet auch bereits vorhandene Einbettungen neu – für den
  /// Fall, dass sich die Bildvorverarbeitung geändert hat.
  Stream<ImportProgress> backfillClipEmbeddings({bool alle = false}) async* {
    // Erst die Arbeit ermitteln, dann das Modell holen – siehe
    // [_bildinhaltsAnalyse].
    final assets = await db.assetsForEmbeddingBackfill(alle: alle);
    if (assets.isEmpty) {
      yield ImportProgress(0, 0);
      return;
    }
    final service = await clipBildHalter.leihen();
    if (service == null) {
      yield ImportProgress(0, 0);
      return;
    }
    try {
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
    } finally {
      clipBildHalter.zurueckgeben();
    }
  }

  /// Berechnet automatische KI-Tags nachträglich (siehe [AiTaggingService])
  /// – für Fotos, die vor Einführung dieser Funktion importiert wurden oder
  /// wenn das CLIP-Modell erst nachträglich installiert wurde. Nutzt ein
  /// bereits gespeichertes CLIP-Embedding weiter, falls vorhanden, statt es
  /// neu zu berechnen.
  Stream<ImportProgress> backfillAiTags({required bool onlyUntagged}) async* {
    // Erst nachsehen, ob es Arbeit gibt – Modelle zu leihen kostet hier
    // besonders viel (beide CLIP-Encoder, 577 MB), und bei einer fertig
    // ausgewerteten Bibliothek wäre es reine Verschwendung. Siehe
    // [_bildinhaltsAnalyse] für den gemessenen Effekt.
    final assets = await db.assetsForAiTagging(onlyUntagged: onlyUntagged);
    if (assets.isEmpty) {
      yield ImportProgress(0, 0);
      return;
    }
    // Die einzige Stelle, die BEIDE CLIP-Encoder braucht: das Foto wird
    // als Bild eingebettet, die Vokabelbegriffe als Text (siehe
    // AiTaggingService.suggestTags). Hier fällt die Aufteilung also nicht
    // ins Gewicht – die übrigen Stellen sparen dafür je die Hälfte.
    final clipBild = await clipBildHalter.leihen();
    final clipText = clipBild == null ? null : await clipTextHalter.leihen();
    if (clipBild == null || clipText == null) {
      if (clipBild != null) clipBildHalter.zurueckgeben();
      yield ImportProgress(0, 0);
      return;
    }
    try {
      // Einmal pro Lauf statt pro Asset gelesen – das Vokabular ändert sich
      // während eines laufenden Backfills nicht, ein SELECT pro Foto wäre
      // gegenüber der ohnehin pro Foto anfallenden CLIP-Inferenz reine Verschwendung.
      final vocabulary = await db.aiTagVocabularyTerms();
      // Aus demselben Grund wie das Vokabular einmal pro Lauf statt pro
      // Foto geladen (siehe applyAutomationRules' `rules`-Parameter).
      final automationRules = await db.allAutomationRules();
      var done = 0;
      yield ImportProgress(0, assets.length);
      for (final asset in assets) {
        try {
          var embedding = await db.embeddingForAsset(asset.id);
          if (embedding == null) {
            final decoded = await _decodeAsset(asset);
            if (decoded == null) throw Exception('Bild konnte nicht dekodiert werden.');
            embedding = await clipBild.embedImage(decoded);
            await db.saveEmbedding(asset.id, embedding);
          }
          final tags = await aiTaggingService.suggestTags(
            clipText,
            embedding,
            vocabulary,
            insEnglische: insEnglische,
          );
          for (final tag in tags) {
            await db.tagAsset(asset.id, tag);
          }
          if (tags.isNotEmpty) {
            await applyAutomationRules(asset.id, aiTags: tags, rules: automationRules);
          }
          // Auch bei LEERER Trefferliste vermerken: "kein Begriff passt" ist
          // ein Ergebnis, kein offener Posten. Ohne diesen Vermerk bliebe das
          // Foto für immer Kandidat und die Stufe lüde bei jedem Start erneut
          // beide CLIP-Encoder, um wieder nichts zu finden (Audit-Fund).
          // Bewusst NUR im Erfolgsfall – ein abgebrochener Durchlauf (siehe
          // catch) soll erneut versucht werden.
          await db.markAiTagsScanned([asset.id]);
        } catch (e) {
          debugPrint('KI-Tagging fehlgeschlagen für ${asset.originalFileName}: $e');
        }
        done++;
        yield ImportProgress(done, assets.length, currentFile: asset.originalFileName);
      }
    } finally {
      clipTextHalter.zurueckgeben();
      clipBildHalter.zurueckgeben();
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
    try {
      if (encrypt) {
        await VaultCrypto.encryptFile(file, tmp, key);
      } else {
        await VaultCrypto.decryptFile(file, tmp, key);
      }
      await tmp.rename(file.path);
    } finally {
      // Scheitert der Durchgang, bleibt sonst ein Rumpf neben dem Original
      // liegen: beim Entsperren Klartext einer gesperrten Datei, beim
      // Sperren Chiffretext, den niemand mehr zuordnen kann. Das Original
      // ist in beiden Fällen unangetastet – nur der Rumpf muss weg.
      if (await tmp.exists()) await tmp.delete();
    }
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
    // Der Ausschnitt ist jetzt Chiffrat – ein Profilbild, das darauf
    // zeigt, bliebe leer.
    await db.verlegeProfilbilderVon([asset.id]);
    if (asset.linkedAssetId != null) {
      final partner = await db.assetById(asset.linkedAssetId!);
      if (partner != null && !partner.isLocked) {
        await _encryptAssetFiles(partner, key);
        await db.setAssetsLocked([partner.id], true);
        await db.clearDerivedContentData([partner.id]);
        await db.verlegeProfilbilderVon([partner.id]);
      }
    }
  }

  /// Löscht die von [AppDatabase.clearDerivedContentData] genannten
  /// Dateien – Gesichts-Ausschnitte gesperrter Fotos.
  ///
  /// Fehlt eine Datei bereits, ist das kein Fehler: Das Ziel ist, dass sie
  /// weg ist.
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
    // Über den Hash des Pfades, nicht über ersetzte Trennzeichen: „a/b.jpg"
    // und „a_b.jpg" wurden sonst auf denselben Namen abgebildet und konnten
    // sich gegenseitig anzeigen.
    final safeName = sha256.convert(utf8.encode(relativePath)).toString();
    final target = File(p.join(cacheDir.path, safeName));
    if (!await target.exists()) {
      // Erst unter eigenem Namen entschlüsseln, dann umbenennen. Zwei
      // Gründe, beide aus Prüfrunde 8:
      //
      // Die Ansicht kann dieselbe Datei zweimal gleichzeitig anfordern –
      // eine Kachel, die aus dem Bild scrollt und zurückkommt, startet
      // einen zweiten Durchgang, während der erste noch schreibt. Beide
      // sähen "gibt es noch nicht" und schrieben ineinander. Das Umbenennen
      // ist unteilbar; im schlimmsten Fall gewinnt der zweite Durchgang mit
      // demselben Inhalt.
      //
      // Und: Unter dem endgültigen Namen darf nie ein Rumpf stehen. Bräche
      // das Entschlüsseln ab, hielte der Zwischenspeicher die abgebrochene
      // Fassung für fertig und zeigte sie beim nächsten Zugriff wortlos
      // weiter, statt es erneut zu versuchen.
      final teil = File('${target.path}.${DateTime.now().microsecondsSinceEpoch}');
      try {
        await VaultCrypto.decryptFile(paths.absolute(relativePath), teil, key);
        await teil.rename(target.path);
      } finally {
        if (await teil.exists()) await teil.delete();
      }
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
    _ordnerTimer?.cancel();
    _modellFreigabeTimer?.cancel();
    super.dispose();
  }
}
