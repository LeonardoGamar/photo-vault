import 'dart:io';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';

import '../db/database.dart';
import '../services/asset_format.dart';
import '../services/bilddekodierung.dart';
import '../services/storage_paths.dart';
import '../theme/app_spacing.dart';

/// Kantenlaenge eines Gesichts-Ausschnitts in [LocalImageTile].
const double _ausschnittKante = 160;

class AssetThumbnailTile extends StatelessWidget {
  final AssetData asset;
  final StoragePaths paths;
  final VoidCallback onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;

  /// Zeigt ein abdunkelndes Overlay mit Häkchen, analog zu [LocalImageTile]
  /// – für die Mehrfachauswahl in Timeline/Suche/Alben (siehe
  /// SelectionActionBar).
  final bool selected;

  const AssetThumbnailTile({
    super.key,
    required this.asset,
    required this.paths,
    required this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.selected = false,
  });

  /// Sprechendes Label für VoiceOver, da die Kachel sonst nur als
  /// unbeschriftetes Bild-Icon vorgelesen würde – Favorit-/Bewertungsstatus
  /// fließen mit ein, damit sie auch ohne den Info-Bereich hörbar sind.
  String _semanticLabel(BuildContext context) {
    final t = AppTexte.of(context);
    final sprache = Localizations.localeOf(context).toString();
    final parts = <String>[
      t.kachelBeschreibung(
        asset.type == 'VIDEO' ? t.allgVideo : t.allgFoto,
        asset.originalFileName,
        DateFormat.yMMMMd(sprache).format(asset.fileCreatedAt),
      ),
    ];
    if (asset.type == 'VIDEO' && asset.durationSeconds != null) {
      parts.add(_formatDuration(asset.durationSeconds!));
    }
    if (asset.isFavorite) parts.add(t.kachelFavorisiert);
    if (asset.rating > 0) parts.add(t.sterneBewertungAnzeige(asset.rating));
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final thumbPath = asset.thumbnailRelativePath;
    return Semantics(
      label: _semanticLabel(context),
      button: true,
      selected: selected,
      child: ExcludeSemantics(
        child: GestureDetector(
          onTap: onTap,
          onDoubleTap: onDoubleTap,
          onLongPress: onLongPress,
          child: Stack(
            fit: StackFit.expand,
            children: [
          if (thumbPath != null)
            // cacheWidth/-Height begrenzen die dekodierte Bitmap-Größe auf die
            // tatsächliche Kachelgröße (× Pixelverhältnis) statt immer die
            // volle, auf der Platte hinterlegte 400px-Vorschau zu dekodieren
            // und zu cachen – in dichten Rasteransichten (Timeline, Kalender,
            // Alben) sind Kacheln oft deutlich kleiner als 400px.
            //
            // **In Stufen und nicht auf den Punkt** – siehe
            // [dekodierbreite]. Die Kachelbreite ändert sich mit jedem
            // Punkt Fensterbreite; ohne die Stufen bekäme jeder
            // Zwischenschritt eines Ziehens am Fenster einen eigenen
            // Schlüssel im Bildspeicher, und jede sichtbare Kachel würde
            // dabei neu dekodiert.
            LayoutBuilder(
              builder: (context, constraints) {
                final dpr = MediaQuery.of(context).devicePixelRatio;
                return Image.file(
                  paths.absolute(thumbPath),
                  fit: BoxFit.cover,
                  cacheWidth: constraints.maxWidth.isFinite
                      ? dekodierbreite(constraints.maxWidth, dpr)
                      : null,
                  cacheHeight: constraints.maxHeight.isFinite
                      ? dekodierbreite(constraints.maxHeight, dpr)
                      : null,
                  errorBuilder: (_, __, ___) => _placeholder(),
                );
              },
            )
          else
            _placeholder(),
          if (asset.type == 'VIDEO')
            Positioned(
              right: 4,
              bottom: 4,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (asset.durationSeconds != null) ...[
                    Text(
                      _formatDuration(asset.durationSeconds!),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        shadows: [Shadow(color: Colors.black, blurRadius: 3)],
                      ),
                    ),
                    const SizedBox(width: 3),
                  ],
                  const Icon(Icons.play_circle_fill, color: Colors.white, size: 20),
                ],
              ),
            ),
          if (asset.type == 'IMAGE' && asset.linkedAssetId != null)
            const Positioned(
              right: 4,
              bottom: 4,
              child: Icon(Icons.motion_photos_on, color: Colors.white, size: 18),
            ),
          if (asset.isFavorite)
            const Positioned(
              left: 4,
              top: 4,
              child: Icon(Icons.favorite, color: Colors.redAccent, size: 16),
            ),
          if (assetHasLocation(asset))
            const Positioned(
              left: 4,
              bottom: 4,
              child: Icon(
                Icons.location_on,
                color: Colors.white,
                size: 14,
                shadows: [Shadow(color: Colors.black, blurRadius: 3)],
              ),
            ),
          // Stapel-Abzeichen hat Vorrang vor dem Format-Kürzel in derselben
          // Ecke – bei einem Serien-Titelbild ist "wie viele Fotos stecken
          // dahinter" wichtiger für die Kachel-Ansicht als das Dateiformat.
          if (asset.isStackCover && asset.stackSize != null)
            Positioned(
              right: 4,
              top: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(3)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.filter_none, color: Colors.white, size: 11),
                    const SizedBox(width: 3),
                    Text(
                      '${asset.stackSize}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            )
          else if (assetFormatLabel(asset).isNotEmpty)
            Positioned(
              right: 4,
              top: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 1),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(3)),
                child: Text(
                  assetFormatLabel(asset),
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          if (selected)
            Container(
              color: Colors.black45,
              child: const Icon(Icons.check_circle, color: Colors.white),
            ),
            ],
          ),
        ),
      ),
    );
  }

  /// Formatiert Sekunden als "m:ss" (bzw. "h:mm:ss" für Videos ab einer
  /// Stunde Länge), analog zur Anzeige in Apple Fotos/Google Fotos.
  String _formatDuration(double seconds) {
    final total = seconds.round();
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;
    final mm = h > 0 ? m.toString().padLeft(2, '0') : m.toString();
    final ss = s.toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
  }

  Widget _placeholder() => Container(
        color: Colors.grey.shade900,
        child: Icon(
          asset.type == 'VIDEO' ? Icons.videocam_outlined : Icons.image_outlined,
          color: Colors.white24,
        ),
      );
}

/// Für Fälle außerhalb der Tabelle (z.B. Gesichts-Crops), bei denen nur ein
/// absoluter Dateipfad statt eines Assets vorliegt.
class LocalImageTile extends StatelessWidget {
  final File file;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final bool selected;

  const LocalImageTile({
    super.key,
    required this.file,
    this.onTap,
    this.onDoubleTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            file,
            fit: BoxFit.cover,
            // Ein Gesichts-Ausschnitt ist klein, aber es sind viele: Die
            // Gesichtspruefung zeigt hunderte davon nebeneinander.
            cacheWidth: (_ausschnittKante *
                    MediaQuery.devicePixelRatioOf(context))
                .round(),
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey.shade900,
              child: const Icon(Icons.face_outlined, color: Colors.white24),
            ),
          ),
          if (selected)
            Container(
              color: Colors.black45,
              child: const Icon(Icons.check_circle, color: Colors.white),
            ),
        ],
      ),
    );
  }
}
