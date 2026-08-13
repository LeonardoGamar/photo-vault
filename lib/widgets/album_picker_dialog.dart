import 'package:flutter/material.dart';

import '../db/database.dart';

class AlbumChoice {
  final String? newName;
  final String? existingAlbumId;
  AlbumChoice.newAlbum(this.newName) : existingAlbumId = null;
  AlbumChoice.existing(this.existingAlbumId) : newName = null;
}

/// Zeigt einen Dialog, um Fotos einem neuen oder bestehenden Album
/// hinzuzufügen – analog zu [showPersonPickerDialog]. Wird von der
/// Mehrfachauswahl (SelectionActionBar) in Timeline/Suche/Alben verwendet.
Future<AlbumChoice?> showAlbumPickerDialog(
  BuildContext context,
  List<AlbumData> existingAlbums, {
  String title = 'Zu Album hinzufügen',
}) {
  return showDialog<AlbumChoice>(
    context: context,
    builder: (context) => _AlbumPickerDialog(existingAlbums: existingAlbums, title: title),
  );
}

class _AlbumPickerDialog extends StatefulWidget {
  final List<AlbumData> existingAlbums;
  final String title;
  const _AlbumPickerDialog({required this.existingAlbums, required this.title});

  @override
  State<_AlbumPickerDialog> createState() => _AlbumPickerDialogState();
}

class _AlbumPickerDialogState extends State<_AlbumPickerDialog> {
  final _nameCtrl = TextEditingController();
  AlbumData? _selectedExisting;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.existingAlbums.isNotEmpty) ...[
            DropdownButtonFormField<AlbumData>(
              initialValue: _selectedExisting,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Bestehendes Album'),
              items: widget.existingAlbums
                  .map((a) => DropdownMenuItem(value: a, child: Text(a.name)))
                  .toList(),
              onChanged: (a) => setState(() => _selectedExisting = a),
            ),
            const SizedBox(height: 12),
            const Text('— oder —', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Neues Album anlegen'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
        FilledButton(
          onPressed: () {
            if (_nameCtrl.text.trim().isNotEmpty) {
              Navigator.pop(context, AlbumChoice.newAlbum(_nameCtrl.text.trim()));
            } else if (_selectedExisting != null) {
              Navigator.pop(context, AlbumChoice.existing(_selectedExisting!.id));
            }
          },
          child: const Text('Hinzufügen'),
        ),
      ],
    );
  }
}
