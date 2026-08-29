import 'package:flutter_test/flutter_test.dart';
import 'package:photo_vault/services/stammbaum.dart';

/// Das Geflecht: wer mit wem lebt, und wer von wem abstammt.
///
/// Der Unterschied zum [ausschnittUm] daneben ist genau **eine** Frage,
/// und es ist die, wegen der es das Geflecht gibt: Zu welcher Schwester
/// gehört dieser Schwager? Eine Reihe nach Rolle kann das nicht sagen.
void main() {
  /// Die Kette aus der Anfrage, dazu ein zweites Geschwister ohne
  /// Anhang – damit sich zeigt, dass die Zuordnung nicht rät.
  ///
  ///   opa == oma      schwagersVater == schwagersMutter
  ///        |                    |            |
  ///   vater == mutter       schwager   schwagersBruder
  ///        |                   ||
  ///   ich, anna, bruno      anna
  ///                           |
  ///                         neffe
  Verwandtschaftsnetz sippe() => Verwandtschaftsnetz([
        kante('vater', 'opa', Verwandtschaft.elternteil),
        kante('vater', 'oma', Verwandtschaft.elternteil),
        partnerKanteFuer('opa', 'oma'),
        partnerKanteFuer('vater', 'mutter'),
        kante('ich', 'vater', Verwandtschaft.elternteil),
        kante('ich', 'mutter', Verwandtschaft.elternteil),
        kante('anna', 'vater', Verwandtschaft.elternteil),
        kante('anna', 'mutter', Verwandtschaft.elternteil),
        kante('bruno', 'vater', Verwandtschaft.elternteil),
        kante('bruno', 'mutter', Verwandtschaft.elternteil),
        partnerKanteFuer('anna', 'schwager'),
        kante('neffe', 'anna', Verwandtschaft.elternteil),
        kante('neffe', 'schwager', Verwandtschaft.elternteil),
        kante('schwager', 'schwagersVater', Verwandtschaft.elternteil),
        kante('schwager', 'schwagersMutter', Verwandtschaft.elternteil),
        partnerKanteFuer('schwagersVater', 'schwagersMutter'),
        kante('schwagersBruder', 'schwagersVater', Verwandtschaft.elternteil),
        kante('schwagersBruder', 'schwagersMutter', Verwandtschaft.elternteil),
      ]);

  /// Alle Personen, in einer festen Reihenfolge – wie im Baum.
  const alle = [
    'opa', 'oma', 'schwagersVater', 'schwagersMutter', 'vater', 'mutter',
    'ich', 'anna', 'bruno', 'schwager', 'schwagersBruder', 'neffe',
  ];

  Stammbaumgeflecht geflecht([String fokus = 'ich']) =>
      geflechtUm(sippe(), fokus, alle);

  group('Haushalte', () {
    test('der Schwager wohnt bei seiner Frau, nicht irgendwo daneben', () {
      // DIE Frage. Vorher stand er in einer eigenen Reihe „Schwäger", und
      // welche der Schwestern ihn geheiratet hatte, war nicht zu sehen.
      final haus = geflecht().haushaltVon('schwager');
      expect(haus, isNotNull);
      expect(haus!.anker, 'anna');
      expect(haus.personen, containsAll(['anna', 'schwager']));
    });

    test('das Geschwister ohne Partner wohnt für sich', () {
      final haus = geflecht().haushaltVon('bruno');
      expect(haus!.personen, ['bruno']);
    });

    test('Vater und Mutter sind ein Haushalt, nicht zwei', () {
      final g = geflecht();
      expect(g.haushaltVon('vater'), same(g.haushaltVon('mutter')));
      expect(g.imBand(-1).where((h) => h.personen.contains('vater')), hasLength(1));
    });

    test('niemand wohnt zweimal', () {
      // Eine Person kann auf mehreren Wegen erreichbar sein. Zwei
      // Schilder für einen Menschen sind kein Baum, sondern ein Fehler.
      final personen = <String>[];
      for (final h in geflecht().haushalte) {
        personen.addAll(h.personen);
      }
      expect(personen.length, personen.toSet().length);
    });
  });

  group('die Elternkante hängt an der Person', () {
    test('die Schwester stammt von meinen Eltern, ihr Mann von seinen', () {
      // Der ganze Sinn: Beide wohnen im selben Haushalt und haben
      // trotzdem verschiedene Eltern. Am Haushalt festgemacht wäre eine
      // der beiden Linien gelogen.
      final g = geflecht();
      expect(g.elternhausVon['anna'], g.haushaltVon('vater')!.id);
      expect(g.elternhausVon['schwager'], g.haushaltVon('schwagersVater')!.id);
      expect(g.elternhausVon['anna'], isNot(g.elternhausVon['schwager']));
    });

    test('der Neffe hängt am Haushalt seiner Eltern', () {
      final g = geflecht();
      expect(g.elternhausVon['neffe'], g.haushaltVon('anna')!.id);
    });

    test('wessen Eltern nicht im Bild stehen, bekommt keine Kante', () {
      // Ein Ast ins Leere wäre eine Behauptung über etwas, das man nicht
      // sieht. Dafür gibt es das Mehrzeichen.
      final g = geflecht();
      expect(g.elternhausVon.containsKey('opa'), isFalse);
      expect(g.weitereOben['opa'], isFalse, reason: 'Opa hat keine Eltern im Netz');
    });
  });

  group('Bänder', () {
    test('jede Generation steht auf ihrer Höhe', () {
      final g = geflecht();
      int bandVon(String person) => g.band[g.haushaltVon(person)!.id]!;
      expect(bandVon('ich'), 0);
      expect(bandVon('anna'), 0);
      expect(bandVon('schwager'), 0, reason: 'er wohnt bei Anna');
      expect(bandVon('schwagersBruder'), 0);
      expect(bandVon('vater'), -1);
      expect(bandVon('schwagersVater'), -1, reason: 'Eltern des Schwagers');
      expect(bandVon('opa'), -2);
      expect(bandVon('neffe'), 1);
    });

    test('die Eltern des Schwagers stehen über ihm, nicht über mir', () {
      // Sie sind eine Generation über der Mitte – aber ihr Ast führt zum
      // Schwager, nicht zu mir.
      final g = geflecht();
      expect(g.band[g.haushaltVon('schwagersVater')!.id], -1);
      expect(g.elternhausVon['schwager'], g.haushaltVon('schwagersVater')!.id);
      expect(g.elternhausVon['ich'], g.haushaltVon('vater')!.id);
    });
  });

  group('die Grenze', () {
    test('ein grosses Band wird gedeckelt und sagt, wie viel fehlt', () {
      // Zwanzig Geschwister passen auf kein Blatt. Stillschweigend
      // wegzulassen wäre das Schlimmste von beidem.
      final kanten = <Kante>[kante('ich', 'vater', Verwandtschaft.elternteil)];
      final alleIds = <String>['vater', 'ich'];
      for (var i = 0; i < 20; i++) {
        kanten.add(kante('g$i', 'vater', Verwandtschaft.elternteil));
        alleIds.add('g$i');
      }
      final g = geflechtUm(Verwandtschaftsnetz(kanten), 'ich', alleIds);

      expect(g.imBand(0).length, maxHaushalteJeBand);
      expect(g.verschwiegen, greaterThan(0));
      // 1 Mitte + 20 Geschwister = 21 Haushalte im Band 0, davon passen
      // maxHaushalteJeBand hinein.
      expect(g.verschwiegen, 21 - maxHaushalteJeBand);
    });

    test('ohne Gedränge wird nichts verschwiegen', () {
      expect(geflecht().verschwiegen, 0);
    });
  });

  test('zweimal gefragt, zweimal dasselbe', () {
    // Die Reihenfolge ist übergeben, also darf nichts umherspringen.
    final a = geflecht();
    final b = geflecht();
    expect(a.haushalte, b.haushalte);
    expect(a.band, b.band);
    expect(a.elternhausVon, b.elternhausVon);
  });
}
