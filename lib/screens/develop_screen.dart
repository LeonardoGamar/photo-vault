import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../services/asset_display_path.dart';
import '../services/histogram.dart';
import '../services/modell_halter.dart';
import '../services/native_image_converter.dart';
import '../services/restore_queue_service.dart';
import '../services/segmentation_service.dart';
import '../services/storage_paths.dart';
import '../services/vector_mask_service.dart';
import '../state/library_state.dart' show decodeImageBytes;
import '../theme/app_spacing.dart';
import '../utils/debouncer.dart';
import '../widgets/develop_preview.dart';
import '../widgets/histogram_view.dart';

/// Welche Art von Maske gerade erstellt/bearbeitet wird – KI-Auswahl (SAM-
/// Punkt-Prompts, siehe SegmentationService) oder eine der drei editierbaren
/// Vektorformen (siehe vector_mask_service.dart).
enum _MaskFormType { aiSelect, freehand, ellipse, gradient }

/// Nicht-destruktive Bildentwicklung (Belichtung, Weißabgleich, Kontrast,
/// Schatten, Schärfe, Rauschunterdrückung, Objektivkorrektur) – anders als
/// [ImageEditorScreen] wird nie die Originaldatei verändert: die
/// Einstellungen landen in [DevelopSettings], das gerenderte Ergebnis als
/// separate Datei unter `Assets.developedRelativePath`. Arbeitet für
/// RAW-Dateien über CIRAWFilter-Eigenschaften (arbeitet auf den Rohdaten
/// vor dem Demosaicing) und für alle anderen Formate über eine
/// äquivalente CIFilter-Kette (siehe ImageConverter.swift `developImage`).
/// Nur für Fotos, nicht für gesperrte (verschlüsselte) Assets – wie
/// [ImageEditorScreen], um Wiederverschlüsselung nach dem Speichern nicht
/// mit abdecken zu müssen.
///
/// Masken (siehe DevelopMasks) gibt es in zwei Arten: KI-Auswahl per
/// SAM-Punkt-Prompt (nur verfügbar, wenn [segmentation] installiert ist –
/// `null`/`installiert == false`, solange das Segmentierungs-Modell nicht
/// heruntergeladen ist) und editierbare Vektorformen (Pinsel/Ellipse/
/// Verlauf, siehe vector_mask_service.dart), die kein Modell benötigen und
/// jederzeit verfügbar sind. Die eigentliche ONNX-Sitzung wird erst beim
/// Öffnen des KI-Auswahl-Werkzeugs geliehen ([_ensureEmbedding]) und beim
/// Verlassen des Bildschirms wieder zurückgegeben (siehe [dispose]).
///
/// [restoreQueue] schaltet die KI-Restaurierung frei (Hochskalieren +
/// Entrauschen, läuft im Hintergrund und dauert mehrere Minuten, siehe
/// RestoreQueueService) – `null`, solange das zugehörige Modell nicht
/// heruntergeladen ist.
class DevelopScreen extends StatefulWidget {
  final AssetData asset;
  final AppDatabase db;
  final StoragePaths paths;
  final ModellHalter<SegmentationService>? segmentation;
  final RestoreQueueService? restoreQueue;

  const DevelopScreen({
    super.key,
    required this.asset,
    required this.db,
    required this.paths,
    this.segmentation,
    this.restoreQueue,
  });

  @override
  State<DevelopScreen> createState() => _DevelopScreenState();
}

class _DevelopScreenState extends State<DevelopScreen> {
  final _debouncer = Debouncer(const Duration(milliseconds: 250));
  int _requestToken = 0;

  bool _loading = true;
  bool _rendering = false;
  bool _saving = false;
  String? _error;
  Uint8List? _previewBytes;

  /// Für den Vorher/Nachher-Vergleich (Gedrückt-Halten) – einmalig beim
  /// ersten Halten mit neutralen Reglerwerten gerendert und danach gecacht,
  /// damit wiederholtes Halten keine erneute native Konvertierung auslöst.
  Uint8List? _originalPreviewBytes;
  bool _loadingOriginalPreview = false;
  bool _showingOriginal = false;

  // --- Live-Vorschau per GPU-Shader ------------------------------------
  // Während des Regler-Ziehens rechnet der Shader sofort auf der
  // neutralen Basis; nach dem Loslassen ersetzt der native Render das Bild
  // und ist maßgeblich (siehe shaders/develop_adjustments.frag).
  ui.FragmentShader? _shader;
  ui.Image? _shaderBasis;
  bool _dragging = false;

  /// Shader-Vorschau nur, wenn sie auch stimmen kann: beim Ziehen, mit
  /// geladener Basis und Shader – und ohne Masken, da die neutrale Basis
  /// keine Maskenwirkung enthält und beim Ziehen sonst alle Masken
  /// verschwinden und danach wieder auftauchen würden.
  bool get _zeigeShaderVorschau =>
      _dragging && _masks.isEmpty && _shader != null && _shaderBasis != null;

  /// Tonwertverteilung der aktuell angezeigten Vorschau (siehe
  /// [_recomputeHistogram]). `null`, solange noch nichts berechnet wurde.
  HistogramData? _histogram;

  /// Verwirft spät eintreffende Histogramm-Berechnungen, wenn inzwischen
  /// eine neuere Vorschau vorliegt – dasselbe Muster wie [_requestToken]
  /// für die Vorschau selbst.
  int _histogramToken = 0;
  bool _histogramPending = false;

  double _exposure = 0;
  bool _autoWhiteBalance = true;
  double _temperature = 6500; // Nur Anzeigewert, solange _autoWhiteBalance = true.
  double _tint = 0;
  double _contrast = 0;
  double _shadows = 0;
  double _sharpness = 0;
  double _noiseReduction = 0;
  bool _lensCorrectionEnabled = true;

  // --- KI-Objektmasken -------------------------------------------------
  List<DevelopMaskData> _masks = [];

  /// `null` = die globalen Regler oben sind aktiv/sichtbar; sonst die
  /// Auto-Increment-`id` der gerade zum Bearbeiten ausgewählten Maske.
  int? _selectedMaskId;

  // Entwurfswerte der aktuell ausgewählten Maske (siehe _selectMask) –
  // dasselbe Muster wie die globalen Regler-Felder oben, nur ohne
  // Objektivkorrektur (die gilt nur für RAW-Rohdaten, nicht pro Maske).
  double _maskExposure = 0;
  bool _maskAutoWhiteBalance = true;
  double _maskTemperature = 6500;
  double _maskTint = 0;
  double _maskContrast = 0;
  double _maskShadows = 0;
  double _maskSharpness = 0;
  double _maskNoiseReduction = 0;

  bool _maskEditMode = false;
  bool _computingEmbedding = false;
  /// Beim ersten Mal wird das Segmentierungsmodell (101 MB) geladen –
  /// das dauert deutlich länger als das blosse Vorbereiten des Bildes
  /// und verdient eine eigene Erklärung.
  bool _ladeSegmentierungsmodell = false;
  bool _computingMask = false;
  SamImageEmbedding? _embedding;
  img.Image? _decodedForMasking;

  /// Die von [widget.segmentation] geliehene Sitzung (siehe
  /// [_ensureEmbedding]) – nicht-null bedeutet zugleich "muss in [dispose]
  /// zurückgegeben werden".
  SegmentationService? _segmentation;

  /// Punkte im Koordinatenraum des für die Maskierung dekodierten Bilds
  /// ([_decodedForMasking]), in Tipp-Reihenfolge – `isBackground: true` =
  /// "hier NICHT auswählen"-Punkt (SAM-Konvention Label 0).
  final List<({Offset point, bool isBackground})> _maskPoints = [];
  bool _backgroundPointMode = false;
  SamMaskResult? _pendingMaskResult;
  Uint8List? _pendingMaskOverlayPng;

  // --- Vektor-Masken (Pinsel/Ellipse/Verlauf) ---------------------------
  _MaskFormType _maskFormType = _MaskFormType.aiSelect;

