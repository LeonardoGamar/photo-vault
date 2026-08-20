import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../screens/person_detail_screen.dart';
import '../services/asset_format.dart';
import '../services/storage_paths.dart';
import '../state/library_state.dart';
import '../theme/app_spacing.dart';
import 'color_label_picker.dart';
import 'mini_location_map.dart';
import 'person_picker_dialog.dart';
import 'star_rating.dart';

/// Info-Ansicht für ein einzelnes Asset (Foto/Video) in der Vollbildvorschau
/// – Layout angelehnt an Google Fotos: Zeilen mit Icon, Titel und optionalem
/// Untertext statt Label/Wert-Paaren, randlose Karte am unteren Ende statt
/// eingerahmt. Zeigt Beschreibung, zugeordnete Personen, Aufnahmedatum,
/// Datei-/Kamera-Metadaten, Tags und Ort – vieles davon direkt korrigierbar,
/// z.B. wenn die EXIF-Daten fehlen oder falsch sind, oder für Videos, die
/// grundsätzlich keine EXIF-GPS-Daten haben.
///
/// Ruft [onUpdated] nach jeder Änderung mit dem frisch aus der DB gelesenen
/// Asset auf, damit die aufrufende Vollbildansicht ihre Anzeige (Favorit,
/// Datum im Titel, …) synchron halten kann.
class AssetInfoSheet extends StatefulWidget {
  final AssetData asset;
  final AppDatabase db;
  final StoragePaths paths;
  final void Function(AssetData updated) onUpdated;
  final VoidCallback onClose;

  const AssetInfoSheet({
    super.key,
    required this.asset,
    required this.db,
    required this.paths,
    required this.onUpdated,
    required this.onClose,
  });

  @override
  State<AssetInfoSheet> createState() => _AssetInfoSheetState();
}

/// Eine auf diesem Foto erkannte, benannte Person samt dem Gesichts-Crop
/// AUS DIESEM FOTO (nicht dem globalen Profilbild der Person) – für die
/// Avatar-Reihe in der "Personen"-Sektion.
class _AssetFace {
  final PersonData person;
  final String? cropRelativePath;
  const _AssetFace(this.person, this.cropRelativePath);
}

