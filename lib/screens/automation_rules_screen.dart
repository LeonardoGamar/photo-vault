import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../state/library_state.dart';
import '../theme/app_spacing.dart';

const _triggerLabels = {
  'location': 'Ort (Umkreis)',
  'aiTag': 'KI-Tag',
  'dateRange': 'Datumsbereich',
};

String _formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

/// Verwaltung des Automatisierungs-Regelwerks: pro Regel eine Bedingung
/// (Ort/KI-Tag/Datumsbereich) und Aktionen (Zielalbum, Tags, automatisches
/// Favorisieren), die automatisch angewendet werden, sobald ein Foto die
/// Bedingung erfüllt – Verallgemeinerung der Kamera-Presets (siehe
/// CameraPresetsScreen) auf andere Auslöser. Angewendet wird das in
/// LibraryState.applyAutomationRules, an zwei Stellen je nachdem, wann die
/// Bedingung geprüft werden kann (Import-Zeit für Ort/Datum, nach der
/// KI-Tagging-Stufe der Hintergrundanalyse für KI-Tag).
class AutomationRulesScreen extends StatefulWidget {
  final LibraryState library;
  const AutomationRulesScreen({super.key, required this.library});

  @override
  State<AutomationRulesScreen> createState() => _AutomationRulesScreenState();
}

class _AutomationRulesScreenState extends State<AutomationRulesScreen> {
  late final Future<List<String>> _vocabularyFuture = widget.library.db.aiTagVocabularyTerms();

  Future<void> _editRule({AutomationRuleData? existing}) async {
    final albums = await widget.library.db.watchAlbums().first;
    final allTags = await widget.library.db.watchAllTags().first;
    final vocabulary = await _vocabularyFuture;
    final existingTagIds = existing == null
        ? <String>{}
        : (await widget.library.db.tagIdsForAutomationRule(existing.id)).toSet();
    if (!mounted) return;

    final result = await showDialog<_RuleEditResult>(
      context: context,
      builder: (context) => _AutomationRuleEditorDialog(
        existing: existing,
        vocabulary: vocabulary,
        albums: albums,
        allTags: allTags,
        initialTagIds: existingTagIds,
      ),
    );
    if (result == null) return;

    var albumId = result.existingAlbumId;
    if (result.newAlbumName != null) {
      albumId = const Uuid().v4();
      await widget.library.db.createAlbum(
        AlbumsCompanion.insert(id: albumId, name: result.newAlbumName!, createdAt: DateTime.now()),
      );
    }

    final ruleId = existing?.id ?? const Uuid().v4();
    await widget.library.db.upsertAutomationRule(AutomationRulesCompanion.insert(
      id: ruleId,
      name: result.name,
      triggerType: result.triggerType,
      regionCenterLat: Value(result.regionCenterLat),
      regionCenterLon: Value(result.regionCenterLon),
      regionRadiusKm: Value(result.regionRadiusKm),
      aiTagTerm: Value(result.aiTagTerm),
      dateFrom: Value(result.dateFrom),
      dateTo: Value(result.dateTo),
      targetAlbumId: Value(albumId),
      autoFavorite: Value(result.autoFavorite),
    ));
    await widget.library.db.setAutomationRuleTags(ruleId, result.tagIds.toList());
  }

