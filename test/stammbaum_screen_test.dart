import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:photo_vault/db/database.dart';
import 'package:photo_vault/l10n/app_localizations.dart';
import 'package:photo_vault/screens/stammbaum_screen.dart';
import 'package:photo_vault/services/backup_service.dart';
import 'package:photo_vault/services/stammbaum.dart';
import 'package:photo_vault/services/storage_paths.dart';
import 'package:photo_vault/state/library_state.dart';
import 'package:photo_vault/theme/app_theme.dart';

/// Der Stammbaum-Bildschirm.
///
/// Geprüft wird, was man an einem Bildschirmfoto nicht sieht: dass die
/// richtigen Personen in den richtigen Reihen stehen, dass ein Klick den
/// Ausschnitt verschiebt statt den Bildschirm zu verlassen, und dass die
/// Hinweise auf weitere Verwandtschaft nur dort erscheinen, wo tatsächlich
/// etwas außerhalb des Bildes liegt.
void main() {
  late Directory tempRoot;
  late AppDatabase db;
  late LibraryState library;

  setUp(() async {
    tempRoot = Directory.systemTemp.createTempSync('pv_stammbaum_');
    db = AppDatabase(NativeDatabase.memory());
    final paths = await StoragePaths.forTesting(Directory(p.join(tempRoot.path, 'lib')));
    library = LibraryState()
      ..db = db
      ..paths = paths
      ..backupService = BackupService(db, paths);

    // opa + oma -> vater; vater + mutter -> kind, schwester
    for (final (id, name, jahr) in [
      ('opa', 'Opa', 1901),
      ('oma', 'Oma', 1903),
      ('vater', 'Vater', 1931),
      ('mutter', 'Mutter', 1934),
      ('kind', 'Kind', 1962),
      ('schwester', 'Schwester', 1965),
    ]) {
      await db.createPerson(PeopleCompanion.insert(
        id: id,
        name: name,
        geburtsdatum: Value(DateTime(jahr)),
      ));
    }
    await db.fuegeBeziehungHinzu('vater', 'opa', Verwandtschaft.elternteil);
    await db.fuegeBeziehungHinzu('vater', 'oma', Verwandtschaft.elternteil);
    await db.fuegeBeziehungHinzu('vater', 'mutter', Verwandtschaft.partner);
    await db.fuegeBeziehungHinzu('kind', 'vater', Verwandtschaft.elternteil);
    await db.fuegeBeziehungHinzu('kind', 'mutter', Verwandtschaft.elternteil);
    await db.fuegeBeziehungHinzu('schwester', 'vater', Verwandtschaft.elternteil);
    await db.fuegeBeziehungHinzu('schwester', 'mutter', Verwandtschaft.elternteil);
  });

  tearDown(() async {
    await db.close();
    tempRoot.deleteSync(recursive: true);
  });

  /// Der Bildschirm wird auf eine Route geschoben statt als `home` gesetzt:
  /// Nur dann gibt es einen Zurück-Pfeil, und nur dann lässt sich prüfen,
  /// dass er erst dem Weg durch den Baum folgt.
  Future<void> zeige(WidgetTester tester, String start) async {
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('de'),
      localizationsDelegates: AppTexte.localizationsDelegates,
      supportedLocales: AppTexte.supportedLocales,
      theme: buildDarkTheme(),
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    StammbaumScreen(library: library, startPersonId: start),
              )),
              child: const Text('auf'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('auf'));
    await tester.pumpAndSettle();
  }

  testWidgets('zeigt Eltern, Geschwister und Lebensdaten', (tester) async {
    await zeige(tester, 'kind');

    expect(find.text('Eltern'), findsOneWidget);
    expect(find.text('Vater'), findsOneWidget);
    expect(find.text('Mutter'), findsOneWidget);
    expect(find.text('Geschwister'), findsOneWidget);
    expect(find.text('Schwester'), findsOneWidget);
    // Der Jahrgang steht unter dem Namen.
    expect(find.text('*1931'), findsOneWidget);
  });

  testWidgets('zeigt Partner und Kinder der Person in der Mitte',
      (tester) async {
    await zeige(tester, 'vater');

    expect(find.text('Partner'), findsOneWidget);
    expect(find.text('Kinder'), findsOneWidget);
    expect(find.text('Kind'), findsOneWidget);
    expect(find.text('Schwester'), findsOneWidget);
    // Geschwister hat der Vater keine – die Beschriftung darf dann nicht
    // als leere Überschrift dastehen.
    expect(find.text('Geschwister'), findsNothing);
  });

  testWidgets('ein Klick rückt die angetippte Person in die Mitte',
      (tester) async {
    await zeige(tester, 'kind');
    expect(find.text('Opa'), findsNothing, reason: 'Großeltern stehen nicht im Bild');

    await tester.tap(find.text('Vater'));
    await tester.pumpAndSettle();

    // Jetzt steht der Vater in der Mitte, seine Eltern darüber.
    expect(find.text('Opa'), findsOneWidget);
    expect(find.text('Oma'), findsOneWidget);
  });

  testWidgets('der Zurück-Pfeil folgt dem eigenen Weg durch den Baum',
      (tester) async {
    await zeige(tester, 'kind');
    await tester.tap(find.text('Vater'));
    await tester.pumpAndSettle();
    expect(find.text('Opa'), findsOneWidget);

    // Nicht tester.pageBack(): das sucht nach der Beschriftung "Back",
    // und die Oberfläche läuft hier auf Deutsch.
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // Zurück beim Kind – und nicht aus dem Stammbaum heraus.
    expect(find.byType(StammbaumScreen), findsOneWidget);
    expect(find.text('Opa'), findsNothing);
    expect(find.text('Geschwister'), findsOneWidget);
  });

  testWidgets('weist auf Verwandtschaft hin, die außerhalb des Bildes liegt',
      (tester) async {
    await zeige(tester, 'kind');
    // Genau ein Hinweis nach oben: beim Vater, der selbst Eltern hat. Die
    // Mutter hat keine, das Kind in der Mitte bekommt nie einen.
    expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);
  });

  testWidgets('eine Verbindung lässt sich lösen', (tester) async {
    await zeige(tester, 'kind');

    final maus = await tester.createGesture(
        kind: PointerDeviceKind.mouse, buttons: kSecondaryMouseButton);
    await maus.down(tester.getCenter(find.text('Mutter')));
    await maus.up();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Verbindung entfernen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Entfernen'));
    await tester.pumpAndSettle();

    expect(find.text('Mutter'), findsNothing);
    // Die Schwester hängt an beiden Eltern und bleibt über den Vater
    // weiterhin Geschwister.
    expect(find.text('Schwester'), findsOneWidget);
    expect((await db.alleBeziehungen()).length, 6);
  });

  testWidgets('so sieht der Baum aus', (tester) async {
    // Ein Abbild statt einer Behauptung. An das echte Fenster kommt man in
    // dieser Umgebung nicht heran; das gerenderte Bild ist die einzige
    // Möglichkeit, die Anordnung und die Verbindungslinien tatsächlich
    // anzusehen statt sie aus dem Quelltext zu erschliessen. Die Schrift
    // ist im Test ein Platzhalter – es geht um Kästen und Linien.
    tester.view.physicalSize = const Size(1000, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await zeige(tester, 'kind');
    await expectLater(
      find.byType(StammbaumScreen),
      matchesGoldenFile('golden/stammbaum.png'),
    );
  });

  testWidgets('so sieht der Baum mit Partner und Kindern aus', (tester) async {
    // Der zweite Fall: eine Person mit Eltern darüber, Partner daneben und
    // zwei Kindern darunter. Das erste Abbild zeigt weder die kurze Linie
    // zum Partner noch den Verbinder nach unten.
    tester.view.physicalSize = const Size(1000, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await zeige(tester, 'vater');
    await expectLater(
      find.byType(StammbaumScreen),
      matchesGoldenFile('golden/stammbaum_voll.png'),
    );
  });

  testWidgets('eine Person ohne Verwandtschaft bekommt eine Erklärung',
      (tester) async {
    await db.createPerson(PeopleCompanion.insert(id: 'allein', name: 'Allein'));
    await zeige(tester, 'allein');
    expect(find.textContaining('noch keine Verwandtschaft eingetragen'),
        findsOneWidget);
  });
}
