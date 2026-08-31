import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../db/database.dart';
import '../l10n/app_localizations.dart';
import '../services/search_filters.dart';
import '../state/library_state.dart';
import '../theme/app_spacing.dart';
import '../widgets/asset_thumbnail_tile.dart';
import '../widgets/mini_location_map.dart'
    show Kachelschicht, Kartenstil, buildMapAttribution;
import '../widgets/pin_dialogs.dart';
import 'album_detail_screen.dart';
import 'albums_screen.dart';
import 'asset_viewer_screen.dart';
import 'map_screen.dart';
import 'people_screen.dart';
import 'reise_detail_screen.dart';
import 'reisen_screen.dart';
import 'person_detail_screen.dart';
import 'timeline_screen.dart';
import 'trash_screen.dart';
import '../widgets/profilbild.dart';
import '../widgets/stromhalter.dart';
import '../services/laendernamen.dart';

const _previewPeopleCount = 10;
const _previewAlbumCount = 8;
const _previewPhotoCount = 12;
const _previewLocationMarkerCount = 60;
const _previewLocationGroupCount = 12;

/// Übersichts-/Entdecken-Tab: bündelt kompakte Vorschauen aus den
/// spezialisierten Bereichen (Personen, Karte, Alben, Timeline) auf einer
/// Seite, statt dass man dafür einzeln durch die jeweiligen Tabs navigieren
/// muss. Jede Sektion verlinkt über "Alle anzeigen" auf die volle Ansicht.
/// Breite einer Karte in den Querlisten – zugleich die Dekodiergroesse
/// des Vorschaubilds darin.
const double _kartenKante = 120;

class ExploreScreen extends StatelessWidget {
  final LibraryState library;
  const ExploreScreen({super.key, required this.library});

  @override
  Widget build(BuildContext context) {
    // **Kein `ListView`.** Die Abschnitte hier sind unterschiedlich hoch
    // (ein Streifen 96 Punkte, die Kartenvorschau 200, die Papierkorbzeile
    // 72), und eine faule Liste schaetzt ihre Gesamthoehe aus dem, was
    // gerade ausgelegt ist. Wer bis zum Papierkorb scrollt, hat oben nur
    // noch die kurzen Abschnitte im Baum – und die Schaetzung bricht ein:
    //
    // ```
    // unten angekommen   1288 von max 1288
    // ein Zug zurueck     250 von max  352   <- 950 Punkte auf einmal
    // zwei Zuege spaeter    0 von max 2810   <- ganz oben
    // ```
    //
    // Die Rollposition wird auf das eingebrochene Maximum gekappt, und
    // wenn die echte Hoehe zurueckkommt, ist sie weg. Von aussen sieht es
    // aus, als springe die Seite von selbst nach oben.
    //
    // Dreizehn Abschnitte auf einmal auszulegen kostet nichts: Die Menge
    // steckt in den Vorschaubildern, und die liegen in den waagerechten
    // Listen darin, die faul bleiben. Nebenbei bauen die Abschnitte sich
    // nicht mehr staendig ab und neu auf – jeder Wiederaufbau hatte seine
    // Abfrage von vorn begonnen.
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MemoriesSection(library: library),
          const SizedBox(height: 28),
          _SectionHeader(
            title: AppTexte.of(context).erkundenPersonen,
            onShowAll: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => PeopleScreen(library: library),
            )),
          ),
          const SizedBox(height: 8),
          _PeopleStrip(library: library),
          const SizedBox(height: 28),
          _SectionHeader(
            title: AppTexte.of(context).erkundenOrte,
            onShowAll: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => MapScreen(library: library),
            )),
          ),
          const SizedBox(height: 8),
          _LocationsPreview(library: library),
          const SizedBox(height: 12),
          _LocationGroupsStrip(library: library),
          const SizedBox(height: 28),
          // Reisen stehen direkt unter den Orten: Sie sind dieselbe Frage,
          // eine Ebene größer – nicht „wo war dieses Bild", sondern „wo war
          // ich, und wie lange".
          _SectionHeader(
            title: AppTexte.of(context).erkundenReisen,
            onShowAll: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ReisenScreen(library: library),
            )),
          ),
          const SizedBox(height: 8),
          _ReisenStrip(library: library),
          const SizedBox(height: 28),
          _SectionHeader(
            title: AppTexte.of(context).erkundenLetzteAlben,
            onShowAll: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => AlbumsScreen(library: library),
            )),
          ),
          const SizedBox(height: 8),
          _RecentAlbumsStrip(library: library),
          const SizedBox(height: 28),
          _SectionHeader(
            title: AppTexte.of(context).erkundenLetzteFotos,
            onShowAll: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => TimelineScreen(library: library),
            )),
          ),
          const SizedBox(height: 8),
          _RecentPhotosStrip(library: library),
          const SizedBox(height: 28),
          // Der Papierkorb steht hier und nicht nur in den Einstellungen.
          // Er ist kein Schalter, sondern ein Ort, an dem Fotos liegen –
          // und wer eines sucht, sucht es beim Erkunden. Er steht zuletzt,
          // weil er der einzige Eintrag ist, den man im Regelfall NICHT
          // braucht.
          _Papierkorbzeile(library: library),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onShowAll;
  const _SectionHeader({required this.title, required this.onShowAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        TextButton(onPressed: onShowAll, child: Text(AppTexte.of(context).allgAlleAnzeigen)),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  final double height;
  const _EmptyHint({required this.text, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(child: Text(text, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))),
    );
  }
}

