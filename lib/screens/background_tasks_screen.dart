import 'package:flutter/material.dart';

import '../state/library_state.dart';
import '../theme/app_spacing.dart';
import '../widgets/progress_dialog.dart';

/// Eine Aktion innerhalb einer [_TaskCard] – öffnet [ProgressDialog] gegen
/// einen der `Stream<ImportProgress>`-Backfills auf [LibraryState].
class _TaskAction {
  final String label;
  final IconData icon;
  final String dialogTitle;
  final String emptyMessage;
  final Stream<ImportProgress> Function() stream;
  const _TaskAction({
    required this.label,
    required this.icon,
    required this.dialogTitle,
    required this.emptyMessage,
    required this.stream,
  });
}

/// Einheitlicher Hinweistext für ein fehlendes KI-Modell/Datenset – dieselbe
/// Formulierung wie in ToolsScreen (Werkzeuge), damit beide Einstiegspunkte
/// nicht auseinanderdriften.
String? _modelHint(bool available, String model, String where) =>
    available ? null : 'Dafür wird zuerst $model benötigt ($where).';

Future<void> _showProgress(BuildContext context, _TaskAction action) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => ProgressDialog(
      title: action.dialogTitle,
      stream: action.stream().map(
            (p) => p.total == 0
                ? action.emptyMessage
                : '${p.done} / ${p.total}${p.currentFile != null ? ' — ${p.currentFile}' : ''}',
          ),
    ),
  );
}

