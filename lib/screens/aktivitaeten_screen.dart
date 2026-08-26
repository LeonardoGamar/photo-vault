import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../l10n/app_localizations.dart';
import '../services/aktivitaeten.dart';
import '../services/meldungsdienst.dart';
import '../services/reisen.dart' show zuhause;
import '../state/library_state.dart';
import '../theme/app_spacing.dart';
import '../widgets/aktivitaetsart_anzeige.dart';
import '../widgets/asset_thumbnail_tile.dart';
import '../widgets/namens_dialog.dart';
import 'aktivitaet_detail_screen.dart';

/// Die Aktivitäten: Wanderungen, Radtouren, Ausflüge.
///
/// **Vorschlagen statt verlangen**, wie bei den Reisen. Andere Programme
/// stellen ein leeres Formular hin; hier steht die Frage: „Am 14. Juni
/// liegen acht Bilder über dreieinhalb Stunden und zwölf Kilometer bei
/// Goslar – war das eine Wanderung?"
class AktivitaetenScreen extends StatefulWidget {
  final LibraryState library;

  const AktivitaetenScreen({super.key, required this.library});

  @override
  State<AktivitaetenScreen> createState() => _AktivitaetenScreenState();
}

class _AktivitaetenScreenState extends State<AktivitaetenScreen> {
  List<AktivitaetenData> _aktivitaeten = const [];
  List<Aktivitaetsvorschlag> _vorschlaege = const [];
  Map<String, String> _reisenamen = const {};
  bool _laedt = true;

  @override
  void initState() {
    super.initState();
    _laden();
  }

  Future<void> _laden() async {
    setState(() => _laedt = true);
    final db = widget.library.db;
    final aktivitaeten = await db.alleAktivitaeten();
    final reisen = await db.alleReisen();
    final roh = await db.aufnahmenFuerReiseerkennung();
    final belegt = await db.zugeordneteAktivitaetsAufnahmen();
    final verworfen = await db.verworfeneAktivitaetsvorschlaege();
    if (!mounted) return;
    final t = AppTexte.of(context);

    final fuerErkennung = [
      for (final a in roh)
        (
          id: a.id,
          zeit: a.zeit,
          breite: a.breite,
          laenge: a.laenge,
          stadt: a.stadt,
        ),
    ];
    final vorschlaege = erkenneAktivitaeten(
      fuerErkennung,
      ohneOrt: t.aktivitaetenOhneOrt,
      // Derselbe Wohnort wie bei der Reiseerkennung – aus denselben
      // Aufnahmen geschlossen, damit „weit weg" beide Male dasselbe
      // heisst.
      wohnort: zuhause([
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
      ]),
      bekannteIds: belegt,
      verworfen: verworfen,
    );

    if (!mounted) return;
    setState(() {
      _aktivitaeten = aktivitaeten;
      _vorschlaege = vorschlaege;
      _reisenamen = {for (final r in reisen) r.id: r.name};
      _laedt = false;
    });
  }

  /// Bestätigen – mit Rückfrage nach dem Namen, wie bei den Reisen. Der
  /// vorgeschlagene Name steht schon im Feld.
  Future<void> _bestaetigen(Aktivitaetsvorschlag v) async {
    final t = AppTexte.of(context);
    final sauber = await frageNamen(
      context,
      titel: t.aktivitaetenBenennen,
      feldbeschriftung: t.aktivitaetenName,
      vorgabe: v.name,
    );
    if (sauber == null || !mounted) return;

    final db = widget.library.db;
    final reisen = await db.alleReisen();
    final zuordnung = await db.reiseJeAufnahme();
    final reiseId = reiseFuerAktivitaet(
      aufnahmeIds: v.aufnahmeIds,
      von: v.von,
      reiseJeAufnahme: zuordnung,
      reisen: [for (final r in reisen) (id: r.id, von: r.von, bis: r.bis)],
    );

    await db.aktivitaetAnlegen(
      AktivitaetenCompanion.insert(
        id: const Uuid().v4(),
        name: sauber,
        art: v.art.kennung,
        von: v.von,
        bis: v.bis,
        reiseId: Value(reiseId),
        angelegtAm: DateTime.now(),
      ),
      v.aufnahmeIds,
    );
    melde.erfolg(t.aktivitaetenAngelegt(sauber));
    await _laden();
  }

  Future<void> _verwerfen(Aktivitaetsvorschlag v) async {
    await widget.library.db.verwirfAktivitaetsvorschlag(v.schluessel);
    await _laden();
  }

  List<AktivitaetenData> get _ohneReise =>
      [for (final k in _aktivitaeten) if (k.reiseId == null) k];

  List<AktivitaetenData> get _mitReise =>
      [for (final k in _aktivitaeten) if (k.reiseId != null) k];