class _AssetInfoSheetState extends State<AssetInfoSheet> {
  late AssetData _asset = widget.asset;
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.asset.description ?? '');
  late final FocusNode _descriptionFocusNode = FocusNode()..addListener(_onDescriptionFocusChange);
  final TextEditingController _tagController = TextEditingController();
  List<TagData> _tags = [];
  List<_AssetFace> _peopleFaces = [];

  @override
  void initState() {
    super.initState();
    _loadTags();
    _loadPeople();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _descriptionFocusNode.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final updated = await widget.db.assetById(_asset.id);
    if (updated == null || !mounted) return;
    setState(() => _asset = updated);
    widget.onUpdated(updated);
  }

  /// Tags getrennt von [_refresh] geladen, da [AppDatabase.tagsForAsset]
  /// (anders als die restlichen Felder hier) über eine eigene Join-Abfrage
  /// läuft statt Teil der Assets-Zeile zu sein.
  Future<void> _loadTags() async {
    final tags = await widget.db.tagsForAsset(_asset.id);
    if (mounted) setState(() => _tags = tags);
  }

  Future<void> _loadPeople() async {
    final faces = await widget.db.facesForAsset(_asset.id);
    final people = await widget.db.peopleForAsset(_asset.id);
    final peopleById = {for (final p in people) p.id: p};
    final items = <_AssetFace>[];
    final seen = <String>{};
    for (final face in faces) {
      final personId = face.personId;
      if (personId == null) continue;
      final person = peopleById[personId];
      if (person == null || !seen.add(personId)) continue;
      items.add(_AssetFace(person, face.cropRelativePath));
    }
    if (mounted) setState(() => _peopleFaces = items);
  }

  Future<void> _addTag() async {
    final name = _tagController.text.trim();
    if (name.isEmpty) return;
    await widget.db.tagAsset(_asset.id, name);
    _tagController.clear();
    await _loadTags();
  }

  Future<void> _removeTag(TagData tag) async {
    await widget.db.untagAsset(_asset.id, tag.id);
    await _loadTags();
  }

  /// Ordnet das erste noch unbenannte Gesicht dieses Fotos einer (neuen oder
  /// bestehenden) Person zu. Bei mehreren unbenannten Gesichtern auf
  /// demselben Foto (mehrere Personen) lässt sich die Zuordnung durch
  /// erneutes Antippen von "+" fortsetzen.
  Future<void> _addPerson() async {
    final faces = await widget.db.facesForAsset(_asset.id);
    final unassigned = faces.where((f) => f.personId == null && !f.isIgnored).toList();
    if (unassigned.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            AppTexte.of(context).infoKeineUnbenannten,
          ),
        ));
      }
      return;
    }
    final people = await widget.db.select(widget.db.people).get();
    if (!mounted) return;
    final choice = await showPersonPickerDialog(context, people,
        paths: widget.paths, title: AppTexte.of(context).personZuordnenTitel);
    if (choice == null) return;

    String personId;
    if (choice.newName != null) {
      personId = const Uuid().v4();
      await widget.db.createPerson(PeopleCompanion.insert(id: personId, name: choice.newName!));
    } else {
      personId = choice.existingPersonId!;
    }
    await widget.db.assignFacesToPerson([unassigned.first.id], personId);
    await _loadPeople();
  }

  void _onDescriptionFocusChange() {
    if (!_descriptionFocusNode.hasFocus) _saveDescription();
  }

  Future<void> _saveDescription() async {
    if (_descriptionController.text.trim() == (_asset.description ?? '')) return;
    await widget.db.setDescription(_asset.id, _descriptionController.text.trim());
    await _refresh();
  }

  Future<void> _setRating(int rating) async {
    await widget.db.setRating(_asset.id, rating);
    await _refresh();
  }

  Future<void> _setColorLabel(String? colorLabel) async {
    await widget.db.setColorLabel(_asset.id, colorLabel);
    await _refresh();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _asset.fileCreatedAt,
      firstDate: DateTime(1990),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_asset.fileCreatedAt),
    );
    if (!mounted) return;
    final combined = DateTime(
      date.year,
      date.month,
      date.day,
      time?.hour ?? _asset.fileCreatedAt.hour,
      time?.minute ?? _asset.fileCreatedAt.minute,
    );
    await widget.db.setFileCreatedAt(_asset.id, combined);
    await _refresh();
  }

  Future<void> _setLocation(double latitude, double longitude) async {
    await widget.db.setLocation(_asset.id, latitude, longitude);
    await _refresh();
  }

  Future<void> _clearLocation() async {
    await widget.db.setLocation(_asset.id, null, null);
    await _refresh();
  }

  /// Löst eine Serien-Gruppierung wieder auf (siehe StackReviewScreen) – nur
  /// vom Titelbild aus erreichbar, da nur dessen Info-Panel überhaupt
  /// sichtbar ist (die übrigen Mitglieder sind aus der Rasteransicht
  /// ausgeblendet).
  Future<void> _unstack() async {
    final stackId = _asset.stackId;
    if (stackId == null) return;
    await widget.db.unstackAssets(stackId);
    await _refresh();
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDuration(double seconds) {
    final total = seconds.round();
    final m = total ~/ 60;
    final s = total % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String _fileDetailsSubtitle(AssetData asset) {
    final parts = <String>[];
    if (asset.type == 'IMAGE' && asset.widthPx != null && asset.heightPx != null) {
      final megapixels = asset.widthPx! * asset.heightPx! / 1000000;
      if (megapixels >= 0.1) {
        parts.add('${megapixels.toStringAsFixed(megapixels < 10 ? 1 : 0)} MP');
      }
      parts.add('${asset.widthPx} × ${asset.heightPx}');
    }
    if (asset.type == 'VIDEO' && asset.durationSeconds != null) {
      parts.add(_formatDuration(asset.durationSeconds!));
    }
    parts.add(_formatFileSize(asset.fileSizeBytes));
    // Das Formatkürzel (HEIC, DNG, JPG) gehört zu den Angaben, nach denen
    // man in dieser Ansicht sucht – bisher stand es nur als kleines
    // Abzeichen an der Kachel in der Übersicht.
    final format = assetFormatLabel(asset);
    if (format.isNotEmpty) parts.add(format);
    return parts.join('   ');
  }

  @override
  Widget build(BuildContext context) {
    final asset = _asset;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    // Kamera und Aufnahmewerte, aufgeteilt wie in den Informationen von
    // macOS Fotos: oben das Gerät, darunter das Objektiv, darunter die
    // Werte-Zeile. Vorher standen Zeit/ISO in der einen und
    // Blende/Brennweite in einer zweiten Zeile mit eigenem Symbol – wer die
    // Aufnahme beurteilen wollte, musste sie aus zwei Zeilen
    // zusammensuchen, und die Belichtungskorrektur fehlte ganz.
    final kameraTitel = cameraLabel(asset);
    // Nur der Objektivname, ohne die Brennweite noch einmal daneben: An
    // einer echten iPhone-Aufnahme geprüft steht sie im Namen bereits drin
    // („iPhone 13 Pro back triple camera 5.7mm f/1.5"), und in der
    // Werte-Zeile darunter ohnehin.
    final objektiv = asset.lensModel != kameraTitel ? asset.lensModel : null;
    final werte = aufnahmewerte(asset);

    final hasLocation = asset.latitude != null && asset.longitude != null;
    final sprache = Localizations.localeOf(context).toString();

    // Welche Fassung der KI-Bildunterschrift angezeigt wird.
    //
    // Das Beschreibungsmodell liefert ausschliesslich Englisch; die deutsche
    // Fassung steht in einer eigenen Spalte, sobald sie übersetzt wurde
    // (siehe LibraryState.uebersetzeBildbeschreibungen). Bisher zeigte diese
    // Ansicht IMMER das englische Original – die Übersetzung war zwar da und
    // durchsuchbar, aber nirgends zu sehen.
    //
    // Bei englischer Oberfläche bleibt es beim Original: Eine deutsche
    // Bildunterschrift in einer englischen Ansicht wäre kein Dienst.
    final istDeutscheOberflaeche = Localizations.localeOf(context).languageCode == 'de';
    final deutscheBeschreibung = asset.aiCaptionDe?.trim();
    final englischeBeschreibung = asset.aiCaption?.trim();
    final kiBeschreibungIstUebersetzt =
        istDeutscheOberflaeche && (deutscheBeschreibung?.isNotEmpty ?? false);
    final String? kiBeschreibung = kiBeschreibungIstUebersetzt
        ? deutscheBeschreibung
        : ((englischeBeschreibung?.isEmpty ?? true) ? null : englischeBeschreibung);
    final regionParts = [asset.locationState, asset.locationCountry]
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xs, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
          child: Row(
            children: [
              IconButton(icon: const Icon(Icons.close), tooltip: AppTexte.of(context).allgSchliessen, onPressed: widget.onClose),
              const SizedBox(width: 4),
              Text(AppTexte.of(context).infoTitel, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _descriptionController,
                        focusNode: _descriptionFocusNode,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: AppTexte.of(context).infoBeschreibungHinzufuegen,
                          border: const UnderlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      if (kiBeschreibung != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          // Sagt dazu, wenn der Satz englisch bleibt, obwohl
                          // die Oberfläche deutsch ist – sonst sähe es nach
                          // einer vergessenen Übersetzung aus statt nach
                          // einer, die es noch nicht gibt.
                          kiBeschreibungIstUebersetzt
                              ? AppTexte.of(context).infoKiBeschreibung
                              : AppTexte.of(context).infoKiBeschreibungEnglisch,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          kiBeschreibung,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Semantics(
                            container: true,
                            label: AppTexte.of(context).infoBewertung,
                            child: StarRating(value: _asset.rating, onChanged: _setRating),
                          ),
                          const Spacer(),
                          Semantics(
                            container: true,
                            label: AppTexte.of(context).suchoptFarbmarkierung,
                            child: ColorLabelPicker(value: _asset.colorLabel, onChanged: _setColorLabel),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(child: _SectionLabel(AppTexte.of(context).navPersonen)),
                          IconButton(
                            icon: const Icon(Icons.add),
                            tooltip: AppTexte.of(context).personZuordnenTitel,
                            onPressed: _addPerson,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 72,
                        child: _peopleFaces.isEmpty
                            ? Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  AppTexte.of(context).infoNiemandZugeordnet,
                                  style: TextStyle(color: onSurfaceVariant, fontSize: 13),
                                ),
                              )
                            : ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _peopleFaces.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 12),
                                itemBuilder: (context, index) {
                                  final item = _peopleFaces[index];
                                  return GestureDetector(
                                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => PersonDetailScreen(
                                        library: context.read<LibraryState>(),
                                        person: item.person,
                                      ),
                                    )),
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 26,
                                          backgroundColor: Colors.grey.shade800,
                                          backgroundImage: item.cropRelativePath != null
                                              ? FileImage(widget.paths.absolute(item.cropRelativePath!))
                                              : null,
                                          child: item.cropRelativePath == null
                                              ? const Icon(Icons.person_outline)
                                              : null,
                                        ),
                                        const SizedBox(height: 4),
                                        SizedBox(
                                          width: 60,
                                          child: Text(
                                            item.person.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(fontSize: 11),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 16),

                      _SectionLabel(AppTexte.of(context).infoDetails),
                      const SizedBox(height: 4),
                      _IconDetailRow(
                        icon: Icons.calendar_today_outlined,
                        title: DateFormat.yMMMd(sprache).format(asset.fileCreatedAt),
                        subtitle: DateFormat.E(sprache)
                            .addPattern(', ')
                            .add_Hms()
                            .format(asset.fileCreatedAt),
                        onEdit: _pickDate,
                      ),
                      _IconDetailRow(
                        icon: asset.type == 'VIDEO' ? Icons.videocam_outlined : Icons.image_outlined,
                        title: asset.originalFileName,
                        subtitle: _fileDetailsSubtitle(asset),
                      ),
                      if (kameraTitel != null || werte.isNotEmpty)
                        _Aufnahmeblock(
                          kamera: kameraTitel ?? asset.lensModel,
                          objektiv: objektiv,
                          werte: werte,
                        ),
                      if (hasLocation)
                        _IconDetailRow(
                          icon: Icons.location_on_outlined,
                          title: asset.locationCity ?? AppTexte.of(context).infoStandortBekannt,
                          subtitle: asset.locationCity != null
                              ? (regionParts.isEmpty ? null : regionParts.join(', '))
                              : AppTexte.of(context).infoOrtNichtAufgeloest,
                          onEdit: _clearLocation,
                          editIcon: Icons.close,
                          editTooltip: AppTexte.of(context).infoOrtEntfernen,
                        ),
                      if (asset.isStackCover && asset.stackSize != null)
                        _IconDetailRow(
                          icon: Icons.filter_none_outlined,
                          title: AppTexte.of(context).infoSerie(asset.stackSize!),
                          subtitle: AppTexte.of(context).infoNurTitelbild,
                          onEdit: _unstack,
                          editIcon: Icons.close,
                          editTooltip: AppTexte.of(context).infoSerieAufloesen,
                        ),
                      const SizedBox(height: 16),

                      _SectionLabel(AppTexte.of(context).suchoptTagsTitel),
                      const SizedBox(height: 8),
                      if (_tags.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final tag in _tags)
                                InputChip(
                                  label: Text(tag.name),
                                  onDeleted: () => _removeTag(tag),
                                ),
                            ],
                          ),
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _tagController,
                              decoration: InputDecoration(
                                hintText: AppTexte.of(context).infoTagHinzufuegenPlatzhalter,
                                isDense: true,
                                border: const OutlineInputBorder(),
                              ),
                              onSubmitted: (_) => _addTag(),
                            ),
                          ),
                          IconButton(icon: const Icon(Icons.add), tooltip: AppTexte.of(context).auswTagHinzufuegen, onPressed: _addTag),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                MiniLocationMap(
                  latitude: asset.latitude,
                  longitude: asset.longitude,
                  onLocationChanged: _setLocation,
                  height: 200,
                  borderRadius: BorderRadius.zero,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .labelMedium
          ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
    );
  }
}

