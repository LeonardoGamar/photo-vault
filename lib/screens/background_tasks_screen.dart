import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../state/library_state.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
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
String? _modelHint(AppTexte t, bool available, String model, String where) =>
    available ? null : t.aufgModellNoetig(model, where);

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

  /// null heisst „Wartend" – der übersetzte Vorgabewert kann nicht im Kopf
  /// stehen, dort gibt es noch keinen Kontext.
  final String? pendingLabel;
  final String? unavailableReason;
  final List<_TaskAction> actions;
  const _TaskCard({
    required this.title,
    required this.description,
    required this.pendingCount,
    this.pendingLabel,
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
              Text(reason,
                  style: TextStyle(fontSize: 12, color: context.semantik.warnung))
            else ...[
              FutureBuilder<int>(
                future: _countFuture,
                builder: (context, snapshot) => _StatusRow(
                  label: widget.pendingLabel ?? AppTexte.of(context).aufgWartend,
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
        final t = AppTexte.of(context);
        final analyse = library.analyse;
        final laeuft = library.analyseLaeuft;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.werkzAllesNachholenTitel,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Theme.of(context).colorScheme.primary)),
                const SizedBox(height: 4),
                Text(
                  t.werkzAllesNachholenText,
                  style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.outline),
                ),
                const SizedBox(height: 12),
                _StatusRow(
                  label: t.aufgStatus,
                  value: laeuft && analyse != null
                      ? t.aufgStufe(analysestufeName(t, analyse.stufe), analyse.erledigt, analyse.gesamt,
                          analyse.stufeNummer, analyse.stufenGesamt)
                      : t.aufgBereit,
                  color: laeuft ? Theme.of(context).colorScheme.primaryContainer : null,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: laeuft
                      ? null
                      : () {
                          library.starteHintergrundanalyse();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(t.aufgLaeuft)),
                          );
                        },
                  icon: const Icon(Icons.play_circle_outline, size: 18),
                  label: Text(t.aufgJetztStarten),
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
    final t = AppTexte.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.einstAbschnittHintergrund)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _CombinedAnalysisCard(library: library),
          const SizedBox(height: AppSpacing.md),
          _TaskCard(
            title: t.werkzGesichterScannenTitel,
            description: t.aufgGesichterText,
            pendingCount: () => library.db.countFaceScan(onlyNew: true),
            unavailableReason: _modelHint(
                t, library.faceDetectionAvailable, t.aufgYunetModell, t.aufgWoModelle),
            actions: [
              _TaskAction(
                label: t.aufgNeueFotos,
                icon: Icons.search,
                dialogTitle: t.werkzScanneNeue,
                emptyMessage: t.werkzKeinePassenden,
                stream: () => library.rescanFaces(onlyNewPhotos: true),
              ),
              _TaskAction(
                label: t.aufgAlleErneut,
                icon: Icons.all_inclusive,
                dialogTitle: t.werkzScanneAlle,
                emptyMessage: t.werkzKeinePassenden,
                stream: () => library.rescanFaces(onlyNewPhotos: false),
              ),
            ],
          ),
          _TaskCard(
            title: t.werkzAbschnittVorschau,
            description: t.aufgVorschauText,
            pendingCount: () => library.db.countThumbnailRegen(onlyMissing: true),
            actions: [
              _TaskAction(
                label: t.aufgFehlende,
                icon: Icons.search,
                dialogTitle: t.werkzErstelleFehlende,
                emptyMessage: t.werkzKeinePassenden,
                stream: () => library.regenerateThumbnails(onlyMissing: true),
              ),
              _TaskAction(
                label: t.aufgAlleNeu,
                icon: Icons.all_inclusive,
                dialogTitle: t.werkzErstelleAlle,
                emptyMessage: t.werkzKeinePassenden,
                stream: () => library.regenerateThumbnails(onlyMissing: false),
              ),
            ],
          ),
          _TaskCard(
            title: t.aufgOcrTitel,
            description: t.aufgOcrText,
            pendingCount: () => library.db.countOcrBackfill(),
            actions: [
              _TaskAction(
                label: t.aufgStarten,
                icon: Icons.play_arrow,
                dialogTitle: t.werkzErkenneText,
                emptyMessage: t.werkzAlleTextDurchsucht,
                stream: () => library.backfillOcrText(),
              ),
            ],
          ),
          _TaskCard(
            title: t.aufgBeschreibungenTitel,
            description: t.aufgBeschreibungenText,
            pendingCount: () => library.db.countCaptionBackfill(),
            unavailableReason: _modelHint(
                t, library.captioningAvailable, t.aufgBeschreibungsmodell, t.aufgWoModelle),
            actions: [
              _TaskAction(
                label: t.aufgStarten,
                icon: Icons.play_arrow,
                dialogTitle: t.werkzErzeugeBeschreibungen,
                emptyMessage: t.werkzAlleHabenBeschreibung,
                stream: () => library.backfillCaptions(),
              ),
            ],
          ),
          _TaskCard(
            title: t.aufgEmbeddingsTitel,
            description: t.aufgEmbeddingsText,
            pendingCount: () => library.db.countEmbeddingBackfill(),
            unavailableReason:
                _modelHint(t, library.clipAvailable, t.aufgClipModell, t.aufgWoModelle),
            actions: [
              _TaskAction(
                label: t.aufgStarten,
                icon: Icons.play_arrow,
                dialogTitle: t.werkzBerechneEmbeddings,
                emptyMessage: t.werkzAlleHabenEmbedding,
                stream: () => library.backfillClipEmbeddings(),
              ),
            ],
          ),
          _TaskCard(
            title: t.aufgKiTagsTitel,
            description: t.aufgKiTagsText,
            pendingCount: () => library.db.countAiTagging(onlyUntagged: true),
            unavailableReason:
                _modelHint(t, library.clipAvailable, t.aufgClipModell, t.aufgWoModelle),
            actions: [
              _TaskAction(
                label: t.aufgUngetaggte,
                icon: Icons.search,
                dialogTitle: t.werkzBerechneKiTags,
                emptyMessage: t.werkzKeinePassenden,
                stream: () => library.backfillAiTags(onlyUntagged: true),
              ),
              _TaskAction(
                label: t.werkzAlleFotos,
                icon: Icons.all_inclusive,
                dialogTitle: t.werkzBerechneKiTags,
                emptyMessage: t.werkzKeinePassenden,
                stream: () => library.backfillAiTags(onlyUntagged: false),
              ),
            ],
          ),
          _TaskCard(
            title: t.aufgUnschaerfeTitel,
            description: t.aufgUnschaerfeText,
            pendingCount: () => library.db.countBlurBackfill(),
            actions: [
              _TaskAction(
                label: t.aufgStarten,
                icon: Icons.play_arrow,
                dialogTitle: t.werkzBerechneUnschaerfe,
                emptyMessage: t.werkzAlleHabenUnschaerfe,
                stream: () => library.backfillBlurScores(),
              ),
            ],
          ),
          _TaskCard(
            title: t.aufgOrteTitel,
            description: t.aufgOrteText,
            pendingCount: () => library.db.countLocationBackfill(),
            actions: [
              _TaskAction(
                label: t.aufgStarten,
                icon: Icons.play_arrow,
                dialogTitle: t.werkzLeseOrte,
                emptyMessage: t.werkzAlleHabenOrt,
                stream: () => library.backfillLocations(),
              ),
            ],
          ),
          _TaskCard(
            title: t.werkzOrteAufloesenTitel,
            description: t.aufgOrteAufloesenText,
            pendingCount: () => library.db.countLocationNameBackfill(),
            unavailableReason: _modelHint(
                t, library.geoDataAvailable, t.aufgGeoDatensatz, t.aufgWoStandortdaten),
            actions: [
              _TaskAction(
                label: t.aufgStarten,
                icon: Icons.play_arrow,
                dialogTitle: t.werkzLoeseOrteAuf,
                emptyMessage: t.werkzAlleAufgeloest,
                stream: () => library.backfillLocationNames(),
              ),
            ],
          ),
          _TaskCard(
            title: t.aufgKameraTitel,
            description: t.aufgKameraText,
            pendingCount: () => library.db.countCameraMetadataBackfill(),
            actions: [
              _TaskAction(
                label: t.aufgStarten,
                icon: Icons.play_arrow,
                dialogTitle: t.werkzLeseKameradaten,
                emptyMessage: t.werkzAlleHabenKameradaten,
                stream: () => library.backfillCameraMetadata(),
              ),
            ],
          ),
          _TaskCard(
            title: t.aufgLivePhotoTitel,
            description: t.aufgLivePhotoText,
            pendingCount: () => library.db.countUnlinkedAssetsOfType('IMAGE'),
            actions: [
              _TaskAction(
                label: t.aufgStarten,
                icon: Icons.play_arrow,
                dialogTitle: t.werkzPruefeLivePhotos,
                emptyMessage: t.werkzKeineUnverknuepften,
                stream: () => library.relinkLivePhotos(),
              ),
            ],
          ),
          _TaskCard(
            title: t.werkzNeuRendernTitel,
            description: t.aufgRendernText,
            pendingLabel: t.aufgBetrifft,
            pendingCount: () => library.db.countAssetsWithDevelopSettings(),
            actions: [
              _TaskAction(
                label: t.aufgStarten,
                icon: Icons.play_arrow,
                dialogTitle: t.werkzRendereNeu,
                emptyMessage: t.werkzKeineEntwickelten,
                stream: () => library.redevelopAll(),
              ),
            ],
          ),
          _TaskCard(
            title: t.werkzXmpSchreibenTitel,
            description: t.aufgXmpText,
            pendingLabel: t.aufgBetrifft,
            pendingCount: () => library.db.countXmpExport(),
            actions: [
              _TaskAction(
                label: t.aufgStarten,
                icon: Icons.play_arrow,
                dialogTitle: t.werkzSchreibeXmp,
                emptyMessage: t.werkzKeineFotosGesperrt,
                stream: () => library.writeXmpSidecars(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
