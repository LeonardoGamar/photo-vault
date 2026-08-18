import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

import '../db/database.dart';
import '../state/library_state.dart';
import '../theme/app_spacing.dart';
import '../widgets/empty_state.dart';
import 'asset_viewer_screen.dart';

class TrashScreen extends StatefulWidget {
  final LibraryState library;
  const TrashScreen({super.key, required this.library});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  final Set<String> _selected = {};

  Future<bool?> _confirm(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppTexte.of(context).allgAbbrechen)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppTexte.of(context).allgLoeschen),
          ),
        ],
      ),
    );
  }

  Future<void> _permanentlyDelete(List<AssetData> toDelete) async {
    for (final asset in toDelete) {
      await widget.library.deleteAssetFilesFromDisk(asset);
    }
    await widget.library.db.deleteAssetRows(toDelete.map((a) => a.id).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTexte.of(context).papierkorbTitel),
        actions: [
          if (_selected.isNotEmpty) ...[
            IconButton(
              tooltip: AppTexte.of(context).einstWiederherstellen,
              icon: const Icon(Icons.restore_from_trash_outlined),
              onPressed: () async {
                await widget.library.db.restoreFromTrash(_selected.toList());
                if (!mounted) return;
                setState(() => _selected.clear());
              },
            ),
            IconButton(
              tooltip: AppTexte.of(context).bestaetigEndgueltigLoeschen,
              icon: const Icon(Icons.delete_forever_outlined),
              onPressed: () async {
                final confirm = await _confirm(
                    AppTexte.of(context).papierkorbEndgueltigTitel, AppTexte.of(context).papierkorbEndgueltigText(_selected.length));
                if (confirm != true) return;
                final all = await widget.library.db.select(widget.library.db.assets).get();
                final toDelete = all.where((a) => _selected.contains(a.id)).toList();
                await _permanentlyDelete(toDelete);
                if (!mounted) return;
                setState(() => _selected.clear());
              },
            ),
          ],
        ],
      ),
      body: StreamBuilder<List<AssetData>>(
        stream: widget.library.db.watchTrash(),
        builder: (context, snapshot) {
          final assets = snapshot.data ?? [];
          if (assets.isEmpty) {
            return EmptyState(icon: Icons.delete_outline, message: AppTexte.of(context).papierkorbLeer);
          }
          return GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 160,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: assets.length,
            itemBuilder: (context, index) {
              final asset = assets[index];
              final isSelected = _selected.contains(asset.id);
              return GestureDetector(
                onLongPress: () => setState(
                    () => isSelected ? _selected.remove(asset.id) : _selected.add(asset.id)),
                onTap: () {
                  if (_selected.isNotEmpty) {
                    setState(() => isSelected ? _selected.remove(asset.id) : _selected.add(asset.id));
                  } else {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => AssetViewerScreen(
                        assets: assets,
                        initialIndex: index,
                        paths: widget.library.paths,
                        db: widget.library.db,
                        library: widget.library,
                      ),
                    ));
                  }
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    asset.thumbnailRelativePath != null
                        ? Image.file(
                            widget.library.paths.absolute(asset.thumbnailRelativePath!),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade900),
                          )
                        : Container(
                            color: Colors.grey.shade900,
                            child: const Icon(Icons.image_outlined, color: Colors.white24),
                          ),
                    if (isSelected)
                      Container(
                        color: Colors.black45,
                        child: const Icon(Icons.check_circle, color: Colors.white),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
