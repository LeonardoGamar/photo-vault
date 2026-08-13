import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../services/embedding_codec.dart';
import '../services/face_clustering_service.dart';
import '../services/face_engine_service.dart';
import '../services/storage_paths.dart';
import '../state/library_state.dart';
import '../theme/app_spacing.dart';
import '../widgets/asset_thumbnail_tile.dart';
import '../widgets/person_picker_dialog.dart';
import 'face_cluster_review_screen.dart';
import 'face_review_screen.dart';
import 'person_detail_screen.dart';

/// Zeigt benannte Personen als Grid sowie – darunter – alle noch nicht
/// zugeordneten erkannten Gesichter. Die lokale YuNet-Engine erkennt nur
/// Gesichter (Bounding Box), liefert aber keine automatische "das ist
/// dieselbe Person"-Zuordnung; der Nutzer ordnet Gesichter daher manuell
/// einer (neuen oder bestehenden) Person zu – unterstützt durch
/// "Ähnliche mit auswählen" auf Basis der SFace-Embeddings. Ein Doppelklick
/// auf ein Gesicht öffnet das zugehörige Foto in Vollbild zur Kontrolle und
/// zum Benennen weiterer Gesichter darauf.
class PeopleScreen extends StatefulWidget {
  final LibraryState library;
  const PeopleScreen({super.key, required this.library});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  final Set<String> _selectedFaceIds = {};
  final Set<String> _autoSelectedIds = {}; // von "Ähnliche mit auswählen" hinzugefügt
  List<FaceData> _unassignedFaces = [];

  @override
  void initState() {
    super.initState();
    _loadUnassigned();
  }

  Future<void> _loadUnassigned() async {
    final faces = await widget.library.db.unassignedFaces();
    if (mounted) setState(() => _unassignedFaces = faces);
  }

  Float32List _vectorOf(FaceData face) => floatsFromEmbeddingBlob(face.embedding!);

