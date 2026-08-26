import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../theme/app_spacing.dart';

/// Die verfügbaren Kartenstile.
///
/// Ein Aufzählungstyp und kein `bool dark` mehr: Ein dritter Stil passt
/// nicht in einen Wahrheitswert, und „hell oder eben nicht hell" hätte
/// bei jeder weiteren Ergänzung erneut umgebaut werden müssen.
enum Kartenstil {
  /// OpenStreetMap-Standard statt Google Maps: quelloffen, kein
  /// API-Schlüssel nötig – passt zur restlichen App (keine proprietären
  /// Cloud-Dienste ausser den einmaligen KI-Modell-Downloads, siehe
  /// README).
  hell(
    kachelUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    namensnennung: '© OpenStreetMap contributors',
  ),

  /// CARTO Dark Matter, ebenfalls quelloffen/kostenlos und ohne
  /// Schlüssel – passend zum permanent dunklen Farbschema der App.
  dunkel(
    kachelUrl: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
    unterbereiche: ['a', 'b', 'c', 'd'],
    namensnennung: '© OpenStreetMap contributors © CARTO',
  ),

  /// OpenTopoMap: Höhenlinien und Schummerung. Das Relief steckt in den
  /// Kacheln, nicht in einer 3D-Maschine – deshalb ist es hier ohne neue
  /// Abhängigkeit und auf allen drei Plattformen zu haben.
  ///
  /// **Nur bis Zoomstufe 17**, und das ist wichtiger als es klingt:
  /// Oberhalb davon antwortet der Server nicht etwa mit 404, sondern
  /// mit **HTTP 200 und einer einfarbigen Kachel**. An der Zugspitze
  /// nachgemessen:
  ///
  /// ```
  /// Zoom 16  200  53031 B  256 Farben
  /// Zoom 17  200  51161 B  255 Farben
  /// Zoom 18  200   4343 B    1 Farbe
  /// Zoom 19  200   4343 B    1 Farbe
  /// ```
  ///
  /// Ohne [hoechsteEchteStufe] wäre die Karte beim Hereinzoomen also
  /// schlicht leer – ohne Fehler, ohne Meldung, ohne Anhaltspunkt. Mit
  /// der Angabe vergrössert flutter_map die Kachel von Stufe 17.
  topo(
    kachelUrl: 'https://tile.opentopomap.org/{z}/{x}/{y}.png',
    namensnennung: '© OpenStreetMap contributors, SRTM | © opentopomap.org (CC-BY-SA)',
    hoechsteEchteStufe: 17,
  );

  const Kartenstil({
    required this.kachelUrl,
    required this.namensnennung,
    this.unterbereiche = const <String>[],
    this.hoechsteEchteStufe,
  });

  final String kachelUrl;
  final String namensnennung;
  final List<String> unterbereiche;

  /// Höchste Stufe, für die der Anbieter echte Kacheln liefert. `null`
  /// heisst „so weit wie die Karte zoomt".
  final int? hoechsteEchteStufe;
}

/// Liefert die Kacheln des gewählten Stils.
///
/// Ohne [stil] richtet sich das nach dem Theme – da die App aber permanent
/// dunkel eingefärbt ist (siehe main.dart), würde das nie helle Kacheln
/// liefern; [MapScreen] übergibt deshalb den vom Nutzer gewählten Stil
/// ausdrücklich, statt sich auf das App-Theme zu verlassen.
TileLayer buildMapTileLayer(BuildContext context, {Kartenstil? stil}) {
  final gewaehlt = stil ?? _ausTheme(context);
  return TileLayer(
    urlTemplate: gewaehlt.kachelUrl,
    subdomains: gewaehlt.unterbereiche,
    // 19 ist die Vorgabe von flutter_map; nur OpenTopoMap hoert
    // frueher auf.
    maxNativeZoom: gewaehlt.hoechsteEchteStufe ?? 19,
    // OpenTopoMap bittet ausdrücklich um einen aussagekräftigen
    // User-Agent statt der Vorgabe der Bibliothek.
    userAgentPackageName: 'com.example.photoVault',
  );
}

Kartenstil _ausTheme(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? Kartenstil.dunkel
        : Kartenstil.hell;

/// Die Namensnennung der Kartenanbieter – eine Auflage der Lizenz, also
/// muss sie lesbar bleiben.
///
/// Eigenhändig gebaut statt mit `SimpleAttributionWidget`: Jenes setzt den
/// Text in normaler Schriftgröße in eine Zeile fester Breite und stellt
/// ihm noch „flutter_map | ©" voran – ein Hinweis auf die verwendete
/// Programmbibliothek, der mit der Lizenz nichts zu tun hat. In der 340
/// Punkte breiten Info-Ansicht lief die Zeile dadurch um über 400 Punkte
/// über und wurde abgeschnitten; ausgerechnet die Namensnennung war damit
/// unvollständig. Hier steht sie klein, umbricht bei Bedarf und ist auf
/// zwei Drittel der Breite begrenzt, damit sie die Karte nicht zudeckt.
Widget buildMapAttribution(BuildContext context, {Kartenstil? stil}) {
  final gewaehlt = stil ?? _ausTheme(context);
  return Align(
    alignment: Alignment.bottomRight,
    child: LayoutBuilder(
      builder: (context, constraints) => ConstrainedBox(
        constraints: BoxConstraints(maxWidth: constraints.maxWidth * 2 / 3),
        child: ColoredBox(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.75),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              gewaehlt.namensnennung,
              style: TextStyle(
                fontSize: 9,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

const _defaultCenter = ll.LatLng(51.1657, 10.4515); // Mitte Deutschlands
const _defaultZoom = 5.0;
const _pinZoom = 14.0;

/// Kleine, eingebettete Kartenansicht für die Info-Ansicht eines einzelnen
/// Assets: zeigt den gespeicherten Ort als Marker. Ist [onLocationChanged]
/// gesetzt, lässt sich der Ort durch Antippen der Karte festlegen bzw.
/// korrigieren (z.B. wenn ein Video keine EXIF-GPS-Daten hat oder das Foto
/// am falschen Ort geotaggt wurde).
class MiniLocationMap extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final double height;
  final void Function(double latitude, double longitude)? onLocationChanged;

  /// `BorderRadius.zero` für randlose ("full bleed") Darstellung, z.B. am
  /// unteren Rand eines Panels (siehe AssetInfoSheet) statt als abgerundete
  /// Karte innerhalb eines gepolsterten Bereichs.
  final BorderRadius borderRadius;

  const MiniLocationMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.height = 160,
    this.onLocationChanged,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  bool get _hasLocation => latitude != null && longitude != null;

  @override
  Widget build(BuildContext context) {
    final center = _hasLocation ? ll.LatLng(latitude!, longitude!) : _defaultCenter;
    final editable = onLocationChanged != null;

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: _hasLocation ? _pinZoom : _defaultZoom,
                onTap: !editable
                    ? null
                    : (_, point) => onLocationChanged!(point.latitude, point.longitude),
              ),
              children: [
                buildMapTileLayer(context),
                buildMapAttribution(context),
                if (_hasLocation)
                  MarkerLayer(markers: [
                    Marker(
                      point: center,
                      width: 32,
                      height: 32,
                      alignment: Alignment.topCenter,
                      child: const Icon(Icons.location_pin, color: Colors.redAccent, size: 32),
                    ),
                  ]),
              ],
            ),
            if (!_hasLocation && editable)
              Positioned.fill(
                child: IgnorePointer(
                  child: ColoredBox(
                    color: Colors.black45,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Text(
                          AppTexte.of(context).karteTippenFuerOrt,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
