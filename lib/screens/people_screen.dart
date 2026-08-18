import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../l10n/app_localizations.dart';
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
/// Die Reihe der Fotos, durch die sich aus einem Gesichts-Raster heraus
/// blättern lässt – in der Reihenfolge des Rasters, jedes Foto einmal.
///
/// Ausgelagert, weil sich hier zwei Fehler verstecken können, die man am
/// fertigen Bildschirm erst nach dem dritten Klick bemerkt: eine verlorene
/// Reihenfolge (die Pfeiltaste springt scheinbar wahllos) und doppelte
/// Einträge. Doppelte entstehen von allein: Auf einem Gruppenfoto liegen
/// mehrere unbenannte Gesichter, und ohne diesen Schritt stünde dasselbe
/// Foto drei Mal hintereinander in der Reihe.
@visibleForTesting
List<String> assetReiheFuerGesichter(List<FaceData> gesichter) {
  final gesehen = <String>{};
  return [
    for (final f in gesichter)
      if (gesehen.add(f.assetId)) f.assetId,
  ];
}

class PeopleScreen extends StatefulWidget {
  final LibraryState library;
  const PeopleScreen({super.key, required this.library});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  final Set<String> _selectedFaceIds = {};
  final Set<String> _autoSelectedIds = {}; // von "Ähnliche mit auswählen" hinzugefügt

  /// Die Ähnlichkeit, mit der ein Gesicht automatisch mit ausgewählt wurde.
  ///
  /// Ohne sie liesse sich später nichts lernen: Dass der Nutzer ein
  /// vorgeschlagenes Gesicht behalten oder wieder abgewählt hat, sagt erst
  /// dann etwas aus, wenn man weiss, bei welchem Wert die Erkennung
  /// zugegriffen hatte.
  final Map<String, double> _autoAehnlichkeit = {};
  List<FaceData> _unassignedFaces = [];

  /// Beiseitegelegte Gesichter und ihre Gesamtzahl. Die Zahl wird getrennt
  /// gezählt, weil die Liste bei 200 gedeckelt ist – ohne sie stünde am Tab
  /// „200", egal ob dort 200 oder 4000 Gesichter liegen.
  List<FaceData> _ignorierteFaces = [];
  int _ignorierteAnzahl = 0;
  final Set<String> _ausgewaehlteIgnorierte = {};

  @override
  void initState() {
    super.initState();
    _neuLaden();
  }

  Future<void> _neuLaden() async {
    final faces = await widget.library.db.unassignedFaces();
    final ignoriert = await widget.library.db.ignoredFaces();
    final anzahl = await widget.library.db.ignoredFacesCount();
    if (mounted) {
      setState(() {
        _unassignedFaces = faces;
        _ignorierteFaces = ignoriert;
        _ignorierteAnzahl = anzahl;
        _ausgewaehlteIgnorierte.removeWhere(
            (id) => !ignoriert.any((f) => f.id == id));
      });
    }
  }

