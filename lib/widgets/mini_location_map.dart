import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart';
import 'package:http/retry.dart';
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
    // Ausdrücklich, nicht über die Vorgabe: Ab Stufe 20 antwortet der
    // Server mit 400, nachgemessen.
    hoechsteEchteStufe: 19,
  ),

  /// CARTO Dark Matter, ebenfalls quelloffen/kostenlos und ohne
  /// Schlüssel – passend zum permanent dunklen Farbschema der App.
  dunkel(
    kachelUrl: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
    unterbereiche: ['a', 'b', 'c', 'd'],
    namensnennung: '© OpenStreetMap contributors © CARTO',
    // Eine Stufe weiter als OSM: An echten Abrufen nachgemessen liefert
    // CARTO auch auf Stufe 20 noch gezeichnete Kacheln, während OSM dort
    // bereits mit 400 antwortet.
    hoechsteEchteStufe: 20,
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

  /// Bis hierhin darf die Karte zoomen.
  ///
  /// **Ohne diese Grenze zoomt die Karte ins Nichts.** Oberhalb der
  /// echten Stufe vergrössert flutter_map die letzte vorhandene Kachel
  /// weiter und weiter: auf Anzeigestufe 24 deckt eine einzige
  /// Topo-Kachel 32.768 Punkte ab, auf Stufe 28 über eine halbe Million.
  /// So etwas kann keine Grafikeinheit mehr zeichnen – und am Bildschirm
  /// sieht es aus, als würden die Kacheln „nicht mehr laden".
  ///
  /// Zwei Stufen darüber sind bewusst erlaubt statt hart bei der echten
  /// Stufe abzuschneiden: Die Kachel wird dabei vierfach vergrössert,
  /// also unschärfer, aber sie ist **da**. Ein hartes Ende fühlte sich
  /// wie ein Defekt an, ein leerer Bildschirm erst recht.
  ///
  /// An den Servern nachgemessen, mitten in Berlin:
  ///
  /// ```
  /// OSM     z19 200,  z20 400            -> harte Grenze bei 19
  /// CARTO   z20 200 (3.765 B, Inhalt)    -> trägt bis 20
  /// Topo    z17 200,  z18 200 aber 4.343 B einfarbig -> Ende bei 17
  /// ```
  int get hoechsteAnzeigeStufe => (hoechsteEchteStufe ?? 19) + 2;
}

/// Wie lange eine einmal geholte Kachel als frisch gilt.
///
/// **Ohne diese Angabe richtet sich flutter_map nach `max-age` der
/// Antwort – und genau dort liegt das Problem.** OpenTopoMap rendert
/// Kacheln bei Bedarf und gibt ausgerechnet den frisch gerenderten die
/// kürzeste Haltbarkeit. Gemessen an echten Abrufen:
///
/// ```
/// x-cache-status: MISS   max-age=15875   (4,4 h)   Abruf 1,72 s
/// x-cache-status: MISS   max-age=13615   (3,8 h)   Abruf 1,63 s
/// x-cache-status: MISS   max-age=12590   (3,5 h)   Abruf 1,48 s
/// vorgerendert           max-age=604800  (7 Tage)  Abruf 0,09 s
/// ```
///
/// Die teuersten Kacheln laufen also nach wenigen Stunden ab, und
/// flutter_map macht dann **vor** der Anzeige einen blockierenden
/// Rückfrage-Umlauf. Am selben Ort einen Tag später wartet man erneut.
///
/// Dreissig Tage sind hier vertretbar: Höhenlinien und Geländeschatten
/// ändern sich über Jahre, nicht über Stunden, und die Karte ist
/// Hintergrund für Fotopins, kein Navigationsgerät. Es schont zugleich
/// die freiwillig betriebenen Kachelserver.
const kartenKachelFrische = Duration(days: 30);

/// Obergrenze des Kachelspeichers auf der Platte.
///
/// Die Vorgabe von flutter_map ist 1 GB. Für eine Fotoverwaltung, deren
/// Karte ein Nebenschauplatz ist, wäre das viel; 300 MB fassen mehrere
/// zehntausend Kacheln.
const kartenSpeicherGrenze = 300 * 1024 * 1024;

/// Richtet den Kachelspeicher ein. **Einmal beim Start, vor der ersten
/// Karte.**
///
/// Der Weg über `getOrCreateInstance` ist Absicht und der Grund, warum
/// hier kein eigener `NetworkTileProvider` gebaut wird: Der Speicher ist
/// ein Einzelstück, dessen Angaben nur beim ERSTEN Aufruf wirken.
/// flutter_map holt sich später von sich aus dasselbe Stück – und
/// bekommt damit unsere Einstellungen, ohne dass wir uns in die
/// Kachelabfrage einmischen müssen.
///
/// Ein eigener `NetworkTileProvider` wäre die naheliegende Lösung
/// gewesen und wäre ein Leck geworden: [buildMapTileLayer] läuft bei
/// jedem Neuaufbau, `TileLayer.didUpdateWidget` entsorgt den alten
/// Anbieter aber nicht – jeder Aufbau hinterliesse einen offenen
/// HTTP-Client.
void kartenSpeicherEinrichten() =>
    BuiltInMapCachingProvider.getOrCreateInstance(
      overrideFreshAge: kartenKachelFrische,
      maxCacheSize: kartenSpeicherGrenze,
    );

