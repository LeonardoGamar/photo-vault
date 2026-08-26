import 'package:flutter_test/flutter_test.dart';
import 'package:photo_vault/services/gpx.dart';

/// GPX einlesen und Aufnahmen nachträglich verorten.
///
/// Der Gewinn liegt nicht bei den Wanderungen, sondern hier: An der
/// echten Bibliothek tragen nur 1092 von 7988 Aufnahmen eine Koordinate.
/// Ob ein Foto dabei an der richtigen Stelle landet, ist eine Rechnung
/// und keine Ansichtssache.
void main() {
  String gpx(String inneres) =>
      '<?xml version="1.0"?><gpx version="1.1"><trk><trkseg>$inneres'
      '</trkseg></trk></gpx>';

  String punkt(double b, double l, String? zeit) =>
      '<trkpt lat="$b" lon="$l">${zeit == null ? '' : '<time>$zeit</time>'}'
      '</trkpt>';

  group('Einlesen', () {
    test('liest Punkte mit Zeitstempel', () {
      final spur = liesGpx(gpx(
        '${punkt(52.5, 13.4, '2024-06-03T09:00:00Z')}'
        '${punkt(52.6, 13.5, '2024-06-03T10:00:00Z')}',
      ));
      expect(spur, hasLength(2));
      expect(spur.first.breite, closeTo(52.5, 0.001));
      expect(spur.first.zeit, DateTime.utc(2024, 6, 3, 9));
    });

    test('sortiert nach Zeit', () {
      final spur = liesGpx(gpx(
        '${punkt(52.6, 13.5, '2024-06-03T10:00:00Z')}'
        '${punkt(52.5, 13.4, '2024-06-03T09:00:00Z')}',
      ));
      expect(spur.first.zeit.hour, 9);
    });

    test('rechnet Ortszeit in UTC um', () {
      // Eine Spur mit Zonenangabe – manche Geraete schreiben sie.
      final spur = liesGpx(gpx(punkt(52.5, 13.4, '2024-06-03T11:00:00+02:00')));
      expect(spur.single.zeit, DateTime.utc(2024, 6, 3, 9));
    });

    test('nimmt auch Routen- und Wegpunkte', () {
      // Welches Programm welche Art schreibt, ist nicht vorherzusehen.
      final spur = liesGpx('<?xml version="1.0"?><gpx>'
          '<wpt lat="1" lon="2"><time>2024-06-03T09:00:00Z</time></wpt>'
          '<rte><rtept lat="3" lon="4">'
          '<time>2024-06-03T10:00:00Z</time></rtept></rte>'
          '</gpx>');
      expect(spur, hasLength(2));
    });

    test('Punkte ohne Zeit fallen weg, der Rest bleibt', () {
      final spur = liesGpx(gpx(
        '${punkt(52.5, 13.4, '2024-06-03T09:00:00Z')}${punkt(52.6, 13.5, null)}',
      ));
      expect(spur, hasLength(1));
    });

    test('eine Spur ganz ohne Zeitstempel wird abgelehnt', () {
      // Ohne Zeit laesst sich nichts zuordnen; die Spur waere nur eine
      // Linie. Das gehoert gesagt, nicht stillschweigend uebergangen.
      expect(
          () => liesGpx(gpx(punkt(52.5, 13.4, null))),
          throwsA(isA<GpxFehler>()
              .having((e) => e.grund, 'grund', GpxAbbruch.ohneZeit)));
    });

    test('eine leere Datei wird abgelehnt', () {
      expect(
          () => liesGpx('<?xml version="1.0"?><gpx></gpx>'),
          throwsA(isA<GpxFehler>()
              .having((e) => e.grund, 'grund', GpxAbbruch.leer)));
    });

    test('etwas anderes als GPX wird abgelehnt', () {
      expect(
          () => liesGpx('<?xml version="1.0"?><html><body/></html>'),
          throwsA(isA<GpxFehler>()
              .having((e) => e.grund, 'grund', GpxAbbruch.keinGpx)));
      expect(
          () => liesGpx('Das ist ein Brief.'),
          throwsA(isA<GpxFehler>()
              .having((e) => e.grund, 'grund', GpxAbbruch.keinGpx)));
    });
  });

  group('Ort zur Zeit', () {
    // Zehn Minuten Abstand – so zeichnen Geraete wirklich auf. Eine
    // ganze Stunde laege ueber [gpxHoechsteLuecke], und dazwischen wird
    // absichtlich nicht gerechnet.
    final spur = liesGpx(gpx(
      '${punkt(52.0, 13.0, '2024-06-03T09:00:00Z')}'
      '${punkt(52.2, 13.0, '2024-06-03T09:10:00Z')}',
    ));

    test('trifft einen Punkt genau', () {
      final ort = ortZurZeit(spur, DateTime.utc(2024, 6, 3, 9))!;
      expect(ort.breite, closeTo(52.0, 0.0001));
    });

    test('rechnet dazwischen linear', () {
      // Eine Annahme, aber die einzige, die eine Aufzeichnung zulaesst.
      final ort = ortZurZeit(spur, DateTime.utc(2024, 6, 3, 9, 5))!;
      expect(ort.breite, closeTo(52.1, 0.0001));
    });

    test('ueber eine grosse Luecke wird nicht gerechnet', () {
      // Bei einer laengeren Luecke stand das Geraet still oder hatte
      // keinen Empfang – dazwischen zu rechnen hiesse, eine Bewegung zu
      // erfinden, die niemand aufgezeichnet hat.
      final weit = liesGpx(gpx(
        '${punkt(52.0, 13.0, '2024-06-03T09:00:00Z')}'
        '${punkt(48.0, 11.0, '2024-06-03T15:00:00Z')}',
      ));
      expect(ortZurZeit(weit, DateTime.utc(2024, 6, 3, 12)), isNull);
    });

    test('kurz vor dem Start und kurz nach dem Ende zaehlt noch', () {
      expect(ortZurZeit(spur, DateTime.utc(2024, 6, 3, 8, 57)), isNotNull);
      expect(ortZurZeit(spur, DateTime.utc(2024, 6, 3, 9, 13)), isNotNull);
    });

    test('weit davor und weit danach nicht mehr', () {
      expect(ortZurZeit(spur, DateTime.utc(2024, 6, 3, 8)), isNull);
      expect(ortZurZeit(spur, DateTime.utc(2024, 6, 3, 12)), isNull);
    });

    test('eine leere Spur liefert nichts statt zu werfen', () {
      expect(ortZurZeit(const [], DateTime.utc(2024)), isNull);
    });
  });

  group('Der Zeitversatz', () {
    // Eine Spur von 09:00 bis 11:00 UTC, alle zehn Minuten ein Punkt.
    final spur = liesGpx(gpx([
      for (var m = 0; m <= 120; m += 10)
        punkt(52.0 + m / 1000, 13.0,
            DateTime.utc(2024, 6, 3, 9).add(Duration(minutes: m))
                .toIso8601String()),
    ].join()));

    test('findet die Zeitzone, die die meisten Fotos trifft', () {
      // EXIF schreibt ohne Zeitzone, GPX schreibt UTC. Die Kamera stand
      // hier auf MESZ, also zwei Stunden vor.
      final zeiten = [
        for (var m = 0; m <= 120; m += 15)
          DateTime.utc(2024, 6, 3, 11).add(Duration(minutes: m)),
      ];
      expect(besterVersatz(spur, zeiten), const Duration(hours: -2));
    });

    test('findet auch eine falsch gehende Kamerauhr', () {
      // Er ist nicht immer die Zeitzone: Eine Uhr, die seit zwei Jahren
      // falsch geht, verschiebt alles um denselben Betrag.
      final zeiten = [
        for (var m = 0; m <= 120; m += 15)
          DateTime.utc(2024, 6, 3, 9, 30).add(Duration(minutes: m)),
      ];
      expect(besterVersatz(spur, zeiten), const Duration(minutes: -30));
    });

    test('ohne jeden Treffer bleibt es beim Nullversatz', () {
      // Ein Vorschlag von "irgendwas" waere schlechter als keiner.
      expect(
          besterVersatz(spur, [DateTime.utc(2020, 1, 1)]), Duration.zero);
    });

    test('bei Gleichstand gewinnt der kleinere Versatz', () {
      // Wenn zwei Erklaerungen gleich viele Fotos treffen, ist die
      // harmlosere die wahrscheinlichere.
      expect(besterVersatz(spur, [DateTime.utc(2024, 6, 3, 10)]),
          Duration.zero);
    });
  });

  group('Verorten', () {
    // Zehn Minuten Abstand – so zeichnen Geraete wirklich auf. Eine
    // ganze Stunde laege ueber [gpxHoechsteLuecke], und dazwischen wird
    // absichtlich nicht gerechnet.
    final spur = liesGpx(gpx(
      '${punkt(52.0, 13.0, '2024-06-03T09:00:00Z')}'
      '${punkt(52.2, 13.0, '2024-06-03T09:10:00Z')}',
    ));

    test('ordnet zu, was sich zuordnen laesst', () {
      final ergebnis = verorteAusSpur(spur, [
        (id: 'passt', zeit: DateTime.utc(2024, 6, 3, 9, 5)),
        (id: 'passt nicht', zeit: DateTime.utc(2024, 6, 3, 20)),
      ]);
      expect(ergebnis, hasLength(1));
      expect(ergebnis.single.assetId, 'passt');
      expect(ergebnis.single.breite, closeTo(52.1, 0.0001));
    });

    test('der Versatz wird angewandt', () {
      final ergebnis = verorteAusSpur(
        spur,
        [(id: 'a', zeit: DateTime.utc(2024, 6, 3, 11, 5))],
        versatz: const Duration(hours: -2),
      );
      expect(ergebnis, hasLength(1));
    });
  });
}
