import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../l10n/app_localizations.dart';
import '../services/reisefortschritt.dart';
import '../services/reisen.dart';
import '../state/library_state.dart';
import '../theme/app_spacing.dart';
import '../widgets/asset_thumbnail_tile.dart';
import '../widgets/namens_dialog.dart';
import '../widgets/fortschrittsbalken.dart';
import 'laenderliste_screen.dart';
import 'reise_detail_screen.dart';
import 'weltkarte_screen.dart';
import 'aktivitaeten_screen.dart';

/// Die Reisen einer Bibliothek – bestätigte und vorgeschlagene.
///
/// **Der Unterschied zu jedem anderen Reisetagebuch:** Hier steht kein
/// leeres Formular. Aufnahmezeit und Koordinate liegen längst in der
/// Datenbank; was fehlte, war jemand, der sie zusammenliest. Der Nutzer
/// bestätigt und benennt — aus einer Tagebuchpflicht wird eine
/// Bestätigung.
class ReisenScreen extends StatefulWidget {
  final LibraryState library;
  const ReisenScreen({super.key, required this.library});

  @override
  State<ReisenScreen> createState() => _ReisenScreenState();
}

class _ReisenScreenState extends State<ReisenScreen> {
  List<ReisenData> _reisen = const [];
  List<Reisevorschlag> _vorschlaege = const [];
  Reisefortschritt? _fortschritt;
  bool _laedt = true;

  @override
  void initState() {
    super.initState();
    _laden();
  }

  Future<void> _laden() async {
    setState(() => _laedt = true);
    final db = widget.library.db;
    final reisen = await db.alleReisen();
    final roh = await db.aufnahmenFuerReiseerkennung();
    final ohneOrt = await db.aufnahmenOhneKoordinate();
    final zugeordnet = await db.zugeordneteReiseAufnahmen();
    final verworfen = await db.verworfeneReisevorschlaege();
    final besucht = await db.besuchteOrte();
    if (!mounted) return;
    // Ohne den GeoNames-Datensatz gibt es keine Länderzahl, gegen die
    // sich zählen liesse – dann bleibt der Balken weg, statt „0 von 0"
    // zu behaupten.
    final verzeichnis = widget.library.geocoder?.laenderverzeichnis;
    final fortschritt = verzeichnis == null
        ? null
        : reisefortschritt(besucht, laenderGesamt: verzeichnis.length);
    final t = AppTexte.of(context);
    final vorschlaege = erkenneReisen(
      [
        for (final a in roh)
          (
            id: a.id,
            zeit: a.zeit,
            breite: a.breite,
            laenge: a.laenge,
            land: a.land,
            region: a.region,
            stadt: a.stadt,
          ),
      ],
      ohneOrt: t.reisenOhneOrt,
      unverortet: ohneOrt,
      bekannteIds: zugeordnet,
      verworfen: verworfen,
    );
    if (!mounted) return;
    setState(() {
      _reisen = reisen;
      _vorschlaege = vorschlaege;
      _fortschritt = fortschritt;
      _laedt = false;
    });
  }

  /// Bestätigen — mit Rückfrage nach dem Namen.
  ///
  /// Der vorgeschlagene Name steht schon im Feld: Meistens stimmt er, und
  /// dann ist es ein Tastendruck. Wo er nicht stimmt, ist er trotzdem ein
  /// besserer Anfang als ein leeres Feld.
  Future<void> _bestaetigen(Reisevorschlag v) async {
    final t = AppTexte.of(context);
    final sauber = await frageNamen(
      context,
      titel: t.reisenBenennen,
      feldbeschriftung: t.reisenName,
      vorgabe: v.name,
    );
    if (sauber == null || !mounted) return;

    await widget.library.db.reiseAnlegen(
      ReisenCompanion.insert(
        id: const Uuid().v4(),
        name: sauber,
        von: v.von,
        bis: v.bis,
        angelegtAm: DateTime.now(),
      ),
      v.aufnahmeIds,
    );
    await _laden();
  }

  Future<void> _verwerfen(Reisevorschlag v) async {
    await widget.library.db.verwirfReisevorschlag(v.schluessel);
    await _laden();
  }

