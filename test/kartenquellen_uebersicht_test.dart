import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_vault/l10n/app_localizations.dart';
import 'package:photo_vault/services/eigenkarte.dart';
import 'package:photo_vault/theme/app_theme.dart';
import 'package:photo_vault/widgets/kartenquellen_uebersicht.dart';

void main() {
  Future<void> zeige(WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('de'),
      localizationsDelegates: AppTexte.localizationsDelegates,
      supportedLocales: AppTexte.supportedLocales,
      theme: buildDarkTheme(),
      home: const Scaffold(
        body: SingleChildScrollView(child: KartenquellenUebersicht()),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('alle mitgelieferten Karten stehen drin', (tester) async {
    await zeige(tester);
    expect(find.text('Hell'), findsOneWidget);
    expect(find.text('Dunkel'), findsOneWidget);
    expect(find.text('Topografie'), findsOneWidget);
  });

  testWidgets('und jede Vorlage', (tester) async {
    await zeige(tester);
    for (final v in kartenvorlagen) {
      expect(find.text(v.name), findsOneWidget, reason: v.name);
    }
  });

  testWidgets('die Tiefe steht in Stufen UND in Metern', (tester) async {
    // Der eigentliche Zweck: „bis Stufe 17" sagt niemandem etwas.
    await zeige(tester);
    expect(find.textContaining('bis Stufe 19 · rund 18 m'), findsWidgets);
    expect(find.textContaining('bis Stufe 17 · rund 74 m'), findsOneWidget);
    expect(find.textContaining('bis Stufe 20 · rund 9 m'), findsWidgets);
  });

  testWidgets('gemessen und behauptet werden auseinandergehalten',
      (tester) async {
    await zeige(tester);
    expect(find.textContaining('nachgemessen'), findsWidgets);
    expect(find.textContaining('laut Anbieter'), findsWidgets);
  });

  testWidgets('wo ein Schluessel noetig ist, steht es dabei', (tester) async {
    await zeige(tester);
    final mitSchluessel =
        kartenvorlagen.where((v) => v.brauchtSchluessel).length;
    expect(find.textContaining('Schlüssel nötig'), findsNWidgets(mitSchluessel));
  });

  testWidgets('die Namensnennung jedes Anbieters steht dabei', (tester) async {
    // Sie ist eine Lizenzauflage - eine Uebersicht ohne sie waere eine
    // Werbeliste.
    await zeige(tester);
    expect(find.textContaining('© Esri'), findsWidgets);
    expect(find.textContaining('© OpenStreetMap contributors'), findsWidgets);
  });
}
