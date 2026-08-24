import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../db/database.dart';
import '../l10n/app_localizations.dart';
import '../services/asset_grouping.dart';
import '../services/storage_paths.dart';
import '../theme/app_spacing.dart';
import '../widgets/star_rating.dart';

/// Die Fotos als Liste mit Metadaten-Spalten statt als Raster.
///
/// Das Raster war bisher die einzige Ansicht. Eine Liste ist die
/// Arbeitsweise, wenn man nicht das Bild sucht, sondern die Aufnahme: „Wo
/// stand die Blende?", „Welches Objektiv war das?". Die Angaben liegen alle
/// bereits in der Datenbank – sie waren nur nirgends nebeneinander zu
/// sehen.
///
/// Welche Spalten erscheinen, hängt von der Fensterbreite ab. Alle immer zu
/// zeigen hiesse, sie auf schmalen Fenstern auf je zwanzig Punkte zu
/// quetschen; dann steht überall „…".
class AssetListView extends StatefulWidget {
  final List<AssetData> assets;
  final StoragePaths paths;
  final ListenGruppierung gruppierung;
  final Set<String> selectedIds;
  final void Function(AssetData asset) onTap;
  final void Function(AssetData asset) onLongPress;
  final String? highlightAssetId;

  /// Jede Änderung springt an den Listenanfang – zu den neuesten Fotos.
  /// Siehe [MonthGroupedAssetGrid.nachObenSignal]; die Listenansicht muss
  /// dasselbe tun, sonst hinge das Verhalten daran, welche Darstellung
  /// gerade gewählt ist.
  final ValueListenable<int>? nachObenSignal;

  const AssetListView({
    super.key,
    required this.assets,
    required this.paths,
    required this.gruppierung,
    required this.selectedIds,
    required this.onTap,
    required this.onLongPress,
    this.highlightAssetId,
    this.nachObenSignal,
  });

  /// Ab welcher Breite eine Spalte noch sinnvoll ist.
  static const _breiteKamera = 620.0;
  static const _breiteBelichtung = 860.0;
  static const _breiteBewertung = 1040.0;

  String _gruppentitel(BuildContext context, String schluessel) {
    if (gruppierung == ListenGruppierung.kamera) {
      return schluessel.isEmpty
          ? AppTexte.of(context).listeOhneKamera
          : schluessel;
    }
    final zahl = int.tryParse(schluessel);
    if (zahl == null) return schluessel;
    final datum = DateTime(zahl ~/ 100, zahl % 100);
    return DateFormat.yMMMM(Localizations.localeOf(context).toString()).format(datum);
  }

  @override
  State<AssetListView> createState() => _AssetListViewState();
}

class _AssetListViewState extends State<AssetListView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.nachObenSignal?.addListener(_nachOben);
  }

  @override
  void didUpdateWidget(covariant AssetListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.nachObenSignal != widget.nachObenSignal) {
      oldWidget.nachObenSignal?.removeListener(_nachOben);
      widget.nachObenSignal?.addListener(_nachOben);
    }
  }

  @override
  void dispose() {
    widget.nachObenSignal?.removeListener(_nachOben);
    _scrollController.dispose();
    super.dispose();
  }

  void _nachOben() {
    if (!mounted || !_scrollController.hasClients) return;
    if (_scrollController.offset <= 0) return;
    _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final gruppen = gruppiereAssets(widget.assets, widget.gruppierung);

    return LayoutBuilder(
      builder: (context, constraints) {
        final breite = constraints.maxWidth;
        final zeigeKamera = breite >= AssetListView._breiteKamera;
        final zeigeBelichtung = breite >= AssetListView._breiteBelichtung;
        final zeigeBewertung = breite >= AssetListView._breiteBewertung;

        // Eine flache Liste aus Kopfzeilen und Fotos: So bleibt das Bauen
        // faul, auch wenn eine Gruppe mehrere tausend Fotos enthält.
        final eintraege = <Object>[];
        for (final gruppe in gruppen) {
          if (widget.gruppierung != ListenGruppierung.keine) eintraege.add(gruppe.schluessel);
          eintraege.addAll(gruppe.assets);
        }

        return ListView.builder(
          controller: _scrollController,
          itemCount: eintraege.length,
          itemBuilder: (context, index) {
            final eintrag = eintraege[index];
            if (eintrag is String) {
              return _Kopfzeile(titel: widget._gruppentitel(context, eintrag));
            }
            final asset = eintrag as AssetData;
            return _Zeile(
              asset: asset,
              paths: widget.paths,
              ausgewaehlt: widget.selectedIds.contains(asset.id),
              hervorgehoben: asset.id == widget.highlightAssetId,
              zeigeKamera: zeigeKamera,
              zeigeBelichtung: zeigeBelichtung,
              zeigeBewertung: zeigeBewertung,
              onTap: () => widget.onTap(asset),
              onLongPress: () => widget.onLongPress(asset),
            );
          },
        );
      },
    );
  }
}

