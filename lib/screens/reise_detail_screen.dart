import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../db/database.dart';
import '../l10n/app_localizations.dart';
import '../state/library_state.dart';
import '../theme/app_spacing.dart';
import '../services/reiseroute.dart';
import '../widgets/asset_thumbnail_tile.dart';
import '../widgets/mini_location_map.dart'
    show buildMapAttribution, buildMapTileLayer, kartenHoechsteStufe;
import '../widgets/namens_dialog.dart';
import 'asset_viewer_screen.dart';
import 'reisen_screen.dart' show reiseUnterzeile;

/// Eine einzelne Reise.
///
/// Ist eine Reise erst benannt, ist die Darstellung fast geschenkt: Die
/// Aufnahmen liegen bereits chronologisch vor, die besuchten Orte stehen
/// aus der Umkehr-Geokodierung an jedem Bild.
class ReiseDetailScreen extends StatefulWidget {
  final LibraryState library;
  final ReisenData reise;

  const ReiseDetailScreen({
    super.key,
    required this.library,
    required this.reise,
  });

  @override
  State<ReiseDetailScreen> createState() => _ReiseDetailScreenState();
}

class _ReiseDetailScreenState extends State<ReiseDetailScreen> {
  late ReisenData _reise = widget.reise;
  List<AssetData> _aufnahmen = const [];
  bool _laedt = true;

  @override
  void initState() {
    super.initState();
    _laden();
  }

  Future<void> _laden() async {
    final aufnahmen = await widget.library.db.aufnahmenDerReise(_reise.id);
    final frisch = await widget.library.db.reise(_reise.id);
    if (!mounted) return;
    setState(() {
      _aufnahmen = aufnahmen;
      if (frisch != null) _reise = frisch;
      _laedt = false;
    });
  }

  /// Die besuchten Orte, häufigste zuerst – aus den Aufnahmen selbst und
  /// nicht gespeichert: Wer eine Aufnahme aus der Reise nimmt, soll die
  /// Liste sofort ohne sie sehen.
  List<String> get _orte {
    final gezaehlt = <String, int>{};
    for (final a in _aufnahmen) {
      final ort = a.locationCity;
      if (ort == null || ort.isEmpty) continue;
      gezaehlt[ort] = (gezaehlt[ort] ?? 0) + 1;
    }
    return gezaehlt.keys.toList()
      ..sort((a, b) {
        final z = gezaehlt[b]!.compareTo(gezaehlt[a]!);
        return z != 0 ? z : a.compareTo(b);
      });
  }

  Map<String, AssetData> get _nachId =>
      {for (final a in _aufnahmen) a.id: a};

  List<Routenpunkt> get _route => reiseroute([
        for (final a in _aufnahmen)
          if (a.latitude != null && a.longitude != null)
            (
              breite: a.latitude!,
              laenge: a.longitude!,
              zeit: a.fileCreatedAt,
            ),
      ]);

  List<Reisetag> get _tage => reisetage([
        for (final a in _aufnahmen)
          (id: a.id, zeit: a.fileCreatedAt, stadt: a.locationCity),
      ]);

  int get _naechte => DateTime(_reise.bis.year, _reise.bis.month, _reise.bis.day)
      .difference(DateTime(_reise.von.year, _reise.von.month, _reise.von.day))
      .inDays;

  Future<void> _umbenennen() async {
    final t = AppTexte.of(context);
    final sauber = await frageNamen(
      context,
      titel: t.reisenUmbenennen,
      feldbeschriftung: t.reisenName,
      vorgabe: _reise.name,
    );
    if (sauber == null || !mounted) return;
    await widget.library.db
        .reiseAendern(_reise.id, ReisenCompanion(name: Value(sauber)));
    await _laden();
  }

  Future<void> _notiz() async {
    final t = AppTexte.of(context);
    final text = await frageNamen(
      context,
      titel: t.reisenNotiz,
      feldbeschriftung: t.reisenNotiz,
      vorgabe: _reise.notiz ?? '',
      mehrzeilig: true,
      leerErlaubt: true,
    );
    if (text == null || !mounted) return;
    await widget.library.db.reiseAendern(
      _reise.id,
      // Leerer Text heisst „keine Notiz" und nicht „eine leere Notiz" –
      // sonst stünde in der Ansicht ein leerer Absatz.
      ReisenCompanion(notiz: Value(text.isEmpty ? null : text)),
    );
    await _laden();
  }

