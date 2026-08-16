import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:photo_vault/services/model_catalog.dart';
import 'package:photo_vault/services/model_download_service.dart';

/// Der Modellordner wächst schnell auf über ein Gigabyte, ohne dass die App
/// das bisher irgendwo auswies. Diese Zahlen speisen die Anzeige in den
/// Einstellungen.
void main() {
  late Directory dir;
  late ModelDownloadService dienst;
  late ModelCatalogEntry eintrag;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('pv_groesse_');
    dienst = ModelDownloadService(dir.path);
    eintrag = ModelCatalog.all.first;
  });
  tearDown(() => dir.deleteSync(recursive: true));

  void lege(String name, int bytes) =>
      File('${dir.path}/$name').writeAsBytesSync(List.filled(bytes, 0));

  test('nicht installiert ergibt null Bytes', () {
    expect(dienst.belegteBytes(eintrag), 0);
    expect(dienst.isEntryInstalled(eintrag), isFalse);
  });

  test('zählt alle Dateien eines Eintrags zusammen', () {
    var erwartet = 0;
    for (var i = 0; i < eintrag.files.length; i++) {
      final groesse = 1000 * (i + 1);
      lege(eintrag.files[i].fileName, groesse);
      erwartet += groesse;
    }
    expect(dienst.belegteBytes(eintrag), erwartet);
  });

  test('eine fehlende Datei zählt als null, der Rest weiterhin mit', () {
    // Nur die erste Datei anlegen – ein halb installierter Eintrag.
    lege(eintrag.files.first.fileName, 4096);
    expect(dienst.belegteBytes(eintrag), 4096);
    expect(dienst.isEntryInstalled(eintrag), eintrag.files.length == 1);
  });

  test('die Gesamtsumme erfasst auch Dateien ausserhalb des Katalogs', () {
    lege(eintrag.files.first.fileName, 2048);
    lege('uraltes_modell.onnx', 5000);
    expect(dienst.gesamteBytes(), 7048,
        reason: 'sonst unterschlüge die Anzeige gerade die Altlasten, '
            'wegen derer man nachsieht');
  });

  test('ein fehlender Ordner ergibt null statt eines Fehlers', () {
    final weg = ModelDownloadService('${dir.path}/gibtesnicht');
    expect(weg.gesamteBytes(), 0);
    expect(weg.belegteBytes(eintrag), 0);
  });
}
