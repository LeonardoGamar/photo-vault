import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../state/library_state.dart';
import '../theme/app_spacing.dart';
import '../widgets/person_picker_dialog.dart';

/// Eine per Union-Find-Clustering (siehe face_clustering_service.dart)
/// vorgeschlagene Gruppe unzugeordneter Gesichter, die vermutlich zur
/// selben Person gehören – optional mit einem Vorschlag, welche bereits
/// benannte Person das sein könnte (Centroid-Vergleich).
class FaceClusterSuggestion {
  final List<FaceData> faces;
  final PersonData? suggestedPerson;
  const FaceClusterSuggestion({required this.faces, this.suggestedPerson});
}

/// Review-Ansicht für die Vorschläge aus "Automatisch gruppieren": jede
/// Karte zeigt eine vermutete Personengruppe zur Bestätigung durch den
/// Nutzer. Es wird nie automatisch/still zugeordnet – passend zur sonst in
/// der App durchgängigen Konvention, dass KI-gestützte Operationen manuell
/// ausgelöst UND bestätigt werden (siehe z.B. Gesichts-Scan, KI-Tagging).
/// Jede Zuordnung wird sofort committet, kein Sammel-Commit am Ende; nicht
/// durchgesehene Cluster bleiben unzugeordnet und tauchen beim nächsten
/// "Automatisch gruppieren"-Lauf wieder auf.
class FaceClusterReviewScreen extends StatefulWidget {
  final LibraryState library;
  final List<FaceClusterSuggestion> suggestions;
  const FaceClusterReviewScreen({super.key, required this.library, required this.suggestions});

  @override
  State<FaceClusterReviewScreen> createState() => _FaceClusterReviewScreenState();
}

class _FaceClusterReviewScreenState extends State<FaceClusterReviewScreen> {
  late final List<FaceClusterSuggestion> _pending = List.of(widget.suggestions);

  Future<void> _assign(FaceClusterSuggestion cluster) async {
    final people = await widget.library.db.select(widget.library.db.people).get();
    if (!mounted) return;
    final choice = await showPersonPickerDialog(
      context,
      people,
      title: '${cluster.faces.length} Gesichter zuordnen',
      suggestedPerson: cluster.suggestedPerson,
    );
    if (choice == null) return;

    String personId;
    if (choice.newName != null) {
      personId = const Uuid().v4();
      await widget.library.db.createPerson(
        PeopleCompanion.insert(id: personId, name: choice.newName!),
      );
    } else {
      personId = choice.existingPersonId!;
    }
    await widget.library.db.assignFacesToPerson(cluster.faces.map((f) => f.id).toList(), personId);
    if (mounted) setState(() => _pending.remove(cluster));
  }

  void _skip(FaceClusterSuggestion cluster) => setState(() => _pending.remove(cluster));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vorschläge prüfen')),
      body: _pending.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xxl),
                child: Text('Alle Vorschläge durchgesehen.', textAlign: TextAlign.center),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: _pending.length,
              itemBuilder: (context, index) {
                final cluster = _pending[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            for (final face in cluster.faces.take(6))
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: face.cropRelativePath != null
                                      ? Image.file(
                                          widget.library.paths.absolute(face.cropRelativePath!),
                                          width: 56,
                                          height: 56,
                                          fit: BoxFit.cover,
                                        )
                                      : const SizedBox(width: 56, height: 56),
                                ),
                              ),
                            if (cluster.faces.length > 6)
                              Text('+${cluster.faces.length - 6}',
                                  style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('${cluster.faces.length} Gesichter'),
                        if (cluster.suggestedPerson != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Chip(
                              label: Text('Ähnlich zu: ${cluster.suggestedPerson!.name}'),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _skip(cluster),
                                child: const Text('Überspringen'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                onPressed: () => _assign(cluster),
                                child: const Text('Zuordnen'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
