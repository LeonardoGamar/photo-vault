import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../services/export_service.dart';
import '../state/library_state.dart';
import '../theme/app_spacing.dart';
import 'album_picker_dialog.dart';
import 'color_label_picker.dart';
import 'mini_location_map.dart';
import 'star_rating.dart';

/// Schwebende Aktionsleiste am unteren Rand, sichtbar sobald in einem
/// Foto-Raster (Timeline, Jahresansicht, Suche, Album) mindestens ein Foto
/// per langem Druck ausgewählt wurde – analog zu Google Fotos/Apple Fotos.
/// Enthält nur die allgemeinen, überall gleichen Sammelaktionen; was
/// "Löschen" im jeweiligen Kontext genau bedeutet (einfaches Verschieben in
/// den Papierkorb vs. zusätzlich Entfernen aus einem Album), entscheidet der
/// Aufrufer über [onDelete] selbst.
class SelectionActionBar extends StatelessWidget {
  final int count;
  final VoidCallback onClear;
  final VoidCallback onFavorite;
  final VoidCallback onAddToAlbum;
  final VoidCallback onTag;
  final VoidCallback onSetRating;
  final VoidCallback onSetColorLabel;
  final VoidCallback onEditMetadata;
  final VoidCallback onExport;
  final VoidCallback onDelete;

  const SelectionActionBar({
    super.key,
    required this.count,
    required this.onClear,
    required this.onFavorite,
    required this.onAddToAlbum,
    required this.onTag,
    required this.onSetRating,
    required this.onSetColorLabel,
    required this.onEditMetadata,
    required this.onExport,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Material(
        elevation: 8,
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Auswahl aufheben',
                  onPressed: onClear,
                ),
                Text('$count ausgewählt'),
                const Spacer(),
                IconButton(icon: const Icon(Icons.favorite_border), tooltip: 'Favorisieren', onPressed: onFavorite),
                IconButton(
                    icon: const Icon(Icons.playlist_add), tooltip: 'Zu Album hinzufügen', onPressed: onAddToAlbum),
                IconButton(icon: const Icon(Icons.label_outline), tooltip: 'Tag hinzufügen', onPressed: onTag),
                IconButton(icon: const Icon(Icons.star_outline), tooltip: 'Bewertung setzen', onPressed: onSetRating),
                IconButton(
                    icon: const Icon(Icons.circle_outlined), tooltip: 'Farbmarkierung setzen', onPressed: onSetColorLabel),
                IconButton(
                    icon: const Icon(Icons.edit_note_outlined), tooltip: 'Metadaten bearbeiten', onPressed: onEditMetadata),
                IconButton(icon: const Icon(Icons.ios_share), tooltip: 'Exportieren', onPressed: onExport),
                IconButton(icon: const Icon(Icons.delete_outline), tooltip: 'Löschen', onPressed: onDelete),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Einfacher Ja/Nein-Bestätigungsdialog für Sammelaktionen, die sich nicht
/// (leicht) rückgängig machen lassen.
Future<bool> confirmDialog(BuildContext context, String title, String message) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Löschen'),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Markiert alle übergebenen Fotos als Favorit. Bewusst kein Toggle – bei
/// gemischter Auswahl (manche schon favorisiert, manche nicht) wäre ein
/// Umschalten mehrdeutig; "als Favorit markieren" ist wie in Google Fotos
/// die einzige Sammelaktion.
Future<void> runBatchFavorite(LibraryState library, List<String> assetIds) async {
  for (final id in assetIds) {
    await library.db.setFavorite(id, true);
  }
}

/// Zeigt eine Sternereihe zur Auswahl einer gemeinsamen Bewertung für alle
/// übergebenen Fotos ("Keine Bewertung" setzt explizit auf 0 zurück statt
/// den Dialog nur abzubrechen).
Future<void> runBatchSetRating(BuildContext context, LibraryState library, List<String> assetIds) async {
  final rating = await showDialog<int>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Bewertung für ${assetIds.length} Foto(s)'),
      content: StarRating(value: 0, size: 32, onChanged: (v) => Navigator.pop(context, v)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, 0), child: const Text('Keine Bewertung')),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
      ],
    ),
  );
  if (rating == null) return;
  await library.db.setRatingBulk(assetIds, rating);
}

/// Zeigt die Farbmarkierungs-Palette zur Auswahl einer gemeinsamen
/// Farbmarkierung für alle übergebenen Fotos. Der leere String dient als
/// Sentinel für "Keine Farbe" (die eigentliche Spalte ist `null`) – so lässt
/// sich der Abbrechen-Fall (`null` vom Dialog-Barrier) vom bewussten
/// Löschen der Markierung unterscheiden.
Future<void> runBatchSetColorLabel(BuildContext context, LibraryState library, List<String> assetIds) async {
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Farbmarkierung für ${assetIds.length} Foto(s)'),
      content: ColorLabelPicker(value: null, size: 32, onChanged: (c) => Navigator.pop(context, c ?? '')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, ''), child: const Text('Keine Farbe')),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
      ],
    ),
  );
  if (result == null) return;
  await library.db.setColorLabelBulk(assetIds, result.isEmpty ? null : result);
}

