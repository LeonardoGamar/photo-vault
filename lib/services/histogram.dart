import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Anzahl der Tonwertstufen pro Kanal (8 Bit).
const histogramBinCount = 256;

/// Tonwertverteilung eines Bildes: je ein Zähler pro Tonwertstufe (0–255)
/// für die wahrgenommene Helligkeit sowie für die drei Farbkanäle.
///
/// Die Listen haben immer exakt [histogramBinCount] Einträge; der Wert an
/// Index i ist die Anzahl der Pixel mit dem Tonwert i in diesem Kanal.
class HistogramData {
  final List<int> luminance;
  final List<int> red;
  final List<int> green;
  final List<int> blue;

  /// Anzahl der ausgewerteten Pixel (nach dem Herunterskalieren, siehe
  /// [computeHistogram]) – nicht die Pixelzahl des Originalfotos.
  final int sampleCount;

  const HistogramData({
    required this.luminance,
    required this.red,
    required this.green,
    required this.blue,
    required this.sampleCount,
  });

  /// Leeres Histogramm (alle Zähler 0) – für den Zustand "noch nichts
  /// berechnet", damit die Anzeige nicht mit null umgehen muss.
  factory HistogramData.empty() => HistogramData(
        luminance: List<int>.filled(histogramBinCount, 0),
        red: List<int>.filled(histogramBinCount, 0),
        green: List<int>.filled(histogramBinCount, 0),
        blue: List<int>.filled(histogramBinCount, 0),
        sampleCount: 0,
      );

  bool get isEmpty => sampleCount == 0;

  /// Höchster Zählerstand über die gewählten Kanäle – Bezugsgröße zum
  /// Normieren der Balkenhöhen beim Zeichnen.
  int peakOf(List<List<int>> channels) {
    var peak = 0;
    for (final channel in channels) {
      for (final value in channel) {
        if (value > peak) peak = value;
      }
    }
    return peak;
  }
}

/// Zielgröße der längsten Kante vor der Auswertung. Ein Histogramm ist eine
/// Verteilung – eine gleichmäßige Stichprobe liefert praktisch dieselbe Form
/// wie das Vollbild, aber in Bruchteilen der Zeit. Muster: der identische
/// Ansatz in computeBlurScore (blur_detection.dart).
const _targetLongEdge = 512;

/// Verkleinert [image] auf [_targetLongEdge] – gemeinsam für Histogramm und
/// Waveform, damit beide dieselbe Grundlage haben.
img.Image _stichprobe(img.Image image) {
  final longEdge = image.width > image.height ? image.width : image.height;
  final scale = longEdge > _targetLongEdge ? _targetLongEdge / longEdge : 1.0;
  if (scale >= 1.0) return image;
  return img.copyResize(
    image,
    width: (image.width * scale).round().clamp(1, image.width),
    height: (image.height * scale).round().clamp(1, image.height),
    interpolation: img.Interpolation.average,
  );
}

/// Berechnet die Tonwertverteilung von [image].
///
/// Reine, isolate-taugliche Funktion (kein Zugriff auf Widgets/Plugins),
/// damit sie über `compute()` aus dem UI-Thread ausgelagert werden kann.
///
/// Der Helligkeitswert folgt der Rec.-601-Luma-Gewichtung
/// (0,299 R + 0,587 G + 0,114 B) statt eines simplen Mittelwerts der drei
/// Kanäle: Grün trägt für das menschliche Auge deutlich mehr zur
/// empfundenen Helligkeit bei als Blau, ein ungewichteter Mittelwert würde
/// die Verteilung entsprechend verzerren. Dieselbe Gewichtung nutzt auch
/// `img.grayscale` des image-Pakets.
HistogramData computeHistogram(img.Image image) {
  final sampled = _stichprobe(image);

  final luminance = List<int>.filled(histogramBinCount, 0);
  final red = List<int>.filled(histogramBinCount, 0);
  final green = List<int>.filled(histogramBinCount, 0);
  final blue = List<int>.filled(histogramBinCount, 0);

  for (final pixel in sampled) {
    // Bilder mit anderer Bittiefe (z.B. 16 Bit pro Kanal aus manchen
    // TIFF/PNG-Dateien) liefern hier Werte über 255 – auf 8 Bit
    // normalisieren, sonst läge der Index außerhalb der Liste.
    final maxValue = pixel.maxChannelValue;
    final factor = maxValue > 0 ? 255.0 / maxValue : 1.0;
    final r = (pixel.r * factor).round().clamp(0, 255);
    final g = (pixel.g * factor).round().clamp(0, 255);
    final b = (pixel.b * factor).round().clamp(0, 255);

    red[r]++;
    green[g]++;
    blue[b]++;
    luminance[(0.299 * r + 0.587 * g + 0.114 * b).round().clamp(0, 255)]++;
  }

  return HistogramData(
    luminance: luminance,
    red: red,
    green: green,
    blue: blue,
    sampleCount: sampled.width * sampled.height,
  );
}

