import 'package:flutter_test/flutter_test.dart';
import 'package:photo_vault/services/sanduhr.dart';
import 'package:photo_vault/services/stammbaum.dart';

/// Die Anordnung der Sanduhr.
///
/// Genau hier lag die Beschränkung, die den Baum bisher auf eine Reihe
/// festnagelte: Mehrere Generationen in flachen Reihen erzeugen
/// mehrdeutige Linien. Geprüft wird deshalb nicht, ob es hübsch aussieht,
/// sondern ob jeder Vorfahr seinen eigenen Platz über seinem Kind hat und
/// sich keine zwei Kästen überlappen.
void main() {
  ///        opaV  omaV   opaM  omaM
  ///            vater  mutter
  ///                ich
  ///          kind1      kind2
  ///                   enkel
  Verwandtschaftsnetz sippe() => Verwandtschaftsnetz([
        kante('ich', 'vater', Verwandtschaft.elternteil),
        kante('ich', 'mutter', Verwandtschaft.elternteil),
        kante('vater', 'opaV', Verwandtschaft.elternteil),
        kante('vater', 'omaV', Verwandtschaft.elternteil),
        kante('mutter', 'opaM', Verwandtschaft.elternteil),
        kante('mutter', 'omaM', Verwandtschaft.elternteil),
        kante('kind1', 'ich', Verwandtschaft.elternteil),
        kante('kind2', 'ich', Verwandtschaft.elternteil),
        kante('enkel', 'kind2', Verwandtschaft.elternteil),
      ]);

  final reihenfolge = [
    'opaV', 'omaV', 'opaM', 'omaM', 'vater', 'mutter', 'ich',
    'kind1', 'kind2', 'enkel', 'gattin',
  ];
  int ordnung(String id) => reihenfolge.indexOf(id);

  Sanduhr bau([Verwandtschaftsnetz? netz]) =>
      ordneSanduhr(netz ?? sippe(), 'ich', ordnung);

  Map<String, Sanduhrknoten> nachId(Sanduhr s) =>
      {for (final k in s.knoten) k.personId: k};

  group('Reihen', () {
    test('die gewählte Person sitzt in der Taille', () {
      expect(nachId(bau())['ich']!.reihe, 0);
    });

    test('Vorfahren nach oben, Nachkommen nach unten', () {
      final k = nachId(bau());
      expect(k['vater']!.reihe, -1);
      expect(k['opaV']!.reihe, -2);
      expect(k['kind1']!.reihe, 1);
      expect(k['enkel']!.reihe, 2);
    });

    test('hält die Tiefengrenzen ein', () {
      final tief = Verwandtschaftsnetz([
        for (var i = 1; i < 8; i++)
          kante('p${i - 1}', 'p$i', Verwandtschaft.elternteil),
        for (var i = 1; i < 8; i++)
          kante('k$i', i == 1 ? 'p0' : 'k${i - 1}', Verwandtschaft.elternteil),
      ]);
      final s = ordneSanduhr(tief, 'p0', (id) => 0, oben: 2, unten: 2);
      expect(s.obersteReihe, -2);
      expect(s.untersteReihe, 2);
    });
  });

  group('Spalten', () {
    test('kein Kasten überlappt einen anderen', () {
      // Die eigentliche Zusicherung: In einer Reihe muss jeder Platz für
      // sich stehen, sonst wäre nicht erkennbar, wessen Linie wohin geht.
      final s = bau();
      final proReihe = <int, List<double>>{};
      for (final k in s.knoten) {
        proReihe.putIfAbsent(k.reihe, () => []).add(k.spalte);
      }
      for (final e in proReihe.entries) {
        final spalten = e.value..sort();
        for (var i = 1; i < spalten.length; i++) {
          expect(spalten[i] - spalten[i - 1], greaterThanOrEqualTo(1.0),
              reason: 'Reihe ${e.key}: ${spalten[i - 1]} und ${spalten[i]}');
        }
      }
    });

    test('jeder Vorfahr steht über seinem Kind, nicht irgendwo in der Reihe', () {
      // Der Kern der Sache. Die Großeltern väterlicherseits müssen den
      // Vater einrahmen, nicht die Mutter.
      final k = nachId(bau());
      final vater = k['vater']!.spalte;
      expect(k['opaV']!.spalte, lessThan(vater));
      expect(k['omaV']!.spalte, greaterThan(vater));
      final mutter = k['mutter']!.spalte;
      expect(k['opaM']!.spalte, lessThan(mutter));
      expect(k['omaM']!.spalte, greaterThan(mutter));
      // Und die beiden Paare dürfen sich nicht kreuzen.
      expect(k['omaV']!.spalte, lessThan(k['opaM']!.spalte));
    });

    test('ein Elternteil sitzt mittig über seinen Kindern', () {
      final k = nachId(bau());
      final mitte = (k['kind1']!.spalte + k['kind2']!.spalte) / 2;
      expect(k['ich']!.spalte, closeTo(mitte, 1e-9));
    });

    test('ein Ast ohne Geschwister bleibt senkrecht', () {
      final k = nachId(bau());
      expect(k['enkel']!.spalte, closeTo(k['kind2']!.spalte, 1e-9));
    });
  });

  group('Kanten', () {
    test('jede Kante verbindet zwei vorhandene Knoten', () {
      final s = bau();
      final ids = {for (final k in s.knoten) k.personId};
      for (final kante in s.kanten) {
        expect(ids, contains(kante.vonId));
        expect(ids, contains(kante.zuId));
      }
    });

    test('merkt sich, wie eine Elternschaft zustande kam', () {
      final netz = Verwandtschaftsnetz([
        kante('ich', 'adoptivvater', Verwandtschaft.adoptivelternteil),
      ]);
      final s = ordneSanduhr(netz, 'ich', ordnung);
      expect(s.kanten.single.art, Verwandtschaft.adoptivelternteil);
    });

    test('Partner stehen daneben, nicht in einer Generation', () {
      final netz = Verwandtschaftsnetz([
        partnerKanteFuer('ich', 'gattin'),
        kante('kind1', 'ich', Verwandtschaft.elternteil),
      ]);
      final s = ordneSanduhr(netz, 'ich', ordnung);
      final gattin = nachId(s)['gattin']!;
      expect(gattin.reihe, 0);
      expect(gattin.istPartner, isTrue);
      expect(s.kanten.any((k) => k.art == Verwandtschaft.partner), isTrue);
    });
  });

  group('Grenzfälle', () {
    test('eine Person ohne Verwandtschaft ergibt einen Knoten', () {
      final s = ordneSanduhr(Verwandtschaftsnetz([]), 'allein', ordnung);
      expect(s.knoten, hasLength(1));
      expect(s.kanten, isEmpty);
    });

    test('ein Kreis im Bestand bringt die Anordnung nicht zum Stehen', () {
      final netz = Verwandtschaftsnetz([
        kante('a', 'b', Verwandtschaft.elternteil),
        kante('b', 'a', Verwandtschaft.elternteil),
      ]);
      final s = ordneSanduhr(netz, 'a', (id) => 0);
      expect(s.knoten, isNotEmpty);
    });

    test('niemand steht zweimal im Bild', () {
      // Bei verschlungenen Familien kann dieselbe Person auf mehreren
      // Wegen erreichbar sein – zweimal gezeichnet wäre sie zweimal
      // anzutippen und einmal falsch verbunden.
      final s = bau();
      final ids = s.knoten.map((k) => k.personId).toList();
      expect(ids.toSet(), hasLength(ids.length));
    });
  });
}