  /// Legt die ausgewählten Gesichter beiseite.
  ///
  /// Ohne Rückfrage, aber mit Rückgängig: Ein Dialog für eine Handlung, die
  /// nichts löscht und einen eigenen Tab zum Zurückholen hat, wäre nur im
  /// Weg – gerade weil man beim Aussortieren von Fehlerkennungen viele
  /// hintereinander wegräumt.
  Future<void> _ignoriereAuswahl() async {
    if (_selectedFaceIds.isEmpty) return;
    final betroffen = _selectedFaceIds.toList();
    await widget.library.db.setFacesIgnored(betroffen, true);
    if (!mounted) return;
    setState(() {
      _selectedFaceIds.clear();
      _autoSelectedIds.clear();
      _autoAehnlichkeit.clear();
    });
    await _neuLaden();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(AppTexte.of(context).personenIgnoriertMeldung(betroffen.length)),
      action: SnackBarAction(
        label: AppTexte.of(context).allgRueckgaengig,
        onPressed: () async {
          await widget.library.db.setFacesIgnored(betroffen, false);
          await _neuLaden();
        },
      ),
    ));
  }

  /// Das Kontextmenü der Gesichts-Raster (Rechtsklick).
  ///
  /// Beide Einträge sind Massenaktionen für den Fall, dass die Erkennung
  /// überwiegend Unbrauchbares gefunden hat. Der Gedanke dahinter: erst
  /// alles wegräumen, dann in Ruhe die wenigen Gesichter herausholen, die
  /// man wirklich benennen will.
  Future<void> _kontextmenue(Offset position) async {
    final t = AppTexte.of(context);
    final offen = await widget.library.db.unassignedFacesCount();
    if (!mounted) return;

    final wo = Overlay.of(context).context.findRenderObject() as RenderBox;
    final wahl = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(position & Size.zero, Offset.zero & wo.size),
      items: [
        PopupMenuItem(
          value: 'ignorieren',
          enabled: offen > 0,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.visibility_off_outlined),
            title: Text(t.personenAlleIgnorieren),
            subtitle: Text(t.personenAlleIgnorierenHinweis(offen)),
          ),
        ),
        PopupMenuItem(
          value: 'loeschen',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.delete_outline),
            title: Text(t.personenAlleErkennungenLoeschen),
            subtitle: Text(t.personenAlleErkennungenLoeschenHinweis),
          ),
        ),
      ],
    );
    if (!mounted || wahl == null) return;
    if (wahl == 'ignorieren') return _alleIgnorieren();
    return _alleErkennungenLoeschen();
  }

  Future<void> _alleIgnorieren() async {
    final anzahl = await widget.library.db.ignoriereAlleUnbenannten();
    if (!mounted) return;
    setState(() {
      _selectedFaceIds.clear();
      _autoSelectedIds.clear();
      _autoAehnlichkeit.clear();
    });
    await _neuLaden();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(AppTexte.of(context).personenAlleIgnoriertMeldung(anzahl)),
    ));
  }

  Future<void> _alleErkennungenLoeschen() async {
    final t = AppTexte.of(context);
    final ja = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(t.personenErkennungenLoeschenTitel),
        // Der Text nennt ausdrücklich, dass Löschen NICHT dauerhaft ist:
        // Der nächste Scan findet dieselben Stellen wieder. Wer die
        // Erkennungen loswerden will, ist mit dem Beiseitelegen besser
        // bedient – das steht hier, weil man es sonst erst nach dem
        // nächsten Scan merkt.
        content: Text(t.personenErkennungenLoeschenText),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialog, false),
              child: Text(t.allgAbbrechen)),
          FilledButton(
              onPressed: () => Navigator.pop(dialog, true),
              child: Text(t.allgLoeschen)),
        ],
      ),
    );
    if (ja != true) return;

    final anzahl = await widget.library.loescheAlleUnbenanntenErkennungen();
    if (!mounted) return;
    setState(() {
      _selectedFaceIds.clear();
      _autoSelectedIds.clear();
      _autoAehnlichkeit.clear();
    });
    await _neuLaden();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(AppTexte.of(context).personenErkennungenGeloeschtMeldung(anzahl)),
    ));
  }

  Future<void> _holeZurueck() async {
    if (_ausgewaehlteIgnorierte.isEmpty) return;
    await widget.library.db.setFacesIgnored(_ausgewaehlteIgnorierte.toList(), false);
    if (!mounted) return;
    setState(_ausgewaehlteIgnorierte.clear);
    await _neuLaden();
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
        // Ein Toggle ist kein Urteil über die einzelnen Gesichter, sondern
        // ein Rückgängigmachen der ganzen Aktion – dabei ist nichts zu
        // lernen.
        _autoAehnlichkeit.clear();
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              AppTexte.of(context).personenModellFehlt),
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
          _autoAehnlichkeit[face.id] = bestSim;
        }
      }
      _autoSelectedIds.addAll(newlyAdded);
    });

    if (newlyAdded.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppTexte.of(context).personenKeineAehnlichen(
            widget.library.faceSimilarityThreshold.toStringAsFixed(2))),
      ));
    }
  }

  Future<void> _assignSelection() async {
    if (_selectedFaceIds.isEmpty) return;
    final people = await widget.library.db.select(widget.library.db.people).get();
    if (!mounted) return;

    final choice = await showPersonPickerDialog(context, people,
        paths: widget.library.paths,
        title: AppTexte.of(context).personenZuordnen(_selectedFaceIds.length));
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

    // Was "Ähnliche mit auswählen" vorgeschlagen hat, ist damit beurteilt:
    // noch ausgewählt heisst bestätigt, wieder abgewählt heisst abgelehnt.
    // Beides steht schon in der Oberfläche – es wurde bisher nur nicht
    // ausgewertet, weshalb beim nächsten Lauf derselbe Fehlvorschlag kam.
    final entscheidungen = [
      for (final e in _autoAehnlichkeit.entries)
        (
          faceId: e.key,
          accepted: _selectedFaceIds.contains(e.key),
          similarity: e.value,
        ),
    ];
    if (entscheidungen.isNotEmpty) {
      await widget.library.db.merkeGesichtsEntscheidungen(
        personId,
        entscheidungen,
        allgemeineSchwelle: widget.library.faceSimilarityThreshold,
      );
    }

    if (!mounted) return;
    setState(() {
      _selectedFaceIds.clear();
      _autoSelectedIds.clear();
      _autoAehnlichkeit.clear();
    });
    _neuLaden();
  }

  /// Gruppiert alle unzugeordneten Gesichter automatisch (siehe
  /// face_clustering_service.dart) und öffnet die Review-Ansicht zur
  /// Bestätigung – bewusst kein stilles Auto-Zuordnen, siehe
  /// FaceClusterReviewScreen.
  ///
  /// Der Lauf zeigt seinen Fortschritt und lässt sich abbrechen. Vorher gab
  /// es dafür nur eine Warnung vorab und danach nichts mehr: Bei mehreren
  /// Zehntausend Gesichtern lief die Vergleichsphase minutenlang, ohne dass
  /// erkennbar war, ob sie überhaupt vorankommt.
  Future<void> _autoCluster() async {
    final stand = ValueNotifier<_ClusterStand>(const _ClusterStand(_Phase.laden, null));
    var abgebrochen = false;
    FaceClusterLauf? lauf;

    void dialogZeigen() {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogKontext) => PopScope(
          // Die Escape-Taste würde den Dialog schliessen, den Lauf aber
          // weiterlaufen lassen – ein unsichtbarer Isolat, der eine Minute
          // lang einen Kern belegt.
          canPop: false,
          child: AlertDialog(
            title: Text(AppTexte.of(dialogKontext).personenAutomatischGruppieren),
            content: ValueListenableBuilder<_ClusterStand>(
              valueListenable: stand,
              builder: (kontext, wert, _) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(switch (wert.phase) {
                    _Phase.laden => AppTexte.of(kontext).clusterPhaseLaden,
                    _Phase.vergleichen => AppTexte.of(kontext).clusterPhaseVergleichen,
                    _Phase.vorschlaege => AppTexte.of(kontext).clusterPhaseVorschlaege,
                  }),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: wert.anteil),
                  const SizedBox(height: 8),
                  Text(
                    wert.anteil == null
                        ? AppTexte.of(kontext).clusterOhneProzent
                        : '${(wert.anteil! * 100).round()} %',
                    style: Theme.of(kontext).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  abgebrochen = true;
                  lauf?.abbrechen();
                  Navigator.of(dialogKontext).pop();
                },
                child: Text(AppTexte.of(dialogKontext).allgAbbrechen),
              ),
            ],
          ),
        ),
      );
    }

    final navigator = Navigator.of(context);
    var dialogOffen = false;
    void dialogSchliessen() {
      if (dialogOffen && !abgebrochen) {
        dialogOffen = false;
        navigator.pop();
      }
    }

    final unassigned = await widget.library.db.allUnassignedFaces();
    final embeddingsByFaceId = {
      for (final f in unassigned)
        if (f.embedding != null) f.id: floatsFromEmbeddingBlob(f.embedding!),
    };
    if (embeddingsByFaceId.length < 2) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppTexte.of(context).personenZuWenigeFuerClustering),
        ));
      }
      stand.dispose();
      return;
    }

    // clusterFaces vergleicht bewusst jedes Gesicht mit jedem (siehe dortiger
    // Kommentar) – bei einer frisch gescannten, noch nie triagierten großen
    // Bibliothek können das leicht mehrere Zehntausend unzugeordnete
    // Gesichter sein, was spürbar dauern kann. Vorher warnen, damit die
    // Entscheidung vor dem Warten fällt und nicht mittendrin.
    if (embeddingsByFaceId.length > 8000) {
      if (!mounted) {
        stand.dispose();
        return;
      }
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppTexte.of(context).personenDauertTitel),
          content: Text(
              AppTexte.of(context).personenDauertText(embeddingsByFaceId.length)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppTexte.of(context).allgAbbrechen)),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(AppTexte.of(context).allgStarten)),
          ],
        ),
      );
      if (proceed != true) {
        stand.dispose();
        return;
      }
    }
    if (!mounted) {
      stand.dispose();
      return;
    }

    dialogOffen = true;
    dialogZeigen();

    final threshold = widget.library.faceSimilarityThreshold;
    stand.value = const _ClusterStand(_Phase.vergleichen, 0);

    List<List<String>>? clusters;
    try {
      lauf = await starteFaceClustering(
        embeddingsByFaceId,
        threshold,
        beiFortschritt: (anteil) =>
            stand.value = _ClusterStand(_Phase.vergleichen, anteil),
      );
      clusters = await lauf.ergebnis;
    } catch (e) {
      dialogSchliessen();
      stand.dispose();
      if (mounted) {
        final grund = e is FaceClusterFehler ? e.meldung : '$e';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(grund == null
              ? AppTexte.of(context).clusterUnerwartetBeendet
              : AppTexte.of(context).clusterFehlgeschlagen(grund)),
        ));
      }
      return;
    }

    if (abgebrochen || clusters == null) {
      stand.dispose();
      return;
    }
    if (clusters.isEmpty) {
      dialogSchliessen();
      stand.dispose();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppTexte.of(context).personenKeineGruppen),
        ));
      }
      return;
    }

    // Centroid je bereits benannter Person, für den "Ähnlich zu"-Vorschlag.
    // Eine Abfrage pro Person – bei vielen Personen dauert auch das, deshalb
    // eine eigene Phase statt eines stillen Nachlaufs bei 100 %.
    stand.value = const _ClusterStand(_Phase.vorschlaege, 0);
    final people = await widget.library.db.select(widget.library.db.people).get();
    final personCentroids = <PersonData, Float32List>{};
    for (var i = 0; i < people.length; i++) {
      if (abgebrochen) {
        stand.dispose();
        return;
      }
      final person = people[i];
      final personFaces = await widget.library.db.facesForPerson(person.id);
      final vectors = [
        for (final f in personFaces)
          if (f.embedding != null) floatsFromEmbeddingBlob(f.embedding!),
      ];
      if (vectors.isNotEmpty) personCentroids[person] = meanNormalizedEmbedding(vectors);
      stand.value = _ClusterStand(_Phase.vorschlaege, (i + 1) / people.length);
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
      // Die persönliche Schwelle der jeweils ähnlichsten Person, nicht die
      // allgemeine: Genau darin steckt das Gelernte – wer bisher zu oft
      // fälschlich vorgeschlagen wurde, braucht jetzt mehr Ähnlichkeit.
      final personenSchwelle =
          bestMatch == null ? threshold : widget.library.schwelleFuerPerson(bestMatch);
      final trifft = bestMatch != null && bestSim >= personenSchwelle;
      suggestions.add(FaceClusterSuggestion(
        faces: clusterFacesData,
        suggestedPerson: trifft ? bestMatch : null,
        similarity: trifft ? bestSim : null,
      ));
    }

    dialogSchliessen();
    stand.dispose();
    if (abgebrochen || !mounted) return;
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => FaceClusterReviewScreen(library: widget.library, suggestions: suggestions),
    ));
    _neuLaden();
  }

  /// Öffnet das Foto zu [face] – und gibt der Vorschau gleich die ganze
  /// Reihe mit, damit sich von dort per Pfeiltaste weiterblättern lässt.
  ///
  /// Die Reihe sind die Fotos aller Gesichter des Rasters, in dessen
  /// Reihenfolge. Doppelte fallen weg: Auf einem Gruppenfoto liegen mehrere
  /// unbenannte Gesichter, und dasselbe Foto dreimal hintereinander
  /// durchzublättern wäre unbrauchbar.
  Future<void> _openPhotoForFace(FaceData face, List<FaceData> reihe) async {
    final assetIds = assetReiheFuerGesichter(reihe);
    final assets = await widget.library.db.assetsByIds(assetIds);
    if (assets.isEmpty || !mounted) return;
    final start = assets.indexWhere((a) => a.id == face.assetId);
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => FaceReviewScreen(
        library: widget.library,
        assets: assets,
        startIndex: start < 0 ? 0 : start,
      ),
    ));
    _neuLaden();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(tabs: [
            Tab(text: AppTexte.of(context).personenTab),
            Tab(text: AppTexte.of(context).personenUnbenannteTab),
            Tab(
              // Die Zahl nur, wenn dort etwas liegt: Ein „(0)" am Tab wäre
              // eine dauerhafte Beschriftung für einen Sonderfall.
              text: _ignorierteAnzahl > 0
                  ? AppTexte.of(context).personenIgnoriertTabMitZahl(_ignorierteAnzahl)
                  : AppTexte.of(context).personenIgnoriertTab,
            ),
          ]),
          Expanded(
            child: TabBarView(
              children: [
                _PeopleGrid(library: widget.library),
                _UnassignedFacesGrid(
                  onKontextmenue: _kontextmenue,
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
                  onOpenPhoto: (face) => _openPhotoForFace(face, _unassignedFaces),
                  onSelectSimilar: _toggleSelectSimilar,
                  onAssign: _assignSelection,
                  onIgnore: _ignoriereAuswahl,
                  onAutoCluster: _autoCluster,
                ),
                _IgnorierteGesichter(
                  onKontextmenue: _kontextmenue,
                  faces: _ignorierteFaces,
                  gesamt: _ignorierteAnzahl,
                  paths: widget.library.paths,
                  selected: _ausgewaehlteIgnorierte,
                  onToggle: (id) => setState(() {
                    _ausgewaehlteIgnorierte.contains(id)
                        ? _ausgewaehlteIgnorierte.remove(id)
                        : _ausgewaehlteIgnorierte.add(id);
                  }),
                  onOpenPhoto: (face) => _openPhotoForFace(face, _ignorierteFaces),
                  onRestore: _holeZurueck,
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
        title: Text(AppTexte.of(context).personenZusammenfuehrenMit(source.name)),
        children: candidates
            .map((p) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, p),
                  child: Text(p.name),
                ))
            .toList(),
      ),
    );
    if (target == null || !context.mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppTexte.of(context).personenZusammenfuehrenTitel),
        content: Text(AppTexte.of(context)
            .personenZusammenfuehrenText(source.name, target.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppTexte.of(context).allgAbbrechen)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(AppTexte.of(context).personenZusammenfuehren)),
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
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Text(
                AppTexte.of(context).personenLeer,
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
            // 0.8 war zu knapp: Avatar (80px) + Name + zweizeiliger
            // Hinweistext liefen unten um wenige Pixel über.
            childAspectRatio: 0.66,
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
                  // maxLines/ellipsis verhindern, dass ein langer Hinweis die
                  // Kachelhöhe sprengt (siehe childAspectRatio oben).
                  Text(AppTexte.of(context).personenLangeDruecken,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
  /// Rechtsklick irgendwo im Raster – die Massenaktionen.
  final void Function(Offset position) onKontextmenue;
  final List<FaceData> faces;
  final StoragePaths paths;
  final Set<String> selected;
  final Set<String> autoSelected;
  final void Function(String faceId) onToggle;
  final void Function(FaceData face) onOpenPhoto;
  final VoidCallback onSelectSimilar;
  final VoidCallback onAssign;
  final VoidCallback onIgnore;
  final VoidCallback onAutoCluster;

  const _UnassignedFacesGrid({
    required this.onKontextmenue,
    required this.faces,
    required this.paths,
    required this.selected,
    required this.autoSelected,
    required this.onToggle,
    required this.onOpenPhoto,
    required this.onSelectSimilar,
    required this.onAssign,
    required this.onIgnore,
    required this.onAutoCluster,
  });

  @override
  Widget build(BuildContext context) {
    // Der Rechtsklick gilt für das ganze Raster, auch für die leere
    // Fläche und den leeren Zustand: „Alle Erkennungen löschen" ist gerade
    // dann gefragt, wenn im Raster nichts Brauchbares mehr steht.
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onSecondaryTapDown: (d) => onKontextmenue(d.globalPosition),
      child: _inhalt(context),
    );
  }

  Widget _inhalt(BuildContext context) {
    if (faces.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Text(
            AppTexte.of(context).personenKeineUnbenannten,
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
                  AppTexte.of(context).personenSchwellenHinweis,
                  style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onAutoCluster,
                icon: const Icon(Icons.group_work_outlined, size: 18),
                label: Text(AppTexte.of(context).personenAutomatischGruppieren),
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
                  AppTexte.of(context).personenDoppelklickHinweis,
                  style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onSelectSimilar,
                        icon: Icon(autoSelected.isNotEmpty ? Icons.remove_done : Icons.auto_awesome_outlined),
                        label: Text(autoSelected.isNotEmpty ? AppTexte.of(context).personenAehnlicheAbwaehlen : AppTexte.of(context).personenAehnlicheAuswaehlen),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Als Symbol, nicht als dritte gleichbreite Schaltfläche:
                    // Beiseitelegen ist die seltenere Handlung, und drei
                    // gleich grosse Knöpfe nebeneinander liessen den
                    // eigentlichen – Zuordnen – nicht mehr hervorstechen.
                    IconButton(
                      tooltip: AppTexte.of(context).personenIgnorierenTooltip,
                      icon: const Icon(Icons.visibility_off_outlined),
                      onPressed: onIgnore,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onAssign,
                        icon: const Icon(Icons.person_add_alt_1),
                        label: Text(AppTexte.of(context).personenZuordnenKnopf(selected.length)),
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

/// Der Tab „Ignoriert": alles, was beiseitegelegt wurde, mit dem Weg
/// zurück.
///
/// Ohne diesen Tab wäre das Beiseitelegen eine Einbahnstrasse – ein
/// versehentlich weggeräumtes Gesicht wäre nirgends mehr zu finden, weil es
/// aus dem Raster und aus der Gruppierung zugleich verschwindet.
class _IgnorierteGesichter extends StatelessWidget {
  final void Function(Offset position) onKontextmenue;
  final List<FaceData> faces;
  final int gesamt;
  final StoragePaths paths;
  final Set<String> selected;
  final void Function(String faceId) onToggle;
  final void Function(FaceData face) onOpenPhoto;
  final VoidCallback onRestore;

  const _IgnorierteGesichter({
    required this.onKontextmenue,
    required this.faces,
    required this.gesamt,
    required this.paths,
    required this.selected,
    required this.onToggle,
    required this.onOpenPhoto,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    // Der Rechtsklick gilt für das ganze Raster, auch für die leere
    // Fläche und den leeren Zustand: „Alle Erkennungen löschen" ist gerade
    // dann gefragt, wenn im Raster nichts Brauchbares mehr steht.
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onSecondaryTapDown: (d) => onKontextmenue(d.globalPosition),
      child: _inhalt(context),
    );
  }

  Widget _inhalt(BuildContext context) {
    if (faces.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Text(
            AppTexte.of(context).personenIgnoriertLeer,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
          child: Text(
            // Sagt beides: wofür der Tab da ist und – falls gedeckelt –
            // dass hier nicht alles zu sehen ist.
            gesamt > faces.length
                ? AppTexte.of(context).personenIgnoriertTeilHinweis(faces.length, gesamt)
                : AppTexte.of(context).personenIgnoriertHinweis,
            style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline),
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
              return Opacity(
                // Abgeblendet: Diese Gesichter zählen gerade nicht mit, und
                // das soll man sehen, ohne die Beschriftung zu lesen.
                opacity: selected.contains(face.id) ? 1.0 : 0.55,
                child: LocalImageTile(
                  file: paths.absolute(face.cropRelativePath!),
                  selected: selected.contains(face.id),
                  onTap: () => onToggle(face.id),
                  onDoubleTap: () => onOpenPhoto(face),
                ),
              );
            },
          ),
        ),
        if (selected.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onRestore,
                icon: const Icon(Icons.visibility_outlined),
                label: Text(AppTexte.of(context).personenZurueckholenKnopf(selected.length)),
              ),
            ),
          ),
      ],
    );
  }
}

/// Woran der Gruppierungslauf gerade arbeitet.
enum _Phase { laden, vergleichen, vorschlaege }

/// Ein Stand des Laufs. [anteil] `null` heisst „nicht bezifferbar" – dann
/// zeigt der Balken die unbestimmte Animation statt einer erfundenen Zahl.
class _ClusterStand {
  final _Phase phase;
  final double? anteil;
  const _ClusterStand(this.phase, this.anteil);
}
