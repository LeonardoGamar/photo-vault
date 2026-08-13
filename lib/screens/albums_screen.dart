import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../state/library_state.dart';
import '../theme/app_spacing.dart';
import 'album_detail_screen.dart';

class AlbumsScreen extends StatelessWidget {
  final LibraryState library;
  const AlbumsScreen({super.key, required this.library});

  Future<void> _createAlbum(BuildContext context) async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Neues Album'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Albumname'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
          FilledButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('Erstellen')),
        ],
      ),
    );
    ctrl.dispose();
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
        label: const Text('Neues Album'),
      ),
      body: StreamBuilder<List<AlbumData>>(
        stream: library.db.watchAlbums(),
        builder: (context, snapshot) {
          final albums = snapshot.data ?? [];
          if (albums.isEmpty) {
            return const Center(child: Text('Noch keine Alben vorhanden.'));
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
