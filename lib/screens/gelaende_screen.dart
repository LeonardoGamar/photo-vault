import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'
    show DisabledMapCachingProvider, MapCachingProvider;
import 'package:http/http.dart' as http;

import '../l10n/app_localizations.dart';
import '../services/gelaende_laden.dart';
import '../services/gelaendeflug.dart';
import '../services/gelaendekacheln.dart';
import '../services/gelaendesicht.dart';
import '../theme/app_spacing.dart';
import '../widgets/gelaende.dart';
import '../widgets/mini_location_map.dart' show Kartenstil, eigeneKarte;

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
  /// dem Netz – und geht dann auch am gemeinsamen Kachelspeicher vorbei,
  /// damit ein Test nicht davon abhängt, was auf dieser Platte liegt.
  final http.Client? netz;

  /// Womit die Landschaft texturiert wird.
  ///
  /// **Warum das von aussen kommt.** Wer eine Wanderung nachfliegt, will
  /// meistens dieselbe Karte sehen, die er ohnehin benutzt – dieser
  /// Bildschirm kennt die Bibliothek aber nicht und kann die gemerkte
  /// Ansicht nicht selbst nachschlagen. Der Aufrufer reicht sie herein;
  /// umschalten lässt sie sich hier trotzdem.
  final Kartenstil stil;

  const GelaendeScreen({
    super.key,
    required this.spur,
    required this.titel,
    this.netz,
    this.stil = Kartenstil.topo,
  });

  @override
  State<GelaendeScreen> createState() => _GelaendeScreenState();
}

class _GelaendeScreenState extends State<GelaendeScreen> {
  Gelaendenetz? _netz;
  List<Raumpunkt> _spurImRaum = const [];
  List<Flugwert> _spurwerte = const [];
  ui.Image? _karte;
  bool _laedt = true;
  late Kartenstil _stil = widget.stil;

  /// Höhengitter und Ausschnitt bleiben gemerkt, damit ein Wechsel der
  /// Textur nicht auch die Höhen noch einmal aus dem Netz holt.
  Hoehengitter? _gitter;
  ({double sued, double west, double nord, double ost})? _ausschnitt;

  @override
  void initState() {
    super.initState();
    _laden();
  }

  PopupMenuItem<Kartenstil> _stilEintrag(
          Kartenstil stil, IconData symbol, String name) =>
      PopupMenuItem(
        value: stil,
        child: Row(
          children: [
            Icon(symbol,
                size: 18,
                color: stil == _stil
                    ? Theme.of(context).colorScheme.primary
                    : null),
            const SizedBox(width: AppSpacing.sm),
            Text(name),
          ],
        ),
      );

