import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../db/database.dart';
import '../services/blur_detection.dart';
import '../services/search_filters.dart';
import '../state/library_state.dart';
import '../theme/app_spacing.dart';
import 'color_label_picker.dart';
import 'star_rating.dart';

/// Panel mit allen kombinierbaren Suchfiltern (Personen, Text-Suche, Tags,
/// Kamera, Zeitraum, Medientyp, Anzeigeoptionen) – analog zu Immichs
/// "Suchoptionen". Wird als Bottom Sheet geöffnet und gibt bei "Suche" die
/// zusammengestellten [SearchFilters] über `Navigator.pop` zurück, bei
/// Abbruch `null`.
class SearchOptionsSheet extends StatefulWidget {
  final LibraryState library;
  final SearchFilters initialFilters;
  const SearchOptionsSheet({super.key, required this.library, required this.initialFilters});

  @override
  State<SearchOptionsSheet> createState() => _SearchOptionsSheetState();
}

class _SearchOptionsSheetState extends State<SearchOptionsSheet> {
  late Set<String> _personIds;
  late SearchTextMode _textMode;
  late final TextEditingController _queryController;
  late Set<String> _tagIds;
  late bool _noTag;
  String? _cameraMake;
  String? _cameraModel;
  String? _lensModel;
  String? _locationCountry;
  String? _locationState;
  String? _locationCity;
  DateTime? _startDate;
  DateTime? _endDate;
  late MediaTypeFilter _mediaType;
  late bool _favoritesOnly;
  late bool _notInAnyAlbum;
  int? _minRating;
  late Set<String> _colorLabels;
  late final TextEditingController _minIsoController;
  late final TextEditingController _maxIsoController;
  late final TextEditingController _minFNumberController;
  late final TextEditingController _maxFNumberController;
  late final TextEditingController _minFocalLengthController;
  late final TextEditingController _maxFocalLengthController;

  /// UI-Vereinfachung von [SearchFilters.maxSharpnessScore]: statt eines
  /// frei einstellbaren Schwellenwerts nur ein Ja/Nein-Filter mit festem
  /// Richtwert ([blurryScoreThreshold]) – ein manuell eingestellter
  /// Zahlenwert wäre für die meisten Nutzer ohne Kontext zum Score kaum
  /// sinnvoll bedienbar.
  bool _blurryOnly = false;

  final _peopleFilterController = TextEditingController();
  String _peopleFilterText = '';

  /// Siehe [_refreshResultCountIfNeeded].
  String? _countedSignature;
  Future<int>? _resultCountFuture;

  late final Future<List<String>> _cameraMakesFuture = widget.library.db.distinctCameraMakes();
  late final Future<List<String>> _cameraModelsFuture = widget.library.db.distinctCameraModels();
  late final Future<List<String>> _lensModelsFuture = widget.library.db.distinctLensModels();

  // Kaskadierend (Land -> Bundesland -> Stadt): jede Ebene schränkt die
  // darunterliegende ein, deshalb nicht `late final`, sondern bei jeder
  // Auswahl über [_onCountryChanged]/[_onStateChanged] neu zugewiesen.
  late final Future<List<String>> _countriesFuture = widget.library.db.distinctCountries();
  late Future<List<String>> _statesFuture;
  late Future<List<String>> _citiesFuture;

