import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../l10n/app_localizations.dart';
import '../services/gelaende_laden.dart';
import '../services/gelaendekacheln.dart';
import '../services/gelaendesicht.dart';
import '../theme/app_spacing.dart';
import '../widgets/gelaende.dart';

/// Eine Spur in der Landschaft.
///
/// **Das Abbruchkriterium dieser Stufe war:** Zeigt die Landschaft mehr
/// als Karte plus Profil? Sie zeigt eine Sache, die keines von beiden
/// zeigt – *wo im Gelände* der Weg verläuft: an einem Hang entlang, über
/// einen Kamm, in einem Talgrund. Die Karte weiss das auch, aber sie
/// verlangt, Höhenlinien zu lesen; das Profil weiss nur, wie steil es
/// war, nicht wo.
class GelaendeScreen extends StatefulWidget {
  /// Die Punkte der Spur, in der Reihenfolge der Aufzeichnung.
  final List<Gelaendespurpunkt> spur;

  final String titel;

  /// Nur für Tests: Wer hier etwas hereinreicht, holt keine Kacheln aus
  /// dem Netz.
  final http.Client? netz;

  const GelaendeScreen({
    super.key,
    required this.spur,
    required this.titel,
    this.netz,
  });

  @override
  State<GelaendeScreen> createState() => _GelaendeScreenState();
}

class _GelaendeScreenState extends State<GelaendeScreen> {
  Gelaendenetz? _netz;
  List<Raumpunkt> _spurImRaum = const [];
  ui.Image? _karte;
  bool _laedt = true;

  @override
  void initState() {
    super.initState();
    _laden();
  }

  @override
  void dispose() {
    _karte?.dispose();
    super.dispose();
  }

  /// Wie viel Rand um die Spur herum geladen wird.
  ///
  /// Ein Fünftel der Ausdehnung. Ohne Rand endete die Landschaft genau
  /// an der Spur, und ein Weg, der am Abgrund der Welt entlangläuft,
  /// sieht falsch aus.
  static const double _randanteil = 0.2;

  Future<void> _laden() async {
    setState(() => _laedt = true);
    final netz = widget.netz ?? http.Client();
    try {
      var sued = double.infinity;
      var nord = double.negativeInfinity;
      var west = double.infinity;
      var ost = double.negativeInfinity;
      for (final p in widget.spur) {
        sued = math.min(sued, p.breite);
        nord = math.max(nord, p.breite);
        west = math.min(west, p.laenge);
        ost = math.max(ost, p.laenge);
      }
      if (!sued.isFinite) {
        if (mounted) setState(() => _laedt = false);
        return;
      }
      // Eine Mindestausdehnung, damit eine Spur, die auf der Stelle
      // aufgezeichnet wurde, kein Rechteck von null Grad ergibt.
      final randB = math.max((nord - sued) * _randanteil, 0.005);
      final randL = math.max((ost - west) * _randanteil, 0.005);
      sued -= randB;
      nord += randB;
      west -= randL;
      ost += randL;

      final gitter = await ladeHoehengitter(
          sued: sued, west: west, nord: nord, ost: ost, netz: netz);
      if (!mounted) return;
      if (gitter == null) {
        setState(() {
          _netz = null;
          _laedt = false;
        });
        return;
      }
      final karte = await ladeKartenbild(
          sued: sued, west: west, nord: nord, ost: ost, netz: netz);
      if (!mounted) {
        karte?.dispose();
        return;
      }

      // Erst die Karte, dann das Netz: Liegt eine Karte darauf, muss
      // die Grundfarbe Weiss sein (siehe [gelaendeGrundfarbe]).
      final gebaut = baueNetz(
        gitter,
        grundfarbe: karte == null ? gelaendeGrundfarbe : const Color(0xFFFFFFFF),
      );
      setState(() {
        _netz = gebaut;
        _karte = karte;
        _spurImRaum = _spurInMeter(gitter, gebaut);
        _laedt = false;
      });
    } finally {
      if (widget.netz == null) netz.close();
    }
  }

  /// Rechnet die Spur in dieselben Meter wie das Netz.
  ///
  /// **Die Höhe kommt aus der Datei, nicht aus den Kacheln** – was das
  /// Gerät gemessen hat, ist die Aussage, die Kacheln sind die Kulisse.
  /// Nur wo die Datei keine Höhe führt, wird das Gelände gefragt.
  ///
  /// Zwei Meter Zugabe: Eine Linie genau auf der Oberfläche verschwindet
  /// halb darin, weil das Gitter zwischen den Stützpunkten gerade
  /// verläuft und der Berg gewölbt ist.
  List<Raumpunkt> _spurInMeter(Hoehengitter gitter, Gelaendenetz netz) {
    final g = gitter.verkleinert(gelaendeGitterkante);
    final spanne = g.spanne;
    final mittlereHoehe = (spanne.tief + spanne.hoch) / 2;
    return [
      for (final p in widget.spur)
        if (p.hoehe ?? g.anOrt(p.breite, p.laenge) case final h?)
          (
            x: ((p.laenge - g.west) / (g.ost - g.west) - 0.5) *
                netz.breiteMeter,
            y: (0.5 - (g.nord - p.breite) / (g.nord - g.sued)) *
                netz.hoeheMeter,
            z: (h + 2 - mittlereHoehe) * gelaendeUeberhoehung,
          ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTexte.of(context);
    final farben = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text('${t.gelaendeTitel} · ${widget.titel}')),
      body: _laedt
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: AppSpacing.lg),
                  Text(t.gelaendeLaedt,
                      style: TextStyle(color: farben.outline)),
                ],
              ),
            )
          : _netz == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: SizedBox(
                      width: 420,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(t.gelaendeNichts,
                              textAlign: TextAlign.center),
                          const SizedBox(height: AppSpacing.lg),
                          FilledButton(
                            onPressed: _laden,
                            child: Text(t.gelaendeErneut),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Stack(
                  children: [
                    Positioned.fill(
                      child: Gelaendeansicht(
                        netz: _netz!,
                        spur: _spurImRaum,
                        karte: _karte,
                      ),
                    ),
                    Positioned(
                      left: AppSpacing.md,
                      bottom: AppSpacing.md,
                      child: _Fussnote([
                        t.gelaendeBedienung,
                        t.gelaendeUeberhoeht(
                            gelaendeUeberhoehung.toStringAsFixed(0)),
                      ].join(' · ')),
                    ),
                    Positioned(
                      right: AppSpacing.md,
                      bottom: AppSpacing.md,
                      child: _Fussnote(t.gelaendeNamensnennung),
                    ),
                  ],
                ),
    );
  }
}

class _Fussnote extends StatelessWidget {
  final String text;
  const _Fussnote(this.text);

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: Theme.of(context)
            .colorScheme
            .surface
            .withValues(alpha: 0.75),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 9,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      );
}
