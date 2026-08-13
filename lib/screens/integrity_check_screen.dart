import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/integrity_check_service.dart';
import '../state/library_state.dart';
import '../theme/app_spacing.dart';
import '../widgets/selection_action_bar.dart' show confirmDialog;
import 'asset_viewer_screen.dart';

/// Gleicht DB-Zeilen gegen tatsächliche Dateien auf der Platte ab: fehlende
/// Dateien, verwaiste Dateien ohne DB-Zeile, und (optional) Prüfsummen-
/// Abweichungen. Läuft die eigentliche Prüfung in einem eigenen Isolate
/// (siehe [runIntegrityCheck]), damit das Auflisten großer Verzeichnisse die
/// UI nicht blockiert – Muster: DuplicatesScreen.
class IntegrityCheckScreen extends StatefulWidget {
  final LibraryState library;
  const IntegrityCheckScreen({super.key, required this.library});

  @override
  State<IntegrityCheckScreen> createState() => _IntegrityCheckScreenState();
}

class _IntegrityCheckScreenState extends State<IntegrityCheckScreen> {
  bool _loading = true;
  bool _verifyChecksums = false;
  String? _error;
  IntegrityCheckReport? _report;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final assets = await widget.library.db.allAssetsForIntegrityCheck();
      final faces = await widget.library.db.allFaces();
      final masks = await widget.library.db.allDevelopMasks();

      final params = IntegrityCheckParams(
        libraryRootPath: widget.library.paths.root.path,
        assets: [
          for (final a in assets)
            AssetPathSnapshot(
              assetId: a.id,
              relativePath: a.relativePath,
              thumbnailRelativePath: a.thumbnailRelativePath,
              previewRelativePath: a.previewRelativePath,
              developedRelativePath: a.developedRelativePath,
              restoredRelativePath: a.restoredRelativePath,
              trimmedRelativePath: a.trimmedRelativePath,
              checksum: a.checksum,
              isLocked: a.isLocked,
            ),
        ],
        faceCrops: [
          for (final f in faces)
            if (f.cropRelativePath != null)
              FaceCropSnapshot(faceId: f.id, relativePath: f.cropRelativePath!),
        ],
        masks: [
          for (final m in masks) MaskSnapshot(maskId: m.id, relativePath: m.maskRelativePath),
        ],
        verifyChecksums: _verifyChecksums,
      );

      final report = await compute(runIntegrityCheck, params);
      setState(() {
        _report = report;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = 'Prüfung fehlgeschlagen: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _removeMissingFromDb(MissingFileIssue issue) async {
    final confirmed = await confirmDialog(
      context,
      'Aus Datenbank entfernen?',
      switch (issue.kind) {
        MissingFileKind.original =>
          'Das Original fehlt auf der Platte – das gesamte Foto/Video wird aus der Bibliothek entfernt.',
        MissingFileKind.mask => 'Die Maskendatei fehlt – der Maskeneintrag wird entfernt.',
        MissingFileKind.faceCrop =>
          'Der Gesichts-Crop fehlt – nur die Vorschau wird entfernt, die Zuordnung zur Person bleibt erhalten.',
        _ => 'Der Datei-Pfad wird aus der Datenbank entfernt – die Datei lässt sich über '
            '"Werkzeuge → Vorschaubilder neu erstellen" wieder herstellen.',
      },
    );
    if (!confirmed) return;

    switch (issue.kind) {
      case MissingFileKind.original:
        await widget.library.db.deleteAssetRows([issue.ownerId]);
      case MissingFileKind.thumbnail:
        await widget.library.db.clearMissingThumbnailPath(issue.ownerId);
      case MissingFileKind.preview:
        await widget.library.db.clearMissingPreviewPath(issue.ownerId);
      case MissingFileKind.developed:
        await widget.library.db.clearMissingDevelopedPath(issue.ownerId);
      case MissingFileKind.restored:
        await widget.library.db.clearMissingRestoredPath(issue.ownerId);
      case MissingFileKind.trimmed:
        await widget.library.db.clearMissingTrimmedPath(issue.ownerId);
      case MissingFileKind.faceCrop:
        await widget.library.db.clearMissingFaceCropPath(issue.ownerId);
      case MissingFileKind.mask:
        await widget.library.db.deleteDevelopMask(int.parse(issue.ownerId));
    }
    if (!mounted) return;
    setState(() => _report = _withoutMissing(_report!, issue));
  }

  Future<void> _deleteOrphanedFile(OrphanedFileIssue issue) async {
    final confirmed = await confirmDialog(
      context,
      'Datei löschen?',
      '${issue.relativePath} wird unwiderruflich von der Platte gelöscht.',
    );
    if (!confirmed) return;
    await widget.library.paths.deletePermanently(issue.relativePath);
    if (!mounted) return;
    setState(() => _report = _withoutOrphan(_report!, issue));
  }

  IntegrityCheckReport _withoutMissing(IntegrityCheckReport report, MissingFileIssue issue) =>
      IntegrityCheckReport(
        missingFiles: report.missingFiles.where((i) => i != issue).toList(),
        orphanedFiles: report.orphanedFiles,
        checksumMismatches: report.checksumMismatches,
        encryptedHeaderIssues: report.encryptedHeaderIssues,
        filesScanned: report.filesScanned,
      );

  IntegrityCheckReport _withoutOrphan(IntegrityCheckReport report, OrphanedFileIssue issue) =>
      IntegrityCheckReport(
        missingFiles: report.missingFiles,
        orphanedFiles: report.orphanedFiles.where((i) => i != issue).toList(),
        checksumMismatches: report.checksumMismatches,
        encryptedHeaderIssues: report.encryptedHeaderIssues,
        filesScanned: report.filesScanned,
      );

  Future<void> _openAsset(String assetId) async {
    final asset = await widget.library.db.assetById(assetId);
    if (asset == null || !mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AssetViewerScreen(
        assets: [asset],
        initialIndex: 0,
        paths: widget.library.paths,
        db: widget.library.db,
        library: widget.library,
      ),
    ));
  }