  /// Wechselt die Textur, **ohne das Höhengitter neu zu holen**.
  ///
  /// Das Gitter hängt am Ausschnitt und nicht am Kartenstil – es ein
  /// zweites Mal zu laden wären Sekunden für nichts, und bei einer
  /// grossen Spur sind es sechzehn Kacheln. Neu geholt wird allein das
  /// Kartenbild; das Netz wird aus dem gemerkten Gitter neu gebaut, weil
  /// seine Grundfarbe davon abhängt, ob überhaupt eine Karte darauf
  /// liegt (siehe [gelaendeGrundfarbe]).
  Future<void> _stilWechseln(Kartenstil neu) async {
    if (neu == _stil) return;
    final gitter = _gitter;
    final aus = _ausschnitt;
    setState(() => _stil = neu);
    // Ohne gemerktes Gitter gab es noch keinen erfolgreichen Lauf – dann
    // ist der volle Weg der richtige.
    if (gitter == null || aus == null) return _laden();

    setState(() => _laedt = true);
    final netz = widget.netz ?? http.Client();
    final MapCachingProvider? speicher =
        widget.netz == null ? null : const DisabledMapCachingProvider();
    try {
      final karte = await ladeKartenbild(
          sued: aus.sued,
          west: aus.west,
          nord: aus.nord,
          ost: aus.ost,
          netz: netz,
          stil: neu,
          speicher: speicher);
      if (!mounted) {
        karte?.dispose();
        return;
      }
      final gebaut = baueNetz(
        gitter,
        grundfarbe:
            karte == null ? gelaendeGrundfarbe : const Color(0xFFFFFFFF),
      );
      final gerechnet = _spurInMeter(gitter, gebaut);
      final alt = _karte;
      setState(() {
        _netz = gebaut;
        _karte = karte;
        _spurImRaum = gerechnet.linie;
        _spurwerte = gerechnet.werte;
        _laedt = false;
      });
      alt?.dispose();
    } finally {
      if (widget.netz == null) netz.close();
    }
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
    final MapCachingProvider? speicher =
        widget.netz == null ? null : const DisabledMapCachingProvider();
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
          sued: sued,
          west: west,
          nord: nord,
          ost: ost,
          netz: netz,
          speicher: speicher);
      if (!mounted) return;
      if (gitter == null) {
        setState(() {
          _netz = null;
          _laedt = false;
        });
        return;
      }
      final karte = await ladeKartenbild(
          sued: sued,
          west: west,
          nord: nord,
          ost: ost,
          netz: netz,
          stil: _stil,
          speicher: speicher);
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
      final gerechnet = _spurInMeter(gitter, gebaut);
      setState(() {
        _gitter = gitter;
        _ausschnitt = (sued: sued, west: west, nord: nord, ost: ost);
        _netz = gebaut;
        _karte = karte;
        _spurImRaum = gerechnet.linie;
        _spurwerte = gerechnet.werte;
        _laedt = false;
      });
    } finally {
      if (widget.netz == null) netz.close();
    }
  }

  /// Rechnet die Spur in dieselben Meter wie das Netz – und liefert die
  /// Zahlen dazu gleich mit.
  ///
  /// **Die Höhe kommt aus der Datei, nicht aus den Kacheln** – was das
  /// Gerät gemessen hat, ist die Aussage, die Kacheln sind die Kulisse.
  /// Nur wo die Datei keine Höhe führt, wird das Gelände gefragt.
  ///
  /// Zwei Meter Zugabe: Eine Linie genau auf der Oberfläche verschwindet
  /// halb darin, weil das Gitter zwischen den Stützpunkten gerade
  /// verläuft und der Berg gewölbt ist.
  ///
  /// Linie und Werte entstehen in einem Zug und sind damit
  /// zwangsläufig gleich lang.
  ///
  /// Getrennt gerechnet wäre es ein Fehler, der still bleibt: Punkte ohne
  /// jede Höhe fallen hier heraus, und eine zweite Schleife über
  /// `widget.spur` ergäbe eine um genau diese Punkte längere Werteliste.
  /// Jede Höhe und jedes Tempo stünde danach an der falschen Stelle,
  /// ohne dass irgendwo etwas abstürzt. Deshalb der gemeinsame Rückgabe-
  /// wert und der Merkposten in [Gelaendeflug].
  ({List<Raumpunkt> linie, List<Flugwert> werte}) _spurInMeter(
      Hoehengitter gitter, Gelaendenetz netz) {
    final g = gitter.verkleinert(gelaendeGitterkante);
    final spanne = g.spanne;
    final mittlereHoehe = (spanne.tief + spanne.hoch) / 2;
    final linie = <Raumpunkt>[];
    final werte = <Flugwert>[];
    for (final p in widget.spur) {
      final h = p.hoehe ?? g.anOrt(p.breite, p.laenge);
      if (h == null) continue;
      linie.add((
        x: ((p.laenge - g.west) / (g.ost - g.west) - 0.5) * netz.breiteMeter,
        y: (0.5 - (g.nord - p.breite) / (g.nord - g.sued)) * netz.hoeheMeter,
        z: (h + 2 - mittlereHoehe) * gelaendeUeberhoehung,
      ));
      // **Die Höhe der Datei, nicht die aus dem Gitter.** Wo die
      // Aufzeichnung eine trägt, ist sie die Aussage; das Gelände ist
      // nur eingesprungen, damit die Linie nicht abreisst. Für die
      // Anzeige zählt nur, was gemessen wurde – sonst stünde eine aus
      // Kacheln geratene Zahl neben einer echten, ununterscheidbar.
      werte.add((hoehe: p.hoehe, zeit: p.zeit));
    }
    return (linie: linie, werte: werte);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTexte.of(context);
    final farben = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('${t.gelaendeTitel} · ${widget.titel}'),
        actions: [
          // Die Textur umschalten, ohne den Bildschirm zu verlassen.
          // Ein Luftbild beantwortet eine andere Frage als eine
          // Wanderkarte: „wie sah es dort aus" gegen „wie hiess der Weg".
          PopupMenuButton<Kartenstil>(
            tooltip: t.gelaendeKarte,
            icon: const Icon(Icons.layers_outlined),
            onSelected: _stilWechseln,
            itemBuilder: (context) => [
              _stilEintrag(Kartenstil.topo, Icons.terrain_outlined,
                  t.karteTopografie),
              _stilEintrag(
                  Kartenstil.hell, Icons.light_mode_outlined, t.karteHell),
              _stilEintrag(
                  Kartenstil.dunkel, Icons.dark_mode_outlined, t.karteDunkel),
              // Die eigene Quelle nur, wenn es eine gibt – ein Eintrag,
              // der auf OpenStreetMap zurückfiele, wäre eine Lüge.
              if (eigeneKarte != null)
                _stilEintrag(Kartenstil.eigene, Icons.travel_explore_outlined,
                    eigeneKarte!.name),
            ],
          ),
        ],
      ),
      body: _laedt
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: AppSpacing.lg),
                  Text(t.gelaendeLaedt,
                      style: TextStyle(color: farben.onSurfaceVariant)),
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
              // Die Fussnoten gehen MIT hinein und liegen nicht darüber:
              // Die Flugleiste sitzt am unteren Rand der Ansicht, und ein
              // zweiter Stapel mit `bottom:` landete genau auf ihrem
              // Startknopf.
              : Gelaendeansicht(
                  netz: _netz!,
                  spur: _spurImRaum,
                  spurwerte: _spurwerte,
                  karte: _karte,
                  fussnoten: [
                    _Fussnote([
                      t.gelaendeBedienung,
                      t.gelaendeUeberhoeht(
                          gelaendeUeberhoehung.toStringAsFixed(0)),
                    ].join(' · ')),
                    _Fussnote(t.gelaendeNamensnennung),
                  ],
                ),
    );
  }
}

/// Die beiden Zeilen am unteren Rand: links die Bedienung, rechts die
/// Quellen.
///
/// **Elf Punkte und nicht neun.** Links steht keine Namensnennung,
/// sondern die Anleitung – wie man dreht, kippt und zoomt. Neun Punkte
/// sind die Groesse, in der man Rechtevermerke wegschaut; sie war hier
/// zugleich die Groesse, in der die einzige Erklaerung der Bedienung
/// stand (15. Pruefrunde).
class _Fussnote extends StatelessWidget {
  static const double schriftgroesse = 11;

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
              fontSize: schriftgroesse,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      );
}
