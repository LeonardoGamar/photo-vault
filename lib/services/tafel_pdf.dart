/// Die Tafel zum Aufhängen: der Fächer als PDF.
///
/// Der einzige Punkt im Stammbaum, an dem das Ergebnis das Programm
/// verlässt und auf Papier weiterlebt.
///
/// Gezeichnet wird mit **derselben** Routine wie auf dem Bildschirm, nur
/// auf eine sehr viel größere Leinwand; das fertige Bild wandert in die
/// Seite. Den Fächer ein zweites Mal mit den Zeichenbefehlen der
/// PDF-Bibliothek zu bauen hätte zwei Darstellungen ergeben, die
/// auseinanderlaufen können – und die Abweichung fiele erst auf dem
/// gedruckten Blatt auf.
library;

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../db/database.dart';
import '../widgets/faecher_ansicht.dart';
import 'faechertafel.dart';

const tafelEndung = '.pdf';
const tafelEndungOhnePunkt = 'pdf';
const tafelDateiname = 'stammbaum-tafel$tafelEndung';

String mitTafelEndung(String pfad) =>
    pfad.toLowerCase().endsWith(tafelEndung) ? pfad : '$pfad$tafelEndung';

/// Kantenlänge der gerenderten Zeichnung in Pixeln.
///
/// 2400 Pixel auf einer A3-Breite ergeben rund 200 dpi – genug, dass die
/// Namen auf einem Meter Abstand sauber stehen, und klein genug, dass die
/// Datei ein paar Megabyte bleibt. Die Zeichnung entsteht in einem Zug im
/// Speicher; ein größerer Wert kostet quadratisch.
const _tafelPixel = 2400;

/// Baut das PDF und gibt seine Bytes zurück.
///
/// [farben] kommt aus dem laufenden Thema. Für den Druck wird daraus
/// bewusst die **helle** Fassung genommen: Eine Tafel auf schwarzem Grund
/// verbraucht eine Tonerkassette und liest sich an der Wand schlechter.
Future<Uint8List> baueTafelPdf({
  required List<Fachplatz> plaetze,
  required Map<String, PersonData> personen,
  required String titel,
  required ColorScheme farben,
  required TextDirection textRichtung,
}) async {
  final bild = await _zeichneFaecher(
    plaetze: plaetze,
    personen: personen,
    titel: titel,
    farben: _druckfarben(farben),
    textRichtung: textRichtung,
  );
  final png = await bild.toByteData(format: ui.ImageByteFormat.png);
  bild.dispose();

  final dokument = pw.Document();
  final grafik = pw.MemoryImage(png!.buffer.asUint8List());
  dokument.addPage(
    pw.Page(
      // Querformat: Ein Fächer ist doppelt so breit wie hoch.
      pageFormat: PdfPageFormat.a3.landscape,
      // Die Seite enthält nur das Bild – auch die Überschrift steckt
      // darin. Grund ist die Schrift: Die eingebauten PDF-Schriften
      // können kein Unicode („Helvetica has no Unicode support“), ein
      // Name wie „Müller“ käme zerstört heraus. Flutters Textsatz kann
      // es, also wird auch die Überschrift dort gezeichnet – und
      // nebenbei bleibt es bei einer einzigen Zeichenroutine.
      build: (kontext) => pw.Center(child: pw.Image(grafik)),
    ),
  );
  return dokument.save();
}

/// Ein helles Farbschema für den Druck, abgeleitet aus dem der App.
///
/// Nicht einfach `buildLightTheme()` benutzt: Diese Datei soll nichts vom
/// Aufbau der Oberfläche wissen müssen, und für eine Tafel genügen
/// Schwarz auf Weiß mit einem Akzent für die Person in der Mitte.
ColorScheme _druckfarben(ColorScheme vorlage) => ColorScheme.fromSeed(
      seedColor: vorlage.primary,
      brightness: Brightness.light,
    );

Future<ui.Image> _zeichneFaecher({
  required List<Fachplatz> plaetze,
  required Map<String, PersonData> personen,
  required String titel,
  required ColorScheme farben,
  required TextDirection textRichtung,
}) async {
  const breite = _tafelPixel * 1.0;
  const kopfhoehe = 140.0;
  // Ein Halbkreis ist halb so hoch wie breit; dazu der Kopfbereich und
  // etwas Luft für die Beschriftung am äußeren Rand.
  const hoehe = breite / 2 + kopfhoehe + 40;
  final ringe = plaetze.fold(0, (m, p) => p.ring > m ? p.ring : m);
  const radius = breite / 2 - 20;
  final ringBreite = radius / (ringe + 1);
  const mitte = Offset(breite / 2, hoehe - 20);

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, breite, hoehe));
  canvas.drawRect(
    const Rect.fromLTWH(0, 0, breite, hoehe),
    Paint()..color = farben.surface,
  );
  final ueberschrift = TextPainter(
    text: TextSpan(
      text: titel,
      style: TextStyle(color: farben.onSurface, fontSize: 64),
    ),
    textAlign: TextAlign.center,
    textDirection: textRichtung,
    maxLines: 1,
    ellipsis: '…',
  )..layout(maxWidth: breite - 80);
  ueberschrift.paint(
      canvas, Offset((breite - ueberschrift.width) / 2, kopfhoehe / 2 - 32));
  ueberschrift.dispose();

  maleFaecher(
    canvas: canvas,
    plaetze: plaetze,
    personen: personen,
    mitte: mitte,
    ringBreite: ringBreite,
    farben: farben,
    textRichtung: textRichtung,
    schriftFaktor: ringBreite / 90,
  );
  final aufzeichnung = recorder.endRecording();
  try {
    return await aufzeichnung.toImage(breite.round(), hoehe.round());
  } finally {
    // Die Aufzeichnung hält alle Zeichenbefehle der 2400-Pixel-Tafel im
    // Speicher der Grafikschicht. Nach dem Ausrastern wird sie nicht mehr
    // gebraucht.
    aufzeichnung.dispose();
  }
}
