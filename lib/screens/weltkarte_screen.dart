import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../db/database.dart';
import '../l10n/app_localizations.dart';
import '../services/reisefortschritt.dart';
import '../services/reverse_geocoder.dart';
import '../state/library_state.dart';
import '../theme/app_spacing.dart';
import '../widgets/mini_location_map.dart'
    show buildMapAttribution, buildMapTileLayer, kartenHoechsteStufe;

/// Die Welt als Karte: wo du warst, und wo du hinwillst.
///
/// **Die Karte zeigt zwei verschiedene Dinge und sagt welches.** Was aus
/// den Fotos kommt, ist ein Beleg; was von Hand gesetzt wurde, eine
/// Angabe. Sie sehen deshalb nicht gleich aus – ein Punkt, dem man nicht
/// ansieht, woher er stammt, ist die Sorte Karte, der man nach einem Jahr
/// nicht mehr glaubt.
class WeltkarteScreen extends StatefulWidget {
  final LibraryState library;
  const WeltkarteScreen({super.key, required this.library});

  @override
  State<WeltkarteScreen> createState() => _WeltkarteScreenState();
}

/// Welche Art Marke ein Punkt auf der Karte ist.
enum _Ebene { land, region, ort }

/// Ein Punkt auf der Weltkarte.
class _Kartenpunkt {
  final _Ebene ebene;
  final String schluessel;
  final String name;
  final double breite;
  final double laenge;

  /// Wie viele Aufnahmen dahinterstehen. 0 heisst: nur von Hand gesetzt.
  final int aufnahmen;

  final Markenart? marke;

  const _Kartenpunkt({
    required this.ebene,
    required this.schluessel,
    required this.name,
    required this.breite,
    required this.laenge,
    required this.aufnahmen,
    required this.marke,
  });

  bool get belegt => aufnahmen > 0;
  bool get geplant => marke == Markenart.geplant && !belegt;
}

class _WeltkarteScreenState extends State<WeltkarteScreen> {
  final _karte = MapController();
  List<_Kartenpunkt>? _punkte;
  final _sichtbar = {_Ebene.land, _Ebene.region, _Ebene.ort};

  @override
  void initState() {
    super.initState();
    _laden();
  }

  Future<void> _laden() async {
    final geo = widget.library.geocoder;
    if (geo == null) {
      if (mounted) setState(() => _punkte = const []);
      return;
    }
    final besucht = await widget.library.db.besuchteOrte();
    final marken = await widget.library.db.alleOrtsmarken();
    if (!mounted) return;
    setState(() => _punkte = _sammle(geo, besucht, marken));
  }

  /// Baut aus Fotos und Marken die Punktmenge.
  ///
  /// Fotos zuerst, Marken danach: Eine Marke auf einem Land, aus dem es
  /// ohnehin Fotos gibt, soll den Punkt nicht verdoppeln, sondern ihn
  /// zusätzlich als „von Hand" ausweisen.
  List<_Kartenpunkt> _sammle(
    ReverseGeocoder geo,
    List<Besuchsangabe> besucht,
    List<OrtsmarkenData> marken,
  ) {
    final aufnahmenJeLand = <String, int>{};
    final regionen = <String, String>{}; // Code -> Name
    final orte = <String, ({String name, String iso})>{};

    for (final a in besucht) {
      final land = a.land;
      if (land == null) continue;
      final iso = geo.isoNachName[land];
      if (iso == null) continue;
      aufnahmenJeLand[iso] = (aufnahmenJeLand[iso] ?? 0) + a.anzahl;
      final region = a.region;
      if (region != null && region.isNotEmpty) {
        final code = geo.regionscodes['$iso|$region'];
        if (code != null) regionen[code] = region;
      }
      final ort = a.ort;
      if (ort != null && ort.isNotEmpty) orte['$iso|$ort'] = (name: ort, iso: iso);
    }

    final landmarken = <String, Markenart>{};
    final regionsmarken = <String, Markenart>{};
    final ortsmarken = <String, Markenart>{};
    for (final m in marken) {
      final wert =
          m.status == 'geplant' ? Markenart.geplant : Markenart.besucht;
      switch (m.art) {
        case 'land':
          landmarken[m.schluessel.toUpperCase()] = wert;
        case 'region':
          regionsmarken[m.schluessel] = wert;
          regionen.putIfAbsent(m.schluessel, () => m.name);
        case 'ort':
          final teile = m.schluessel.split('|');
          if (teile.length < 3) continue;
          final iso = geo.isoNachName[teile[0]] ?? teile[0].toUpperCase();
          ortsmarken['$iso|${teile[2]}'] = wert;
          orte.putIfAbsent(
              '$iso|${teile[2]}', () => (name: teile[2], iso: iso));
      }
    }

    final ergebnis = <_Kartenpunkt>[];

    for (final iso in {...aufnahmenJeLand.keys, ...landmarken.keys}) {
      final punkt = geo.landpunkt(iso);
      if (punkt == null) continue;
      ergebnis.add(_Kartenpunkt(
        ebene: _Ebene.land,
        schluessel: iso,
        name: geo.laenderkatalog.nachIso(iso)?.name ?? iso,
        breite: punkt.breite,
        laenge: punkt.laenge,
        aufnahmen: aufnahmenJeLand[iso] ?? 0,
        marke: landmarken[iso],
      ));
    }

    for (final e in regionen.entries) {
      final punkt = geo.regionspunkt(e.key);
      if (punkt == null) continue;
      ergebnis.add(_Kartenpunkt(
        ebene: _Ebene.region,
        schluessel: e.key,
        name: e.value,
        breite: punkt.breite,
        laenge: punkt.laenge,
        // Eine Region gilt als belegt, sobald ein Foto sie nennt – die
        // Zahl der Aufnahmen steht am Land, nicht hier.
        aufnahmen: regionsmarken.containsKey(e.key) ? 0 : 1,
        marke: regionsmarken[e.key],
      ));
    }

    for (final e in orte.entries) {
      final punkt = geo.ortspunkt(e.value.iso, e.value.name);
      if (punkt == null) continue;
      ergebnis.add(_Kartenpunkt(
        ebene: _Ebene.ort,
        schluessel: e.key,
        name: e.value.name,
        breite: punkt.breite,
        laenge: punkt.laenge,
        aufnahmen: ortsmarken.containsKey(e.key) ? 0 : 1,
        marke: ortsmarken[e.key],
      ));
    }

    return ergebnis;
  }

