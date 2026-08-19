import 'package:flutter_test/flutter_test.dart';
import 'package:photo_vault/services/map_clustering.dart';

/// Ein Ort, wie ihn die Kartenansicht übergibt.
typedef Ort = ({double breite, double laenge});

Ort ort(double breite, double laenge) => (breite: breite, laenge: laenge);

/// Wie viele Grad ein Bildschirmpunkt bei dieser Zoomstufe abdeckt –
/// unabhängig von [rasterFuerZoom] aus der Web-Mercator-Formel
/// hergeleitet, sonst prüfte der Test sich selbst.
double gradJePunkt(double zoom) => 360.0 / (256.0 * (1 << zoom.toInt()));

void main() {
  group('rasterFuerZoom', () {
    test('halbiert sich mit jeder Zoomstufe', () {
      for (var z = 1.0; z <= 18; z++) {
        expect(rasterFuerZoom(z), closeTo(rasterFuerZoom(z - 1) / 2, 1e-12));
      }
    });

    test('eine Rasterzelle ist genau so breit wie ein Marker', () {
      // Die eigentliche Behauptung der Funktion.
      for (final z in [0.0, 6.0, 12.0, 18.0]) {
        expect(rasterFuerZoom(z) / gradJePunkt(z), closeTo(markerGroesse, 1e-9),
            reason: 'bei Zoom $z');
      }
    });
  });

  group('gruppiereFuerKarte', () {
    test('fasst dicht beieinanderliegende Fotos zusammen', () {
      final raster = rasterFuerZoom(6);
      final punkte = [
        ort(52.0, 10.0),
        ort(52.0 + raster / 10, 10.0 + raster / 10),
        ort(52.0 - raster / 10, 10.0),
      ];
      final gruppen = gruppiereFuerKarte(punkte, 6, (o) => o);
      expect(gruppen, hasLength(1));
      expect(gruppen.values.single, hasLength(3));
    });

    test('trennt sie beim Hineinzoomen wieder', () {
      // Genau der Zweck der zoomabhängigen Rastergröße: Was in der
      // Übersicht ein Punkt ist, muss sich auseinanderziehen lassen.
      final punkte = [ort(52.0, 10.0), ort(52.0, 10.02)];
      expect(gruppiereFuerKarte(punkte, 6, (o) => o), hasLength(1));
      expect(gruppiereFuerKarte(punkte, 14, (o) => o), hasLength(2));
    });

    test('behält die Eingabereihenfolge innerhalb einer Gruppe', () {
      // Der Marker zeigt das Vorschaubild des ersten Eintrags. Ginge die
      // Reihenfolge verloren, zeigte er ein beliebiges Foto der Gruppe
      // statt des jüngsten.
      final punkte = [ort(52.0, 10.0), ort(52.0001, 10.0001), ort(52.0002, 10.0)];
      final gruppe = gruppiereFuerKarte(punkte, 6, (o) => o).values.single;
      expect(gruppe, equals(punkte));
    });

    test('verliert kein Foto', () {
      final punkte = [
        for (var i = 0; i < 500; i++) ort(47 + i % 90 * 0.1, 6 + i % 70 * 0.13),
      ];
      for (final z in [4.0, 8.0, 12.0, 16.0]) {
        final gruppen = gruppiereFuerKarte(punkte, z, (o) => o);
        expect(gruppen.values.fold(0, (n, g) => n + g.length), punkte.length,
            reason: 'bei Zoom $z');
      }
    });

    test('deckelt die Markerdichte auch bei dichter Streuung', () {
      // Die eigentliche Zusicherung (siehe Doku): nicht "keine
      // Überlappung", sondern eine gedeckelte Dichte. Vor der Änderung
      // standen alle 2000 Marker übereinander.
      const zoom = 6.0;
      final raster = rasterFuerZoom(zoom);
      final punkte = [
        for (var i = 0; i < 2000; i++)
          ort(52 + (i % 40) * raster * 2 / 40, 10 + (i ~/ 40) * raster * 2 / 50),
      ];
      final gruppen = gruppiereFuerKarte(punkte, zoom, (o) => o);
      // Zwei mal zwei Zellen, durch das Runden je eine Randzelle mehr.
      expect(gruppen.length, lessThanOrEqualTo(9));
    });
  });
}
