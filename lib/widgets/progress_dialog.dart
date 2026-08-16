import 'package:flutter/material.dart';

/// Zeigt den Fortschritt eines Streams (z.B. Backup, Restore, Gesichts-Scan)
/// in einem nicht schließbaren Dialog mit Fortschrittsbalken und Text.
class ProgressDialog extends StatelessWidget {
  final String title;
  final Stream<String> stream;
  const ProgressDialog({super.key, required this.title, required this.stream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: stream,
      builder: (context, snapshot) {
        final done = snapshot.connectionState == ConnectionState.done;
        final failed = snapshot.hasError;
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!done)
                const LinearProgressIndicator()
              else if (failed)
                const Icon(Icons.error_outline, color: Colors.red)
              else
                const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(height: 12),
              // Ein Stream-Fehler (z.B. ein Modell, das sich nicht laden
              // ließ) darf hier nie als Erfolg durchgehen – vorher wurde nur
              // `snapshot.data` gelesen, das bei einem Fehler VOR dem ersten
              // `yield` schlicht leer blieb und trotzdem den grünen Haken
              // zeigte (Audit-Fund).
              Text(failed ? 'Fehlgeschlagen: ${snapshot.error}' : (snapshot.data ?? '…')),
            ],
          ),
          actions: [
            if (done)
              FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Schließen')),
          ],
        );
      },
    );
  }
}
