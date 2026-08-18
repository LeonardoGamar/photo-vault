import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/native_image_converter.dart';
import '../state/library_state.dart';
import '../theme/app_spacing.dart';
import '../widgets/progress_dialog.dart';
import 'asset_viewer_screen.dart';
import 'automation_rules_screen.dart';
import 'camera_presets_screen.dart';
import 'export_presets_screen.dart';
import 'duplicates_screen.dart';
import 'integrity_check_screen.dart';
import 'stack_review_screen.dart';
import 'statistics_screen.dart';
import 'xmp_import_screen.dart';

/// Eigenständiger Bereich für Werkzeuge, die nicht Teil des normalen
/// Durchstöberns der Bibliothek sind: manueller Gesichts-Scan (inkl. der
/// Ähnlichkeitsschwelle für "Ähnliche mit auswählen" im Personen-Tab) sowie
/// die Duplikat-/Ähnlichkeitssuche.
class ToolsScreen extends StatefulWidget {
  final LibraryState library;
  const ToolsScreen({super.key, required this.library});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  late double _threshold = widget.library.faceSimilarityThreshold;
  // Ändert sich nie während der Laufzeit (native Fähigkeit des Rechners) –
  // einmalig statt inline in build() abgefragt, damit ein FutureBuilder
  // nicht bei jedem Rebuild neu in den Ladezustand zurückfällt.
  late final Future<bool> _nativeConversionSupportedFuture = NativeImageConverter.isSupported();

  /// Zeigt einen Fortschrittsdialog über einem Nachholvorgang.
  ///
  /// Titel und Leermeldung werden VOR dem Dialog aufgelöst: Der Mapper unten
  /// läuft bei jedem Fortschritts-Ereignis, also lange nach dem Aufbau des
  /// Dialogs, und dürfte den BuildContext bis dahin nicht festhalten.
  Future<void> _zeigeFortschritt({
    required String titel,
    required String wennLeer,
    required Stream<dynamic> lauf,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgressDialog(
        title: titel,
        stream: lauf.map((p) => p.total == 0
            ? wennLeer
            : '${p.done} / ${p.total}${p.currentFile != null ? ' — ${p.currentFile}' : ''}'),
      ),
    );
  }

