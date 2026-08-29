import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../db/database.dart';
import '../l10n/app_localizations.dart';
import '../state/library_state.dart';
import '../theme/app_spacing.dart';
import '../services/reiseroute.dart';
import '../widgets/asset_thumbnail_tile.dart';
import '../widgets/routenkarte.dart';
import '../widgets/namens_dialog.dart';
import 'asset_viewer_screen.dart';
import 'aufnahmen_waehlen_screen.dart';
import 'reisen_screen.dart' show reiseUnterzeile;
import '../services/meldungsdienst.dart';
import 'aktivitaet_detail_screen.dart';
import 'aktivitaeten_screen.dart' show Aktivitaetszeile;

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
  List<AktivitaetenData> _aktivitaeten = const [];
  bool _laedt = true;

  @override
  void initState() {
    super.initState();
    _laden();
  }

  Future<void> _laden() async {
    final aufnahmen = await widget.library.db.aufnahmenDerReise(_reise.id);
    final frisch = await widget.library.db.reise(_reise.id);
    final aktivitaeten =
        await widget.library.db.aktivitaetenDerReise(_reise.id);
    if (!mounted) return;
    setState(() {
      _aufnahmen = aufnahmen;
      _aktivitaeten = aktivitaeten;
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

  /// Die Aufenthaltsorte – ein Pin je Ort statt einer je Aufnahme.
  List<Aufenthaltsort> get _orteMitBildern => aufenthaltsorte([
        for (final a in _aufnahmen)
          if (a.latitude != null && a.longitude != null)
            (
              id: a.id,
              breite: a.latitude!,
              laenge: a.longitude!,
              zeit: a.fileCreatedAt,
              stadt: a.locationCity,
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
    melde.erfolg(t.reisenTitelbildGesetzt);
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

  /// Fotos dazunehmen oder herausnehmen.
  ///
  /// Beim Anlegen kam alles aus dem Zeitraum mit (siehe
  /// `frageZeitraum`); dass eine Reise am Abflugtag noch drei Bilder aus
  /// der Küche enthält, war bis hierher nicht zu ändern.
  Future<void> _aufnahmenBearbeiten() async {
    final t = AppTexte.of(context);
    final vorher = {for (final a in _aufnahmen) a.id};
    final neu = await Navigator.of(context).push<Set<String>>(
      MaterialPageRoute(
        builder: (_) => AufnahmenWaehlenScreen(
          library: widget.library,
          titel: t.aufnahmenWahlTitelReise,
          vorhanden: vorher,
          von: _reise.von,
          bis: _reise.bis,
        ),
      ),
    );
    if (neu == null || !mounted) return;
    final dazu = neu.difference(vorher).length;
    final weg = vorher.difference(neu).length;
    if (dazu == 0 && weg == 0) {
      melde.hinweis(t.aufnahmenWahlUnveraendert);
      return;
    }
    await widget.library.db.setzeAufnahmenDerReise(_reise.id, neu);
    melde.erfolg(t.aufnahmenWahlGeaendert(dazu, weg));
    await _laden();
  }

  /// Tippen auf einen Pin: nur die Bilder von dort.
  ///
  /// Nicht der Sprung in die vollständige Liste an der passenden Stelle.
  /// „Was habe ich in Rom fotografiert" ist eine eigene Frage, und ein
  /// Betrachter, der danach weiterblättert nach Florenz, beantwortet sie
  /// nur halb.
  Future<void> _aktivitaetOeffnen(AktivitaetenData k) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) =>
          AktivitaetDetailScreen(library: widget.library, aktivitaet: k),
    ));
    if (mounted) await _laden();
  }

  void _ortOeffnen(Aufenthaltsort ort) {
    final bilder = [
      for (final id in ort.aufnahmeIds)
        if (_nachId[id] case final a?) a,
    ];
    if (bilder.isEmpty) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AssetViewerScreen(
        assets: bilder,
        initialIndex: 0,
        paths: widget.library.paths,
        db: widget.library.db,
        library: widget.library,
        onToggleFavorite: (a) =>
            widget.library.db.setFavorite(a.id, !a.isFavorite),
      ),
    ));
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
            tooltip: t.aufnahmenBearbeiten,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            onPressed: _aufnahmenBearbeiten,
          ),
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
                          Routenkarte(
                            route: _route,
                            orte: _orteMitBildern,
                            nachId: _nachId,
                            paths: widget.library.paths,
                            beiOrt: _ortOeffnen,
                          ),
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
                // Die Unternehmungen dieser Reise – vor den Tagen, weil
                // sie die Frage „was haben wir gemacht?" beantworten und
                // die Tage nur die Frage „wann".
                if (_aktivitaeten.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.lg,
                          AppSpacing.md, AppSpacing.lg, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.aktivitaetenInDieserReise,
                              style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: AppSpacing.xs),
                          for (final k in _aktivitaeten)
                            Aktivitaetszeile(
                              aktivitaet: k,
                              library: widget.library,
                              // In der Liste einer Reise wäre der Name
                              // bei jeder Zeile derselbe.
                              reisename: null,
                              onTippen: () => _aktivitaetOeffnen(k),
                            ),
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
