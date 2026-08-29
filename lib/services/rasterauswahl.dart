/// Was Zusatztasten und Pfeiltasten in einem Fotoraster bewirken – als reine
/// Rechnung, ohne Widgets.
///
/// Getrennt vom Bildschirm aus demselben Grund wie `baumnavigation.dart`: Die
/// Frage „welche Kacheln liegen zwischen diesen beiden" hat eine Antwort, die
/// man hinschreiben und prüfen kann, ohne ein Pixel zu bauen. Im Bildschirm
/// bliebe sie zwischen Rollbalken und Rasterberechnung verstreut.
library;

import 'package:flutter/services.dart';

/// Welche Zusatztaste beim Klick gedrückt war.
enum Klickart {
  /// Ohne Zusatztaste.
  einfach,

  /// Umschalttaste: alles zwischen Anker und Ziel dazunehmen.
  bereich,

  /// Strg (Windows/Linux) bzw. Command (macOS): genau diese eine Kachel
  /// umschalten, unabhängig davon, ob schon etwas ausgewählt ist.
  einzeln,
}

/// Liest die Klickart aus den gerade gedrückten Tasten.
///
/// Die Umschalttaste gewinnt, wenn beide gedrückt sind – ein Bereich ist die
/// stärkere Aussage, und „Umschalt+Strg" bedeutet in Dateimanagern dasselbe
/// wie Umschalt allein, sobald ein Anker existiert.
///
/// `meta` deckt die Command-Taste ab (macOS), `control` die Strg-Taste. Beide
/// werden auf allen Plattformen akzeptiert: Eine externe Tastatur an einem Mac
/// meldet je nach Belegung das eine oder das andere, und eine Taste
/// abzulehnen, die der Nutzer bewusst gedrückt hat, wäre nirgends hilfreich.
Klickart klickartAus(Set<LogicalKeyboardKey> gedrueckt) {
  final umschalt = <LogicalKeyboardKey>{
    LogicalKeyboardKey.shift,
    LogicalKeyboardKey.shiftLeft,
    LogicalKeyboardKey.shiftRight,
  };
  final einzeln = <LogicalKeyboardKey>{
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.controlLeft,
    LogicalKeyboardKey.controlRight,
    LogicalKeyboardKey.meta,
    LogicalKeyboardKey.metaLeft,
    LogicalKeyboardKey.metaRight,
  };
  if (gedrueckt.any(umschalt.contains)) return Klickart.bereich;
  if (gedrueckt.any(einzeln.contains)) return Klickart.einzeln;
  return Klickart.einfach;
}

/// Die bestehende [auswahl] **vereinigt** mit allem, was in [reihenfolge]
/// zwischen [anker] und [ziel] liegt (beide einschliesslich).
///
/// Bewusst vereinigend und nicht ersetzend. Der Dateimanager wirft bei einem
/// Umschalt-Klick alles ausserhalb des Bereichs weg; beim Aussuchen von Fotos
/// ist das die teuerste denkbare Fehlbedienung, weil man den Verlust erst
/// bemerkt, wenn die Zahl in der Leiste kleiner geworden ist. Abwählen geht
/// weiterhin einzeln.
///
/// Kommt eine der beiden Kennungen in [reihenfolge] nicht vor (etwa weil das
/// Ladefenster inzwischen ein anderes ist), wird nur [ziel] hinzugefügt –
/// niemals ein geratener Bereich.
Set<String> auswahlMitBereich(
  List<String> reihenfolge,
  Set<String> auswahl,
  String anker,
  String ziel,
) {
  final neu = {...auswahl};
  final von = reihenfolge.indexOf(anker);
  final bis = reihenfolge.indexOf(ziel);
  if (von < 0 || bis < 0) {
    neu.add(ziel);
    return neu;
  }
  final erste = von <= bis ? von : bis;
  final letzte = von <= bis ? bis : von;
  for (var i = erste; i <= letzte; i++) {
    neu.add(reihenfolge[i]);
  }
  return neu;
}

/// Richtung einer Pfeiltaste im Raster.
enum Rasterrichtung { links, rechts, hoch, runter }

