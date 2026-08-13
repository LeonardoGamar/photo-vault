import 'dart:io';

import 'package:flutter/material.dart';

import '../db/database.dart';
import '../state/library_state.dart';
import '../theme/app_spacing.dart';
import 'asset_viewer_screen.dart';

/// Zeigt alle Fotos/Videos im gesperrten Ordner (Tab "Fotos") sowie einen
/// eigenen, PIN-geschützten Papierkorb dafür (Tab "Papierkorb") – daraus
/// gelöschte, gesperrte Fotos landen NICHT im normalen, ungeschützten
/// Papierkorb (siehe AppDatabase.watchTrash), sonst könnte jeder ohne PIN
/// ein gesperrtes Foto wiederherstellen oder sogar endgültig löschen.
///
/// Der Zugriff auf diesen Screen selbst wird bereits vorher über die
/// PIN-Abfrage in [SettingsScreen] abgesichert – hier findet keine erneute
/// Prüfung mehr statt, der Master-Key gilt für die laufende App-Sitzung
/// (siehe LibraryState.vaultUnlockedThisSession). Thumbnails und die
/// Vollbildansicht werden hier on-demand entschlüsselt (die Originaldateien
/// auf der Platte bleiben dabei verschlüsselt).
class LockedFolderScreen extends StatefulWidget {
  final LibraryState library;
  const LockedFolderScreen({super.key, required this.library});

  @override
  State<LockedFolderScreen> createState() => _LockedFolderScreenState();
}

class _LockedFolderScreenState extends State<LockedFolderScreen> {
  LibraryState get library => widget.library;

  @override
  void dispose() {
    // Entschlüsselte Zwischenkopien (Thumbnails/Vollbild) sollen nicht
    // länger als nötig als Klartext im OS-Temp-Verzeichnis liegen bleiben.
    library.clearDecryptCache();
    super.dispose();
  }

  Future<void> _permanentlyDelete(AssetData asset) async {
    await library.deleteAssetFilesFromDisk(asset);
    await library.db.deleteAssetRows([asset.id]);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gesperrter Ordner'),
          bottom: const TabBar(tabs: [Tab(text: 'Fotos'), Tab(text: 'Papierkorb')]),
        ),
        body: TabBarView(
          children: [
            _LockedAssetsGrid(library: library),
            _LockedTrashGrid(library: library, onPermanentlyDelete: _permanentlyDelete),
          ],
        ),
      ),
    );
  }
}

