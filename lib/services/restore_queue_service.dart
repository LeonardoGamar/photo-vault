import 'dart:async';

import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import 'native_image_converter.dart';
import 'restore_service.dart';
import 'storage_paths.dart';

/// Persistierte Hintergrund-Warteschlange für KI-Restaurierung (siehe
/// RestoreService, RestoreJobs) – ein Auftrag läuft oft mehrere Minuten
/// (echt gemessen: ~5 Min. bei 12 MP mit CoreML), daher bewusst NICHT als
/// blockierender Dialog, sondern als Warteschlange, die der Nutzer anstößt
/// und dann in der App weiterarbeitet. Verarbeitet **einen Auftrag
/// gleichzeitig** – mehrere parallele ONNX-Inferenzen würden sich nur um
/// CPU/GPU streiten. Lebt auf [LibraryState] wie `importService`/
/// `backupService`.
class RestoreQueueService {
  RestoreQueueService(this._db, this._paths);

  final AppDatabase _db;
  final StoragePaths _paths;

  /// Von außen gesetzt, sobald das Modell heruntergeladen und geladen ist
  /// (Muster: LibraryState._loadModelsIfPresent, analog zu
  /// `segmentationService`) – ohne Modell bleibt die Warteschlange nutzbar
  /// für bereits vorhandene Aufträge, [enqueue] schlägt aber fehl.
  RestoreService? restoreService;

  bool _processing = false;
  String? _activeJobId;
  final Set<String> _cancelRequested = {};

  /// Ob gerade ein Auftrag verarbeitet wird – LibraryState.reloadModels()
  /// prüft das, bevor es [restoreService] disposed/ersetzt: die ONNX-
  /// Sitzung eines laufenden, oft mehrere Minuten dauernden Auftrags darf
  /// nicht unter ihm weggerissen werden (anders als bei den kurzen
  /// SAM/CLIP-Aufrufen der übrigen Modelle ist das Zeitfenster hier real
  /// relevant, nicht nur theoretisch).
  bool get isProcessing => _processing;

  /// Legt einen neuen Auftrag an und stößt die Verarbeitung an (falls
  /// gerade nichts läuft). Wirft, wenn kein Modell geladen ist – der
  /// Aufrufer (UI) sollte den Knopf dafür ohnehin deaktivieren. Ist für
  /// dasselbe Asset bereits ein wartender/laufender Auftrag vorhanden, wird
  /// dessen ID zurückgegeben statt eines Duplikats – ohne diese Prüfung
  /// würde ein Doppelklick (oder mehrfaches Anstoßen aus verschiedenen
  /// Screens) denselben mehrminütigen Auftrag mehrfach redundant laufen
  /// lassen.
  Future<String> enqueue(String assetId) async {
    if (restoreService == null) {
      throw StateError('KI-Restaurierung ist nicht verfügbar – Modell nicht geladen.');
    }
    final existing = await _db.activeRestoreJobForAsset(assetId);
    if (existing != null) return existing.id;

    final id = const Uuid().v4();
    await _db.createRestoreJob(RestoreJobsCompanion.insert(
      id: id,
      assetId: assetId,
      status: 'queued',
      createdAt: DateTime.now(),
    ));
    unawaited(_maybeStartNext());
    return id;
  }

  /// Ein noch wartender Auftrag wird sofort entfernt; ein gerade laufender
  /// wird zwischen Kacheln abgebrochen (siehe [RestoreService.restore]s
  /// `isCancelled`) und dann als `cancelled` markiert, OHNE ein
  /// unvollständiges Ergebnis zu speichern.
  Future<void> cancel(String jobId) async {
    if (jobId == _activeJobId) {
      _cancelRequested.add(jobId);
    } else {
      await _db.deleteRestoreJob(jobId);
    }
  }

  /// Stößt die Verarbeitung an, falls Aufträge warten und gerade nichts
  /// läuft – aufgerufen beim App-Start (nach [AppDatabase.resetStuckRunningRestoreJobs],
  /// siehe LibraryState.initialize) für Aufträge, die aus der letzten
  /// Sitzung noch offen sind.
  Future<void> resume() => _maybeStartNext();

  Future<void> _maybeStartNext() async {
    // _processing wird bewusst VOR dem ersten await gesetzt (statt erst
    // nachdem [nextQueuedRestoreJob] zurückkommt) – Audit-Fund: zwei
    // schnell aufeinanderfolgende Aufrufe (z.B. zwei enqueue()s in
    // Folge) würden sonst beide die DB-Abfrage starten, bevor einer von
    // beiden _processing setzt, und so zwei Aufträge parallel verarbeiten
    // (verdoppelte CPU/GPU-Last, doppelter Speicherbedarf für die
    // Kachel-Puffer) statt der vorgesehenen Ein-Auftrag-gleichzeitig-Regel.
    if (_processing) return;
    _processing = true;
    try {
      final next = await _db.nextQueuedRestoreJob();
      if (next == null) return;
      _activeJobId = next.id;
      try {
        await _process(next);
      } finally {
        _cancelRequested.remove(next.id);
        _activeJobId = null;
      }
    } finally {
      _processing = false;
    }
    unawaited(_maybeStartNext());
  }