  /// Nur gesetzt, während die Form einer bereits gespeicherten Vektor-Maske
  /// erneut bearbeitet wird (siehe "Form bearbeiten" in _buildAdjustmentsPanel)
  /// – steuert, ob [_commitShape] ein neues DevelopMasks-Row anlegt oder ein
  /// bestehendes aktualisiert. `null` beim Erstellen einer neuen Maske.
  int? _editingMaskId;

  /// Entwurf der gerade gezeichneten/bearbeiteten Vektorform, in Bild-
  /// normalisierten [0,1]-Koordinaten – erst bei "Fertig" ([_commitShape])
  /// tatsächlich rasterisiert und gespeichert.
  MaskShapeDefinition? _draftShape;

  /// Temporärer Anker für die Ellipse-Zieh-Geste (Gegenstück zu Start-/
  /// Endpunkt beim Verlauf, die direkt im GradientShape-Entwurf leben).
  Offset? _ellipseDragAnchor;

  @override
  void initState() {
    super.initState();
    // _initShaderVorschau() bewusst NICHT hier: _init() lehnt gesperrte
    // Fotos ab, bevor irgendetwas die noch verschlüsselte Originaldatei
    // anfasst. Ein paralleler Aufruf würde genau daran vorbeilaufen. Der
    // Start erfolgt daher am Ende von _init(), wo Sperre und Vorschau
    // bereits geklärt sind.
    _init();
  }

