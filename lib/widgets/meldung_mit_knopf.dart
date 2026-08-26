import 'package:flutter/material.dart';

/// Eine Meldung mit Knopf, die trotzdem von selbst verschwindet.
///
/// **Flutter lässt sie sonst für immer stehen.** In `snack_bar.dart`:
///
/// ```dart
/// persist = persist ?? action != null;
/// ```
///
/// Jede Meldung mit Knopf bleibt also per Voreinstellung liegen, bis
/// jemand sie anfasst. Gemeint ist das gut – wer etwas zurücknehmen
/// können soll, braucht Zeit dafür. Gemessen an dem, was daraus wird,
/// ist es falsch: Die Meldung überlebt den Bildschirmwechsel, steht bei
/// der nächsten Aufgabe noch da und wird zu einem Möbelstück, das man
/// wegklicken muss.
///
/// Deshalb [dauer] statt „für immer" – lang genug, um den Knopf zu
/// finden, kurz genug, um zu verschwinden. Vier Sekunden (Flutters
/// Standard ohne Knopf) sind zu wenig, um einen Text zu lesen *und*
/// zu handeln.
SnackBar meldungMitKnopf({
  required Widget inhalt,
  required SnackBarAction knopf,
  Duration dauer = meldungMitKnopfDauer,
}) =>
    SnackBar(
      content: inhalt,
      action: knopf,
      duration: dauer,
      persist: false,
    );

/// Acht Sekunden: doppelt so lang wie eine Meldung ohne Knopf.
const Duration meldungMitKnopfDauer = Duration(seconds: 8);
