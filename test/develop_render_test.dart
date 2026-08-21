import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:photo_vault/services/develop_render.dart';
import 'package:photo_vault/services/native_image_converter.dart';

/// Der Shader war bisher nur für die Live-Vorschau da; das gespeicherte
/// Ergebnis kam vom nativen Renderpfad. Wo es den nicht gibt – Linux,
/// Windows – wirkten die Entwickeln-Regler auf gar nichts (siehe
/// docs/plan_linux.md, Phase 3).
///
/// Diese Tests laufen auf JEDER Plattform: Sie rufen den Shader-Weg direkt
/// auf, nicht über die Plattform-Weiche. So fällt eine Änderung am Shader
/// auch auf dem Entwicklungsrechner auf und nicht erst auf der Zielmaschine.
void main() {
  late Directory temp;

  setUp(() => temp = Directory.systemTemp.createTempSync('pv_develop_'));
  tearDown(() => temp.deleteSync(recursive: true));

  /// Eine gleichmässig mittelgraue Fläche – daran lässt sich jede
  /// Helligkeitsänderung als eine Zahl ablesen.
  File legeGrau(String name, {int wert = 128, int kante = 256}) {
    final bild = img.Image(width: kante, height: kante);
    img.fill(bild, color: img.ColorRgb8(wert, wert, wert));
    return File(p.join(temp.path, name))..writeAsBytesSync(img.encodePng(bild));
  }

  double mittlereHelligkeit(Uint8List jpeg) {
    final bild = img.decodeImage(jpeg)!;
    var summe = 0.0;
    var n = 0;
    for (var x = 0; x < bild.width; x += 4) {
      for (var y = 0; y < bild.height; y += 4) {
        summe += bild.getPixel(x, y).luminance;
        n++;
      }
    }
    return summe / n;
  }

  test('neutrale Einstellungen lassen das Bild, wie es ist', () async {
    final quelle = legeGrau('grau.png');

    final bytes = await DevelopRender.rendere(quelle,
        adjustments: const DevelopAdjustments());

    expect(bytes, isNotNull, reason: 'der Shader-Weg lieferte gar nichts');
    // JPEG rundet, deshalb eine kleine Toleranz – aber es muss dasselbe
    // Grau sein und nicht etwa Schwarz.
    expect(mittlereHelligkeit(bytes!), closeTo(128, 3));
  });

  test('Belichtung hellt auf, und zwar in der richtigen Grössenordnung', () async {
    final quelle = legeGrau('grau.png');

    final neutral = await DevelopRender.rendere(quelle,
        adjustments: const DevelopAdjustments());
    final heller = await DevelopRender.rendere(quelle,
        adjustments: const DevelopAdjustments(exposure: 1));
    final dunkler = await DevelopRender.rendere(quelle,
        adjustments: const DevelopAdjustments(exposure: -1));

    final n = mittlereHelligkeit(neutral!);
    final h = mittlereHelligkeit(heller!);
    final d = mittlereHelligkeit(dunkler!);

    expect(h, greaterThan(n + 20), reason: '+1 EV muss sichtbar aufhellen');
    expect(d, lessThan(n - 20), reason: '-1 EV muss sichtbar abdunkeln');
    // +1 EV verdoppelt die Lichtmenge; nach der sRGB-Kennlinie landet
    // mittleres Grau (128) dabei etwa bei 180. Die Grenzen sind weit
    // genug, um Rundung zu erlauben, und eng genug, um eine Rechnung in
    // der falschen Farbraum-Domäne auffallen zu lassen.
    expect(h, inInclusiveRange(165, 195));
  });

  test('das Ergebnis behält die Maße des Ausgangsbildes', () async {
    final quelle = legeGrau('gross.png', kante: 640);

    final bytes = await DevelopRender.rendere(quelle,
        adjustments: const DevelopAdjustments(contrast: 0.3), maxDimension: 320);

    final bild = img.decodeImage(bytes!)!;
    expect(bild.width, 320);
    expect(bild.height, 320);
  });

  test('eine Maske wirkt nur dort, wo sie deckt', () async {
    final quelle = legeGrau('grau.png', kante: 200);

    // Maske: linke Hälfte deckend, rechte Hälfte durchsichtig.
    final maske = img.Image(width: 200, height: 200, numChannels: 4);
    img.fill(maske, color: img.ColorRgba8(0, 0, 0, 0));
    img.fillRect(maske,
        x1: 0, y1: 0, x2: 99, y2: 199, color: img.ColorRgba8(255, 255, 255, 255));
    final maskeDatei = File(p.join(temp.path, 'maske.png'))
      ..writeAsBytesSync(img.encodePng(maske));

    final bytes = await DevelopRender.rendere(
      quelle,
      adjustments: const DevelopAdjustments(),
      masks: [
        MaskAdjustmentLayer(
          maskFilePath: maskeDatei.path,
          adjustments: const DevelopAdjustments(exposure: 1.5),
        ),
      ],
    );

    final bild = img.decodeImage(bytes!)!;
    final links = bild.getPixel(40, 100).luminance;
    final rechts = bild.getPixel(160, 100).luminance;

    expect(links, greaterThan(rechts + 30),
        reason: 'die Maskenwirkung ist über das ganze Bild gelaufen');
    expect(rechts, closeTo(128, 6), reason: 'ausserhalb der Maske unverändert');
  });

  test('sagt, welche Regler dieser Weg nicht umsetzt', () {
    // Ein Regler, der sich bewegen lässt und nichts tut, ist die
    // unangenehmste Art von Fehler – deshalb benennt der Dienst sie, statt
    // sie zu nähern.
    expect(DevelopRender.ohneWirkung, contains(Entwicklungsregler.schaerfe));
    expect(DevelopRender.ohneWirkung, contains(Entwicklungsregler.vignettierung));

    expect(DevelopRender.gesetztOhneWirkung(const DevelopAdjustments()), isEmpty);
    expect(
        DevelopRender.gesetztOhneWirkung(
            const DevelopAdjustments(exposure: 1, contrast: 0.5)),
        isEmpty,
        reason: 'diese beiden setzt der Shader sehr wohl um');
    expect(
        DevelopRender.gesetztOhneWirkung(
            const DevelopAdjustments(sharpness: 0.5, vignette: -0.3)),
        [Entwicklungsregler.schaerfe, Entwicklungsregler.vignettierung]);
  });
}
