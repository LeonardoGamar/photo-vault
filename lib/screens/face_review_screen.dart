import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../services/face_engine_service.dart';
import '../state/library_state.dart';
import '../theme/app_spacing.dart';
import '../widgets/person_picker_dialog.dart';

/// Zeigt ein einzelnes Foto in Vollbild mit allen erkannten Gesichtern als
/// Rahmen darüber. Tippen auf einen Rahmen ordnet dieses Gesicht einer
/// Person zu (oder benennt sie um). Im "Gesicht hinzufügen"-Modus kann man
/// zusätzlich per Ziehen einen neuen Rahmen aufziehen, um ein von der
/// automatischen Erkennung übersehenes Gesicht manuell zu markieren und zu
/// benennen.
class FaceReviewScreen extends StatefulWidget {
  final LibraryState library;
  final AssetData asset;
  const FaceReviewScreen({super.key, required this.library, required this.asset});

  @override
  State<FaceReviewScreen> createState() => _FaceReviewScreenState();
}

class _FaceReviewScreenState extends State<FaceReviewScreen> {
  List<FaceData> _faces = [];
  Map<String, String> _personNames = {}; // personId -> Name
  double? _aspectRatio;
  bool _addMode = false;
  Offset? _dragStart;
  Offset? _dragCurrent;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // Redundant zur Sperre in asset_viewer_screen.dart (bisher der einzige
    // Einstiegspunkt, seit heute auch über dessen Kontextmenü erreichbar):
    // schützt auch dann, falls dieser Screen je aus einem anderen Kontext
    // heraus geöffnet würde, bevor die Original-/Vorschau-Datei (noch
    // verschlüsselt) angefasst wird – dasselbe Muster wie DevelopScreen._init.
    if (widget.asset.isLocked) {
      _loading = false;
      return;
    }
    _load();
  }

  /// Datei, die tatsächlich angezeigt/für Crops verwendet wird: die
  /// konvertierte Vorschau, falls das Originalformat (z.B. HEIC/DNG) von
  /// Flutter nicht direkt gerendert werden kann – sonst das Original.
  File get _displayFile =>
      widget.library.paths.absolute(widget.asset.previewRelativePath ?? widget.asset.relativePath);

  Future<void> _load() async {
    setState(() => _loading = true);
    final faces = await widget.library.db.facesForAsset(widget.asset.id);
    final people = await widget.library.db.select(widget.library.db.people).get();

    double? aspect;
    if (widget.asset.widthPx != null && widget.asset.heightPx != null && widget.asset.heightPx! > 0) {
      aspect = widget.asset.widthPx! / widget.asset.heightPx!;
    } else {
      final decoded = img.decodeImage(await _displayFile.readAsBytes());
      if (decoded != null) aspect = decoded.width / decoded.height;
    }

    if (mounted) {
      setState(() {
        _faces = faces;
        _personNames = {for (final p in people) p.id: p.name};
        _aspectRatio = aspect ?? 1.0;
        _loading = false;
      });
    }
  }

  Future<void> _tapFace(FaceData face) async {
    final people = await widget.library.db.select(widget.library.db.people).get();
    if (!mounted) return;
    final currentName = face.personId != null ? _personNames[face.personId] : null;
    final choice = await showPersonPickerDialog(
      context,
      people,
      title: currentName != null
          ? AppTexte.of(context).gesichtUmbenennen
          : AppTexte.of(context).gesichtBenennen,
      currentName: currentName,
    );
    if (choice == null) return;

    String personId;
    if (choice.newName != null) {
      personId = const Uuid().v4();
      await widget.library.db.createPerson(PeopleCompanion.insert(id: personId, name: choice.newName!));
    } else {
      personId = choice.existingPersonId!;
    }
    await widget.library.db.assignFacesToPerson([face.id], personId);
    _load();
  }

  Future<void> _finishManualBox(Rect normalizedRect) async {
    final people = await widget.library.db.select(widget.library.db.people).get();
    if (!mounted) return;
    final choice = await showPersonPickerDialog(context, people, title: AppTexte.of(context).gesichtNeuBenennen);
    if (choice == null) return;

    String personId;
    if (choice.newName != null) {
      personId = const Uuid().v4();
      await widget.library.db.createPerson(PeopleCompanion.insert(id: personId, name: choice.newName!));
    } else {
      personId = choice.existingPersonId!;
    }

    final faceId = const Uuid().v4();
    final box = DetectedFace(normalizedRect.left, normalizedRect.top, normalizedRect.width, normalizedRect.height, 1.0);
    final decoded = img.decodeImage(await _displayFile.readAsBytes());
    if (decoded == null) return;
    final cropFile = widget.library.paths.absolute(widget.library.paths.faceRelativePath(faceId));
    final croppedThumb = FaceEngineService.cropFaceImage(decoded, box);
    await FaceEngineService.saveFaceCrop(croppedThumb, cropFile);

    // Ein Ladefehler (z.B. eine beschädigte Modelldatei) darf den Rest
    // dieser Methode nicht abbrechen: Ohne dieses try/catch würde die
    // Exception hier unbehandelt aus dem Tap-Callback fliegen, während der
    // Crop bereits auf der Platte liegt (siehe oben) – ein verwaistes Foto
    // ohne zugehörigen Faces-Eintrag, ohne jede Fehlermeldung für den
    // Nutzer. Stattdessen wird ein Ladefehler wie "kann nicht einbetten"
    // behandelt: das Gesicht wird trotzdem der Person zugeordnet, nur ohne
    // Wiedererkennungs-Embedding.
    Float32List? embedding;
    try {
      embedding = await widget.library.faceEngineHalter.mit<Float32List?>((engine) {
        return engine.canEmbed ? engine.embedFace(decoded, box) : Future<Float32List?>.value(null);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTexte.of(context).gesichtEmbeddingFehler('$e'))),
        );
      }
    }

    await widget.library.db.insertFace(FacesCompanion.insert(
      id: faceId,
      assetId: widget.asset.id,
      personId: Value(personId),
      boxX: box.x,
      boxY: box.y,
      boxW: box.width,
      boxH: box.height,
      cropRelativePath: Value(widget.library.paths.faceRelativePath(faceId)),
      embedding: embedding != null
          ? Value(Uint8List.view(embedding.buffer, embedding.offsetInBytes, embedding.lengthInBytes))
          : const Value.absent(),
    ));
    await widget.library.db.setPersonCoverIfUnset(
      personId,
      widget.library.paths.faceRelativePath(faceId),
    );

    setState(() {
      _addMode = false;
      _dragStart = null;
      _dragCurrent = null;
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.asset.isLocked) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(widget.asset.originalFileName, overflow: TextOverflow.ellipsis),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Text(
              AppTexte.of(context).gesichtGesperrt,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.asset.originalFileName, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: _addMode ? AppTexte.of(context).gesichtHinzufuegenBeenden : AppTexte.of(context).gesichtManuellHinzufuegen,
            icon: Icon(_addMode ? Icons.close : Icons.add_a_photo_outlined),
            onPressed: () => setState(() {
              _addMode = !_addMode;
              _dragStart = null;
              _dragCurrent = null;
            }),
          ),
        ],
      ),
      body: _loading || _aspectRatio == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: AspectRatio(
                aspectRatio: _aspectRatio!,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    final h = constraints.maxHeight;
                    return GestureDetector(
                      onPanStart: _addMode ? (d) => setState(() {
                            _dragStart = d.localPosition;
                            _dragCurrent = d.localPosition;
                          }) : null,
                      onPanUpdate: _addMode ? (d) => setState(() => _dragCurrent = d.localPosition) : null,
                      onPanEnd: _addMode
                          ? (_) {
                              if (_dragStart == null || _dragCurrent == null) return;
                              final rect = Rect.fromPoints(_dragStart!, _dragCurrent!);
                              if (rect.width < 10 || rect.height < 10) {
                                setState(() {
                                  _dragStart = null;
                                  _dragCurrent = null;
                                });
                                return;
                              }
                              final normalized = Rect.fromLTWH(
                                (rect.left / w).clamp(0.0, 1.0),
                                (rect.top / h).clamp(0.0, 1.0),
                                (rect.width / w).clamp(0.0, 1.0),
                                (rect.height / h).clamp(0.0, 1.0),
                              );
                              _finishManualBox(normalized);
                            }
                          : null,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            _displayFile,
                            fit: BoxFit.fill,
                          ),
                          for (final face in _faces)
                            Positioned(
                              left: face.boxX * w,
                              top: face.boxY * h,
                              width: face.boxW * w,
                              height: face.boxH * h,
                              child: GestureDetector(
                                onTap: () => _tapFace(face),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: face.personId != null ? Colors.greenAccent : Colors.orangeAccent,
                                      width: 2,
                                    ),
                                  ),
                                  alignment: Alignment.bottomLeft,
                                  child: Container(
                                    color: Colors.black54,
                                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
                                    child: Text(
                                      face.personId != null
                                          ? (_personNames[face.personId] ?? '…')
                                          : AppTexte.of(context).gesichtUnbenannt,
                                      style: const TextStyle(color: Colors.white, fontSize: 11),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (_addMode && _dragStart != null && _dragCurrent != null)
                            Positioned.fromRect(
                              rect: Rect.fromPoints(_dragStart!, _dragCurrent!),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.cyanAccent, width: 2),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
      bottomNavigationBar: _addMode
          ? Container(
              color: Colors.black87,
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                AppTexte.of(context).gesichtRechteckHinweis,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            )
          : null,
    );
  }
}
