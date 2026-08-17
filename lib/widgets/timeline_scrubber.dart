import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../db/database.dart';
import 'timeline_grid_layout.dart';

/// Vertikaler "Schnell-Scroll"-Regler am rechten Rand der Timeline/des
/// Kalenders (analog zum Jahres-/Monats-Index in Apple Fotos): zeigt Jahre
/// als Beschriftung, Monate als Punkte, und beim Ziehen eine Sprechblase mit
/// dem exakten Monat/Jahr der Zielposition – zusätzlich eine dünne
/// Positionsmarkierung, die immer die aktuelle Scroll-Position widerspiegelt.
class TimelineScrubber extends StatefulWidget {
  /// Jahr*100+Monat-Schlüssel, absteigend sortiert (neueste zuerst) – exakt
  /// wie in [MonthGroupedAssetGrid] verwendet.
  final List<int> orderedKeys;
  final Map<int, List<AssetData>> groups;
  final ScrollController controller;

  /// Breite, die der eigentlichen Foto-Grid-Spalte zur Verfügung steht
  /// (schon ohne die Breite des Scrubbers selbst) – für die Schätzung, wie
  /// viele Spalten das Grid hat und wie hoch eine Foto-Zeile ist.
  final double gridWidth;

  const TimelineScrubber({
    super.key,
    required this.orderedKeys,
    required this.groups,
    required this.controller,
    required this.gridWidth,
  });

  @override
  State<TimelineScrubber> createState() => _TimelineScrubberState();
}

class _TimelineScrubberState extends State<TimelineScrubber> {
  double? _dragFraction;
  int _hoveredKeyIndex = 0;
  double _scrollFraction = 0.0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant TimelineScrubber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onScroll);
      widget.controller.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!widget.controller.hasClients) return;
    final maxExtent = widget.controller.position.maxScrollExtent;
    final fraction = maxExtent <= 0 ? 0.0 : (widget.controller.position.pixels / maxExtent).clamp(0.0, 1.0);
    if ((fraction - _scrollFraction).abs() > 0.001) {
      setState(() => _scrollFraction = fraction);
    }
  }

  double _monthHeight(int key) =>
      timelineMonthGroupHeight(widget.groups[key]!.length, widget.gridWidth);

  /// Kumulierte Pixel-Offsets für den Start jedes Monats (gleiche
  /// Reihenfolge wie [orderedKeys]), letzter Eintrag = geschätzte
  /// Gesamthöhe aller Monatsgruppen (ohne den abschließenden Leerraum).
  List<double> get _cumulativeOffsets {
    final offsets = <double>[0.0];
    var total = 0.0;
    for (final key in widget.orderedKeys) {
      total += _monthHeight(key);
      offsets.add(total);
    }
    return offsets;
  }

  void _handleDrag(double localY, double trackHeight) {
    if (widget.orderedKeys.isEmpty || !widget.controller.hasClients) return;
    final fraction = trackHeight <= 0 ? 0.0 : (localY / trackHeight).clamp(0.0, 1.0);
    final offsets = _cumulativeOffsets;
    final totalHeight = offsets.last + timelineTrailingHeight;
    final targetPixels = fraction * totalHeight;

    var index = 0;
    for (var i = 0; i < widget.orderedKeys.length; i++) {
      if (offsets[i] <= targetPixels) {
        index = i;
      } else {
        break;
      }
    }

    final maxScroll = widget.controller.position.maxScrollExtent;
    widget.controller.jumpTo(targetPixels.clamp(0.0, maxScroll));
    setState(() {
      _dragFraction = fraction;
      _hoveredKeyIndex = index;
    });
  }

  String _labelFor(int key) =>
      DateFormat.yMMM(Localizations.localeOf(context).toString())
          .format(widget.groups[key]!.first.fileCreatedAt);

  @override
  Widget build(BuildContext context) {
    // Bei sehr wenig Inhalt bringt ein Schnell-Scroll-Regler nichts außer
    // visueller Unruhe.
    if (widget.orderedKeys.length < 2) return const SizedBox.shrink();

    final offsets = _cumulativeOffsets;
    final totalHeight = offsets.last + timelineTrailingHeight;

    final firstIndexOfYear = <int>{};
    final seenYears = <int>{};
    for (var i = 0; i < widget.orderedKeys.length; i++) {
      if (seenYears.add(widget.orderedKeys[i] ~/ 100)) firstIndexOfYear.add(i);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final trackHeight = constraints.maxHeight;

        double topFor(int index) {
          final fraction = totalHeight <= 0 ? 0.0 : offsets[index] / totalHeight;
          return fraction * trackHeight;
        }

        return Semantics(
          label: AppTexte.of(context).scrubberTooltip,
          value: _dragFraction != null ? _labelFor(widget.orderedKeys[_hoveredKeyIndex]) : null,
          child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onVerticalDragStart: (d) => _handleDrag(d.localPosition.dy, trackHeight),
          onVerticalDragUpdate: (d) => _handleDrag(d.localPosition.dy, trackHeight),
          onVerticalDragEnd: (_) => setState(() => _dragFraction = null),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: 20,
                top: 0,
                bottom: 0,
                child: Container(width: 1, color: Colors.white24),
              ),
              for (var i = 0; i < widget.orderedKeys.length; i++) ...[
                Positioned(
                  right: 17,
                  top: (topFor(i) - 3).clamp(0.0, trackHeight - 6),
                  child: Container(
                    width: firstIndexOfYear.contains(i) ? 6 : 3,
                    height: firstIndexOfYear.contains(i) ? 6 : 3,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: firstIndexOfYear.contains(i) ? 0.9 : 0.4),
                    ),
                  ),
                ),
                if (firstIndexOfYear.contains(i))
                  Positioned(
                    right: 28,
                    top: (topFor(i) - 8).clamp(0.0, trackHeight - 16),
                    child: Text(
                      '${widget.orderedKeys[i] ~/ 100}',
                      style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
              // Immer sichtbare, dünne Markierung der aktuellen Scroll-Position.
              Positioned(
                right: 0,
                top: (_scrollFraction * trackHeight - 1).clamp(0.0, trackHeight - 2),
                child: Container(width: 14, height: 2, color: Colors.white),
              ),
              if (_dragFraction != null)
                Positioned(
                  right: 36,
                  top: (_dragFraction! * trackHeight - 14).clamp(0.0, trackHeight - 28),
                  child: _TooltipBubble(text: _labelFor(widget.orderedKeys[_hoveredKeyIndex])),
                ),
            ],
          ),
          ),
        );
      },
    );
  }
}

class _TooltipBubble extends StatelessWidget {
  final String text;
  const _TooltipBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 6)],
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }
}
