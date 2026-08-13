import 'dart:async';

import 'package:flutter/material.dart';

import '../services/removable_media_service.dart';
import '../theme/app_spacing.dart';

/// Zeigt alle aktuell erkannten Kameras/SD-Karten (siehe
/// [RemovableMediaService]) zur Auswahl an und aktualisiert die Liste
/// automatisch alle 2 Sekunden, solange der Dialog offen ist – der
/// Datenträger muss also nicht schon VOR dem Öffnen eingesteckt sein.
/// Gibt den DCIM-Pfad der gewählten Quelle zurück, oder `null` bei Abbruch.
Future<String?> showCameraSourcePickerDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (context) => const _CameraSourcePickerDialog(),
  );
}

class _CameraSourcePickerDialog extends StatefulWidget {
  const _CameraSourcePickerDialog();

  @override
  State<_CameraSourcePickerDialog> createState() => _CameraSourcePickerDialogState();
}

class _CameraSourcePickerDialogState extends State<_CameraSourcePickerDialog> {
  static const _service = RemovableMediaService();
  Timer? _pollTimer;
  List<DetectedMediaSource>? _sources;

  @override
  void initState() {
    super.initState();
    _refresh();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _refresh());
  }

  Future<void> _refresh() async {
    final sources = await _service.detect();
    if (mounted) setState(() => _sources = sources);
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sources = _sources;
    return AlertDialog(
      title: const Text('Von Kamera/SD-Karte importieren'),
      content: SizedBox(
        width: 420,
        child: sources == null
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                child: Center(child: CircularProgressIndicator()),
              )
            : sources.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Text(
                      'Kein Datenträger mit Fotos/Videos gefunden. Kamera oder '
                      'SD-Karte per USB einstecken – die Liste aktualisiert sich '
                      'automatisch, sobald sie erkannt wird.',
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final source in sources)
                        ListTile(
                          leading: const Icon(Icons.sd_card_outlined),
                          title: Text(source.name),
                          subtitle: Text(
                            source.dcimPath,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11),
                          ),
                          onTap: () => Navigator.pop(context, source.dcimPath),
                        ),
                    ],
                  ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
      ],
    );
  }
}
