import 'package:flutter/material.dart';

import '../db/database.dart';
import '../services/xmp_reader.dart';
import '../state/library_state.dart';
import '../theme/app_spacing.dart';

enum _XmpDiffField { rating, colorLabel, description, tags, location }

class _XmpDiff {
  final AssetData asset;
  final _XmpDiffField field;
  final String currentValueDisplay;
  final String xmpValueDisplay;
  final XmpFields xmpFields;
  const _XmpDiff({
    required this.asset,
    required this.field,
    required this.currentValueDisplay,
    required this.xmpValueDisplay,
    required this.xmpFields,
  });
}

/// Gegenstück zum bestehenden XMP-Export (Werkzeuge → "XMP-Sidecars
/// schreiben"): liest vorhandene .xmp-Sidecars (z.B. extern in Lightroom/
/// darktable/digiKam bearbeitet) und zeigt, welche Werte von der DB
/// abweichen – Bewertung, Farbmarkierung, Beschreibung, Tags, GPS-Position.
/// Bewusst OHNE Gesichts-Regionen (siehe xmp_reader.dart) und ohne
/// gesperrte Assets (deren Klartext gerade nicht ohne Weiteres zugänglich
/// ist). Muster für die Review-UI: IntegrityCheckScreen.
class XmpImportScreen extends StatefulWidget {
  final LibraryState library;
  const XmpImportScreen({super.key, required this.library});

  @override
  State<XmpImportScreen> createState() => _XmpImportScreenState();
}

class _XmpImportScreenState extends State<XmpImportScreen> {
  bool _loading = true;
  String? _error;
  List<_XmpDiff> _diffs = [];
  int _sidecarsFound = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final assets = await widget.library.db.allAssetsForIntegrityCheck();
      final diffs = <_XmpDiff>[];
      var sidecarsFound = 0;

      for (final asset in assets) {
        if (asset.isTrashed || asset.isLocked) continue;
        final sidecarPath = widget.library.paths.xmpSidecarPath(asset.relativePath);
        final sidecarFile = widget.library.paths.absolute(sidecarPath);
        final fields = parseXmpFile(sidecarFile);
        if (fields == null) continue;
        sidecarsFound++;

        if (fields.rating != null && fields.rating != asset.rating) {
          diffs.add(_XmpDiff(
            asset: asset,
            field: _XmpDiffField.rating,
            currentValueDisplay: '${asset.rating}',
            xmpValueDisplay: '${fields.rating}',
            xmpFields: fields,
          ));
        }
        if (fields.colorLabel != null && fields.colorLabel != asset.colorLabel) {
          diffs.add(_XmpDiff(
            asset: asset,
            field: _XmpDiffField.colorLabel,
            currentValueDisplay: asset.colorLabel ?? '–',
            xmpValueDisplay: fields.colorLabel!,
            xmpFields: fields,
          ));
        }
        if (fields.description != null && fields.description != asset.description) {
          diffs.add(_XmpDiff(
            asset: asset,
            field: _XmpDiffField.description,
            currentValueDisplay: asset.description ?? '–',
            xmpValueDisplay: fields.description!,
            xmpFields: fields,
          ));
        }
        if (fields.tags != null) {
          final currentTags = (await widget.library.db.tagsForAsset(asset.id)).map((t) => t.name).toSet();
          final newTags = fields.tags!.where((t) => !currentTags.contains(t)).toList();
          if (newTags.isNotEmpty) {
            diffs.add(_XmpDiff(
              asset: asset,
              field: _XmpDiffField.tags,
              currentValueDisplay: currentTags.isEmpty ? '–' : currentTags.join(', '),
              xmpValueDisplay: newTags.join(', '),
              xmpFields: fields,
            ));
          }
        }
        if (fields.latitude != null && fields.longitude != null) {
          final samePosition = asset.latitude != null &&
              asset.longitude != null &&
              (asset.latitude! - fields.latitude!).abs() < 0.0001 &&
              (asset.longitude! - fields.longitude!).abs() < 0.0001;
          if (!samePosition) {
            diffs.add(_XmpDiff(
              asset: asset,
              field: _XmpDiffField.location,
              currentValueDisplay: asset.latitude != null
                  ? '${asset.latitude!.toStringAsFixed(5)}, ${asset.longitude!.toStringAsFixed(5)}'
                  : '–',
              xmpValueDisplay: '${fields.latitude!.toStringAsFixed(5)}, ${fields.longitude!.toStringAsFixed(5)}',
              xmpFields: fields,
            ));
          }
        }
      }

      setState(() {
        _diffs = diffs;
        _sidecarsFound = sidecarsFound;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = 'Einlesen fehlgeschlagen: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _apply(_XmpDiff diff) async {
    switch (diff.field) {
      case _XmpDiffField.rating:
        await widget.library.db.setRating(diff.asset.id, diff.xmpFields.rating!);
      case _XmpDiffField.colorLabel:
        await widget.library.db.setColorLabel(diff.asset.id, diff.xmpFields.colorLabel);
      case _XmpDiffField.description:
        await widget.library.db.setDescription(diff.asset.id, diff.xmpFields.description!);
      case _XmpDiffField.tags:
        final currentTags = (await widget.library.db.tagsForAsset(diff.asset.id)).map((t) => t.name).toSet();
        for (final tag in diff.xmpFields.tags!) {
          if (!currentTags.contains(tag)) await widget.library.db.tagAsset(diff.asset.id, tag);
        }
      case _XmpDiffField.location:
        await widget.library.db.setLocation(diff.asset.id, diff.xmpFields.latitude, diff.xmpFields.longitude);
    }
    if (!mounted) return;
    setState(() => _diffs = _diffs.where((d) => d != diff).toList());
  }

  Future<void> _applyAll() async {
    for (final diff in List<_XmpDiff>.from(_diffs)) {
      await _apply(diff);
    }
  }

  String _fieldLabel(_XmpDiffField field) => switch (field) {
        _XmpDiffField.rating => 'Bewertung',
        _XmpDiffField.colorLabel => 'Farbmarkierung',
        _XmpDiffField.description => 'Beschreibung',
        _XmpDiffField.tags => 'Neue Tags',
        _XmpDiffField.location => 'Standort',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('XMP-Sidecars einlesen'),
        actions: [
          if (_diffs.isNotEmpty)
            TextButton(
              onPressed: _applyAll,
              child: const Text('Alle übernehmen', style: TextStyle(color: Colors.white)),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Erneut einlesen',
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Text(_error!, textAlign: TextAlign.center),
        ),
      );
    }
    if (_diffs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline, size: 56, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                _sidecarsFound == 0
                    ? 'Keine XMP-Sidecars gefunden.'
                    : '$_sidecarsFound Sidecar(s) geprüft – keine Abweichungen zur Datenbank gefunden.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _diffs.length,
      itemBuilder: (context, index) {
        final diff = _diffs[index];
        return Card(
          child: ListTile(
            title: Text(diff.asset.originalFileName),
            subtitle: Text('${_fieldLabel(diff.field)}: "${diff.currentValueDisplay}" → "${diff.xmpValueDisplay}"'),
            trailing: TextButton(
              onPressed: () => _apply(diff),
              child: const Text('Übernehmen'),
            ),
          ),
        );
      },
    );
  }
}
