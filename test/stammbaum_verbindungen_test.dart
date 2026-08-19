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

/// Verbindungen im Stammbaum: lösen, umwidmen, und die Verwandten, die
/// über eine Zwischenperson eingetragen werden.
///
/// Der erste Block hält einen gemeldeten Fehler fest: Eine Adoptiv- oder
/// Pflegeverbindung ließ sich nicht lösen. Beide Elternreihen übergaben
/// fest „leiblich", und das Löschen traf deshalb keine Zeile – ohne
/// Fehler, ohne Hinweis.
void main() {
  late Directory tempRoot;
  late AppDatabase db;
  late LibraryState library;

  setUp(() async {
    tempRoot = Directory.systemTemp.createTempSync('pv_verbindungen_');
    db = AppDatabase(NativeDatabase.memory());
    final paths = await StoragePaths.forTesting(Directory(p.join(tempRoot.path, 'lib')));
    library = LibraryState()
      ..db = db
      ..paths = paths
      ..backupService = BackupService(db, paths);

    for (final (id, name, jahr) in [
      ('kind', 'Kind', 1960),
      ('vater', 'Vater', 1930),
      ('ziehvater', 'Ziehvater', 1932),
      ('pflegemutter', 'Pflegemutter', 1935),
      ('enkel', 'Enkel', 1990),
      ('fremd', 'Fremd', 1970),
    ]) {
      await db.createPerson(PeopleCompanion.insert(
          id: id, name: name, geburtsdatum: Value(DateTime(jahr))));
    }
  });

  tearDown(() async {
    await db.close();
    tempRoot.deleteSync(recursive: true);
  });

  Future<void> zeige(WidgetTester tester, String start) async {
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('de'),
      localizationsDelegates: AppTexte.localizationsDelegates,
      supportedLocales: AppTexte.supportedLocales,
      theme: buildDarkTheme(),
      home: StammbaumScreen(library: library, startPersonId: start),
    ));
    await tester.pumpAndSettle();
  }

  /// Wählt im Personenwähler eine bestehende Person aus und bestätigt.
  ///
  /// Der Wähler ist ein Ausklappfeld, keine Liste: erst aufklappen, dann
  /// den Namen antippen, dann übernehmen.
  Future<void> waehlePerson(WidgetTester tester, String name) async {
    await tester.tap(find.byType(DropdownButtonFormField<PersonData>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(name).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zuordnen'));
    await tester.pumpAndSettle();
  }

  /// Öffnet das Kartenmenü über den sichtbaren Knopf.
  Future<void> oeffneMenue(WidgetTester tester, String name) async {
    final karte = find.ancestor(
      of: find.text(name).first,
      matching: find.byType(Stack),
    );
    await tester.tap(
      find.descendant(of: karte.first, matching: find.byIcon(Icons.more_vert)).first,
    );
    await tester.pumpAndSettle();
  }

  group('Verbindung lösen', () {
    test('eine Adoptivkante lässt sich auch als "leiblich" adressiert lösen', () async {
      await db.fuegeBeziehungHinzu('kind', 'ziehvater', Verwandtschaft.adoptivelternteil);
      // Genau der Aufruf, den die Oberfläche vorher machte.
      final weg = await db.entferneBeziehung(
          'kind', 'ziehvater', Verwandtschaft.elternteil);
      expect(weg, isTrue);
      expect(await db.alleBeziehungen(), isEmpty);
    });

    test('das Lösen meldet, wenn es gar nichts gab', () async {
      expect(
        await db.entferneBeziehung('kind', 'fremd', Verwandtschaft.elternteil),
        isFalse,
      );
    });

    test('eine Partnerkante bleibt beim Lösen einer Elternkante stehen', () async {
      await db.fuegeBeziehungHinzu('kind', 'vater', Verwandtschaft.elternteil);
      await db.fuegeBeziehungHinzu('kind', 'fremd', Verwandtschaft.partner);
      await db.entferneBeziehung('kind', 'vater', Verwandtschaft.elternteil);
      final rest = await db.alleBeziehungen();
      expect(rest, hasLength(1));
      expect(rest.single.art, 'partner');
    });

    testWidgets('über die Oberfläche: die Adoptivkarte verschwindet', (tester) async {
      await db.fuegeBeziehungHinzu('kind', 'ziehvater', Verwandtschaft.adoptivelternteil);
      await db.fuegeBeziehungHinzu('kind', 'pflegemutter', Verwandtschaft.pflegeelternteil);
      await zeige(tester, 'kind');

      await oeffneMenue(tester, 'Ziehvater');
      await tester.tap(find.text('Verbindung entfernen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Entfernen'));
      await tester.pumpAndSettle();

      expect(find.text('Ziehvater'), findsNothing);
      expect(find.text('Pflegemutter'), findsWidgets, reason: 'die andere bleibt');
      final rest = await db.alleBeziehungen();
      expect(rest, hasLength(1));
      expect(rest.single.andereId, 'pflegemutter');
    });

    testWidgets('das Menü öffnet auch weiterhin per rechter Maustaste', (tester) async {
      await db.fuegeBeziehungHinzu('kind', 'vater', Verwandtschaft.elternteil);
      await zeige(tester, 'kind');

      final maus = await tester.createGesture(
          kind: PointerDeviceKind.mouse, buttons: kSecondaryMouseButton);
      await maus.down(tester.getCenter(find.text('Vater').first));
      await maus.up();
      await tester.pumpAndSettle();
      expect(find.text('Verbindung entfernen'), findsOneWidget);
    });
  });

  group('Art der Verbindung ändern', () {
    test('aus leiblich wird adoptiv, ohne die Verbindung zu verlieren', () async {
      await db.fuegeBeziehungHinzu('kind', 'vater', Verwandtschaft.elternteil);
      expect(
        await db.aendereElternart('kind', 'vater', Verwandtschaft.adoptivelternteil),
        isTrue,
      );
      final zeilen = await db.alleBeziehungen();
      expect(zeilen, hasLength(1));
      expect(zeilen.single.art, 'adoptiv');
      expect(zeilen.single.personId, 'kind');
      expect(zeilen.single.andereId, 'vater');
    });

    test('ohne bestehende Verbindung wird nichts angelegt', () async {
      expect(
        await db.aendereElternart('kind', 'fremd', Verwandtschaft.adoptivelternteil),
        isFalse,
      );
      expect(await db.alleBeziehungen(), isEmpty);
    });

    test('eine Partnerschaft hat keine Art und lässt sich nicht umwidmen', () async {
      await db.fuegeBeziehungHinzu('kind', 'fremd', Verwandtschaft.partner);
      expect(
        await db.aendereElternart('kind', 'fremd', Verwandtschaft.partner),
        isFalse,
      );
      expect((await db.alleBeziehungen()).single.art, 'partner');
    });

    testWidgets('über die Oberfläche wird aus dem Vater ein Ziehvater', (tester) async {
      await db.fuegeBeziehungHinzu('kind', 'vater', Verwandtschaft.elternteil);
      await zeige(tester, 'kind');

      await oeffneMenue(tester, 'Vater');
      await tester.tap(find.text('Art der Verbindung …'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Adoptiv'));
      await tester.pumpAndSettle();

      expect((await db.alleBeziehungen()).single.art, 'adoptiv');
    });
  });

  group('Kartenhöhe', () {
    testWidgets('ein zweizeiliger Name lässt die Karte nicht überlaufen',
        (tester) async {
      // Der Fall fiel beim Nachstellen des Verbindungsfehlers auf: Ein
      // Name, der in zwei Zeilen umbricht, brauchte zusammen mit
      // Bezeichnung und Lebensspanne 158 Punkte – die Karte war 148 hoch.
      // Nachgemessen, nicht geschätzt.
      await db.createPerson(PeopleCompanion.insert(
        id: 'lang',
        name: 'Marianne Schmidt-Hollmann',
        geburtsdatum: Value(DateTime(1874)),
        sterbedatum: Value(DateTime(1955)),
      ));
      await db.fuegeBeziehungHinzu('kind', 'lang', Verwandtschaft.elternteil);
      await zeige(tester, 'kind');

      expect(find.textContaining('Marianne'), findsWidgets);
      expect(find.text('1874–1955'), findsOneWidget);
      expect(tester.takeException(), isNull,
          reason: 'Ein Überlauf meldet sich hier als Ausnahme.');
    });
  });

  group('Weitere Verwandte', () {
    testWidgets('ein Geschwisterkind bekommt beide Eltern', (tester) async {
      await db.fuegeBeziehungHinzu('kind', 'vater', Verwandtschaft.elternteil);
      await db.fuegeBeziehungHinzu('kind', 'pflegemutter', Verwandtschaft.elternteil);
      await zeige(tester, 'kind');

      await tester.tap(find.byTooltip('Mehr'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Geschwisterkind hinzufügen …'));
      await tester.pumpAndSettle();
      await waehlePerson(tester, 'Fremd');

      final kanten = await db.alleBeziehungen();
      expect(
        kanten.where((k) => k.personId == 'fremd').map((k) => k.andereId).toSet(),
        equals({'vater', 'pflegemutter'}),
        reason: 'Ein Geschwisterkind mit nur einem Elternteil wäre ein '
            'Halbgeschwisterkind – eine andere Aussage.',
      );
    });

    testWidgets('ohne Elternteil erklärt der Hinweis, was fehlt', (tester) async {
      await zeige(tester, 'kind');

      await tester.tap(find.byTooltip('Mehr'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Geschwisterkind hinzufügen …'));
      await tester.pumpAndSettle();

      expect(find.textContaining('teilt sich einen Elternteil'), findsOneWidget);
      expect(await db.alleBeziehungen(), isEmpty);
    });

    testWidgets('ein Großelternteil wird Elternteil des einzigen Elternteils',
        (tester) async {
      await db.fuegeBeziehungHinzu('kind', 'vater', Verwandtschaft.elternteil);
      await zeige(tester, 'kind');

      await tester.tap(find.byTooltip('Mehr'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Großelternteil hinzufügen …'));
      await tester.pumpAndSettle();
      // Nur ein Elternteil – es wird nicht gefragt.
      await waehlePerson(tester, 'Fremd');

      final neu = (await db.alleBeziehungen())
          .where((k) => k.andereId == 'fremd')
          .toList();
      expect(neu, hasLength(1));
      expect(neu.single.personId, 'vater');
    });

    testWidgets('bei zwei Eltern wird gefragt, wessen Elternteil gemeint ist',
        (tester) async {
      await db.fuegeBeziehungHinzu('kind', 'vater', Verwandtschaft.elternteil);
      await db.fuegeBeziehungHinzu('kind', 'pflegemutter', Verwandtschaft.elternteil);
      await zeige(tester, 'kind');

      await tester.tap(find.byTooltip('Mehr'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Großelternteil hinzufügen …'));
      await tester.pumpAndSettle();

      expect(find.text('Wessen Elternteil?'), findsOneWidget);
      await tester.tap(find.text('Pflegemutter').last);
      await tester.pumpAndSettle();
      await waehlePerson(tester, 'Fremd');

      final neu = (await db.alleBeziehungen())
          .where((k) => k.andereId == 'fremd')
          .toList();
      expect(neu.single.personId, 'pflegemutter');
    });

    testWidgets('ein Enkelkind wird Kind des Kindes', (tester) async {
      await db.fuegeBeziehungHinzu('enkel', 'kind', Verwandtschaft.elternteil);
      await zeige(tester, 'kind');

      await tester.tap(find.byTooltip('Mehr'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enkelkind hinzufügen …'));
      await tester.pumpAndSettle();
      await waehlePerson(tester, 'Fremd');

      final neu = (await db.alleBeziehungen())
          .where((k) => k.personId == 'fremd')
          .toList();
      expect(neu.single.andereId, 'enkel');
    });
  });
}
