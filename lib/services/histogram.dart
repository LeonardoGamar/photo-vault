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
  final longEdge = image.width > image.height ? image.width : image.height;
  final scale = longEdge > _targetLongEdge ? _targetLongEdge / longEdge : 1.0;
  final sampled = scale < 1.0
      ? img.copyResize(
          image,
          width: (image.width * scale).round().clamp(1, image.width),
          height: (image.height * scale).round().clamp(1, image.height),
          interpolation: img.Interpolation.average,
        )
      : image;

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
