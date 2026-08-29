import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/zierbaum.dart';
import '../theme/zierbaum_farben.dart';
import 'profilbild.dart';
import 'zierbaum_maler.dart';

/// Was auf einem Schild steht.
@immutable
class Schildinhalt {
  final String name;

  /// Wie diese Person zur Mitte steht – bei der Mitte selbst `null`.
  final String? verwandtschaft;

  /// Der Gesichtsausschnitt, falls es einen gibt.
  final File? bild;

  /// „1874–1955", „*1972" – oder `null`, wenn nichts bekannt ist.
  ///
  /// Steht auf dem Schild, weil sie auf der alten Karte stand: Ein
  /// Stammbaum ohne Jahreszahlen beantwortet die halben Fragen nicht,
  /// die man an ihn stellt. Sie beim Umbau stillschweigend wegzulassen
  /// wäre ein Verlust gewesen, den niemand bestellt hat.
  final String? lebensspanne;

  /// Ob über bzw. unter der Person noch etwas steht, das dieses Bild
  /// nicht zeigt.
  final bool weitereOben;
  final bool weitereUnten;

  const Schildinhalt({
    required this.name,
    this.verwandtschaft,
    this.bild,
    this.lebensspanne,
    this.weitereOben = false,
    this.weitereUnten = false,
  });
}

/// Der Zierbaum: gemalter Grund, echte Schilder darüber.
///
/// **Die Aufteilung ist der Kern.** Grund, Stamm, Äste und Ranken malt
/// [ZierbaumMaler]; die Schilder liegen als gewöhnliche Widgets in einem
/// [Stack] darüber. Damit bleiben Antippen, Rechtsklick-Menü,
/// Kurzhinweis, Tastaturfokus und Sprachausgabe erhalten, ohne dass
/// irgendetwas davon nachgebaut werden müsste – und das Profilbild ist
/// dasselbe Widget wie überall sonst.
class ZierbaumAnsicht extends StatelessWidget {
  final Zierbaumplan plan;
  final Zierbaumfarben farben;

  /// Was auf dem Schild dieser Person steht.
  final Schildinhalt Function(String personId) inhalt;

  /// Die Person in der Mitte – ihr Schild hebt sich ab.
  final String fokusId;

  final void Function(String personId) beiTipp;
  final void Function(String personId, Offset stelle) beiMenue;

  /// Steht unten am Stamm. `null`, wenn sich kein gemeinsamer Name
  /// findet – dann bleibt die Zeile weg, statt etwas zu behaupten.
  final String? familienname;

  /// Der Kurzhinweis am Menüknopf jedes Schildes.
  final String menueHinweis;

  /// Wie gross das Bild mindestens wird.
  ///
  /// Ein rollbarer Bereich gibt seinem Kind unbegrenzten Platz; ohne
  /// diese Untergrenze wäre der gemalte Grund nur so gross wie der Baum,
  /// und daneben stünde die gewöhnliche Hintergrundfarbe – ein Bild mit
  /// einer Kante mitten im Fenster.
  final Size mindestens;

  const ZierbaumAnsicht({
    super.key,
    required this.plan,
    required this.farben,
    required this.inhalt,
    required this.fokusId,
    required this.beiTipp,
    required this.beiMenue,
    required this.menueHinweis,
    this.familienname,
    this.mindestens = Size.zero,
  });

  @override
  Widget build(BuildContext context) {
    final breite = math.max(plan.breite, mindestens.width);
    final hoehe = math.max(plan.hoehe, mindestens.height);
    // Der Baum steht mittig, wenn Platz übrig ist.
    final versatzX = (breite - plan.breite) / 2;
    return SizedBox(
      width: breite,
      height: hoehe,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: ZierbaumMaler(
                plan: plan,
                farben: farben,
                versatzX: versatzX,
                // Damit der Stamm an der Person in der Mitte ansetzt und
                // nicht am tiefsten Schild.
                fokusId: fokusId,
              ),
            ),
          ),
          if (familienname != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 28,
              child: Text(
                familienname!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: farben.familienname,
                  fontSize: 46,
                  letterSpacing: 2,
                  fontFamily: zierschriftGross,
                ),
              ),
            ),
          for (final schild in plan.schilder)
            Positioned(
              left: schild.links + versatzX,
              top: schild.oben,
              width: schild.breite,
              height: schild.hoehe,
              child: _Schild(
                inhalt: inhalt(schild.personId),
                farben: farben,
                istMitte: schild.personId == fokusId,
                onTap: () => beiTipp(schild.personId),
                onMenue: (stelle) => beiMenue(schild.personId, stelle),
                menueHinweis: menueHinweis,
              ),
            ),
        ],
      ),
    );
  }
}

