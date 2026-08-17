import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_earth_globe/flutter_earth_globe.dart';
import 'package:flutter_earth_globe/flutter_earth_globe_controller.dart';
import 'package:flutter_earth_globe/globe_coordinates.dart';
import 'package:flutter_earth_globe/point.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../db/database.dart';
import '../l10n/app_localizations.dart';
import '../services/storage_paths.dart';
import '../state/library_state.dart';
import '../theme/app_spacing.dart';
import '../widgets/mini_location_map.dart';
import '../widgets/pin_dialogs.dart';
import 'asset_viewer_screen.dart';

/// Die drei Darstellungen der Kartenansicht: helle/dunkle flache Karte
/// (OpenStreetMap-Kacheln) oder ein interaktiver 3D-Globus. Bewusst als
/// eigener, vom Nutzer gewählter Zustand statt am App-Theme (siehe
/// [buildMapTileLayer]) – die App ist permanent dunkel eingefärbt, ohne
/// diesen Umschalter gäbe es also nie helle Kacheln zu sehen.
enum _MapViewMode { light, dark, globe }

/// Scrollbare Kartenansicht (OpenStreetMap) über alle Fotos/Videos mit
/// bekanntem Ort – aus EXIF-GPS-Daten beim Import übernommen oder manuell in
/// der Info-Ansicht eines Assets gesetzt (siehe [AssetInfoSheet]).
class MapScreen extends StatefulWidget {
  final LibraryState library;
  const MapScreen({super.key, required this.library});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<AssetData>? _located;
  _MapViewMode _mode = _MapViewMode.dark;

  // Lazy angelegt (GPU-Shader-Ressourcen) und nur befüllt, solange der
  // Globus-Modus tatsächlich schon einmal aktiv war – wer nie in den
  // Globus-Modus wechselt, zahlt dafür auch keine Rendering-Kosten.
  FlutterEarthGlobeController? _globeController;
  bool _globePointsSynced = false;
  double? _lastGroupedZoomBucket;

  // Zuletzt genutzte flache Kartenansicht (Hell/Dunkel) – Ziel, wenn man
  // vom Globus über einen Pin "auf die Karte springt" (siehe
  // [_jumpToFlatMap]), statt dafür immer Dunkel zu erzwingen.
  _MapViewMode _lastFlatMode = _MapViewMode.dark;