  /// Lädt alle noch unbewerteten Fotos/Videos und öffnet sie im Vollbild-
  /// Sichtungs-Modus (Culling). Zweiter Einstiegspunkt neben dem "Jetzt
  /// sichten"-Vorschlag direkt nach dem Import (siehe ImportProgressSheet).
  Future<void> _openCulling() async {
    final assets = await widget.library.db.assetsForCulling();
    if (!mounted) return;
    if (assets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTexte.of(context).werkzKeineUnbewerteten)),
      );
      return;
    }
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AssetViewerScreen(
        assets: assets,
        initialIndex: 0,
        paths: widget.library.paths,
        db: widget.library.db,
        library: widget.library,
        onToggleFavorite: (a) => widget.library.db.setFavorite(a.id, !a.isFavorite),
        cullingMode: true,
      ),
    ));
  }

  Future<void> _runFaceRescan() async {
    if (!widget.library.faceDetectionAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppTexte.of(context).werkzYunetNoetig),
      ));
      return;
    }

    final onlyNew = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppTexte.of(context).werkzGesichterScannenTitel),
        content: Text(AppTexte.of(context).werkzGesichterScannenFrage),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppTexte.of(context).allgAbbrechen)),
          OutlinedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppTexte.of(context).werkzNurNeueFotos),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppTexte.of(context).werkzAlleErneutScannen),
          ),
        ],
      ),
    );
    if (onlyNew == null || !mounted) return;

    final t = AppTexte.of(context);
    await _zeigeFortschritt(
      titel: onlyNew ? t.werkzScanneNeue : t.werkzScanneAlle,
      wennLeer: t.werkzKeinePassenden,
      lauf: widget.library.rescanFaces(onlyNewPhotos: onlyNew),
    );
  }

  Future<void> _runThumbnailRegen() async {
    final onlyMissing = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppTexte.of(context).werkzVorschauNeuTitel),
        content: Text(AppTexte.of(context).werkzVorschauNeuFrage),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppTexte.of(context).allgAbbrechen)),
          OutlinedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppTexte.of(context).werkzNurFehlende),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppTexte.of(context).werkzAlleNeuErstellen),
          ),
        ],
      ),
    );
    if (onlyMissing == null || !mounted) return;

    final t = AppTexte.of(context);
    await _zeigeFortschritt(
      titel: onlyMissing ? t.werkzErstelleFehlende : t.werkzErstelleAlle,
      wennLeer: t.werkzKeinePassenden,
      lauf: widget.library.regenerateThumbnails(onlyMissing: onlyMissing),
    );
  }

  Future<void> _runRedevelopAll() async {
    final t = AppTexte.of(context);
    await _zeigeFortschritt(
      titel: t.werkzRendereNeu,
      wennLeer: t.werkzKeineEntwickelten,
      lauf: widget.library.redevelopAll(),
    );
  }

  Future<void> _runLivePhotoRelink() async {
    final t = AppTexte.of(context);
    await _zeigeFortschritt(
      titel: t.werkzPruefeLivePhotos,
      wennLeer: t.werkzKeineUnverknuepften,
      lauf: widget.library.relinkLivePhotos(),
    );
  }

  Future<void> _runEmbeddingBackfill() async {
    if (!widget.library.clipAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppTexte.of(context).werkzClipNoetig),
      ));
      return;
    }
    final t = AppTexte.of(context);
    await _zeigeFortschritt(
      titel: t.werkzBerechneEmbeddings,
      wennLeer: t.werkzAlleHabenEmbedding,
      lauf: widget.library.backfillClipEmbeddings(),
    );
  }

  Future<void> _runAiTaggingBackfill() async {
    if (!widget.library.clipAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppTexte.of(context).werkzClipNoetig),
      ));
      return;
    }
    final onlyUntagged = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppTexte.of(context).werkzKiTagsTitel),
        content: Text(AppTexte.of(context).werkzKiTagsFrage),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppTexte.of(context).allgAbbrechen)),
          OutlinedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppTexte.of(context).werkzNurUngetaggte),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppTexte.of(context).werkzAlleFotos),
          ),
        ],
      ),
    );
    if (onlyUntagged == null || !mounted) return;

    final t = AppTexte.of(context);
    await _zeigeFortschritt(
      titel: t.werkzBerechneKiTags,
      wennLeer: t.werkzKeinePassenden,
      lauf: widget.library.backfillAiTags(onlyUntagged: onlyUntagged),
    );
  }

  Future<void> _runLocationBackfill() async {
    final t = AppTexte.of(context);
    await _zeigeFortschritt(
      titel: t.werkzLeseOrte,
      wennLeer: t.werkzAlleHabenOrt,
      lauf: widget.library.backfillLocations(),
    );
  }

  Future<void> _runLocationNameBackfill() async {
    if (!widget.library.geoDataAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppTexte.of(context).werkzGeoNoetig),
      ));
      return;
    }
    final t = AppTexte.of(context);
    await _zeigeFortschritt(
      titel: t.werkzLoeseOrteAuf,
      wennLeer: t.werkzAlleAufgeloest,
      lauf: widget.library.backfillLocationNames(),
    );
  }

  Future<void> _runCameraMetadataBackfill() async {
    final t = AppTexte.of(context);
    await _zeigeFortschritt(
      titel: t.werkzLeseKameradaten,
      wennLeer: t.werkzAlleHabenKameradaten,
      lauf: widget.library.backfillCameraMetadata(),
    );
  }

  Future<void> _runXmpSidecarExport() async {
    final t = AppTexte.of(context);
    await _zeigeFortschritt(
      titel: t.werkzSchreibeXmp,
      wennLeer: t.werkzKeineFotosGesperrt,
      lauf: widget.library.writeXmpSidecars(),
    );
  }

  Future<void> _runOcrBackfill() async {
    final t = AppTexte.of(context);
    await _zeigeFortschritt(
      titel: t.werkzErkenneText,
      wennLeer: t.werkzAlleTextDurchsucht,
      lauf: widget.library.backfillOcrText(),
    );
  }

  Future<void> _runCaptionBackfill() async {
    if (!widget.library.captioningAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppTexte.of(context).werkzBeschreibungsmodellNoetig),
      ));
      return;
    }
    final t = AppTexte.of(context);
    await _zeigeFortschritt(
      titel: t.werkzErzeugeBeschreibungen,
      wennLeer: t.werkzAlleHabenBeschreibung,
      lauf: widget.library.backfillCaptions(),
    );
  }

  Future<void> _runBlurBackfill() async {
    final t = AppTexte.of(context);
    await _zeigeFortschritt(
      titel: t.werkzBerechneUnschaerfe,
      wennLeer: t.werkzAlleHabenUnschaerfe,
      lauf: widget.library.backfillBlurScores(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTexte.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.navWerkzeuge)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(t.werkzAbschnittStatistik, style: Theme.of(context).textTheme.titleMedium),
          Card(
            child: ListTile(
              leading: const Icon(Icons.bar_chart_outlined),
              title: Text(t.werkzAnalyseseiteTitel),
              subtitle: Text(t.werkzAnalyseseiteText),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => StatisticsScreen(library: widget.library)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(t.werkzAbschnittGesichtserkennung, style: Theme.of(context).textTheme.titleMedium),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.face_retouching_natural_outlined),
                  title: Text(t.werkzGesichterScannenTitel),
                  subtitle: Text(t.werkzGesichterScannenUntertitel),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _runFaceRescan,
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xs),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(t.werkzSchwelleLabel,
                            style: const TextStyle(fontSize: 13)),
                      ),
                      Expanded(
                        flex: 3,
                        child: Slider(
                          value: _threshold,
                          min: 0.15,
                          max: 0.6,
                          divisions: 18,
                          label: _threshold.toStringAsFixed(2),
                          onChanged: (v) => setState(() => _threshold = v),
                          // Erst beim Loslassen speichern: Das Schreiben
                          // rechnet zugleich die persönlichen Schwellen
                          // aller Personen neu (siehe
                          // AppDatabase.setFaceSimilarityThreshold) – bei
                          // jeder Reglerbewegung wäre das eine Datenbank-
                          // Transaktion pro Bild.
                          onChangeEnd: (v) => widget.library.setFaceSimilarityThreshold(v),
                        ),
                      ),
                      SizedBox(width: 36, child: Text(_threshold.toStringAsFixed(2))),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
                  child: Text(
                    t.werkzSchwelleErklaerung,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(t.werkzAbschnittVorschau, style: Theme.of(context).textTheme.titleMedium),
          Card(
            child: Column(
              children: [
                FutureBuilder<bool>(
                  future: _nativeConversionSupportedFuture,
                  builder: (context, snapshot) {
                    final supported = snapshot.data ?? false;
                    return ListTile(
                      leading: Icon(
                        supported ? Icons.check_circle_outline : Icons.error_outline,
                        color: supported ? Colors.green : Colors.orange,
                      ),
                      title: Text(t.werkzHeicTitel),
                      subtitle: Text(supported ? t.werkzHeicAktiv : t.werkzHeicInaktiv),
                      isThreeLine: true,
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.image_outlined),
                  title: Text(t.werkzVorschauNeuTitel),
                  subtitle: Text(t.werkzVorschauNeuUntertitel),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _runThumbnailRegen,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(t.werkzAbschnittEntwicklung, style: Theme.of(context).textTheme.titleMedium),
          Card(
            child: ListTile(
              leading: const Icon(Icons.exposure),
              title: Text(t.werkzNeuRendernTitel),
              subtitle: Text(t.werkzNeuRendernText),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
              onTap: _runRedevelopAll,
            ),
          ),
          const SizedBox(height: 20),
          Text(t.werkzAbschnittLivePhotos, style: Theme.of(context).textTheme.titleMedium),
          Card(
            child: ListTile(
              leading: const Icon(Icons.motion_photos_on_outlined),
              title: Text(t.werkzLivePhotoTitel),
              subtitle: Text(t.werkzLivePhotoText),
              trailing: const Icon(Icons.chevron_right),
              onTap: _runLivePhotoRelink,
            ),
          ),
          const SizedBox(height: 20),
          Text(t.werkzAbschnittOrte, style: Theme.of(context).textTheme.titleMedium),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(t.werkzOrteEinlesenTitel),
                  subtitle: Text(t.werkzOrteEinlesenText),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _runLocationBackfill,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.map_outlined),
                  title: Text(t.werkzOrteAufloesenTitel),
                  subtitle: Text(t.werkzOrteAufloesenText),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _runLocationNameBackfill,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(t.werkzAbschnittKamera, style: Theme.of(context).textTheme.titleMedium),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: Text(t.werkzKameradatenTitel),
                  subtitle: Text(t.werkzKameradatenText),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _runCameraMetadataBackfill,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.tune_outlined),
                  title: Text(t.werkzPresetsTitel),
                  subtitle: Text(t.werkzPresetsText),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => CameraPresetsScreen(library: widget.library)),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.photo_size_select_large_outlined),
                  title: Text(t.werkzExportVorgabenTitel),
                  subtitle: Text(t.werkzExportVorgabenText),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => ExportPresetsScreen(library: widget.library)),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.rule_outlined),
                  title: Text(t.werkzRegelnTitel),
                  subtitle: Text(t.werkzRegelnText),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => AutomationRulesScreen(library: widget.library)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(t.werkzAbschnittQualitaet, style: Theme.of(context).textTheme.titleMedium),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.text_fields_outlined),
                  title: Text(t.werkzOcrTitel),
                  subtitle: Text(t.werkzOcrText),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _runOcrBackfill,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.short_text_outlined),
                  title: Text(t.werkzBeschreibungenTitel),
                  subtitle: Text(t.werkzBeschreibungenText),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _runCaptionBackfill,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.deblur_outlined),
                  title: Text(t.werkzUnschaerfeTitel),
                  subtitle: Text(t.werkzUnschaerfeText),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _runBlurBackfill,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(t.werkzAbschnittBildsuche, style: Theme.of(context).textTheme.titleMedium),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.play_circle_outline),
                  title: Text(t.werkzAllesNachholenTitel),
                  subtitle: Text(t.werkzAllesNachholenText),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    widget.library.starteHintergrundanalyse();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(t.werkzAnalyseGestartet)),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.travel_explore_outlined),
                  title: Text(t.werkzEmbeddingsTitel),
                  subtitle: Text(t.werkzEmbeddingsText),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _runEmbeddingBackfill,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.sell_outlined),
                  title: Text(t.werkzKiTagsTitel),
                  subtitle: Text(t.werkzKiTagsKarteText),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _runAiTaggingBackfill,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(t.werkzAbschnittBibliothek, style: Theme.of(context).textTheme.titleMedium),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.rate_review_outlined),
                  title: Text(t.werkzSichtenTitel),
                  subtitle: Text(t.werkzSichtenText),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _openCulling,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.compare_outlined),
                  title: Text(t.werkzDuplikateTitel),
                  subtitle: Text(t.werkzDuplikateText),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => DuplicatesScreen(library: widget.library)),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.filter_none_outlined),
                  title: Text(t.werkzStapelTitel),
                  subtitle: Text(t.werkzStapelText),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => StackReviewScreen(library: widget.library)),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.fact_check_outlined),
                  title: Text(t.werkzIntegritaetTitel),
                  subtitle: Text(t.werkzIntegritaetText),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => IntegrityCheckScreen(library: widget.library)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(t.werkzAbschnittInterop, style: Theme.of(context).textTheme.titleMedium),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(t.werkzXmpSchreibenTitel),
                  subtitle: Text(t.werkzXmpSchreibenText),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _runXmpSidecarExport,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.file_open_outlined),
                  title: Text(t.werkzXmpLesenTitel),
                  subtitle: Text(t.werkzXmpLesenText),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => XmpImportScreen(library: widget.library)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
