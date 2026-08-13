import 'dart:math' as math;
import 'dart:typed_data';

import 'clip_service.dart';

/// Ursprüngliches, festes Vokabular deutscher Alltagsbegriffe für
/// automatisches KI-Tagging – dient seit der Einführung eines editierbaren
/// Vokabulars (Einstellungen → KI-Tagging-Vokabular, Tabelle
/// `AiTagVocabulary`) nur noch als Startbestückung für die Migration auf
/// Schema v24 (siehe `AppDatabase._seedAiTagVocabulary`). Bewusst kein
/// zusätzliches, dediziertes Tagging-Modell: stattdessen wird das ohnehin
/// für die KI-Bildsuche installierte CLIP-Modell per Zero-Shot-
/// Klassifikation wiederverwendet (siehe [AiTaggingService]).
const List<String> defaultAiTagVocabulary = [
  'Baby', 'Kleinkind', 'Kind', 'Familie', 'Gruppe von Menschen', 'Porträt', 'Selfie',
  'Draußen', 'Drinnen', 'Natur', 'Wald', 'Berge', 'Strand', 'Meer', 'See', 'Fluss',
  'Garten', 'Spielplatz', 'Stadt', 'Straße', 'Zuhause',
  'Essen', 'Kuchen', 'Geburtstagstorte', 'Restaurant',
  'Tier', 'Hund', 'Katze', 'Vogel',
  'Auto', 'Fahrrad', 'Zug', 'Flugzeug', 'Boot',
  'Feier', 'Geburtstag', 'Weihnachten', 'Ostern', 'Urlaub', 'Hochzeit',
  'Schnee', 'Winter', 'Sommer', 'Herbst', 'Frühling', 'Sonnenuntergang', 'Nacht',
  'Blumen', 'Sport', 'Schwimmen', 'Wasser',
  'Bildschirmfoto', 'Dokument', 'Bauwerk', 'Kunst', 'Gruppenfoto',
];

/// Ordnet einem Foto (über sein bereits berechnetes CLIP-Bild-Embedding)
/// automatisch Tags aus dem in den Einstellungen editierbaren Vokabular
/// (Tabelle `AiTagVocabulary`, siehe `AppDatabase.aiTagVocabularyTerms`) zu –
/// per Zero-Shot-Klassifikation: für jeden Begriff wird einmalig ein
/// CLIP-Text-Embedding berechnet (danach im Speicher gecacht) und dessen
/// Kosinus-Ähnlichkeit zum Bild-Embedding geprüft. Kein zusätzlicher
/// Modell-Download, keine zusätzliche Bild-Inferenz nötig – die
/// Bild-Embeddings liegen für jedes Foto ohnehin schon vor (siehe
/// LibraryState._postProcessNewAsset).
///
/// Die zugewiesenen Tags landen in denselben Tabellen wie manuell vergebene
/// Tags und lassen sich in der Info-Ansicht eines Fotos genauso entfernen
/// oder ergänzen – es gibt bewusst keine Unterscheidung "KI" vs. "manuell"
/// in der Datenbank, um das Datenmodell einfach zu halten.
class AiTaggingService {
  AiTaggingService(this._clip);

  final ClipService _clip;

  /// Pro-Begriff-Cache statt einer "alles oder nichts"-Vorberechnung: da
  /// sich das Vokabular jetzt zur Laufzeit ändern kann (Hinzufügen/Entfernen
  /// einzelner Begriffe in den Einstellungen), würde ein einmalig gefüllter
  /// Gesamt-Cache bei jeder Änderung ungültig. Entfernte Begriffe bleiben
  /// harmlos im Cache zurück (wenige Dutzend kurze Vektoren, vernachlässigbar).
  final Map<String, Float32List> _termEmbeddingCache = {};

  /// Liefert alle Begriffe aus [vocabulary], deren Kosinus-Ähnlichkeit zum
  /// gegebenen Bild-Embedding mindestens [threshold] beträgt. Der Standard
  /// orientiert sich an typischen CLIP-Zero-Shot-Ähnlichkeiten (deutlich
  /// niedriger als bei Gesichts-Embeddings üblich) – bewusst eher
  /// zurückhaltend gewählt, um zu viele falsche Tags zu vermeiden; ein
  /// zugewiesener Tag lässt sich in der Info-Ansicht jederzeit wieder
  /// entfernen.
  Future<List<String>> suggestTags(
    Float32List imageEmbedding,
    List<String> vocabulary, {
    double threshold = 0.24,
  }) async {
    final matches = <String>[];
    for (final term in vocabulary) {
      final embedding = _termEmbeddingCache[term] ??= await _clip.embedText(term);
      if (_cosine(imageEmbedding, embedding) >= threshold) matches.add(term);
    }
    return matches;
  }

  double _cosine(Float32List a, Float32List b) {
    var dot = 0.0;
    final len = math.min(a.length, b.length);
    for (var i = 0; i < len; i++) {
      dot += a[i] * b[i];
    }
    return dot; // beide Vektoren sind bereits L2-normalisiert
  }
}