  /// Ein Tippen auf die freie Fläche.
  Future<void> _stelleGewaehlt(ll.LatLng punkt) async {
    final geo = widget.library.geocoder;
    final t = AppTexte.of(context);
    final treffer = geo?.lookup(punkt.latitude, punkt.longitude);
    if (geo == null || treffer == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.weltkarteKeinOrt)));
      return;
    }
    final iso = treffer.country == null
        ? null
        : geo.isoNachName[treffer.country!];
    await showModalBottomSheet<void>(
      context: context,
      builder: (blatt) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(t.weltkarteNaechsterOrt(treffer.city)),
              subtitle: Text(t.weltkarteHinweis),
              subtitleTextStyle: TextStyle(
                  fontSize: 12,
                  color: Theme.of(blatt).colorScheme.onSurfaceVariant),
            ),
            const Divider(height: 1),
            if (iso != null && treffer.country != null)
              ListTile(
                leading: const Icon(Icons.public),
                title: Text(t.weltkarteAlsLand(treffer.country!)),
                onTap: () {
                  Navigator.pop(blatt);
                  _setze('land', iso, treffer.country!);
                },
              ),
            if (iso != null && treffer.state != null)
              ListTile(
                leading: const Icon(Icons.map_outlined),
                title: Text(t.weltkarteAlsRegion(treffer.state!)),
                onTap: () {
                  Navigator.pop(blatt);
                  final code = geo.regionscodes['$iso|${treffer.state}'];
                  if (code != null) _setze('region', code, treffer.state!);
                },
              ),
            ListTile(
              leading: const Icon(Icons.place_outlined),
              title: Text(t.weltkarteAlsOrt(treffer.city)),
              onTap: () {
                Navigator.pop(blatt);
                _setze(
                  'ort',
                  '${treffer.country ?? ''}|${treffer.state ?? ''}|${treffer.city}',
                  treffer.city,
                  breite: punkt.latitude,
                  laenge: punkt.longitude,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setze(String art, String schluessel, String name,
      {double? breite, double? laenge}) async {
    await widget.library.db.setzeOrtsmarke(OrtsmarkenCompanion.insert(
      art: art,
      schluessel: schluessel,
      name: name,
      status: 'besucht',
      angelegtAm: DateTime.now(),
      breite: Value(breite),
      laenge: Value(laenge),
    ));
    await _laden();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTexte.of(context).weltkarteMarkeGesetzt(name))));
  }

  Future<void> _punktGewaehlt(_Kartenpunkt p) async {
    final t = AppTexte.of(context);
    await showModalBottomSheet<void>(
      context: context,
      builder: (blatt) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(p.name),
              subtitle: Text(p.belegt
                  ? t.laenderAufnahmen(p.aufnahmen)
                  : t.laenderVonHand),
            ),
            const Divider(height: 1),
            if (p.marke != Markenart.besucht)
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: Text(t.laenderMarkeBesucht),
                onTap: () {
                  Navigator.pop(blatt);
                  _setze(p.ebene.name, p.schluessel, p.name);
                },
              ),
            if (p.marke != null)
              ListTile(
                leading: const Icon(Icons.remove_circle_outline),
                title: Text(t.laenderMarkeWeg),
                onTap: () {
                  Navigator.pop(blatt);
                  _entferne(p);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _entferne(_Kartenpunkt p) async {
    await widget.library.db.loescheOrtsmarke(p.ebene.name, p.schluessel);
    await _laden();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTexte.of(context);
    final punkte = _punkte;
    return Scaffold(
      appBar: AppBar(title: Text(t.weltkarteTitel)),
      body: punkte == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _karte,
                  options: MapOptions(
                    initialCenter: const ll.LatLng(30, 10),
                    initialZoom: 2,
                    maxZoom: kartenHoechsteStufe(context),
                    onTap: (_, punkt) => _stelleGewaehlt(punkt),
                  ),
                  children: [
                    buildMapTileLayer(context),
                    MarkerLayer(markers: [
                      // Länder zuletzt, damit sie über den Orten liegen –
                      // sonst verdeckt eine Stadt ihr eigenes Land.
                      for (final ebene in [_Ebene.ort, _Ebene.region, _Ebene.land])
                        if (_sichtbar.contains(ebene))
                          for (final p in punkte)
                            if (p.ebene == ebene)
                              Marker(
                                point: ll.LatLng(p.breite, p.laenge),
                                width: 26,
                                height: 26,
                                child: GestureDetector(
                                  onTap: () => _punktGewaehlt(p),
                                  child: _Marke(punkt: p),
                                ),
                              ),
                    ]),
                    buildMapAttribution(context),
                  ],
                ),
                Positioned(
                  left: AppSpacing.sm,
                  top: AppSpacing.sm,
                  child: _Ebenenwahl(
                    sichtbar: _sichtbar,
                    beiWechsel: (ebene, an) => setState(() {
                      if (an) {
                        _sichtbar.add(ebene);
                      } else {
                        _sichtbar.remove(ebene);
                      }
                    }),
                  ),
                ),
              ],
            ),
    );
  }
}