  /// Ein langer Druck öffnet ein Menü und ändert nicht stillschweigend
  /// das Titelbild: Eine Geste, die etwas verändert, ohne es zu sagen,
  /// findet man nur durch Zufall wieder.
  Future<void> _bildmenue(AssetData asset) async {
    final t = AppTexte.of(context);
    await showModalBottomSheet<void>(
      context: context,
      builder: (blatt) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: Text(t.reisenAlsTitelbild),
              onTap: () {
                Navigator.pop(blatt);
                _titelbild(asset);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _titelbild(AssetData asset) async {
    final t = AppTexte.of(context);
    await widget.library.db.reiseAendern(
        _reise.id, ReisenCompanion(titelbildAssetId: Value(asset.id)));
    await _laden();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(t.reisenTitelbildGesetzt)));
  }

  Future<void> _entfernen() async {
    final t = AppTexte.of(context);
    final ja = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(t.reisenLoeschen),
        content: Text(t.reisenLoeschenFrage(_reise.name)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialog, false),
              child: Text(t.allgAbbrechen)),
          FilledButton(
              onPressed: () => Navigator.pop(dialog, true),
              child: Text(t.allgEntfernen)),
        ],
      ),
    );
    if (ja != true || !mounted) return;
    await widget.library.db.reiseLoeschen(_reise.id);
    if (mounted) Navigator.of(context).pop();
  }

  void _oeffnen(int index) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AssetViewerScreen(
        assets: _aufnahmen,
        initialIndex: index,
        paths: widget.library.paths,
        db: widget.library.db,
        library: widget.library,
        onToggleFavorite: (a) =>
            widget.library.db.setFavorite(a.id, !a.isFavorite),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTexte.of(context);
    final farben = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(_reise.name),
        actions: [
          IconButton(
            tooltip: t.reisenUmbenennen,
            icon: const Icon(Icons.drive_file_rename_outline),
            onPressed: _umbenennen,
          ),
          IconButton(
            tooltip: t.reisenNotiz,
            icon: const Icon(Icons.notes_outlined),
            onPressed: _notiz,
          ),
          IconButton(
            tooltip: t.reisenLoeschen,
            icon: const Icon(Icons.delete_outline),
            onPressed: _entfernen,
          ),
        ],
      ),
      body: _laedt
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg,
                        AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reiseUnterzeile(t, Localizations.localeOf(context),
                              von: _reise.von,
                              bis: _reise.bis,
                              naechte: _naechte,
                              anzahl: _aufnahmen.length),
                          style: TextStyle(
                              fontSize: 13, color: farben.onSurfaceVariant),
                        ),
                        if (_route.length > 1) ...[
                          const SizedBox(height: AppSpacing.md),
                          Text(t.reisenRoute,
                              style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: AppSpacing.xs),
                          _Routenkarte(route: _route),
                        ] else if (_aufnahmen.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.md),
                          Text(t.reisenKeineRoute,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: farben.onSurfaceVariant)),
                        ],
                        if (_reise.notiz case final notiz?
                            when notiz.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.md),
                          Text(notiz),
                        ],
                        if (_orte.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.md),
                          Text(t.reisenOrte,
                              style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: AppSpacing.xs),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.xs,
                            children: [
                              for (final ort in _orte.take(20))
                                Chip(
                                  label: Text(ort),
                                  visualDensity: VisualDensity.compact,
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // Die Tage als Kapitel. Ein durchgehendes Raster von
                // dreihundertfünfzig Bildern beantwortet die Frage nicht,
                // die man an eine Reise stellt: Was war wann?
                for (final tag in _tage) ...[
                  SliverToBoxAdapter(
                    child: _Tageskopf(
                      tag: tag,
                      anzahl: tag.aufnahmeIds.length,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 160,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final asset =
                              _nachId[tag.aufnahmeIds[index]];
                          if (asset == null) return const SizedBox.shrink();
                          return AssetThumbnailTile(
                            asset: asset,
                            paths: widget.library.paths,
                            onTap: () =>
                                _oeffnen(_aufnahmen.indexOf(asset)),
                            onLongPress: () => _bildmenue(asset),
                          );
                        },
                        childCount: tag.aufnahmeIds.length,
                      ),
                    ),
                  ),
                ],
                const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.xl)),
              ],
            ),
    );
  }
}

/// Die Überschrift eines Reisetages.
class _Tageskopf extends StatelessWidget {
  final Reisetag tag;
  final int anzahl;

  const _Tageskopf({required this.tag, required this.anzahl});

  @override
  Widget build(BuildContext context) {
    final t = AppTexte.of(context);
    final farben = Theme.of(context).colorScheme;
    final datum =
        DateFormat.yMMMMEEEEd(Localizations.localeOf(context).toString());
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Flexible(
            child: Text(
              tag.ort == null
                  ? t.reisenTag(datum.format(tag.tag))
                  : '${datum.format(tag.tag)} · ${tag.ort}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(t.reisenAufnahmen(anzahl),
              style: TextStyle(fontSize: 12, color: farben.onSurfaceVariant)),
        ],
      ),
    );
  }
}

/// Die Strecke auf der Karte.
///
/// Ohne Bedienung: Diese Karte beantwortet eine Frage („wo war das?"),
/// sie ist kein Kartenbildschirm. Wer suchen will, hat den unter „Orte".
class _Routenkarte extends StatelessWidget {
  final List<Routenpunkt> route;

  const _Routenkarte({required this.route});

  @override
  Widget build(BuildContext context) {
    final farben = Theme.of(context).colorScheme;
    final punkte = [for (final p in route) ll.LatLng(p.breite, p.laenge)];
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: SizedBox(
        height: 240,
        child: FlutterMap(
          options: MapOptions(
            // Der Ausschnitt wird auf die Strecke gelegt, nicht auf eine
            // geratene Mitte mit geratener Zoomstufe.
            initialCameraFit: CameraFit.coordinates(
              coordinates: punkte,
              padding: const EdgeInsets.all(AppSpacing.xxl),
            ),
            interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.none),
            // Auch eine unbewegliche Karte braucht die Grenze: Das
            // Einpassen auf die Strecke kann bei zwei dicht
            // beieinanderliegenden Punkten über die höchste Stufe hinaus
            // rechnen, für die es Kacheln gibt.
            maxZoom: kartenHoechsteStufe(context),
          ),
          children: [
            buildMapTileLayer(context),
            PolylineLayer(polylines: [
              Polyline(
                points: punkte,
                strokeWidth: 3,
                color: farben.primary,
              ),
            ]),
            MarkerLayer(markers: [
              for (final (i, p) in punkte.indexed)
                Marker(
                  point: p,
                  width: 14,
                  height: 14,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // Anfang und Ende betont: Eine Strecke ohne
                      // erkennbare Richtung ist nur ein Strich.
                      color: i == 0 || i == punkte.length - 1
                          ? farben.primary
                          : farben.surface,
                      border: Border.all(color: farben.primary, width: 2),
                    ),
                  ),
                ),
            ]),
            buildMapAttribution(context),
          ],
        ),
      ),
    );
  }
}