/// Kompakte Status-Zeile im Immich-"Auftrags-Schlangen"-Stil (Label links,
/// Wert rechts, farbig hinterlegt).
class _StatusRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _StatusRow({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

/// Eine Aufgaben-Karte: Titel, Beschreibung, Wartend-Zähler (aus [pendingCount],
/// einer bereits vorhandenen DB-Zählmethode) und ein bis zwei Aktions-Knöpfe.
/// [unavailableReason] gesetzt: Knöpfe deaktiviert, Grund wird stattdessen
/// angezeigt (fehlendes KI-Modell o.ä.) – dieselben Verfügbarkeits-Getter wie
/// in ToolsScreen.
class _TaskCard extends StatefulWidget {
  final String title;
  final String description;
  final Future<int> Function() pendingCount;
  final String pendingLabel;
  final String? unavailableReason;
  final List<_TaskAction> actions;
  const _TaskCard({
    required this.title,
    required this.description,
    required this.pendingCount,
    this.pendingLabel = 'Wartend',
    this.unavailableReason,
    required this.actions,
  });

  @override
  State<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<_TaskCard> {
  // Nur berechnen, wenn die Karte den Zähler überhaupt anzeigt – bei
  // fehlendem Modell (unavailableReason gesetzt) würde die Abfrage sonst
  // unnötig eine volle Tabellen-Zählung auslösen, ohne dass das Ergebnis je
  // sichtbar wird.
  late Future<int>? _countFuture = widget.unavailableReason == null ? widget.pendingCount() : null;

  void _refreshCount() {
    if (widget.unavailableReason != null) return;
    setState(() => _countFuture = widget.pendingCount());
  }

  Future<void> _runAction(_TaskAction action) async {
    await _showProgress(context, action);
    if (mounted) _refreshCount();
  }

  @override
  Widget build(BuildContext context) {
    final reason = widget.unavailableReason;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 4),
            Text(widget.description,
                style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.outline)),
            const SizedBox(height: 12),
            if (reason != null)
              Text(reason, style: const TextStyle(fontSize: 12, color: Colors.orange))
            else ...[
              FutureBuilder<int>(
                future: _countFuture,
                builder: (context, snapshot) => _StatusRow(
                  label: widget.pendingLabel,
                  value: snapshot.hasData ? '${snapshot.data}' : '…',
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final action in widget.actions)
                    OutlinedButton.icon(
                      onPressed: () => _runAction(action),
                      icon: Icon(action.icon, size: 18),
                      label: Text(action.label),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Sonderkarte für [LibraryState.starteHintergrundanalyse]: läuft (anders als
/// die übrigen Aufgaben hier) bereits echt im Hintergrund weiter, während man
/// navigiert – deshalb ein echtes "Status"-Badge statt eines Wartend-Zählers,
/// gespeist aus [LibraryState.analyse]/[LibraryState.analyseLaeuft] über
/// ListenableBuilder (LibraryState ist ein ChangeNotifier).
class _CombinedAnalysisCard extends StatelessWidget {
  final LibraryState library;
  const _CombinedAnalysisCard({required this.library});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: library,
      builder: (context, _) {
        final analyse = library.analyse;
        final laeuft = library.analyseLaeuft;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Alle Auswertungen jetzt nachholen',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Theme.of(context).colorScheme.primary)),
                const SizedBox(height: 4),
                Text(
                  'Startet alle rechenintensiven Schritte nacheinander im Hintergrund: '
                  'Unschärfe, Gesichter, Texterkennung, Bildsuche, Schlagwörter und '
                  'Bildbeschreibung. Jeder Schritt überspringt, was er schon hat – die '
                  'App bleibt bedienbar.',
                  style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.outline),
                ),
                const SizedBox(height: 12),
                _StatusRow(
                  label: 'Status',
                  value: laeuft && analyse != null
                      ? '${analyse.stufe} (${analyse.erledigt}/${analyse.gesamt}) – '
                          'Stufe ${analyse.stufeNummer}/${analyse.stufenGesamt}'
                      : 'Bereit',
                  color: laeuft ? Theme.of(context).colorScheme.primaryContainer : null,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: laeuft
                      ? null
                      : () {
                          library.starteHintergrundanalyse();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Auswertung läuft im Hintergrund.')),
                          );
                        },
                  icon: const Icon(Icons.play_circle_outline, size: 18),
                  label: const Text('Jetzt starten'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Übersicht aller Hintergrund-/Backfill-Aufgaben im Stil von Immichs
/// Admin-Seite "Auftrags-Schlangen": pro Aufgabe eine Karte mit Kurzbe-
/// schreibung, Anzahl noch offener Fotos und Start-Knöpfen. Rein additiv zu
/// ToolsScreen (Werkzeuge) gedacht – ruft exakt dieselben LibraryState-Streams
/// auf, ersetzt Werkzeuge aber nicht (viele Stellen in der App verweisen
/// wörtlich dorthin).
class BackgroundTasksScreen extends StatelessWidget {
  final LibraryState library;
  const BackgroundTasksScreen({super.key, required this.library});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hintergrundaufgaben')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _CombinedAnalysisCard(library: library),
          const SizedBox(height: AppSpacing.md),
          _TaskCard(
            title: 'Gesichter scannen',
            description: 'Erkennt und ordnet Gesichter zu, sofern das YuNet-Modell installiert ist.',
            pendingCount: () => library.db.countFaceScan(onlyNew: true),
            unavailableReason:
                _modelHint(library.faceDetectionAvailable, 'das YuNet-Modell', 'Einstellungen → KI-Modelle'),
            actions: [
              _TaskAction(
                label: 'Neue Fotos',
                icon: Icons.search,
                dialogTitle: 'Scanne neue Fotos …',
                emptyMessage: 'Keine passenden Fotos gefunden.',
                stream: () => library.rescanFaces(onlyNewPhotos: true),
              ),
              _TaskAction(
                label: 'Alle erneut',
                icon: Icons.all_inclusive,
                dialogTitle: 'Scanne alle Fotos erneut …',
                emptyMessage: 'Keine passenden Fotos gefunden.',
                stream: () => library.rescanFaces(onlyNewPhotos: false),
              ),
            ],
          ),
          _TaskCard(
            title: 'Vorschaubilder',
            description: 'Erzeugt Thumbnails/Vorschauen für Fotos und Videos.',
            pendingCount: () => library.db.countThumbnailRegen(onlyMissing: true),
            actions: [
              _TaskAction(
                label: 'Fehlende',
                icon: Icons.search,
                dialogTitle: 'Erstelle fehlende Vorschaubilder …',
                emptyMessage: 'Keine passenden Fotos gefunden.',
                stream: () => library.regenerateThumbnails(onlyMissing: true),
              ),
              _TaskAction(
                label: 'Alle neu',
                icon: Icons.all_inclusive,
                dialogTitle: 'Erstelle alle Vorschaubilder neu …',
                emptyMessage: 'Keine passenden Fotos gefunden.',
                stream: () => library.regenerateThumbnails(onlyMissing: false),
              ),
            ],
          ),
          _TaskCard(
            title: 'Text erkennen (OCR)',
            description: 'Erkennt sichtbaren Text in Fotos, rein lokal über Apples Vision-Framework.',
            pendingCount: () => library.db.countOcrBackfill(),
            actions: [
              _TaskAction(
                label: 'Starten',
                icon: Icons.play_arrow,
                dialogTitle: 'Erkenne Text in Fotos …',
                emptyMessage: 'Alle Fotos wurden bereits nach Text durchsucht.',
                stream: () => library.backfillOcrText(),
              ),
            ],
          ),
          _TaskCard(
            title: 'Bildbeschreibungen',
            description: 'Erzeugt eine kurze, englische KI-Bildunterschrift pro Foto.',
            pendingCount: () => library.db.countCaptionBackfill(),
            unavailableReason: _modelHint(
                library.captioningAvailable, 'das Bildbeschreibungs-Modell', 'Einstellungen → KI-Modelle'),
            actions: [
              _TaskAction(
                label: 'Starten',
                icon: Icons.play_arrow,
                dialogTitle: 'Erzeuge Bildbeschreibungen …',
                emptyMessage: 'Alle Fotos haben bereits eine KI-Beschreibung.',
                stream: () => library.backfillCaptions(),
              ),
            ],
          ),
          _TaskCard(
            title: 'CLIP-Embeddings',
            description: 'Grundlage für KI-Bildsuche und Duplikatsuche.',
            pendingCount: () => library.db.countEmbeddingBackfill(),
            unavailableReason: _modelHint(library.clipAvailable, 'das CLIP-Modell', 'Einstellungen → KI-Modelle'),
            actions: [
              _TaskAction(
                label: 'Starten',
                icon: Icons.play_arrow,
                dialogTitle: 'Berechne CLIP-Embeddings …',
                emptyMessage: 'Alle Fotos haben bereits ein Embedding.',
                stream: () => library.backfillClipEmbeddings(),
              ),
            ],
          ),
          _TaskCard(
            title: 'KI-Tags',
            description: 'Ordnet Fotos automatisch passende Tags aus dem Vokabular zu (auf CLIP-Basis).',
            pendingCount: () => library.db.countAiTagging(onlyUntagged: true),
            unavailableReason: _modelHint(library.clipAvailable, 'das CLIP-Modell', 'Einstellungen → KI-Modelle'),
            actions: [
              _TaskAction(
                label: 'Ungetaggte',
                icon: Icons.search,
                dialogTitle: 'Berechne KI-Tags …',
                emptyMessage: 'Keine passenden Fotos gefunden.',
                stream: () => library.backfillAiTags(onlyUntagged: true),
              ),
              _TaskAction(
                label: 'Alle Fotos',
                icon: Icons.all_inclusive,
                dialogTitle: 'Berechne KI-Tags …',
                emptyMessage: 'Keine passenden Fotos gefunden.',
                stream: () => library.backfillAiTags(onlyUntagged: false),
              ),
            ],
          ),
          _TaskCard(
            title: 'Unschärfe',
            description: 'Ermöglicht den Suchfilter "Nur unscharfe Fotos anzeigen".',
            pendingCount: () => library.db.countBlurBackfill(),
            actions: [
              _TaskAction(
                label: 'Starten',
                icon: Icons.play_arrow,
                dialogTitle: 'Berechne Unschärfe-Scores …',
                emptyMessage: 'Für alle Fotos wurde bereits ein Unschärfe-Score berechnet.',
                stream: () => library.backfillBlurScores(),
              ),
            ],
          ),
          _TaskCard(
            title: 'Orte einlesen',
            description: 'Liest EXIF-GPS-Daten aus Fotos nachträglich ein.',
            pendingCount: () => library.db.countLocationBackfill(),
            actions: [
              _TaskAction(
                label: 'Starten',
                icon: Icons.play_arrow,
                dialogTitle: 'Lese Orte aus Fotos ein …',
                emptyMessage: 'Alle Fotos haben bereits einen Ort (oder keine EXIF-GPS-Daten).',
                stream: () => library.backfillLocations(),
              ),
            ],
          ),
          _TaskCard(
            title: 'Land/Bundesland/Stadt auflösen',
            description: 'Ordnet dem GPS-Ort eines Fotos Land, Bundesland/Provinz und Stadt zu.',
            pendingCount: () => library.db.countLocationNameBackfill(),
            unavailableReason:
                _modelHint(library.geoDataAvailable, 'der GeoNames-Datensatz', 'Einstellungen → Standortdaten'),
            actions: [
              _TaskAction(
                label: 'Starten',
                icon: Icons.play_arrow,
                dialogTitle: 'Löse Land/Bundesland/Stadt auf …',
                emptyMessage: 'Alle Fotos mit bekanntem Ort sind bereits aufgelöst.',
                stream: () => library.backfillLocationNames(),
              ),
            ],
          ),
          _TaskCard(
            title: 'Kameradaten einlesen',
            description: 'Liest Kamera, Objektiv, Brennweite, Blende, ISO und Belichtungszeit aus EXIF ein.',
            pendingCount: () => library.db.countCameraMetadataBackfill(),
            actions: [
              _TaskAction(
                label: 'Starten',
                icon: Icons.play_arrow,
                dialogTitle: 'Lese Kameradaten aus Fotos ein …',
                emptyMessage: 'Alle Fotos haben bereits Kameradaten (oder keine passenden EXIF-Daten).',
                stream: () => library.backfillCameraMetadata(),
              ),
            ],
          ),
          _TaskCard(
            title: 'Live-Photo-Paare prüfen',
            description: 'Verknüpft HEIC/JPG-Standbilder mit gleichnamigen MOV-Videos.',
            pendingCount: () => library.db.countUnlinkedAssetsOfType('IMAGE'),
            actions: [
              _TaskAction(
                label: 'Starten',
                icon: Icons.play_arrow,
                dialogTitle: 'Prüfe auf Live-Photo-Paare …',
                emptyMessage: 'Keine unverknüpften Fotos gefunden.',
                stream: () => library.relinkLivePhotos(),
              ),
            ],
          ),
          _TaskCard(
            title: 'Entwickelte Fotos neu rendern',
            description: 'Rendert Fotos mit gespeicherten Entwicklungs-Anpassungen unverändert neu.',
            pendingLabel: 'Betrifft',
            pendingCount: () => library.db.countAssetsWithDevelopSettings(),
            actions: [
              _TaskAction(
                label: 'Starten',
                icon: Icons.play_arrow,
                dialogTitle: 'Rendere entwickelte Fotos neu …',
                emptyMessage: 'Keine entwickelten Fotos gefunden.',
                stream: () => library.redevelopAll(),
              ),
            ],
          ),
          _TaskCard(
            title: 'XMP-Sidecars schreiben',
            description: 'Legt für jedes Foto eine .xmp-Datei für Lightroom/darktable/digiKam daneben ab.',
            pendingLabel: 'Betrifft',
            pendingCount: () => library.db.countXmpExport(),
            actions: [
              _TaskAction(
                label: 'Starten',
                icon: Icons.play_arrow,
                dialogTitle: 'Schreibe XMP-Sidecars …',
                emptyMessage: 'Keine Fotos gefunden (gesperrte Fotos werden übersprungen).',
                stream: () => library.writeXmpSidecars(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
