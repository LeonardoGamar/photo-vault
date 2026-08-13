import 'dart:convert';
import 'dart:io';

/// Wandelt die Token-ID-Ausgabe des KI-Bildbeschreibungs-Decoders
/// (`captioning_service.dart`, Standard-GPT-2-Byte-Level-BPE) zurück in
/// lesbaren Text. Reine Decode-Richtung – im Unterschied zu
/// [ClipTokenizer] (der Text in Such-Anfragen encodiert) wird hier nie
/// neuer Text tokenisiert, daher genügt die ID→Token-Rückrichtung aus
/// `vocab.json`; `merges.txt` (nur für die BPE-Merge-Anwendung beim
/// Encodieren nötig) wird bewusst nicht mitgeliefert/geladen.
class CaptionTokenizer {
  CaptionTokenizer._(this._idToToken);

  final Map<int, String> _idToToken;

  /// `<|endoftext|>` – bei diesem Modell zugleich Start- UND Ende-Token.
  static const endOfTextId = 50256;

  static Future<CaptionTokenizer> loadFromFile(String vocabJsonPath) async {
    final vocabRaw = jsonDecode(await File(vocabJsonPath).readAsString()) as Map<String, dynamic>;
    final idToToken = <int, String>{for (final entry in vocabRaw.entries) entry.value as int: entry.key};
    return CaptionTokenizer._(idToToken);
  }

  /// Baut die Unicode->Byte-Zuordnung, die GPT-2 zum Kodieren beliebiger
  /// Bytes als druckbare Zeichen verwendet – hier in umgekehrter Richtung
  /// gebraucht, um die vom Modell erzeugten Token-Strings zurück in
  /// UTF-8-Bytes zu übersetzen (dieselbe Tabelle wie
  /// `ClipTokenizer._buildByteEncoder()`, nur invertiert; hier bewusst als
  /// eigene kleine Kopie statt gemeinsamer Abstraktion, um den
  /// funktionierenden Encode-Pfad von `ClipTokenizer` nicht anzufassen).
  static Map<String, int> _buildUnicodeToByteDecoder() {
    final bs = <int>[
      ...List.generate('~'.codeUnitAt(0) - '!'.codeUnitAt(0) + 1, (i) => '!'.codeUnitAt(0) + i),
      ...List.generate('¬'.codeUnitAt(0) - '¡'.codeUnitAt(0) + 1, (i) => '¡'.codeUnitAt(0) + i),
      ...List.generate('ÿ'.codeUnitAt(0) - '®'.codeUnitAt(0) + 1, (i) => '®'.codeUnitAt(0) + i),
    ];
    final bsSet = bs.toSet();
    final cs = List<int>.from(bs);
    var n = 0;
    for (var b = 0; b < 256; b++) {
      if (!bsSet.contains(b)) {
        bs.add(b);
        cs.add(256 + n);
        n++;
      }
    }
    return {for (var i = 0; i < bs.length; i++) String.fromCharCode(cs[i]): bs[i]};
  }

  static final Map<String, int> _unicodeToByte = _buildUnicodeToByteDecoder();

  /// Wandelt eine Folge generierter Token-IDs in den fertigen Caption-Text
  /// um. Überspringt [endOfTextId] (Start-/Ende-Marker) an beliebiger
  /// Stelle statt nur am Rand, damit ein versehentlich mittendrin
  /// erzeugtes End-Token die restliche Dekodierung nicht zerstört.
  String decode(List<int> ids) {
    final buffer = StringBuffer();
    for (final id in ids) {
      if (id == endOfTextId) continue;
      final token = _idToToken[id];
      if (token == null) continue;
      buffer.write(token);
    }

    final bytes = <int>[];
    for (final ch in buffer.toString().runes) {
      final byte = _unicodeToByte[String.fromCharCode(ch)];
      if (byte != null) bytes.add(byte);
    }
    return utf8.decode(bytes, allowMalformed: true);
  }
}
