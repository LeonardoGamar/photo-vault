import 'package:flutter/material.dart';

import '../services/native_image_converter.dart';
import '../state/library_state.dart';
import '../theme/app_spacing.dart';
import '../widgets/progress_dialog.dart';
import 'asset_viewer_screen.dart';
import 'automation_rules_screen.dart';
import 'camera_presets_screen.dart';
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

  /// Lädt alle noch unbewerteten Fotos/Videos und öffnet sie im Vollbild-
  /// Sichtungs-Modus (Culling). Zweiter Einstiegspunkt neben dem "Jetzt
  /// sichten"-Vorschlag direkt nach dem Import (siehe ImportProgressSheet).
  Future<void> _openCulling() async {
    final assets = await widget.library.db.assetsForCulling();
    if (!mounted) return;
    if (assets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keine unbewerteten Fotos gefunden.')),
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Dafür wird zuerst das YuNet-Modell benötigt (Einstellungen → KI-Modelle).'),
      ));
      return;
    }

    final onlyNew = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gesichter scannen'),
        content: const Text(
          'Nur neue Fotos scannen: schnell, überspringt bereits gescannte Fotos.\n\n'
          'Alle Fotos erneut scannen: prüft die komplette Bibliothek neu (z.B. '
          'sinnvoll nach einem Update der Gesichtserkennung, oder um die '
          'Geschlossene-Augen-Erkennung nachträglich für bereits gescannte '
          'Fotos zu berechnen) – dauert bei großen Bibliotheken entsprechend '
          'länger. Bereits manuell zugeordnete Gesichter bleiben dabei erhalten.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
          OutlinedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Nur neue Fotos'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Alle erneut scannen'),
          ),
        ],
      ),
    );
    if (onlyNew == null || !mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgressDialog(
        title: onlyNew ? 'Scanne neue Fotos …' : 'Scanne alle Fotos erneut …',
        stream: widget.library.rescanFaces(onlyNewPhotos: onlyNew).map(
              (p) => p.total == 0
                  ? 'Keine passenden Fotos gefunden.'
                  : '${p.done} / ${p.total}${p.currentFile != null ? ' — ${p.currentFile}' : ''}',
            ),
      ),
    );
  }

  Future<void> _runThumbnailRegen() async {
    final onlyMissing = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vorschaubilder neu erstellen'),
        content: const Text(
          'Nur fehlende: verarbeitet nur Fotos/Videos, die aktuell kein '
          'Thumbnail haben (z.B. HEIC-Fotos, die vor Einrichtung der '
          'nativen Bildkonvertierung importiert wurden, oder Videos, die '
          'vor Einführung der Video-Thumbnail-Erzeugung importiert '
          'wurden).\n\n'
          'Alle neu erstellen: erzeugt für die komplette Bibliothek neue '
          'Thumbnails/Vorschauen – sinnvoll z.B. nach einem Update der '
          'Bild- oder Videokonvertierung. Dauert bei großen Bibliotheken '
          'entsprechend länger.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
          OutlinedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Nur fehlende'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Alle neu erstellen'),
          ),
        ],
      ),
    );
    if (onlyMissing == null || !mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgressDialog(
        title: onlyMissing ? 'Erstelle fehlende Vorschaubilder …' : 'Erstelle alle Vorschaubilder neu …',
        stream: widget.library.regenerateThumbnails(onlyMissing: onlyMissing).map(
              (p) => p.total == 0
                  ? 'Keine passenden Fotos gefunden.'
                  : '${p.done} / ${p.total}${p.currentFile != null ? ' — ${p.currentFile}' : ''}',
            ),
      ),
    );
  }

  Future<void> _runRedevelopAll() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgressDialog(
        title: 'Rendere entwickelte Fotos neu …',
        stream: widget.library.redevelopAll().map(
              (p) => p.total == 0
                  ? 'Keine entwickelten Fotos gefunden.'
                  : '${p.done} / ${p.total}${p.currentFile != null ? ' — ${p.currentFile}' : ''}',
            ),
      ),
    );
  }

  Future<void> _runLivePhotoRelink() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgressDialog(
        title: 'Prüfe auf Live-Photo-Paare …',
        stream: widget.library.relinkLivePhotos().map(
              (p) => p.total == 0
                  ? 'Keine unverknüpften Fotos gefunden.'
                  : '${p.done} / ${p.total}${p.currentFile != null ? ' — ${p.currentFile}' : ''}',
            ),
      ),
    );
  }

  Future<void> _runEmbeddingBackfill() async {
    if (!widget.library.clipAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Dafür wird zuerst das CLIP-Modell benötigt (Einstellungen → KI-Modelle).'),
      ));
      return;
    }
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgressDialog(
        title: 'Berechne CLIP-Embeddings …',
        stream: widget.library.backfillClipEmbeddings().map(
              (p) => p.total == 0
                  ? 'Alle Fotos haben bereits ein Embedding.'
                  : '${p.done} / ${p.total}${p.currentFile != null ? ' — ${p.currentFile}' : ''}',
            ),
      ),
    );
  }

  Future<void> _runAiTaggingBackfill() async {
    if (!widget.library.clipAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Dafür wird zuerst das CLIP-Modell benötigt (Einstellungen → KI-Modelle).'),
      ));
      return;
    }
    final onlyUntagged = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('KI-Tags berechnen'),
        content: const Text(
          'Nur ungetaggte Fotos: schnell, überspringt Fotos, die schon mindestens '
          'einen Tag haben (manuell oder automatisch).\n\n'
          'Alle Fotos: prüft die komplette Bibliothek neu und ergänzt zusätzlich '
          'passende KI-Tags bei bereits getaggten Fotos – vorhandene Tags bleiben '
          'dabei erhalten.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
          OutlinedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Nur ungetaggte'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Alle Fotos'),
          ),
        ],
      ),
    );
    if (onlyUntagged == null || !mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgressDialog(
        title: 'Berechne KI-Tags …',
        stream: widget.library.backfillAiTags(onlyUntagged: onlyUntagged).map(
              (p) => p.total == 0
                  ? 'Keine passenden Fotos gefunden.'
                  : '${p.done} / ${p.total}${p.currentFile != null ? ' — ${p.currentFile}' : ''}',
            ),
      ),
    );
  }

  Future<void> _runLocationBackfill() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgressDialog(
        title: 'Lese Orte aus Fotos ein …',
        stream: widget.library.backfillLocations().map(
              (p) => p.total == 0
                  ? 'Alle Fotos haben bereits einen Ort (oder keine EXIF-GPS-Daten).'
                  : '${p.done} / ${p.total}${p.currentFile != null ? ' — ${p.currentFile}' : ''}',
            ),
      ),
    );
  }

  Future<void> _runLocationNameBackfill() async {
    if (!widget.library.geoDataAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Dafür wird zuerst der GeoNames-Datensatz benötigt (Einstellungen → Standortdaten).'),
      ));
      return;
    }
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgressDialog(
        title: 'Löse Land/Bundesland/Stadt auf …',
        stream: widget.library.backfillLocationNames().map(
              (p) => p.total == 0
                  ? 'Alle Fotos mit bekanntem Ort sind bereits aufgelöst.'
                  : '${p.done} / ${p.total}${p.currentFile != null ? ' — ${p.currentFile}' : ''}',
            ),
      ),
    );
  }

  Future<void> _runCameraMetadataBackfill() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgressDialog(
        title: 'Lese Kameradaten aus Fotos ein …',
        stream: widget.library.backfillCameraMetadata().map(
              (p) => p.total == 0
                  ? 'Alle Fotos haben bereits Kameradaten (oder keine passenden EXIF-Daten).'
                  : '${p.done} / ${p.total}${p.currentFile != null ? ' — ${p.currentFile}' : ''}',
            ),
      ),
    );
  }

  Future<void> _runXmpSidecarExport() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgressDialog(
        title: 'Schreibe XMP-Sidecars …',
        stream: widget.library.writeXmpSidecars().map(
              (p) => p.total == 0
                  ? 'Keine Fotos gefunden (gesperrte Fotos werden übersprungen).'
                  : '${p.done} / ${p.total}${p.currentFile != null ? ' — ${p.currentFile}' : ''}',
            ),
      ),
    );
  }

  Future<void> _runOcrBackfill() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgressDialog(
        title: 'Erkenne Text in Fotos …',
        stream: widget.library.backfillOcrText().map(
              (p) => p.total == 0
                  ? 'Alle Fotos wurden bereits nach Text durchsucht.'
                  : '${p.done} / ${p.total}${p.currentFile != null ? ' — ${p.currentFile}' : ''}',
            ),
      ),
    );
  }

  Future<void> _runCaptionBackfill() async {
    if (!widget.library.captioningAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Dafür wird zuerst das Bildbeschreibungs-Modell benötigt (Einstellungen → KI-Modelle).'),
      ));
      return;
    }
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgressDialog(
        title: 'Erzeuge Bildbeschreibungen …',
        stream: widget.library.backfillCaptions().map(
              (p) => p.total == 0
                  ? 'Alle Fotos haben bereits eine KI-Beschreibung.'
                  : '${p.done} / ${p.total}${p.currentFile != null ? ' — ${p.currentFile}' : ''}',
            ),
      ),
    );
  }

  Future<void> _runBlurBackfill() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgressDialog(
        title: 'Berechne Unschärfe-Scores …',
        stream: widget.library.backfillBlurScores().map(
              (p) => p.total == 0
                  ? 'Für alle Fotos wurde bereits ein Unschärfe-Score berechnet.'
                  : '${p.done} / ${p.total}${p.currentFile != null ? ' — ${p.currentFile}' : ''}',
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Werkzeuge')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Statistik', style: Theme.of(context).textTheme.titleMedium),
          Card(
            child: ListTile(
              leading: const Icon(Icons.bar_chart_outlined),
              title: const Text('Analyseseite'),
              subtitle: const Text(
                'Anzahl Fotos/Videos, Speicherplatz, Aufnahmen pro Jahr/Monat, häufigste Kameras',
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => StatisticsScreen(library: widget.library)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Gesichtserkennung', style: Theme.of(context).textTheme.titleMedium),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.face_retouching_natural_outlined),
                  title: const Text('Gesichter scannen'),
                  subtitle: const Text('Manuell auslösen – neue oder alle Fotos'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _runFaceRescan,
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xs),
                  child: Row(
                    children: [
                      const Expanded(
                        flex: 2,
                        child: Text('Ähnlichkeitsschwelle für\n"Ähnliche mit auswählen"',
                            style: TextStyle(fontSize: 13)),
                      ),
                      Expanded(
                        flex: 3,
                        child: Slider(
                          value: _threshold,
                          min: 0.15,
                          max: 0.6,
                          divisions: 18,
                          label: _threshold.toStringAsFixed(2),
                          onChanged: (v) {
                            setState(() => _threshold = v);
                            widget.library.setFaceSimilarityThreshold(v);
                          },
                        ),
                      ),
                      SizedBox(width: 36, child: Text(_threshold.toStringAsFixed(2))),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
                  child: Text(
                    'Höhere Werte = strengerer Abgleich (weniger, aber sicherere '
                    'Treffer). Gilt für den Button "Ähnliche mit auswählen" im '
                    'Personen-Tab bei "Unbenannte Gesichter".',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Vorschaubilder', style: Theme.of(context).textTheme.titleMedium),
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
                      title: const Text('HEIC/HEIF & RAW-Unterstützung'),
                      subtitle: Text(supported
                          ? 'Aktiv – iPhone-Fotos (HEIC) und RAW-Dateien (DNG, CR2/CR3, NEF, '
                              'ARW, RAF, ORF, RW2 & Co.) werden über die native '
                              'macOS-Bildkonvertierung unterstützt.'
                          : 'Inaktiv – native Swift-Datei muss noch ins Xcode-Projekt '
                              'eingebunden werden (siehe README). JPG/PNG/WebP/GIF/BMP/TIFF '
                              'funktionieren auch ohne das.'),
                      isThreeLine: true,
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.image_outlined),
                  title: const Text('Vorschaubilder neu erstellen'),
                  subtitle: const Text('Für alle Fotos oder nur für noch fehlende'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _runThumbnailRegen,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Entwicklung', style: Theme.of(context).textTheme.titleMedium),
          Card(
            child: ListTile(
              leading: const Icon(Icons.exposure),
              title: const Text('Entwickelte Fotos neu rendern'),
              subtitle: const Text(
                'Rendert alle Fotos mit gespeicherten Entwicklungs-Anpassungen (Belichtung, '
                'Weißabgleich & Co.) mit unveränderten Einstellungen neu – z.B. sinnvoll nach '
                'einem Update der nativen Bildverarbeitung.',
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
              onTap: _runRedevelopAll,
            ),
          ),
          const SizedBox(height: 20),
          Text('Live Photos', style: Theme.of(context).textTheme.titleMedium),
          Card(
            child: ListTile(
              leading: const Icon(Icons.motion_photos_on_outlined),
              title: const Text('Live-Photo-Paare erneut prüfen'),
              subtitle: const Text(
                'Für Fotos/Videos, die vor dieser Funktion importiert wurden – '
                'verknüpft HEIC/JPG-Standbilder mit gleichnamigen MOV-Videos.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _runLivePhotoRelink,
            ),
          ),
          const SizedBox(height: 20),
          Text('Orte', style: Theme.of(context).textTheme.titleMedium),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: const Text('Orte aus Fotos einlesen'),
                  subtitle: const Text(
                    'Für Fotos, die vor Einführung der Kartenansicht importiert '
                    'wurden – liest EXIF-GPS-Daten nachträglich ein.',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _runLocationBackfill,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.map_outlined),
                  title: const Text('Land/Bundesland/Stadt auflösen'),
                  subtitle: const Text(
                    'Ordnet dem GPS-Ort eines Fotos Land, Bundesland/Provinz und Stadt '
                    'zu – komplett lokal/offline über den GeoNames-Datensatz (siehe '
                    'Einstellungen → Standortdaten). Für die Land-/Bundesland-/Stadt-'
                    'Filter in den Suchoptionen nötig.',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _runLocationNameBackfill,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Kamera', style: Theme.of(context).textTheme.titleMedium),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text('Kameradaten aus Fotos einlesen'),
                  subtitle: const Text(
                    'Für Fotos, die vor Einführung der Kamera-Anzeige importiert wurden – '
                    'liest Kamera, Objektiv, Brennweite, Blende, ISO und Belichtungszeit aus '
                    'den EXIF-Daten nachträglich ein.',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _runCameraMetadataBackfill,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.tune_outlined),
                  title: const Text('Kamera-Presets verwalten'),
                  subtitle: const Text(
                    'Fotos einer bestimmten Kamera automatisch beim Import einem Album/Tag '
                    'zuordnen oder favorisieren – analog zu Digikams "Kamera für den Import '
                    'voreinstellen".',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => CameraPresetsScreen(library: widget.library)),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.rule_outlined),
                  title: const Text('Automatisierungsregeln verwalten'),
                  subtitle: const Text(
                    'Fotos automatisch anhand von Ort, KI-Tag oder Aufnahmedatum einem '
                    'Album/Tag zuordnen oder favorisieren – wie Kamera-Presets, nur für '
                    'andere Bedingungen.',
                  ),
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
          Text('Fotoqualität', style: Theme.of(context).textTheme.titleMedium),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.text_fields_outlined),
                  title: const Text('Text in Fotos erkennen'),
                  subtitle: const Text(
                    'Für Fotos, die vor Einführung der Textsuche importiert wurden – erkennt '
                    'sichtbaren Text (z.B. Schilder, Dokumente) nachträglich, rein lokal über '
                    'Apples Vision-Framework.',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _runOcrBackfill,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.short_text_outlined),
                  title: const Text('Bildbeschreibungen erzeugen'),
                  subtitle: const Text(
                    'Für Fotos, die vor Installation des Bildbeschreibungs-Modells importiert '
                    'wurden – erzeugt eine kurze, englische Bildunterschrift pro Foto, rein lokal.',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _runCaptionBackfill,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.deblur_outlined),
                  title: const Text('Unschärfe neu berechnen'),
                  subtitle: const Text(
                    'Für Fotos, die vor Einführung der Unschärfe-Erkennung importiert wurden – '
                    'ermöglicht den Suchfilter "Nur unscharfe Fotos anzeigen".',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _runBlurBackfill,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('KI-Bildsuche', style: Theme.of(context).textTheme.titleMedium),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.play_circle_outline),
                  title: const Text('Alle Auswertungen jetzt nachholen'),
                  subtitle: const Text(
                    'Startet alle rechenintensiven Schritte nacheinander im '
                    'Hintergrund: Unschärfe, Gesichter, Texterkennung, Bildsuche, '
                    'Schlagwörter und Bildbeschreibung. Jeder Schritt überspringt, '
                    'was er schon hat – die App bleibt bedienbar.',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    widget.library.starteHintergrundanalyse();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Auswertung läuft im Hintergrund – '
                            'Fortschritt oben in der Leiste.'),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.travel_explore_outlined),
                  title: const Text('CLIP-Embeddings berechnen'),
                  subtitle: const Text(
                    'Für Fotos, die vor Installation des CLIP-Modells importiert '
                    'wurden – ohne Embedding tauchen sie in der KI-Bildsuche und '
                    'der Duplikatsuche nicht auf.',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _runEmbeddingBackfill,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.sell_outlined),
                  title: const Text('KI-Tags berechnen'),
                  subtitle: const Text(
                    'Ordnet Fotos automatisch passende Tags aus einer festen Begriffsliste '
                    'zu (z.B. "Kind", "Draußen", "Geburtstag") – auf Basis des CLIP-Modells, '
                    'ohne zusätzlichen Download. Tags lassen sich in der Info-Ansicht eines '
                    'Fotos jederzeit anpassen.',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _runAiTaggingBackfill,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Bibliothek', style: Theme.of(context).textTheme.titleMedium),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.rate_review_outlined),
                  title: const Text('Unbewertete Fotos sichten'),
                  subtitle: const Text(
                    'Öffnet alle noch unbewerteten Fotos/Videos im Vollbild-Sichtungs-Modus, '
                    'zum schnellen Durchgehen und Bewerten.',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _openCulling,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.compare_outlined),
                  title: const Text('Duplikate & ähnliche Fotos suchen'),
                  subtitle: const Text('Auf Basis der CLIP-Bild-Embeddings'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => DuplicatesScreen(library: widget.library)),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.filter_none_outlined),
                  title: const Text('Serienbilder gruppieren'),
                  subtitle: const Text(
                    'Findet zeitlich nahe, ähnliche Fotos (z.B. Serienbilder) und fasst sie auf '
                    'Wunsch zu einem Stapel mit einem Titelbild zusammen.',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => StackReviewScreen(library: widget.library)),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.fact_check_outlined),
                  title: const Text('Bibliotheks-Integritätsprüfung'),
                  subtitle: const Text(
                    'Gleicht die Datenbank gegen die tatsächlichen Dateien auf der Platte ab: '
                    'fehlende Dateien, verwaiste Dateien, optional Prüfsummen-Abweichungen.',
                  ),
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
          Text('Interoperabilität', style: Theme.of(context).textTheme.titleMedium),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('XMP-Sidecars schreiben'),
                  subtitle: const Text(
                    'Legt für jedes Foto eine .xmp-Datei mit Bewertung, Farbmarkierung, '
                    'Beschreibung, Tags und Kamera-Daten daneben ab – für Lightroom, darktable '
                    'oder digiKam. Gesperrte Fotos werden übersprungen. Passiert automatisch auch '
                    'beim Exportieren und bei unverschlüsselten Backups.',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _runXmpSidecarExport,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.file_open_outlined),
                  title: const Text('XMP-Sidecars einlesen'),
                  subtitle: const Text(
                    'Liest vorhandene .xmp-Dateien (z.B. extern in Lightroom/darktable/digiKam '
                    'bearbeitet) und zeigt Abweichungen zur Datenbank – Bewertung, '
                    'Farbmarkierung, Beschreibung, Tags, Standort.',
                  ),
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
