import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_vault/db/database.dart';
import 'package:photo_vault/l10n/app_localizations.dart';
import 'package:photo_vault/widgets/timeline_scrubber.dart';

/// Der Regler ist reine Oberfläche, aber eine mit Fallstricken: Er zeichnet
/// in einem [Stack] mit festen Abständen, und seine Beschriftungen sind in
/// beiden Sprachen unterschiedlich lang. Diese Prüfungen halten fest, dass
/// er in eine schmale Leiste passt, ohne überzulaufen.
AssetData _foto(String id, DateTime wann) => AssetData(
      id: id,
      relativePath: 'originals/$id.jpg',
      originalFileName: '$id.jpg',
      type: 'IMAGE',
      fileSizeBytes: 1000,
      checksum: id,
      fileCreatedAt: wann,
      importedAt: wann,
      isFavorite: false,
      isTrashed: false,
      isLocked: false,
      backedUp: false,
      autoBackedUp: false,
      facesScanned: false,
      ocrScanned: false,
      aiCaptionScanned: false,
      aiTagsScanned: false,
      isStackCover: false,
      rating: 0,
    );

/// Vier Jahre à zwölf Monate, absteigend – so viel, dass Jahreszahlen und
/// Monatspunkte dicht beieinander liegen.
({List<int> keys, Map<int, List<AssetData>> groups}) _bibliothek() {
  final keys = <int>[];
  final groups = <int, List<AssetData>>{};
  for (var jahr = 2026; jahr >= 2023; jahr--) {
    for (var monat = 12; monat >= 1; monat--) {
      final key = jahr * 100 + monat;
      keys.add(key);
      groups[key] = [
        for (var i = 0; i < 8; i++) _foto('$key-$i', DateTime(jahr, monat, 5)),
      ];
    }
  }
  return (keys: keys, groups: groups);
}

Future<void> _zeige(WidgetTester tester, Locale locale, double breite) async {
  final b = _bibliothek();
  await tester.pumpWidget(MaterialApp(
    locale: locale,
    localizationsDelegates: AppTexte.localizationsDelegates,
    supportedLocales: AppTexte.supportedLocales,
    home: Scaffold(
      body: Row(
        children: [
          const Expanded(child: SizedBox()),
          SizedBox(
            width: breite,
            height: 600,
            child: TimelineScrubber(
              orderedKeys: b.keys,
              groups: b.groups,
              controller: ScrollController(),
              gridWidth: 800,
            ),
          ),
        ],
      ),
    ),
  ));
  await tester.pump();
}

void main() {
  testWidgets('die Jahreszahlen stehen da, die Monate nicht', (tester) async {
    await _zeige(tester, const Locale('de'), 64);
    // Vier Jahre, jedes genau einmal beschriftet – nicht 48 Monate.
    for (final jahr in ['2026', '2025', '2024', '2023']) {
      expect(find.text(jahr), findsOneWidget, reason: '$jahr fehlt');
    }
  });

  testWidgets('nichts läuft über die Leiste hinaus', (tester) async {
    // Die eigentliche Gefahr: Die aktive Beschriftung ("Dez. 2026") ist
    // deutlich breiter als eine Jahreszahl. Läuft sie über, meldet Flutter
    // einen Overflow – und der zählt hier als Fehler.
    for (final locale in [const Locale('de'), const Locale('en')]) {
      await _zeige(tester, locale, 64);
      expect(tester.takeException(), isNull,
          reason: 'Überlauf in ${locale.languageCode}');
    }
  });

  testWidgets('bei sehr wenigen Monaten erscheint der Regler gar nicht',
      (tester) async {
    // Ein Schnell-Scroll-Regler über zwei Gruppen wäre nur Unruhe.
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('de'),
      localizationsDelegates: AppTexte.localizationsDelegates,
      supportedLocales: AppTexte.supportedLocales,
      home: Scaffold(
        body: SizedBox(
          width: 64,
          height: 600,
          child: TimelineScrubber(
            orderedKeys: const [202601],
            groups: {202601: [_foto('a', DateTime(2026, 1, 5))]},
            controller: ScrollController(),
            gridWidth: 800,
          ),
        ),
      ),
    ));
    expect(find.text('2026'), findsNothing);
  });
}
