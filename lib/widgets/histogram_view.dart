import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

import '../services/histogram.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

/// Welche Kanäle das Histogramm gerade zeigt.
enum HistogramMode {
  /// Wahrgenommene Helligkeit (Luma) als einzelne Fläche – zeigt die
  /// Tonwertverteilung von Schwarz (links) bis Weiß (rechts).
  luminance,

  /// Rot, Grün und Blau getrennt, additiv übereinandergelegt.
  rgb,
}

/// Zeigt die Tonwertverteilung eines Bildes, umschaltbar zwischen
/// Helligkeit und RGB.
///
/// Bewusst ohne eigene Berechnung: die Daten kommen fertig von außen
/// (siehe computeHistogramFromBytes), damit das Widget beim Neuzeichnen
/// keine Bildverarbeitung anstößt und dieselbe Berechnung auch für andere
/// Anzeigen wiederverwendbar bleibt.
class HistogramView extends StatefulWidget {
  final HistogramData? data;

  /// Zeigt einen dezenten Ladehinweis, während im Hintergrund eine neue
  /// Vorschau berechnet wird – das bisherige Histogramm bleibt dabei
  /// sichtbar, statt auf einen leeren Kasten zu springen.
  final bool isStale;

  const HistogramView({super.key, required this.data, this.isStale = false});

  @override
  State<HistogramView> createState() => _HistogramViewState();
}

class _HistogramViewState extends State<HistogramView> {
  HistogramMode _mode = HistogramMode.luminance;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppTexte.of(context).histogrammTitel,
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
            if (widget.isStale)
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white38),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          height: 96,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: Colors.white24),
          ),
          clipBehavior: Clip.antiAlias,
          child: data == null || data.isEmpty
              ? Center(
                  child: Text(
                    AppTexte.of(context).histogrammKeineVorschau,
                    style: const TextStyle(color: DunkleFlaeche.hinweis, fontSize: 11),
                  ),
                )
              : CustomPaint(
                  painter: _HistogramPainter(data: data, mode: _mode),
                  size: Size.infinite,
                ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SegmentedButton<HistogramMode>(
          style: const ButtonStyle(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          segments: [
            ButtonSegment(
              value: HistogramMode.luminance,
              label: Text(AppTexte.of(context).histogrammHelligkeit,
                  style: const TextStyle(fontSize: 11)),
            ),
            const ButtonSegment(
              value: HistogramMode.rgb,
              label: Text('RGB', style: TextStyle(fontSize: 11)),
            ),
          ],
          selected: {_mode},
          onSelectionChanged: (selection) => setState(() => _mode = selection.first),
          showSelectedIcon: false,
        ),
      ],
    );
  }
}

class _HistogramPainter extends CustomPainter {
  final HistogramData data;
  final HistogramMode mode;

  _HistogramPainter({required this.data, required this.mode});

  @override
  void paint(Canvas canvas, Size size) {
    _paintGrid(canvas, size);

    if (mode == HistogramMode.luminance) {
      final peak = data.peakOf([data.luminance]);
      _paintChannel(canvas, size, data.luminance, peak, Colors.white.withValues(alpha: 0.75));
    } else {
      // Gemeinsame Bezugshöhe über alle drei Kanäle, sonst wären die
      // Kurven zueinander nicht mehr vergleichbar (jeder Kanal würde auf
      // seine eigene Spitze normiert).
      final peak = data.peakOf([data.red, data.green, data.blue]);
      // Additiv überlagert (Plus-Blendmode): wo sich alle drei Kanäle
      // decken, entsteht Weiß – das übliche Lightroom-/darktable-Bild.
      _paintChannel(canvas, size, data.red, peak, const Color(0xFFFF4444), blend: BlendMode.plus);
      _paintChannel(canvas, size, data.green, peak, const Color(0xFF44FF44), blend: BlendMode.plus);
      _paintChannel(canvas, size, data.blue, peak, const Color(0xFF4488FF), blend: BlendMode.plus);
    }
  }

  /// Senkrechte Viertel-Linien als Orientierung (Schatten/Mitten/Lichter).
  void _paintGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white12
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      final x = size.width * i / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  void _paintChannel(
    Canvas canvas,
    Size size,
    List<int> bins,
    int peak,
    Color color, {
    BlendMode blend = BlendMode.srcOver,
  }) =>
      paintHistogramSilhouette(canvas, size, bins, peak, color, blend: blend);

  @override
  bool shouldRepaint(covariant _HistogramPainter oldDelegate) =>
      oldDelegate.mode != mode || !identical(oldDelegate.data, data);
}

/// Zeichnet die Fläche unter einer Tonwertverteilung.
///
/// Öffentlich, weil der Tonwertkurven-Editor dieselbe Silhouette hinter
/// seinem Raster zeigt – dort ist sie der eigentliche Bezugspunkt: Man
/// zieht die Kurve dorthin, wo die Tonwerte tatsächlich liegen. Eine
/// zweite, leicht abweichende Zeichenroutine dafür wäre genau die Art
/// Ungenauigkeit, die beim Vergleichen stört.
///
/// Die Quadratwurzel-Skalierung ist kein Schönheitsmittel: Reale Fotos
/// haben oft einzelne, extrem hohe Spitzen (etwa eine grosse einfarbige
/// Fläche), gegen die alle anderen Tonwerte bei linearer Skalierung zu
/// einer unlesbaren Nulllinie zusammenfielen.
void paintHistogramSilhouette(
  Canvas canvas,
  Size size,
  List<int> bins,
  int peak,
  Color color, {
  BlendMode blend = BlendMode.srcOver,
}) {
  if (peak <= 0 || bins.length < 2) return;

  final path = Path()..moveTo(0, size.height);
  for (var i = 0; i < bins.length; i++) {
    final x = size.width * i / (bins.length - 1);
    final normalized = (bins[i] / peak).clamp(0.0, 1.0);
    path.lineTo(x, size.height * (1 - math.sqrt(normalized)));
  }
  path
    ..lineTo(size.width, size.height)
    ..close();

  canvas.drawPath(
    path,
    Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..blendMode = blend,
  );
}
