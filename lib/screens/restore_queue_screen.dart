import 'package:flutter/material.dart';

import '../db/database.dart';
import '../state/library_state.dart';
import '../theme/app_spacing.dart';
import '../widgets/empty_state.dart';
import 'asset_viewer_screen.dart';

/// Übersicht aller KI-Restaurierungs-Aufträge (siehe RestoreQueueService,
/// RestoreJobs) – erreichbar über den Warteschlangen-Indikator in
/// [HomeShell]. Ein Auftrag läuft oft mehrere Minuten; diese Liste zeigt
/// den Fortschritt live (über [AppDatabase.watchRestoreJobs]) und erlaubt
/// Abbrechen (wartend/laufend), Öffnen (fertig) und Entfernen aus der Liste
/// (fertig/fehlgeschlagen/abgebrochen – betrifft nur den Warteschlangen-
/// Eintrag, nicht das Foto selbst).
class RestoreQueueScreen extends StatelessWidget {
  final LibraryState library;
  const RestoreQueueScreen({super.key, required this.library});

  Future<void> _openAsset(BuildContext context, String assetId) async {
    final asset = await library.db.assetById(assetId);
    if (asset == null || !context.mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AssetViewerScreen(
        assets: [asset],
        initialIndex: 0,
        paths: library.paths,
        db: library.db,
        library: library,
      ),
    ));
  }

  String _statusLabel(RestoreJobData job) => switch (job.status) {
        'queued' => 'Wartet in der Warteschlange',
        'running' => job.tilesTotal > 0 ? 'Läuft – Kachel ${job.tilesDone} von ${job.tilesTotal}' : 'Wird gestartet …',
        'done' => 'Fertig',
        'cancelled' => 'Abgebrochen',
        'failed' => job.errorMessage != null ? 'Fehlgeschlagen: ${job.errorMessage}' : 'Fehlgeschlagen',
        _ => job.status,
      };

  IconData _statusIcon(String status) => switch (status) {
        'queued' => Icons.schedule_outlined,
        'running' => Icons.auto_awesome_outlined,
        'done' => Icons.check_circle_outline,
        'cancelled' => Icons.cancel_outlined,
        'failed' => Icons.error_outline,
        _ => Icons.help_outline,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KI-Restaurierung – Warteschlange')),
      body: StreamBuilder<List<RestoreJobData>>(
        stream: library.db.watchRestoreJobs(),
        builder: (context, snapshot) {
          final jobs = snapshot.data ?? [];
          if (jobs.isEmpty) {
            return const EmptyState(
              icon: Icons.auto_awesome_outlined,
              message: 'Keine Restaurierungs-Aufträge vorhanden.\n'
                  'Im Entwickeln-Screen eines Fotos lässt sich eine KI-Restaurierung anstoßen.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: jobs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final job = jobs[index];
              final isActive = job.status == 'queued' || job.status == 'running';
              return FutureBuilder<AssetData?>(
                future: library.db.assetById(job.assetId),
                builder: (context, assetSnapshot) {
                  final asset = assetSnapshot.data;
                  return ListTile(
                    leading: Icon(_statusIcon(job.status)),
                    title: Text(asset?.originalFileName ?? job.assetId),
                    subtitle: Text(_statusLabel(job)),
                    onTap: job.status == 'done' ? () => _openAsset(context, job.assetId) : null,
                    trailing: isActive
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            tooltip: 'Abbrechen',
                            onPressed: () => library.restoreQueue.cancel(job.id),
                          )
                        : IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: 'Aus der Liste entfernen',
                            onPressed: () => library.db.deleteRestoreJob(job.id),
                          ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
