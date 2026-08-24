// ignore_for_file: avoid_print
// Misst von innen, was ein Modelllauf an Speicher kostet – und vor allem,
// ob wiederholte Läufe weiter wachsen.
//
// Von aussen betrachtet sieht das Verhalten nach einem Leck aus: Nach dem
// ersten Lauf gibt der Prozess nur einen Teil zurück. Das ist keins. Weder
// glibc noch der Zuteiler von ONNX Runtime geben freie Seiten sofort ans
// Betriebssystem zurück; sie behalten sie für den nächsten Lauf. Der
// Unterschied zeigt sich erst in der Wiederholung: Ein Leck wüchse in
// jeder Runde um denselben Betrag, zurückgehaltener Speicher pendelt sich
// ein.
//
// Gemessen auf der Linux-Testmaschine (2026-08-21):
//   Runde 1: 448 MB · 2: 497 · 3: 508 · 4: 512
//   Zuwachs je Runde: +49, +11, +4 – eine konvergierende Reihe.
//   Ein anschliessender fünfter Lauf belegte 0 MB zusätzlich.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:integration_test/integration_test.dart';
import 'package:photo_vault/services/ocr_service.dart';

/// Der belegte Speicher in MB. `/proc` gibt es nur unter Linux – deshalb
/// läuft diese Datei auch nur dort.
int rssMb() {
  final zeile = File('/proc/self/status')
      .readAsLinesSync()
      .firstWhere((z) => z.startsWith('VmRSS'), orElse: () => 'VmRSS: 0 kB');
  return int.parse(zeile.split(RegExp(r'\s+'))[1]) ~/ 1024;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  test('wiederholte Modellläufe wachsen nicht weiter', () async {
    // /proc gibt es nur unter Linux, deshalb genügt hier HOME.
    final ordner = '${Platform.environment['HOME']}/ocr_modelle';
    expect(OcrService.isAvailable(ordner), isTrue,
        reason: 'Modelle fehlen unter $ordner');
    final bild =
        img.decodeImage(File('$ordner/probe_de.png').readAsBytesSync())!;

    final stand = <int>[];
    for (var runde = 1; runde <= 4; runde++) {
      final dienst = await OcrService.load(ordner);
      final text = await dienst.erkenneText(bild);
      expect(text.isNotEmpty, isTrue, reason: 'Runde $runde las nichts');
      await dienst.dispose();
      // Dem Zuteiler einen Moment lassen, Seiten zurückzugeben.
      await Future<void>.delayed(const Duration(seconds: 2));
      stand.add(rssMb());
      print('nach Runde $runde: ${stand.last} MB');
    }

    final spaeterZuwachs = stand[3] - stand[1];
    print('Zuwachs über die letzten zwei Runden: $spaeterZuwachs MB');

    // Der Kern: Zwei weitere vollständige Runden dürfen zusammen weniger
    // kosten als ein einzelnes Laden der Modelle (rund 50 MB). Liefe je
    // Runde derselbe Betrag weg, wären es hier rund 100 MB – und bei
    // achttausend Fotos das Ende.
    //
    // Nicht geprüft wird, ob der Zuwachs von Runde zu Runde monoton
    // abnimmt: Bei diesen kleinen Beträgen schwankt die Messung zwischen
    // den Läufen stärker als der Effekt (gesehen: 5 MB, dann 15 MB).
    expect(spaeterZuwachs, lessThan(60),
        reason: 'gleichbleibender Zuwachs je Runde wäre ein Leck');
  });
}
