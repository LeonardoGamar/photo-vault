import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../db/database.dart';
import '../theme/app_theme.dart';
import 'timeline_grid_layout.dart';

/// Vertikaler "Schnell-Scroll"-Regler am rechten Rand der Timeline/des
/// Kalenders: Jahre als Beschriftung, Monate als Punkte, und an der
/// aktuellen Position eine Linie quer über die ganze Leiste mit dem Monat
/// darüber.
///
/// Die Leiste hat einen eigenen, halbdurchsichtigen Grund. Das ist keine
/// Zierde: Ohne ihn stünde weisse Schrift direkt auf den Fotos und wäre
/// über einem hellen Bild unlesbar – und die Fotos darunter wechseln beim
/// Scrollen ständig die Helligkeit. Mit dem Grund gilt derselbe Kontrast
/// wie auf den übrigen dunklen Arbeitsflächen (siehe [DunkleFlaeche]),
/// unabhängig davon, ob die App gerade hell oder dunkel läuft.
///
/// Statt einer Sprechblase neben dem Finger steht die Beschriftung IN der
/// Leiste: Beim Ziehen liegt der Finger genau dort, wo die Sprechblase
/// erschien, und verdeckte sie auf dem Trackpad-Bildschirm regelmässig.
/// Wie weit die Punktspalte vom rechten Rand entfernt sitzt.
const double _punktSpalte = 14;

/// Grund der Leiste. Dunkel und halbdurchsichtig, damit die Fotos daneben
/// durchscheinen, die Schrift darauf aber in jedem Helligkeitsmodus lesbar
/// bleibt – gegen diesen Grund gelten die Werte aus [DunkleFlaeche].
const Color _leistenGrund = Color(0xD9000000);

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
  double _scrollFraction = 0.0;

  /// Die Monatsgruppe, die zur aktuell angezeigten Position gehört – beim
  /// Ziehen die unter dem Finger, sonst die, in der die Ansicht gerade
  /// steht. Wird beim Aufbau ausgerechnet statt mitgeführt: Sonst laufen
  /// Marke und Beschriftung auseinander, sobald jemand mit dem Mausrad
  /// scrollt statt zu ziehen.
  int _aktiverIndex(double trackHeight) {
    final offsets = _cumulativeOffsets;
    final gesamt = offsets.last + timelineTrailingHeight;
    final ziel = (_dragFraction ?? _scrollFraction) * gesamt;
    var index = 0;
    for (var i = 0; i < widget.orderedKeys.length; i++) {
      if (offsets[i] <= ziel) {
        index = i;
      } else {
        break;
      }
    }
    return index;
  }

  /// Ob bei [index] ein neues Jahr beginnt – nur dort steht eine Jahreszahl.
  bool _istJahresbeginn(int index) {
    if (index == 0) return true;
    return widget.orderedKeys[index] ~/ 100 !=
        widget.orderedKeys[index - 1] ~/ 100;
  }

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

    // Welche Monatsgruppe das ist, rechnet _aktiverIndex beim Aufbau aus –
    // hier wird nur gesprungen.
    final maxScroll = widget.controller.position.maxScrollExtent;
    widget.controller.jumpTo(targetPixels.clamp(0.0, maxScroll));
    setState(() => _dragFraction = fraction);
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final trackHeight = constraints.maxHeight;

        double topFor(int index) {
          final fraction = totalHeight <= 0 ? 0.0 : offsets[index] / totalHeight;
          return fraction * trackHeight;
        }

        return Semantics(
          label: AppTexte.of(context).scrubberTooltip,
          value: _labelFor(widget.orderedKeys[_aktiverIndex(trackHeight)]),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onVerticalDragStart: (d) => _handleDrag(d.localPosition.dy, trackHeight),
            onVerticalDragUpdate: (d) => _handleDrag(d.localPosition.dy, trackHeight),
            onVerticalDragEnd: (_) => setState(() => _dragFraction = null),
            onTapDown: (d) => _handleDrag(d.localPosition.dy, trackHeight),
            child: DecoratedBox(
              decoration: const BoxDecoration(color: _leistenGrund),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Die Punktspalte: eine feine Linie, auf der die Monate
                  // sitzen.
                  const Positioned(
                    right: _punktSpalte,
                    top: 0,
                    bottom: 0,
                    child: SizedBox(
                      width: 1,
                      child: ColoredBox(color: DunkleFlaeche.linie),
                    ),
                  ),
                  for (var i = 0; i < widget.orderedKeys.length; i++) ...[
                    Positioned(
                      right: _punktSpalte - (_istJahresbeginn(i) ? 2 : 1),
                      top: (topFor(i) - (_istJahresbeginn(i) ? 2.5 : 1.5))
                          .clamp(0.0, trackHeight - 5),
                      child: Container(
                        width: _istJahresbeginn(i) ? 5 : 3,
                        height: _istJahresbeginn(i) ? 5 : 3,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _istJahresbeginn(i)
                              ? DunkleFlaeche.text
                              : DunkleFlaeche.inaktiv,
                        ),
                      ),
                    ),
                    if (_istJahresbeginn(i))
                      Positioned(
                        right: _punktSpalte + 8,
                        top: (topFor(i) - 7).clamp(0.0, trackHeight - 14),
                        child: Text(
                          '${widget.orderedKeys[i] ~/ 100}',
                          style: const TextStyle(
                            fontSize: 11,
                            height: 1.1,
                            color: DunkleFlaeche.hinweis,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                  // Die aktuelle Position: eine Linie quer über die ganze
                  // Leiste, mit dem Monat direkt darüber. Beim Ziehen folgt
                  // sie dem Finger, sonst der Scroll-Position.
                  Positioned(
                    left: 0,
                    right: 0,
                    top: ((_dragFraction ?? _scrollFraction) * trackHeight)
                        .clamp(0.0, trackHeight - 1),
                    child: const SizedBox(
                      height: 1,
                      child: ColoredBox(color: DunkleFlaeche.text),
                    ),
                  ),
                  // Die aktive Beschriftung darf weiter nach rechts als die
                  // Jahreszahlen – "Nov. 2025" ist breiter als "2025", und
                  // sie liegt ohnehin obenauf.
                  Positioned(
                    right: 4,
                    left: 2,
                    top: (((_dragFraction ?? _scrollFraction) * trackHeight) - 16)
                        .clamp(0.0, trackHeight - 16),
                    child: Text(
                      _labelFor(widget.orderedKeys[_aktiverIndex(trackHeight)]),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: const TextStyle(
                        fontSize: 11,
                        height: 1.1,
                        color: DunkleFlaeche.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