/// Eine Detailzeile im Google-Fotos-Stil: Icon links, Titel + optionaler
/// grauer Untertext in der Mitte, optionales Icon-Button-Symbol rechts
/// (z.B. Stift zum Bearbeiten oder "X" zum Entfernen).
class _IconDetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onEdit;
  final IconData editIcon;
  final String? editTooltip;

  const _IconDetailRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onEdit,
    this.editIcon = Icons.edit_outlined,
    this.editTooltip,
  });

  @override
  Widget build(BuildContext context) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 20, color: onSurfaceVariant),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: TextStyle(fontSize: 12, color: onSurfaceVariant)),
                ],
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              icon: Icon(editIcon, size: 18),
              tooltip: editTooltip ?? AppTexte.of(context).allgBearbeiten,
              visualDensity: VisualDensity.compact,
              onPressed: onEdit,
            ),
        ],
      ),
    );
  }
}

/// Kamera, Objektiv und die Aufnahmewerte als ein Block – dieselbe
/// Gliederung wie in den Informationen von macOS Fotos.
///
/// Die Werte-Zeile bricht um, statt abgeschnitten zu werden: Das Bedienfeld
/// ist schmal, und fünf Werte nebeneinander passen darin nicht immer. Eine
/// abgeschnittene Verschlusszeit wäre schlimmer als eine zweite Zeile.
class _Aufnahmeblock extends StatelessWidget {
  final String? kamera;
  final String? objektiv;
  final List<String> werte;

  const _Aufnahmeblock({required this.kamera, required this.objektiv, required this.werte});

  @override
  Widget build(BuildContext context) {
    final farben = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(Icons.camera_alt_outlined, size: 20, color: farben.onSurfaceVariant),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (kamera != null) Text(kamera!),
                if (objektiv != null) ...[
                  const SizedBox(height: 2),
                  Text(objektiv!,
                      style: TextStyle(fontSize: 12, color: farben.onSurfaceVariant)),
                ],
                if (werte.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: farben.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 4,
                      children: [
                        for (final wert in werte)
                          Text(
                            wert,
                            style: TextStyle(
                              fontSize: 12,
                              color: farben.onSurfaceVariant,
                              // Damit die Werte zweier Fotos untereinander
                              // fluchten, wenn man durch die Bibliothek geht.
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