/// Bei welchen Statuscodes ein zweiter Versuch sinnvoll ist.
///
/// **404 steht hier mit Absicht, und das ist der Kern der Sache.**
/// OpenTopoMap rendert Kacheln bei Bedarf; ist eine noch nicht fertig,
/// antwortet der Server nicht mit „warte", sondern mit 404. An einer
/// echten Kartenfahrt im Alpenraum gemessen:
///
/// ```
/// 170 Kachelabrufe -> 126 x 200, 44 x 404   (alle auf Stufe 17)
/// dieselben 404-Kacheln Sekunden später -> 200, in 70-90 ms
/// ```
///
/// Dieselbe Fahrt kurz darauf: 142 Abrufe, kein einziger Fehler. Es ist
/// also nichts, was man beim Programmieren sieht – und für den
/// Betrachter bleibt eine graue Lücke im Kartenbild, dauerhaft.
///
/// Denn ohne diese Liste hilft niemand nach: Der Vorgabe-[RetryClient]
/// von flutter_map wiederholt **allein bei 503**, und
/// [EvictErrorTileStrategy.none] behält die gescheiterte Kachel für
/// immer. Ein einziger Fehlschlag wird so zu einem Loch, das bis zum
/// nächsten Programmstart bleibt.
///
/// Bei OSM und CARTO ist ein 404 dagegen echt. Der Preis dafür sind
/// zwei überflüssige Abrufe für eine Kachel, die es ohnehin nicht gibt –
/// gegenüber einer Lücke im Bild ist das der bessere Handel.
bool kachelNochmalVersuchen(int status) =>
    status == 404 || // noch nicht gerendert, siehe oben
    status == 408 || // Zeitüberschreitung beim Server
    status == 429 || // zu viele Abrufe, gleich wieder gut
    (status >= 500 && status < 600);

/// Ob ein geworfener Fehler einen zweiten Versuch verdient.
///
/// Abgebrochene Abrufe gehören ausdrücklich **nicht** dazu: flutter_map
/// bricht selbst ab, wenn eine Kachel beim schnellen Ziehen gar nicht
/// mehr gebraucht wird. Die zu wiederholen hiesse, dem Server Arbeit für
/// Bilder aufzuladen, die niemand mehr sieht.
bool kachelFehlerNochmalVersuchen(Object fehler) {
  if (fehler is ClientException) {
    final m = fehler.message.toLowerCase();
    if (m.contains('cancel') || m.contains('abort')) return false;
    return true;
  }
  return fehler is SocketException ||
      fehler is HttpException ||
      fehler is TimeoutException;
}

/// Wartezeit vor dem Versuch nach dem [versuch]-ten Fehlschlag.
///
/// Kurz genug, dass die Kachel noch im Bild ist, wenn sie ankommt, und
/// lang genug, dass ein Renderer sie fertigstellen kann. Zwei Versuche
/// sind die Obergrenze: Die Kachelserver werden gespendet.
Duration kachelWartezeit(int versuch) =>
    Duration(milliseconds: 400 * (versuch + 1) * (versuch + 1));

/// Wie oft ein gescheiterter Kachelabruf wiederholt wird.
const kachelVersuche = 2;

NetworkTileProvider? _kachelAnbieter;

/// Der gemeinsame Kachelanbieter samt Wiederholungen.
///
/// Ein **Einzelstück**, aus demselben Grund wie beim Speicher: Ein
/// eigener Anbieter je Aufbau wäre ein Leck, denn
/// `TileLayer.didUpdateWidget` entsorgt den alten nicht. Hier ist es
/// zusätzlich ungefährlich, den einen weiterzureichen – der Anbieter
/// schliesst in `dispose()` nur einen selbst erzeugten HTTP-Client, und
/// unserer wird von aussen übergeben.
NetworkTileProvider kartenKachelAnbieter() => _kachelAnbieter ??=
    NetworkTileProvider(
      httpClient: RetryClient(
        Client(),
        retries: kachelVersuche,
        when: (antwort) => kachelNochmalVersuchen(antwort.statusCode),
        whenError: (fehler, _) => kachelFehlerNochmalVersuchen(fehler),
        delay: kachelWartezeit,
      ),
    );

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
    tileProvider: kartenKachelAnbieter(),
    // Bleibt eine Kachel auch nach den Wiederholungen aus, wird sie
    // beim Wegscrollen weggeworfen statt behalten. Die Vorgabe
    // `none` hiesse: Wer zu der Stelle zurückkehrt, sieht dieselbe
    // Lücke wieder - ohne dass je ein neuer Versuch stattfände.
    evictErrorTileStrategy: EvictErrorTileStrategy.notVisible,
  );
}

Kartenstil _ausTheme(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? Kartenstil.dunkel
        : Kartenstil.hell;

/// Die höchste Zoomstufe, die für den gerade geltenden Stil sinnvoll ist.
///
/// Öffentlich, damit jede Karte in dieser App dieselbe Grenze setzen kann
/// – auch die, die nicht in dieser Datei steht. Ohne Grenze zoomt
/// flutter_map unbegrenzt weiter und fordert Kacheln an, die es nicht
/// gibt (siehe zoomgrenze_test.dart, das genau darauf besteht).
double kartenHoechsteStufe(BuildContext context, {Kartenstil? stil}) =>
    (stil ?? _ausTheme(context)).hoechsteAnzeigeStufe.toDouble();

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
                // Auch hier: ohne Grenze zoomt die Karte ueber die
                // vorhandenen Kacheln hinaus – siehe
                // [Kartenstil.hoechsteAnzeigeStufe].
                maxZoom: _ausTheme(context).hoechsteAnzeigeStufe.toDouble(),
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
