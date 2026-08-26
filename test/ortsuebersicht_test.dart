import 'package:flutter_test/flutter_test.dart';
import 'package:photo_vault/services/ortsuebersicht.dart';
import 'package:photo_vault/services/reisefortschritt.dart';

/// Die Rechnung hinter der Ortsansicht.
///
/// Sie beantwortet dreimal dieselbe Frage – „was war hier?" – für Land,
/// Region und Ort. Geprüft wird an einer Lage, wie sie die echte
/// Bibliothek hat: viel aus Niedersachsen, etwas aus Polen, ein
/// Geisterland aus einer falsch gelesenen Kamera.
Besuchsangabe angabe(String? land, String? region, String? ort, int anzahl) =>
    (land: land, region: region, ort: ort, anzahl: anzahl);

Markeneintrag marke(String art, String schluessel, Markenart wert) =>
    (art: art, schluessel: schluessel, wert: wert);

void main() {
  final angaben = [
    angabe('Germany', 'Lower Saxony', 'Hannover', 400),
    angabe('Germany', 'Lower Saxony', 'Oldenburg', 237),
    angabe('Germany', 'Hamburg', 'Hamburg', 15),
    angabe('Poland', 'Lesser Poland', 'Kraków', 328),
  ];
  const nachIso = {'Germany': 'DE', 'Poland': 'PL'};
  const regionscodes = {
    'DE|Lower Saxony': 'DE.06',
    'DE|Hamburg': 'DE.04',
    'DE|Bavaria': 'DE.02',
    'PL|Lesser Poland': 'PL.77',
  };
  const regionenDe = [
    (schluessel: 'DE.06', name: 'Lower Saxony'),
    (schluessel: 'DE.04', name: 'Hamburg'),
    (schluessel: 'DE.02', name: 'Bavaria'),
  ];

  group('ein Land', () {
    Ortsuebersicht land({Iterable<Markeneintrag> marken = const []}) =>
        ortsuebersicht(
          ebene: Ortsebene.land,
          schluessel: 'DE',
          name: 'Germany',
          angaben: angaben,
          nachIso: nachIso,
          regionscodes: regionscodes,
          bekannteUnterorte: regionenDe,
          marken: marken,
        );

    test('zählt nur seine eigenen Aufnahmen', () {
      // 400 + 237 + 15, und keine einzige aus Polen.
      expect(land().aufnahmen, 652);
    });

    test('führt auch die Regionen, in denen niemand war', () {
      // Sonst wäre die Liste ein Spiegel der eigenen Fotos statt einer
      // Landkarte – und man sähe nie, was noch fehlt.
      final l = land();
      expect(l.unterorteGesamt, 3);
      expect(l.unterorteBesucht, 2);
      expect(l.unterorte.map((u) => u.name),
          ['Lower Saxony', 'Hamburg', 'Bavaria']);
    });

    test('besuchte zuerst, darin die mit den meisten Aufnahmen', () {
      final l = land();
      expect(l.unterorte[0].aufnahmen, 637); // Niedersachsen
      expect(l.unterorte[1].aufnahmen, 15); // Hamburg
      expect(l.unterorte[2].aufnahmen, 0); // Bayern
      expect(l.unterorte[2].besucht, isFalse);
    });

    test('ein Haken von Hand macht eine Region besucht', () {
      final l = land(marken: [marke('region', 'DE.02', Markenart.besucht)]);
      final bayern =
          l.unterorte.firstWhere((u) => u.schluessel == 'DE.02');
      expect(bayern.aufnahmen, 0);
      expect(bayern.besucht, isTrue);
      expect(l.unterorteBesucht, 3);
      // **Und rückt damit vor alles Unbesuchte.** Der Fall muss so
      // gewählt sein, dass er es zeigen kann: Der Haken liegt auf dem
      // Saarland, das alphabetisch HINTER Bayern steht. Ohne die Regel
      // „besuchte zuerst" käme Bayern zuerst — beide haben null
      // Aufnahmen, und dann entscheidet der Name. Mit einem Haken auf
      // Bayern liefen beide Regeln zufällig auf dieselbe Reihenfolge
      // hinaus, und der Test hätte nichts geprüft.
      final mitSaarland = ortsuebersicht(
        ebene: Ortsebene.land,
        schluessel: 'DE',
        name: 'Germany',
        angaben: angaben,
        nachIso: nachIso,
        regionscodes: regionscodes,
        bekannteUnterorte: const [
          ...regionenDe,
          (schluessel: 'DE.09', name: 'Saarland'),
        ],
        marken: [marke('region', 'DE.09', Markenart.besucht)],
      );
      expect(mitSaarland.unterorte.map((u) => u.name),
          ['Lower Saxony', 'Hamburg', 'Saarland', 'Bavaria']);
    });

    test('„geplant" zählt nicht als besucht', () {
      // Dieselbe Regel wie überall in der App: Ein Vorhaben ist kein
      // Besuch.
      final l = land(marken: [marke('region', 'DE.02', Markenart.geplant)]);
      expect(l.unterorteBesucht, 2);
      expect(l.unterorte.last.schluessel, 'DE.02');
      expect(l.unterorte.last.marke, Markenart.geplant);
    });

    test('die eigene Marke des Landes wird gefunden', () {
      expect(land().marke, isNull);
      expect(land(marken: [marke('land', 'DE', Markenart.besucht)]).marke,
          Markenart.besucht);
      // Eine Marke auf einer Region ist nicht die des Landes.
      expect(land(marken: [marke('region', 'DE.06', Markenart.besucht)]).marke,
          isNull);
    });

    test('ein Land ohne verzeichnete Region bleibt trotzdem auskunftsfähig',
        () {
      // 24 der 252 Länder haben keine – Monaco und der Vatikan etwa.
      final l = ortsuebersicht(
        ebene: Ortsebene.land,
        schluessel: 'MC',
        name: 'Monaco',
        angaben: [angabe('Monaco', null, 'Monte-Carlo', 4)],
        nachIso: const {'Monaco': 'MC'},
        regionscodes: const {},
      );
      expect(l.aufnahmen, 4);
      expect(l.unterorte, isEmpty);
      expect(l.besucht, isTrue);
    });

    test('ein Land ohne alles ist nicht besucht, aber auch kein Fehler', () {
      final l = ortsuebersicht(
        ebene: Ortsebene.land,
        schluessel: 'FR',
        name: 'France',
        angaben: angaben,
        nachIso: nachIso,
        regionscodes: regionscodes,
        bekannteUnterorte: const [
          (schluessel: 'FR.11', name: 'Île-de-France')
        ],
      );
      expect(l.aufnahmen, 0);
      expect(l.besucht, isFalse);
      expect(l.unterorteGesamt, 1);
    });
  });

  group('eine Region', () {
    Ortsuebersicht region() => ortsuebersicht(
          ebene: Ortsebene.region,
          schluessel: 'DE.06',
          name: 'Lower Saxony',
          angaben: angaben,
          nachIso: nachIso,
          regionscodes: regionscodes,
          bekannteUnterorte: const [
            (schluessel: 'Germany|Lower Saxony|Celle', name: 'Celle'),
          ],
        );

    test('zählt nur ihre eigenen Aufnahmen', () {
      expect(region().aufnahmen, 637);
    });

    test('führt ihre Orte, auch die aus den Fotos', () {
      // Hannover und Oldenburg stehen nicht in der übergebenen Liste des
      // Datensatzes – sie kommen aus den Fotos und müssen trotzdem
      // dastehen. Ein Ort, den `cities1000` nicht führt, ist kein Grund,
      // seine Bilder zu verstecken.
      final r = region();
      expect(r.unterorte.map((u) => u.name), ['Hannover', 'Oldenburg', 'Celle']);
      expect(r.unterorteBesucht, 2);
    });

    test('der Schlüssel eines Ortes passt zu dem der Ortsmarken', () {
      // „Land|Region|Ort" mit Namen – genau so, wie die Weltkarte eine
      // Marke schreibt. Zwei Schreibweisen wären zwei Orte.
      expect(region().unterorte.first.schluessel,
          'Germany|Lower Saxony|Hannover');
    });
  });

  group('ein Ort', () {
    test('zählt seine Aufnahmen und hat nichts mehr darunter', () {
      final o = ortsuebersicht(
        ebene: Ortsebene.ort,
        schluessel: 'Germany|Lower Saxony|Hannover',
        name: 'Hannover',
        angaben: angaben,
        nachIso: nachIso,
        regionscodes: regionscodes,
      );
      expect(o.aufnahmen, 400);
      expect(o.unterorte, isEmpty);
      expect(o.besucht, isTrue);
    });

    test('zwei gleichnamige Orte in verschiedenen Ländern bleiben getrennt',
        () {
      // „Springfield" gibt es über zwanzigmal. Ohne Land und Region im
      // Schlüssel wären es alle zusammen ein Ort.
      final zwei = [
        angabe('Germany', 'Hesse', 'Neustadt', 3),
        angabe('Poland', 'Lesser Poland', 'Neustadt', 7),
      ];
      final deutsch = ortsuebersicht(
        ebene: Ortsebene.ort,
        schluessel: 'Germany|Hesse|Neustadt',
        name: 'Neustadt',
        angaben: zwei,
        nachIso: nachIso,
        regionscodes: regionscodes,
      );
      expect(deutsch.aufnahmen, 3);
    });
  });

  group('was aus den Fotos nicht auflösbar ist', () {
    test('ein unbekanntes Land fällt weg statt zu werfen', () {
      // Kommt vor: Eine Kamera schreibt einen Ländernamen, den der
      // Datensatz nicht kennt.
      final l = ortsuebersicht(
        ebene: Ortsebene.land,
        schluessel: 'DE',
        name: 'Germany',
        angaben: [...angaben, angabe('Absurdistan', 'Irgendwo', 'X', 99)],
        nachIso: nachIso,
        regionscodes: regionscodes,
        bekannteUnterorte: regionenDe,
      );
      expect(l.aufnahmen, 652);
    });

    test('eine Region ohne auflösbaren Code erscheint nicht als Zeile', () {
      // Sie hätte keinen Schlüssel, unter dem eine Marke stehen könnte –
      // eine Zeile, die man ansieht und nicht anklicken kann.
      final l = ortsuebersicht(
        ebene: Ortsebene.land,
        schluessel: 'DE',
        name: 'Germany',
        angaben: [angabe('Germany', 'Erfundenland', 'Ort', 5)],
        nachIso: nachIso,
        regionscodes: regionscodes,
      );
      // Die Aufnahme zählt für das Land – nur die Region fehlt.
      expect(l.aufnahmen, 5);
      expect(l.unterorte, isEmpty);
    });

    test('eine Aufnahme ohne Ortsangabe zählt trotzdem für ihr Land', () {
      final l = ortsuebersicht(
        ebene: Ortsebene.land,
        schluessel: 'DE',
        name: 'Germany',
        angaben: [angabe('Germany', null, null, 12)],
        nachIso: nachIso,
        regionscodes: regionscodes,
      );
      expect(l.aufnahmen, 12);
      expect(l.unterorte, isEmpty);
    });
  });
}