/// Die Nachbarkachel in einem nach Monaten gruppierten Raster, oder `null`,
/// wenn es in dieser Richtung keine gibt.
///
/// [gruppen] sind die Monatsgruppen in Anzeigereihenfolge, jede mit ihren
/// Kennungen in Anzeigereihenfolge. [spalten] ist die Spaltenzahl, die das
/// Raster gerade tatsächlich verwendet (siehe `timelineColumnsForWidth`) –
/// sie wird übergeben und nicht hier gerechnet, damit Bildschirm und
/// Navigation nicht zwei leicht verschiedene Formeln pflegen.
///
/// **Links/rechts** laufen über Gruppengrenzen hinweg, denn das ist schlicht
/// „das vorige/nächste Foto".
///
/// **Hoch/runter** springen um eine Zeile. Reicht der Sprung über die Gruppe
/// hinaus, landet er in der Nachbargruppe in derselben Spalte – bei „runter"
/// in deren erster Zeile, bei „hoch" in deren letzter. Ist diese Spalte dort
/// nicht besetzt (die letzte Zeile eines Monats ist selten voll), rückt er
/// auf die letzte belegte Kachel. Ohne diese Regel bliebe der Zeiger am
/// unteren Rand eines kurzen Monats hängen.
String? nachbarkachel({
  required List<List<String>> gruppen,
  required String von,
  required Rasterrichtung richtung,
  required int spalten,
}) {
  if (spalten < 1) return null;
  var gruppenIndex = -1;
  var index = -1;
  for (var g = 0; g < gruppen.length; g++) {
    final i = gruppen[g].indexOf(von);
    if (i != -1) {
      gruppenIndex = g;
      index = i;
      break;
    }
  }
  if (gruppenIndex == -1) return null;

  switch (richtung) {
    case Rasterrichtung.links:
    case Rasterrichtung.rechts:
      final schritt = richtung == Rasterrichtung.rechts ? 1 : -1;
      final flach = [for (final g in gruppen) ...g];
      final ziel = flach.indexOf(von) + schritt;
      return ziel < 0 || ziel >= flach.length ? null : flach[ziel];

    case Rasterrichtung.runter:
      final gruppe = gruppen[gruppenIndex];
      final ziel = index + spalten;
      if (ziel < gruppe.length) return gruppe[ziel];
      return _inNachbargruppe(
          gruppen, gruppenIndex + 1, index % spalten, spalten,
          ersteZeile: true);

    case Rasterrichtung.hoch:
      final gruppe = gruppen[gruppenIndex];
      final ziel = index - spalten;
      if (ziel >= 0) return gruppe[ziel];
      return _inNachbargruppe(
          gruppen, gruppenIndex - 1, index % spalten, spalten,
          ersteZeile: false);
  }
}

/// Die Kachel in Spalte [spalte] der ersten bzw. letzten Zeile von Gruppe
/// [gruppenIndex], auf die letzte belegte Kachel dieser Zeile begrenzt.
/// Überspringt leere Gruppen, statt bei einer davon aufzugeben.
String? _inNachbargruppe(
  List<List<String>> gruppen,
  int gruppenIndex,
  int spalte,
  int spalten, {
  required bool ersteZeile,
}) {
  final schritt = ersteZeile ? 1 : -1;
  for (var g = gruppenIndex; g >= 0 && g < gruppen.length; g += schritt) {
    final gruppe = gruppen[g];
    if (gruppe.isEmpty) continue;
    final zeilenanfang =
        ersteZeile ? 0 : ((gruppe.length - 1) ~/ spalten) * spalten;
    final ziel = zeilenanfang + spalte;
    return gruppe[ziel < gruppe.length ? ziel : gruppe.length - 1];
  }
  return null;
}

/// Worauf eine Taste wirkt: auf die Auswahl, wenn es eine gibt – sonst auf
/// die aktive Kachel.
///
/// Die Reihenfolge ist der Punkt. Wer zwanzig Fotos ausgewählt hat und „3"
/// drückt, meint die zwanzig; die aktive Kachel ist dann nur der Zeiger, an
/// dem er stehen geblieben ist. Umgekehrt wäre die Taste ohne Auswahl
/// wirkungslos, und das ist genau der Zustand, in dem man mit den Pfeiltasten
/// durch das Raster geht.
List<String> tastenziel(Set<String> auswahl, String? aktiveKachel) {
  if (auswahl.isNotEmpty) return auswahl.toList();
  return aktiveKachel == null ? const [] : [aktiveKachel];
}

/// Die Farbmarke zu einer Zifferntaste 6–9, oder `null` für jede andere Taste.
///
/// Vier statt fünf Farben, und das mit Absicht: Photo Mechanic und Lightroom
/// belegen seit jeher 6–9 mit Rot/Gelb/Grün/Blau und lassen Violett ohne
/// Taste. Eine fünfte Taste dazuzuerfinden hiesse, eine Gewohnheit zu brechen,
/// die Umsteiger mitbringen. Violett bleibt der Maus.
String? farbmarkeFuerZiffer(LogicalKeyboardKey taste) => switch (taste) {
      LogicalKeyboardKey.digit6 => 'red',
      LogicalKeyboardKey.digit7 => 'yellow',
      LogicalKeyboardKey.digit8 => 'green',
      LogicalKeyboardKey.digit9 => 'blue',
      _ => null,
    };

/// Die Bewertung zu einer Zifferntaste 0–5, oder `null` für jede andere Taste.
int? bewertungFuerZiffer(LogicalKeyboardKey taste) => switch (taste) {
      LogicalKeyboardKey.digit0 => 0,
      LogicalKeyboardKey.digit1 => 1,
      LogicalKeyboardKey.digit2 => 2,
      LogicalKeyboardKey.digit3 => 3,
      LogicalKeyboardKey.digit4 => 4,
      LogicalKeyboardKey.digit5 => 5,
      _ => null,
    };