  /// Lädt Shader-Programm und neutrale Basis für die Live-Vorschau.
  ///
  /// Wird am Ende von [_init] aufgerufen, also erst nachdem die Sperre
  /// geprüft und die Vorschau geladen ist. Beides ist optional: Schlägt es
  /// fehl (Plattform ohne Shader, Foto nicht renderbar), bleibt schlicht
  /// das bisherige Verhalten – nach jedem Reglerstopp ein nativer Render.
  Future<void> _initShaderVorschau({required bool unbearbeitet}) async {
    final shader = await ladeDevelopShader();
    if (!mounted) return;
    if (shader != null) setState(() => _shader = shader);

    // Bei einem unbearbeiteten Foto IST die angezeigte Vorschau bereits der
    // neutrale Stand – die lässt sich direkt als Shader-Basis verwenden.
    // Ein zusätzlicher nativer Render wäre reine Verschwendung und würde
    // die Optimierung aus _init() (kein CIRAWFilter-Durchlauf für
    // unveränderte Fotos) wieder zunichtemachen.
    Uint8List? bytes = unbearbeitet ? _previewBytes : null;
    if (bytes == null) {
      await _ensureOriginalPreviewLoaded();
      bytes = _originalPreviewBytes;
    }
    if (bytes == null || !mounted) return;
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      if (!mounted) {
        frame.image.dispose();
        return;
      }
      setState(() => _shaderBasis = frame.image);
    } catch (_) {
      // Ohne Basis keine Live-Vorschau – kein Grund, den Screen zu stören.
    }
  }

  @override
  void dispose() {
    _debouncer.dispose();
    // GPU-Ressourcen gehören ausdrücklich freigegeben – der Garbage
    // Collector räumt sie nicht ab.
    _shader?.dispose();
    _shaderBasis?.dispose();
    if (_segmentation != null) widget.segmentation?.zurueckgeben();
    super.dispose();
  }

  Future<void> _init() async {
    // Redundant zur Sperre in asset_viewer_screen.dart (der einzige
    // Einstiegspunkt): schützt auch dann, falls diese Ansicht je aus einem
    // anderen Kontext heraus geöffnet würde, bevor überhaupt ein nativer
    // Renderversuch auf der noch verschlüsselten Originaldatei unternommen
    // wird.
    if (widget.asset.isLocked) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Entwickeln ist für Fotos im gesperrten Ordner nicht verfügbar.';
        });
      }
      return;
    }

    final settings = await widget.db.developSettingsForAsset(widget.asset.id);
    if (settings != null) {
      _exposure = settings.exposure;
      _contrast = settings.contrast;
      _shadows = settings.shadows;
      _sharpness = settings.sharpness;
      _noiseReduction = settings.noiseReduction;
      _lensCorrectionEnabled = settings.lensCorrectionEnabled;
      if (settings.temperature != null) {
        _autoWhiteBalance = false;
        _temperature = settings.temperature!;
        _tint = settings.tint ?? 0;
      }
    }
    _masks = await widget.db.masksForAsset(widget.asset.id);
    if (mounted) setState(() => _loading = false);

    if (settings == null && _masks.isEmpty) {
      // Unverändertes Foto: die bereits vorhandene Vorschau/Originaldatei
      // direkt anzeigen statt beim bloßen Öffnen unnötig einmal nativ neu zu
      // rendern (mit DevelopAdjustments.neutral käme ohnehin dasselbe Bild
      // heraus) – erspart bei RAW-Dateien einen vollen CIRAWFilter-Durchlauf,
      // nur um exakt das zu zeigen, was schon auf der Platte liegt.
      await _showExistingPreview();
      unawaited(_initShaderVorschau(unbearbeitet: true));
    } else {
      await _requestPreview();
      unawaited(_initShaderVorschau(unbearbeitet: false));
    }
  }

  Future<void> _showExistingPreview() async {
    try {
      final bytes = await widget.paths.absolute(displayRelativePath(widget.asset)).readAsBytes();
      if (!mounted) return;
      setState(() => _previewBytes = bytes);
      unawaited(_recomputeHistogram());
    } catch (_) {
      // Vorschaudatei fehlt/unlesbar – auf den nativen Renderpfad zurückfallen.
      await _requestPreview();
    }
  }

  DevelopAdjustments _currentAdjustments() => DevelopAdjustments(
        exposure: _exposure,
        temperature: _autoWhiteBalance ? null : _temperature,
        tint: _autoWhiteBalance ? null : _tint,
        contrast: _contrast,
        shadows: _shadows,
        sharpness: _sharpness,
        noiseReduction: _noiseReduction,
        lensCorrectionEnabled: _lensCorrectionEnabled,
      );

  /// Baut die Masken-Ebenen für den nativen Renderaufruf: für die gerade
  /// ausgewählte Maske werden die LIVE-Entwurfswerte verwendet (damit
  /// Regler-Änderungen sofort sichtbar werden), für alle anderen die
  /// zuletzt gespeicherten Werte aus der DB.
  List<MaskAdjustmentLayer> _currentMaskLayers() {
    return _masks.map((mask) {
      final adjustments = mask.id == _selectedMaskId
          ? DevelopAdjustments(
              exposure: _maskExposure,
              temperature: _maskAutoWhiteBalance ? null : _maskTemperature,
              tint: _maskAutoWhiteBalance ? null : _maskTint,
              contrast: _maskContrast,
              shadows: _maskShadows,
              sharpness: _maskSharpness,
              noiseReduction: _maskNoiseReduction,
            )
          : DevelopAdjustments(
              exposure: mask.exposure,
              temperature: mask.temperature,
              tint: mask.tint,
              contrast: mask.contrast,
              shadows: mask.shadows,
              sharpness: mask.sharpness,
              noiseReduction: mask.noiseReduction,
            );
      return MaskAdjustmentLayer(
        maskFilePath: widget.paths.absolute(mask.maskRelativePath).path,
        adjustments: adjustments,
      );
    }).toList();
  }

  /// Rendert eine Vorschau über den nativen Kanal – immer aus der echten
  /// Originaldatei (nicht aus previewRelativePath/developedRelativePath),
  /// da nur die Originaldatei bei RAW-Formaten die vollen Rohdaten für
  /// CIRAWFilter enthält. [_requestToken] verwirft spät eintreffende
  /// Antworten auf schnelles Regler-Ziehen, damit nie eine neuere Vorschau
  /// von einer älteren, langsameren Anfrage überschrieben wird.
  Future<void> _requestPreview() async {
    final token = ++_requestToken;
    setState(() => _rendering = true);
    final sourceFile = widget.paths.absolute(widget.asset.relativePath);
    final bytes = await NativeImageConverter.developImage(
      sourceFile,
      adjustments: _currentAdjustments(),
      masks: _currentMaskLayers(),
      maxDimension: 1600,
      quality: 0.85,
    );
    if (token != _requestToken || !mounted) return;
    setState(() {
      _rendering = false;
      // Jetzt erst ist der native Render da – ab hier darf die
      // Shader-Vorschau abgelöst werden (siehe onChangeEnd im _slider).
      _dragging = false;
      if (bytes != null) {
        _previewBytes = bytes;
        _error = null;
      } else {
        _error = 'Vorschau konnte nicht erzeugt werden – native Bildkonvertierung nicht verfügbar?';
      }
    });
    if (bytes != null) unawaited(_recomputeHistogram());
  }

  void _scheduleRerender() => _debouncer.run(_requestPreview);

  /// Berechnet das Histogramm zur aktuellen Vorschau neu – ausgelagert über
  /// `compute()`, da Dekodieren + Auswerten des Vorschaubilds sonst bei
  /// jedem Regler-Loslassen den UI-Thread blockieren würde.
  ///
  /// Fehler werden bewusst verschluckt: das Histogramm ist eine reine
  /// Zusatzanzeige und darf die Entwicklung nie stören.
  Future<void> _recomputeHistogram() async {
    final bytes = _previewBytes;
    if (bytes == null) return;
    final token = ++_histogramToken;
    setState(() => _histogramPending = true);
    try {
      final histogram = await compute(computeHistogramFromBytes, bytes);
      if (token != _histogramToken || !mounted) return;
      setState(() {
        _histogram = histogram;
        _histogramPending = false;
      });
    } catch (_) {
      if (token != _histogramToken || !mounted) return;
      setState(() => _histogramPending = false);
    }
  }

  /// Rendert die unbearbeitete Vorschau (neutrale Regler) einmalig und
  /// cached sie – für das Gedrückt-Halten-"Vorher"-Bild. Kein zusätzlicher
  /// nativer Aufruf bei wiederholtem Halten.
  Future<void> _ensureOriginalPreviewLoaded() async {
    if (_originalPreviewBytes != null || _loadingOriginalPreview) return;
    _loadingOriginalPreview = true;
    final sourceFile = widget.paths.absolute(widget.asset.relativePath);
    final bytes = await NativeImageConverter.developImage(
      sourceFile,
      adjustments: DevelopAdjustments.neutral,
      maxDimension: 1600,
      quality: 0.85,
    );
    _loadingOriginalPreview = false;
    if (mounted && bytes != null) setState(() => _originalPreviewBytes = bytes);
  }

  /// Übernimmt einen vergangenen, dauerhaft gespeicherten Entwickeln-Stand
  /// zurück in die Regler und stößt eine neue Vorschau an – speichert dabei
  /// noch NICHT, der Nutzer bestätigt wie gewohnt über "Speichern" (das den
  /// gerade ersetzten Stand wiederum in die Historie schiebt, siehe
  /// AppDatabase.saveDevelopResult). Betrifft nur die globalen Regler – die
  /// Historie kennt keine Masken, siehe DevelopMasks-Doc-Kommentar.
  void _loadHistoryEntry(DevelopHistoryData entry) {
    setState(() {
      _exposure = entry.exposure;
      _contrast = entry.contrast;
      _shadows = entry.shadows;
      _sharpness = entry.sharpness;
      _noiseReduction = entry.noiseReduction;
      _lensCorrectionEnabled = entry.lensCorrectionEnabled;
      _autoWhiteBalance = entry.temperature == null;
      _temperature = entry.temperature ?? _temperature;
      _tint = entry.tint ?? 0;
    });
    _scheduleRerender();
  }

  Future<void> _showHistory() async {
    final history = await widget.db.developHistoryForAsset(widget.asset.id);
    if (!mounted) return;
    final selected = await showModalBottomSheet<DevelopHistoryData>(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      builder: (context) {
        if (history.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(AppSpacing.xxl),
            child: Text(
              'Noch kein Verlauf vorhanden – ein Eintrag entsteht, sobald du nach einer '
              'ersten Anpassung erneut speicherst.',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final entry in history)
                ListTile(
                  leading: const Icon(Icons.history, color: Colors.white70),
                  title: Text(
                    DateFormat('dd.MM.yyyy HH:mm', 'de_DE').format(entry.createdAt),
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () => Navigator.pop(context, entry),
                ),
            ],
          ),
        );
      },
    );
    if (selected != null) _loadHistoryEntry(selected);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final adjustments = _currentAdjustments();
    final maskLayers = _currentMaskLayers();
    final sourceFile = widget.paths.absolute(widget.asset.relativePath);
    final bytes = await NativeImageConverter.developImage(
      sourceFile,
      adjustments: adjustments,
      masks: maskLayers,
      maxDimension: 4096,
      quality: 0.92,
    );
    if (bytes == null) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Speichern fehlgeschlagen: Bild konnte nicht gerendert werden.')));
      }
      return;
    }

    final developedRelativePath = widget.paths.developedRelativePath(widget.asset.id);
    final targetFile = widget.paths.absolute(developedRelativePath);
    await targetFile.parent.create(recursive: true);
    await targetFile.writeAsBytes(bytes);

    await widget.db.saveDevelopResult(
      widget.asset.id,
      settings: DevelopSettingsCompanion.insert(
        assetId: widget.asset.id,
        exposure: Value(adjustments.exposure),
        temperature: Value(adjustments.temperature),
        tint: Value(adjustments.tint),
        contrast: Value(adjustments.contrast),
        shadows: Value(adjustments.shadows),
        sharpness: Value(adjustments.sharpness),
        noiseReduction: Value(adjustments.noiseReduction),
        lensCorrectionEnabled: Value(adjustments.lensCorrectionEnabled),
        updatedAt: DateTime.now(),
      ),
      developedRelativePath: developedRelativePath,
    );

    // Nur die gerade ausgewählte Maske kann seit dem letzten Speichern
    // geänderte Regler-Werte im Speicher haben (siehe _currentMaskLayers) –
    // alle anderen sind bereits mit der DB konsistent.
    if (_selectedMaskId != null) {
      await widget.db.updateDevelopMaskAdjustments(
        _selectedMaskId!,
        DevelopMasksCompanion(
          exposure: Value(_maskExposure),
          temperature: Value(_maskAutoWhiteBalance ? null : _maskTemperature),
          tint: Value(_maskAutoWhiteBalance ? null : _maskTint),
          contrast: Value(_maskContrast),
          shadows: Value(_maskShadows),
          sharpness: Value(_maskSharpness),
          noiseReduction: Value(_maskNoiseReduction),
        ),
      );
    }

    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _reset() async {
    await widget.db.resetDevelopSettings(widget.asset.id);
    final developedFile = widget.paths.absolute(widget.paths.developedRelativePath(widget.asset.id));
    if (await developedFile.exists()) await developedFile.delete();
    if (mounted) Navigator.of(context).pop(true);
  }

  // --- KI-Restaurierung (RestoreQueueService, Hintergrund-Warteschlange) --

  /// Stößt nur an – läuft im Hintergrund weiter, auch nachdem dieser
  /// Screen geschlossen wurde (siehe RestoreQueueService, HomeShell-
  /// Warteschlangen-Indikator). Kein Warten in der UI.
  Future<void> _enqueueRestore() async {
    final queue = widget.restoreQueue;
    if (queue == null) return;
    try {
      await queue.enqueue(widget.asset.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Zur Warteschlange für KI-Restaurierung hinzugefügt.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Konnte nicht zur Warteschlange hinzugefügt werden: $e')));
      }
    }
  }

  /// Entfernt ein vorhandenes Restaurierungs-Ergebnis (Muster: [_reset]) –
  /// betrifft nur die Datei-Referenz, die globalen Entwickeln-Regler und
  /// Masken bleiben unangetastet.
  Future<void> _removeRestoredResult() async {
    final relativePath = widget.asset.restoredRelativePath;
    if (relativePath == null) return;
    await widget.db.clearMissingRestoredPath(widget.asset.id);
    final file = widget.paths.absolute(relativePath);
    if (await file.exists()) await file.delete();
    if (mounted) Navigator.of(context).pop(true);
  }

  // --- KI-Objektmasken ---------------------------------------------------

  void _selectMask(DevelopMaskData mask) {
    setState(() {
      _selectedMaskId = mask.id;
      _maskExposure = mask.exposure;
      _maskContrast = mask.contrast;
      _maskShadows = mask.shadows;
      _maskSharpness = mask.sharpness;
      _maskNoiseReduction = mask.noiseReduction;
      _maskAutoWhiteBalance = mask.temperature == null;
      _maskTemperature = mask.temperature ?? 6500;
      _maskTint = mask.tint ?? 0;
    });
  }

  void _selectGlobalAdjustments() => setState(() => _selectedMaskId = null);

  Future<void> _deleteMask(DevelopMaskData mask) async {
    await widget.db.deleteDevelopMask(mask.id);
    final file = widget.paths.absolute(mask.maskRelativePath);
    if (await file.exists()) await file.delete();
    setState(() {
      _masks = _masks.where((m) => m.id != mask.id).toList();
      if (_selectedMaskId == mask.id) _selectedMaskId = null;
    });
    _scheduleRerender();
  }

  /// Öffnet den Masken-Editor. Ohne [editingMask] startet ein neuer Entwurf
  /// (Formtyp: KI-Auswahl, falls [SegmentationService] verfügbar, sonst
  /// Pinsel als sinnvollste Standardwahl). Mit [editingMask] wird stattdessen
  /// dessen gespeicherte Vektorform zum Weiterbearbeiten geladen (nur möglich
  /// für Masken mit `shapeDefinitionJson`, siehe "Form bearbeiten" in
  /// _buildAdjustmentsPanel).
  Future<void> _startMaskCreation({DevelopMaskData? editingMask}) async {
    MaskShapeDefinition? shape;
    if (editingMask?.shapeDefinitionJson != null) {
      shape = MaskShapeDefinition.decode(editingMask!.shapeDefinitionJson!);
    }
    final formType = switch (shape) {
      FreehandShape() => _MaskFormType.freehand,
      EllipseShape() => _MaskFormType.ellipse,
      GradientShape() => _MaskFormType.gradient,
      null => (widget.segmentation?.installiert ?? false) ? _MaskFormType.aiSelect : _MaskFormType.freehand,
    };
    setState(() {
      _maskEditMode = true;
      _maskFormType = formType;
      _editingMaskId = editingMask?.id;
      _draftShape = shape;
      _ellipseDragAnchor = null;
      _maskPoints.clear();
      _backgroundPointMode = false;
      _pendingMaskResult = null;
      _pendingMaskOverlayPng = null;
    });
    if (formType == _MaskFormType.aiSelect) await _ensureEmbedding();
  }

  /// Wechselt den Formtyp innerhalb des offenen Masken-Editors – verwirft
  /// dabei immer einen eventuell geladenen Bearbeiten-Entwurf ([_editingMaskId]),
  /// da eine Form bei ihrem eigentlichen Typ bleibt und ein Typwechsel somit
  /// automatisch eine NEUE Maske anlegt statt die alte zu ersetzen.
  void _switchMaskFormType(_MaskFormType type) {
    setState(() {
      _maskFormType = type;
      _draftShape = null;
      _editingMaskId = null;
      _ellipseDragAnchor = null;
      _maskPoints.clear();
      _pendingMaskResult = null;
      _pendingMaskOverlayPng = null;
    });
    if (type == _MaskFormType.aiSelect) _ensureEmbedding();
  }

  void _cancelMaskCreation() {
    setState(() {
      _maskEditMode = false;
      _maskPoints.clear();
      _pendingMaskResult = null;
      _pendingMaskOverlayPng = null;
      _draftShape = null;
      _editingMaskId = null;
      _ellipseDragAnchor = null;
    });
  }

  /// Berechnet das (teure) Bild-Embedding einmalig beim Öffnen des
  /// Maskier-Modus – aus der bereits vorhandenen Vorschau (nicht dem
  /// RAW-Original: das `image`-Paket kann RAW nicht dekodieren, die
  /// Vorschau ist für die interaktive Punktauswahl auflösungsmäßig mehr
  /// als ausreichend).
  Future<void> _ensureEmbedding() async {
    final halter = widget.segmentation;
    final previewBytes = _previewBytes;
    if (halter == null || previewBytes == null || _embedding != null) return;
    setState(() {
      _computingEmbedding = true;
      _ladeSegmentierungsmodell = !halter.istGeladen;
    });

    SegmentationService? segmentation;
    try {
      segmentation = await halter.leihen();
    } catch (e) {
      if (mounted) {
        setState(() => _computingEmbedding = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('KI-Auswahl konnte nicht geladen werden: $e')),
        );
      }
      return;
    }
    if (segmentation == null) {
      if (mounted) setState(() => _computingEmbedding = false);
      return;
    }

    // Ab hier ist die Leihe offen und MUSS auf jedem Weg wieder heraus –
    // ausser im Erfolgsfall, wo dieser Bildschirm sie bis zu seinem
    // dispose() behält. Vorher lagen `compute` und `encodeImage` ohne
    // try/finally dazwischen: Warf eines von beiden (ONNX-Inferenz kann
    // das), blieb der Nutzerzähler für immer auf 1, das
    // Segmentierungsmodell (101 MB) liess sich bis zum Programmende nicht
    // mehr freigeben, und der Ladekringel drehte sich endlos weiter.
    // dispose() half dabei nicht: Es prüft `_segmentation`, das erst im
    // Erfolgsfall gesetzt wird (Audit-Fund).
    var behalten = false;
    try {
      final decoded = await compute(decodeImageBytes, previewBytes);
      if (decoded == null) {
        if (mounted) {
          setState(() => _computingEmbedding = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vorschaubild konnte nicht für die Maskierung dekodiert werden.')),
          );
        }
        return;
      }
      final embedding = await segmentation.encodeImage(decoded);
      // Bildschirm inzwischen verlassen? Dann gibt das finally die Leihe
      // zurück – dispose() kann sie nicht kennen, dieser Aufruf war ja
      // noch nicht fertig.
      if (!mounted) return;
      setState(() {
        _decodedForMasking = decoded;
        _embedding = embedding;
        _segmentation = segmentation;
        _computingEmbedding = false;
      });
      behalten = true;
    } catch (e) {
      if (mounted) {
        setState(() => _computingEmbedding = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('KI-Auswahl fehlgeschlagen: $e')),
        );
      }
    } finally {
      if (!behalten) halter.zurueckgeben();
    }
  }

  /// Der tatsächlich gerenderte Bildbereich innerhalb eines Widgets, das per
  /// `BoxFit.contain` skaliert/gelettert wird (Muster: BoxFit.contain-Formel).
  /// Gemeinsame Grundlage für [_widgetPointToImagePoint] (Pixel-Koordinaten,
  /// KI-Auswahl) und [_widgetPointToNormalizedImagePoint] ([0,1]-Koordinaten,
  /// Vektorformen).
  Rect _imageDisplayRect(Size widgetSize, double imageWidth, double imageHeight) {
    final imageAspect = imageWidth / imageHeight;
    final widgetAspect = widgetSize.width / widgetSize.height;
    double renderedWidth, renderedHeight, offsetX, offsetY;
    if (imageAspect > widgetAspect) {
      renderedWidth = widgetSize.width;
      renderedHeight = widgetSize.width / imageAspect;
      offsetX = 0;
      offsetY = (widgetSize.height - renderedHeight) / 2;
    } else {
      renderedHeight = widgetSize.height;
      renderedWidth = widgetSize.height * imageAspect;
      offsetY = 0;
      offsetX = (widgetSize.width - renderedWidth) / 2;
    }
    return Rect.fromLTWH(offsetX, offsetY, renderedWidth, renderedHeight);
  }

  /// Rechnet eine Tipp-Position innerhalb des Vorschau-Widgets in eine
  /// Pixel-Koordinate des dekodierten Bilds um. `null`, wenn der Tipp im
  /// Letterbox-Rand lag.
  Offset? _widgetPointToImagePoint(Offset local, Size widgetSize, int imageWidth, int imageHeight) {
    final rect = _imageDisplayRect(widgetSize, imageWidth.toDouble(), imageHeight.toDouble());
    final dx = local.dx - rect.left;
    final dy = local.dy - rect.top;
    if (dx < 0 || dy < 0 || dx > rect.width || dy > rect.height) return null;
    return Offset(dx / rect.width * imageWidth, dy / rect.height * imageHeight);
  }

  /// Wie [_widgetPointToImagePoint], aber bild-normalisiert ([0,1]) und ohne
  /// ein dekodiertes Bitmap zu brauchen (nutzt direkt Assets.widthPx/heightPx)
  /// – für die Vektorformen-Editoren, die (anders als die KI-Auswahl) kein
  /// SAM-Embedding und damit auch keine Dekodierung des Vorschaubilds
  /// benötigen.
  Offset? _widgetPointToNormalizedImagePoint(Offset local, Size widgetSize) {
    final imageWidth = widget.asset.widthPx;
    final imageHeight = widget.asset.heightPx;
    if (imageWidth == null || imageHeight == null || imageWidth <= 0 || imageHeight <= 0) return null;
    final rect = _imageDisplayRect(widgetSize, imageWidth.toDouble(), imageHeight.toDouble());
    final dx = local.dx - rect.left;
    final dy = local.dy - rect.top;
    if (dx < 0 || dy < 0 || dx > rect.width || dy > rect.height) return null;
    return Offset(dx / rect.width, dy / rect.height);
  }

  void _handleMaskTap(Offset local, Size widgetSize) {
    final decoded = _decodedForMasking;
    if (decoded == null || _computingMask) return;
    final imagePoint = _widgetPointToImagePoint(local, widgetSize, decoded.width, decoded.height);
    if (imagePoint == null) return;
    setState(() => _maskPoints.add((point: imagePoint, isBackground: _backgroundPointMode)));
    _runMaskPrediction();
  }

  void _undoLastMaskPoint() {
    if (_maskPoints.isEmpty) return;
    setState(() => _maskPoints.removeLast());
    if (_maskPoints.isEmpty) {
      setState(() {
        _pendingMaskResult = null;
        _pendingMaskOverlayPng = null;
      });
    } else {
      _runMaskPrediction();
    }
  }

  /// EIN Forward-Pass durch den Masken-Decoder pro Punkt-Änderung (siehe
  /// SegmentationService.decodeMask) – kein Mehrschritt-Loop, daher auch
  /// bei mehreren Punkten hintereinander noch interaktiv genug.
  Future<void> _runMaskPrediction() async {
    final segmentation = _segmentation;
    final embedding = _embedding;
    if (segmentation == null || embedding == null || _maskPoints.isEmpty) return;
    setState(() => _computingMask = true);
    final foreground = [for (final p in _maskPoints) if (!p.isBackground) p.point];
    final background = [for (final p in _maskPoints) if (p.isBackground) p.point];
    if (foreground.isEmpty) {
      // SAM braucht mindestens einen Vordergrund-Punkt, um sinnvoll zu
      // starten – reine Hintergrund-Punkte allein ergeben keine Maske.
      setState(() => _computingMask = false);
      return;
    }
    final result = await segmentation.decodeMask(embedding, foregroundPoints: foreground, backgroundPoints: background);
    // Über compute() ausgelagert (Audit-Fund: Hochskalieren/Einfärben/PNG-
    // Kodieren lief vorher synchron im Haupt-Isolate bei JEDEM Punkt-Tap).
    final overlayPng = await compute(renderMaskPreviewPng, result);
    if (!mounted) return;
    setState(() {
      _pendingMaskResult = result;
      _pendingMaskOverlayPng = overlayPng;
      _computingMask = false;
    });
  }

  Future<void> _commitMask() async {
    final result = _pendingMaskResult;
    if (result == null) return;
    final pngBytes = await compute(renderMaskPngBytes, result);
    final relativePath = widget.paths.maskRelativePath(const Uuid().v4());
    final file = widget.paths.absolute(relativePath);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(pngBytes);

    await widget.db.createDevelopMask(DevelopMasksCompanion.insert(
      assetId: widget.asset.id,
      maskRelativePath: relativePath,
      label: 'Maske ${_masks.length + 1}',
      createdAt: DateTime.now(),
    ));
    final refreshedMasks = await widget.db.masksForAsset(widget.asset.id);

    if (!mounted) return;
    setState(() {
      _masks = refreshedMasks;
      _maskEditMode = false;
      _maskPoints.clear();
      _pendingMaskResult = null;
      _pendingMaskOverlayPng = null;
    });
    _selectMask(_masks.last);
    _scheduleRerender();
  }

  // --- Vektor-Masken: Zieh-Gesten -----------------------------------------

  void _handleShapePanStart(DragStartDetails details, Size widgetSize) {
    final point = _widgetPointToNormalizedImagePoint(details.localPosition, widgetSize);
    if (point == null) return;
    switch (_maskFormType) {
      case _MaskFormType.freehand:
        setState(() => _draftShape = FreehandShape(
              points: [point],
              strokeWidth: (_draftShape as FreehandShape?)?.strokeWidth ?? 0.03,
            ));
      case _MaskFormType.ellipse:
        setState(() => _ellipseDragAnchor = point);
      case _MaskFormType.gradient:
        final feather = (_draftShape as GradientShape?)?.feather ?? 0.3;
        setState(() => _draftShape =
            GradientShape(startX: point.dx, startY: point.dy, endX: point.dx, endY: point.dy, feather: feather));
      case _MaskFormType.aiSelect:
        break;
    }
  }

  void _handleShapePanUpdate(DragUpdateDetails details, Size widgetSize) {
    final point = _widgetPointToNormalizedImagePoint(details.localPosition, widgetSize);
    if (point == null) return;
    switch (_maskFormType) {
      case _MaskFormType.freehand:
        final current = _draftShape;
        if (current is! FreehandShape) return;
        setState(() =>
            _draftShape = FreehandShape(points: [...current.points, point], strokeWidth: current.strokeWidth));
      case _MaskFormType.ellipse:
        final anchor = _ellipseDragAnchor;
        if (anchor == null) return;
        final previous = _draftShape;
        final rotation = previous is EllipseShape ? previous.rotation : 0.0;
        final feather = previous is EllipseShape ? previous.feather : 0.3;
        setState(() => _draftShape = EllipseShape(
              centerX: (anchor.dx + point.dx) / 2,
              centerY: (anchor.dy + point.dy) / 2,
              radiusX: math.max(0.01, (point.dx - anchor.dx).abs() / 2),
              radiusY: math.max(0.01, (point.dy - anchor.dy).abs() / 2),
              rotation: rotation,
              feather: feather,
            ));
      case _MaskFormType.gradient:
        final current = _draftShape;
        if (current is! GradientShape) return;
        setState(() => _draftShape = GradientShape(
              startX: current.startX,
              startY: current.startY,
              endX: point.dx,
              endY: point.dy,
              feather: current.feather,
            ));
      case _MaskFormType.aiSelect:
        break;
    }
  }

  bool get _canCommitShape => switch (_maskFormType) {
        _MaskFormType.aiSelect => _pendingMaskResult != null,
        _MaskFormType.freehand => _draftShape is FreehandShape,
        _MaskFormType.ellipse => _draftShape is EllipseShape,
        _MaskFormType.gradient => _draftShape is GradientShape,
      };

  Future<void> _commitCurrentMask() =>
      _maskFormType == _MaskFormType.aiSelect ? _commitMask() : _commitShape();

  /// Rasterisiert [_draftShape] auf die tatsächliche Original-Bildauflösung
  /// (Muster: maskToOriginalResolution in segmentation_service.dart nutzt für
  /// KI-Masken dieselbe Zielauflösung) und legt eine neue DevelopMasks-Zeile
  /// an – oder, falls [_editingMaskId] gesetzt ist (erneutes Bearbeiten einer
  /// bestehenden Vektor-Maske über "Form bearbeiten"), überschreibt die
  /// vorhandene Maskendatei und aktualisiert nur ihre Geometrie.
  Future<void> _commitShape() async {
    final shape = _draftShape;
    if (shape == null) return;
    final width = widget.asset.widthPx;
    final height = widget.asset.heightPx;
    if (width == null || height == null || width <= 0 || height <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bildauflösung unbekannt – Maske kann nicht gespeichert werden.')),
        );
      }
      return;
    }
    setState(() => _computingMask = true);
    final pngBytes = await compute(rasterizeMaskShapeToPngBytes, (shape, width, height));
    var editingId = _editingMaskId;

    // Verteidigung gegen eine seit dem Öffnen des Editors zwischenzeitlich
    // gelöschte Maske (z.B. über einen anderen Weg entfernt) – ohne diese
    // Prüfung würde firstWhere() ohne Treffer abstürzen. Fällt in diesem
    // seltenen Fall auf "neu anlegen" zurück, statt die Bearbeitung zu
    // verwerfen.
    DevelopMaskData? existing;
    if (editingId != null) {
      for (final m in _masks) {
        if (m.id == editingId) existing = m;
      }
      if (existing == null) editingId = null;
    }

    if (editingId != null && existing != null) {
      await widget.paths.absolute(existing.maskRelativePath).writeAsBytes(pngBytes);
      await widget.db.updateDevelopMaskShape(editingId, shape.encode());
    } else {
      final relativePath = widget.paths.maskRelativePath(const Uuid().v4());
      final file = widget.paths.absolute(relativePath);
      await file.parent.create(recursive: true);
      await file.writeAsBytes(pngBytes);
      await widget.db.createDevelopMask(DevelopMasksCompanion.insert(
        assetId: widget.asset.id,
        maskRelativePath: relativePath,
        label: 'Maske ${_masks.length + 1}',
        createdAt: DateTime.now(),
        shapeDefinitionJson: Value(shape.encode()),
      ));
    }
    final refreshedMasks = await widget.db.masksForAsset(widget.asset.id);

    if (!mounted) return;
    setState(() {
      _masks = refreshedMasks;
      _maskEditMode = false;
      _computingMask = false;
      _draftShape = null;
    });
    DevelopMaskData? committedMask;
    if (editingId != null) {
      for (final m in refreshedMasks) {
        if (m.id == editingId) committedMask = m;
      }
    }
    committedMask ??= refreshedMasks.isEmpty ? null : refreshedMasks.last;
    _editingMaskId = null;
    if (committedMask != null) _selectMask(committedMask);
    _scheduleRerender();
  }

  Widget _slider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged, {
    bool enabled = true,
    // Für Temperatur/Tint bewusst aus: der Shader bildet den Weißabgleich
    // nur genähert nach (real gemessen bis 6,1 % Abweichung vom nativen
    // Render bei 3200 K, gegenüber 0,1 % bei Belichtung). Genau bei diesem
    // Regler beurteilt man die Farbe – eine ungenaue Live-Vorschau würde
    // zu falschen Einstellungen verleiten. Beim Ziehen dieser beiden
    // Regler bleibt es deshalb beim nativen Render.
    bool liveVorschau = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: enabled ? Colors.white : Colors.white38, fontSize: 13)),
              Text(
                value.toStringAsFixed(min.abs() >= 100 ? 0 : 2),
                style: TextStyle(color: enabled ? Colors.white70 : Colors.white24, fontSize: 12),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            // Während des Ziehens rechnet der Shader live; nach dem
            // Loslassen übernimmt wieder der native Render.
            onChangeStart:
                (enabled && liveVorschau) ? (_) => setState(() => _dragging = true) : null,
            // Bewusst NICHT hier _dragging zurücksetzen: der native Render
            // ist erst nach Debounce + Renderzeit da. Sofortiges Umschalten
            // würde für diese Zeitspanne den ALTEN Stand zeigen, das Bild
            // also sichtbar zurückspringen. Zurückgesetzt wird in
            // _requestPreview(), sobald das neue Bild vorliegt.
            onChangeEnd: null,
            onChanged: enabled
                ? (v) {
                    onChanged(v);
                    _scheduleRerender();
                  }
                : null,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Entwickeln'),
        actions: [
          if (widget.asset.restoredRelativePath != null)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              tooltip: 'KI-Restaurierung entfernen',
              onPressed: _saving ? null : _removeRestoredResult,
            ),
          IconButton(
            icon: const Icon(Icons.auto_awesome_outlined),
            tooltip: widget.restoreQueue?.restoreHalter?.installiert != true
                ? 'Benötigt das Restaurierungs-Modell (Einstellungen → KI-Modelle)'
                : 'KI-Restaurierung anwenden (läuft im Hintergrund, dauert mehrere Minuten)',
            onPressed: (_saving || widget.restoreQueue?.restoreHalter?.installiert != true) ? null : _enqueueRestore,
          ),
          IconButton(
            icon: const Icon(Icons.auto_fix_high_outlined),
            tooltip: 'Maske hinzufügen',
            onPressed: (_saving || _maskEditMode) ? null : () => _startMaskCreation(),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Verlauf',
            onPressed: _saving ? null : _showHistory,
          ),
          TextButton(
            onPressed: _saving ? null : _reset,
            child: const Text('Zurücksetzen', style: TextStyle(color: Colors.white70)),
          ),
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              tooltip: 'Speichern',
              onPressed: _save,
            ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Row(
                children: [
                  Expanded(
                    child: Center(
                      child: _previewBytes == null
                          ? (_error != null
                              ? Padding(
                                  padding: const EdgeInsets.all(AppSpacing.xxl),
                                  child: Text(_error!, style: const TextStyle(color: Colors.white70)),
                                )
                              : const CircularProgressIndicator())
                          : _maskEditMode
                              ? _buildMaskEditor()
                              : GestureDetector(
                                  onLongPressStart: (_) {
                                    _ensureOriginalPreviewLoaded();
                                    setState(() => _showingOriginal = true);
                                  },
                                  onLongPressEnd: (_) => setState(() => _showingOriginal = false),
                                  onLongPressCancel: () => setState(() => _showingOriginal = false),
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(AppSpacing.lg),
                                        child: (_zeigeShaderVorschau && !_showingOriginal)
                                            ? DevelopShaderPreview(
                                                shader: _shader,
                                                image: _shaderBasis!,
                                                adjustments: _currentAdjustments(),
                                              )
                                            : Image.memory(
                                                (_showingOriginal && _originalPreviewBytes != null)
                                                    ? _originalPreviewBytes!
                                                    : _previewBytes!,
                                                gaplessPlayback: true,
                                                fit: BoxFit.contain,
                                              ),
                                      ),
                                      if (_showingOriginal)
                                        Positioned(
                                          top: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: AppSpacing.xs),
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius: BorderRadius.circular(AppRadius.pill),
                                            ),
                                            child: const Text('Original',
                                                style: TextStyle(color: Colors.white, fontSize: 12)),
                                          ),
                                        )
                                      else
                                        const Positioned(
                                          bottom: 4,
                                          child: Text(
                                            'Zum Vergleichen gedrückt halten',
                                            style: TextStyle(color: Colors.white38, fontSize: 11),
                                          ),
                                        ),
                                      if (_rendering)
                                        const Padding(
                                          padding: EdgeInsets.only(bottom: AppSpacing.lg),
                                          child: SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                    ),
                  ),
                  Container(
                    width: 300,
                    color: const Color(0xFF1A1A1A),
                    child: _maskEditMode ? _buildMaskCreationPanel() : _buildAdjustmentsPanel(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildMaskEditor() =>
      _maskFormType == _MaskFormType.aiSelect ? _buildAiSelectMaskEditor() : _buildShapeMaskEditor();

  Widget _buildAiSelectMaskEditor() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final widgetSize = Size(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          onTapUp: (details) => _handleMaskTap(details.localPosition, widgetSize),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Image.memory(_previewBytes!, gaplessPlayback: true, fit: BoxFit.contain),
              ),
              if (_pendingMaskOverlayPng != null)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Image.memory(_pendingMaskOverlayPng!, gaplessPlayback: true, fit: BoxFit.contain),
                ),
              if (_computingEmbedding)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white70),
                    const SizedBox(height: 12),
                    Text(
                      _ladeSegmentierungsmodell
                          ? 'Modell für die KI-Auswahl wird geladen …'
                          : 'Bild wird für die Maskierung vorbereitet …',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                )
              else if (_computingMask)
                const Positioned(
                  bottom: 16,
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Editor für Pinsel/Ellipse/Verlauf: zeichnet [_draftShape] live über
  /// einen [CustomPainter] in Widget-Koordinaten (schnell, keine erneute
  /// Rasterisierung bei jeder Zeigerbewegung) – die tatsächliche, präzise
  /// Rasterisierung auf Originalauflösung passiert erst einmalig bei
  /// "Fertig" (siehe [_commitShape]).
  Widget _buildShapeMaskEditor() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final widgetSize = Size(constraints.maxWidth, constraints.maxHeight);
        final assetWidth = widget.asset.widthPx;
        final assetHeight = widget.asset.heightPx;
        final displayRect = (assetWidth != null && assetHeight != null && assetWidth > 0 && assetHeight > 0)
            ? _imageDisplayRect(widgetSize, assetWidth.toDouble(), assetHeight.toDouble())
            : Rect.fromLTWH(0, 0, widgetSize.width, widgetSize.height);
        return GestureDetector(
          onPanStart: (details) => _handleShapePanStart(details, widgetSize),
          onPanUpdate: (details) => _handleShapePanUpdate(details, widgetSize),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Image.memory(_previewBytes!, gaplessPlayback: true, fit: BoxFit.contain),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: _ShapeDraftPainter(_draftShape, displayRect)),
                ),
              ),
              if (_computingMask)
                const Positioned(
                  bottom: 16,
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMaskCreationPanel() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Maske erstellen', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          SegmentedButton<_MaskFormType>(
            segments: [
              ButtonSegment(
                value: _MaskFormType.aiSelect,
                label: const Text('KI'),
                icon: const Icon(Icons.auto_awesome_outlined, size: 16),
                enabled: widget.segmentation?.installiert ?? false,
              ),
              const ButtonSegment(
                value: _MaskFormType.freehand,
                label: Text('Pinsel'),
                icon: Icon(Icons.brush_outlined, size: 16),
              ),
              const ButtonSegment(
                value: _MaskFormType.ellipse,
                label: Text('Ellipse'),
                icon: Icon(Icons.circle_outlined, size: 16),
              ),
              const ButtonSegment(
                value: _MaskFormType.gradient,
                label: Text('Verlauf'),
                icon: Icon(Icons.gradient_outlined, size: 16),
              ),
            ],
            selected: {_maskFormType},
            showSelectedIcon: false,
            onSelectionChanged: (s) => _switchMaskFormType(s.first),
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildMaskFormTypePanel()),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(onPressed: _cancelMaskCreation, child: const Text('Abbrechen')),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _canCommitShape ? _commitCurrentMask : null,
                  child: const Text('Fertig'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMaskFormTypePanel() => switch (_maskFormType) {
        _MaskFormType.aiSelect => _buildAiSelectPanel(),
        _MaskFormType.freehand => _buildFreehandPanel(),
        _MaskFormType.ellipse => _buildEllipsePanel(),
        _MaskFormType.gradient => _buildGradientPanel(),
      };

  Widget _buildAiSelectPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Auf den Bereich tippen, den du anpassen möchtest. Mehrere Tipps verfeinern die Auswahl.',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 16),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('Hinzufügen'), icon: Icon(Icons.add)),
            ButtonSegment(value: true, label: Text('Entfernen'), icon: Icon(Icons.remove)),
          ],
          selected: {_backgroundPointMode},
          onSelectionChanged: (s) => setState(() => _backgroundPointMode = s.first),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: _maskPoints.isEmpty ? null : _undoLastMaskPoint,
          icon: const Icon(Icons.undo, color: Colors.white70, size: 18),
          label: const Text('Letzten Punkt entfernen', style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }

  Widget _buildFreehandPanel() {
    final shape = _draftShape;
    final strokeWidth = shape is FreehandShape ? shape.strokeWidth : 0.03;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Über den Bereich ziehen, den du anpassen möchtest.',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 16),
        _shapeSlider('Strichbreite', strokeWidth, 0.01, 0.15, (v) {
          setState(() => _draftShape =
              FreehandShape(points: shape is FreehandShape ? shape.points : const [], strokeWidth: v));
        }),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: shape == null ? null : () => setState(() => _draftShape = null),
          icon: const Icon(Icons.undo, color: Colors.white70, size: 18),
          label: const Text('Neu zeichnen', style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }

  Widget _buildEllipsePanel() {
    final shape = _draftShape;
    final rotationDeg = shape is EllipseShape ? shape.rotation * 180 / math.pi : 0.0;
    final feather = shape is EllipseShape ? shape.feather : 0.3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Über den Bereich ziehen, um die Ellipse aufzuziehen.',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 16),
        _shapeSlider('Rotation (°)', rotationDeg, -180, 180, (v) {
          if (shape is! EllipseShape) return;
          setState(() => _draftShape = EllipseShape(
                centerX: shape.centerX,
                centerY: shape.centerY,
                radiusX: shape.radiusX,
                radiusY: shape.radiusY,
                rotation: v * math.pi / 180,
                feather: shape.feather,
              ));
        }, enabled: shape is EllipseShape),
        _shapeSlider('Weichzeichnung', feather, 0, 1, (v) {
          if (shape is! EllipseShape) return;
          setState(() => _draftShape = EllipseShape(
                centerX: shape.centerX,
                centerY: shape.centerY,
                radiusX: shape.radiusX,
                radiusY: shape.radiusY,
                rotation: shape.rotation,
                feather: v,
              ));
        }, enabled: shape is EllipseShape),
      ],
    );
  }

  Widget _buildGradientPanel() {
    final shape = _draftShape;
    final feather = shape is GradientShape ? shape.feather : 0.3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Von einer Kante zur anderen ziehen, um den Verlauf festzulegen.',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 16),
        _shapeSlider('Weichzeichnung', feather, 0, 1, (v) {
          if (shape is! GradientShape) return;
          setState(() => _draftShape = GradientShape(
                startX: shape.startX,
                startY: shape.startY,
                endX: shape.endX,
                endY: shape.endY,
                feather: v,
              ));
        }, enabled: shape is GradientShape),
      ],
    );
  }

  /// Wie [_slider], aber ohne [_scheduleRerender] – die Vektorformen-Werte
  /// wirken erst nach "Fertig" ([_commitShape]) auf das Bild, ein
  /// zwischenzeitlicher nativer Re-Render bei jeder Regler-Bewegung wäre nur
  /// verschwendete Arbeit.
  Widget _shapeSlider(String label, double value, double min, double max, ValueChanged<double> onChanged,
      {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: enabled ? Colors.white : Colors.white38, fontSize: 13)),
              Text(
                value.toStringAsFixed(min.abs() >= 100 ? 0 : 2),
                style: TextStyle(color: enabled ? Colors.white70 : Colors.white24, fontSize: 12),
              ),
            ],
          ),
          Slider(value: value, min: min, max: max, onChanged: enabled ? onChanged : null),
        ],
      ),
    );
  }

  Widget _buildAdjustmentsPanel() {
    final editingMask = _selectedMaskId != null;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ganz oben: das Histogramm zeigt immer die gesamte Vorschau, also
          // das Ergebnis aller Anpassungen zusammen – auch beim Bearbeiten
          // einer einzelnen Maske.
          HistogramView(data: _histogram, isStale: _histogramPending || _rendering),
          const SizedBox(height: AppSpacing.lg),
          const Divider(color: Colors.white24),
          const SizedBox(height: AppSpacing.sm),
          if (_masks.isNotEmpty) ...[
            const Text('Anpassung für', style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ChoiceChip(
                  label: const Text('Ganzes Bild'),
                  selected: !editingMask,
                  onSelected: (_) => _selectGlobalAdjustments(),
                ),
                for (final mask in _masks)
                  InputChip(
                    label: Text(mask.label),
                    selected: mask.id == _selectedMaskId,
                    onPressed: () => _selectMask(mask),
                    onDeleted: () => _deleteMask(mask),
                    deleteIcon: const Icon(Icons.close, size: 16),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
          ],
          if (editingMask) ..._buildEditShapeButtonIfVector(),
          if (editingMask) ..._buildMaskSliders() else ..._buildGlobalSliders(),
        ],
      ),
    );
  }

  /// Zeigt "Form bearbeiten" nur für Masken, die als Vektorform angelegt
  /// wurden (`shapeDefinitionJson != null`) – SAM-Masken haben keine
  /// nachträglich editierbare Geometrie, nur ihre Regler-Werte.
  List<Widget> _buildEditShapeButtonIfVector() {
    DevelopMaskData? mask;
    for (final m in _masks) {
      if (m.id == _selectedMaskId) mask = m;
    }
    // Verteidigung: _selectedMaskId kann theoretisch veraltet sein, falls
    // sich _masks und die Auswahl je auseinander entwickeln (firstWhere()
    // ohne Treffer würde sonst abstürzen).
    if (mask == null || mask.shapeDefinitionJson == null) return const [];
    return [
      Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: OutlinedButton.icon(
          onPressed: () => _startMaskCreation(editingMask: mask),
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('Form bearbeiten'),
        ),
      ),
    ];
  }

  List<Widget> _buildGlobalSliders() => [
        _slider('Belichtung', _exposure, -3, 3, (v) => setState(() => _exposure = v)),
        const Divider(color: Colors.white24),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Automatischer Weißabgleich', style: TextStyle(color: Colors.white, fontSize: 13)),
          value: _autoWhiteBalance,
          onChanged: (v) {
            setState(() => _autoWhiteBalance = v);
            _scheduleRerender();
          },
        ),
        _slider('Temperatur (K)', _temperature, 2000, 12000, (v) => setState(() => _temperature = v),
            enabled: !_autoWhiteBalance, liveVorschau: false),
        _slider('Tint', _tint, -100, 100, (v) => setState(() => _tint = v),
            enabled: !_autoWhiteBalance, liveVorschau: false),
        const Divider(color: Colors.white24),
        _slider('Kontrast', _contrast, -1, 1, (v) => setState(() => _contrast = v)),
        _slider('Schatten', _shadows, -1, 1, (v) => setState(() => _shadows = v)),
        _slider('Schärfe', _sharpness, 0, 1, (v) => setState(() => _sharpness = v)),
        _slider('Rauschunterdrückung', _noiseReduction, 0, 1, (v) => setState(() => _noiseReduction = v)),
        const Divider(color: Colors.white24),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Objektivkorrektur', style: TextStyle(color: Colors.white, fontSize: 13)),
          subtitle: const Text(
            'Nur wirksam für RAW-Fotos, deren Kamera/Objektiv unterstützt wird.',
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),
          value: _lensCorrectionEnabled,
          onChanged: (v) {
            setState(() => _lensCorrectionEnabled = v);
            _scheduleRerender();
          },
        ),
      ];

  List<Widget> _buildMaskSliders() => [
        const Text(
          'Diese Anpassungen wirken nur innerhalb der ausgewählten Maske.',
          style: TextStyle(color: Colors.white38, fontSize: 11),
        ),
        const SizedBox(height: 8),
        _slider('Belichtung', _maskExposure, -3, 3, (v) => setState(() => _maskExposure = v)),
        const Divider(color: Colors.white24),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Automatischer Weißabgleich', style: TextStyle(color: Colors.white, fontSize: 13)),
          value: _maskAutoWhiteBalance,
          onChanged: (v) {
            setState(() => _maskAutoWhiteBalance = v);
            _scheduleRerender();
          },
        ),
        _slider('Temperatur (K)', _maskTemperature, 2000, 12000, (v) => setState(() => _maskTemperature = v),
            enabled: !_maskAutoWhiteBalance),
        _slider('Tint', _maskTint, -100, 100, (v) => setState(() => _maskTint = v), enabled: !_maskAutoWhiteBalance),
        const Divider(color: Colors.white24),
        _slider('Kontrast', _maskContrast, -1, 1, (v) => setState(() => _maskContrast = v)),
        _slider('Schatten', _maskShadows, -1, 1, (v) => setState(() => _maskShadows = v)),
        _slider('Schärfe', _maskSharpness, 0, 1, (v) => setState(() => _maskSharpness = v)),
        _slider('Rauschunterdrückung', _maskNoiseReduction, 0, 1, (v) => setState(() => _maskNoiseReduction = v)),
      ];
}

