import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../theme/app_spacing.dart';

/// OpenStreetMap statt Google Maps: quelloffen, kein API-Key nötig – passt
/// zur restlichen App (keine proprietären Cloud-Diensten außer den
/// einmaligen KI-Modell-Downloads, siehe README).
const kOsmTileUrlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const kOsmAttribution = '© OpenStreetMap contributors';

/// Dunkle Kartenkacheln (CARTO Dark Matter, ebenfalls quelloffen/kostenlos,
/// kein API-Key nötig) – passend zum permanent dunklen Farbschema der App
/// (siehe main.dart), statt der hellen Standard-OSM-Kacheln.
const kOsmDarkTileUrlTemplate = 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png';
const kOsmDarkSubdomains = ['a', 'b', 'c', 'd'];
const kOsmDarkAttribution = '© OpenStreetMap contributors © CARTO';

/// Liefert die passenden Kartenkacheln/-attribution. Ohne [dark] richtet
/// sich das nach dem Theme – da die App aber permanent dunkel eingefärbt
/// ist (siehe main.dart), würde das nie helle Kacheln liefern; [MapScreen]
/// übergibt deshalb den vom Nutzer gewählten Kartenmodus explizit, statt
/// sich auf das App-Theme zu verlassen.
TileLayer buildMapTileLayer(BuildContext context, {bool? dark}) {
  final isDark = dark ?? Theme.of(context).brightness == Brightness.dark;
  return TileLayer(
    urlTemplate: isDark ? kOsmDarkTileUrlTemplate : kOsmTileUrlTemplate,
    subdomains: isDark ? kOsmDarkSubdomains : const [],
    userAgentPackageName: 'com.example.photoVault',
  );
}

Widget buildMapAttribution(BuildContext context, {bool? dark}) {
  final isDark = dark ?? Theme.of(context).brightness == Brightness.dark;
  return SimpleAttributionWidget(source: Text(isDark ? kOsmDarkAttribution : kOsmAttribution));
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
              const Positioned.fill(
                child: IgnorePointer(
                  child: ColoredBox(
                    color: Colors.black45,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Text(
                          'Tippen, um einen Ort festzulegen',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