  Future<void> _deleteRule(AutomationRuleData rule) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Regel löschen?'),
        content: Text('Die Regel "${rule.name}" wirklich löschen? Bereits angewendete Aktionen bleiben erhalten.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Löschen')),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.library.db.deleteAutomationRule(rule.id);
    }
  }

  String _conditionSummary(AutomationRuleData rule) {
    switch (rule.triggerType) {
      case 'location':
        if (rule.regionCenterLat == null || rule.regionCenterLon == null || rule.regionRadiusKm == null) {
          return 'Ort: unvollständig konfiguriert';
        }
        return 'Umkreis ${rule.regionRadiusKm!.toStringAsFixed(0)} km um '
            '${rule.regionCenterLat!.toStringAsFixed(2)}, ${rule.regionCenterLon!.toStringAsFixed(2)}';
      case 'aiTag':
        return 'KI-Tag: ${rule.aiTagTerm ?? '–'}';
      case 'dateRange':
        if (rule.dateFrom == null || rule.dateTo == null) return 'Datumsbereich: unvollständig konfiguriert';
        return '${_formatDate(rule.dateFrom!)} – ${_formatDate(rule.dateTo!)}';
      default:
        return rule.triggerType;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Automatisierungsregeln')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _editRule(),
        tooltip: 'Neue Regel',
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<AutomationRuleData>>(
        stream: widget.library.db.watchAutomationRules(),
        builder: (context, ruleSnap) {
          if (!ruleSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final rules = ruleSnap.data!;
          if (rules.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xxxl),
                child: Text(
                  'Noch keine Automatisierungsregeln.\n\n'
                  'Lege eine Regel an, um Fotos automatisch anhand von Ort, '
                  'KI-Tag oder Aufnahmedatum einem Album/Tag zuzuordnen oder zu '
                  'favorisieren – wie Kamera-Presets, nur für andere Bedingungen.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return StreamBuilder<List<AlbumData>>(
            stream: widget.library.db.watchAlbums(),
            builder: (context, albumSnap) {
              final albumNames = {for (final a in albumSnap.data ?? const <AlbumData>[]) a.id: a.name};
              return StreamBuilder<List<TagData>>(
                stream: widget.library.db.watchAllTags(),
                builder: (context, tagSnap) {
                  final tagNames = {for (final t in tagSnap.data ?? const <TagData>[]) t.id: t.name};
                  return StreamBuilder<Map<String, List<String>>>(
                    stream: widget.library.db.watchAllAutomationRuleTagIds(),
                    builder: (context, ruleTagSnap) {
                      final ruleTagIds = ruleTagSnap.data ?? const <String, List<String>>{};
                      return ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        itemCount: rules.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final rule = rules[index];
                          final actionParts = <String>[
                            if (rule.targetAlbumId != null && albumNames[rule.targetAlbumId] != null)
                              'Album: ${albumNames[rule.targetAlbumId]}',
                            if (rule.autoFavorite) 'Automatisch favorisieren',
                            if ((ruleTagIds[rule.id] ?? const []).isNotEmpty)
                              'Tags: ${[for (final id in ruleTagIds[rule.id]!) if (tagNames[id] != null) tagNames[id]!].join(', ')}',
                          ];
                          return Card(
                            child: ListTile(
                              leading: Icon(switch (rule.triggerType) {
                                'location' => Icons.location_on_outlined,
                                'aiTag' => Icons.sell_outlined,
                                'dateRange' => Icons.date_range_outlined,
                                _ => Icons.rule_outlined,
                              }),
                              title: Text(rule.name),
                              subtitle: Text(
                                '${_triggerLabels[rule.triggerType] ?? rule.triggerType} · ${_conditionSummary(rule)}'
                                '${actionParts.isEmpty ? '' : '\n${actionParts.join(' · ')}'}',
                              ),
                              isThreeLine: actionParts.isNotEmpty,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined),
                                    tooltip: 'Bearbeiten',
                                    onPressed: () => _editRule(existing: rule),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    tooltip: 'Löschen',
                                    onPressed: () => _deleteRule(rule),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _RuleEditResult {
  final String name;
  final String triggerType;
  final double? regionCenterLat;
  final double? regionCenterLon;
  final double? regionRadiusKm;
  final String? aiTagTerm;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? existingAlbumId;
  final String? newAlbumName;
  final bool autoFavorite;
  final Set<String> tagIds;

  const _RuleEditResult({
    required this.name,
    required this.triggerType,
    this.regionCenterLat,
    this.regionCenterLon,
    this.regionRadiusKm,
    this.aiTagTerm,
    this.dateFrom,
    this.dateTo,
    this.existingAlbumId,
    this.newAlbumName,
    required this.autoFavorite,
    required this.tagIds,
  });
}

class _AutomationRuleEditorDialog extends StatefulWidget {
  final AutomationRuleData? existing;
  final List<String> vocabulary;
  final List<AlbumData> albums;
  final List<TagData> allTags;
  final Set<String> initialTagIds;

  const _AutomationRuleEditorDialog({
    required this.existing,
    required this.vocabulary,
    required this.albums,
    required this.allTags,
    required this.initialTagIds,
  });

  @override
  State<_AutomationRuleEditorDialog> createState() => _AutomationRuleEditorDialogState();
}

class _AutomationRuleEditorDialogState extends State<_AutomationRuleEditorDialog> {
  late final _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
  late final _latCtrl = TextEditingController(text: widget.existing?.regionCenterLat?.toString() ?? '');
  late final _lonCtrl = TextEditingController(text: widget.existing?.regionCenterLon?.toString() ?? '');
  late double _radiusKm = widget.existing?.regionRadiusKm ?? 25;
  late final _newAlbumCtrl = TextEditingController();
  late String _triggerType = widget.existing?.triggerType ?? 'location';
  String? _aiTagTerm;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  AlbumData? _selectedAlbum;
  late bool _autoFavorite = widget.existing?.autoFavorite ?? false;
  late Set<String> _tagIds = Set.of(widget.initialTagIds);
  String? _error;

  @override
  void initState() {
    super.initState();
    _aiTagTerm = widget.existing?.aiTagTerm ?? (widget.vocabulary.isEmpty ? null : widget.vocabulary.first);
    _dateFrom = widget.existing?.dateFrom;
    _dateTo = widget.existing?.dateTo;
    final targetId = widget.existing?.targetAlbumId;
    if (targetId != null) {
      final matches = widget.albums.where((a) => a.id == targetId);
      _selectedAlbum = matches.isEmpty ? null : matches.first;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _latCtrl.dispose();
    _lonCtrl.dispose();
    _newAlbumCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isFrom ? _dateFrom : _dateTo) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() => isFrom ? _dateFrom = picked : _dateTo = picked);
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Ein Name für die Regel ist erforderlich.');
      return;
    }

    double? lat, lon, radius;
    String? aiTagTerm;
    DateTime? dateFrom, dateTo;

    switch (_triggerType) {
      case 'location':
        lat = double.tryParse(_latCtrl.text.trim().replaceAll(',', '.'));
        lon = double.tryParse(_lonCtrl.text.trim().replaceAll(',', '.'));
        if (lat == null || lon == null) {
          setState(() => _error = 'Breiten- und Längengrad müssen gültige Zahlen sein.');
          return;
        }
        // Ohne diese Prüfung speicherte die Regel klaglos einen unmöglichen
        // Wert (z.B. vertauschte Ziffern) und traf danach einfach nie zu,
        // ohne dass der Nutzer je einen Hinweis bekäme (Audit-Fund).
        if (lat < -90 || lat > 90) {
          setState(() => _error = 'Der Breitengrad muss zwischen -90 und 90 liegen.');
          return;
        }
        if (lon < -180 || lon > 180) {
          setState(() => _error = 'Der Längengrad muss zwischen -180 und 180 liegen.');
          return;
        }
        radius = _radiusKm;
      case 'aiTag':
        if (_aiTagTerm == null) {
          setState(() => _error = 'Bitte einen KI-Tag-Begriff wählen.');
          return;
        }
        aiTagTerm = _aiTagTerm;
      case 'dateRange':
        if (_dateFrom == null || _dateTo == null) {
          setState(() => _error = 'Bitte Start- und Enddatum wählen.');
          return;
        }
        if (_dateFrom!.isAfter(_dateTo!)) {
          setState(() => _error = 'Das Startdatum muss vor dem Enddatum liegen.');
          return;
        }
        dateFrom = _dateFrom;
        dateTo = _dateTo;
    }

    final newAlbumName = _newAlbumCtrl.text.trim();
    Navigator.pop(
      context,
      _RuleEditResult(
        name: name,
        triggerType: _triggerType,
        regionCenterLat: lat,
        regionCenterLon: lon,
        regionRadiusKm: radius,
        aiTagTerm: aiTagTerm,
        dateFrom: dateFrom,
        dateTo: dateTo,
        existingAlbumId: newAlbumName.isEmpty ? _selectedAlbum?.id : null,
        newAlbumName: newAlbumName.isEmpty ? null : newAlbumName,
        autoFavorite: _autoFavorite,
        tagIds: _tagIds,
      ),
    );
  }

  Widget _buildConditionFields() {
    switch (_triggerType) {
      case 'location':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _latCtrl,
                    decoration: const InputDecoration(labelText: 'Breitengrad'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _lonCtrl,
                    decoration: const InputDecoration(labelText: 'Längengrad'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Umkreis: ${_radiusKm.toStringAsFixed(0)} km'),
            Slider(
              value: _radiusKm,
              min: 1,
              max: 200,
              divisions: 199,
              label: '${_radiusKm.toStringAsFixed(0)} km',
              onChanged: (v) => setState(() => _radiusKm = v),
            ),
          ],
        );
      case 'aiTag':
        return widget.vocabulary.isEmpty
            ? const Text('Kein KI-Tag-Vokabular vorhanden (Einstellungen → KI-Tagging-Vokabular).')
            : DropdownButtonFormField<String>(
                initialValue: _aiTagTerm,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'KI-Tag-Begriff'),
                items: [
                  for (final term in widget.vocabulary) DropdownMenuItem(value: term, child: Text(term)),
                ],
                onChanged: (v) => setState(() => _aiTagTerm = v),
              );
      case 'dateRange':
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pickDate(isFrom: true),
                child: Text(_dateFrom == null ? 'Startdatum' : _formatDate(_dateFrom!)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pickDate(isFrom: false),
                child: Text(_dateTo == null ? 'Enddatum' : _formatDate(_dateTo!)),
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedTags = widget.allTags.where((t) => _tagIds.contains(t.id)).toList();
    return AlertDialog(
      title: Text(widget.existing == null ? 'Neue Automatisierungsregel' : 'Regel bearbeiten'),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                const SizedBox(height: 8),
              ],
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Name (z.B. "Urlaub Italien")'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _triggerType,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Bedingung'),
                items: [
                  for (final entry in _triggerLabels.entries)
                    DropdownMenuItem(value: entry.key, child: Text(entry.value)),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _triggerType = v);
                },
              ),
              const SizedBox(height: 12),
              _buildConditionFields(),
              const SizedBox(height: 16),
              DropdownButtonFormField<AlbumData?>(
                initialValue: _selectedAlbum,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Zielalbum (optional)'),
                items: [
                  const DropdownMenuItem<AlbumData?>(value: null, child: Text('Kein Album')),
                  for (final a in widget.albums) DropdownMenuItem<AlbumData?>(value: a, child: Text(a.name)),
                ],
                // Beide Felder meinen dasselbe Ziel (Zielalbum) – ohne das
                // gegenseitige Leeren würde die zuletzt beim Speichern
                // gelesene Eingabe die andere still überschreiben, ohne dass
                // der Nutzer merkt, welche "gewonnen" hat (Audit-Fund).
                onChanged: (a) => setState(() {
                  _selectedAlbum = a;
                  if (a != null) _newAlbumCtrl.clear();
                }),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _newAlbumCtrl,
                decoration: const InputDecoration(labelText: 'oder: neues Album anlegen'),
                onChanged: (text) {
                  if (text.trim().isNotEmpty && _selectedAlbum != null) {
                    setState(() => _selectedAlbum = null);
                  }
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Automatisch favorisieren'),
                value: _autoFavorite,
                onChanged: (v) => setState(() => _autoFavorite = v),
              ),
              const SizedBox(height: 8),
              Text('Tags', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              InkWell(
                onTap: () async {
                  var filter = '';
                  final selection = Set<String>.from(_tagIds);
                  final result = await showDialog<Set<String>>(
                    context: context,
                    builder: (context) => StatefulBuilder(
                      builder: (context, setDialogState) {
                        final visible = filter.isEmpty
                            ? widget.allTags
                            : widget.allTags.where((t) => t.name.toLowerCase().contains(filter.toLowerCase())).toList();
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
                                      ? const Center(child: Text('Keine Tags vorhanden.'))
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
                            FilledButton(
                                onPressed: () => Navigator.pop(context, selection), child: const Text('Übernehmen')),
                          ],
                        );
                      },
                    ),
                  );
                  if (result != null) setState(() => _tagIds = result);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Tags auswählen …',
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