  Future<void> _oeffnen(AktivitaetenData k) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) =>
          AktivitaetDetailScreen(library: widget.library, aktivitaet: k),
    ));
    if (mounted) await _laden();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTexte.of(context);
    final farben = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.aktivitaetenTitel),
        actions: [
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
                  Text(t.aktivitaetenSuchtNoch,
                      style: TextStyle(color: farben.onSurfaceVariant)),
                ],
              ),
            )
          : _aktivitaeten.isEmpty && _vorschlaege.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: SizedBox(
                      width: 440,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(t.aktivitaetenLeer,
                              textAlign: TextAlign.center),
                          // Ohne den Datensatz weiss die App nicht, wo
                          // etwas aufgenommen wurde – dann ist „noch
                          // keine Aktivität" nur die halbe Auskunft.
                          if (widget.library.geocoder == null) ...[
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              t.fortschrittOhneGeodaten,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: farben.onSurfaceVariant),
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
                    if (_vorschlaege.isNotEmpty) ...[
                      _Ueberschrift(t.aktivitaetenVorschlaege),
                      for (final v in _vorschlaege)
                        _Vorschlagskarte(
                          vorschlag: v,
                          onJa: () => _bestaetigen(v),
                          onNein: () => _verwerfen(v),
                        ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                    // Zwei Listen und nicht eine: Die Sonntagswanderung
                    // vor der Haustür sucht man anders als die Wanderung
                    // im Südtirol-Urlaub – die eine über das Datum, die
                    // andere über die Reise.
                    if (_ohneReise.isNotEmpty) ...[
                      _Ueberschrift(t.aktivitaetenOhneReise),
                      for (final k in _ohneReise)
                        Aktivitaetszeile(
                          aktivitaet: k,
                          library: widget.library,
                          reisename: null,
                          onTippen: () => _oeffnen(k),
                        ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                    if (_mitReise.isNotEmpty) ...[
                      _Ueberschrift(t.aktivitaetenBestaetigte),
                      for (final k in _mitReise)
                        Aktivitaetszeile(
                          aktivitaet: k,
                          library: widget.library,
                          reisename: _reisenamen[k.reiseId],
                          onTippen: () => _oeffnen(k),
                        ),
                    ],
                  ],
                ),
    );
  }
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
  final Aktivitaetsvorschlag vorschlag;
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
    final locale = Localizations.localeOf(context);
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
                Icon(symbolFuerArt(vorschlag.art), color: farben.primary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(vorschlag.name,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              [
                nameFuerArt(t, vorschlag.art),
                DateFormat.yMMMd(locale.toString()).format(vorschlag.von),
                dauertext(t, vorschlag.dauer),
                streckentext(t, locale, vorschlag.streckeKm),
                t.aktivitaetenAufnahmen(vorschlag.anzahl),
              ].join(' · '),
              style: TextStyle(fontSize: 13, color: farben.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: onNein, child: Text(t.aktivitaetenKeine)),
                const SizedBox(width: AppSpacing.sm),
                FilledButton(
                    onPressed: onJa, child: Text(t.aktivitaetenIstEine)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Eine Aktivität als Zeile – in der Liste und als Kapitel einer Reise.
class Aktivitaetszeile extends StatefulWidget {
  final AktivitaetenData aktivitaet;
  final LibraryState library;

  /// Der Name der Reise, zu der sie gehört – oder `null`. In der Liste
  /// einer Reise bleibt er weg: Dort wäre er bei jeder Zeile derselbe.
  final String? reisename;

  final VoidCallback onTippen;

  const Aktivitaetszeile({
    super.key,
    required this.aktivitaet,
    required this.library,
    required this.reisename,
    required this.onTippen,
  });

  @override
  State<Aktivitaetszeile> createState() => _AktivitaetszeileState();
}

class _AktivitaetszeileState extends State<Aktivitaetszeile> {
  /// Einmal beim Anlegen der Zeile geholt und nicht in `build` – sonst
  /// liefe die Abfrage bei jedem Neuaufbau erneut.
  late final Future<AssetData?> _bild =
      widget.library.db.ersteAufnahmeDerAktivitaet(widget.aktivitaet.id);

  @override
  Widget build(BuildContext context) {
    final t = AppTexte.of(context);
    final locale = Localizations.localeOf(context);
    final art = Aktivitaetsart.aus(widget.aktivitaet.art);
    final dauer = widget.aktivitaet.bis.difference(widget.aktivitaet.von);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: SizedBox(
          width: 52,
          height: 52,
          child: FutureBuilder<AssetData?>(
            future: _bild,
            builder: (context, schnappschuss) {
              final asset = schnappschuss.data;
              if (asset == null) {
                return Center(child: Icon(symbolFuerArt(art)));
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
        title: Row(
          children: [
            Icon(symbolFuerArt(art),
                size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.xs),
            Expanded(child: Text(widget.aktivitaet.name)),
          ],
        ),
        subtitle: Text([
          nameFuerArt(t, art),
          DateFormat.yMMMd(locale.toString()).format(widget.aktivitaet.von),
          dauertext(t, dauer),
          if (widget.reisename case final r?) t.aktivitaetenZuReise(r),
        ].join(' · ')),
        trailing: const Icon(Icons.chevron_right),
        onTap: widget.onTippen,
      ),
    );
  }
}