  @override
  void initState() {
    super.initState();
    final f = widget.initialFilters;
    _personIds = f.personIds.toSet();
    _textMode = f.textMode;
    _queryController = TextEditingController(text: f.query)
      // Löst (wie jede andere Filteränderung) einen Rebuild aus, damit
      // [_refreshResultCountIfNeeded] auch auf Texteingaben reagiert – die
      // übrigen Filter-Widgets tun das bereits über ihr jeweiliges
      // setState() in onChanged.
      ..addListener(() => setState(() {}));
    _tagIds = f.tagIds.toSet();
    _noTag = f.noTag;
    _cameraMake = f.cameraMake;
    _cameraModel = f.cameraModel;
    _lensModel = f.lensModel;
    _locationCountry = f.locationCountry;
    _locationState = f.locationState;
    _locationCity = f.locationCity;
    _statesFuture =
        _locationCountry != null ? widget.library.db.distinctStates(_locationCountry!) : Future.value(const []);
    _citiesFuture =
        _locationState != null ? widget.library.db.distinctCities(_locationState!) : Future.value(const []);
    _startDate = f.startDate;
    _endDate = f.endDate;
    _mediaType = f.mediaType;
    _favoritesOnly = f.favoritesOnly;
    _notInAnyAlbum = f.notInAnyAlbum;
    _minRating = f.minRating;
    _colorLabels = f.colorLabels.toSet();
    _minIsoController = TextEditingController(text: f.minIso?.toString() ?? '');
    _maxIsoController = TextEditingController(text: f.maxIso?.toString() ?? '');
    _minFNumberController = TextEditingController(text: f.minFNumber?.toString() ?? '');
    _maxFNumberController = TextEditingController(text: f.maxFNumber?.toString() ?? '');
    _minFocalLengthController = TextEditingController(text: f.minFocalLengthMm?.toString() ?? '');
    _maxFocalLengthController = TextEditingController(text: f.maxFocalLengthMm?.toString() ?? '');
    _blurryOnly = f.maxSharpnessScore != null;
  }

  void _onCountryChanged(String? country) {
    setState(() {
      _locationCountry = country;
      _locationState = null;
      _locationCity = null;
      _statesFuture = country != null ? widget.library.db.distinctStates(country) : Future.value(const []);
      _citiesFuture = Future.value(const []);
    });
  }

  void _onStateChanged(String? state) {
    setState(() {
      _locationState = state;
      _locationCity = null;
      _citiesFuture = state != null ? widget.library.db.distinctCities(state) : Future.value(const []);
    });
  }

  @override
  void dispose() {
    _queryController.dispose();
    _peopleFilterController.dispose();
    _minIsoController.dispose();
    _maxIsoController.dispose();
    _minFNumberController.dispose();
    _maxFNumberController.dispose();
    _minFocalLengthController.dispose();
    _maxFocalLengthController.dispose();
    super.dispose();
  }

  void _clearAll() {
    setState(() {
      _personIds = {};
      _textMode = SearchTextMode.context;
      _queryController.clear();
      _tagIds = {};
      _noTag = false;
      _cameraMake = null;
      _cameraModel = null;
      _lensModel = null;
      _locationCountry = null;
      _locationState = null;
      _locationCity = null;
      _statesFuture = Future.value(const []);
      _citiesFuture = Future.value(const []);
      _startDate = null;
      _endDate = null;
      _mediaType = MediaTypeFilter.all;
      _favoritesOnly = false;
      _notInAnyAlbum = false;
      _minRating = null;
      _colorLabels = {};
      _minIsoController.clear();
      _maxIsoController.clear();
      _minFNumberController.clear();
      _maxFNumberController.clear();
      _minFocalLengthController.clear();
      _maxFocalLengthController.clear();
      _blurryOnly = false;
    });
  }

  SearchFilters _buildFilters() => SearchFilters(
        personIds: _personIds.toList(),
        textMode: _textMode,
        query: _queryController.text,
        tagIds: _tagIds.toList(),
        noTag: _noTag,
        cameraMake: _cameraMake,
        cameraModel: _cameraModel,
        lensModel: _lensModel,
        locationCountry: _locationCountry,
        locationState: _locationState,
        locationCity: _locationCity,
        startDate: _startDate,
        endDate: _endDate,
        mediaType: _mediaType,
        favoritesOnly: _favoritesOnly,
        notInAnyAlbum: _notInAnyAlbum,
        minRating: _minRating,
        colorLabels: _colorLabels,
        minIso: int.tryParse(_minIsoController.text.trim()),
        maxIso: int.tryParse(_maxIsoController.text.trim()),
        minFNumber: double.tryParse(_minFNumberController.text.trim().replaceAll(',', '.')),
        maxFNumber: double.tryParse(_maxFNumberController.text.trim().replaceAll(',', '.')),
        minFocalLengthMm: double.tryParse(_minFocalLengthController.text.trim().replaceAll(',', '.')),
        maxFocalLengthMm: double.tryParse(_maxFocalLengthController.text.trim().replaceAll(',', '.')),
        maxSharpnessScore: _blurryOnly ? blurryScoreThreshold : null,
      );

