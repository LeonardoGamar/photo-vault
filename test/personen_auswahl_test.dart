import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:photo_vault/db/database.dart';
import 'package:photo_vault/l10n/app_localizations.dart';
import 'package:photo_vault/services/storage_paths.dart';
import 'package:photo_vault/screens/people_screen.dart';
import 'package:photo_vault/widgets/person_picker_dialog.dart';

/// Der Zuordnungs-Dialog.
///
/// Zwei Dinge sind hier neu und beide leicht zu übersehen: dass die
/// bestehenden Personen ihr Profilbild zeigen, und dass „Ignorieren" nur
/// dort erscheint, wo der Aufrufer es angeboten hat. Ein Ignorieren-Knopf
/// an der falschen Stelle würde ein bereits benanntes Gesicht still aus
/// seiner Person entfernen.
void main() {
  late Directory tempRoot;
  late StoragePaths paths;

  setUp(() async {
    tempRoot = Directory.systemTemp.createTempSync('pv_person_picker_');
    paths = await StoragePaths.forTesting(Directory(p.join(tempRoot.path, 'library')));
  });

  tearDown(() => tempRoot.deleteSync(recursive: true));

  PersonData person(String id, String name, {String? bild}) => PersonData(
        id: id,
        name: name,
        coverFaceCropPath: bild,
      );

  /// Legt eine echte Bilddatei an – FileImage schlägt sonst beim Laden fehl,
  /// und der Test prüfte nur, dass ein Widget existiert, nicht dass es ein
  /// benutzbares Bild bekommt.
  String bilddatei(String faceId) {
    final relativ = paths.faceRelativePath(faceId);
    final datei = paths.absolute(relativ);
    datei.parent.createSync(recursive: true);
    // Kleinstes gültiges PNG (1×1, transparent).
    datei.writeAsBytesSync([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
      0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
      0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
      0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
      0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
      0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
      0x42, 0x60, 0x82,
    ]);
    return relativ;
  }

  Future<PersonChoice?> zeige(
    WidgetTester tester,
    List<PersonData> leute, {
    bool erlaubtIgnorieren = false,
    String? currentName,
  }) async {
    PersonChoice? ergebnis;
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('de'),
      localizationsDelegates: AppTexte.localizationsDelegates,
      supportedLocales: AppTexte.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () async {
              ergebnis = await showPersonPickerDialog(
                context,
                leute,
                paths: paths,
                erlaubtIgnorieren: erlaubtIgnorieren,
                currentName: currentName,
              );
            },
            child: const Text('los'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('los'));
    await tester.pumpAndSettle();
    return ergebnis;
  }

  testWidgets('bestehende Personen erscheinen mit ihrem Profilbild', (tester) async {
    final leute = [
      person('p1', 'Anna', bild: bilddatei('f1')),
      person('p2', 'Bernd', bild: bilddatei('f2')),
    ];
    await zeige(tester, leute);

    // Aufklappen, damit die Liste gebaut wird.
    await tester.tap(find.byType(DropdownButtonFormField<PersonData>));
    await tester.pumpAndSettle();

    expect(find.text('Anna'), findsWidgets);
    expect(find.byType(CircleAvatar), findsWidgets);

    final avatare = tester.widgetList<CircleAvatar>(find.byType(CircleAvatar));
    final bilder = avatare
        .map((a) => a.backgroundImage)
        .whereType<ResizeImage>()
        .toList();
    expect(bilder, isNotEmpty,
        reason: 'ohne backgroundImage bliebe nur der graue Platzhalter');
    // Seit der 17. Prüfrunde geht das Bild durch [begrenztesBild]: Ein
    // roher FileImage dekodierte die Datei in voller Grösse, und das an
    // neun gleichlautenden Stellen.
    expect(bilder.first.imageProvider, isA<FileImage>());
    expect(bilder.first.policy, ResizeImagePolicy.fit);
  });

  testWidgets('eine Person ohne Profilbild bekommt ein Platzhaltersymbol', (tester) async {
    // Der Fall tritt auf, bevor das erste Gesicht zugeordnet ist. Ein
    // FileImage auf einen nicht vorhandenen Pfad brächte eine rote
    // Fehlerbox mitten in die Liste.
    await zeige(tester, [person('p1', 'Ohne Bild')]);
    await tester.tap(find.byType(DropdownButtonFormField<PersonData>));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.person_outline), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ohne bestehende Personen bleibt nur das Namensfeld', (tester) async {
    await zeige(tester, []);
    expect(find.byType(DropdownButtonFormField<PersonData>), findsNothing);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('„Ignorieren" erscheint nur, wenn es angeboten wird', (tester) async {
    await zeige(tester, [person('p1', 'Anna')]);
    expect(find.text('Ignorieren'), findsNothing);
  });

  testWidgets('„Ignorieren" liefert die entsprechende Entscheidung', (tester) async {
    PersonChoice? ergebnis;
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('de'),
      localizationsDelegates: AppTexte.localizationsDelegates,
      supportedLocales: AppTexte.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () async {
              ergebnis = await showPersonPickerDialog(
                context,
                [person('p1', 'Anna')],
                paths: paths,
                erlaubtIgnorieren: true,
              );
            },
            child: const Text('los'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('los'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ignorieren'));
    await tester.pumpAndSettle();

    expect(ergebnis, isNotNull);
    expect(ergebnis!.ignorieren, isTrue);
    expect(ergebnis!.newName, isNull);
    expect(ergebnis!.existingPersonId, isNull);
  });

  group('Die Reihe für die Pfeiltasten', () {
    FaceData g(String id, String assetId) => FaceData(
          id: id,
          assetId: assetId,
          boxX: 0,
          boxY: 0,
          boxW: 0.1,
          boxH: 0.1,
          isIgnored: false,
        );

    test('behält die Reihenfolge des Rasters bei', () {
      // Sonst spränge die Pfeiltaste scheinbar wahllos durch die Bibliothek,
      // obwohl im Raster eine klare Ordnung zu sehen ist.
      expect(
        assetReiheFuerGesichter([g('f1', 'c'), g('f2', 'a'), g('f3', 'b')]),
        ['c', 'a', 'b'],
      );
    });

    test('ein Gruppenfoto steht nur einmal in der Reihe', () {
      // Drei unbenannte Gesichter auf einem Foto sind drei Rasterkacheln,
      // aber ein einziges Foto zum Durchblättern.
      expect(
        assetReiheFuerGesichter([g('f1', 'a'), g('f2', 'a'), g('f3', 'b'), g('f4', 'a')]),
        ['a', 'b'],
      );
    });

    test('ein leeres Raster ergibt eine leere Reihe', () {
      expect(assetReiheFuerGesichter([]), isEmpty);
    });
  });
}
