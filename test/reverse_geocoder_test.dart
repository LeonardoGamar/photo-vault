import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:photo_vault/services/reverse_geocoder.dart';

/// Prüft die lokale/offline Umkehr-Geokodierung gegen einen kleinen,
/// synthetischen GeoNames-Auszug (statt des echten ~150.000-Zeilen-
/// Datensatzes) – Format identisch zu cities1000.txt/admin1CodesASCII.txt/
/// countryInfo.txt, nur mit zwei Städten.
void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('photo_vault_geocoder_test_');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  Future<ReverseGeocoder> loadSynthetic() async {
    final citiesFile = File(p.join(tempDir.path, 'cities1000.txt'));
    // Spalten: geonameid, name, asciiname, alternatenames, lat, lon,
    // feature class, feature code, country code, cc2, admin1, admin2,
    // admin3, admin4, population, elevation, dem, timezone, mod date.
    await citiesFile.writeAsString(
      '2988507\tParis\tParis\t\t48.85661\t2.35222\tP\tPPLC\tFR\t\t11\t75\t\t\t2138551\t\t42\tEurope/Paris\t2023-05-03\n'
      '2996944\tLyon\tLyon\t\t45.76\t4.84139\tP\tPPLA\tFR\t\t84\t69\t\t\t513275\t\t189\tEurope/Paris\t2023-05-03\n',
    );

    final admin1File = File(p.join(tempDir.path, 'admin1CodesASCII.txt'));
    await admin1File.writeAsString(
      'FR.11\tÎle-de-France\tIle-de-France\t3012874\n'
      'FR.84\tAuvergne-Rhône-Alpes\tAuvergne-Rhone-Alpes\t11071619\n',
    );

    final countryFile = File(p.join(tempDir.path, 'countryInfo.txt'));
    await countryFile.writeAsString(
      '# comment line, muss übersprungen werden\n'
      'FR\tFRA\t250\tFR\tFrance\tParis\t547030\t67059887\tEU\t.fr\tEUR\tEuro\t33\t#####\t^(\\d{5})\$\tfr-FR\t3017382\tAD,BE,DE,IT,LU,MC,ES,CH\t\n',
    );

    return ReverseGeocoder.loadFromFiles(
      citiesFile: citiesFile,
      admin1File: admin1File,
      countryFile: countryFile,
    );
  }

  test('findet die nächstgelegene Stadt samt Bundesland und Land', () async {
    final geocoder = await loadSynthetic();

    final nearParis = geocoder.lookup(48.86, 2.35);
    expect(nearParis?.city, 'Paris');
    expect(nearParis?.state, 'Île-de-France');
    expect(nearParis?.country, 'France');

    final nearLyon = geocoder.lookup(45.75, 4.85);
    expect(nearLyon?.city, 'Lyon');
    expect(nearLyon?.state, 'Auvergne-Rhône-Alpes');
    expect(nearLyon?.country, 'France');
  });

  test('gibt null zurück, wenn keine Stadt im Suchradius bekannt ist', () async {
    final geocoder = await loadSynthetic();

    // Golf von Guinea (0,0) – weit von beiden Testorten in Frankreich entfernt.
    final result = geocoder.lookup(0, 0);
    expect(result, isNull);
  });

  test('gibt bei leerem Datensatz immer null zurück', () async {
    final citiesFile = File(p.join(tempDir.path, 'empty_cities.txt'))..writeAsStringSync('');
    final admin1File = File(p.join(tempDir.path, 'empty_admin1.txt'))..writeAsStringSync('');
    final countryFile = File(p.join(tempDir.path, 'empty_country.txt'))..writeAsStringSync('');

    final geocoder = await ReverseGeocoder.loadFromFiles(
      citiesFile: citiesFile,
      admin1File: admin1File,
      countryFile: countryFile,
    );

    expect(geocoder.lookup(48.86, 2.35), isNull);
  });
}
