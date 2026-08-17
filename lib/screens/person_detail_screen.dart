import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

import '../db/database.dart';
import '../services/face_threshold.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppTexte.of(context).personKeineGesichter),
        ));
      }
      return;
    }
    if (!context.mounted) return;
    final chosen = await showDialog<FaceData>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppTexte.of(context).personProfilbildWaehlen),
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
          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppTexte.of(context).allgAbbrechen)),
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
                    label: Text(AppTexte.of(context).personProfilbildAendern),
                  ),
                ),
              ],
            ),
          ),
          _ErkennungsStand(library: library, person: person),
          Expanded(
            child: StreamBuilder<List<AssetData>>(
              stream: library.db.watchAssetsForPerson(person.id),
              builder: (context, snapshot) {
                final assets = snapshot.data ?? [];
                if (assets.isEmpty) {
                  return Center(child: Text(AppTexte.of(context).personKeineFotos));
                }
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: Text(
                        AppTexte.of(context).personDoppelklickHinweis,
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
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

/// Zeigt im Klartext, nach welcher Schwelle diese Person wiedererkannt wird
/// und warum.
///
/// Eine Schwelle, die sich hinter dem Rücken des Nutzers verstellt, wäre in
/// einem Programm unangebracht, das KI-Schritte sonst durchgehend auslösen
/// UND bestätigen lässt. Deshalb steht hier nicht nur die Zahl, sondern
/// auch, woraus sie stammt – und ein Weg zurück.
class _ErkennungsStand extends StatefulWidget {
  final LibraryState library;
  final PersonData person;

  const _ErkennungsStand({required this.library, required this.person});

  @override
  State<_ErkennungsStand> createState() => _ErkennungsStandState();
}

class _ErkennungsStandState extends State<_ErkennungsStand> {
  List<GesichtsRueckmeldung>? _rueckmeldungen;

  @override
  void initState() {
    super.initState();
    _lade();
  }

  Future<void> _lade() async {
    final r = await widget.library.db.gesichtsRueckmeldungen(widget.person.id);
    if (mounted) setState(() => _rueckmeldungen = r);
  }

  Future<void> _vergessen() async {
    await widget.library.db.vergissGesichtsEntscheidungen(widget.person.id);
    await _lade();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppTexte.of(context).personGelerntesVerworfen),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final rueckmeldungen = _rueckmeldungen;
    if (rueckmeldungen == null || rueckmeldungen.isEmpty) return const SizedBox.shrink();

    final allgemein = widget.library.faceSimilarityThreshold;
    final schwelle = leiteSchwelleAb(rueckmeldungen, allgemein);
    final woher = herkunft(rueckmeldungen, allgemein);
    final bestaetigt = rueckmeldungen.where((r) => r.bestaetigt).length;
    final abgelehnt = rueckmeldungen.length - bestaetigt;

    final t = AppTexte.of(context);
    final erklaerung = switch (woher) {
      SchwellenHerkunft.angepasst => t.personSchwelleAngepasst(
          schwelle.toStringAsFixed(2), allgemein.toStringAsFixed(2)),
      SchwellenHerkunft.widerspruch =>
        t.personSchwelleWiderspruch(allgemein.toStringAsFixed(2)),
      SchwellenHerkunft.zuWenigDaten =>
        t.personSchwelleWirdAngepasst(mindestEntscheidungen),
      SchwellenHerkunft.wieAllgemein =>
        t.personSchwelleWieAllgemein(allgemein.toStringAsFixed(2)),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            woher == SchwellenHerkunft.angepasst
                ? Icons.auto_awesome_outlined
                : Icons.info_outline,
            size: 16,
            color: Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              t.personWiedererkennung(erklaerung, bestaetigt, abgelehnt),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: _vergessen,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(AppTexte.of(context).personVerwerfen, style: const TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
