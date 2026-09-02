import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/eigenkarte.dart';
import '../theme/app_spacing.dart';
import 'mini_location_map.dart';

/// Was diese App an Kartenquellen kennt – als Auskunft, nicht zum
/// Anklicken.
///
/// **Warum eine Übersicht und nicht nur das Vorlagenmenü.** Die Vorlagen
/// stehen hinter einem Knopf, und dort sieht man immer nur eine Zeile.
/// Die Frage, um die es tatsächlich geht – „wie nah komme ich mit
/// welcher Karte heran, und was kostet mich das" – lässt sich nur
/// beantworten, wenn alle nebeneinanderstehen.
///
/// **Und warum in Metern.** Zoomstufen sind eine Erfindung der
/// Kartenserver. „Bis Stufe 17" sagt niemandem etwas, „bis rund 74 m"
/// schon (siehe [massstabMeter]).
class KartenquellenUebersicht extends StatelessWidget {
  const KartenquellenUebersicht({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppTexte.of(context);
    final farben = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Text(
            t.einstKartenquellenText,
            style: TextStyle(fontSize: 12, color: farben.onSurfaceVariant),
          ),
        ),
        Card(
          child: Column(
            children: [
              // Die drei mitgelieferten. Ihre Namen stehen in der
              // Oberfläche und nicht im Aufzählungstyp – deshalb hier und
              // nicht in [Kartenstil].
              _Zeile(
                symbol: Icons.light_mode_outlined,
                name: t.karteHell,
                stufe: Kartenstil.hell.hoechsteEchteStufe!,
                gemessen: true,
                mitgeliefert: true,
                nennung: Kartenstil.hell.namensnennung,
              ),
              _Zeile(
                symbol: Icons.dark_mode_outlined,
                name: t.karteDunkel,
                stufe: Kartenstil.dunkel.hoechsteEchteStufe!,
                gemessen: true,
                mitgeliefert: true,
                // Mit CARTO-Schlüssel kommen Kacheln in doppelter
                // Auflösung vom Server, ohne wird sie nachgebildet.
                hochaufloesend: cartoSchluessel != null,
                nennung: Kartenstil.dunkel.namensnennung,
              ),
              _Zeile(
                symbol: Icons.terrain_outlined,
                name: t.karteTopografie,
                stufe: Kartenstil.topo.hoechsteEchteStufe!,
                gemessen: true,
                mitgeliefert: true,
                nennung: Kartenstil.topo.namensnennung,
              ),
              const Divider(height: 1),
              for (final v in kartenvorlagen)
                _Zeile(
                  symbol: v.brauchtSchluessel
                      ? Icons.vpn_key_outlined
                      : Icons.public_outlined,
                  name: v.name,
                  stufe: v.stufe,
                  gemessen: v.gemessen,
                  mitgeliefert: false,
                  schluessel: v.brauchtSchluessel,
                  hochaufloesend: v.url.contains('{r}'),
                  nennung: v.nennung,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Zeile extends StatelessWidget {
  const _Zeile({
    required this.symbol,
    required this.name,
    required this.stufe,
    required this.gemessen,
    required this.mitgeliefert,
    required this.nennung,
    this.schluessel = false,
    this.hochaufloesend = false,
  });

  final IconData symbol;
  final String name;
  final int stufe;
  final bool gemessen;
  final bool mitgeliefert;
  final bool schluessel;
  final bool hochaufloesend;
  final String nennung;

  @override
  Widget build(BuildContext context) {
    final t = AppTexte.of(context);
    final farben = Theme.of(context).colorScheme;
    final meter = massstabMeter(stufe);
    // Unter tausend Metern ganze Meter, darüber Kilometer – eine
    // Nachkommastelle bei 1.234 m wäre eine Genauigkeit, die die
    // Rechnung gar nicht hat.
    final massstab = meter >= 1000
        ? '${(meter / 1000).toStringAsFixed(1)} km'
        : '${meter.round()} m';

    // Was auf DIESEM Bildschirm passiert, nicht was allgemein möglich
    // wäre: Auf einem gewöhnlichen Bildschirm ist die doppelte Auflösung
    // gar kein Thema, und ein Hinweis darauf wäre nur Lärm.
    final dicht = MediaQuery.of(context).devicePixelRatio > 1.0;
    final marken = <String>[
      mitgeliefert
          ? t.einstKartenquellenMitgeliefert
          : t.einstKartenquellenVorlage,
      gemessen
          ? t.einstKartenquellenGemessen
          : t.einstKartenquellenLautAnbieter,
      if (schluessel) t.einstKartenquellenSchluessel,
      if (dicht && hochaufloesend) t.einstKartenquellenHochaufloesend,
      if (dicht && !hochaufloesend) t.einstKartenquellenSimuliert,
    ];

    return ListTile(
      dense: true,
      leading: Icon(symbol, size: 20, color: farben.onSurfaceVariant),
      title: Text(name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.einstKartenquellenTiefe('$stufe', massstab),
            style: TextStyle(fontSize: 12, color: farben.onSurfaceVariant),
          ),
          Text(
            [...marken, nennung].join(' · '),
            style: TextStyle(fontSize: 11, color: farben.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
