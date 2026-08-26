import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../db/database.dart';
import '../l10n/app_localizations.dart';
import '../services/familienorte.dart';
import '../services/map_clustering.dart';
import '../state/library_state.dart';
import '../theme/app_spacing.dart';
import '../widgets/mini_location_map.dart';
import '../widgets/pin_dialogs.dart';
import 'asset_viewer_screen.dart';

/// Ein verortetes Foto samt der Gruppe, nach der es eingefärbt wird.
typedef Familienort = ({AssetData asset, Ortsgruppe gruppe});

/// Die Orte einer Familie – wo sich die Verwandtschaft über die
/// Generationen aufgehalten hat.
///
/// Dieselbe Kartengrundlage und dieselbe zoomabhängige Gruppierung wie in
/// der allgemeinen Kartenansicht; der Unterschied ist die Auswahl der
/// Fotos und ihre Einfärbung nach Verwandtschaftsrichtung.
class FamilienorteScreen extends StatefulWidget {
  final LibraryState library;
  final String titel;
  final List<Familienort> orte;

  const FamilienorteScreen({
    super.key,
    required this.library,
    required this.titel,
    required this.orte,
  });

  @override
  State<FamilienorteScreen> createState() => _FamilienorteScreenState();
}

class _FamilienorteScreenState extends State<FamilienorteScreen> {
  static const _standardZoom = 5.0;
  double _zoom = _standardZoom;

  /// Welche Gruppen gerade gezeigt werden. Anfangs alle – die Karte soll
  /// zuerst zeigen, was da ist, und sich erst auf Wunsch verengen.
  final Set<Ortsgruppe> _sichtbar = {...Ortsgruppe.values};

  Color _farbe(BuildContext context, Ortsgruppe g) {
    final f = Theme.of(context).colorScheme;
    return switch (g) {
      Ortsgruppe.ich => f.primary,
      Ortsgruppe.vorfahren => f.tertiary,
      Ortsgruppe.nachkommen => f.secondary,
      Ortsgruppe.seitenlinie => f.onSurfaceVariant,
      Ortsgruppe.angeheiratet => f.outline,
    };
  }

  String _name(AppTexte t, Ortsgruppe g) => switch (g) {
        Ortsgruppe.ich => t.orteIch,
        Ortsgruppe.vorfahren => t.orteVorfahren,
        Ortsgruppe.nachkommen => t.orteNachkommen,
        Ortsgruppe.seitenlinie => t.orteSeitenlinie,
        Ortsgruppe.angeheiratet => t.orteAngeheiratet,
      };

  ll.LatLng _mitte(List<Familienort> orte) {
    var lat = 0.0, lng = 0.0;
    for (final o in orte) {
      lat += o.asset.latitude!;
      lng += o.asset.longitude!;
    }
    return ll.LatLng(lat / orte.length, lng / orte.length);
  }

  void _oeffne(List<AssetData> gruppe) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AssetViewerScreen(
        assets: gruppe,
        initialIndex: 0,
        paths: widget.library.paths,
        db: widget.library.db,
        library: widget.library,
        onToggleFavorite: (a) =>
            widget.library.db.setFavorite(a.id, !a.isFavorite),
        onDelete: (a) => widget.library.db.moveToTrash([a.id]),
        onLock: (a) async {
          if (await ensureVaultUnlocked(context, widget.library)) {
            await widget.library.lockAsset(a);
          }
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTexte.of(context);
    final gezeigt =
        widget.orte.where((o) => _sichtbar.contains(o.gruppe)).toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.titel)),
      body: Column(
        children: [
          _legende(context, t),
          Expanded(
            child: gezeigt.isEmpty
                ? Center(child: Text(t.orteNichtsGewaehlt))
                : _karte(gezeigt),
          ),
        ],
      ),
    );
  }

  /// Die Legende ist zugleich der Filter – eine Farberklärung, die man
  /// nur lesen kann, wäre eine verschenkte Fläche.
  Widget _legende(BuildContext context, AppTexte t) {
    final vorhanden = {for (final o in widget.orte) o.gruppe};
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.xs,
        children: [
          for (final g in Ortsgruppe.values)
            if (vorhanden.contains(g))
              FilterChip(
                selected: _sichtbar.contains(g),
                onSelected: (an) => setState(
                    () => an ? _sichtbar.add(g) : _sichtbar.remove(g)),
                avatar: CircleAvatar(
                    backgroundColor: _farbe(context, g), radius: 7),
                label: Text(
                    '${_name(t, g)} (${widget.orte.where((o) => o.gruppe == g).length})'),
              ),
        ],
      ),
    );
  }

  Widget _karte(List<Familienort> gezeigt) {
    final gruppen = gruppiereFuerKarte(gezeigt, _zoom,
        (o) => (breite: o.asset.latitude!, laenge: o.asset.longitude!));
    return FlutterMap(
      options: MapOptions(
        initialCenter: _mitte(gezeigt),
        initialZoom: _standardZoom,
        // Sonst zoomt die Karte ueber die vorhandenen Kacheln hinaus ins
        // Leere – siehe Kartenstil.hoechsteAnzeigeStufe.
        maxZoom: Kartenstil.dunkel.hoechsteAnzeigeStufe.toDouble(),
        onPositionChanged: (kamera, _) {
          final stufe = kamera.zoom.roundToDouble();
          if (stufe != _zoom) setState(() => _zoom = stufe);
        },
      ),
      children: [
        buildMapTileLayer(context, stil: Kartenstil.dunkel),
        buildMapAttribution(context, stil: Kartenstil.dunkel),
        MarkerLayer(
          markers: [
            for (final gruppe in gruppen.values)
              Marker(
                point: ll.LatLng(
                  gruppe.map((o) => o.asset.latitude!).reduce((a, b) => a + b) /
                      gruppe.length,
                  gruppe.map((o) => o.asset.longitude!).reduce((a, b) => a + b) /
                      gruppe.length,
                ),
                width: markerGroesse,
                height: markerGroesse,
                child: GestureDetector(
                  onTap: () => _oeffne([for (final o in gruppe) o.asset]),
                  child: _Ortsmarke(
                    farbe: _farbe(context, gruppe.first.gruppe),
                    anzahl: gruppe.length,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Ein Punkt auf der Familienkarte: farbig nach Verwandtschaftsrichtung,
/// mit der Zahl der Fotos.
///
/// Kein Vorschaubild wie auf der allgemeinen Karte – hier trägt die Farbe
/// die Aussage, und ein Foto darüber würde sie verdecken.
class _Ortsmarke extends StatelessWidget {
  final Color farbe;
  final int anzahl;
  const _Ortsmarke({required this.farbe, required this.anzahl});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: anzahl > 1 ? 30 : 20,
        height: anzahl > 1 ? 30 : 20,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: farbe,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4)],
        ),
        child: anzahl > 1
            ? Text('$anzahl',
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.bold))
            : null,
      ),
    );
  }
}
