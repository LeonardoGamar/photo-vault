import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_vault/l10n/app_localizations.dart';
import 'package:photo_vault/theme/app_theme.dart';
import 'package:photo_vault/widgets/mini_location_map.dart';

/// Die Namensnennung der Kartenanbieter ist eine Lizenzauflage – sie muss
/// vollständig zu sehen sein, auch in der schmalsten Stelle, an der eine
/// Karte vorkommt: der 340 Punkte breiten Info-Ansicht.
///
/// Vorher lief sie dort um über 400 Punkte über und wurde abgeschnitten.
/// Aufgefallen ist das erst, als die Info-Ansicht zum ersten Mal unter
/// Test stand; am Bildschirm sieht man einen abgeschnittenen Kleinsttext
/// in einer Ecke nicht.
void main() {
  /// Die Breite der Info-Ansicht (siehe AssetInfoSheet in
  /// asset_viewer_screen.dart und face_review_screen.dart).
  const panelBreite = 340.0;

  Future<void> zeige(WidgetTester tester, double breite) async {
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('de'),
      localizationsDelegates: AppTexte.localizationsDelegates,
      supportedLocales: AppTexte.supportedLocales,
      theme: buildDarkTheme(),
      home: Scaffold(
        body: SizedBox(
          width: breite,
          child: const MiniLocationMap(
            latitude: null,
            longitude: null,
            height: 200,
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('passt in die Breite der Info-Ansicht', (tester) async {
    await zeige(tester, panelBreite);
    // Ein Überlauf meldet sich als Ausnahme; tester.takeException() wäre
    // dann nicht null. Zusätzlich die Sichtprüfung, dass der Text ganz da
    // ist und nicht bloß in Teilen.
    expect(tester.takeException(), isNull);
    expect(find.text(kOsmDarkAttribution), findsOneWidget);
  });

  testWidgets('passt auch in eine sehr schmale Spalte', (tester) async {
    // Ein Fenster kann schmaler werden als die Info-Ansicht; die Auflage
    // gilt dann trotzdem.
    await zeige(tester, 200);
    expect(tester.takeException(), isNull);
    expect(find.text(kOsmDarkAttribution), findsOneWidget);
  });

  testWidgets('deckt die Karte nicht zu', (tester) async {
    await zeige(tester, panelBreite);
    final breite = tester.getSize(find.text(kOsmDarkAttribution)).width;
    expect(breite, lessThan(panelBreite * 2 / 3),
        reason: 'sonst liegt sie über der halben Karte');
  });
}