/// Die Strom-Halter der Streifen: Seit die Abschnitte nicht mehr
/// abgebaut werden (siehe [ExploreScreen.build]), bleiben sie stehen –
/// und werden bei JEDER Meldung des Bibliothekszustands neu gebaut, in
/// der Hintergrundanalyse also zehnmal je Sekunde. Ein `watch()` im
/// `stream:` haette dabei jedes Mal ein neues Stream-Objekt geliefert
/// und damit eine neue Abfrage. Siehe [Stromhalter].
class _PeopleStrip extends StatefulWidget {
  final LibraryState library;
  const _PeopleStrip({required this.library});

  @override
  State<_PeopleStrip> createState() => _PeopleStripState();
}

class _PeopleStripState extends State<_PeopleStrip> {
  final _strom = Stromhalter<List<PersonData>>();

  @override
  Widget build(BuildContext context) {
    final library = widget.library;
    return SizedBox(
      height: 96,
      child: StreamBuilder<List<PersonData>>(
        stream: _strom.hole(true, () => library.db.watchPeople()),
        builder: (context, snapshot) {
          final people = snapshot.data ?? [];
          if (people.isEmpty) {
            return _EmptyHint(text: AppTexte.of(context).erkundenKeinePersonen, height: 96);
          }
          final shown = people.take(_previewPeopleCount).toList();
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: shown.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final person = shown[index];
              return InkWell(
                borderRadius: BorderRadius.circular(32),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => PersonDetailScreen(library: library, person: person),
                )),
                child: SizedBox(
                  width: 76,
                  child: Column(
                    children: [
                      Profilbild(
                        datei: person.coverFaceCropPath == null
                            ? null
                            : library.paths
                                .absolute(person.coverFaceCropPath!),
                        radius: 32,
                        hintergrund: Colors.grey.shade800,
                        symbolgroesse: 28,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        person.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _LocationsPreview extends StatefulWidget {
  final LibraryState library;
  const _LocationsPreview({required this.library});

  @override
  State<_LocationsPreview> createState() => _LocationsPreviewState();
}

class _LocationsPreviewState extends State<_LocationsPreview> {
  // Einmalig in initState geladen statt inline in build(): ein Future direkt
  // als `future:`-Argument eines FutureBuilder in build() zu erzeugen würde
  // bei jedem Rebuild (z.B. durch den übergeordneten Consumer<LibraryState>)
  // ein NEUES Future anstoßen – der FutureBuilder würde jedes Mal kurz in
  // den Ladezustand zurückfallen und die Abfrage unnötig wiederholen.
  late final Future<List<AssetData>> _locatedFuture = widget.library.db.assetsWithLocation();

  ll.LatLng _averageCenter(List<AssetData> assets) {
    var latSum = 0.0, lngSum = 0.0;
    for (final a in assets) {
      latSum += a.latitude!;
      lngSum += a.longitude!;
    }
    return ll.LatLng(latSum / assets.length, lngSum / assets.length);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AssetData>>(
      future: _locatedFuture,
      builder: (context, snapshot) {
        final located = snapshot.data ?? [];
        return InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => MapScreen(library: widget.library),
          )),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: SizedBox(
              height: 160,
              child: located.isEmpty
                  ? Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      alignment: Alignment.center,
                      child: Text(
                        AppTexte.of(context).ohneOrtLeer,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    )
                  // IgnorePointer: die Vorschau soll nur als Ganzes zur
                  // vollen Kartenansicht führen, nicht selbst pannbar/zoombar
                  // sein (das würde mit dem Tippen zum Öffnen kollidieren).
                  : IgnorePointer(
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: _averageCenter(located),
                          initialZoom: 4,
                          // Sonst zoomt die Karte ueber die
                          // vorhandenen Kacheln hinaus ins Leere –
                          // siehe Kartenstil.hoechsteAnzeigeStufe.
                          maxZoom: Kartenstil.dunkel.hoechsteAnzeigeStufe.toDouble(),
                        ),
                        children: [
                          const Kachelschicht(),
                          buildMapAttribution(context),
                          MarkerLayer(
                            markers: [
                              for (final a in located.take(_previewLocationMarkerCount))
                                Marker(
                                  point: ll.LatLng(a.latitude!, a.longitude!),
                                  width: 10,
                                  height: 10,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context).colorScheme.primary,
                                      border: Border.all(color: Colors.white, width: 1.5),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}

/// Ein Ort (Stadt + optional Land) mit einem repräsentativen Foto (das
/// zeitlich aktuellste dieses Orts) und der Anzahl zugehöriger Fotos.
class _LocationGroup {
  final String city;
  final String? country;
  final AssetData cover;
  int count = 1;
  _LocationGroup({required this.city, required this.country, required this.cover});
}

/// Zeigt die per Umkehr-Geokodierung erkannten Orte (siehe ReverseGeocoder)
/// als Bildvorschau-Kacheln, zusätzlich zur Kartenvorschau oben – eine Zeile
/// je Ort, sortiert nach dem zeitlich aktuellsten Foto an diesem Ort.
class _LocationGroupsStrip extends StatefulWidget {
  final LibraryState library;
  const _LocationGroupsStrip({required this.library});

  @override
  State<_LocationGroupsStrip> createState() => _LocationGroupsStripState();
}

class _LocationGroupsStripState extends State<_LocationGroupsStrip> {
  late final Future<List<AssetData>> _resolvedFuture = widget.library.db.assetsWithResolvedLocation();

  /// [assets] kommt bereits absteigend nach Aufnahmedatum sortiert aus der
  /// Datenbank – das erste Vorkommen je Ort ist damit automatisch das
  /// aktuellste Foto und wird als Vorschaubild verwendet.
  List<_LocationGroup> _groupByPlace(List<AssetData> assets) {
    final groups = <String, _LocationGroup>{};
    for (final a in assets) {
      final key = '${a.locationCity}|${a.locationCountry ?? ''}';
      final existing = groups[key];
      if (existing == null) {
        groups[key] = _LocationGroup(city: a.locationCity!, country: a.locationCountry, cover: a);
      } else {
        existing.count++;
      }
    }
    return groups.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: FutureBuilder<List<AssetData>>(
        future: _resolvedFuture,
        builder: (context, snapshot) {
          final assets = snapshot.data ?? [];
          if (assets.isEmpty) {
            return _EmptyHint(
              text: AppTexte.of(context).erkundenKeineOrte,
              height: 150,
            );
          }
          final groups = _groupByPlace(assets).take(_previewLocationGroupCount).toList();
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: groups.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) =>
                _LocationGroupTile(library: widget.library, group: groups[index]),
          );
        },
      ),
    );
  }
}

class _LocationGroupTile extends StatelessWidget {
  final LibraryState library;
  final _LocationGroup group;
  const _LocationGroupTile({required this.library, required this.group});

  Future<void> _openPlace(BuildContext context) async {
    final results = await library.db.searchAssets(
      SearchFilters(locationCity: group.city, locationCountry: group.country),
    );
    if (results.isEmpty || !context.mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AssetViewerScreen(
        assets: results,
        initialIndex: 0,
        paths: library.paths,
        db: library.db,
        library: library,
        onToggleFavorite: (a) => library.db.setFavorite(a.id, !a.isFavorite),
        onDelete: (a) => library.db.moveToTrash([a.id]),
        onLock: (a) async {
          if (await ensureVaultUnlocked(context, library)) {
            await library.lockAsset(a);
          }
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final thumbPath = group.cover.thumbnailRelativePath;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: () => _openPlace(context),
      child: SizedBox(
        width: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: thumbPath != null
                      ? Image.file(
                          library.paths.absolute(thumbPath),
                          fit: BoxFit.cover,
                          cacheWidth: (_kartenKante *
                                  MediaQuery.devicePixelRatioOf(context))
                              .round(),
                          errorBuilder: (_, __, ___) => const Icon(Icons.location_city_outlined, size: 32),
                        )
                      : const Center(child: Icon(Icons.location_city_outlined, size: 32)),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              group.city,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            if (group.country != null)
              Text(
                landAnzeige(group.country,
                    Localizations.localeOf(context).languageCode),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
          ],
        ),
      ),
    );
  }
}

/// Die zuletzt bestätigten Reisen.
///
/// Bewusst **nur die bestätigten**: Nach Vorschlägen zu suchen heißt, die
/// ganze verortete Bibliothek durchzugehen. Das gehört in den
/// Reisen-Bildschirm, den man dafür öffnet, und nicht in eine
/// Übersichtsseite, die bei jedem Wechsel auf diesen Reiter neu aufgebaut
/// wird.
class _ReisenStrip extends StatefulWidget {
  final LibraryState library;
  const _ReisenStrip({required this.library});

  @override
  State<_ReisenStrip> createState() => _ReisenStripState();
}

class _ReisenStripState extends State<_ReisenStrip> {
  final _strom = Stromhalter<List<ReisenData>>();

  @override
  Widget build(BuildContext context) {
    final library = widget.library;
    return SizedBox(
      height: 92,
      child: StreamBuilder<List<ReisenData>>(
        stream: _strom.hole(true, () => library.db.watchReisen()),
        builder: (context, snapshot) {
          final reisen = snapshot.data ?? const <ReisenData>[];
          if (reisen.isEmpty) {
            return _EmptyHint(
                text: AppTexte.of(context).reisenKeineVorschlaege, height: 92);
          }
          final gezeigt = reisen.take(_previewAlbumCount).toList();
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: gezeigt.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) =>
                _Reisekachel(library: library, reise: gezeigt[index]),
          );
        },
      ),
    );
  }
}

class _Reisekachel extends StatelessWidget {
  final LibraryState library;
  final ReisenData reise;
  const _Reisekachel({required this.library, required this.reise});

  @override
  Widget build(BuildContext context) {
    final farben = Theme.of(context).colorScheme;
    final jahr = reise.von.year == reise.bis.year
        ? '${reise.von.year}'
        : '${reise.von.year}–${reise.bis.year}';
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ReiseDetailScreen(library: library, reise: reise),
      )),
      child: Container(
        width: 190,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: farben.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.luggage, color: farben.primary, size: 20),
            const SizedBox(height: AppSpacing.xs),
            Text(reise.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(jahr,
                style: TextStyle(fontSize: 12, color: farben.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _RecentAlbumsStrip extends StatefulWidget {
  final LibraryState library;
  const _RecentAlbumsStrip({required this.library});

  @override
  State<_RecentAlbumsStrip> createState() => _RecentAlbumsStripState();
}

class _RecentAlbumsStripState extends State<_RecentAlbumsStrip> {
  final _strom = Stromhalter<List<AlbumData>>();

  @override
  Widget build(BuildContext context) {
    final library = widget.library;
    return SizedBox(
      height: 150,
      child: StreamBuilder<List<AlbumData>>(
        // Bereits nach createdAt absteigend sortiert -> die ersten N sind
        // die zuletzt angelegten Alben.
        stream: _strom.hole(true, () => library.db.watchAlbums()),
        builder: (context, snapshot) {
          final albums = snapshot.data ?? [];
          if (albums.isEmpty) {
            return _EmptyHint(text: AppTexte.of(context).albenLeer, height: 150);
          }
          final shown = albums.take(_previewAlbumCount).toList();
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: shown.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _AlbumPreviewTile(library: library, album: shown[index]),
          );
        },
      ),
    );
  }
}

class _AlbumPreviewTile extends StatefulWidget {
  final LibraryState library;
  final AlbumData album;
  const _AlbumPreviewTile({required this.library, required this.album});

  @override
  State<_AlbumPreviewTile> createState() => _AlbumPreviewTileState();
}

class _AlbumPreviewTileState extends State<_AlbumPreviewTile> {
  // Kein eigenes Cover-Feld gepflegt – als Vorschau dient stattdessen das
  // zuletzt hinzugefügte Foto des Albums. Diese Kachel wird pro Album einmal
  // in einer horizontalen Liste erzeugt – ein inline in build() erzeugtes
  // Future würde hier bei jedem Rebuild ERNEUT pro sichtbarem Album
  // abgefragt (statt einmal beim Erzeugen der Kachel).
  late final Future<List<AssetData>> _assetsFuture = widget.library.db.assetsInAlbumOnce(widget.album.id);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) =>
            AlbumDetailScreen(library: widget.library, albumId: widget.album.id, albumName: widget.album.name),
      )),
      child: SizedBox(
        width: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: FutureBuilder<List<AssetData>>(
                  future: _assetsFuture,
                  builder: (context, snapshot) {
                    final assets = snapshot.data ?? [];
                    final cover = assets.isEmpty
                        ? null
                        : assets.reduce((a, b) => a.fileCreatedAt.isAfter(b.fileCreatedAt) ? a : b);
                    final thumbPath = cover?.thumbnailRelativePath;
                    return Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: thumbPath != null
                          ? Image.file(
                              widget.library.paths.absolute(thumbPath),
                              fit: BoxFit.cover,
                              cacheWidth: (_kartenKante *
                                      MediaQuery.devicePixelRatioOf(context))
                                  .round(),
                              errorBuilder: (_, __, ___) => const Icon(Icons.photo_album_outlined, size: 32),
                            )
                          : const Center(child: Icon(Icons.photo_album_outlined, size: 32)),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.album.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentPhotosStrip extends StatefulWidget {
  final LibraryState library;
  const _RecentPhotosStrip({required this.library});

  @override
  State<_RecentPhotosStrip> createState() => _RecentPhotosStripState();
}

class _RecentPhotosStripState extends State<_RecentPhotosStrip> {
  final _strom = Stromhalter<List<AssetData>>();

  @override
  Widget build(BuildContext context) {
    final library = widget.library;
    return SizedBox(
      height: 140,
      child: StreamBuilder<List<AssetData>>(
        stream: _strom.hole(_previewPhotoCount,
            () => library.db.watchTimeline(limit: _previewPhotoCount)),
        builder: (context, snapshot) {
          final shown = snapshot.data ?? [];
          if (shown.isEmpty) {
            return _EmptyHint(text: AppTexte.of(context).erkundenKeineFotos, height: 140);
          }
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: shown.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final asset = shown[index];
              return SizedBox(
                width: 140,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: AssetThumbnailTile(
                    asset: asset,
                    paths: library.paths,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => AssetViewerScreen(
                        assets: shown,
                        initialIndex: shown.indexOf(asset),
                        paths: library.paths,
                        db: library.db,
                        library: library,
                        onToggleFavorite: (a) => library.db.setFavorite(a.id, !a.isFavorite),
                        onDelete: (a) => library.db.moveToTrash([a.id]),
                        onLock: (a) async {
                          if (await ensureVaultUnlocked(context, library)) {
                            await library.lockAsset(a);
                          }
                        },
                      ),
                    )),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// "Erinnerungen": Fotos, die genau heute vor 1, 2, 3 … Jahren aufgenommen
/// wurden – analog zu "Vor X Jahren" in Google Fotos/Apple Fotos. Zeigt sich
/// nur, wenn es für den heutigen Tag tatsächlich etwas gibt; ein Tag ohne
/// Treffer ist der Normalfall und verdient (anders als z.B. "Noch keine
/// Alben vorhanden") keinen eigenen Leerzustand-Hinweis, deshalb hier
/// bewusst `SizedBox.shrink()` statt einer `_EmptyHint`.
class _MemoriesSection extends StatefulWidget {
  final LibraryState library;
  const _MemoriesSection({required this.library});

  @override
  State<_MemoriesSection> createState() => _MemoriesSectionState();
}

class _MemoriesSectionState extends State<_MemoriesSection> {
  late final Future<List<AssetData>> _memoriesFuture = widget.library.db.assetsOnThisDay(DateTime.now());

  /// [assets] kommt bereits absteigend nach Aufnahmedatum sortiert – die
  /// Gruppierung hier fasst sie nur noch nach "vor wie vielen Jahren"
  /// zusammen, die Reihenfolge innerhalb einer Gruppe bleibt erhalten.
  Map<int, List<AssetData>> _groupByYearsAgo(List<AssetData> assets) {
    final now = DateTime.now();
    final groups = <int, List<AssetData>>{};
    for (final a in assets) {
      final yearsAgo = now.year - a.fileCreatedAt.year;
      groups.putIfAbsent(yearsAgo, () => []).add(a);
    }
    return groups;
  }

  void _openMemory(BuildContext context, List<AssetData> assets, AssetData asset) {
    Navigator.of(context).push(MaterialPageRoute(
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
    ));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AssetData>>(
      future: _memoriesFuture,
      builder: (context, snapshot) {
        final assets = snapshot.data ?? [];
        if (assets.isEmpty) return const SizedBox.shrink();

        final groups = _groupByYearsAgo(assets);
        final orderedYearsAgo = groups.keys.toList()..sort();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppTexte.of(context).erkundenErinnerungen, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final yearsAgo in orderedYearsAgo) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  AppTexte.of(context).erkundenVorJahren(yearsAgo),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: groups[yearsAgo]!.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final group = groups[yearsAgo]!;
                    final asset = group[index];
                    return SizedBox(
                      width: 140,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: AssetThumbnailTile(
                          asset: asset,
                          paths: widget.library.paths,
                          onTap: () => _openMemory(context, group, asset),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (yearsAgo != orderedYearsAgo.last) const SizedBox(height: 16),
            ],
          ],
        );
      },
    );
  }
}

/// Der Weg in den Papierkorb, mit der Zahl gleich daneben.
///
/// Bis Fassung 2.2.1 gab es ihn nur über die Einstellungen – und davor
/// zwei Jahre lang gar nicht (siehe `jeder_bildschirm_erreichbar_test.dart`).
/// Er bleibt dort auch stehen: Wer die automatische Leerung einstellt,
/// will von dort hineinsehen können.
class _Papierkorbzeile extends StatefulWidget {
  final LibraryState library;
  const _Papierkorbzeile({required this.library});

  @override
  State<_Papierkorbzeile> createState() => _PapierkorbzeileState();
}

class _PapierkorbzeileState extends State<_Papierkorbzeile> {
  final _strom = Stromhalter<Papierkorbumfang>();

  @override
  Widget build(BuildContext context) {
    final library = widget.library;
    final t = AppTexte.of(context);
    // Nur die Zahl, nicht die Aufnahmen: 0,3 statt 13,0 ms je Abo, siehe
    // [AppDatabase.watchPapierkorbUmfang].
    return StreamBuilder<Papierkorbumfang>(
      stream: _strom.hole(true, () => library.db.watchPapierkorbUmfang()),
      builder: (context, schnappschuss) {
        final anzahl = schnappschuss.data?.anzahl ?? 0;
        return Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            leading: const Icon(Icons.delete_outline),
            title: Text(t.papierkorbTitel),
            subtitle: Text(anzahl == 0
                ? t.papierkorbLeer
                : t.papierkorbAnzahl(anzahl)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => TrashScreen(library: library),
            )),
          ),
        );
      },
    );
  }
}