  Future<void> _oeffnen(ReisenData reise) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ReiseDetailScreen(library: widget.library, reise: reise),
    ));
    if (mounted) await _laden();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTexte.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.reisenTitel),
        actions: [
          IconButton(
            tooltip: t.weltkarteOeffnen,
            icon: const Icon(Icons.public),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => WeltkarteScreen(library: widget.library),
            )),
          ),
          IconButton(
            tooltip: t.laenderTitel,
            icon: const Icon(Icons.flag_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => LaenderlisteScreen(library: widget.library),
            )),
          ),
          IconButton(
            tooltip: t.aktivitaetenOeffnen,
            icon: const Icon(Icons.hiking),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => AktivitaetenScreen(library: widget.library),
            )),
          ),
          IconButton(
            tooltip: t.reisenAktualisieren,
            icon: const Icon(Icons.refresh),
            onPressed: _laedt ? null : _laden,
          ),
        ],
      ),
      body: _laedt
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: AppSpacing.lg),
                  Text(t.reisenSuchtNoch,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.outline)),
                ],
              ),
            )
          : _reisen.isEmpty && _vorschlaege.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: SizedBox(
                      width: 440,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(t.reisenLeer, textAlign: TextAlign.center),
                          // Ohne den Datensatz kann die App gar nicht
                          // wissen, wo etwas aufgenommen wurde – dann ist
                          // „noch keine Reise" nur die halbe Auskunft.
                          if (widget.library.geocoder == null) ...[
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              t.fortschrittOhneGeodaten,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    if (_fortschritt case final f? when !f.istLeer) ...[
                      Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          onTap: () =>
                              Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => LaenderlisteScreen(
                                library: widget.library),
                          )),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Fortschrittsbalken(fortschritt: f),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                    if (_vorschlaege.isNotEmpty) ...[
                      _Ueberschrift(t.reisenVorschlaege),
                      for (final v in _vorschlaege)
                        _Vorschlagskarte(
                          vorschlag: v,
                          onJa: () => _bestaetigen(v),
                          onNein: () => _verwerfen(v),
                        ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                    if (_reisen.isNotEmpty) ...[
                      _Ueberschrift(t.reisenBestaetigte),
                      for (final r in _reisen)
                        _Reisezeile(
                          reise: r,
                          library: widget.library,
                          onTippen: () => _oeffnen(r),
                        ),
                    ] else
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: Text(
                          t.reisenLeer,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.outline),
                        ),
                      ),
                  ],
                ),
    );
  }
}

/// Zeitraum, Nächte und Zahl der Aufnahmen in einer Zeile.
String reiseUnterzeile(
  AppTexte t,
  Locale locale, {
  required DateTime von,
  required DateTime bis,
  required int naechte,
  required int anzahl,
}) {
  final datum = DateFormat.yMMMd(locale.toString());
  return [
    t.reisenSpanne(datum.format(von), datum.format(bis)),
    t.reisenNaechte(naechte),
    t.reisenAufnahmen(anzahl),
  ].join(' · ');
}

class _Ueberschrift extends StatelessWidget {
  final String text;
  const _Ueberschrift(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );
}

class _Vorschlagskarte extends StatelessWidget {
  final Reisevorschlag vorschlag;
  final VoidCallback onJa;
  final VoidCallback onNein;

  const _Vorschlagskarte({
    required this.vorschlag,
    required this.onJa,
    required this.onNein,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppTexte.of(context);
    final farben = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.luggage_outlined, color: farben.primary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(vorschlag.name,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              reiseUnterzeile(t, Localizations.localeOf(context),
                  von: vorschlag.von,
                  bis: vorschlag.bis,
                  naechte: vorschlag.naechte,
                  anzahl: vorschlag.anzahl),
              style: TextStyle(fontSize: 13, color: farben.onSurfaceVariant),
            ),
            if (vorschlag.orte.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  vorschlag.orte.take(6).join(' · '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: farben.onSurfaceVariant),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: onNein, child: Text(t.reisenKeineReise)),
                const SizedBox(width: AppSpacing.sm),
                FilledButton(
                    onPressed: onJa, child: Text(t.reisenIstEineReise)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Reisezeile extends StatefulWidget {
  final ReisenData reise;
  final LibraryState library;
  final VoidCallback onTippen;

  const _Reisezeile({
    required this.reise,
    required this.library,
    required this.onTippen,
  });

  @override
  State<_Reisezeile> createState() => _ReisezeileState();
}

class _ReisezeileState extends State<_Reisezeile> {
  /// Einmal beim Anlegen der Zeile geholt und nicht in `build`: Sonst
  /// liefe die Abfrage bei jedem Neuaufbau erneut – und eine Liste baut
  /// sich oft neu auf.
  late final Future<AssetData?> _titelbild = _hole();

  Future<AssetData?> _hole() async {
    final id = widget.reise.titelbildAssetId;
    if (id != null) {
      final gewaehlt = await widget.library.db.assetById(id);
      if (gewaehlt != null) return gewaehlt;
    }
    // Kein gewähltes Titelbild – dann die erste Aufnahme der Reise. Ein
    // gewähltes, das inzwischen gelöscht wurde, fällt auf denselben Weg
    // zurück, statt eine leere Fläche zu zeigen.
    return widget.library.db.ersteAufnahmeDerReise(widget.reise.id);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTexte.of(context);
    final datum = DateFormat.yMMMd(Localizations.localeOf(context).toString());
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: SizedBox(
          width: 52,
          height: 52,
          child: FutureBuilder<AssetData?>(
            future: _titelbild,
            builder: (context, schnappschuss) {
              final asset = schnappschuss.data;
              if (asset == null) {
                return const Center(child: Icon(Icons.luggage));
              }
              return ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.xs),
                child: AssetThumbnailTile(
                  asset: asset,
                  paths: widget.library.paths,
                  onTap: widget.onTippen,
                ),
              );
            },
          ),
        ),
        title: Text(widget.reise.name),
        subtitle: Text(t.reisenSpanne(
            datum.format(widget.reise.von), datum.format(widget.reise.bis))),
        trailing: const Icon(Icons.chevron_right),
        onTap: widget.onTippen,
      ),
    );
  }
}
