import 'package:flutter_test/flutter_test.dart';
import 'package:photo_vault/services/stammbaum.dart';

/// Die Verwandtschaftslogik.
///
/// Zwei Dinge sind hier leicht falsch und am fertigen Bild nicht zu sehen:
/// ein Kreis (jemand wird zum eigenen Vorfahren, jede Auswertung nach oben
/// läuft dann endlos) und eine Partnerkante, die je nach Eingaberichtung
/// zweimal entsteht und sich nur zur Hälfte wieder entfernen lässt.
void main() {
  /// Eine kleine Familie:
  ///   opa + oma
  ///        |
  ///     vater + mutter
  ///        |
  ///   kind, schwester
  Verwandtschaftsnetz familie() => Verwandtschaftsnetz([
        partnerKanteFuer('opa', 'oma'),
        kante('vater', 'opa', Verwandtschaft.elternteil),
        kante('vater', 'oma', Verwandtschaft.elternteil),
        partnerKanteFuer('vater', 'mutter'),
        kante('kind', 'vater', Verwandtschaft.elternteil),
        kante('kind', 'mutter', Verwandtschaft.elternteil),
        kante('schwester', 'vater', Verwandtschaft.elternteil),
        kante('schwester', 'mutter', Verwandtschaft.elternteil),
      ]);

  group('Verwandtschaftsnetz', () {
    test('liest die Gegenrichtung aus derselben Kante', () {
      final netz = familie();
      expect(netz.eltern('kind'), {'vater', 'mutter'});
      expect(netz.kinder('vater'), {'kind', 'schwester'});
    });

    test('Partnerschaft gilt in beide Richtungen, obwohl nur einmal gespeichert', () {
      final netz = familie();
      expect(netz.partner('vater'), {'mutter'});
      expect(netz.partner('mutter'), {'vater'});
    });

    test('Geschwister sind die weiteren Kinder der eigenen Eltern', () {
      expect(familie().geschwister('kind'), {'schwester'});
      expect(familie().geschwister('vater'), isEmpty);
    });

    test('ein gemeinsamer Elternteil genügt für Geschwister', () {
      final netz = Verwandtschaftsnetz([
        kante('a', 'vater', Verwandtschaft.elternteil),
        kante('b', 'vater', Verwandtschaft.elternteil),
        kante('b', 'zweiteMutter', Verwandtschaft.elternteil),
      ]);
      expect(netz.geschwister('a'), {'b'});
    });

    test('Vorfahren werden über beliebig viele Stufen gefunden', () {
      final netz = familie();
      expect(netz.istVorfahreVon('opa', 'kind'), isTrue);
      expect(netz.istVorfahreVon('kind', 'opa'), isFalse);
      expect(netz.istVorfahreVon('kind', 'kind'), isTrue,
          reason: 'die Person selbst zählt mit');
    });

    test('kommt aus einem bereits vorhandenen Kreis zurück', () {
      // Ein Bestand, der ohne die Prüfung entstanden sein könnte. Ohne das
      // Merken des Besuchten liefe diese Suche endlos.
      final netz = Verwandtschaftsnetz([
        kante('a', 'b', Verwandtschaft.elternteil),
        kante('b', 'a', Verwandtschaft.elternteil),
      ]);
      expect(netz.istVorfahreVon('fremd', 'a'), isFalse);
    });
  });

  group('partnerKanteFuer', () {
    test('ergibt dieselbe Kante, egal in welcher Richtung eingegeben', () {
      expect(partnerKanteFuer('anna', 'bert'), partnerKanteFuer('bert', 'anna'));
    });
  });

  group('pruefeBeziehung', () {
    test('lässt eine neue Verwandtschaft zu', () {
      expect(pruefeBeziehung(familie(), 'kind', 'fremd', Verwandtschaft.elternteil), isNull);
    });

    test('weist eine Person mit sich selbst ab', () {
      expect(pruefeBeziehung(familie(), 'kind', 'kind', Verwandtschaft.elternteil),
          Beziehungsfehler.mitSichSelbst);
    });

    test('weist einen Kreis ab', () {
      // „kind" als Elternteil von „opa" wäre ein Kreis über drei Stufen.
      expect(pruefeBeziehung(familie(), 'opa', 'kind', Verwandtschaft.elternteil),
          Beziehungsfehler.kreis);
    });

    test('erkennt eine bereits eingetragene Verwandtschaft', () {
      expect(pruefeBeziehung(familie(), 'kind', 'vater', Verwandtschaft.elternteil),
          Beziehungsfehler.schonVorhanden);
      // Auch in der Gegenrichtung, in der die Kante gar nicht steht.
      expect(pruefeBeziehung(familie(), 'mutter', 'vater', Verwandtschaft.partner),
          Beziehungsfehler.schonVorhanden);
    });

    test('eine Partnerschaft darf einen Kreis nicht auslösen', () {
      // Partner sind ungerichtet – zwischen ihnen kann es keinen Kreis
      // geben, auch nicht zwischen Vorfahr und Nachkomme.
      expect(pruefeBeziehung(familie(), 'opa', 'kind', Verwandtschaft.partner), isNull);
    });
  });

  group('ausschnittUm', () {
    final reihenfolge = ['oma', 'opa', 'mutter', 'vater', 'kind', 'schwester'];

    test('sammelt die unmittelbare Verwandtschaft', () {
      final a = ausschnittUm(familie(), 'kind', reihenfolge);
      expect(a.eltern, ['mutter', 'vater']);
      expect(a.geschwister, ['schwester']);
      expect(a.kinder, isEmpty);
      expect(a.partner, isEmpty);
    });

    test('hält die vorgegebene Reihenfolge ein', () {
      final a = ausschnittUm(familie(), 'vater', ['opa', 'oma']);
      expect(a.eltern, ['opa', 'oma'], reason: 'nicht die Reihenfolge der Kanten');
    });

    test('meldet Verwandtschaft, die außerhalb des Ausschnitts liegt', () {
      final a = ausschnittUm(familie(), 'kind', reihenfolge);
      // Der Vater hat selbst Eltern – die stehen nicht im Bild.
      expect(a.weitereOben['vater'], isTrue);
      // Die Kinder des Vaters sind der Fokus und die Schwester, beide da.
      expect(a.weitereUnten['vater'], isFalse);
      // Für die Person in der Mitte gibt es nie einen Hinweis: Ihre Eltern
      // und Kinder sind genau das, was ringsum steht.
      expect(a.weitereOben['kind'], isFalse);
      expect(a.weitereUnten['kind'], isFalse);
      // Und für ein Geschwister ebenso wenig: Es hat dieselben Eltern,
      // und die stehen bereits im Bild.
      expect(a.weitereOben['schwester'], isFalse);
    });

    test('ein Halbgeschwister bekommt den Hinweis sehr wohl', () {
      // Sein zweiter Elternteil steht nicht im Bild – genau darauf soll
      // der Hinweis aufmerksam machen.
      final netz = Verwandtschaftsnetz([
        kante('kind', 'vater', Verwandtschaft.elternteil),
        kante('halb', 'vater', Verwandtschaft.elternteil),
        kante('halb', 'andereMutter', Verwandtschaft.elternteil),
      ]);
      final a = ausschnittUm(netz, 'kind', ['vater', 'kind', 'halb', 'andereMutter']);
      expect(a.geschwister, ['halb']);
      expect(a.weitereOben['halb'], isTrue);
    });

    test('ein Partner mit Kindern aus früherer Verbindung ebenso', () {
      final netz = Verwandtschaftsnetz([
        partnerKanteFuer('ich', 'du'),
        kante('unser', 'ich', Verwandtschaft.elternteil),
        kante('unser', 'du', Verwandtschaft.elternteil),
        kante('deins', 'du', Verwandtschaft.elternteil),
      ]);
      final a = ausschnittUm(netz, 'ich', ['ich', 'du', 'unser', 'deins']);
      expect(a.kinder, ['unser'], reason: 'nur die eigenen Kinder stehen unten');
      expect(a.weitereUnten['du'], isTrue);
    });

    test('ist leer, wenn nichts eingetragen ist', () {
      final a = ausschnittUm(Verwandtschaftsnetz([]), 'allein', ['allein']);
      expect(a.istLeer, isTrue);
    });
  });

  group('lebensspanne', () {
    test('nennt beide Jahre', () {
      expect(lebensspanne(DateTime(1931, 4, 2), DateTime(2004, 11, 9)), '1931–2004');
    });

    test('kommt mit nur einer Angabe aus', () {
      expect(lebensspanne(DateTime(1972, 6, 1), null), '*1972');
      expect(lebensspanne(null, DateTime(2004)), '†2004');
    });

    test('bleibt weg, wenn nichts bekannt ist', () {
      expect(lebensspanne(null, null), isNull);
    });
  });
}