/// Ein Punkt auf der Karte.
///
/// Belegt, von Hand oder geplant unterscheiden sich in **Füllung und
/// Rand**, nicht nur im Farbton: Drei Zustände, die man nur an der Farbe
/// auseinanderhält, sind für einen Rotgrünblinden ein Zustand.
class _Marke extends StatelessWidget {
  final _Kartenpunkt punkt;
  const _Marke({required this.punkt});

  @override
  Widget build(BuildContext context) {
    final farben = Theme.of(context).colorScheme;
    final gross = punkt.ebene == _Ebene.land;
    final groesse = gross ? 18.0 : (punkt.ebene == _Ebene.region ? 13.0 : 10.0);
    final farbe = punkt.geplant ? farben.secondary : farben.primary;
    return Tooltip(
      message: punkt.name,
      child: Center(
        child: Container(
          width: groesse,
          height: groesse,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Geplantes bleibt hohl. Was belegt ist, ist gefüllt.
            color: punkt.geplant ? Colors.transparent : farbe,
            border: Border.all(
              color: punkt.geplant ? farbe : Colors.white,
              width: punkt.geplant ? 2.5 : 1.5,
            ),
          ),
          // Von Hand gesetzt, ohne ein einziges Foto: ein Punkt in der
          // Mitte. Damit sieht man einer Marke an, worauf sie beruht.
          child: punkt.belegt || punkt.geplant
              ? null
              : Center(
                  child: Container(
                    width: groesse / 3,
                    height: groesse / 3,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white),
                  ),
                ),
        ),
      ),
    );
  }
}

/// Welche Ebenen die Karte zeigt.
class _Ebenenwahl extends StatelessWidget {
  final Set<_Ebene> sichtbar;
  final void Function(_Ebene, bool) beiWechsel;

  const _Ebenenwahl({required this.sichtbar, required this.beiWechsel});

  @override
  Widget build(BuildContext context) {
    final t = AppTexte.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.weltkarteEbenen,
                style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: AppSpacing.xs),
            for (final (ebene, text) in [
              (_Ebene.land, t.weltkarteLaender),
              (_Ebene.region, t.weltkarteRegionen),
              (_Ebene.ort, t.weltkarteOrte),
            ])
              SizedBox(
                height: 32,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      visualDensity: VisualDensity.compact,
                      value: sichtbar.contains(ebene),
                      onChanged: (an) => beiWechsel(ebene, an ?? false),
                    ),
                    Text(text),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
