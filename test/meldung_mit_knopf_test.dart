import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_vault/widgets/meldung_mit_knopf.dart';

/// Meldungen mit Knopf blieben für immer stehen.
///
/// Der Grund steht in Flutters `snack_bar.dart`: `persist = persist ??
/// action != null`. Wer einen Knopf anbietet, bekommt ungefragt eine
/// Meldung, die nicht mehr weggeht. Der erste Test hier hält Flutters
/// Verhalten fest – fällt er eines Tages, hat die Bibliothek ihre
/// Voreinstellung geändert und dieses Widget wird überflüssig.
Widget _rahmen(SnackBar Function() bauen) => MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (c) => TextButton(
            onPressed: () => ScaffoldMessenger.of(c).showSnackBar(bauen()),
            child: const Text('los'),
          ),
        ),
      ),
    );

/// Die Uhr vorstellen und die Ausblendung zu Ende laufen lassen.
///
/// **Beides ist nötig, und zwar in dieser Reihenfolge.** `pump(dauer)`
/// erzeugt genau ein Bild und lässt dabei die Uhr springen – damit
/// feuert der Zeitgeber, der die Meldung schliesst. Die Ausblendung
/// selbst ist eine Animation und braucht weitere Bilder; ohne
/// `pumpAndSettle` steht die Meldung noch im Baum, obwohl sie schon
/// geht, und der Test fände sie.
Future<void> _warten(WidgetTester tester, Duration dauer) async {
  await tester.pump(dauer);
  await tester.pumpAndSettle();
}

Future<void> _zeigen(WidgetTester tester) async {
  await tester.tap(find.text('los'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  testWidgets('Flutters Voreinstellung: mit Knopf bleibt sie stehen',
      (tester) async {
    await tester.pumpWidget(_rahmen(() => SnackBar(
          content: const Text('hallo'),
          action: SnackBarAction(label: 'zurück', onPressed: () {}),
        )));
    await _zeigen(tester);
    expect(find.byType(SnackBar), findsOneWidget);

    // Zwanzig Sekunden – das Fünffache der Standarddauer.
    await _warten(tester, const Duration(seconds: 20));
    expect(find.byType(SnackBar), findsOneWidget,
        reason: 'Flutter lässt eine Meldung mit Knopf liegen');
  });

  testWidgets('ohne Knopf verschwindet sie nach vier Sekunden',
      (tester) async {
    await tester.pumpWidget(
        _rahmen(() => const SnackBar(content: Text('hallo'))));
    await _zeigen(tester);
    expect(find.byType(SnackBar), findsOneWidget);
    await _warten(tester, const Duration(seconds: 6));
    expect(find.byType(SnackBar), findsNothing);
  });

  group('meldungMitKnopf', () {
    testWidgets('bleibt lange genug für den Knopf stehen', (tester) async {
      await tester.pumpWidget(_rahmen(() => meldungMitKnopf(
            inhalt: const Text('hallo'),
            knopf: SnackBarAction(label: 'zurück', onPressed: () {}),
          )));
      await _zeigen(tester);
      expect(find.byType(SnackBar), findsOneWidget);

      // Nach den vier Sekunden, die eine Meldung ohne Knopf hat, steht
      // sie noch – wer zurücknehmen will, braucht Zeit zum Lesen.
      await tester.pump(const Duration(seconds: 5));
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('zurück'), findsOneWidget);
    });

    testWidgets('und verschwindet dann von selbst', (tester) async {
      await tester.pumpWidget(_rahmen(() => meldungMitKnopf(
            inhalt: const Text('hallo'),
            knopf: SnackBarAction(label: 'zurück', onPressed: () {}),
          )));
      await _zeigen(tester);
      await _warten(tester, meldungMitKnopfDauer + const Duration(seconds: 2));
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('der Knopf wirkt, solange sie steht', (tester) async {
      var gedrueckt = false;
      await tester.pumpWidget(_rahmen(() => meldungMitKnopf(
            inhalt: const Text('hallo'),
            knopf: SnackBarAction(
                label: 'zurück', onPressed: () => gedrueckt = true),
          )));
      await _zeigen(tester);
      await tester.tap(find.text('zurück'));
      await tester.pump();
      expect(gedrueckt, isTrue);
      // Ein Druck auf den Knopf nimmt die Meldung mit weg.
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
    });
  });
}
