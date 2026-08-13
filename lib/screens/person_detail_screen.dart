import 'package:flutter/material.dart';

import '../db/database.dart';
import '../state/library_state.dart';
import '../theme/app_spacing.dart';
import '../widgets/asset_thumbnail_tile.dart';
import '../widgets/pin_dialogs.dart';
import 'asset_viewer_screen.dart';
import 'face_review_screen.dart';

class PersonDetailScreen extends StatelessWidget {
  final LibraryState library;
  final PersonData person;
  const PersonDetailScreen({super.key, required this.library, required this.person});

  /// Zeigt alle Gesichter dieser Person zur Auswahl an und setzt das
  /// angetippte als neues Profilbild (überschreibt ein evtl. vorhandenes).
  Future<void> _pickProfilePicture(BuildContext context) async {
    final faces = (await library.db.facesForPerson(person.id))
        .where((f) => f.cropRelativePath != null)
        .toList();
    if (faces.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Keine Gesichter dieser Person vorhanden.'),
        ));
      }
      return;
    }
    if (!context.mounted) return;
    final chosen = await showDialog<FaceData>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profilbild auswählen'),
        content: SizedBox(
          width: 360,
          height: 360,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 100,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: faces.length,
            itemBuilder: (context, index) {
              final face = faces[index];
              return InkWell(
                onTap: () => Navigator.pop(context, face),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: Image.file(
                    library.paths.absolute(face.cropRelativePath!),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
        ],
      ),
    );
    if (chosen != null) {
      await library.db.setPersonCover(person.id, chosen.cropRelativePath!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(person.name)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
            child: Row(
              children: [
                StreamBuilder<PersonData?>(
                  stream: library.db.watchPerson(person.id),
                  initialData: person,
                  builder: (context, snapshot) {
                    final coverPath = snapshot.data?.coverFaceCropPath;
                    return CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.grey.shade800,
                      backgroundImage:
                          coverPath != null ? FileImage(library.paths.absolute(coverPath)) : null,
                      child: coverPath == null ? const Icon(Icons.person_outline, size: 28) : null,
                    );
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickProfilePicture(context),
                    icon: const Icon(Icons.image_outlined),
                    label: const Text('Profilbild ändern'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<AssetData>>(
              stream: library.db.watchAssetsForPerson(person.id),
              builder: (context, snapshot) {
                final assets = snapshot.data ?? [];
                if (assets.isEmpty) {
                  return const Center(child: Text('Noch keine Fotos für diese Person.'));
                }
                return Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: Text(
                        'Doppelklick auf ein Foto öffnet es zur Kontrolle mit allen erkannten Gesichtern.',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 160,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                        ),
                        itemCount: assets.length,
                        itemBuilder: (context, index) {
                          final asset = assets[index];
                          return AssetThumbnailTile(
                            asset: asset,
                            paths: library.paths,
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => AssetViewerScreen(
                                assets: assets,
                                initialIndex: index,
                                paths: library.paths,
                                db: library.db,
                                library: library,
                                onToggleFavorite: (a) => library.db.setFavorite(a.id, !a.isFavorite),
                                onDelete: (a) => library.db.moveToTrash([a.id]),
                                onLock: (a) async {
                                  if (await ensureVaultUnlocked(context, library)) {
                                    await library.lockAsset(a);
                                  }
                                },
                              ),
                            )),
                            onDoubleTap: () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => FaceReviewScreen(library: library, asset: asset),
                            )),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