class _LockedAssetsGrid extends StatelessWidget {
  final LibraryState library;
  const _LockedAssetsGrid({required this.library});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AssetData>>(
      stream: library.db.watchLockedAssets(),
      builder: (context, snapshot) {
        final assets = snapshot.data ?? [];
        if (assets.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xxl),
              child: Text(
                'Keine gesperrten Fotos. In der Vollbildansicht eines Fotos '
                'lässt es sich über das Schloss-Symbol oben rechts hierher '
                'verschieben (dabei verschlüsselt).',
                textAlign: TextAlign.center,
              ),
            ),
          );
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
            return Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => AssetViewerScreen(
                        assets: assets,
                        initialIndex: index,
                        paths: library.paths,
                        db: library.db,
                        library: library,
                        onToggleFavorite: (a) => library.db.setFavorite(a.id, !a.isFavorite),
                        onDelete: (a) => library.db.moveToTrash([a.id]),
                      ),
                    )),
                    child: _DecryptedThumbnail(asset: asset, library: library),
                  ),
                ),
                Positioned(
                  right: 4,
                  top: 4,
                  child: Material(
                    color: Colors.black54,
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: const Icon(Icons.lock_open, color: Colors.white, size: 18),
                      tooltip: 'Aus dem gesperrten Ordner entfernen (entschlüsseln)',
                      onPressed: () => library.unlockAsset(asset),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _LockedTrashGrid extends StatelessWidget {
  final LibraryState library;
  final Future<void> Function(AssetData asset) onPermanentlyDelete;
  const _LockedTrashGrid({required this.library, required this.onPermanentlyDelete});

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Endgültig löschen?'),
        content: const Text(
          'Die Datei wird unwiderruflich gelöscht – auch mit dem richtigen PIN gibt es '
          'danach keine Wiederherstellung mehr.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Endgültig löschen'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AssetData>>(
      stream: library.db.watchLockedTrash(),
      builder: (context, snapshot) {
        final assets = snapshot.data ?? [];
        if (assets.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xxl),
              child: Text(
                'Der gesperrte Papierkorb ist leer.\n\nAus dem gesperrten Ordner '
                'gelöschte Fotos landen hier statt im normalen (ungeschützten) '
                'Papierkorb.',
                textAlign: TextAlign.center,
              ),
            ),
          );
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
            return Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => AssetViewerScreen(
                        assets: assets,
                        initialIndex: index,
                        paths: library.paths,
                        db: library.db,
                        library: library,
                      ),
                    )),
                    child: _DecryptedThumbnail(asset: asset, library: library),
                  ),
                ),
                Positioned(
                  right: 4,
                  top: 4,
                  child: Material(
                    color: Colors.black54,
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: const Icon(Icons.delete_forever_outlined, color: Colors.white, size: 18),
                      tooltip: 'Endgültig löschen',
                      onPressed: () async {
                        final confirm = await _confirmDelete(context);
                        if (confirm == true) await onPermanentlyDelete(asset);
                      },
                    ),
                  ),
                ),
                Positioned(
                  left: 4,
                  top: 4,
                  child: Material(
                    color: Colors.black54,
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: const Icon(Icons.restore_from_trash_outlined, color: Colors.white, size: 18),
                      tooltip: 'Wiederherstellen (bleibt gesperrt)',
                      onPressed: () => library.db.restoreFromTrash([asset.id]),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Entschlüsselt das Thumbnail eines gesperrten Assets on-demand (nur
/// einmal pro Sitzung, [LibraryState.decryptForViewing] cacht danach).
class _DecryptedThumbnail extends StatefulWidget {
  final AssetData asset;
  final LibraryState library;
  const _DecryptedThumbnail({required this.asset, required this.library});

  @override
  State<_DecryptedThumbnail> createState() => _DecryptedThumbnailState();
}

class _DecryptedThumbnailState extends State<_DecryptedThumbnail> {
  // Einmalig entschlüsselt statt inline in build(): watchLockedAssets()/
  // watchLockedTrash() lösen bei JEDER Änderung an der assets-Tabelle neu
  // aus (drift invalidiert reaktive Streams pro Tabelle, nicht pro Zeile) –
  // ohne Hoisting würde das komplette sichtbare Raster bei jeder noch so
  // unabhängigen DB-Schreibaktion erneut entschlüsselt.
  Future<File>? _decryptedFuture;

  @override
  void initState() {
    super.initState();
    final thumbPath = widget.asset.thumbnailRelativePath;
    if (thumbPath != null) _decryptedFuture = widget.library.decryptForViewing(thumbPath);
  }

  @override
  Widget build(BuildContext context) {
    final asset = widget.asset;
    final thumbPath = asset.thumbnailRelativePath;
    if (thumbPath == null) {
      return Container(
        color: Colors.grey.shade900,
        child: Icon(
          asset.type == 'VIDEO' ? Icons.videocam_outlined : Icons.image_outlined,
          color: Colors.white24,
        ),
      );
    }
    return FutureBuilder<File>(
      future: _decryptedFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            color: Colors.grey.shade900,
            child: const Center(
              child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          );
        }
        return Image.file(
          snapshot.data!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.grey.shade900,
            child: const Icon(Icons.broken_image_outlined, color: Colors.white24),
          ),
        );
      },
    );
  }
}
