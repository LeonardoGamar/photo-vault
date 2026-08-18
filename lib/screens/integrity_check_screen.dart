import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

import '../services/integrity_check_service.dart';
import '../state/library_state.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
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
      if (!mounted) return;
      setState(() {
        _report = report;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = AppTexte.of(context).integPruefungFehlgeschlagen('$e'));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _removeMissingFromDb(MissingFileIssue issue) async {
    final confirmed = await confirmDialog(
      context,
      AppTexte.of(context).integAusDbEntfernenTitel,
      switch (issue.kind) {
        MissingFileKind.original =>
          AppTexte.of(context).integOriginalFehlt,
        MissingFileKind.mask => AppTexte.of(context).integMaskeFehlt,
        MissingFileKind.faceCrop =>
          AppTexte.of(context).integCropFehlt,
        _ => AppTexte.of(context).integPfadEntfernt,
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
      AppTexte.of(context).integDateiLoeschenTitel,
      AppTexte.of(context).integDateiLoeschenText(issue.relativePath),
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

  /// Die Art der fehlenden Datei in der Oberflächensprache. Wie beim
  /// Modellkatalog wandert der Text nicht in die Aufzählung selbst –
  /// `MissingFileKind` stammt aus dem Dienst und kennt keinen Kontext.
  String _kindLabel(AppTexte t, MissingFileKind kind) => switch (kind) {
        MissingFileKind.original => t.integArtOriginal,
        MissingFileKind.thumbnail => t.integArtThumbnail,
        MissingFileKind.preview => t.integArtVorschau,
        MissingFileKind.developed => t.integArtEntwickelt,
        MissingFileKind.restored => t.integArtRestauriert,
        MissingFileKind.trimmed => t.integArtVideoZuschnitt,
        MissingFileKind.faceCrop => t.integArtGesichtsCrop,
        MissingFileKind.mask => t.integArtMaske,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTexte.of(context).werkzIntegritaetTitel),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: AppTexte.of(context).integErneutPruefen,
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
              title: Text(AppTexte.of(context).integPruefsummen),
              subtitle: Text(
                AppTexte.of(context).integPruefsummenHinweis,
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
              Text(AppTexte.of(context).integKeineProbleme(report.filesScanned)),
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
            title: AppTexte.of(context).integFehlendeDateien(report.missingFiles.length),
            children: [
              for (final issue in report.missingFiles)
                ListTile(
                  leading: Icon(Icons.error_outline, color: context.semantik.warnung),
                  title: Text(issue.relativePath),
                  subtitle: Text(_kindLabel(AppTexte.of(context), issue.kind)),
                  trailing: TextButton(
                    onPressed: () => _removeMissingFromDb(issue),
                    child: Text(AppTexte.of(context).integAusDbEntfernen),
                  ),
                ),
            ],
          ),
        if (report.orphanedFiles.isNotEmpty)
          _Section(
            title: AppTexte.of(context).integVerwaisteDateien(report.orphanedFiles.length),
            children: [
              for (final issue in report.orphanedFiles)
                ListTile(
                  leading: Icon(Icons.help_outline, color: context.semantik.warnung),
                  title: Text(issue.relativePath),
                  subtitle: Text('${(issue.sizeBytes / 1024).round()} KB'),
                  trailing: TextButton(
                    onPressed: () => _deleteOrphanedFile(issue),
                    child: Text(AppTexte.of(context).integDateiLoeschen),
                  ),
                ),
            ],
          ),
        if (report.checksumMismatches.isNotEmpty)
          _Section(
            title: AppTexte.of(context).integAbweichungen(report.checksumMismatches.length),
            children: [
              for (final issue in report.checksumMismatches)
                ListTile(
                  leading: Icon(Icons.warning_amber, color: Theme.of(context).colorScheme.error),
                  title: Text(issue.relativePath),
                  subtitle: Text(AppTexte.of(context).integInhaltGeaendert),
                  trailing: TextButton(
                    onPressed: () => _openAsset(issue.assetId),
                    child: Text(AppTexte.of(context).integFotoOeffnen),
                  ),
                ),
            ],
          ),
        if (report.encryptedHeaderIssues.isNotEmpty)
          _Section(
            title: AppTexte.of(context).integHeaderProbleme(report.encryptedHeaderIssues.length),
            children: [
              for (final issue in report.encryptedHeaderIssues)
                ListTile(
                  leading: Icon(Icons.warning_amber, color: Theme.of(context).colorScheme.error),
                  title: Text(issue.relativePath),
                  subtitle: Text(AppTexte.of(context).integBeschaedigt),
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
