import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../l10n/app_localizations.dart';
import '../widgets/namens_dialog.dart' show MitTextsteuerung;
import '../state/library_state.dart';
import '../theme/app_spacing.dart';
import 'album_detail_screen.dart';

class AlbumsScreen extends StatelessWidget {
  final LibraryState library;
  const AlbumsScreen({super.key, required this.library});

  Future<void> _createAlbum(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      // Die Steuerung gehört dem Fenster, nicht diesem Aufruf – siehe
      // [MitTextsteuerung].
      builder: (context) => MitTextsteuerung(
          builder: (context, ctrl) => AlertDialog(
        title: Text(AppTexte.of(context).albumNeu),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(labelText: AppTexte.of(context).albumName),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppTexte.of(context).allgAbbrechen)),
          FilledButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: Text(AppTexte.of(context).allgErstellen)),
                ],
              )),
    );
    if (name != null && name.isNotEmpty) {
      await library.db.createAlbum(AlbumsCompanion.insert(
        id: const Uuid().v4(),
        name: name,
        createdAt: DateTime.now(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createAlbum(context),
        icon: const Icon(Icons.add),
        label: Text(AppTexte.of(context).albumNeu),
      ),
      body: StreamBuilder<List<AlbumData>>(
        stream: library.db.watchAlbums(),
        builder: (context, snapshot) {
          final albums = snapshot.data ?? [];
          if (albums.isEmpty) {
            return Center(child: Text(AppTexte.of(context).albenLeer));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: albums.length,
            itemBuilder: (context, index) {
              final album = albums[index];
              return InkWell(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => AlbumDetailScreen(library: library, albumId: album.id, albumName: album.name),
                )),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.photo_album_outlined, size: 40),
                      const SizedBox(height: 8),
                      Text(album.name, style: Theme.of(context).textTheme.titleSmall),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
