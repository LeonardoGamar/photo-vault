/// Kacheln holen und in ein Höhengitter samt Kartenbild verwandeln.
///
/// Getrennt von `gelaendekacheln.dart`, weil dort nur gerechnet wird:
/// Jede Umrechnung lässt sich ohne Netz prüfen, und was hier steht,
/// braucht beides – einen Server und `dart:ui`.
///
/// **Die Karte gehört dazu.** Geländehöhen sind keine Karte: Ohne die
/// Kartenkacheln darüber sieht man Berge ohne Wege, und eine Wanderung
/// vor einer namenlosen Landschaft beantwortet keine Frage. Deshalb holt
/// dieser Dienst beides und legt das eine als Textur auf das andere.
library;

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:http/http.dart' as http;

import '../widgets/mini_location_map.dart' show Kartenstil;
import 'gelaendekacheln.dart';

/// Wie lange auf eine einzelne Kachel gewartet wird.
///
/// Acht Sekunden. Eine Landschaft, die auf die letzte von sechzehn
/// Kacheln unbegrenzt wartet, erscheint nie.
const Duration gelaendeZeitgrenze = Duration(seconds: 8);

/// Holt die Geländehöhen für einen Ausschnitt.
///
/// Fehlende oder fehlerhafte Kacheln werden **übersprungen**, nicht als
/// Fehler behandelt: Fünfzehn von sechzehn Kacheln ergeben eine
/// Landschaft mit einem Loch, null Kacheln ergeben nichts. Kommt keine
/// einzige an, ist das Ergebnis `null`.
Future<Hoehengitter?> ladeHoehengitter({
  required double sued,
  required double west,
  required double nord,
  required double ost,
  required http.Client netz,
  int hoechstensKacheln = 16,
  int hoechsteStufe = gelaendeHoechsteStufe,
}) async {
  final bereich = kachelbereich(
    sued: sued,
    west: west,
    nord: nord,
    ost: ost,
    hoechstensKacheln: hoechstensKacheln,
    hoechsteStufe: hoechsteStufe,
  );
  final adressen = kacheladressen(bereich);

  final bilder = await Future.wait([
    for (final a in adressen) _holeKachel(netz, a.z, a.x, a.y),
  ]);
  final da = [
    for (final b in bilder)
      if (b != null) b,
  ];
  if (da.isEmpty) return null;

  return gitterAusKacheln(
    zoom: bereich.zoom,
    x0: bereich.x0,
    y0: bereich.y0,
    x1: bereich.x1,
    y1: bereich.y1,
    kacheln: da,
  );
}

Future<Kachelbild?> _holeKachel(http.Client netz, int z, int x, int y) async {
  try {
    final antwort = await netz
        .get(Uri.parse(kacheladresse(z, x, y)))
        .timeout(gelaendeZeitgrenze);
    if (antwort.statusCode != 200) return null;
    final rgba = await _nachRgba(antwort.bodyBytes);
    return rgba == null ? null : (x: x, y: y, rgba: rgba);
  } catch (_) {
    // Eine einzelne Kachel darf ausfallen, ohne die Landschaft
    // mitzunehmen.
    return null;
  }
}

Future<Uint8List?> _nachRgba(Uint8List png) async {
  final codec = await ui.instantiateImageCodec(png);
  try {
    final bild = (await codec.getNextFrame()).image;
    try {
      final daten =
          await bild.toByteData(format: ui.ImageByteFormat.rawRgba);
      return daten?.buffer.asUint8List();
    } finally {
      bild.dispose();
    }
  } finally {
    codec.dispose();
  }
}

/// Holt dieselben Kacheln als Kartenbild – die Textur für das Gelände.
///
/// Genau derselbe Ausschnitt und dieselbe Stufe wie beim Höhengitter,
/// sonst läge die Karte verschoben auf der Landschaft.
Future<ui.Image?> ladeKartenbild({
  required double sued,
  required double west,
  required double nord,
  required double ost,
  required http.Client netz,
  Kartenstil stil = Kartenstil.topo,
  int hoechstensKacheln = 16,
  int hoechsteStufe = gelaendeHoechsteStufe,
}) async {
  final bereich = kachelbereich(
    sued: sued,
    west: west,
    nord: nord,
    ost: ost,
    hoechstensKacheln: hoechstensKacheln,
    // OpenTopoMap rendert nur bis 17; die Geländekacheln hören bei 15
    // auf. Es ist also dieselbe Stufe – aber die Grenze steht hier
    // trotzdem, damit ein Wechsel der Höhenquelle die Karte nicht
    // sprengt.
    hoechsteStufe: hoechsteStufe,
  );
  final adressen = kacheladressen(bereich);

  final bilder = await Future.wait([
    for (final a in adressen) _holeKartenkachel(netz, stil, a.z, a.x, a.y),
  ]);
  if (bilder.every((b) => b == null)) return null;

  final sammler = ui.PictureRecorder();
  final leinwand = ui.Canvas(sammler);
  final spalten = bereich.x1 - bereich.x0 + 1;
  final zeilen = bereich.y1 - bereich.y0 + 1;
  for (var i = 0; i < adressen.length; i++) {
    final bild = bilder[i];
    if (bild == null) continue;
    final sx = (adressen[i].x - bereich.x0) * kachelKante.toDouble();
    final sy = (adressen[i].y - bereich.y0) * kachelKante.toDouble();
    leinwand.drawImageRect(
      bild,
      ui.Rect.fromLTWH(
          0, 0, bild.width.toDouble(), bild.height.toDouble()),
      ui.Rect.fromLTWH(
          sx, sy, kachelKante.toDouble(), kachelKante.toDouble()),
      ui.Paint(),
    );
    bild.dispose();
  }
  final bild = await sammler
      .endRecording()
      .toImage(spalten * kachelKante, zeilen * kachelKante);
  return bild;
}

Future<ui.Image?> _holeKartenkachel(
    http.Client netz, Kartenstil stil, int z, int x, int y) async {
  final vorlage = stil.kachelUrl
      .replaceAll('{s}',
          stil.unterbereiche.isEmpty ? '' : stil.unterbereiche.first)
      .replaceAll('{r}', '');
  try {
    final antwort = await netz
        .get(
          Uri.parse(kacheladresse(z, x, y, vorlage: vorlage)),
          // OpenTopoMap bittet ausdrücklich um eine aussagekräftige
          // Kennung statt der Vorgabe der Bibliothek.
          headers: const {'User-Agent': 'com.example.photoVault'},
        )
        .timeout(gelaendeZeitgrenze);
    if (antwort.statusCode != 200) return null;
    final codec = await ui.instantiateImageCodec(antwort.bodyBytes);
    try {
      return (await codec.getNextFrame()).image;
    } finally {
      codec.dispose();
    }
  } catch (_) {
    return null;
  }
}