  Future<void> _process(RestoreJobData job) async {
    final service = restoreService;
    if (service == null) {
      await _db.markRestoreJobStatus(job.id, 'failed', errorMessage: 'Modell nicht mehr verfügbar.');
      return;
    }
    await _db.markRestoreJobStatus(job.id, 'running');

    try {
      final asset = await _db.assetById(job.assetId);
      if (asset == null) {
        await _db.markRestoreJobStatus(job.id, 'failed', errorMessage: 'Foto wurde inzwischen gelöscht.');
        return;
      }
      if (asset.isLocked) {
        await _db.markRestoreJobStatus(job.id, 'failed',
            errorMessage: 'KI-Restaurierung ist für gesperrte Fotos nicht verfügbar.');
        return;
      }
      final targetWidth = asset.widthPx;
      final targetHeight = asset.heightPx;
      if (targetWidth == null || targetHeight == null) {
        await _db.markRestoreJobStatus(job.id, 'failed', errorMessage: 'Bildauflösung unbekannt.');
        return;
      }

      // Eingabe: das bereits entwickelte Bild (aktuelle Regler/Masken) in
      // voller Auflösung über den nativen Kanal – das `image`-Dart-Paket
      // kann RAW-Originale nicht selbst dekodieren (siehe DevelopScreen).
      final settings = await _db.developSettingsForAsset(job.assetId);
      final adjustments = settings == null
          ? DevelopAdjustments.neutral
          : DevelopAdjustments(
              exposure: settings.exposure,
              temperature: settings.temperature,
              tint: settings.tint,
              contrast: settings.contrast,
              shadows: settings.shadows,
              sharpness: settings.sharpness,
              noiseReduction: settings.noiseReduction,
              lensCorrectionEnabled: settings.lensCorrectionEnabled,
            );
      final masks = await _db.masksForAsset(job.assetId);
      final maskLayers = [
        for (final m in masks)
          MaskAdjustmentLayer(
            maskFilePath: _paths.absolute(m.maskRelativePath).path,
            adjustments: DevelopAdjustments(
              exposure: m.exposure,
              temperature: m.temperature,
              tint: m.tint,
              contrast: m.contrast,
              shadows: m.shadows,
              sharpness: m.sharpness,
              noiseReduction: m.noiseReduction,
            ),
          ),
      ];

      final sourceFile = _paths.absolute(asset.relativePath);
      final jpegBytes = await NativeImageConverter.developImage(
        sourceFile,
        adjustments: adjustments,
        masks: maskLayers,
        maxDimension: targetWidth > targetHeight ? targetWidth : targetHeight,
        quality: 0.95,
      );
      if (jpegBytes == null) {
        await _db.markRestoreJobStatus(job.id, 'failed', errorMessage: 'Bild konnte nicht gerendert werden.');
        return;
      }
      final decoded = img.decodeJpg(jpegBytes);
      if (decoded == null) {
        await _db.markRestoreJobStatus(job.id, 'failed', errorMessage: 'Gerendertes Bild konnte nicht dekodiert werden.');
        return;
      }

      final result = await service.restore(
        decoded,
        // Absichtlich nicht awaited (der Fortschritt darf die Inferenz
        // nicht ausbremsen) – catchError statt eines unbehandelten
        // Future-Fehlers, falls der DB-Schreibzugriff einmal transient
        // fehlschlägt.
        onProgress: (done, total) =>
            unawaited(_db.updateRestoreJobProgress(job.id, done, total).catchError((_) {})),
        isCancelled: () => _cancelRequested.contains(job.id),
      );

      if (_cancelRequested.contains(job.id)) {
        await _db.markRestoreJobStatus(job.id, 'cancelled');
        return;
      }

      final relativePath = _paths.restoredRelativePath(job.assetId);
      final outFile = _paths.absolute(relativePath);
      await outFile.parent.create(recursive: true);
      await outFile.writeAsBytes(img.encodeJpg(result, quality: 92));

      await _db.completeRestoreJob(job.id, job.assetId, relativePath);
    } catch (e) {
      await _db.markRestoreJobStatus(job.id, 'failed', errorMessage: e.toString());
    }
  }
}