/// Obergrenze für die Spaltenzahl einer Waveform.
///
/// Nicht die Bildbreite: Die Anzeige ist ein paar hundert Punkte breit, und
/// jede Spalte ist ohnehin eine Zusammenfassung.
///
/// Die tatsächliche Zahl ist das Kleinere aus dieser Grenze und der Breite
/// der Stichprobe. Fest 256 zu nehmen wäre falsch: Ein schmales Bild füllt
/// dann nur jede zweite oder dritte Spalte, und die Waveform bekäme
/// senkrechte Lücken, die wie Bildinhalt aussähen.
const waveformMaxColumns = 256;

/// Die Tonwertverteilung **je Bildspalte** – die Datengrundlage für
/// Waveform und RGB-Parade.
///
/// Jede Kanalliste hat [waveformColumnCount] Einträge, jeder davon
/// [histogramBinCount] Zähler: `luminance[x][t]` ist die Anzahl der Pixel
/// in Bildspalte x mit dem Tonwert t.
///
/// Das ist ausdrücklich **nicht** dasselbe wie ein Histogramm anders
/// gezeichnet: Ein Histogramm zählt über das ganze Bild und wirft dabei die
/// Position weg. Eine Waveform braucht sie – ohne x-Achse gäbe es nichts zu
/// zeichnen. Gemeinsam ist beiden nur die Stichprobe.
class WaveformData {
  final List<List<int>> luminance;
  final List<List<int>> red;
  final List<List<int>> green;
  final List<List<int>> blue;

  /// Höchster Zählerstand über alle Spalten und Kanäle – Bezugsgröße für
  /// die Helligkeit beim Zeichnen.
  final int peak;

  const WaveformData({
    required this.luminance,
    required this.red,
    required this.green,
    required this.blue,
    required this.peak,
  });

  /// Wie viele Spalten diese Auswertung hat.
  int get columnCount => luminance.length;

  factory WaveformData.empty() {
    List<List<int>> leer() => List.generate(
        waveformMaxColumns, (_) => List<int>.filled(histogramBinCount, 0));
    return WaveformData(
      luminance: leer(),
      red: leer(),
      green: leer(),
      blue: leer(),
      peak: 0,
    );
  }

  bool get isEmpty => peak == 0;
}

/// Berechnet die Waveform von [image].
///
/// Dieselbe Stichprobe wie [computeHistogram] – ein Bild auf 512 Pixel
/// längster Kante liefert praktisch dieselbe Form wie das Vollbild.
WaveformData computeWaveform(img.Image image) {
  final sampled = _stichprobe(image);
  final spalten =
      sampled.width < waveformMaxColumns ? sampled.width : waveformMaxColumns;

  List<List<int>> leer() =>
      List.generate(spalten, (_) => List<int>.filled(histogramBinCount, 0));
  final luminance = leer(), red = leer(), green = leer(), blue = leer();

  for (final pixel in sampled) {
    final maxValue = pixel.maxChannelValue;
    final factor = maxValue > 0 ? 255.0 / maxValue : 1.0;
    final r = (pixel.r * factor).round().clamp(0, 255);
    final g = (pixel.g * factor).round().clamp(0, 255);
    final b = (pixel.b * factor).round().clamp(0, 255);

    // Die Bildspalte auf eine Anzeigespalte abbilden.
    final x = spalten <= 1
        ? 0
        : (pixel.x * spalten ~/ sampled.width).clamp(0, spalten - 1);

    red[x][r]++;
    green[x][g]++;
    blue[x][b]++;
    luminance[x][(0.299 * r + 0.587 * g + 0.114 * b).round().clamp(0, 255)]++;
  }

  var peak = 0;
  for (final spalte in luminance) {
    for (final wert in spalte) {
      if (wert > peak) peak = wert;
    }
  }
  return WaveformData(
    luminance: luminance,
    red: red,
    green: green,
    blue: blue,
    peak: peak,
  );
}

/// Histogramm und Waveform in einem Zug.
class BildAuswertung {
  final HistogramData histogramm;
  final WaveformData waveform;
  const BildAuswertung(this.histogramm, this.waveform);
}

/// Dekodiert [bytes] und berechnet Histogramm UND Waveform.
///
/// Beides gemeinsam und nicht in zwei Aufrufen: Das Dekodieren ist der
/// teure Teil, und es zweimal zu machen wäre die Hälfte der Arbeit
/// umsonst. Ausserdem entstünden bei getrennten Läufen zwei Stände, die
/// beim schnellen Reglerziehen zu verschiedenen Vorschauen gehören
/// könnten.
BildAuswertung? computeBildAuswertung(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return null;
  return BildAuswertung(computeHistogram(decoded), computeWaveform(decoded));
}

/// Dekodiert [bytes] und berechnet daraus die Tonwertverteilung – eine
/// einzige `compute()`-taugliche Funktion, damit Dekodieren UND Auswerten
/// gemeinsam im Hintergrund-Isolate landen (die Vorschau im Entwickeln-
/// Screen liegt als JPEG-Bytes vor, nicht als fertiges img.Image).
///
/// Gibt `null` zurück, wenn sich [bytes] nicht dekodieren lassen.
HistogramData? computeHistogramFromBytes(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return null;
  return computeHistogram(decoded);
}
