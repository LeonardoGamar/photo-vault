import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:photo_vault/widgets/mini_location_map.dart';

/// Der Kachelspeicher der Karte.
///
/// Warum das überhaupt geprüft wird: Ohne eigene Angabe richtet sich
/// flutter_map nach dem `max-age` der Antwort – und OpenTopoMap gibt
/// ausgerechnet den frisch gerenderten, also teuersten Kacheln die
/// kürzeste Haltbarkeit (3,5 h gegenüber 7 Tagen bei vorgerenderten).
/// Läuft eine Kachel ab, macht flutter_map vor der Anzeige einen
/// blockierenden Rückfrage-Umlauf. Am selben Ort einen Tag später
/// wartet man also erneut.
void main() {
  test('die Frische ist lang genug, um den Zweck zu erfuellen', () {
    // Die kuerzeste beobachtete Haltbarkeit von OpenTopoMap lag bei rund
    // 3,5 Stunden. Alles darunter waere wirkungslos; ein Tag waere
    // besser, aber immer noch bei jedem zweiten Besuch teuer.
    expect(kartenKachelFrische.inDays, greaterThanOrEqualTo(7),
        reason: 'unter einer Woche greift die Massnahme kaum');
    // Nach oben ebenfalls begrenzt: Strassen aendern sich, und die
    // Kacheln sollen nicht auf Dauer veralten.
    expect(kartenKachelFrische.inDays, lessThanOrEqualTo(90));
  });

  test('die Speichergrenze ist gesetzt und massvoll', () {
    // Die Vorgabe von flutter_map ist 1 GB. Fuer eine Fotoverwaltung,
    // deren Karte ein Nebenschauplatz ist, waere das viel.
    expect(kartenSpeicherGrenze, greaterThan(50 * 1024 * 1024),
        reason: 'zu klein hiesse staendiges Nachladen');
    expect(kartenSpeicherGrenze, lessThanOrEqualTo(500 * 1024 * 1024));
  });

  group('Die Verdrahtung', () {
    // Beides sind Quelltext-Pruefungen nach dem Muster von
    // keine_festen_texte_test.dart. Sie sehen etwas, das weder `analyze`
    // noch ein Laufzeittest sieht - und im Unittest laesst sich der
    // Speicher gar nicht anlegen, weil path_provider keine
    // Plattformkanaele hat.
    final quellen = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .map((f) => (f.path, f.readAsStringSync()))
        .toList();

    test('der Speicher wird an genau EINER Stelle angelegt', () {
      // `getOrCreateInstance` ist ein Einzelstueck: Die Angaben wirken
      // nur beim ERSTEN Aufruf. Ein zweiter Aufruf mit anderen Werten
      // waere wirkungslos - und der Fehler zeigte sich erst Wochen
      // spaeter als "die Karte ist wieder langsam".
      final stellen = [
        for (final (pfad, inhalt) in quellen)
          if (inhalt.contains('BuiltInMapCachingProvider.getOrCreateInstance'))
            pfad
      ];
      expect(stellen, hasLength(1), reason: 'gefunden in: $stellen');
      expect(stellen.single, endsWith('mini_location_map.dart'));
    });

    test('der Kachelanbieter wird an genau EINER Stelle gebaut', () {
      // Dieselbe Falle wie beim Speicher, nur schaerfer:
      // buildMapTileLayer laeuft bei JEDEM Neuaufbau, und
      // TileLayer.didUpdateWidget entsorgt den alten Anbieter NICHT -
      // ein Anbieter je Aufbau hinterliesse jedes Mal einen offenen
      // HTTP-Client. Deshalb gibt es genau ein Exemplar.
      final stellen = [
        for (final (pfad, inhalt) in quellen)
          if (inhalt.contains('NetworkTileProvider(')) pfad
      ];
      expect(stellen, hasLength(1), reason: 'gefunden in: $stellen');
      expect(stellen.single, endsWith('mini_location_map.dart'));
    });

    test('das Einzelstueck wird wirklich wiederverwendet', () {
      // Der Unterschied zwischen „einmal geschrieben" und „einmal
      // erzeugt": Stuende dort `=>  NetworkTileProvider(...)` ohne
      // Zwischenspeicher, faende der Test oben trotzdem eine Stelle -
      // und es entstuende bei jedem Aufbau ein neuer Anbieter.
      final quelle = quellen
          .firstWhere((q) => q.$1.endsWith('mini_location_map.dart')).$2;
      expect(quelle, contains('_kachelAnbieter ??='),
          reason: 'sonst ist es kein Einzelstueck, sondern eine Fabrik');
    });
  });
}