  // Von [_jumpToFlatMap] gesetzt, um die nächste flache Karte auf einen
  // bestimmten Ort statt auf den Durchschnitt aller Fotos zu zentrieren –
  // der Globus zeigt selbst bei starkem Reinzoomen keine Straßendetails
  // (siehe _ensureGlobeController), ein Pin-Tap springt deshalb direkt in
  // die kachelbasierte OSM-Karte an genau dieser Stelle.
  ll.LatLng? _pendingFlatFocus;
  double? _pendingFlatZoom;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    // Kein `_globeController?.dispose()` hier: `RotatingGlobeState.dispose()`
    // (im FlutterEarthGlobe-Widget selbst) räumt dessen internen
    // rotationController bereits auf, sobald das Widget beim Tab-Wechsel
    // aus dem Baum entfernt wird. Ein zusätzlicher Aufruf hier würde genau
    // diesen AnimationController ein zweites Mal disposen ("disposed more
    // than once") – reproduzierbar beim Verlassen der Kartenansicht, nachdem
    // der Globus-Modus einmal genutzt wurde.
    super.dispose();
  }

  Future<void> _load() async {
    final assets = await widget.library.db.assetsWithLocation();
    if (!mounted) return;
    setState(() => _located = assets);
    _globePointsSynced = false;
    if (_mode == _MapViewMode.globe) _syncGlobePoints(focus: true);
  }

  void _openAsset(List<AssetData> assets, AssetData asset) {
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (_) => AssetViewerScreen(
            assets: assets,
            initialIndex: assets.indexOf(asset),
            paths: widget.library.paths,
            db: widget.library.db,
            library: widget.library,
            onToggleFavorite: (a) => widget.library.db.setFavorite(a.id, !a.isFavorite),
            onDelete: (a) => widget.library.db.moveToTrash([a.id]),
            onLock: (a) async {
              if (await ensureVaultUnlocked(context, widget.library)) {
                await widget.library.lockAsset(a);
              }
            },
          ),
        ))
        // Nach Rückkehr neu laden – der Ort könnte in der Info-Ansicht
        // geändert oder entfernt worden sein.
        .then((_) => _load());
  }

  ll.LatLng _averageCenter(List<AssetData> assets) {
    var latSum = 0.0, lngSum = 0.0;
    for (final a in assets) {
      latSum += a.latitude!;
      lngSum += a.longitude!;
    }
    return ll.LatLng(latSum / assets.length, lngSum / assets.length);
  }

  /// Rastergröße (in Grad) für [_groupForGlobe] – abhängig vom aktuellen
  /// Zoom, damit dicht beieinanderliegende Fotos beim Reinzoomen sichtbar
  /// auseinanderrücken statt für immer an einem Punkt zu kleben. Grob
  /// 33km beim Herausgezoomten Überblick (verhindert hunderte überlappende
  /// Punkte auf der kleinen Kugelfläche), bis knapp über GPS-Genauigkeit
  /// (~55m) beim tiefsten unterstützten Zoom.
  double _gridDegreesForZoom(double zoom) {
    final scale = math.pow(2.0, zoom).toDouble();
    return (0.3 / scale).clamp(0.0005, 0.3);
  }

  Map<String, List<AssetData>> _groupForGlobe(List<AssetData> assets, double gridDegrees) {
    final groups = <String, List<AssetData>>{};
    for (final a in assets) {
      final latKey = (a.latitude! / gridDegrees).round();
      final lngKey = (a.longitude! / gridDegrees).round();
      final key = '$latKey,$lngKey';
      groups.putIfAbsent(key, () => []).add(a);
    }
    return groups;
  }

  FlutterEarthGlobeController _ensureGlobeController() {
    return _globeController ??= FlutterEarthGlobeController(
      surface: const AssetImage('assets/globe/2k_earth_daymap.jpg'),
      background: const AssetImage('assets/globe/2k_stars_milky_way.jpg'),
      isRotating: false,
      // 0 statt des Standards 1 – der gerenderte Radius ist
      // `radius * 2^zoom` (siehe RotatingGlobe.convertedRadius), Zoom 1
      // würde den Globus also schon beim Öffnen auf die doppelte Größe
      // vergrößern und nur einen Ausschnitt statt der ganzen Erde zeigen.
      zoom: 0,
      // Deutlich höher als der Bibliotheks-Standard (2.5): einzelne Fotos
      // innerhalb einer Stadt lassen sich erst bei starkem Reinzoomen
      // auseinanderhalten (siehe _gridDegreesForZoom). Straßen-/Gebäude-
      // Detailgrad zeigt aber selbst dieser Zoom nicht – die Erdtextur ist
      // ein einzelnes, niedrig aufgelöstes (2048×1024px) Bild ohne
      // Kachel-Nachladen wie bei der flachen Karte; dafür bleibt die
      // Hell/Dunkel-Kartenansicht (echte OSM-Kacheln) die richtige Wahl.
      maxZoom: 6,
    );
  }

  /// [focus] zentriert den Globus einmalig auf den Fotos (beim ersten
  /// Aktivieren des Globus-Modus bzw. nach einem Reload) – beim erneuten
  /// Gruppieren wegen eines Zoom-Wechsels (siehe [_onGlobeZoomChanged])
  /// bewusst false, sonst würde jede Neugruppierung die eigene
  /// Zoom-/Dreh-Position des Nutzers wieder zurücksetzen.
  void _syncGlobePoints({double zoom = 0, bool focus = false}) {
    final located = _located;
    if (located == null) return;
    final controller = _ensureGlobeController();
    controller.points.clear();
    final groups = _groupForGlobe(located, _gridDegreesForZoom(zoom));
    for (final entry in groups.entries) {
      final group = entry.value;
      final first = group.first;
      controller.addPoint(Point(
        id: entry.key,
        coordinates: GlobeCoordinates(first.latitude!, first.longitude!),
        // Der GPU-gezeichnete Punkt selbst bleibt unsichtbar (Alpha 0) –
        // die eigentliche Pin-Nadel ist unten ein normales Flutter-Widget
        // (siehe labelBuilder), das sich exakt an dieselbe Position
        // ankert, aber gestochen scharf bleibt statt als Kugel-Ellipse
        // verzerrt zu werden.
        style: const PointStyle(color: Colors.transparent, size: 0.1),
        labelBuilder: (context, point, isHovering, isVisible) => GestureDetector(
          // Der Globus selbst zeigt keine Straßendetails (siehe
          // _ensureGlobeController) – ein Pin-Tap springt deshalb zur
          // flachen Karte an dieser Stelle statt direkt das Foto zu
          // öffnen; von dort öffnet der bekannte Foto-Marker das Bild.
          onTap: () => _jumpToFlatMap(group),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: _GlobePin(count: group.length),
          ),
        ),
      ));
    }
    if (focus && groups.isNotEmpty) {
      final center = _averageCenter(located);
      controller.focusOnCoordinates(GlobeCoordinates(center.latitude, center.longitude));
    }
    _globePointsSynced = true;
  }

  void _onGlobeZoomChanged(double zoom) {
    // Nur bei ganzen Zoom-Schritten neu gruppieren statt bei jedem Frame
    // einer laufenden Zoomgeste – sonst würde bei jedem Pixel Scroll-Delta
    // die komplette Punktliste neu aufgebaut.
    final bucket = zoom.roundToDouble();
    if (bucket == _lastGroupedZoomBucket) return;
    _lastGroupedZoomBucket = bucket;
    _syncGlobePoints(zoom: bucket);
  }

  void _setMode(_MapViewMode mode) {
    setState(() {
      _mode = mode;
      if (mode != _MapViewMode.globe) {
        _lastFlatMode = mode;
        // Explizite Auswahl über das Menü statt eines Pin-Sprungs (siehe
        // [_jumpToFlatMap]) -> normale Übersicht statt eines noch aus
        // einem früheren Sprung übrig gebliebenen Zielorts.
        _pendingFlatFocus = null;
        _pendingFlatZoom = null;
      }
    });
    if (mode == _MapViewMode.globe && !_globePointsSynced) {
      _syncGlobePoints(focus: true);
    }
  }

  /// Springt von einem Globus-Pin direkt in die flache, kachelbasierte
  /// Karte an dieser Stelle (siehe Doku bei [_pendingFlatFocus]) – der
  /// Globus selbst kann Straßenebene nicht darstellen.
  void _jumpToFlatMap(List<AssetData> group) {
    setState(() {
      _pendingFlatFocus = _averageCenter(group);
      _pendingFlatZoom = 16;
      _mode = _lastFlatMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final located = _located;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTexte.of(context).karteTitel),
        actions: [
          PopupMenuButton<_MapViewMode>(
            tooltip: AppTexte.of(context).karteAnsicht,
            icon: Icon(switch (_mode) {
              _MapViewMode.light => Icons.light_mode_outlined,
              _MapViewMode.dark => Icons.dark_mode_outlined,
              _MapViewMode.globe => Icons.public,
            }),
            onSelected: _setMode,
            itemBuilder: (context) => [
              _modeMenuItem(_MapViewMode.light, Icons.light_mode_outlined, 'Hell'),
              _modeMenuItem(_MapViewMode.dark, Icons.dark_mode_outlined, 'Dunkel'),
              _modeMenuItem(_MapViewMode.globe, Icons.public, 'Globus'),
            ],
          ),
        ],
      ),
      body: _buildBody(located),
    );
  }

  PopupMenuItem<_MapViewMode> _modeMenuItem(_MapViewMode mode, IconData icon, String label) {
    return PopupMenuItem(
      value: mode,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(label),
          if (mode == _mode) ...[
            const Spacer(),
            const Icon(Icons.check, size: 18),
          ],
        ],
      ),
    );
  }

  Widget _buildBody(List<AssetData>? located) {
    if (located == null) return const Center(child: CircularProgressIndicator());
    if (located.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Text(
            AppTexte.of(context).karteKeineOrteLang,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_mode == _MapViewMode.globe) {
      return Stack(
        children: [
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final radius = math.min(constraints.maxWidth, constraints.maxHeight) / 2 - 16;
                return Center(
                  child: FlutterEarthGlobe(
                    controller: _ensureGlobeController(),
                    radius: radius.clamp(60.0, 400.0),
                    onZoomChanged: _onGlobeZoomChanged,
                  ),
                );
              },
            ),
          ),
          Positioned(
            left: 8,
            bottom: 8,
            child: Text(
              AppTexte.of(context).karteTexturNachweis,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),
        ],
      );
    }

    final isDark = _mode == _MapViewMode.dark;
    return FlutterMap(
      options: MapOptions(
        initialCenter: _pendingFlatFocus ?? _averageCenter(located),
        initialZoom: _pendingFlatZoom ?? 6,
      ),
      children: [
        buildMapTileLayer(context, dark: isDark),
        buildMapAttribution(context, dark: isDark),
        MarkerLayer(
          markers: [
            for (final asset in located)
              Marker(
                point: ll.LatLng(asset.latitude!, asset.longitude!),
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () => _openAsset(located, asset),
                  child: _MapThumbMarker(asset: asset, paths: widget.library.paths),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _MapThumbMarker extends StatelessWidget {
  final AssetData asset;
  final StoragePaths paths;
  const _MapThumbMarker({required this.asset, required this.paths});

  @override
  Widget build(BuildContext context) {
    final thumbPath = asset.thumbnailRelativePath;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4)],
      ),
      child: ClipOval(
        child: thumbPath != null
            ? Image.file(
                paths.absolute(thumbPath),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallbackIcon(),
              )
            : _fallbackIcon(),
      ),
    );
  }

  Widget _fallbackIcon() => Container(
        color: Colors.grey.shade800,
        alignment: Alignment.center,
        child: Icon(
          asset.type == 'VIDEO' ? Icons.videocam : Icons.image,
          color: Colors.white70,
          size: 18,
        ),
      );
}

/// Pin-Nadel für den Globus-Modus (statt einer vom Bibliotheks-eigenen
/// Kugel-Renderer gezeichneten, bei Zoom leicht überdimensionierten
/// Ellipse) – ein normales, gestochen scharfes Flutter-Icon, das über
/// [Point.labelBuilder] exakt an der Foto-Koordinate verankert wird
/// (Spitze der Nadel = Position). Bei mehreren Fotos am selben
/// Raster-Punkt zeigt ein kleines Badge die Anzahl.
class _GlobePin extends StatelessWidget {
  final int count;
  const _GlobePin({required this.count});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 34,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(
            Icons.location_pin,
            color: Colors.redAccent,
            size: 34,
            shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
          ),
          if (count > 1)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