/// Ein einzelnes Schild: Porträt, Name, Verwandtschaft.
class _Schild extends StatelessWidget {
  final Schildinhalt inhalt;
  final Zierbaumfarben farben;
  final bool istMitte;
  final VoidCallback onTap;
  final void Function(Offset stelle) onMenue;

  /// Der Kurzhinweis am Menüknopf.
  final String menueHinweis;

  const _Schild({
    required this.inhalt,
    required this.farben,
    required this.istMitte,
    required this.onTap,
    required this.onMenue,
    required this.menueHinweis,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: [
        inhalt.name,
        if (inhalt.verwandtschaft != null) inhalt.verwandtschaft!,
        if (inhalt.lebensspanne != null) inhalt.lebensspanne!,
      ].join(', '),
      child: GestureDetector(
        onSecondaryTapDown: (d) => onMenue(d.globalPosition),
        onLongPressStart: (d) => onMenue(d.globalPosition),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            InkWell(
              onTap: istMitte ? null : onTap,
              borderRadius: BorderRadius.circular(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Das Porträt sitzt ÜBER dem Schild und ragt darüber
                  // hinaus, wie ein Bildnis über einer Tafel. Innerhalb
                  // des Schildes bliebe für den Namen nichts übrig.
                  Profilbild(
                    datei: inhalt.bild,
                    radius: 19,
                    hintergrund: farben.schildUnten,
                    symbolgroesse: 20,
                    symbolfarbe: farben.schildRand,
                  ),
                  const SizedBox(height: 3),
                  Expanded(child: _tafel(context)),
                ],
              ),
            ),
            // **Ein sichtbarer Weg ins Menü.** Rechtsklick und langes
            // Drücken tun dasselbe, aber beide muss man kennen. Auf der
            // alten Karte stand dieser Knopf, und ihn beim Umbau
            // wegzulassen hiesse, eine Tür zuzumauern – derselbe Fehler
            // wie beim Papierkorb, der eine Prüfrunde lang keinen
            // Eingang hatte.
            Positioned(
              top: 0,
              right: 0,
              child: Builder(
                builder: (knopfKontext) => IconButton(
                  iconSize: 15,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.all(2),
                  constraints: const BoxConstraints(),
                  tooltip: menueHinweis,
                  color: farben.schildRand,
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    final kasten =
                        knopfKontext.findRenderObject() as RenderBox;
                    onMenue(kasten
                        .localToGlobal(kasten.size.bottomLeft(Offset.zero)));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tafel(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [farben.schildOben, farben.schildUnten],
          ),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: istMitte ? farben.mitteRand : farben.schildRand,
            width: istMitte ? 2.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (inhalt.weitereOben)
              _mehr(nachOben: true),
            Flexible(
              child: Text(
                inhalt.name,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: farben.schrift,
                  fontSize: 14,
                  height: 1.1,
                  fontFamily: zierschrift,
                  fontVariations: zierGewicht(istMitte ? 700 : 600),
                ),
              ),
            ),
            if (inhalt.verwandtschaft != null)
              Flexible(
                child: Text(
                  inhalt.verwandtschaft!,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  // Kein Kursiv: Die kursive Fassung waere eine zweite
                  // Datei von 754 kB, und ein kuenstlich geneigtes
                  // Garamond sieht schlechter aus als ein aufrechtes.
                  // Unterschieden wird ueber Groesse und Farbe.
                  style: TextStyle(
                    color: farben.nebenschrift,
                    fontSize: 11,
                    fontFamily: zierschrift,
                  ),
                ),
              ),
            if (inhalt.lebensspanne != null)
              Flexible(
                child: Text(
                  inhalt.lebensspanne!,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: farben.nebenschrift,
                    fontSize: 10,
                    fontFamily: zierschrift,
                  ),
                ),
              ),
            if (inhalt.weitereUnten) _mehr(nachOben: false),
          ],
        ),
      );

  /// Das Zeichen „hier geht es weiter, aber nicht in diesem Bild".
  Widget _mehr({required bool nachOben}) => Icon(
        nachOben ? Icons.more_horiz : Icons.more_horiz,
        size: 12,
        color: farben.schildRand,
      );
}