  String _kindLabel(MissingFileKind kind) => switch (kind) {
        MissingFileKind.original => 'Original',
        MissingFileKind.thumbnail => 'Thumbnail',
        MissingFileKind.preview => 'Vorschau',
        MissingFileKind.developed => 'Entwickeltes Bild',
        MissingFileKind.restored => 'KI-restauriertes Bild',
        MissingFileKind.trimmed => 'Geschnittenes Video',
        MissingFileKind.faceCrop => 'Gesichts-Crop',
        MissingFileKind.mask => 'KI-Maske',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bibliotheks-Integritätsprüfung'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Erneut prüfen',
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
            child: CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Prüfsummen prüfen'),
              subtitle: const Text(
                'Liest jede Originaldatei komplett ein und vergleicht sie mit der beim Import '
                'gespeicherten Prüfsumme – bei großen Bibliotheken deutlich langsamer als die '
                'reine Existenz-/Verwaisten-Prüfung.',
              ),
              value: _verifyChecksums,
              onChanged: _loading
                  ? null
                  : (v) {
                      setState(() => _verifyChecksums = v ?? false);
                      _load();
                    },
            ),
          ),
          const Divider(height: 1),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Text(_error!, textAlign: TextAlign.center),
        ),
      );
    }
    final report = _report;
    if (report == null) return const SizedBox.shrink();
    if (report.isClean) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline, size: 56, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text('Keine Probleme gefunden (${report.filesScanned} Dateien geprüft).'),
            ],
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        if (report.missingFiles.isNotEmpty)
          _Section(
            title: 'Fehlende Dateien (${report.missingFiles.length})',
            children: [
              for (final issue in report.missingFiles)
                ListTile(
                  leading: const Icon(Icons.error_outline, color: Colors.orange),
                  title: Text(issue.relativePath),
                  subtitle: Text(_kindLabel(issue.kind)),
                  trailing: TextButton(
                    onPressed: () => _removeMissingFromDb(issue),
                    child: const Text('Aus DB entfernen'),
                  ),
                ),
            ],
          ),
        if (report.orphanedFiles.isNotEmpty)
          _Section(
            title: 'Verwaiste Dateien (${report.orphanedFiles.length})',
            children: [
              for (final issue in report.orphanedFiles)
                ListTile(
                  leading: const Icon(Icons.help_outline, color: Colors.orange),
                  title: Text(issue.relativePath),
                  subtitle: Text('${(issue.sizeBytes / 1024).round()} KB'),
                  trailing: TextButton(
                    onPressed: () => _deleteOrphanedFile(issue),
                    child: const Text('Datei löschen'),
                  ),
                ),
            ],
          ),
        if (report.checksumMismatches.isNotEmpty)
          _Section(
            title: 'Prüfsummen-Abweichungen (${report.checksumMismatches.length})',
            children: [
              for (final issue in report.checksumMismatches)
                ListTile(
                  leading: const Icon(Icons.warning_amber, color: Colors.red),
                  title: Text(issue.relativePath),
                  subtitle: const Text('Inhalt hat sich seit dem Import geändert'),
                  trailing: TextButton(
                    onPressed: () => _openAsset(issue.assetId),
                    child: const Text('Foto öffnen'),
                  ),
                ),
            ],
          ),
        if (report.encryptedHeaderIssues.isNotEmpty)
          _Section(
            title: 'Verschlüsselte Dateien mit ungültigem Header (${report.encryptedHeaderIssues.length})',
            children: [
              for (final issue in report.encryptedHeaderIssues)
                ListTile(
                  leading: const Icon(Icons.warning_amber, color: Colors.red),
                  title: Text(issue.relativePath),
                  subtitle: const Text('Datei ist evtl. beschädigt – keine gültige verschlüsselte Datei'),
                ),
            ],
          ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(title, style: Theme.of(context).textTheme.titleSmall),
          ),
          Card(child: Column(children: children)),
        ],
      ),
    );
  }
}