class _Kopfzeile extends StatelessWidget {
  final String titel;
  const _Kopfzeile({required this.titel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Text(titel,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w600)),
    );
  }
}

class _Zeile extends StatelessWidget {
  final AssetData asset;
  final StoragePaths paths;
  final bool ausgewaehlt;
  final bool hervorgehoben;
  final bool zeigeKamera;
  final bool zeigeBelichtung;
  final bool zeigeBewertung;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _Zeile({
    required this.asset,
    required this.paths,
    required this.ausgewaehlt,
    required this.hervorgehoben,
    required this.zeigeKamera,
    required this.zeigeBelichtung,
    required this.zeigeBewertung,
    required this.onTap,
    required this.onLongPress,
  });

  /// Belichtungsangaben in der Schreibweise, die auf jedem Gehäuse steht.
  ///
  /// Die Verschlusszeit als Bruch, sobald sie kürzer als eine Sekunde ist –
  /// „0,004 s" liest niemand, „1/250" jeder.
  String _belichtung(AppTexte t) {
    final teile = <String>[];
    if (asset.focalLengthMm != null) {
      teile.add('${asset.focalLengthMm!.round()} mm');
    }
    if (asset.fNumber != null) {
      teile.add('f/${asset.fNumber!.toStringAsFixed(1)}');
    }
    final zeit = asset.exposureTimeSeconds;
    if (zeit != null && zeit > 0) {
      teile.add(zeit >= 1 ? '${zeit.toStringAsFixed(1)} s' : '1/${(1 / zeit).round()}');
    }
    if (asset.iso != null) teile.add('ISO ${asset.iso}');
    return teile.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTexte.of(context);
    final farben = Theme.of(context).colorScheme;
    final thumb = asset.thumbnailRelativePath;

    return Material(
      color: ausgewaehlt
          ? farben.primaryContainer
          : hervorgehoben
              ? farben.surfaceContainerHigh
              : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          child: Row(
            children: [
              SizedBox(
                width: 48,
                height: 36,
                child: thumb == null
                    ? Icon(Icons.image_outlined, size: 18, color: farben.outline)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                        child: Image.file(
                          paths.absolute(thumb),
                          fit: BoxFit.cover,
                          cacheWidth: (48 * MediaQuery.devicePixelRatioOf(context)).round(),
                          errorBuilder: (_, __, ___) =>
                              Icon(Icons.broken_image_outlined, size: 18, color: farben.outline),
                        ),
                      ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 3,
                child: Text(asset.originalFileName,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                flex: 2,
                child: Text(
                  DateFormat.yMd(Localizations.localeOf(context).toString())
                      .add_Hm()
                      .format(asset.fileCreatedAt),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: farben.onSurfaceVariant,
                    fontSize: 12,
                    // Damit die Daten zweier Zeilen untereinander fluchten.
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              if (zeigeKamera) ...[
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: 3,
                  child: Text(
                    kamerabezeichnung(asset) ?? '—',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: farben.onSurfaceVariant, fontSize: 12),
                  ),
                ),
              ],
              if (zeigeBelichtung) ...[
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: 3,
                  child: Text(
                    _belichtung(t),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: farben.onSurfaceVariant,
                      fontSize: 12,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
              if (zeigeBewertung) ...[
                const SizedBox(width: AppSpacing.sm),
                SizedBox(
                  width: 92,
                  child: StarRating(value: asset.rating, size: 14),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