/// Zeichnet [shape] live über die Vorschau, in Widget-Koordinaten
/// (Muster: _CropMaskPainter in image_editor_screen.dart) – reine
/// Editier-Vorschau, NICHT die tatsächlich gespeicherte Maske (die entsteht
/// erst bei "Fertig" per [rasterizeMaskShape] auf voller Auflösung).
class _ShapeDraftPainter extends CustomPainter {
  final MaskShapeDefinition? shape;
  final Rect displayRect;
  _ShapeDraftPainter(this.shape, this.displayRect);

  Offset _toWidget(double nx, double ny) =>
      Offset(displayRect.left + nx * displayRect.width, displayRect.top + ny * displayRect.height);

  @override
  void paint(Canvas canvas, Size size) {
    final s = shape;
    if (s == null) return;
    const fillColor = Color(0x8C2196F3); // Muster: maskToPreviewOverlay (33,150,243, alpha 140).
    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    switch (s) {
      case FreehandShape():
        if (s.points.isEmpty) return;
        final path = Path();
        final first = _toWidget(s.points.first.dx, s.points.first.dy);
        path.moveTo(first.dx, first.dy);
        for (final p in s.points.skip(1)) {
          final w = _toWidget(p.dx, p.dy);
          path.lineTo(w.dx, w.dy);
        }
        final strokeWidthPx = s.strokeWidth * math.max(displayRect.width, displayRect.height);
        canvas.drawPath(
          path,
          Paint()
            ..color = fillColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidthPx
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      case EllipseShape():
        final center = _toWidget(s.centerX, s.centerY);
        final rx = s.radiusX * displayRect.width;
        final ry = s.radiusY * displayRect.height;
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(s.rotation);
        final rect = Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2);
        canvas.drawOval(rect, Paint()..color = fillColor);
        canvas.drawOval(rect, strokePaint);
        canvas.restore();
      case GradientShape():
        final start = _toWidget(s.startX, s.startY);
        final end = _toWidget(s.endX, s.endY);
        canvas.drawLine(start, end, strokePaint);
        canvas.drawCircle(start, 6, Paint()..color = Colors.white);
        canvas.drawCircle(end, 6, Paint()..color = Colors.white);
        final dir = end - start;
        if (dir.distance > 0) {
          final normal = Offset(-dir.dy, dir.dx) / dir.distance * 40;
          final band = Path()
            ..moveTo((start + normal).dx, (start + normal).dy)
            ..lineTo((start - normal).dx, (start - normal).dy)
            ..lineTo((end - normal).dx, (end - normal).dy)
            ..lineTo((end + normal).dx, (end + normal).dy)
            ..close();
          canvas.drawPath(band, Paint()..color = fillColor);
        }
    }
  }

  @override
  bool shouldRepaint(covariant _ShapeDraftPainter oldDelegate) =>
      oldDelegate.shape != shape || oldDelegate.displayRect != displayRect;
}
