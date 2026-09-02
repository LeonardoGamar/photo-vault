import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../db/database.dart';
import '../services/rasterauswahl.dart';
import '../theme/app_spacing.dart';

/// Maus mit Zusatztasten und Tastatur für die Fotoraster – an einer Stelle
/// für alle vier Bildschirme, die eine Mehrfachauswahl kennen (Zeitleiste,
/// Kalenderjahr, Album, Suche).
///
/// **Warum ein Mixin und keine vier Umsetzungen.** Genau diese Frage hat
/// schon einmal Geld gekostet: Die Liste der zu einem Foto gehörenden Dateien
/// stand dreimal von Hand da und lief zweimal auseinander (siehe
/// `LibraryState.dateienVon`). Eine Bedienung, die auf einem Raster anders
/// reagiert als auf dem daneben, ist derselbe Fehler in Grün.
///
/// Der Mixin verwaltet die Auswahlmenge **nicht** selbst – die Bildschirme
/// haben sie längst und reichen sie über [auswahl] herein. So kommt kein
/// zweiter Ort dazu, an dem steht, was ausgewählt ist.
mixin Rasterbedienung<T extends StatefulWidget> on State<T> {
  // ---- vom Bildschirm zu liefern ----

  /// Die Auswahlmenge des Bildschirms. Wird von hier aus verändert.
  Set<String> get auswahl;

  AppDatabase get rasterDb;

  /// Die Fotos in Anzeigereihenfolge. Leer, solange nichts geladen ist.
  List<AssetData> get rasterAssets;

  /// Wie viele Spalten das Raster gerade zeigt – aus dem `LayoutBuilder` des
  /// Bildschirms. Bestimmt, wie weit „Pfeil nach unten" springt.
  int get rasterSpalten;

  /// Je Gruppe die Länge jeder Reihe – nur für Raster **ohne** feste
  /// Spaltenzahl.
  ///
  /// `null` heisst: Es gibt eine, [rasterSpalten] genügt. Die Zeitleiste
  /// liefert hier ihre bündigen Reihen; ohne das spränge „nach unten"
  /// irgendwohin, weil dort mal drei und mal dreizehn Fotos nebeneinander
  /// stehen.
  List<List<int>>? get rasterReihenlaengen => null;

  /// Öffnet die Vollbildansicht bei diesem Foto (einfacher Klick ohne
  /// bestehende Auswahl, oder Eingabetaste).
  void rasterOeffne(AssetData asset);

  /// Die Gruppen, in denen das Raster die Fotos zeigt. Vorgabe ist eine
  /// einzige Gruppe – richtig für jedes flache `GridView`. Die Zeitleiste und
  /// das Kalenderjahr überschreiben das mit ihren Monatsgruppen, sonst spränge
  /// der Zeiger über eine Monatsüberschrift hinweg an die falsche Stelle.
  List<List<String>> get rasterGruppen => [
        [for (final a in rasterAssets) a.id],
      ];

  // ---- Zustand ----

  /// Wo ein mit der Umschalttaste aufgezogener Bereich beginnt.
  String? anker;

  /// Die Kachel, auf der die Tastatur steht (bekommt den Rahmen).
  String? aktiveKachel;

  /// Wird nach jeder Änderung an Bewertung/Farbmarke/Favorit aufgerufen –
  /// Bildschirme mit einem Datenstrom brauchen nichts zu tun, Bildschirme mit
  /// einer einmal geladenen Liste laden hier nach.
  Future<void> rasterAktualisieren() async {}

  // ---- Maus ----

  /// Ein Klick auf eine Kachel, mit oder ohne Zusatztaste.
  ///
  /// Ohne Zusatztaste bleibt alles beim Alten: Gibt es schon eine Auswahl,
  /// schaltet der Klick diese Kachel um; gibt es keine, öffnet er das Foto.
  /// Das ist die Bedienung, die es immer gab, und sie funktioniert weiterhin
  /// mit dem Finger.
  void rasterKlick(AssetData asset) {
    final art = klickartAus(HardwareKeyboard.instance.logicalKeysPressed);
    final ankerVorher = anker;

    switch (art) {
      case Klickart.bereich:
        setState(() {
          aktiveKachel = asset.id;
          if (ankerVorher == null) {
            auswahl.add(asset.id);
            anker = asset.id;
          } else {
            final erweitert = auswahlMitBereich(
              [for (final a in rasterAssets) a.id],
              auswahl,
              ankerVorher,
              asset.id,
            );
            auswahl
              ..clear()
              ..addAll(erweitert);
          }
        });

      case Klickart.einzeln:
        setState(() {
          if (!auswahl.remove(asset.id)) auswahl.add(asset.id);
          anker = asset.id;
          aktiveKachel = asset.id;
        });

      case Klickart.einfach:
        if (auswahl.isNotEmpty) {
          setState(() {
            if (!auswahl.remove(asset.id)) auswahl.add(asset.id);
            anker = asset.id;
            aktiveKachel = asset.id;
          });
        } else {
          setState(() {
            anker = asset.id;
            aktiveKachel = asset.id;
          });
          rasterOeffne(asset);
        }
    }
  }

  // ---- Tastatur ----

  /// Umschliesst [kind] mit der Tastaturbedienung.
  ///
  /// `autofocus` ist gesetzt, weil das Raster den Bildschirm füllt: Wer ihn
  /// öffnet, will tippen können, ohne vorher irgendwohin zu klicken.
  Widget mitTastatur({required Widget kind}) =>
      Focus(autofocus: true, onKeyEvent: rasterTaste, child: kind);

  /// Ob gerade in ein Textfeld geschrieben wird.
  ///
  /// Ohne diese Prüfung wäre die Suche unbenutzbar: Der Mixin sitzt als
  /// `Focus` über dem ganzen Bildschirm, und Zifferntasten laufen an einem
  /// Textfeld vorbei nach oben durch. „2026" ins Suchfeld getippt hiesse
  /// sonst: vier Bewertungen vergeben.
  bool _schreibtGerade() {
    final ctx = FocusManager.instance.primaryFocus?.context;
    return ctx != null &&
        ctx.findAncestorStateOfType<EditableTextState>() != null;
  }

  KeyEventResult rasterTaste(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (_schreibtGerade()) return KeyEventResult.ignored;
    if (rasterAssets.isEmpty) return KeyEventResult.ignored;

    final taste = event.logicalKey;
    final gedrueckt = HardwareKeyboard.instance.logicalKeysPressed;
    final art = klickartAus(gedrueckt);
    final mitUmschalt = art == Klickart.bereich;

    // Strg bzw. Command gehören den Fensterkürzeln, nicht dem Raster: Die
    // Hülle schaltet mit ⌘1…⌘9 den Bereich um (siehe HomeShell). Ohne diese
    // Zeile fingen wir ⌘3 ab, setzten eine Bewertung und meldeten die Taste
    // als erledigt – der Bereichswechsel käme nie an.
    if (art == Klickart.einzeln) return KeyEventResult.ignored;

    final richtungen = <LogicalKeyboardKey, Rasterrichtung>{
      LogicalKeyboardKey.arrowLeft: Rasterrichtung.links,
      LogicalKeyboardKey.arrowRight: Rasterrichtung.rechts,
      LogicalKeyboardKey.arrowUp: Rasterrichtung.hoch,
      LogicalKeyboardKey.arrowDown: Rasterrichtung.runter,
    };
    final richtung = richtungen[taste];
    if (richtung != null) {
      _bewegeZeiger(richtung, mitUmschalt: mitUmschalt);
      return KeyEventResult.handled;
    }

    if (taste == LogicalKeyboardKey.escape) {
      if (auswahl.isEmpty) return KeyEventResult.ignored;
      setState(() {
        auswahl.clear();
        anker = null;
      });
      return KeyEventResult.handled;
    }

    if (taste == LogicalKeyboardKey.enter ||
        taste == LogicalKeyboardKey.numpadEnter) {
      final id = aktiveKachel;
      if (id == null) return KeyEventResult.ignored;
      final treffer = rasterAssets.where((a) => a.id == id);
      if (treffer.isEmpty) return KeyEventResult.ignored;
      rasterOeffne(treffer.first);
      return KeyEventResult.handled;
    }

    final ziele = tastenziel(auswahl, aktiveKachel);
    if (ziele.isEmpty) return KeyEventResult.ignored;

    final bewertung = bewertungFuerZiffer(taste);
    if (bewertung != null) {
      _fuehreAus(rasterDb.setRatingBulk(ziele, bewertung));
      return KeyEventResult.handled;
    }

    final farbe = farbmarkeFuerZiffer(taste);
    if (farbe != null) {
      // Dieselbe Farbe erneut nimmt die Marke wieder weg – genau wie ein
      // zweiter Klick auf denselben Kreis in der Palette. Massgeblich ist
      // dabei die aktive Kachel bzw. das erste Foto der Auswahl; bei
      // gemischten Marken setzt die Taste also erst einmal alle gleich.
      final erstes = rasterAssets.where((a) => a.id == ziele.first);
      final schonSo = erstes.isNotEmpty && erstes.first.colorLabel == farbe;
      _fuehreAus(rasterDb.setColorLabelBulk(ziele, schonSo ? null : farbe));
      return KeyEventResult.handled;
    }

    if (taste == LogicalKeyboardKey.keyF) {
      final erstes = rasterAssets.where((a) => a.id == ziele.first);
      final schonSo = erstes.isNotEmpty && erstes.first.isFavorite;
      _fuehreAus(rasterDb.setFavoriteBulk(ziele, !schonSo));
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  /// Führt eine Datenbankänderung aus und lädt danach nach.
  ///
  /// Kein `await` im Tastenpfad: Ein `KeyEventResult` muss sofort zurück,
  /// sonst gilt die Taste als unbehandelt und wandert weiter nach oben.
  void _fuehreAus(Future<void> aenderung) {
    aenderung.then((_) {
      if (mounted) rasterAktualisieren();
    });
  }

  void _bewegeZeiger(Rasterrichtung richtung, {required bool mitUmschalt}) {
    final start = aktiveKachel;
    if (start == null) {
      // Erster Tastendruck ohne Zeiger: beim ersten Foto anfangen, statt
      // wortlos nichts zu tun.
      setState(() {
        aktiveKachel = rasterAssets.first.id;
        anker ??= aktiveKachel;
      });
      return;
    }
    final ziel = nachbarkachel(
      gruppen: rasterGruppen,
      von: start,
      richtung: richtung,
      spalten: rasterSpalten,
      reihenlaengen: rasterReihenlaengen,
    );
    if (ziel == null) return;
    setState(() {
      aktiveKachel = ziel;
      if (mitUmschalt) {
        final ab = anker ?? start;
        anker = ab;
        final erweitert = auswahlMitBereich(
          [for (final a in rasterAssets) a.id],
          auswahl,
          ab,
          ziel,
        );
        auswahl
          ..clear()
          ..addAll(erweitert);
      } else {
        anker = ziel;
      }
    });
  }
}

/// Spaltenzahl eines flachen Fotorasters (Album, Suche) bei dieser Breite.
///
/// Dieselbe Formel wie in `SliverGridDelegateWithMaxCrossAxisExtent`; die
/// Zeitleiste hat ihre eigene, weil dort noch der Zeitstrahl abgeht (siehe
/// `rasterSpaltenzahl`). [seitenpolster] ist die Summe aus linkem und rechtem
/// Rand.
int flachesRasterSpalten(
  double breite, {
  double seitenpolster = 0,
  double maxKachel = 160,
  double abstand = 4,
}) {
  final nutzbar = breite - seitenpolster;
  if (nutzbar <= 0) return 1;
  final zahl = (nutzbar / (maxKachel + abstand)).ceil();
  return zahl < 1 ? 1 : zahl;
}

/// Bleibender Rahmen um die Kachel, auf der die Tastatur steht.
///
/// Bewusst anders als das Auswahl-Overlay: Die aktive Kachel ist nicht
/// dasselbe wie eine ausgewählte, und beides kann gleichzeitig zutreffen. Der
/// Rahmen liegt deshalb aussen um die Kachel herum statt darauf.
class AktiveKachelRahmen extends StatelessWidget {
  final Widget child;
  const AktiveKachelRahmen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border:
            Border.all(color: Theme.of(context).colorScheme.primary, width: 3),
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: child,
    );
  }
}