  void _search() => Navigator.of(context).pop(_buildFilters());

  /// Berechnet die Trefferzahl für die aktuelle Filterkombination neu, wenn
  /// sie sich seit dem letzten Aufruf tatsächlich geändert hat (Vergleich
  /// über die JSON-Signatur, da [SearchFilters] keine `==` überschreibt) –
  /// verhindert, dass jeder Rebuild (auch ohne Filteränderung) eine neue
  /// DB-Abfrage auslöst. Zeigt einen Hinweis, sobald eine nicht-leere
  /// Filterkombination 0 Treffer liefert, statt dass der Nutzer das Sheet
  /// schließt und sich über eine leere Ergebnisliste wundert.
  void _refreshResultCountIfNeeded() {
    final filters = _buildFilters();
    final signature = jsonEncode(filters.toJson());
    if (signature == _countedSignature) return;
    _countedSignature = signature;
    if (filters.isEmpty) {
      _resultCountFuture = null;
      return;
    }
    _resultCountFuture = widget.library.db.searchAssets(filters).then((r) => r.length);
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _openTagPicker(List<TagData> allTags) async {
    var filter = '';
    final selection = Set<String>.from(_tagIds);
    final result = await showDialog<Set<String>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final visible = filter.isEmpty
              ? allTags
              : allTags.where((t) => t.name.toLowerCase().contains(filter.toLowerCase())).toList();
          return AlertDialog(
            title: const Text('Tags auswählen'),
            content: SizedBox(
              width: 360,
              height: 420,
              child: Column(
                children: [
                  TextField(
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Tags filtern …',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                    ),
                    onChanged: (v) => setDialogState(() => filter = v),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: visible.isEmpty
                        ? const Center(child: Text('Keine Tags gefunden.'))
                        : ListView(
                            children: [
                              for (final tag in visible)
                                CheckboxListTile(
                                  value: selection.contains(tag.id),
                                  title: Text(tag.name),
                                  onChanged: (checked) => setDialogState(() {
                                    checked == true ? selection.add(tag.id) : selection.remove(tag.id);
                                  }),
                                ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
              FilledButton(onPressed: () => Navigator.pop(context, selection), child: const Text('Übernehmen')),
            ],
          );
        },
      ),
    );
    if (result != null) setState(() => _tagIds = result);
  }

  @override
  Widget build(BuildContext context) {
    _refreshResultCountIfNeeded();
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.md, AppSpacing.sm),
              child: Row(
                children: [
                  const Icon(Icons.tune),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Suchoptionen', style: Theme.of(context).textTheme.titleLarge),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Schließen',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.lg),
                children: [
                  _buildPeopleSection(),
                  const SizedBox(height: 24),
                  _buildTextModeSection(),
                  const SizedBox(height: 24),
                  _buildTagsSection(),
                  const SizedBox(height: 24),
                  _buildRatingAndColorSection(),
                  const SizedBox(height: 24),
                  _buildCameraSection(),
                  const SizedBox(height: 24),
                  _buildRangeFiltersSection(),
                  const SizedBox(height: 24),
                  _buildLocationSection(),
                  const SizedBox(height: 24),
                  _buildDateSection(),
                  const SizedBox(height: 24),
                  _buildMediaTypeAndDisplaySection(),
                ],
              ),
            ),
            const Divider(height: 1),
            if (_resultCountFuture != null)
              FutureBuilder<int>(
                future: _resultCountFuture,
                builder: (context, snapshot) {
                  final count = snapshot.data;
                  if (count != 0) return const SizedBox.shrink();
                  return const Padding(
                    padding: EdgeInsets.fromLTRB(AppSpacing.lg, 10, AppSpacing.lg, 0),
                    child: Text(
                      'Keine Fotos gefunden – diese Filterkombination liefert 0 Treffer.',
                      style: TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                  );
                },
              ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(onPressed: _clearAll, child: const Text('Alles leeren')),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(onPressed: _search, child: const Text('Suche')),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPeopleSection() {
    return StreamBuilder<List<PersonData>>(
      stream: widget.library.db.watchPeople(),
      builder: (context, snapshot) {
        final people = snapshot.data ?? [];
        final filtered = _peopleFilterText.isEmpty
            ? people
            : people
                .where((p) => p.name.toLowerCase().contains(_peopleFilterText.toLowerCase()))
                .toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Personen', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                if (people.length > 6)
                  SizedBox(
                    width: 220,
                    child: TextField(
                      controller: _peopleFilterController,
                      decoration: const InputDecoration(
                        isDense: true,
                        prefixIcon: Icon(Icons.search, size: 18),
                        hintText: 'Personen filtern',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => setState(() => _peopleFilterText = v),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (people.isEmpty)
              Text('Noch keine Personen benannt.', style: TextStyle(color: Theme.of(context).colorScheme.outline))
            else if (filtered.isEmpty)
              Text('Keine Personen gefunden.', style: TextStyle(color: Theme.of(context).colorScheme.outline))
            else
              SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final person = filtered[index];
                    final selected = _personIds.contains(person.id);
                    return GestureDetector(
                      onTap: () => setState(() {
                        selected ? _personIds.remove(person.id) : _personIds.add(person.id);
                      }),
                      child: SizedBox(
                        width: 76,
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 32,
                                  backgroundColor: Colors.grey.shade800,
                                  backgroundImage: person.coverFaceCropPath != null
                                      ? FileImage(widget.library.paths.absolute(person.coverFaceCropPath!))
                                      : null,
                                  child: person.coverFaceCropPath == null
                                      ? const Icon(Icons.person_outline, size: 28)
                                      : null,
                                ),
                                if (selected)
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black45,
                                      border: Border.all(
                                        color: Theme.of(context).colorScheme.primary,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(Icons.check_circle,
                                        color: Theme.of(context).colorScheme.primary, size: 26),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              person.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  String _textModeSectionLabel() {
    switch (_textMode) {
      case SearchTextMode.context:
        return 'Suche nach Kontext';
      case SearchTextMode.filename:
        return 'Suche nach Dateiname';
      case SearchTextMode.description:
        return 'Suche nach Beschreibung';
      case SearchTextMode.ocr:
        return 'Suche nach erkanntem Text im Foto';
      case SearchTextMode.caption:
        return 'Suche nach KI-Beschreibung (Englisch)';
    }
  }

  Widget _buildTextModeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Suche nach Typ', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          children: [
            _InlineRadio(
              value: SearchTextMode.context,
              groupValue: _textMode,
              label: 'Kontext',
              onChanged: (v) => setState(() => _textMode = v),
            ),
            _InlineRadio(
              value: SearchTextMode.filename,
              groupValue: _textMode,
              label: 'Dateiname',
              onChanged: (v) => setState(() => _textMode = v),
            ),
            _InlineRadio(
              value: SearchTextMode.description,
              groupValue: _textMode,
              label: 'Beschreibung',
              onChanged: (v) => setState(() => _textMode = v),
            ),
            _InlineRadio(
              value: SearchTextMode.ocr,
              groupValue: _textMode,
              label: 'Text im Foto (OCR)',
              onChanged: (v) => setState(() => _textMode = v),
            ),
            _InlineRadio(
              value: SearchTextMode.caption,
              groupValue: _textMode,
              label: 'KI-Beschreibung (Englisch)',
              onChanged: (v) => setState(() => _textMode = v),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(_textModeSectionLabel(), style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _queryController,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            isDense: true,
            hintText: switch (_textMode) {
              SearchTextMode.context => 'z.B. "Sonnenaufgang am Strand", "Hund im Schnee" …',
              SearchTextMode.filename => 'Dateiname …',
              SearchTextMode.description => 'Beschreibung …',
              SearchTextMode.ocr => 'Text im Foto …',
              SearchTextMode.caption => 'z.B. "dog", "sunset" (Englisch) …',
            },
          ),
        ),
        if (_textMode == SearchTextMode.context && !widget.library.clipAvailable)
          const Padding(
            padding: EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              'KI-Bildsuche nicht verfügbar – Modell fehlt (siehe Einstellungen → KI-Modelle).',
              style: TextStyle(fontSize: 12, color: Colors.orange),
            ),
          ),
        if (_textMode == SearchTextMode.caption && !widget.library.captioningAvailable)
          const Padding(
            padding: EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              'KI-Bildbeschreibung nicht verfügbar – Modell fehlt (siehe Einstellungen → KI-Modelle).',
              style: TextStyle(fontSize: 12, color: Colors.orange),
            ),
          ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return StreamBuilder<List<TagData>>(
      stream: widget.library.db.watchAllTags(),
      builder: (context, snapshot) {
        final allTags = snapshot.data ?? [];
        final selectedTags = allTags.where((t) => _tagIds.contains(t.id)).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tags', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            InkWell(
              onTap: _noTag || allTags.isEmpty ? null : () => _openTagPicker(allTags),
              child: InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Suche nach Tags …',
                  suffixIcon: Icon(Icons.arrow_drop_down),
                  isDense: true,
                ),
                child: selectedTags.isEmpty
                    ? null
                    : Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final tag in selectedTags)
                            Chip(
                              label: Text(tag.name),
                              onDeleted: () => setState(() => _tagIds.remove(tag.id)),
                            ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 4),
            CheckboxListTile(
              value: _noTag,
              onChanged: (v) => setState(() {
                _noTag = v ?? false;
                if (_noTag) _tagIds = {};
              }),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text('Ohne Tag'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRatingAndColorSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mindestbewertung', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              StarRating(
                value: _minRating ?? 0,
                onChanged: (v) => setState(() => _minRating = v == 0 ? null : v),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Farbmarkierung', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final entry in colorLabelSwatches.entries)
                    FilterChip(
                      label: Text(_colorLabelName(entry.key)),
                      avatar: CircleAvatar(backgroundColor: entry.value, radius: 8),
                      selected: _colorLabels.contains(entry.key),
                      onSelected: (selected) => setState(() {
                        selected ? _colorLabels.add(entry.key) : _colorLabels.remove(entry.key);
                      }),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _colorLabelName(String key) {
    switch (key) {
      case 'red':
        return 'Rot';
      case 'yellow':
        return 'Gelb';
      case 'green':
        return 'Grün';
      case 'blue':
        return 'Blau';
      case 'purple':
        return 'Lila';
      default:
        return key;
    }
  }

  Widget _buildRangeFiltersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Aufnahmewerte', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _numberField('ISO von', _minIsoController)),
            const SizedBox(width: 12),
            Expanded(child: _numberField('ISO bis', _maxIsoController)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _numberField('Blende von (f/…)', _minFNumberController)),
            const SizedBox(width: 12),
            Expanded(child: _numberField('Blende bis (f/…)', _maxFNumberController)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _numberField('Brennweite von (mm)', _minFocalLengthController)),
            const SizedBox(width: 12),
            Expanded(child: _numberField('Brennweite bis (mm)', _maxFocalLengthController)),
          ],
        ),
        const SizedBox(height: 4),
        CheckboxListTile(
          value: _blurryOnly,
          onChanged: (v) => setState(() => _blurryOnly = v ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: const Text('Nur unscharfe Fotos anzeigen'),
        ),
      ],
    );
  }

  Widget _numberField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true),
    );
  }

  Widget _buildCameraSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Kamera', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _cameraDropdown(
                  'Marke', _cameraMakesFuture, _cameraMake, (v) => setState(() => _cameraMake = v)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _cameraDropdown('Modell', _cameraModelsFuture, _cameraModel,
                  (v) => setState(() => _cameraModel = v)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _cameraDropdown(
                  'Objektiv', _lensModelsFuture, _lensModel, (v) => setState(() => _lensModel = v)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _cameraDropdown(
    String label,
    Future<List<String>> future,
    String? value,
    ValueChanged<String?>? onChanged,
  ) {
    return FutureBuilder<List<String>>(
      future: future,
      builder: (context, snapshot) {
        final values = snapshot.data ?? [];
        // Falls der aktuell gesetzte Wert (noch) nicht in der geladenen
        // Liste steckt (z.B. während des Ladens), trotzdem als Eintrag
        // anbieten, damit DropdownButtonFormField nicht abstürzt.
        final items = {value, ...values}.whereType<String>().toList()..sort();
        return DropdownButtonFormField<String?>(
          initialValue: value,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('Alle')),
            for (final v in items) DropdownMenuItem(value: v, child: Text(v, overflow: TextOverflow.ellipsis)),
          ],
          onChanged: onChanged,
        );
      },
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ort', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _cameraDropdown('Land', _countriesFuture, _locationCountry, _onCountryChanged),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _cameraDropdown('Bundesland', _statesFuture, _locationState,
                  _locationCountry == null ? null : _onStateChanged),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _cameraDropdown('Stadt', _citiesFuture, _locationCity,
                  _locationState == null ? null : (v) => setState(() => _locationCity = v)),
            ),
          ],
        ),
        if (!widget.library.geoDataAvailable)
          const Padding(
            padding: EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              'Noch keine Orte aufgelöst – GeoNames-Datensatz herunterladen und Fotos '
              'auflösen (siehe Einstellungen → Standortdaten, Werkzeuge → Orte).',
              style: TextStyle(fontSize: 12, color: Colors.orange),
            ),
          ),
      ],
    );
  }

  Widget _buildDateSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _dateField('Anfangsdatum', _startDate, () => _pickDate(isStart: true),
              () => setState(() => _startDate = null)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _dateField('Enddatum', _endDate, () => _pickDate(isStart: false),
              () => setState(() => _endDate = null)),
        ),
      ],
    );
  }

  Widget _dateField(String label, DateTime? value, VoidCallback onTap, VoidCallback onClear) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: InputDecorator(
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              isDense: true,
              suffixIcon: value != null
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      tooltip: 'Datum entfernen',
                      onPressed: onClear,
                    )
                  : const Icon(Icons.calendar_today_outlined, size: 18),
            ),
            child: Text(value != null ? DateFormat('dd.MM.yyyy', 'de_DE').format(value) : 'tt.mm.jjjj'),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaTypeAndDisplaySection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Medientyp', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                children: [
                  _InlineRadio(
                    value: MediaTypeFilter.all,
                    groupValue: _mediaType,
                    label: 'Alle',
                    onChanged: (v) => setState(() => _mediaType = v),
                  ),
                  _InlineRadio(
                    value: MediaTypeFilter.image,
                    groupValue: _mediaType,
                    label: 'Bild',
                    onChanged: (v) => setState(() => _mediaType = v),
                  ),
                  _InlineRadio(
                    value: MediaTypeFilter.video,
                    groupValue: _mediaType,
                    label: 'Video',
                    onChanged: (v) => setState(() => _mediaType = v),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Anzeigeoptionen', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              CheckboxListTile(
                value: _notInAnyAlbum,
                onChanged: (v) => setState(() => _notInAnyAlbum = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: const Text('In keinem Album'),
              ),
              CheckboxListTile(
                value: _favoritesOnly,
                onChanged: (v) => setState(() => _favoritesOnly = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: const Text('Favoriten'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Radio-Button + Beschriftung als ein gemeinsam antippbares Element, in
/// einer horizontalen [Wrap] nutzbar – für "Suche nach Typ" und
/// "Medientyp", analog zum Vorbild-Layout.
class _InlineRadio<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final String label;
  final ValueChanged<T> onChanged;
  const _InlineRadio({
    required this.value,
    required this.groupValue,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: AppSpacing.xs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Radio<T>(
              value: value,
              groupValue: groupValue,
              onChanged: (v) => onChanged(v as T),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }
}
