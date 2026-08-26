import 'package:flutter_test/flutter_test.dart';
import 'package:photo_vault/services/reiseroute.dart';

/// Route und Tageskapitel einer Reise.
void main() {
  Routenpunkt p(double b, double l, int stunde) =>
      (breite: b, laenge: l, zeit: DateTime(2024, 6, 3, stunde));

  group('Die Route', () {
    test('fasst dicht beieinanderliegende Aufnahmen zusammen', () {
      // An der echten Bibliothek: 356 Aufnahmen, davon ueber dreihundert
      // an derselben Stelle. Als Linie waeren das dreihundert
      // deckungsgleiche Ecken.
      final route = reiseroute([
        for (var i = 0; i < 50; i++) p(41.900, 12.500, i % 24),
      ]);
      expect(route, hasLength(1),
          reason: 'auch der letzte Punkt faellt weg – er liegt dort, wo der '
              'erste schon steht');
    });

    test('behaelt weit auseinanderliegende Punkte', () {
      final route = reiseroute([
        p(41.90, 12.50, 9),
        p(43.77, 11.26, 12),
        p(45.44, 12.32, 18),
      ]);
      expect(route, hasLength(3));
    });

    test('der letzte Punkt bleibt immer stehen', () {
      // Wo eine Reise endet, ist eine Angabe, auch wenn der Rueckweg
      // kurz war.
      final route = reiseroute([
        p(41.900, 12.500, 9),
        p(43.770, 11.260, 12),
        // Nur wenige Meter vom vorigen entfernt – wuerde sonst wegfallen.
        p(43.7702, 11.2602, 20),
      ]);
      expect(route.last.zeit.hour, 20);
      expect(route, hasLength(3));
    });

    test('sortiert nach Zeit, nicht nach Eingabereihenfolge', () {
      final route = reiseroute([
        p(45.44, 12.32, 18),
        p(41.90, 12.50, 9),
      ]);
      expect(route.first.zeit.hour, 9);
    });

    test('ein einzelner Punkt bleibt ein Punkt', () {
      expect(reiseroute([p(41.9, 12.5, 9)]), hasLength(1));
      expect(reiseroute(const []), isEmpty);
    });
  });

  group('Die Tageskapitel', () {
    ({String id, DateTime zeit, String? stadt}) a(
            String id, DateTime zeit, String? stadt) =>
        (id: id, zeit: zeit, stadt: stadt);

    test('teilen nach Kalendertagen', () {
      // Was um 23:50 aufgenommen wurde, gehoert zum 4. Juni und nicht zum
      // halben fuenften.
      final tage = reisetage([
        a('a', DateTime(2024, 6, 4, 23, 50), 'Roma'),
        a('b', DateTime(2024, 6, 5, 0, 10), 'Roma'),
      ]);
      expect(tage, hasLength(2));
      expect(tage.first.tag, DateTime(2024, 6, 4));
    });

    test('kommen chronologisch', () {
      final tage = reisetage([
        a('spaet', DateTime(2024, 6, 6, 10), 'Roma'),
        a('frueh', DateTime(2024, 6, 4, 10), 'Roma'),
      ]);
      expect(tage.map((t) => t.tag.day), [4, 6]);
    });

    test('der Ort eines Tages ist sein haeufigster', () {
      final tage = reisetage([
        a('1', DateTime(2024, 6, 4, 9), 'Firenze'),
        a('2', DateTime(2024, 6, 4, 15), 'Roma'),
        a('3', DateTime(2024, 6, 4, 16), 'Roma'),
      ]);
      expect(tage.single.ort, 'Roma');
    });

    test('ein Tag ohne verortete Aufnahme bleibt ohne Ort', () {
      // Richtiger als der Ort vom Vortag.
      final tage = reisetage([
        a('1', DateTime(2024, 6, 4, 9), 'Roma'),
        a('2', DateTime(2024, 6, 5, 9), null),
      ]);
      expect(tage.last.ort, isNull);
    });

    test('die Aufnahmen eines Tages stehen chronologisch', () {
      final tage = reisetage([
        a('mittag', DateTime(2024, 6, 4, 12), null),
        a('morgen', DateTime(2024, 6, 4, 8), null),
      ]);
      expect(tage.single.aufnahmeIds, ['morgen', 'mittag']);
    });
  });
}