  /// Wählt Gesichter aus, die mind. einem der aktuell ausgewählten Gesichter
  /// ähnlich genug sind (Maximum der paarweisen Kosinus-Ähnlichkeit statt
  /// eines gemittelten "Prototyp"-Vektors – deutlich präziser, besonders bei
  /// mehreren bereits ausgewählten, unterschiedlich aussehenden Fotos
  /// derselben Person). Ein erneuter Klick auf den Button macht genau die
  /// zuvor automatisch hinzugefügte Auswahl wieder rückgängig (Toggle).
  Future<void> _toggleSelectSimilar() async {
    if (_autoSelectedIds.isNotEmpty) {
      setState(() {
        _selectedFaceIds.removeAll(_autoSelectedIds);
        _autoSelectedIds.clear();
      });
      return;
    }

    if (_selectedFaceIds.isEmpty) return;
    final referenceVectors = _unassignedFaces
        .where((f) => _selectedFaceIds.contains(f.id) && f.embedding != null)
        .map(_vectorOf)
        .toList();

    if (referenceVectors.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Für die Ähnlichkeitssuche wird das SFace-Modell benötigt (siehe Einstellungen → Modelle).'),
        ));
      }
      return;
    }

    final newlyAdded = <String>{};
    setState(() {
      for (final face in _unassignedFaces) {
        if (face.embedding == null || _selectedFaceIds.contains(face.id)) continue;
        final vec = _vectorOf(face);
        final bestSim =
            referenceVectors.map((r) => FaceEngineService.cosineSimilarity(r, vec)).reduce(math.max);
        if (bestSim >= widget.library.faceSimilarityThreshold) {
          _selectedFaceIds.add(face.id);
          newlyAdded.add(face.id);
        }
      }
      _autoSelectedIds.addAll(newlyAdded);
    });

    if (newlyAdded.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Keine ähnlichen Gesichter über der Schwelle '
            '${widget.library.faceSimilarityThreshold.toStringAsFixed(2)} gefunden.'),
      ));
    }
  }

  Future<void> _assignSelection() async {
    if (_selectedFaceIds.isEmpty) return;
    final people = await widget.library.db.select(widget.library.db.people).get();
    if (!mounted) return;

    final choice = await showPersonPickerDialog(context, people, title: 'Gesicht(ern) zuordnen');
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

    await widget.library.db.assignFacesToPerson(_selectedFaceIds.toList(), personId);
    setState(() {
      _selectedFaceIds.clear();
      _autoSelectedIds.clear();
    });
    _loadUnassigned();
  }

  /// Gruppiert alle unzugeordneten Gesichter automatisch (siehe
  /// face_clustering_service.dart) und öffnet die Review-Ansicht zur
  /// Bestätigung – bewusst kein stilles Auto-Zuordnen, siehe
  /// FaceClusterReviewScreen.
  Future<void> _autoCluster() async {
    final unassigned = await widget.library.db.allUnassignedFaces();
    final embeddingsByFaceId = {
      for (final f in unassigned)
        if (f.embedding != null) f.id: floatsFromEmbeddingBlob(f.embedding!),
    };
    if (embeddingsByFaceId.length < 2) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Nicht genug unbenannte Gesichter mit Embedding für ein Clustering.'),
        ));
      }
      return;
    }

    // clusterFaces vergleicht bewusst jedes Gesicht mit jedem (siehe dortiger
    // Kommentar) – bei einer frisch gescannten, noch nie triagierten großen
    // Bibliothek können das leicht mehrere Zehntausend unzugeordnete
    // Gesichter sein, was spürbar dauern kann. Vorher warnen statt den
    // Button scheinbar einfrieren zu lassen.
    if (embeddingsByFaceId.length > 8000) {
      if (!mounted) return;
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Das kann etwas dauern'),
          content: Text(
            '${embeddingsByFaceId.length} unbenannte Gesichter gefunden. Die automatische '
            'Gruppierung vergleicht jedes mit jedem und kann bei so vielen Gesichtern einige '
            'Zeit dauern (die App bleibt währenddessen bedienbar). Trotzdem starten?',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Starten')),
          ],
        ),
      );
      if (proceed != true) return;
    }
    if (!mounted) return;

    final threshold = widget.library.faceSimilarityThreshold;
    final clusters = await compute(clusterFaces, FaceClusterInput(embeddingsByFaceId, threshold));
    if (clusters.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Keine ähnlichen Gruppen gefunden.'),
        ));
      }
      return;
    }

    // Centroid je bereits benannter Person, für den "Ähnlich zu"-Vorschlag.
    final people = await widget.library.db.select(widget.library.db.people).get();
    final personCentroids = <PersonData, Float32List>{};
    for (final person in people) {
      final personFaces = await widget.library.db.facesForPerson(person.id);
      final vectors = [
        for (final f in personFaces)
          if (f.embedding != null) floatsFromEmbeddingBlob(f.embedding!),
      ];
      if (vectors.isNotEmpty) personCentroids[person] = meanNormalizedEmbedding(vectors);
    }

    final faceById = {for (final f in unassigned) f.id: f};
    final suggestions = <FaceClusterSuggestion>[];
    for (final cluster in clusters) {
      final clusterFacesData = [for (final id in cluster) faceById[id]!];
      final centroid = meanNormalizedEmbedding([for (final id in cluster) embeddingsByFaceId[id]!]);
      PersonData? bestMatch;
      var bestSim = 0.0;
      for (final entry in personCentroids.entries) {
        final sim = FaceEngineService.cosineSimilarity(centroid, entry.value);
        if (sim > bestSim) {
          bestSim = sim;
          bestMatch = entry.key;
        }
      }
      suggestions.add(FaceClusterSuggestion(
        faces: clusterFacesData,
        suggestedPerson: bestSim >= threshold ? bestMatch : null,
      ));
    }

    if (!mounted) return;
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => FaceClusterReviewScreen(library: widget.library, suggestions: suggestions),
    ));
    _loadUnassigned();
  }

  Future<void> _openPhotoForFace(FaceData face) async {
    final asset = await widget.library.db.assetById(face.assetId);
    if (asset == null || !mounted) return;
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => FaceReviewScreen(library: widget.library, asset: asset),
    ));
    _loadUnassigned();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(tabs: [Tab(text: 'Personen'), Tab(text: 'Unbenannte Gesichter')]),
          Expanded(
            child: TabBarView(
              children: [
                _PeopleGrid(library: widget.library),
                _UnassignedFacesGrid(
                  faces: _unassignedFaces,
                  paths: widget.library.paths,
                  selected: _selectedFaceIds,
                  autoSelected: _autoSelectedIds,
                  onToggle: (id) => setState(() {
                    _selectedFaceIds.contains(id)
                        ? _selectedFaceIds.remove(id)
                        : _selectedFaceIds.add(id);
                    _autoSelectedIds.remove(id);
                  }),
                  onOpenPhoto: _openPhotoForFace,
                  onSelectSimilar: _toggleSelectSimilar,
                  onAssign: _assignSelection,
                  onAutoCluster: _autoCluster,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PeopleGrid extends StatelessWidget {
  final LibraryState library;
  const _PeopleGrid({required this.library});

  Future<void> _mergeInto(BuildContext context, PersonData source, List<PersonData> all) async {
    final candidates = all.where((p) => p.id != source.id).toList();
    if (candidates.isEmpty) return;
    final target = await showDialog<PersonData>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('"${source.name}" zusammenführen mit …'),
        children: candidates
            .map((p) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, p),
                  child: Text(p.name),
                ))
            .toList(),
      ),
    );
    if (target == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Zusammenführen bestätigen'),
        content: Text(
          'Alle Fotos von "${source.name}" werden "${target.name}" zugeordnet. '
          '"${source.name}" wird danach gelöscht. Das lässt sich nicht rückgängig machen.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Zusammenführen')),
        ],
      ),
    );
    if (confirm == true) {
      await library.db.mergePeople(keepPersonId: target.id, removePersonId: source.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PersonData>>(
      stream: library.db.watchPeople(),
      builder: (context, snapshot) {
        final people = snapshot.data ?? [];
        if (people.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xxl),
              child: Text(
                'Noch keine Personen angelegt. Wechsle zum Tab '
                '"Unbenannte Gesichter", wähle ein paar Gesichter aus und '
                'ordne sie einer neuen Person zu.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 120,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: people.length,
          itemBuilder: (context, index) {
            final person = people[index];
            return InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => PersonDetailScreen(library: library, person: person),
              )),
              onLongPress: () => _mergeInto(context, person, people),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey.shade800,
                    backgroundImage: person.coverFaceCropPath != null
                        ? FileImage(library.paths.absolute(person.coverFaceCropPath!))
                        : null,
                    child: person.coverFaceCropPath == null
                        ? const Icon(Icons.person_outline, size: 32)
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(person.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('lange drücken: zusammenführen',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontSize: 9, color: Theme.of(context).colorScheme.outline)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _UnassignedFacesGrid extends StatelessWidget {
  final List<FaceData> faces;
  final StoragePaths paths;
  final Set<String> selected;
  final Set<String> autoSelected;
  final void Function(String faceId) onToggle;
  final void Function(FaceData face) onOpenPhoto;
  final VoidCallback onSelectSimilar;
  final VoidCallback onAssign;
  final VoidCallback onAutoCluster;

  const _UnassignedFacesGrid({
    required this.faces,
    required this.paths,
    required this.selected,
    required this.autoSelected,
    required this.onToggle,
    required this.onOpenPhoto,
    required this.onSelectSimilar,
    required this.onAssign,
    required this.onAutoCluster,
  });

  @override
  Widget build(BuildContext context) {
    if (faces.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Text(
            'Keine unbenannten Gesichter (mehr). Neue Gesichter erscheinen '
            'hier automatisch, sobald du weitere Fotos importierst.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Ähnlichkeitsschwelle einstellbar unter Werkzeuge → Gesichtserkennung.',
                  style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onAutoCluster,
                icon: const Icon(Icons.group_work_outlined, size: 18),
                label: const Text('Automatisch gruppieren'),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 110,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: faces.length,
            itemBuilder: (context, index) {
              final face = faces[index];
              if (face.cropRelativePath == null) return const SizedBox.shrink();
              final isAuto = autoSelected.contains(face.id);
              return Stack(
                fit: StackFit.expand,
                children: [
                  LocalImageTile(
                    file: paths.absolute(face.cropRelativePath!),
                    selected: selected.contains(face.id),
                    onTap: () => onToggle(face.id),
                    onDoubleTap: () => onOpenPhoto(face),
                  ),
                  if (isAuto)
                    const Positioned(
                      right: 2,
                      top: 2,
                      child: Icon(Icons.auto_awesome, color: Colors.cyanAccent, size: 14),
                    ),
                ],
              );
            },
          ),
        ),
        if (selected.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
            child: Column(
              children: [
                Text(
                  'Doppelklick auf ein Gesicht öffnet das ganze Foto zur Kontrolle.',
                  style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onSelectSimilar,
                        icon: Icon(autoSelected.isNotEmpty ? Icons.remove_done : Icons.auto_awesome_outlined),
                        label: Text(autoSelected.isNotEmpty ? 'Ähnliche abwählen' : 'Ähnliche mit auswählen'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onAssign,
                        icon: const Icon(Icons.person_add_alt_1),
                        label: Text('${selected.length} zuordnen'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