/// Dialog mit drei optionalen Feldern (Beschreibung, Datum, Ort) – nur
/// tatsächlich ausgefüllte/geänderte Felder werden geschrieben, damit die
/// Sammelbearbeitung keine bestehenden Werte der einzelnen Fotos mit
/// Leerwerten überschreibt.
Future<void> runBatchEditMetadataDialog(BuildContext context, LibraryState library, List<String> assetIds) async {
  final result = await showDialog<_BatchMetadataResult>(
    context: context,
    builder: (context) => _BatchMetadataDialog(count: assetIds.length),
  );
  if (result == null) return;
  if (result.description != null) {
    await library.db.setDescriptionBulk(assetIds, result.description!);
  }
  if (result.date != null) {
    await library.db.setFileCreatedAtBulk(assetIds, result.date!);
  }
  if (result.latitude != null && result.longitude != null) {
    await library.db.setLocationBulk(assetIds, result.latitude, result.longitude);
  }
}

class _BatchMetadataResult {
  final String? description;
  final DateTime? date;
  final double? latitude;
  final double? longitude;
  const _BatchMetadataResult({this.description, this.date, this.latitude, this.longitude});
}

class _BatchMetadataDialog extends StatefulWidget {
  final int count;
  const _BatchMetadataDialog({required this.count});

  @override
  State<_BatchMetadataDialog> createState() => _BatchMetadataDialogState();
}

class _BatchMetadataDialogState extends State<_BatchMetadataDialog> {
  final _descriptionCtrl = TextEditingController();
  DateTime? _date;
  double? _latitude;
  double? _longitude;

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    Navigator.pop(
      context,
      _BatchMetadataResult(
        description: _descriptionCtrl.text.trim().isEmpty ? null : _descriptionCtrl.text.trim(),
        date: _date,
        latitude: _latitude,
        longitude: _longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Metadaten für ${widget.count} Foto(s) bearbeiten'),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _descriptionCtrl,
                decoration: const InputDecoration(
                  labelText: 'Beschreibung (überschreibt bestehende)',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_date == null ? 'Datum unverändert lassen' : 'Datum: ${_date!.toLocal()}'.split('.').first),
                trailing: TextButton(onPressed: _pickDate, child: const Text('Wählen')),
              ),
              const SizedBox(height: 12),
              const Text('Ort (unverändert lassen: nicht antippen)'),
              const SizedBox(height: 8),
              MiniLocationMap(
                latitude: _latitude,
                longitude: _longitude,
                onLocationChanged: (lat, lon) => setState(() {
                  _latitude = lat;
                  _longitude = lon;
                }),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
        FilledButton(onPressed: _save, child: const Text('Speichern')),
      ],
    );
  }
}

/// Fragt einen einzelnen Tag-Namen ab und fügt ihn allen übergebenen Fotos
/// hinzu.
Future<void> runBatchTagDialog(BuildContext context, LibraryState library, List<String> assetIds) async {
  final ctrl = TextEditingController();
  final tag = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Tag zu ${assetIds.length} Foto(s) hinzufügen'),
      content: TextField(controller: ctrl, autofocus: true, decoration: const InputDecoration(labelText: 'Tag')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
        FilledButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('Hinzufügen')),
      ],
    ),
  );
  ctrl.dispose();
  if (tag == null || tag.isEmpty) return;
  for (final id in assetIds) {
    await library.db.tagAsset(id, tag);
  }
}

/// Zeigt den Album-Auswahl-Dialog und fügt die übergebenen Fotos danach dem
/// gewählten (oder neu angelegten) Album hinzu.
Future<void> runBatchAddToAlbumDialog(BuildContext context, LibraryState library, List<String> assetIds) async {
  final existingAlbums = await library.db.watchAlbums().first;
  if (!context.mounted) return;
  final choice = await showAlbumPickerDialog(context, existingAlbums);
  if (choice == null) return;

  final String albumId;
  if (choice.newName != null) {
    albumId = const Uuid().v4();
    await library.db.createAlbum(
      AlbumsCompanion.insert(id: albumId, name: choice.newName!, createdAt: DateTime.now()),
    );
  } else {
    albumId = choice.existingAlbumId!;
  }
  await library.db.addAssetsToAlbum(albumId, assetIds);
}

/// Exportiert alle übergebenen Fotos in einen vom Nutzer gewählten Ordner,
/// mit Fortschrittsanzeige – dieselbe Logik wie der bisherige, nur an ein
/// Album gebundene "Album exportieren"-Button in AlbumDetailScreen, jetzt
/// für eine beliebige Auswahl nutzbar.
Future<void> runBatchExport(BuildContext context, LibraryState library, List<AssetData> assets) async {
  final destination = await FilePicker.platform.getDirectoryPath(
    dialogTitle: 'Zielordner für ${assets.length} Foto(s) wählen',
  );
  if (destination == null || !context.mounted) return;

  final exporter = ExportService(library.paths, library: library);
  var done = 0;
  void Function(void Function())? setDialogState;

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => StatefulBuilder(builder: (context, setState) {
      setDialogState = setState;
      return AlertDialog(
        content: Row(
          children: [
            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: 16),
            Expanded(child: Text('Exportiere … ($done / ${assets.length})')),
          ],
        ),
      );
    }),
  );

  var exported = 0;
  for (final asset in assets) {
    try {
      await exporter.exportAsset(asset, destination);
      exported++;
    } catch (_) {
      // Einzelne fehlgeschlagene Datei überspringen, Rest weiter exportieren.
    }
    done++;
    setDialogState?.call(() {});
  }

  if (context.mounted) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$exported von ${assets.length} Foto(s) exportiert nach $destination')),
    );
  }
}
