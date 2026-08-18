import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

import '../services/ai_tagging_service.dart' show defaultAiTagVocabulary;
import '../services/embedding_codec.dart';
import '../services/exif_camera.dart';
import '../services/face_threshold.dart';
import '../services/library_location.dart';
import '../services/library_stats.dart';
import '../services/search_filters.dart';

part 'database.g.dart';

/// Ein einzelnes Foto oder Video. `relativePath`/`thumbnailRelativePath` sind
/// relativ zum Bibliotheksordner (siehe StoragePaths), damit die gesamte
/// Bibliothek portabel bleibt (z.B. beim Umzug auf einen anderen Rechner).
@DataClassName('AssetData')
class Assets extends Table {
  TextColumn get id => text()();
  TextColumn get originalFileName => text()();
  TextColumn get relativePath => text()();
  TextColumn get thumbnailRelativePath => text().nullable()();
  TextColumn get previewRelativePath => text().nullable()(); // HEIC/DNG & Co.

  /// Ergebnis der nicht-destruktiven Entwicklung (siehe DevelopSettings) –
  /// nur gesetzt, solange der Nutzer tatsächlich Anpassungen vorgenommen
  /// hat. Null bedeutet "unverändert", nicht "fehlt" – dann wird
  /// [previewRelativePath] bzw. [relativePath] angezeigt. Bewusst NICHT für
  /// Gesichtserkennung/CLIP verwendet (siehe LibraryState._decodableFile) –
  /// KI-Verarbeitung soll immer das unveränderte Bild sehen.
  TextColumn get developedRelativePath => text().nullable()();

  /// Ergebnis des nicht-destruktiven Video-Zuschnitts (siehe VideoTrims) –
  /// analog zu [developedRelativePath]: null bedeutet "unverändert", die
  /// Original-Videodatei wird nie angetastet. Für IMAGE-Assets stets null,
  /// da sich die beiden Felder gegenseitig ausschließen (ein Asset ist
  /// entweder Foto oder Video).
  TextColumn get trimmedRelativePath => text().nullable()();

  /// Ergebnis einer KI-Restaurierung (Hochskalieren/Entrauschen, siehe
  /// RestoreJobs/RestoreQueueService) – analog zu [developedRelativePath]:
  /// null bedeutet "keine Restaurierung vorhanden". Höchste Priorität in
  /// displayRelativePath (siehe asset_display_path.dart), da sie – anders
  /// als [developedRelativePath] – ein bewusst einmalig angestoßenes,
  /// abgeschlossenes Ergebnis ist, kein live nachregelbarer Zustand.
  TextColumn get restoredRelativePath => text().nullable()();
  TextColumn get checksum => text().unique()();
  TextColumn get type => text()(); // 'IMAGE' oder 'VIDEO'
  DateTimeColumn get fileCreatedAt => dateTime()();
  DateTimeColumn get importedAt => dateTime()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isTrashed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get trashedAt => dateTime().nullable()();

  /// In den gesperrten (PIN-geschützten) Ordner verschoben – solche Assets
  /// werden aus Timeline, Kalender, Karte, Suche, Alben, Personen und
  /// Backup-Export herausgefiltert und sind nur über den gesperrten Ordner
  /// (nach PIN-Eingabe) erreichbar. Siehe [PrivacySettings].
  BoolColumn get isLocked => boolean().withDefault(const Constant(false))();
  TextColumn get description => text().nullable()();
  IntColumn get widthPx => integer().nullable()();
  IntColumn get heightPx => integer().nullable()();
  RealColumn get durationSeconds => real().nullable()();
  IntColumn get fileSizeBytes => integer().withDefault(const Constant(0))();
  BoolColumn get backedUp => boolean().withDefault(const Constant(false))();

  /// Separat von [backedUp] getrackt, damit sich manuelles Backup (eigener
  /// Zielordner) und automatisches Backup (eigener Zielordner, siehe
  /// [BackupSettings]) nicht gegenseitig den "schon gesichert"-Status
  /// stehlen, wenn beide gleichzeitig genutzt werden.
  BoolColumn get autoBackedUp => boolean().withDefault(const Constant(false))();
  BoolColumn get facesScanned => boolean().withDefault(const Constant(false))();
  TextColumn get linkedAssetId => text().nullable()(); // Live-Photo-Partner (Foto<->Video)

  /// Aus EXIF-GPS-Daten übernommen (nur Fotos) oder manuell in der
  /// Info-Ansicht der Vollbildvorschau gesetzt/korrigiert. Beide null,
  /// solange kein Ort bekannt ist.
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();

  /// Kamera-/Objektiv-/Aufnahme-Angaben aus den EXIF-Daten (nur Fotos) –
  /// rein informativ für die Info-Ansicht, siehe ExifCamera.parseExifCameraInfo.
  TextColumn get cameraMake => text().nullable()();
  TextColumn get cameraModel => text().nullable()();
  TextColumn get lensModel => text().nullable()();
  RealColumn get focalLengthMm => real().nullable()();
  RealColumn get fNumber => real().nullable()();
  IntColumn get iso => integer().nullable()();
  RealColumn get exposureTimeSeconds => real().nullable()();

  /// Aus [latitude]/[longitude] abgeleitet über die lokale/offline
  /// Umkehr-Geokodierung (siehe ReverseGeocoder – nächstgelegene bekannte
  /// Stadt, keine Anfrage an einen Online-Dienst). Bleibt `null`, solange
  /// entweder kein Ort bekannt ist oder der GeoNames-Datensatz noch nicht
  /// heruntergeladen wurde.
  TextColumn get locationCountry => text().nullable()();
  TextColumn get locationState => text().nullable()();
  TextColumn get locationCity => text().nullable()();

  /// Sternebewertung 0-5 (0 = unbewertet), analog zu Photo Mechanic/
  /// Lightroom – für schnelle Sichtung großer Importstapel.
  IntColumn get rating => integer().withDefault(const Constant(0))();

  /// 'red'|'yellow'|'green'|'blue'|'purple', null = keine Markierung.
  TextColumn get colorLabel => text().nullable()();

  /// Per Vision-Framework erkannter Text im Bild (siehe ImageConverter.swift
  /// `recognizeText`), durchsuchbar über SearchTextMode.ocr.
  TextColumn get ocrText => text().nullable()();

  /// Eigenes Flag statt "ocrText == null" als "noch nicht gescannt"-Signal,
  /// da ein leerer erkannter Text (kein Text im Bild gefunden) ein gültiges
  /// Ergebnis ist – analog zu [facesScanned].
  BoolColumn get ocrScanned => boolean().withDefault(const Constant(false))();

  /// Automatisch erzeugte (englische) Bildunterschrift (siehe
  /// CaptioningService), durchsuchbar über SearchTextMode.caption. Bewusst
  /// NICHT [description] wiederverwendet – das ist Nutzer-Freitext.
  TextColumn get aiCaption => text().nullable()();

  /// Deutsche Fassung von [aiCaption] (siehe TranslationService).
  ///
  /// Als eigene Spalte, nicht als Ersatz: Das englische Original bleibt
  /// erhalten, damit ein Abschalten der Übersetzung nicht bedeutet, das
  /// Beschreibungsmodell über die ganze Bibliothek erneut laufen zu
  /// lassen. Die Suche durchsucht beide.
  TextColumn get aiCaptionDe => text().nullable()();

  /// Eigenes Flag statt "aiCaption == null" als "noch nicht erzeugt"-Signal,
  /// analog zu [ocrScanned].
  BoolColumn get aiCaptionScanned => boolean().withDefault(const Constant(false))();

  /// Eigenes Flag statt "hat keine Tags" als "noch nicht verschlagwortet"-
  /// Signal, aus demselben Grund wie [ocrScanned]: Dass CLIP zu keinem
  /// Vokabelbegriff eine ausreichende Ähnlichkeit findet, ist ein GÜLTIGES
  /// Ergebnis, kein offener Posten. Ohne dieses Flag blieben solche Fotos
  /// dauerhaft Kandidaten und die Tagging-Stufe lud bei JEDEM Programmstart
  /// beide CLIP-Encoder (577 MB), rechnete sie durch und erzeugte wieder
  /// nichts (Audit-Fund: gemessen 1066 MB Grundlast statt 214 MB).
  BoolColumn get aiTagsScanned => boolean().withDefault(const Constant(false))();

  /// Laplace-Varianz des Bilds (siehe blur_detection.dart) – höher = schärfer.
  /// Null, solange noch nicht berechnet.
  RealColumn get sharpnessScore => real().nullable()();

  /// Serien-/Burst-Gruppierung (siehe StackReviewScreen, findBurstGroups):
  /// alle Mitglieder einer Serie teilen dieselbe [stackId], analog zu
  /// [linkedAssetId] bei Live Photos. `null` = kein Stapel.
  TextColumn get stackId => text().nullable()();

  /// Genau ein Mitglied pro Stapel ist Titelbild – nur dieses erscheint in
  /// Timeline/Kalender/Karte & Co. (siehe die `stackId`/`isStackCover`-Filter
  /// dort, exakt wie bei [linkedAssetId] für Live Photos).
  BoolColumn get isStackCover => boolean().withDefault(const Constant(false))();

  /// Gesamtzahl der Fotos im Stapel – NUR auf der Titelbild-Zeile gesetzt
  /// (sonst `null`), damit die Rasteransicht die Zahl fürs Abzeichen ohne
  /// zusätzliche COUNT-Abfrage pro Kachel anzeigen kann.
  IntColumn get stackSize => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AlbumData')
class Albums extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get coverAssetId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class AlbumAssets extends Table {
  TextColumn get albumId => text()();
  TextColumn get assetId => text()();

  @override
  Set<Column> get primaryKey => {albumId, assetId};
}

@DataClassName('TagData')
class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().unique()();

  @override
  Set<Column> get primaryKey => {id};
}

class AssetTags extends Table {
  TextColumn get assetId => text()();
  TextColumn get tagId => text()();

  @override
  Set<Column> get primaryKey => {assetId, tagId};
}

/// Vorkonfigurierte Aktionen für eine bestimmte, per EXIF erkannte Kamera
/// (Hersteller + Modell) – analog zu Digikams "Kamera für den Import
/// voreinstellen". Wird bei jedem neu importierten (oder nachträglich per
/// Kameradaten-Backfill erkannten) Foto automatisch angewendet, sobald
/// cameraMake/cameraModel übereinstimmen, siehe
/// LibraryState._applyCameraPreset.
@DataClassName('CameraPresetData')
class CameraPresets extends Table {
  TextColumn get id => text()();
  TextColumn get cameraMake => text()();
  TextColumn get cameraModel => text()();
  TextColumn get targetAlbumId => text().nullable()();
  BoolColumn get autoFavorite => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class CameraPresetTags extends Table {
  TextColumn get presetId => text()();
  TextColumn get tagId => text()();

  @override
  Set<Column> get primaryKey => {presetId, tagId};
}

/// Eine benannte Ausgabe-Vorgabe für den Export – Grösse, Format, Qualität,
/// Dateibenennung und ob die XMP-Beistelldatei mitgeschrieben wird.
///
/// Bisher gab es dafür nur die feste Aufzählung `Exportgroesse` mit vier
/// Stufen. Die deckt die häufigen Fälle ab, aber nicht die
/// wiederkehrenden: „für den Fotoclub, lange Kante 2048, benannt nach
/// Aufnahmedatum" tippt man sonst jedes Mal neu zusammen.
///
/// [nachJpeg] und [maxKante] sind bewusst getrennt: Ohne [nachJpeg] wird
/// die Datei unverändert kopiert (der einzige Weg, der RAW und Videos
/// unangetastet lässt); mit [nachJpeg] wird gerendert, und [maxKante]
/// begrenzt dabei zusätzlich die längere Seite – `null` heisst dann
/// „volle Auflösung, nur neu kodiert".
@DataClassName('ExportPresetData')
class ExportPresets extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Angezeigter Name. Eindeutig, damit die Auswahlliste eindeutig bleibt.
  TextColumn get name => text().unique()();

  BoolColumn get nachJpeg => boolean().withDefault(const Constant(false))();

  /// Längere Bildkante in Pixeln; `null` = nicht begrenzen.
  IntColumn get maxKante => integer().nullable()();

  /// JPEG-Qualität 0,1 … 1,0. Ohne [nachJpeg] ohne Bedeutung.
  RealColumn get qualitaet => real().withDefault(const Constant(0.9))();

  /// Muster für den Dateinamen, siehe `export_naming.dart`.
  TextColumn get namensmuster => text().withDefault(const Constant('{name}'))();

  BoolColumn get xmpDaneben => boolean().withDefault(const Constant(true))();

  DateTimeColumn get erstelltAm => dateTime()();
}

/// Verallgemeinerung von [CameraPresets] auf andere Bedingungen als die
/// Kamera – bewusst eine eigene, zusätzliche Tabelle statt [CameraPresets]
/// zu erweitern: Kamera-Presets bleiben unverändert nutzbar (kein
/// Migrationsrisiko für bestehende Daten), und die je nach [triggerType]
/// stark unterschiedlich geformten Bedingungen (Umkreis, Datumsbereich,
/// KI-Tag) hätten als zusätzliche, meist leere Spalten auf [CameraPresets]
/// keine saubere Passform gehabt.
///
/// [triggerType] ist bewusst ein einfacher String statt eines Drift-Enums
/// (`'location'`/`'aiTag'`/`'dateRange'`) – dieselbe Konvention wie
/// [Assets.type] (`'IMAGE'`/`'VIDEO'`). Je nach Typ sind nur die
/// zugehörigen Bedingungs-Spalten gesetzt, der Rest bleibt `null` – siehe
/// LibraryState.applyAutomationRules für die Auswertung.
///
/// Zwei Auslösepunkte, weil die jeweilige Bedingung zu unterschiedlichen
/// Zeitpunkten überhaupt geprüft werden kann: `location`/`dateRange` schon
/// beim Import (GPS/Datum liegen sofort vor), `aiTag` erst nach der
/// KI-Tagging-Stufe der Hintergrundanalyse.
@DataClassName('AutomationRuleData')
class AutomationRules extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get triggerType => text()();

  // triggerType == 'location': Umkreis um einen Mittelpunkt (einfacher fürs
  // UI als eine Bounding-Box – ein Punkt + Radius-Regler).
  RealColumn get regionCenterLat => real().nullable()();
  RealColumn get regionCenterLon => real().nullable()();
  RealColumn get regionRadiusKm => real().nullable()();

  // triggerType == 'aiTag': muss exakt einem Begriff aus dem KI-Tag-
  // Vokabular entsprechen (siehe AiTagVocabulary).
  TextColumn get aiTagTerm => text().nullable()();

  // triggerType == 'dateRange': volles Datum statt wiederkehrend
  // Monat/Tag – vermeidet Jahresübergangs-Sonderfälle (z.B. "20.12.–5.1."),
  // auf Kosten dessen, dass eine wiederkehrende Regel jedes Jahr neu
  // angelegt werden muss.
  DateTimeColumn get dateFrom => dateTime().nullable()();
  DateTimeColumn get dateTo => dateTime().nullable()();

  TextColumn get targetAlbumId => text().nullable()();
  BoolColumn get autoFavorite => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class AutomationRuleTags extends Table {
  TextColumn get ruleId => text()();
  TextColumn get tagId => text()();

  @override
  Set<Column> get primaryKey => {ruleId, tagId};
}

/// Nicht-destruktive Entwicklungs-Einstellungen für ein Asset (siehe
/// DevelopScreen) – existiert nur, solange der Nutzer tatsächlich
/// Anpassungen vorgenommen hat (kein Row = "unverändert"). Ein Asset pro
/// Zeile statt zusätzlicher Spalten direkt auf [Assets], analog zu
/// [Faces]/[ImageEmbeddings] als Pro-Asset-Zusatztabelle.
@DataClassName('DevelopSettingsData')
class DevelopSettings extends Table {
  TextColumn get assetId => text()();
  RealColumn get exposure => real().withDefault(const Constant(0))(); // EV, -3..3
  RealColumn get temperature => real().nullable()(); // Kelvin, null = Kamera-Weißabgleich
  RealColumn get tint => real().nullable()(); // Grün/Magenta, null = Kamera-Weißabgleich
  RealColumn get contrast => real().withDefault(const Constant(0))(); // -1..1
  RealColumn get shadows => real().withDefault(const Constant(0))(); // -1..1
  RealColumn get sharpness => real().withDefault(const Constant(0))(); // 0..1
  RealColumn get noiseReduction => real().withDefault(const Constant(0))(); // 0..1
  BoolColumn get lensCorrectionEnabled => boolean().withDefault(const Constant(true))();

  /// JSON-kodierte [ToneCurve] bzw. [ColorMixer] (siehe develop_color.dart).
  ///
  /// Anders als die Regler darüber sind das keine einzelnen Zahlen, sondern
  /// eine Punktfolge je Kanal bzw. acht Bänder mit je drei Werten – als
  /// Spalten flachgeklopft wären das über dreissig zusätzliche Felder, die
  /// in [DevelopHistory] noch einmal aufträten. `null` bedeutet neutral;
  /// damit brauchen vorhandene Zeilen keine Migration und der Normalfall
  /// kostet zur Laufzeit nichts (siehe `ToneCurve.istNeutral`).
  TextColumn get toneCurveJson => text().nullable()();
  TextColumn get colorMixerJson => text().nullable()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {assetId};
}

/// Nicht-destruktiver Video-Zuschnitt (siehe VideoTrimScreen) – analog zu
/// [DevelopSettings]: ein Asset pro Zeile, existiert nur solange ein
/// Zuschnitt aktiv ist. Speichert Start/Ende getrennt vom eigentlichen
/// Ergebnis (`Assets.trimmedRelativePath`), damit der Zuschnitt-Editor beim
/// erneuten Öffnen wieder mit den zuletzt gewählten Grenzen startet, statt
/// bei 0/volle Länge.
@DataClassName('VideoTrimData')
class VideoTrims extends Table {
  TextColumn get assetId => text()();
  RealColumn get startSeconds => real()();
  RealColumn get endSeconds => real()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {assetId};
}

/// Vergangene, dauerhaft gespeicherte Entwickeln-Einstellungs-Stände eines
/// Assets – jeder Speichern-Vorgang im DevelopScreen schiebt den bisherigen
/// [DevelopSettings]-Stand hierher, bevor er überschrieben wird (siehe
/// AppDatabase.pushDevelopHistory), begrenzt auf die neuesten 10 Einträge
/// pro Asset. Eigene Tabelle statt Versionierung von [DevelopSettings]
/// selbst, damit "aktueller Stand" weiterhin ein einfaches 1:1-Lookup
/// bleibt (wie bei [Faces]/[ImageEmbeddings] als Pro-Asset-Zusatztabelle).
@DataClassName('DevelopHistoryData')
class DevelopHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get assetId => text()();
  RealColumn get exposure => real()();
  RealColumn get temperature => real().nullable()();
  RealColumn get tint => real().nullable()();
  RealColumn get contrast => real()();
  RealColumn get shadows => real()();
  RealColumn get sharpness => real()();
  RealColumn get noiseReduction => real()();
  BoolColumn get lensCorrectionEnabled => boolean()();

  /// Wie in [DevelopSettings] – ohne diese beiden Spalten liesse ein
  /// Verlaufs-Eintrag Kurve und Mischer stillschweigend fallen, und
  /// "Zurück zu diesem Stand" führte zu einem anderen Bild als damals.
  TextColumn get toneCurveJson => text().nullable()();
  TextColumn get colorMixerJson => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
}

/// KI-Objektmaske (siehe MaskEditor, SegmentationService): eine per SAM
/// vorhergesagte, vom Nutzer bestätigte Region eines Fotos, mit eigenen
/// Regler-Werten (nur innerhalb der Maske wirksam) – ein Asset kann mehrere
/// Masken haben (1:n), zusätzlich zu den globalen [DevelopSettings] fürs
/// ganze Bild. [maskRelativePath] zeigt auf eine kleine Graustufen-PNG-
/// Alphamaske (analog zu [Faces.cropRelativePath]), NICHT die rohen
/// SAM-Embeddings – die werden nur während der offenen Maskier-Sitzung im
/// Speicher gehalten, nie persistiert. Nimmt bewusst NICHT am
/// [DevelopHistory]-Verlauf teil (der ist auf den flachen 8-Felder-
/// Regler-Satz eines einzelnen Bildes zugeschnitten) – "Maske entfernen"
/// ist die einzige Rückgängig-Funktion für Masken.
@DataClassName('DevelopMaskData')
class DevelopMasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get assetId => text()();
  TextColumn get maskRelativePath => text()();
  TextColumn get label => text()();
  RealColumn get exposure => real().withDefault(const Constant(0))();
  RealColumn get temperature => real().nullable()();
  RealColumn get tint => real().nullable()();
  RealColumn get contrast => real().withDefault(const Constant(0))();
  RealColumn get shadows => real().withDefault(const Constant(0))();
  RealColumn get sharpness => real().withDefault(const Constant(0))();
  RealColumn get noiseReduction => real().withDefault(const Constant(0))();
  BoolColumn get lensCorrectionEnabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();

  /// JSON-kodierte [MaskShapeDefinition] (siehe vector_mask_service.dart) –
  /// `null` bedeutet eine per SAM-Punkt-Prompt erzeugte Maske (heutiges
  /// Verhalten, nicht nachträglich als Form editierbar). Ist ein Wert
  /// gesetzt, ist er die Quelle der Wahrheit für erneutes Bearbeiten;
  /// [maskRelativePath] bleibt in beiden Fällen der gerenderte Graustufen-
  /// PNG-Cache, den die native Kompositierung tatsächlich konsumiert – bei
  /// jeder Formänderung wird er neu gerendert und überschrieben.
  TextColumn get shapeDefinitionJson => text().nullable()();
}

/// Ein KI-Restaurierungs-Auftrag (siehe RestoreQueueService,
/// RestoreService) – läuft im Hintergrund, oft mehrere Minuten pro Foto
/// (echt gemessen: ~5 Min. bei 12 MP mit CoreML-Beschleunigung), daher als
/// eigene, persistierte Warteschlange statt eines blockierenden Dialogs.
/// [status] durchläuft `queued` → `running` → `done`/`failed`/`cancelled`.
/// Wird die App mitten in `running` beendet, setzt
/// [AppDatabase.resetStuckRunningRestoreJobs] beim nächsten Start auf
/// `queued` zurück (Crash-Safety, siehe LibraryState.initialize) – es
/// werden keine Teil-Kacheln persistiert, ein zurückgesetzter Job läuft
/// komplett neu.
@DataClassName('RestoreJobData')
class RestoreJobs extends Table {
  TextColumn get id => text()();
  TextColumn get assetId => text()();
  TextColumn get status => text()(); // 'queued' | 'running' | 'done' | 'failed' | 'cancelled'
  IntColumn get tilesDone => integer().withDefault(const Constant(0))();
  IntColumn get tilesTotal => integer().withDefault(const Constant(0))();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PersonData')
class People extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get coverFaceCropPath => text().nullable()();

  /// Persönliche Wiedererkennungs-Schwelle, abgeleitet aus den bisherigen
  /// Entscheidungen des Nutzers (siehe [FaceMatchFeedback] und
  /// face_threshold.dart). `null` = die allgemeine Schwelle gilt.
  ///
  /// Als gespeicherter Wert statt bei jedem Vorschlag neu gerechnet, damit
  /// die Zahl im Personen-Bildschirm dieselbe ist, nach der tatsächlich
  /// entschieden wurde – eine Schwelle, die sich zwischen Anzeige und
  /// Anwendung unterscheidet, wäre nicht erklärbar.
  RealColumn get similarityThreshold => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Eine festgehaltene Entscheidung über einen Wiedererkennungs-Vorschlag.
///
/// Bisher wurden Zuordnungen zwar übernommen, aber nicht ausgewertet: Wer
/// einen Vorschlag korrigierte, bekam beim nächsten Lauf denselben erneut.
/// Diese Tabelle ist das Gedächtnis dafür.
///
/// [similarity] ist der Wert **zum Entscheidungszeitpunkt** und der
/// eigentliche Grund für die Tabelle. Dass ein Gesicht zu einer Person
/// gehört, steht schon in [Faces.personId]; woran die Erkennung das hätte
/// merken können, steht nur hier.
///
/// Bewusst NICHT festgehalten wird das Überspringen eines Vorschlags:
/// "nicht jetzt" ist keine Aussage darüber, ob der Vorschlag richtig war,
/// und als Ablehnung gewertet würde es die Schwelle verderben.
@DataClassName('FaceMatchFeedbackData')
class FaceMatchFeedback extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get personId => text()();
  TextColumn get faceId => text()();
  BoolColumn get accepted => boolean()();
  RealColumn get similarity => real()();
  DateTimeColumn get createdAt => dateTime()();
}

/// Ein einzelnes erkanntes Gesicht innerhalb eines Assets (Bounding Box,
/// relativ 0..1). `personId` ist null, solange das Gesicht noch keiner
/// Person zugeordnet wurde. `embedding` ist nur gefüllt, wenn ein
/// Gesichts-Embedding-Modell installiert ist (siehe FaceEmbeddingService).
@DataClassName('FaceData')
class Faces extends Table {
  TextColumn get id => text()();
  TextColumn get assetId => text()();
  TextColumn get personId => text().nullable()();
  RealColumn get boxX => real()();
  RealColumn get boxY => real()();
  RealColumn get boxW => real()();
  RealColumn get boxH => real()();
  TextColumn get cropRelativePath => text().nullable()();
  BlobColumn get embedding => blob().nullable()();

  /// Wahrscheinlichkeit "Augen offen" (0..1, siehe EyeStateService) – `null`
  /// heißt "noch nicht berechnet" (kein Landmark verfügbar, oder das
  /// Augen-Modell war zum Scan-Zeitpunkt nicht installiert), NICHT "Augen
  /// geschlossen". Für die Sichtungs-Warnung erst ab einem gesetzten Wert
  /// unter dem Schwellenwert auswerten.
  RealColumn get eyeOpenScore => real().nullable()();

  /// Vom Nutzer beiseitegelegt: kein Gesicht (Plakat, Spiegelung, Statue)
  /// oder eine Person, die er nicht benennen will.
  ///
  /// Bewusst ein Merkmal statt eines Löschens. Löschen wäre endgültig und
  /// obendrein wirkungslos: Der nächste Gesichts-Scan fände dieselbe Stelle
  /// erneut und legte den Eintrag neu an. Ein beiseitegelegtes Gesicht
  /// verschwindet aus dem Raster und aus der automatischen Gruppierung,
  /// bleibt aber unter „Ignoriert" auffindbar und rückholbar.
  BoolColumn get isIgnored => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// CLIP-Bild-Embedding eines Assets (Float32-Vektor als Bytes), für die
/// KI-Bildsuche in natürlicher Sprache. Ähnlichkeit wird zur Laufzeit per
/// Brute-Force-Kosinus-Distanz berechnet – für private Bibliotheken
/// (bis zu einigen Zehntausend Fotos) schnell genug, ganz ohne
/// Vektordatenbank-Server.
class ImageEmbeddings extends Table {
  TextColumn get assetId => text()();
  BlobColumn get vector => blob()();

  @override
  Set<Column> get primaryKey => {assetId};
}

/// Einzeilige Tabelle (id immer 0) für den PIN-Schutz des gesperrten
/// Ordners – "Envelope Encryption": ein zufälliger Master-Key verschlüsselt
/// tatsächlich die Dateien (siehe VaultCrypto), der PIN verschlüsselt nur
/// diesen Master-Key (über Argon2id abgeleitet). Es wird nie der PIN selbst
/// gespeichert; die einzige PIN-Prüfung ist der Versuch, den Master-Key
/// damit zu entpacken (schlägt bei falschem PIN durch die
/// GCM-Authentifizierung fehl). `pinHash`/`pinSalt` sind Altlasten aus einer
/// früheren, rein anzeige-filternden (nicht verschlüsselnden) Version und
/// werden nicht mehr genutzt.
@DataClassName('PrivacySettingsData')
class PrivacySettings extends Table {
  IntColumn get id => integer()();
  TextColumn get pinHash => text().nullable()();
  TextColumn get pinSalt => text().nullable()();
  BlobColumn get kdfSalt => blob().nullable()();
  BlobColumn get wrappedMasterKeyNonce => blob().nullable()();
  BlobColumn get wrappedMasterKey => blob().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('BackupRecordData')
class BackupRecords extends Table {
  TextColumn get id => text()();
  DateTimeColumn get performedAt => dateTime()();
  TextColumn get destinationPath => text()();
  IntColumn get fileCount => integer()();
  IntColumn get totalBytes => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Einzeilige Tabelle (id immer 0) für die Backup-Verschlüsselung: derselbe
/// Envelope-Ansatz wie [PrivacySettings], aber mit eigenem Master-Key und
/// eigener Passphrase (bewusst getrennt vom PIN des gesperrten Ordners –
/// ein Backup landet oft extern, z.B. in einem Cloud-Sync-Ordner, und muss
/// unabhängig von der lokalen Bibliothek entschlüsselbar sein). Der
/// verpackte Schlüssel wird deshalb zusätzlich als kleine Datei ins Backup
/// selbst geschrieben (siehe BackupService), nicht nur hier lokal.
///
/// [autoBackupEnabled]/[autoBackupDestination]/[autoBackupIntervalHours]/
/// [lastAutoBackupAt] konfigurieren das automatische Backup (läuft nur,
/// während die App offen ist – kein Hintergrunddienst).
@DataClassName('BackupSettingsData')
class BackupSettings extends Table {
  IntColumn get id => integer()();
  BlobColumn get kdfSalt => blob().nullable()();
  BlobColumn get wrappedMasterKeyNonce => blob().nullable()();
  BlobColumn get wrappedMasterKey => blob().nullable()();

  BoolColumn get autoBackupEnabled => boolean().withDefault(const Constant(false))();
  TextColumn get autoBackupDestination => text().nullable()();
  IntColumn get autoBackupIntervalHours => integer().withDefault(const Constant(24))();
  DateTimeColumn get lastAutoBackupAt => dateTime().nullable()();

  /// Obergrenze je Sicherungslauf in Megabyte, 0 = unbegrenzt.
  ///
  /// Gedacht für Cloud-Ordner: Ohne Grenze landen bei der ersten Sicherung
  /// zigtausend Dateien auf einmal im Sync-Ordner, und der Upload läuft
  /// danach stunden- bis tagelang. Mit Grenze wird portionsweise gesichert,
  /// der Rest folgt beim nächsten Intervall.
  IntColumn get autoBackupMaxMbPerRun => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Einzeilige Tabelle (id immer 0) für den automatischen Papierkorb-Ablauf:
/// löscht in den Papierkorb verschobene Assets nach [autoDeleteAfterDays]
/// Tagen endgültig (Dateien + DB-Zeile) – läuft, wie das automatische
/// Backup, nur während die App geöffnet ist (siehe
/// [LibraryState.purgeExpiredTrashIfDue]). Standardmäßig deaktiviert, damit
/// niemand unerwartet Fotos verliert, die "nur eben" im Papierkorb lagen.
@DataClassName('TrashSettingsData')
class TrashSettings extends Table {
  IntColumn get id => integer()();
  BoolColumn get autoDeleteEnabled => boolean().withDefault(const Constant(false))();
  IntColumn get autoDeleteAfterDays => integer().withDefault(const Constant(30))();
  DateTimeColumn get lastPurgeAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Einzeilige Tabelle (id immer 0, gleiches Muster wie [TrashSettings]) für
/// app-weite Oberflächen-Einstellungen – aktuell nur das Erscheinungsbild.
/// [themeMode] als Text ('system'|'light'|'dark') statt als Enum-Index
/// gespeichert, damit eine künftige Umsortierung von [ThemeMode] die
/// gespeicherte Bedeutung nicht verschiebt.
@DataClassName('AppSettingsData')
class AppSettings extends Table {
  IntColumn get id => integer()();
  TextColumn get themeMode => text().withDefault(const Constant('system'))();

  /// Oberflächensprache: `'system'`, `'de'` oder `'en'`.
  ///
  /// Dasselbe Muster wie [themeMode], und aus demselben Grund als Text
  /// statt als Aufzählung: Eine unbekannte Angabe (etwa aus einer
  /// neueren Fassung) fällt beim Lesen auf den Standard zurück, statt
  /// den Start zu verhindern.
  TextColumn get sprache => text().withDefault(const Constant('system'))();

  /// Ob die rechenintensiven KI-Auswertungen (Gesichter, Texterkennung,
  /// CLIP, Bildbeschreibung, Unschärfe) nach einem Import automatisch als
  /// Hintergrundaufgabe nachlaufen. Standard an – sonst blieben frisch
  /// importierte Fotos ohne Suche und ohne Personenzuordnung, bis jemand
  /// die Werkzeuge von Hand anstößt.
  BoolColumn get autoAnalyzeAfterImport => boolean().withDefault(const Constant(true))();

  /// Ordner, der laufend auf neue Dateien geprüft wird (siehe
  /// LibraryState.pruefeUeberwachtenOrdner). Null = keiner eingerichtet.
  ///
  /// Der Zugriff braucht unter macOS zusätzlich das Sandbox-Merkmal aus der
  /// Ordnerauswahl, sonst erlischt er beim nächsten Programmstart – deshalb
  /// beide Angaben zusammen, wie bei den Bibliotheksorten auch.
  TextColumn get watchedFolderPath => text().nullable()();
  TextColumn get watchedFolderToken => text().nullable()();

  /// Allgemeine Schwelle für "dasselbe Gesicht" (Kosinus-Ähnlichkeit).
  ///
  /// 0,363 ist der von OpenCV Zoo für SFace dokumentierte Wert. Die
  /// Einstellung lag bisher nur im Speicher – der Regler unter "Werkzeuge"
  /// war bei jedem Programmstart wieder auf dem Ausgangswert, ohne dass
  /// das irgendwo stand.
  RealColumn get faceSimilarityThreshold => real().withDefault(const Constant(0.363))();

  /// Bildbeschreibungen ins Deutsche übersetzen (Modell `translation_en_de`).
  BoolColumn get translateCaptions => boolean().withDefault(const Constant(false))();

  /// Deutsche Suchanfragen und Schlagwörter vor der KI-Bildsuche ins
  /// Englische übersetzen (Modell `translation_de_en`).
  ///
  /// Standard aus, und zwar bewusst: An 103 Fotos der Testbibliothek
  /// gemessen trennt die englische Fassung eines Vokabelbegriffs bei 33
  /// von 56 Begriffen schärfer, bei 19 schlechter. Der Gewinn ist real,
  /// aber weder gross noch durchgängig – und die Zahl vergebener Tags
  /// sinkt bei gleicher Schwelle von 402 auf 248. Eine solche Änderung
  /// gehört nicht stillschweigend eingeschaltet.
  BoolColumn get translateSearchAndTags => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Editierbares Vokabular für automatisches KI-Tagging (siehe
/// AiTaggingService.suggestTags) – ursprünglich ein fester Konstanten-Array
/// (siehe [defaultAiTagVocabulary]), seit Schema v24 eine echte Tabelle
/// (analog zu [Tags], aber ohne Join-Tabelle, da hier keine Zuordnung zu
/// einzelnen Assets nötig ist, nur eine flache Begriffsliste). Bestehende
/// Installationen werden beim Upgrade auf v24 mit den bisherigen Begriffen
/// bestückt (siehe `_seedAiTagVocabulary`), damit sich das Tagging-Verhalten
/// nicht stillschweigend ändert.
@DataClassName('AiTagVocabularyData')
class AiTagVocabulary extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get term => text().unique()();
}

/// Eine gespeicherte Kombination aus Suchoptionen-Filtern ("Intelligentes
/// Album") – anders als ein normales Album keine feste Foto-Liste, sondern
/// läuft bei jedem Öffnen live gegen die aktuelle Bibliothek (siehe
/// [SearchFilters.toJson]/[AppDatabase.createSavedSearch]).
@DataClassName('SavedSearchData')
class SavedSearches extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get filtersJson => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  Assets,
  Albums,
  AlbumAssets,
  Tags,
  AssetTags,
  People,
  Faces,
  FaceMatchFeedback,
  ImageEmbeddings,
  BackupRecords,
  PrivacySettings,
  BackupSettings,
  SavedSearches,
  TrashSettings,
  CameraPresets,
  CameraPresetTags,
  DevelopSettings,
  DevelopHistory,
  VideoTrims,
  DevelopMasks,
  RestoreJobs,
  AppSettings,
  AiTagVocabulary,
  AutomationRules,
  AutomationRuleTags,
  ExportPresets,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Wird bei jeder Mutation erhöht, die das Ergebnis von [allEmbeddings]
  /// verändern könnte (neues/aktualisiertes Embedding, Papierkorb/
  /// Wiederherstellen, endgültiges Löschen, Sperren/Entsperren) – LibraryState
  /// nutzt das als billigen "ist mein gecachtes allEmbeddings()-Ergebnis noch
  /// aktuell?"-Check, ohne bei jeder Suche erneut alle Embeddings (oft
  /// hunderte MB bei großen Bibliotheken) aus der DB laden zu müssen.
  int _embeddingsGeneration = 0;
  int get embeddingsGeneration => _embeddingsGeneration;

  @override
  int get schemaVersion => 38;

  /// Bestückt AiTagVocabulary mit dem ursprünglichen, festen Begriffs-Array
  /// – für Neuinstallationen ([onCreate], das NICHT durch [onUpgrade] läuft)
  /// ebenso wie für das Upgrade bestehender Installationen auf v24.
  Future<void> _seedAiTagVocabulary() => batch((b) => b.insertAll(
        aiTagVocabulary,
        [for (final term in defaultAiTagVocabulary) AiTagVocabularyCompanion.insert(term: term)],
      ));

  /// Indizes für die im Betrieb häufigsten Filter/Sortierungen – ohne sie
  /// degenerieren mehrere Abfragen (Timeline/Alben/Personen-Ansicht, die
  /// Personen-/Album-Filter in [searchAssets]) bei wachsender Bibliothek zu
  /// vollständigen Tabellen-Scans, siehe die einzelnen Abfragen weiter unten.
  /// In einer eigenen Methode, damit sowohl frisch angelegte Datenbanken
  /// ([onCreate]) als auch bestehende (Migration `from < 11`) dieselben
  /// Indizes bekommen.
  Future<void> _createPerformanceIndices(Migrator m) async {
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_assets_trashed_locked_created '
        'ON assets (is_trashed, is_locked, file_created_at DESC)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_assets_location '
        'ON assets (location_country, location_state, location_city)');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_faces_asset_id ON faces (asset_id)');
    // Teilindex, nicht vollständig: Nur ein kleiner Teil aller Gesichter ist
    // beiseitegelegt, und genau danach wird gefragt. Gemessen an 17.836
    // Gesichtern / 7.988 Fotos: ohne Index 8,3 ms, mit Teilindex 0,49 ms.
    // Ein vollständiger Index über is_ignored brachte nichts – der Planer
    // benutzt ihn nicht, weil die Spalte für den Regelfall (0) nichts
    // eingrenzt.
    await customStatement('CREATE INDEX IF NOT EXISTS idx_faces_ignored '
        'ON faces (is_ignored) WHERE is_ignored = 1');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_faces_person_id ON faces (person_id)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_album_assets_asset_id ON album_assets (asset_id)');
  }

  /// Zusätzliche Indizes ab Version 14: Papierkorb-Sortierung nach Alter
  /// (für den automatischen Ablauf sowie die Papierkorb-Ansichten),
  /// Kartenansicht (nur Fotos mit GPS-Koordinaten) und Backup-Status – alle
  /// drei filtern bei einer sehr großen Bibliothek sonst auf einem
  /// Großteil der Tabelle, ohne dass die bestehenden Indizes (siehe
  /// [_createPerformanceIndices]) dafür etwas hergeben. Die Teilindizes
  /// ("WHERE ...") halten die jeweils indexierte Zeilenmenge klein (nur
  /// GPS-Fotos bzw. noch nicht gesicherte Fotos) statt die komplette
  /// Tabelle zu indexieren.
  Future<void> _createIndicesV14(Migrator m) async {
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_assets_trashed_at '
        'ON assets (is_trashed, trashed_at DESC)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_assets_gps '
        'ON assets (latitude, longitude) WHERE latitude IS NOT NULL');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_assets_not_backed_up '
        'ON assets (is_trashed, is_locked) WHERE backed_up = 0');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_assets_not_auto_backed_up '
        'ON assets (is_trashed, is_locked) WHERE auto_backed_up = 0');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_assets_camera '
        'ON assets (camera_make, camera_model)');
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _createPerformanceIndices(m);
          await _createIndicesV14(m);
          await _seedAiTagVocabulary();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(assets, assets.facesScanned);
          }
          if (from < 3) {
            await m.addColumn(assets, assets.previewRelativePath);
          }
          if (from < 4) {
            await m.addColumn(assets, assets.linkedAssetId);
          }
          if (from < 5) {
            await m.addColumn(assets, assets.latitude);
            await m.addColumn(assets, assets.longitude);
          }
          if (from < 6) {
            await m.addColumn(assets, assets.isLocked);
            await m.createTable(privacySettings);
          }
          if (from < 7) {
            await m.addColumn(privacySettings, privacySettings.kdfSalt);
            await m.addColumn(privacySettings, privacySettings.wrappedMasterKeyNonce);
            await m.addColumn(privacySettings, privacySettings.wrappedMasterKey);
            // Das alte Schema (Version 6) hat "gesperrte" Fotos nie
            // tatsächlich verschlüsselt, nur aus den normalen Ansichten
            // gefiltert. Ein bestehender PIN-Hash lässt sich nicht sicher
            // ins neue Master-Key-Schema übernehmen (der Klartext-PIN ist
            // aus einem Hash nicht rekonstruierbar) – deshalb hier
            // zurückgesetzt. Da unter Version 6 ohnehin nie verschlüsselt
            // wurde, ist "entsperren" das einzig korrekte Verhalten (es
            // geht nichts verloren, nur der PIN-Schutz muss neu
            // eingerichtet werden, jetzt mit echter Verschlüsselung).
            await (update(assets)..where((t) => t.isLocked.equals(true)))
                .write(const AssetsCompanion(isLocked: Value(false)));
            await delete(privacySettings).go();
          }
          if (from < 8) {
            await m.addColumn(assets, assets.autoBackedUp);
            await m.createTable(backupSettings);
          }
          if (from < 9) {
            await m.addColumn(assets, assets.cameraMake);
            await m.addColumn(assets, assets.cameraModel);
            await m.addColumn(assets, assets.lensModel);
            await m.addColumn(assets, assets.focalLengthMm);
            await m.addColumn(assets, assets.fNumber);
            await m.addColumn(assets, assets.iso);
            await m.addColumn(assets, assets.exposureTimeSeconds);
          }
          if (from < 10) {
            await m.addColumn(assets, assets.locationCountry);
            await m.addColumn(assets, assets.locationState);
            await m.addColumn(assets, assets.locationCity);
          }
          if (from < 11) {
            await _createPerformanceIndices(m);
          }
          if (from < 12) {
            await m.createTable(savedSearches);
          }
          if (from < 13) {
            await m.createTable(trashSettings);
          }
          if (from < 14) {
            await _createIndicesV14(m);
          }
          if (from < 15) {
            await m.createTable(cameraPresets);
            await m.createTable(cameraPresetTags);
          }
          if (from < 16) {
            await m.addColumn(assets, assets.developedRelativePath);
            await m.createTable(developSettings);
          }
          if (from < 17) {
            await m.addColumn(assets, assets.rating);
            await m.addColumn(assets, assets.colorLabel);
            await m.addColumn(assets, assets.ocrText);
            await m.addColumn(assets, assets.ocrScanned);
            await m.addColumn(assets, assets.sharpnessScore);
          }
          if (from < 18) {
            await m.createTable(developHistory);
          }
          if (from < 19) {
            await m.addColumn(assets, assets.trimmedRelativePath);
            await m.createTable(videoTrims);
          }
          if (from < 20) {
            await m.addColumn(assets, assets.stackId);
            await m.addColumn(assets, assets.isStackCover);
            await m.addColumn(assets, assets.stackSize);
          }
          if (from < 21) {
            await m.createTable(developMasks);
          }
          if (from < 22) {
            await m.addColumn(assets, assets.aiCaption);
            await m.addColumn(assets, assets.aiCaptionScanned);
          }
          if (from < 23) {
            await m.createTable(appSettings);
          }
          if (from < 24) {
            await m.createTable(aiTagVocabulary);
            await _seedAiTagVocabulary();
          }
          if (from < 25) {
            await m.addColumn(faces, faces.eyeOpenScore);
          }
          if (from < 26) {
            await m.addColumn(developMasks, developMasks.shapeDefinitionJson);
          }
          if (from < 27) {
            await m.addColumn(assets, assets.restoredRelativePath);
            await m.createTable(restoreJobs);
          }
          if (from < 28) {
            await _addColumnIfMissing(m, appSettings, appSettings.autoAnalyzeAfterImport,
                'app_settings', 'auto_analyze_after_import');
          }
          if (from < 29) {
            // Beide bewusst nachgeholt: Eine fehlerhafte Zwischenfassung hat
            // Datenbanken als Version 28 gestempelt, ohne die zugehörige
            // Spalte anzulegen. Ohne dieses Nachholen bliebe eine so
            // markierte Datenbank dauerhaft unbrauchbar, weil Drift die
            // Migration für erledigt hält und nie erneut ausführt.
            await _addColumnIfMissing(m, appSettings, appSettings.autoAnalyzeAfterImport,
                'app_settings', 'auto_analyze_after_import');
            await _addColumnIfMissing(m, backupSettings, backupSettings.autoBackupMaxMbPerRun,
                'backup_settings', 'auto_backup_max_mb_per_run');
          }
          if (from < 30) {
            await m.createTable(automationRules);
            await m.createTable(automationRuleTags);
          }
          if (from < 31) {
            await _addColumnIfMissing(
                m, assets, assets.aiTagsScanned, 'assets', 'ai_tags_scanned');
          }
          if (from < 32) {
            await _addColumnIfMissing(m, appSettings, appSettings.watchedFolderPath,
                'app_settings', 'watched_folder_path');
            await _addColumnIfMissing(m, appSettings, appSettings.watchedFolderToken,
                'app_settings', 'watched_folder_token');
          }
          if (from < 33) {
            // Tonwertkurve und Farbmischer. Beide nullable, `null` = neutral
            // – vorhandene Entwicklungen bleiben dadurch unverändert
            // gültig, es ist nichts nachzutragen.
            await _addColumnIfMissing(m, developSettings, developSettings.toneCurveJson,
                'develop_settings', 'tone_curve_json');
            await _addColumnIfMissing(m, developSettings, developSettings.colorMixerJson,
                'develop_settings', 'color_mixer_json');
            await _addColumnIfMissing(m, developHistory, developHistory.toneCurveJson,
                'develop_history', 'tone_curve_json');
            await _addColumnIfMissing(m, developHistory, developHistory.colorMixerJson,
                'develop_history', 'color_mixer_json');
          }
          if (from < 34) {
            // Lernende Gesichtserkennung. Ohne Rückmeldungen verhält sich
            // alles wie bisher: Die persönliche Schwelle bleibt null, es
            // gilt die allgemeine.
            await m.createTable(faceMatchFeedback);
            await _addColumnIfMissing(
                m, people, people.similarityThreshold, 'people', 'similarity_threshold');
            await _addColumnIfMissing(m, appSettings, appSettings.faceSimilarityThreshold,
                'app_settings', 'face_similarity_threshold');
          }
          if (from < 35) {
            // Übersetzung. Beide Schalter stehen auf aus, vorhandene
            // englische Beschreibungen bleiben unangetastet – erst wer die
            // Modelle installiert und den Schalter umlegt, bekommt Deutsch.
            await _addColumnIfMissing(
                m, assets, assets.aiCaptionDe, 'assets', 'ai_caption_de');
            await _addColumnIfMissing(m, appSettings, appSettings.translateCaptions,
                'app_settings', 'translate_captions');
            await _addColumnIfMissing(m, appSettings, appSettings.translateSearchAndTags,
                'app_settings', 'translate_search_and_tags');
          }
          if (from < 36) {
            // Oberflächensprache. Standard 'system' – für bestehende
            // Installationen ändert sich damit nichts, solange das System
            // auf Deutsch steht.
            await _addColumnIfMissing(
                m, appSettings, appSettings.sprache, 'app_settings', 'sprache');
          }
          if (from < 37) {
            // Export-Voreinstellungen. Eine neue, anfangs leere Tabelle –
            // ohne eine einzige gespeicherte Vorgabe verhält sich der Export
            // wie bisher, die vier festen Grössen bleiben erhalten.
            await m.createTable(exportPresets);
          }
          if (from < 38) {
            // Ignorierte Gesichter. Ein Merkmal an der bestehenden Tabelle,
            // keine eigene: Die Alternative wäre eine Ausschlussliste
            // gewesen, die bei jeder Abfrage mitgejoint werden müsste – für
            // eine Eigenschaft, die genau ein Gesicht betrifft.
            await _addColumnIfMissing(m, faces, faces.isIgnored, 'faces', 'is_ignored');
            // Erst nach der Spalte – ein Index auf eine noch nicht
            // existierende Spalte scheitert.
            await _createPerformanceIndices(m);
          }
        },
      );

  /// Legt [spalte] nur an, wenn sie in [tabellenName] noch fehlt.
  ///
  /// Schützt gegen den Fall, dass eine Datenbank bereits auf eine
  /// Schemaversion gestempelt wurde, deren Migration die Spalte gar nicht
  /// angelegt hat – dann würde ein blindes addColumn beim Nachholen mit
  /// "duplicate column" scheitern und der Start bräche ab.
  Future<void> _addColumnIfMissing(
    Migrator m,
    TableInfo table,
    GeneratedColumn spalte,
    String tabellenName,
    String spaltenName,
  ) async {
    final vorhanden = await customSelect('PRAGMA table_info($tabellenName)').get();
    final namen = vorhanden.map((r) => r.data['name'] as String).toSet();
    if (namen.contains(spaltenName)) return;
    await m.addColumn(table, spalte);
  }

  /// Öffnet (bzw. legt beim ersten Start an) die lokale SQLite-Datei im
  /// App-Support-Verzeichnis des Betriebssystems.
  static Future<AppDatabase> open() async {
    final libraryRoot = await LibraryLocation.currentRoot();
    await libraryRoot.create(recursive: true);
    final dbFile = File(p.join(libraryRoot.path, 'library.sqlite'));
    return AppDatabase(NativeDatabase.createInBackground(dbFile));
  }

  // -----------------------------------------------------------------------
  // Assets / Timeline
  // -----------------------------------------------------------------------

  Future<void> insertAsset(AssetsCompanion asset) => into(assets).insert(asset);

  Future<AssetData?> assetById(String id) =>
      (select(assets)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<AssetData>> assetsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final rows = await (select(assets)..where((t) => t.id.isIn(ids))).get();
    final byId = {for (final r in rows) r.id: r};
    // Reihenfolge der übergebenen IDs beibehalten (z.B. Ranking nach Ähnlichkeit).
    return ids.map((id) => byId[id]).whereType<AssetData>().toList();
  }

  /// Prüft anhand der Prüfsumme, ob eine Datei bereits importiert wurde
  /// (Duplikaterkennung beim Import).
  Future<bool> checksumExists(String checksum) async {
    final row = await (select(assets)..where((t) => t.checksum.equals(checksum)))
        .getSingleOrNull();
    return row != null;
  }

  /// "Eigenständig sichtbar" in Timeline/Kalender/Karte/Alben/Suche & Co.:
  /// weder das Video-Gegenstück eines Live-Photo-Paares (bleibt nur über das
  /// verknüpfte Foto sichtbar, siehe LivePhotoView) noch ein
  /// nicht-Titelbild-Mitglied eines Serien-Stapels (siehe createStack) –
  /// exakt dasselbe OR-Muster wie beim Live-Photo-Verstecken, nur einmal
  /// formuliert statt an jeder der rund ein Dutzend Fundstellen wiederholt.
  Expression<bool> _isPrimaryGridEntry($AssetsTable t) =>
      (t.type.equals('IMAGE') | t.linkedAssetId.isNull()) &
      (t.stackId.isNull() | t.isStackCover.equals(true));

  /// [limit] begrenzt auf die neuesten [limit] Fotos/Videos (per
  /// `idx_assets_trashed_locked_created` indexgestützt, also auch bei sehr
  /// großen Bibliotheken ein günstiger Index-Walk statt eines vollständigen
  /// Tabellen-Scans). Ohne [limit] wird – wie bisher – die komplette
  /// Zeitleiste geliefert; TimelineScreen nutzt [limit] für ein wachsendes
  /// Ladefenster (siehe dort), damit weder bei jeder Mutation noch beim
  /// ersten Öffnen zwingend die GESAMTE Bibliothek aus der DB geladen und in
  /// Dart neu gruppiert werden muss.
  Stream<List<AssetData>> watchTimeline({bool favoritesOnly = false, int? limit}) {
    final query = select(assets)
      ..where((t) =>
          t.isTrashed.equals(false) &
          t.isLocked.equals(false) &
          _isPrimaryGridEntry(t));
    if (favoritesOnly) {
      query.where((t) => t.isFavorite.equals(true));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.fileCreatedAt)]);
    if (limit != null) {
      query.limit(limit);
    }
    return query.watch();
  }

  /// Fotos/Videos genau eines Kalenderjahres – im Gegensatz zu
  /// `watchTimeline()` + Dart-seitigem Filtern (früheres Verhalten von
  /// YearDetailScreen) direkt als indexgestützte SQL-Bereichsabfrage, die bei
  /// großen Bibliotheken nicht erst alle anderen Jahre mitladen muss.
  Stream<List<AssetData>> watchTimelineForYear(int year) {
    final start = DateTime(year);
    final end = DateTime(year + 1);
    return (select(assets)
          ..where((t) =>
              t.isTrashed.equals(false) &
              t.isLocked.equals(false) &
              _isPrimaryGridEntry(t) &
              t.fileCreatedAt.isBiggerOrEqualValue(start) &
              t.fileCreatedAt.isSmallerThanValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.fileCreatedAt)]))
        .watch();
  }

  /// Anzahl Fotos/Videos pro Kalenderjahr für die Jahresübersicht
  /// (CalendarScreen) – eine einzelne aggregierte SQL-Abfrage statt (wie
  /// zuvor) die komplette Zeitleiste zu laden und in Dart pro Jahr zu
  /// zählen. `strftime('%Y', ...)` arbeitet auf demselben, bereits über
  /// `idx_assets_trashed_locked_created` indexierten Filter.
  Stream<Map<int, int>> watchAssetCountsByYear() {
    // 'unixepoch' ist zwingend nötig: drift speichert DateTimeColumn
    // standardmäßig als Unix-Timestamp (Sekunden) statt als ISO8601-Text –
    // ohne den Modifier interpretiert SQLites strftime() die rohe Zahl als
    // Julianisches Datum statt als Unix-Zeit und liefert NULL zurück.
    const yearExpr = CustomExpression<String>(
        "strftime('%Y', file_created_at, 'unixepoch')");
    final query = selectOnly(assets)
      ..addColumns([yearExpr, assets.id.count()])
      ..where(assets.isTrashed.equals(false) &
          assets.isLocked.equals(false) &
          _isPrimaryGridEntry(assets))
      ..groupBy([yearExpr]);
    return query.watch().map((rows) => {
          for (final row in rows)
            int.parse(row.read(yearExpr)!): row.read(assets.id.count())!,
        });
  }

  Future<int> _countWhere(Expression<bool> predicate) async {
    final countExpr = assets.id.count();
    final query = selectOnly(assets)
      ..addColumns([countExpr])
      ..where(predicate);
    final row = await query.getSingle();
    return row.read<int>(countExpr) ?? 0;
  }

  /// Gebündelte Kennzahlen für die Analyseseite (StatisticsScreen) – bewusst
  /// eine einzelne Momentaufnahme (`Future`, kein `Stream`) statt mehrerer
  /// reaktiver Einzel-Queries: die Seite selbst nutzt Pull-to-Refresh statt
  /// Live-Aktualisierung, da bei einer großen Bibliothek sonst nach jeder
  /// Mutation (z.B. Favorit toggeln) sämtliche Aggregate neu berechnet
  /// würden, obwohl sich für die Analyseseite selbst nichts geändert hat.
  Future<LibraryStats> loadLibraryStats() async {
    // Dieselbe Definition von "sichtbares Medium" wie in watchTimeline() &
    // Co.: nicht im Papierkorb, nicht gesperrt, und beim Live-Photo-Paar nur
    // das Foto zählen (das zugehörige Video wird sonst doppelt gezählt).
    final visible = assets.isTrashed.equals(false) &
        assets.isLocked.equals(false) &
        _isPrimaryGridEntry(assets);

    final results = await Future.wait([
      _countWhere(visible & assets.type.equals('IMAGE')),
      _countWhere(visible & assets.type.equals('VIDEO')),
      _countWhere(visible & assets.isFavorite.equals(true)),
      _countWhere(assets.isTrashed.equals(true) & assets.isLocked.equals(false)),
      _countWhere(assets.isLocked.equals(true) & assets.isTrashed.equals(false)),
      _loadTotalSizeBytes(),
      watchAssetCountsByYear().first,
      _loadCountsByMonth(visible),
      _loadTopCameras(visible),
    ]);

    return LibraryStats(
      imageCount: results[0] as int,
      videoCount: results[1] as int,
      favoriteCount: results[2] as int,
      trashedCount: results[3] as int,
      lockedCount: results[4] as int,
      totalSizeBytes: results[5] as int,
      countsByYear: results[6] as Map<int, int>,
      countsByMonth: results[7] as Map<int, int>,
      topCameras: results[8] as List<CameraStat>,
    );
  }

  /// Tatsächlich belegter Speicherplatz aller nicht gelöschten Dateien –
  /// bewusst OHNE den `visible`-Filter von [loadLibraryStats]: das
  /// zugehörige Video eines Live-Photo-Paares belegt real Speicherplatz auf
  /// der Festplatte, auch wenn es in der UI nicht als eigenes Element
  /// gezählt wird. Gesperrte Assets werden trotzdem ausgeschlossen, damit
  /// die Analyseseite (ohne PIN-Eingabe erreichbar) keine Information über
  /// den Inhalt des gesperrten Ordners preisgibt.
  Future<int> _loadTotalSizeBytes() async {
    final sumExpr = assets.fileSizeBytes.sum();
    final query = selectOnly(assets)
      ..addColumns([sumExpr])
      ..where(assets.isTrashed.equals(false) & assets.isLocked.equals(false));
    final row = await query.getSingle();
    return row.read<int>(sumExpr) ?? 0;
  }

  /// Anzahl Fotos/Videos je Kalendermonat (1-12), über alle Jahre summiert –
  /// zeigt saisonale Muster (z.B. mehr Fotos im Sommer/an Feiertagen).
  Future<Map<int, int>> _loadCountsByMonth(Expression<bool> visible) async {
    const monthExpr = CustomExpression<String>("strftime('%m', file_created_at, 'unixepoch')");
    final countExpr = assets.id.count();
    final query = selectOnly(assets)
      ..addColumns([monthExpr, countExpr])
      ..where(visible)
      ..groupBy([monthExpr]);
    final rows = await query.get();
    return {
      for (final row in rows) int.parse(row.read<String>(monthExpr)!): row.read<int>(countExpr) ?? 0,
    };
  }

  /// Die [limit] häufigsten Kamera-Kombinationen (Hersteller + Modell) für
  /// die Analyseseite – schließt Fotos ganz ohne Kamerainformation
  /// (Screenshots, Scans, ...) bewusst NICHT aus, damit deren Anteil an der
  /// Bibliothek sichtbar wird.
  Future<List<CameraStat>> _loadTopCameras(Expression<bool> visible, {int limit = 12}) async {
    final countExpr = assets.id.count();
    final query = selectOnly(assets)
      ..addColumns([assets.cameraMake, assets.cameraModel, countExpr])
      ..where(visible)
      ..groupBy([assets.cameraMake, assets.cameraModel])
      ..orderBy([OrderingTerm.desc(countExpr)])
      ..limit(limit);
    final rows = await query.get();
    return [
      for (final row in rows)
        CameraStat(
          make: row.read<String>(assets.cameraMake),
          model: row.read<String>(assets.cameraModel),
          count: row.read<int>(countExpr) ?? 0,
        ),
    ];
  }

  /// Position (0-basiert) eines Assets in der absteigend nach Datum
  /// sortierten Zeitleiste – wie viele andere (nicht Papierkorb/gesperrte)
  /// Assets neuer sind. Für TimelineScreen: bei "Foto in der Timeline
  /// anzeigen" (Kontextmenü der Vollbildansicht) muss das Ladefenster (siehe
  /// `watchTimeline(limit: ...)`) mindestens so weit geöffnet werden, dass
  /// das Zielfoto enthalten ist – auch wenn es weit "unten" in einer sehr
  /// großen Bibliothek liegt. Gibt `null` zurück, wenn das Asset nicht
  /// existiert.
  Future<int?> timelineRankOfAsset(String assetId) async {
    final asset = await assetById(assetId);
    if (asset == null) return null;
    final Expression<int> countExpr = assets.id.count();
    final JoinedSelectStatement<Assets, AssetData> query = selectOnly(assets)
      ..addColumns([countExpr])
      ..where(assets.isTrashed.equals(false) &
          assets.isLocked.equals(false) &
          _isPrimaryGridEntry(assets) &
          assets.fileCreatedAt.isBiggerThanValue(asset.fileCreatedAt));
    final row = await query.getSingle();
    return row.read<int>(countExpr) ?? 0;
  }

  /// Neuestes Foto/Video eines Jahres als Titelbild für die Jahresübersicht
  /// (CalendarScreen) – dieselbe indexgestützte Bereichsabfrage wie
  /// [watchTimelineForYear], aber auf ein einzelnes Ergebnis begrenzt (pro
  /// Jahr wird dort nur ein Titelbild gebraucht, nicht die volle Liste).
  Future<AssetData?> newestAssetForYear(int year) {
    final start = DateTime(year);
    final end = DateTime(year + 1);
    return (select(assets)
          ..where((t) =>
              t.isTrashed.equals(false) &
              t.isLocked.equals(false) &
              _isPrimaryGridEntry(t) &
              t.fileCreatedAt.isBiggerOrEqualValue(start) &
              t.fileCreatedAt.isSmallerThanValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.fileCreatedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Der normale, ungeschützte Papierkorb – gesperrte (verschlüsselte)
  /// Assets werden hier bewusst ausgeblendet (siehe [watchLockedTrash]):
  /// sonst könnte jeder ohne PIN ein gesperrtes Foto wiederherstellen oder
  /// sogar endgültig löschen, nur weil es zwischenzeitlich im Papierkorb
  /// liegt.
  Stream<List<AssetData>> watchTrash() {
    return (select(assets)
          ..where((t) => t.isTrashed.equals(true) & t.isLocked.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.trashedAt)]))
        .watch();
  }

  /// Eigener, PIN-geschützter Papierkorb für aus dem gesperrten Ordner
  /// gelöschte Fotos – nur über den gesperrten Ordner erreichbar (siehe
  /// LockedFolderScreen), damit "gelöscht" bei gesperrten Fotos denselben
  /// Schutz genießt wie "sichtbar".
  Stream<List<AssetData>> watchLockedTrash() {
    return (select(assets)
          ..where((t) => t.isTrashed.equals(true) & t.isLocked.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.trashedAt)]))
        .watch();
  }

  Future<void> setFavorite(String assetId, bool value) =>
      (update(assets)..where((t) => t.id.equals(assetId)))
          .write(AssetsCompanion(isFavorite: Value(value)));

  Future<void> setRating(String assetId, int rating) =>
      (update(assets)..where((t) => t.id.equals(assetId)))
          .write(AssetsCompanion(rating: Value(rating)));

  Future<void> setRatingBulk(List<String> assetIds, int rating) =>
      (update(assets)..where((t) => t.id.isIn(assetIds)))
          .write(AssetsCompanion(rating: Value(rating)));

  Future<void> setColorLabel(String assetId, String? colorLabel) =>
      (update(assets)..where((t) => t.id.equals(assetId)))
          .write(AssetsCompanion(colorLabel: Value(colorLabel)));

  /// Setzt den Favoriten-Status für mehrere Assets in EINER Anweisung.
  ///
  /// Die Auswahlleiste lief vorher in einer Schleife über die Auswahl – bei
  /// 500 markierten Fotos also 500 einzelne Schreibvorgänge statt einem.
  Future<void> setFavoriteBulk(List<String> assetIds, bool value) =>
      (update(assets)..where((t) => t.id.isIn(assetIds)))
          .write(AssetsCompanion(isFavorite: Value(value)));

  Future<void> setColorLabelBulk(List<String> assetIds, String? colorLabel) =>
      (update(assets)..where((t) => t.id.isIn(assetIds)))
          .write(AssetsCompanion(colorLabel: Value(colorLabel)));

  /// Setzt dieselbe Beschreibung für mehrere Assets auf einmal (Auswahlleiste
  /// "Metadaten bearbeiten") – überschreibt, statt anzuhängen.
  Future<void> setDescriptionBulk(List<String> assetIds, String description) =>
      (update(assets)..where((t) => t.id.isIn(assetIds)))
          .write(AssetsCompanion(description: Value(description)));

  /// Setzt denselben Zeitpunkt für mehrere Assets auf einmal – bewusst kein
  /// relatives Verschieben (jedes Foto würde sonst seinen ursprünglichen
  /// Abstand zu den anderen behalten müssen), sondern ein einfaches
  /// "alle auf diesen einen Zeitpunkt setzen" für die Auswahlleiste.
  Future<void> setFileCreatedAtBulk(List<String> assetIds, DateTime fileCreatedAt) =>
      (update(assets)..where((t) => t.id.isIn(assetIds)))
          .write(AssetsCompanion(fileCreatedAt: Value(fileCreatedAt)));

  Future<void> setLocationBulk(List<String> assetIds, double? latitude, double? longitude) =>
      (update(assets)..where((t) => t.id.isIn(assetIds))).write(AssetsCompanion(
        latitude: Value(latitude),
        longitude: Value(longitude),
      ));

  Future<void> moveToTrash(List<String> assetIds) async {
    await (update(assets)..where((t) => t.id.isIn(assetIds)))
        .write(AssetsCompanion(isTrashed: const Value(true), trashedAt: Value(DateTime.now())));
    _embeddingsGeneration++;
  }

  Future<void> restoreFromTrash(List<String> assetIds) async {
    await (update(assets)..where((t) => t.id.isIn(assetIds)))
        .write(const AssetsCompanion(isTrashed: Value(false), trashedAt: Value(null)));
    _embeddingsGeneration++;
  }

  /// Löscht die Datenbankzeile endgültig. Das eigentliche Löschen der Datei
  /// auf der Festplatte übernimmt StoragePaths.
  Future<void> deleteAssetRows(List<String> assetIds) async {
    await (delete(assets)..where((t) => t.id.isIn(assetIds))).go();
    _embeddingsGeneration++;
  }

  /// Alle Assets (gesperrt oder nicht – der PIN-Schutz gilt dem Ansehen des
  /// Inhalts, nicht dem endgültigen Löschen einer bereits im Papierkorb
  /// liegenden Datei), die vor [cutoff] in den Papierkorb verschoben wurden.
  /// Für den automatischen Papierkorb-Ablauf, siehe
  /// [LibraryState.purgeExpiredTrashIfDue].
  Future<List<AssetData>> expiredTrashAssets(DateTime cutoff) => (select(assets)
        ..where((t) => t.isTrashed.equals(true) & t.trashedAt.isSmallerThanValue(cutoff)))
      .get();

  Future<TrashSettingsData?> trashSettingsRow() =>
      (select(trashSettings)..where((t) => t.id.equals(0))).getSingleOrNull();

  Future<void> setTrashAutoDeleteConfig({required bool enabled, int? afterDays}) =>
      into(trashSettings).insertOnConflictUpdate(TrashSettingsCompanion.insert(
        id: const Value(0),
        autoDeleteEnabled: Value(enabled),
        autoDeleteAfterDays: afterDays != null ? Value(afterDays) : const Value.absent(),
      ));

  Future<void> setLastTrashPurgeAt(DateTime when) =>
      (update(trashSettings)..where((t) => t.id.equals(0)))
          .write(TrashSettingsCompanion(lastPurgeAt: Value(when)));

  /// Reaktiv statt einmalig gelesen, damit ein Theme-Wechsel in den
  /// Einstellungen sofort in main.dart ankommt, ohne App-Neustart.
  Stream<AppSettingsData?> watchAppSettings() =>
      (select(appSettings)..where((t) => t.id.equals(0))).watchSingleOrNull();

  Future<void> setAutoAnalyzeAfterImport(bool an) =>
      into(appSettings).insertOnConflictUpdate(AppSettingsCompanion.insert(
        id: const Value(0),
        autoAnalyzeAfterImport: Value(an),
      ));

  /// Einmalig gelesen (nicht als Stream): wird direkt nach einem Import
  /// abgefragt, um zu entscheiden, ob die Analyse anlaufen soll.
  /// Der überwachte Ordner samt Sandbox-Merkmal, oder null.
  Future<({String pfad, String? token})?> ueberwachterOrdner() async {
    final row = await (select(appSettings)..where((t) => t.id.equals(0))).getSingleOrNull();
    final pfad = row?.watchedFolderPath;
    if (pfad == null || pfad.isEmpty) return null;
    return (pfad: pfad, token: row?.watchedFolderToken);
  }

  /// Setzt den überwachten Ordner; [pfad] = null schaltet die Überwachung ab.
  Future<void> setzeUeberwachtenOrdner({String? pfad, String? token}) =>
      into(appSettings).insertOnConflictUpdate(AppSettingsCompanion.insert(
        id: const Value(0),
        watchedFolderPath: Value(pfad),
        watchedFolderToken: Value(token),
      ));

  /// Allgemeine Gesichts-Ähnlichkeitsschwelle. Beim Schreiben werden die
  /// persönlichen Schwellen mitgezogen – sie hängen an dieser (siehe
  /// [rechneAlleSchwellenNeu]), sonst hätte der Regler für bereits
  /// gelernte Personen keine Wirkung mehr.
  Future<void> setFaceSimilarityThreshold(double wert) => transaction(() async {
        await into(appSettings).insertOnConflictUpdate(AppSettingsCompanion.insert(
          id: const Value(0),
          faceSimilarityThreshold: Value(wert),
        ));
        await rechneAlleSchwellenNeu(wert);
      });

  Future<double> faceSimilarityThresholdWert() async {
    final row = await (select(appSettings)..where((t) => t.id.equals(0))).getSingleOrNull();
    return row?.faceSimilarityThreshold ?? 0.363;
  }

  Future<bool> autoAnalyzeAfterImportEnabled() async {
    final row = await (select(appSettings)..where((t) => t.id.equals(0))).getSingleOrNull();
    return row?.autoAnalyzeAfterImport ?? true;
  }

  /// Benennt Vokabelbegriffe und die zugehörigen Schlagwörter um – für das
  /// Angebot beim Sprachwechsel.
  ///
  /// [zuordnung] bildet alt auf neu ab und enthält **nur** Begriffe, die
  /// tatsächlich im Vokabular stehen; selbst hinzugefügte bleiben
  /// unangetastet.
  ///
  /// Drei Tabellen sind betroffen, und die dritte ist die, die man
  /// übersieht:
  ///
  ///  1. [AiTagVocabulary.term] – der Vokabeleintrag
  ///  2. [Tags.name] – der Schlagwort-Name. Alle Zuordnungen hängen an
  ///     [Tags.id] und wandern deshalb von selbst mit; es ist ein reines
  ///     Umbenennen, kein Umhängen.
  ///  3. [AutomationRules.aiTagTerm] – eine Textspalte, die exakt einem
  ///     Vokabelbegriff entsprechen muss. Bliebe sie stehen, hörte eine
  ///     Regel „wenn Hund erkannt" lautlos auf zu feuern.
  ///
  /// **Namenskollisionen** sind der Fall, an dem eine naive Fassung
  /// scheitert: Beide Namensspalten sind `unique`. Gibt es das Ziel schon
  /// (etwa ein von Hand angelegtes „Dog"), wird nicht umbenannt, sondern
  /// **verschmolzen** – die Zuordnungen des alten Schlagworts wandern auf
  /// das bestehende, das alte wird gelöscht. Ohne diesen Zweig bräche die
  /// ganze Umstellung mit einem Constraint-Fehler ab.
  ///
  /// Gibt die Anzahl tatsächlich umbenannter Begriffe zurück.
  Future<int> uebersetzeVokabular(Map<String, String> zuordnung) async {
    var geaendert = 0;
    await transaction(() async {
      for (final eintrag in zuordnung.entries) {
        final alt = eintrag.key;
        final neu = eintrag.value;
        if (alt == neu) continue;

        // --- Vokabular ---
        final vorhandenesVokabel = await (select(aiTagVocabulary)
              ..where((t) => t.term.equals(alt)))
            .getSingleOrNull();
        if (vorhandenesVokabel == null) continue;

        final zielVokabel = await (select(aiTagVocabulary)
              ..where((t) => t.term.equals(neu)))
            .getSingleOrNull();
        if (zielVokabel != null) {
          // Ziel gibt es schon – der alte Eintrag ist damit überflüssig.
          await (delete(aiTagVocabulary)..where((t) => t.id.equals(vorhandenesVokabel.id))).go();
        } else {
          await (update(aiTagVocabulary)..where((t) => t.id.equals(vorhandenesVokabel.id)))
              .write(AiTagVocabularyCompanion(term: Value(neu)));
        }

        // --- Schlagwort samt Zuordnungen ---
        final altesTag =
            await (select(tags)..where((t) => t.name.equals(alt))).getSingleOrNull();
        if (altesTag != null) {
          final zielTag =
              await (select(tags)..where((t) => t.name.equals(neu))).getSingleOrNull();
          if (zielTag == null) {
            await (update(tags)..where((t) => t.id.equals(altesTag.id)))
                .write(TagsCompanion(name: Value(neu)));
          } else {
            // Verschmelzen: Zuordnungen umhängen, dabei bereits
            // bestehende Paare nicht doppelt anlegen.
            final betroffene = await (select(assetTags)
                  ..where((t) => t.tagId.equals(altesTag.id)))
                .get();
            for (final zuweisung in betroffene) {
              await into(assetTags).insertOnConflictUpdate(AssetTagsCompanion.insert(
                assetId: zuweisung.assetId,
                tagId: zielTag.id,
              ));
            }
            await (delete(assetTags)..where((t) => t.tagId.equals(altesTag.id))).go();
            await (delete(automationRuleTags)..where((t) => t.tagId.equals(altesTag.id))).go();
            await (delete(tags)..where((t) => t.id.equals(altesTag.id))).go();
          }
        }

        // --- Automatisierungsregeln ---
        await (update(automationRules)..where((t) => t.aiTagTerm.equals(alt)))
            .write(AutomationRulesCompanion(aiTagTerm: Value(neu)));

        geaendert++;
      }
    });
    return geaendert;
  }

  /// Begriffe im Vokabular, die NICHT aus der mitgelieferten
  /// Startbestückung stammen – sie bleiben beim Sprachwechsel unverändert
  /// und werden im Dialog gezählt.
  Future<int> zaehleEigeneVokabelbegriffe(Set<String> bekannte) async {
    final alle = await select(aiTagVocabulary).get();
    return alle.where((v) => !bekannte.contains(v.term)).length;
  }

  Future<void> setSprache(String sprache) =>
      into(appSettings).insertOnConflictUpdate(AppSettingsCompanion.insert(
        id: const Value(0),
        sprache: Value(sprache),
      ));

  Future<String> spracheWert() async {
    final row = await (select(appSettings)..where((t) => t.id.equals(0))).getSingleOrNull();
    return row?.sprache ?? 'system';
  }

  Future<void> setThemeMode(String mode) =>
      into(appSettings).insertOnConflictUpdate(AppSettingsCompanion.insert(
        id: const Value(0),
        themeMode: Value(mode),
      ));

  Future<void> setDescription(String assetId, String description) =>
      (update(assets)..where((t) => t.id.equals(assetId)))
          .write(AssetsCompanion(description: Value(description)));

  Future<void> setFileCreatedAt(String assetId, DateTime fileCreatedAt) =>
      (update(assets)..where((t) => t.id.equals(assetId)))
          .write(AssetsCompanion(fileCreatedAt: Value(fileCreatedAt)));

  /// Setzt (oder löscht, bei `null`) den Ort eines Assets – entweder aus
  /// EXIF-GPS-Daten beim Import übernommen oder manuell in der Info-Ansicht
  /// der Vollbildvorschau gesetzt/korrigiert.
  Future<void> setLocation(String assetId, double? latitude, double? longitude) =>
      (update(assets)..where((t) => t.id.equals(assetId))).write(AssetsCompanion(
        latitude: Value(latitude),
        longitude: Value(longitude),
      ));

  /// Fotos ohne bekannten Ort – für das nachträgliche Einlesen von
  /// EXIF-GPS-Daten (Werkzeuge), z.B. für Fotos, die vor Einführung dieser
  /// Funktion importiert wurden. Nur Fotos, da Videos i.d.R. keine
  /// EXIF-GPS-Daten haben (Ort muss dort manuell in der Info-Ansicht
  /// gesetzt werden).
  Future<List<AssetData>> assetsForLocationBackfill() => (select(assets)
        ..where((t) =>
            t.type.equals('IMAGE') & t.isTrashed.equals(false) & t.latitude.isNull()))
      .get();

  /// Zählvariante von [assetsForLocationBackfill] – für Anzeigezwecke (siehe
  /// BackgroundTasksScreen), ohne die vollen Zeilen aus der DB zu holen.
  Future<int> countLocationBackfill() =>
      _countWhere(assets.type.equals('IMAGE') & assets.isTrashed.equals(false) & assets.latitude.isNull());

  /// Setzt die Kamera-/Objektiv-/Aufnahme-Angaben eines Assets (siehe
  /// CameraInfo) – beim Import automatisch oder nachträglich über das
  /// Werkzeug "Kameradaten einlesen".
  Future<void> setCameraMetadata(String assetId, CameraInfo info) =>
      (update(assets)..where((t) => t.id.equals(assetId))).write(AssetsCompanion(
        cameraMake: Value(info.make),
        cameraModel: Value(info.model),
        lensModel: Value(info.lensModel),
        focalLengthMm: Value(info.focalLengthMm),
        fNumber: Value(info.fNumber),
        iso: Value(info.iso),
        exposureTimeSeconds: Value(info.exposureTimeSeconds),
      ));

  /// Fotos ohne bekannte Kamera-Angaben – für das nachträgliche Einlesen in
  /// den Werkzeugen (Fotos, die vor Einführung dieser Funktion importiert
  /// wurden). Prüft nur Hersteller+Modell als "schon verarbeitet"-Signal;
  /// Fotos, deren EXIF-Daten tatsächlich keine Kamera-Angaben enthalten
  /// (z.B. Screenshots), werden dadurch bei jedem Lauf erneut geprüft – wie
  /// bei [assetsForLocationBackfill] bewusst in Kauf genommen, da das
  /// erneute Prüfen sehr günstig ist.
  Future<List<AssetData>> assetsForCameraMetadataBackfill() => (select(assets)
        ..where((t) =>
            t.type.equals('IMAGE') &
            t.isTrashed.equals(false) &
            t.cameraMake.isNull() &
            t.cameraModel.isNull()))
      .get();

  /// Zählvariante von [assetsForCameraMetadataBackfill], siehe [countLocationBackfill].
  Future<int> countCameraMetadataBackfill() => _countWhere(assets.type.equals('IMAGE') &
      assets.isTrashed.equals(false) &
      assets.cameraMake.isNull() &
      assets.cameraModel.isNull());

  /// Setzt das Ergebnis der Texterkennung (siehe ImageConverter.swift
  /// `recognizeText`) – [text] darf leer sein (kein Text im Bild gefunden),
  /// `ocrScanned` unterscheidet das von "noch nicht gescannt".
  Future<void> setOcrResult(String assetId, String text) =>
      (update(assets)..where((t) => t.id.equals(assetId))).write(AssetsCompanion(
        ocrText: Value(text),
        ocrScanned: const Value(true),
      ));

  /// Bild-Assets ohne Texterkennung – für den nachträglichen Lauf in den
  /// Werkzeugen (Fotos, die vor Einführung dieser Funktion importiert wurden).
  ///
  /// Ohne gesperrte Fotos, aus demselben Grund wie bei [assetsForAiTagging]:
  /// Erkannter Text ist Bildinhalt und hätte in der unverschlüsselten
  /// Datenbank nichts zu suchen. Bisher fehlte dieser Filter (Audit-Fund) –
  /// folgenlos nur deshalb, weil die mitverschlüsselte Vorschau ohnehin
  /// nicht dekodierbar ist; verlassen sollte sich darauf niemand.
  Future<List<AssetData>> assetsForOcrBackfill() => (select(assets)
        ..where((t) =>
            t.type.equals('IMAGE') &
            t.isTrashed.equals(false) &
            t.isLocked.equals(false) &
            t.ocrScanned.equals(false)))
      .get();

  /// Zählvariante von [assetsForOcrBackfill], siehe [countLocationBackfill].
  Future<int> countOcrBackfill() => _countWhere(assets.type.equals('IMAGE') &
      assets.isTrashed.equals(false) &
      assets.isLocked.equals(false) &
      assets.ocrScanned.equals(false));

  /// Setzt das Ergebnis der KI-Bildbeschreibung (siehe CaptioningService) –
  /// analog zu [setOcrResult].
  ///
  /// [deutsch] ist die übersetzte Fassung, sofern das Übersetzungsmodell
  /// installiert und eingeschaltet ist. Das englische Original bleibt in
  /// jedem Fall stehen.
  Future<void> setAiCaption(String assetId, String caption, {String? deutsch}) =>
      (update(assets)..where((t) => t.id.equals(assetId))).write(AssetsCompanion(
        aiCaption: Value(caption),
        aiCaptionDe: Value(deutsch),
        aiCaptionScanned: const Value(true),
      ));

  Future<bool> uebersetzeBeschreibungen() async {
    final row = await (select(appSettings)..where((t) => t.id.equals(0))).getSingleOrNull();
    return row?.translateCaptions ?? false;
  }

  Future<bool> uebersetzeSucheUndTags() async {
    final row = await (select(appSettings)..where((t) => t.id.equals(0))).getSingleOrNull();
    return row?.translateSearchAndTags ?? false;
  }

  Future<void> setzeUebersetzeBeschreibungen(bool an) =>
      into(appSettings).insertOnConflictUpdate(AppSettingsCompanion.insert(
        id: const Value(0),
        translateCaptions: Value(an),
      ));

  Future<void> setzeUebersetzeSucheUndTags(bool an) =>
      into(appSettings).insertOnConflictUpdate(AppSettingsCompanion.insert(
        id: const Value(0),
        translateSearchAndTags: Value(an),
      ));

  /// Bild-Assets ohne KI-Bildbeschreibung – für den nachträglichen Lauf in
  /// den Werkzeugen, analog zu [assetsForOcrBackfill] (gesperrte Fotos
  /// ebenfalls ausgenommen, siehe dort).
  Future<List<AssetData>> assetsForCaptionBackfill() => (select(assets)
        ..where((t) =>
            t.type.equals('IMAGE') &
            t.isTrashed.equals(false) &
            t.isLocked.equals(false) &
            t.aiCaptionScanned.equals(false)))
      .get();

  /// Zählvariante von [assetsForCaptionBackfill], siehe [countLocationBackfill].
  Future<int> countCaptionBackfill() => _countWhere(assets.type.equals('IMAGE') &
      assets.isTrashed.equals(false) &
      assets.isLocked.equals(false) &
      assets.aiCaptionScanned.equals(false));

  Future<void> setSharpnessScore(String assetId, double score) =>
      (update(assets)..where((t) => t.id.equals(assetId)))
          .write(AssetsCompanion(sharpnessScore: Value(score)));

  /// Bild-Assets, denen mindestens eine der drei Auswertungen fehlt, die
  /// DASSELBE dekodierte Bild brauchen: Unschärfe, Gesichter, CLIP-Embedding.
  ///
  /// Grundlage für den gemeinsamen Durchlauf in
  /// [LibraryState.starteHintergrundanalyse]: Statt dass jede Stufe die
  /// Bibliothek für sich durchgeht und jedes Foto erneut dekodiert (gemessen
  /// rund 85 ms je Foto), wird einmal dekodiert und das Ergebnis an alle drei
  /// weitergereicht.
  ///
  /// `hatEmbedding` kommt aus dem Left Join und sagt, ob die CLIP-Stufe für
  /// dieses Foto noch etwas zu tun hat – die beiden anderen Stufen lassen
  /// sich direkt am Asset ablesen ([Assets.sharpnessScore], [Assets.facesScanned]).
  Future<List<({AssetData asset, bool hatEmbedding})>> assetsForCombinedImageAnalysis() async {
    final query = select(assets).join([
      leftOuterJoin(imageEmbeddings, imageEmbeddings.assetId.equalsExp(assets.id)),
    ])
      ..where(assets.type.equals('IMAGE') &
          assets.isTrashed.equals(false) &
          assets.isLocked.equals(false) &
          (assets.sharpnessScore.isNull() |
              assets.facesScanned.equals(false) |
              imageEmbeddings.assetId.isNull()));
    final rows = await query.get();
    return [
      for (final r in rows)
        (asset: r.readTable(assets), hatEmbedding: r.readTableOrNull(imageEmbeddings) != null),
    ];
  }

  /// Bild-Assets ohne Schärfe-Score – für den nachträglichen Lauf in den
  /// Werkzeugen. Gesperrte Fotos ausgenommen, siehe [assetsForOcrBackfill].
  Future<List<AssetData>> assetsForBlurBackfill() => (select(assets)
        ..where((t) =>
            t.type.equals('IMAGE') &
            t.isTrashed.equals(false) &
            t.isLocked.equals(false) &
            t.sharpnessScore.isNull()))
      .get();

  /// Zählvariante von [assetsForBlurBackfill], siehe [countLocationBackfill].
  Future<int> countBlurBackfill() => _countWhere(assets.type.equals('IMAGE') &
      assets.isTrashed.equals(false) &
      assets.isLocked.equals(false) &
      assets.sharpnessScore.isNull());

  /// Assets für den XMP-Sidecar-Export (Bibliothek + Backup) – bewusst OHNE
  /// gesperrte Assets: ein Sidecar würde Beschreibung/GPS/Tags im Klartext
  /// neben die (im Falle der Bibliothek noch verschlüsselte, im Falle des
  /// Backups gar nicht erst kopierte) Originaldatei legen und damit genau
  /// die Vertraulichkeit unterlaufen, wegen der das Foto gesperrt wurde –
  /// exakt dieselbe `isLocked`-Ausnahme wie bei [assetsNotBackedUp]. Beim
  /// manuellen Export (siehe ExportService.exportAsset) gilt das NICHT: dort
  /// hat der Nutzer das Entschlüsseln/Exportieren bereits aktiv angestoßen.
  Future<List<AssetData>> assetsForXmpExport() =>
      (select(assets)..where((t) => t.isTrashed.equals(false) & t.isLocked.equals(false))).get();

  /// Zählvariante von [assetsForXmpExport], siehe [countLocationBackfill].
  Future<int> countXmpExport() =>
      _countWhere(assets.isTrashed.equals(false) & assets.isLocked.equals(false));

  /// Noch unbewertete Fotos/Videos für den Sichtungs-Modus (Culling) –
  /// bewusst `rating == 0` statt eines eigenen "gesichtet"-Flags: sobald ein
  /// Foto eine Bewertung (auch 0 Sterne explizit gesetzt gäbe es nicht, da
  /// die Sternereihe bei erneutem Tippen auf 0 zurücksetzt) oder eine
  /// Ablehnung (Papierkorb) erhalten hat, verschwindet es automatisch aus
  /// dieser Liste. Neueste zuerst, da frisch importierte Fotos der
  /// Hauptanwendungsfall sind.
  Future<List<AssetData>> assetsForCulling({int limit = 500}) => (select(assets)
        ..where((t) =>
            t.rating.equals(0) & t.isTrashed.equals(false) & t.isLocked.equals(false))
        ..orderBy([(t) => OrderingTerm.desc(t.fileCreatedAt)])
        ..limit(limit))
      .get();

  /// Setzt die per Umkehr-Geokodierung ermittelten Orts-Namen eines Assets
  /// (siehe ReverseGeocoder) – beim Import automatisch (falls der
  /// GeoNames-Datensatz bereits heruntergeladen ist) oder nachträglich über
  /// das Werkzeug "Orte auflösen".
  Future<void> setLocationNames(
    String assetId, {
    String? country,
    String? state,
    required String city,
  }) =>
      (update(assets)..where((t) => t.id.equals(assetId))).write(AssetsCompanion(
        locationCountry: Value(country),
        locationState: Value(state),
        locationCity: Value(city),
      ));

  /// Fotos mit bekanntem GPS-Ort, aber noch ohne aufgelösten Orts-Namen – für
  /// das nachträgliche Auflösen (Werkzeuge) sowie den erstmaligen Lauf,
  /// nachdem der GeoNames-Datensatz heruntergeladen wurde.
  Future<List<AssetData>> assetsForLocationNameBackfill() => (select(assets)
        ..where((t) =>
            t.isTrashed.equals(false) &
            t.latitude.isNotNull() &
            t.longitude.isNotNull() &
            t.locationCountry.isNull()))
      .get();

  /// Zählvariante von [assetsForLocationNameBackfill], siehe [countLocationBackfill].
  Future<int> countLocationNameBackfill() => _countWhere(assets.isTrashed.equals(false) &
      assets.latitude.isNotNull() &
      assets.longitude.isNotNull() &
      assets.locationCountry.isNull());

  /// Alle nicht gelöschten Assets mit aufgelöstem Orts-Namen (Land/
  /// Bundesland/Stadt), neueste zuerst – für die "Erkannte Orte"-Sektion im
  /// Erkunden-Tab. Die Gruppierung zu einem repräsentativen Foto je Ort
  /// (erstes Vorkommen = zeitlich aktuellstes Foto dieses Orts) übernimmt der
  /// Aufrufer, da sie reine Präsentationslogik ist.
  Future<List<AssetData>> assetsWithResolvedLocation() => (select(assets)
        ..where((t) =>
            t.isTrashed.equals(false) &
            t.isLocked.equals(false) &
            t.locationCity.isNotNull() &
            // Sonst würde das .mov eines Live-Photos als eigenes Foto am
            // selben Ort mitgezählt (siehe searchAssets).
            _isPrimaryGridEntry(t))
        ..orderBy([(t) => OrderingTerm.desc(t.fileCreatedAt)]))
      .get();

  /// Alle nicht gelöschten Assets mit bekanntem Ort – für die Kartenansicht.
  Future<List<AssetData>> assetsWithLocation() => (select(assets)
        ..where((t) =>
            t.isTrashed.equals(false) &
            t.isLocked.equals(false) &
            t.latitude.isNotNull() &
            t.longitude.isNotNull() &
            _isPrimaryGridEntry(t)))
      .get();

  /// Alle Fotos/Videos, die exakt heute vor 1, 2, 3 … Jahren aufgenommen
  /// wurden (Monat+Tag, unabhängig vom Aufnahmejahr) – für die
  /// "Erinnerungen"-Sektion im Erkunden-Tab, analog zu "Vor X Jahren" in
  /// Google Fotos/Apple Fotos. Filtert clientseitig statt per SQL-
  /// Datumsfunktion: bei den für eine private Bibliothek üblichen
  /// Foto-Mengen (nicht Millionen) unproblematisch und deutlich einfacher
  /// als SQLite-spezifisches Datums-Handling in reinem SQL.
  Future<List<AssetData>> assetsOnThisDay(DateTime today) async {
    final all = await (select(assets)
          ..where((t) =>
              t.isTrashed.equals(false) &
              t.isLocked.equals(false) &
              _isPrimaryGridEntry(t)))
        .get();
    final matches = all
        .where((a) =>
            a.fileCreatedAt.month == today.month &&
            a.fileCreatedAt.day == today.day &&
            a.fileCreatedAt.year != today.year)
        .toList()
      ..sort((a, b) => b.fileCreatedAt.compareTo(a.fileCreatedAt));
    return matches;
  }

  /// Ersetzt Original-Datei (Pfad + Prüfsumme) eines Assets nach einer
  /// Bildbearbeitung (Zuschneiden/Drehen/Spiegeln, siehe ImageEditorScreen).
  /// Löscht eine ggf. vorhandene konvertierte Vorschau (HEIC/RAW & Co.):
  /// nach der Bearbeitung ist die neue Originaldatei selbst bereits ein
  /// direkt darstellbares JPEG.
  Future<void> setEditedAssetFile(String assetId, {required String relativePath, required String checksum}) =>
      (update(assets)..where((t) => t.id.equals(assetId))).write(AssetsCompanion(
        relativePath: Value(relativePath),
        checksum: Value(checksum),
        previewRelativePath: const Value(null),
        // Ein evtl. vorhandenes entwickeltes Bild wurde für die ALTE
        // Pixel-Grundlage berechnet (vor Zuschnitt/Drehung) und würde nach
        // dem destruktiven Bearbeiten falschen Inhalt zeigen – die
        // DevelopSettings-Zeile selbst bleibt bewusst bestehen (der Nutzer
        // müsste sie sonst nach jedem Zuschnitt neu einstellen), nur der
        // veraltete gerenderte Cache wird hier zurückgesetzt.
        developedRelativePath: const Value(null),
      ));

  /// Setzt den ursprünglichen, für Menschen lesbaren Dateinamen – u.a. nach
  /// einem Restore aus einem Backup nötig: der Reimport dort liest den
  /// Namen zunächst aus dem Backup-Pfad (`originals/{yyyy}/{mm}/{id}.ext`,
  /// also der Asset-UUID statt des Originalnamens), erst
  /// [BackupService._applyMetadataExport] korrigiert ihn anschließend
  /// anhand von metadata.json.
  Future<void> setOriginalFileName(String assetId, String name) =>
      (update(assets)..where((t) => t.id.equals(assetId)))
          .write(AssetsCompanion(originalFileName: Value(name)));

  // ---------------------------------------------------------------------
  // Live Photos (Standbild <-> Video-Verknüpfung)
  // ---------------------------------------------------------------------

  /// Alle noch nicht verknüpften, nicht gelöschten Assets eines Typs – für
  /// den Abgleich beim Import, ob ein passender Live-Photo-Partner (gleicher
  /// Dateiname, anderer Typ) schon in der Bibliothek liegt.
  Future<List<AssetData>> unlinkedAssetsOfType(String type) => (select(assets)
        ..where((t) =>
            t.type.equals(type) & t.isTrashed.equals(false) & t.linkedAssetId.isNull()))
      .get();

  /// Zählvariante von [unlinkedAssetsOfType], siehe [countLocationBackfill].
  Future<int> countUnlinkedAssetsOfType(String type) =>
      _countWhere(assets.type.equals(type) & assets.isTrashed.equals(false) & assets.linkedAssetId.isNull());

  Future<void> linkAssets(String idA, String idB) async {
    await (update(assets)..where((t) => t.id.equals(idA)))
        .write(AssetsCompanion(linkedAssetId: Value(idB)));
    await (update(assets)..where((t) => t.id.equals(idB)))
        .write(AssetsCompanion(linkedAssetId: Value(idA)));
  }

  // ---------------------------------------------------------------------
  // Serien-/Burst-Stapel (siehe StackReviewScreen, findBurstGroups)
  // ---------------------------------------------------------------------

  /// Fasst [assetIds] zu einem neuen Stapel zusammen: [coverAssetId] (muss in
  /// [assetIds] enthalten sein) wird Titelbild (`isStackCover = true`,
  /// `stackSize` = Gesamtzahl) und bleibt allein in Timeline & Co. sichtbar
  /// (siehe die `stackId`/`isStackCover`-Filter dort), die übrigen
  /// Mitglieder werden aus der Rasteransicht ausgeblendet. [stackId] wird
  /// vom Aufrufer erzeugt (Muster wie `createSavedSearch`/`createAlbum`).
  Future<void> createStack(String stackId, List<String> assetIds, String coverAssetId) async {
    assert(assetIds.contains(coverAssetId));
    await batch((b) {
      for (final id in assetIds) {
        b.update(
          assets,
          AssetsCompanion(
            stackId: Value(stackId),
            isStackCover: Value(id == coverAssetId),
            stackSize: id == coverAssetId ? Value(assetIds.length) : const Value(null),
          ),
          where: (t) => t.id.equals(id),
        );
      }
    });
  }

  /// Löst einen Stapel wieder auf ("Serie auflösen") – alle Mitglieder
  /// werden wieder einzeln sichtbar.
  Future<void> unstackAssets(String stackId) => (update(assets)..where((t) => t.stackId.equals(stackId)))
      .write(const AssetsCompanion(stackId: Value(null), isStackCover: Value(false), stackSize: Value(null)));

  Future<List<AssetData>> assetsInStack(String stackId) =>
      (select(assets)..where((t) => t.stackId.equals(stackId))).get();

  /// Alle Assets (Fotos und Videos), die für eine (erneute) Thumbnail-/
  /// Vorschau-Erzeugung infrage kommen. Bei [onlyMissing] nur Assets ohne
  /// Thumbnail (z.B. HEIC-Fotos, die vor Einbindung der nativen
  /// Bildkonvertierung importiert wurden, oder Videos, die vor Einführung
  /// der Video-Thumbnail-Erzeugung importiert wurden).
  Future<List<AssetData>> assetsForThumbnailRegen({required bool onlyMissing}) {
    // Läuft absichtlich auch über gesperrte Assets: die gesperrte
    // Ordner-Ansicht braucht ebenfalls funktionierende Thumbnails.
    final query = select(assets)..where((t) => t.isTrashed.equals(false));
    if (onlyMissing) {
      query.where((t) => t.thumbnailRelativePath.isNull());
    }
    return query.get();
  }

  /// Zählvariante von [assetsForThumbnailRegen], siehe [countLocationBackfill].
  Future<int> countThumbnailRegen({required bool onlyMissing}) => _countWhere(onlyMissing
      ? assets.isTrashed.equals(false) & assets.thumbnailRelativePath.isNull()
      : assets.isTrashed.equals(false));

  /// Für die Bibliotheks-Integritätsprüfung (IntegrityCheckScreen): bewusst
  /// vollständig ungefiltert (auch gelöscht/gesperrt), da all diese Assets
  /// weiterhin echte Dateien auf der Platte referenzieren, die geprüft
  /// werden müssen.
  Future<List<AssetData>> allAssetsForIntegrityCheck() => select(assets).get();

  /// Löscht NUR den (dann fehlenden) Datei-Pfad einer abgeleiteten Datei,
  /// OHNE die zugehörigen Einstellungen zu verwerfen – anders als
  /// [resetDevelopSettings]/[resetVideoTrim], die bewusst auch die
  /// Regler-Werte zurücksetzen. Für die Bibliotheks-Integritätsprüfung: das
  /// Original ist ja noch da, die Datei lässt sich (mit denselben
  /// Einstellungen) einfach erneut rendern.
  Future<void> clearMissingThumbnailPath(String assetId) =>
      (update(assets)..where((t) => t.id.equals(assetId)))
          .write(const AssetsCompanion(thumbnailRelativePath: Value(null)));

  Future<void> clearMissingPreviewPath(String assetId) =>
      (update(assets)..where((t) => t.id.equals(assetId)))
          .write(const AssetsCompanion(previewRelativePath: Value(null)));

  Future<void> clearMissingDevelopedPath(String assetId) =>
      (update(assets)..where((t) => t.id.equals(assetId)))
          .write(const AssetsCompanion(developedRelativePath: Value(null)));

  Future<void> clearMissingTrimmedPath(String assetId) =>
      (update(assets)..where((t) => t.id.equals(assetId)))
          .write(const AssetsCompanion(trimmedRelativePath: Value(null)));

  Future<void> clearMissingRestoredPath(String assetId) =>
      (update(assets)..where((t) => t.id.equals(assetId)))
          .write(const AssetsCompanion(restoredRelativePath: Value(null)));

  /// Löscht nur den fehlenden Crop-Pfad eines Gesichts, die Zuordnung zur
  /// Person und das Embedding bleiben erhalten (der Crop ist nur eine
  /// zwischengespeicherte Vorschau).
  Future<void> clearMissingFaceCropPath(String faceId) =>
      (update(faces)..where((t) => t.id.equals(faceId)))
          .write(const FacesCompanion(cropRelativePath: Value(null)));

  Future<void> updateThumbnailInfo(
    String assetId, {
    String? thumbnailRelativePath,
    String? previewRelativePath,
    int? widthPx,
    int? heightPx,
    double? durationSeconds,
  }) =>
      (update(assets)..where((t) => t.id.equals(assetId))).write(AssetsCompanion(
        thumbnailRelativePath:
            thumbnailRelativePath != null ? Value(thumbnailRelativePath) : const Value.absent(),
        previewRelativePath:
            previewRelativePath != null ? Value(previewRelativePath) : const Value.absent(),
        widthPx: widthPx != null ? Value(widthPx) : const Value.absent(),
        heightPx: heightPx != null ? Value(heightPx) : const Value.absent(),
        durationSeconds: durationSeconds != null ? Value(durationSeconds) : const Value.absent(),
      ));

  // -----------------------------------------------------------------------
  // Nicht-destruktive Entwicklung (DevelopScreen)
  // -----------------------------------------------------------------------

  Future<DevelopSettingsData?> developSettingsForAsset(String assetId) =>
      (select(developSettings)..where((t) => t.assetId.equals(assetId))).getSingleOrNull();

  /// Speichert die Entwicklungs-Einstellungen und das dazu gerenderte Bild
  /// in einer Transaktion, damit `Assets.developedRelativePath` nie auf
  /// eine DevelopSettings-Zeile zeigt, die (durch einen Fehler mittendrin)
  /// gar nicht existiert. Schiebt zuvor den bisherigen Stand (falls
  /// vorhanden) in [DevelopHistory] – ein einfacher, linearer Verlauf ohne
  /// Sonderfall-Restore-Pfad: lädt der Nutzer später einen Verlaufs-Eintrag
  /// in die Regler zurück und speichert erneut, landet der gerade ersetzte
  /// Stand wieder ganz normal hier in der Historie.
  Future<void> saveDevelopResult(
    String assetId, {
    required DevelopSettingsCompanion settings,
    required String developedRelativePath,
  }) =>
      transaction(() async {
        final previous =
            await (select(developSettings)..where((t) => t.assetId.equals(assetId))).getSingleOrNull();
        if (previous != null) {
          await into(developHistory).insert(DevelopHistoryCompanion.insert(
            assetId: assetId,
            exposure: previous.exposure,
            temperature: Value(previous.temperature),
            tint: Value(previous.tint),
            contrast: previous.contrast,
            shadows: previous.shadows,
            sharpness: previous.sharpness,
            noiseReduction: previous.noiseReduction,
            lensCorrectionEnabled: previous.lensCorrectionEnabled,
            toneCurveJson: Value(previous.toneCurveJson),
            colorMixerJson: Value(previous.colorMixerJson),
            createdAt: DateTime.now(),
          ));
          await _pruneDevelopHistory(assetId);
        }
        await into(developSettings).insertOnConflictUpdate(settings);
        await (update(assets)..where((t) => t.id.equals(assetId)))
            .write(AssetsCompanion(developedRelativePath: Value(developedRelativePath)));
      });

  /// Begrenzt [DevelopHistory] auf die neuesten [keep] Einträge pro Asset,
  /// damit die Tabelle bei Nutzern, die häufig speichern, nicht unbegrenzt
  /// wächst. Sortiert nach der Auto-Increment-`id` statt `createdAt` – die
  /// steigt garantiert streng mit jedem Insert, während zwei sehr schnell
  /// aufeinanderfolgende Speicher-Vorgänge (z.B. in Tests) denselben
  /// `DateTime.now()`-Millisekundenwert treffen könnten.
  Future<void> _pruneDevelopHistory(String assetId, {int keep = 10}) async {
    final rows = await (select(developHistory)
          ..where((t) => t.assetId.equals(assetId))
          ..orderBy([(t) => OrderingTerm.desc(t.id)]))
        .get();
    if (rows.length <= keep) return;
    final idsToDelete = rows.skip(keep).map((r) => r.id).toList();
    await (delete(developHistory)..where((t) => t.id.isIn(idsToDelete))).go();
  }

  /// Vergangene Entwickeln-Stände eines Assets, neueste zuerst (siehe
  /// [_pruneDevelopHistory] zur Sortierung nach `id` statt `createdAt`) –
  /// für den "Verlauf"-Einstieg im DevelopScreen.
  Future<List<DevelopHistoryData>> developHistoryForAsset(String assetId) =>
      (select(developHistory)
            ..where((t) => t.assetId.equals(assetId))
            ..orderBy([(t) => OrderingTerm.desc(t.id)]))
          .get();

  /// Setzt ein Asset auf unentwickelt zurück (Regler-"Zurücksetzen") – der
  /// Aufrufer löscht die zugehörige gerenderte Datei selbst von der Platte.
  Future<void> resetDevelopSettings(String assetId) => transaction(() async {
        await (delete(developSettings)..where((t) => t.assetId.equals(assetId))).go();
        await (update(assets)..where((t) => t.id.equals(assetId)))
            .write(const AssetsCompanion(developedRelativePath: Value(null)));
      });

  /// Alle entwickelten Assets samt ihrer Einstellungen – für das
  /// "Entwickelte Fotos neu rendern"-Werkzeug (z.B. nach einer Änderung an
  /// der Render-Logik selbst).
  Future<List<(AssetData, DevelopSettingsData)>> assetsWithDevelopSettings() async {
    final query = select(assets).join([
      innerJoin(developSettings, developSettings.assetId.equalsExp(assets.id)),
    ])
      // isLocked ausgeschlossen, damit das Bulk-Werkzeug ("Entwickelte
      // Fotos neu rendern") nie versucht, aus der verschlüsselten
      // Originaldatei eines gesperrten Assets zu rendern und das Ergebnis
      // unverschlüsselt in developed/ zu schreiben.
      ..where(assets.isTrashed.equals(false) & assets.isLocked.equals(false));
    final rows = await query.get();
    return rows.map((r) => (r.readTable(assets), r.readTable(developSettings))).toList();
  }

  /// Zählvariante von [assetsWithDevelopSettings], siehe [countLocationBackfill].
  Future<int> countAssetsWithDevelopSettings() async {
    final countExpr = assets.id.count();
    final query = selectOnly(assets).join([
      innerJoin(developSettings, developSettings.assetId.equalsExp(assets.id)),
    ])
      ..addColumns([countExpr])
      ..where(assets.isTrashed.equals(false) & assets.isLocked.equals(false));
    final row = await query.getSingle();
    return row.read<int>(countExpr) ?? 0;
  }

  // -----------------------------------------------------------------------
  // KI-Objektmasken (MaskEditor, SegmentationService)
  // -----------------------------------------------------------------------

  /// Masken eines Assets in Erstellreihenfolge – der native Renderer
  /// (developImage) legt sie in genau dieser Reihenfolge übereinander.
  Future<List<DevelopMaskData>> masksForAsset(String assetId) =>
      (select(developMasks)
            ..where((t) => t.assetId.equals(assetId))
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .get();

  /// Für die Bibliotheks-Integritätsprüfung – ein einzelner Full-Table-Select
  /// statt N+1-Abfragen pro Asset.
  Future<List<DevelopMaskData>> allDevelopMasks() => select(developMasks).get();

  Future<int> createDevelopMask(DevelopMasksCompanion mask) => into(developMasks).insert(mask);

  /// Aktualisiert nur die Regler-Werte einer bereits vorhandenen Maske
  /// (Label/Maskendatei bleiben unverändert) – beim Speichern im
  /// Entwickeln-Screen, analog zu [saveDevelopResult] für die globalen
  /// Regler.
  Future<void> updateDevelopMaskAdjustments(int id, DevelopMasksCompanion adjustments) =>
      (update(developMasks)..where((t) => t.id.equals(id))).write(adjustments);

  /// Aktualisiert die Geometrie einer Vektor-Maske nach erneutem Bearbeiten
  /// ihrer Form (siehe MaskShapeDefinition/vector_mask_service.dart) – die
  /// gerenderte PNG-Datei selbst überschreibt der Aufrufer direkt (Muster
  /// wie [createDevelopMask]), hier wird nur die Quelle der Wahrheit
  /// (`shapeDefinitionJson`) aktualisiert.
  Future<void> updateDevelopMaskShape(int id, String shapeDefinitionJson) =>
      (update(developMasks)..where((t) => t.id.equals(id)))
          .write(DevelopMasksCompanion(shapeDefinitionJson: Value(shapeDefinitionJson)));

  /// "Maske entfernen" – der Aufrufer löscht die zugehörige PNG-Datei selbst
  /// von der Platte (Muster wie [resetDevelopSettings]/[resetVideoTrim]).
  Future<void> deleteDevelopMask(int id) => (delete(developMasks)..where((t) => t.id.equals(id))).go();

  // -----------------------------------------------------------------------
  // KI-Restaurierung (RestoreQueueService, RestoreService)
  // -----------------------------------------------------------------------

  Future<void> createRestoreJob(RestoreJobsCompanion job) => into(restoreJobs).insert(job);

  /// Alle Aufträge, neueste zuerst – Grundlage für den Warteschlangen-
  /// Indikator (nur `queued`/`running` gefiltert vom Aufrufer) und den
  /// Warteschlangen-Screen (alle Status).
  Stream<List<RestoreJobData>> watchRestoreJobs() =>
      (select(restoreJobs)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();

  /// Der älteste noch wartende Auftrag – FIFO, ein Auftrag gleichzeitig
  /// (siehe RestoreQueueService: parallele ONNX-Inferenzen würden sich nur
  /// um CPU/GPU streiten).
  Future<RestoreJobData?> nextQueuedRestoreJob() => (select(restoreJobs)
        ..where((t) => t.status.equals('queued'))
        ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
        ..limit(1))
      .getSingleOrNull();

  /// Bereits wartender/laufender Auftrag für dieses Asset, falls vorhanden
  /// – verhindert in [RestoreQueueService.enqueue] doppelte Aufträge für
  /// dasselbe Foto (z.B. durch einen Doppelklick).
  Future<RestoreJobData?> activeRestoreJobForAsset(String assetId) => (select(restoreJobs)
        ..where((t) => t.assetId.equals(assetId) & t.status.isIn(['queued', 'running']))
        ..limit(1))
      .getSingleOrNull();

  Future<void> updateRestoreJobProgress(String id, int tilesDone, int tilesTotal) =>
      (update(restoreJobs)..where((t) => t.id.equals(id))).write(
        RestoreJobsCompanion(tilesDone: Value(tilesDone), tilesTotal: Value(tilesTotal)),
      );

  Future<void> markRestoreJobStatus(String id, String status, {String? errorMessage}) =>
      (update(restoreJobs)..where((t) => t.id.equals(id))).write(
        RestoreJobsCompanion(
          status: Value(status),
          errorMessage: Value(errorMessage),
          completedAt: Value(status == 'queued' || status == 'running' ? null : DateTime.now()),
        ),
      );

  Future<void> deleteRestoreJob(String id) => (delete(restoreJobs)..where((t) => t.id.equals(id))).go();

  /// Schließt einen erfolgreichen Auftrag transaktional ab: setzt
  /// `Assets.restoredRelativePath` UND markiert den Auftrag `done` in einem
  /// Zug (Muster: [saveDevelopResult]) – verhindert einen inkonsistenten
  /// Zwischenstand (Job "done", aber Asset zeigt noch nicht auf das
  /// Ergebnis, oder umgekehrt).
  Future<void> completeRestoreJob(String jobId, String assetId, String restoredRelativePath) =>
      transaction(() async {
        await (update(assets)..where((t) => t.id.equals(assetId)))
            .write(AssetsCompanion(restoredRelativePath: Value(restoredRelativePath)));
        await (update(restoreJobs)..where((t) => t.id.equals(jobId)))
            .write(RestoreJobsCompanion(status: const Value('done'), completedAt: Value(DateTime.now())));
      });

  /// Crash-Safety: setzt beim App-Start jeden Auftrag, der beim letzten
  /// Beenden noch `running` war (die App wurde mitten in der Verarbeitung
  /// beendet/ist abgestürzt), zurück auf `queued` – ohne Teil-Kacheln zu
  /// persistieren, läuft er beim nächsten Warteschlangen-Durchlauf komplett
  /// neu. Siehe LibraryState.initialize().
  Future<void> resetStuckRunningRestoreJobs() =>
      (update(restoreJobs)..where((t) => t.status.equals('running'))).write(
        const RestoreJobsCompanion(status: Value('queued'), tilesDone: Value(0), tilesTotal: Value(0)),
      );

  // -----------------------------------------------------------------------
  // Nicht-destruktiver Video-Zuschnitt (VideoTrimScreen)
  // -----------------------------------------------------------------------

  Future<VideoTrimData?> videoTrimForAsset(String assetId) =>
      (select(videoTrims)..where((t) => t.assetId.equals(assetId))).getSingleOrNull();

  /// Speichert Start/Ende und das dazu geschnittene Video in einer
  /// Transaktion, analog zu [saveDevelopResult] – `Assets.trimmedRelativePath`
  /// zeigt nie auf eine VideoTrims-Zeile, die (durch einen Fehler
  /// mittendrin) gar nicht existiert.
  Future<void> saveVideoTrim(
    String assetId, {
    required double startSeconds,
    required double endSeconds,
    required String trimmedRelativePath,
  }) =>
      transaction(() async {
        await into(videoTrims).insertOnConflictUpdate(VideoTrimsCompanion.insert(
          assetId: assetId,
          startSeconds: startSeconds,
          endSeconds: endSeconds,
          updatedAt: DateTime.now(),
        ));
        await (update(assets)..where((t) => t.id.equals(assetId)))
            .write(AssetsCompanion(trimmedRelativePath: Value(trimmedRelativePath)));
      });

  /// Setzt ein Video auf den Originalausschnitt zurück (Zuschneiden-
  /// "Zurücksetzen") – der Aufrufer löscht die zugehörige geschnittene
  /// Datei selbst von der Platte.
  Future<void> resetVideoTrim(String assetId) => transaction(() async {
        await (delete(videoTrims)..where((t) => t.assetId.equals(assetId))).go();
        await (update(assets)..where((t) => t.id.equals(assetId)))
            .write(const AssetsCompanion(trimmedRelativePath: Value(null)));
      });

  // -----------------------------------------------------------------------
  // Alben
  // -----------------------------------------------------------------------

  Stream<List<AlbumData>> watchAlbums() =>
      (select(albums)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();

  Future<void> createAlbum(AlbumsCompanion album) => into(albums).insert(album);

  Future<void> addAssetsToAlbum(String albumId, List<String> assetIds) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(
        albumAssets,
        assetIds.map((id) => AlbumAssetsCompanion.insert(albumId: albumId, assetId: id)),
      );
    });
  }

  Future<void> removeAssetFromAlbum(String albumId, String assetId) =>
      (delete(albumAssets)
            ..where((t) => t.albumId.equals(albumId) & t.assetId.equals(assetId)))
          .go();

  Stream<List<AssetData>> watchAlbumAssets(String albumId) {
    final query = select(assets).join([
      innerJoin(albumAssets, albumAssets.assetId.equalsExp(assets.id)),
    ])
      ..where(albumAssets.albumId.equals(albumId))
      ..where(assets.isTrashed.equals(false))
      ..where(assets.isLocked.equals(false))
      ..where(_isPrimaryGridEntry(assets))
      ..orderBy([OrderingTerm.desc(assets.fileCreatedAt)]);
    return query.watch().map((rows) => rows.map((r) => r.readTable(assets)).toList());
  }

  /// Einmalige (nicht-reaktive) Variante von [watchAlbumAssets], u.a. für den
  /// Metadaten-Export beim Backup und die Album-Vorschau im Erkunden-Tab –
  /// deshalb ebenfalls ohne gelöschte/gesperrte Assets, analog zu
  /// [watchAlbumAssets].
  Future<List<AssetData>> assetsInAlbumOnce(String albumId) async {
    final query = select(assets).join([
      innerJoin(albumAssets, albumAssets.assetId.equalsExp(assets.id)),
    ])
      ..where(albumAssets.albumId.equals(albumId) &
          assets.isTrashed.equals(false) &
          assets.isLocked.equals(false) &
          _isPrimaryGridEntry(assets));
    final rows = await query.get();
    return rows.map((r) => r.readTable(assets)).toList();
  }

  // -----------------------------------------------------------------------
  // Tags & Textsuche
  // -----------------------------------------------------------------------

  Future<String> ensureTag(String name) async {
    final existing =
        await (select(tags)..where((t) => t.name.equals(name))).getSingleOrNull();
    if (existing != null) return existing.id;
    final id = name.hashCode.toRadixString(36) + DateTime.now().microsecondsSinceEpoch.toString();
    await into(tags).insert(TagsCompanion.insert(id: id, name: name));
    return id;
  }

  Future<void> tagAsset(String assetId, String tagName) async {
    final tagId = await ensureTag(tagName);
    await into(assetTags).insertOnConflictUpdate(
      AssetTagsCompanion.insert(assetId: assetId, tagId: tagId),
    );
  }

  /// Hängt denselben Tag an mehrere Assets. Der Tag wird einmal angelegt
  /// (statt je Foto nachgeschlagen), die Zuordnungen gehen als ein Stapel
  /// in einer Transaktion hinaus.
  Future<void> tagAssetsBulk(List<String> assetIds, String tagName) async {
    final tagId = await ensureTag(tagName);
    await batch((b) => b.insertAllOnConflictUpdate(
          assetTags,
          [
            for (final id in assetIds)
              AssetTagsCompanion.insert(assetId: id, tagId: tagId),
          ],
        ));
  }

  Future<void> untagAsset(String assetId, String tagId) => (delete(assetTags)
        ..where((t) => t.assetId.equals(assetId) & t.tagId.equals(tagId)))
      .go();

  /// Alle Tags der Bibliothek – für die Mehrfachauswahl im
  /// Suchoptionen-Panel.
  Stream<List<TagData>> watchAllTags() =>
      (select(tags)..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();

  /// Direkte Tag-Zuordnung per ID statt per Name (anders als [tagAsset], das
  /// den Tag bei Bedarf erst per Name anlegt) – für das Anwenden eines
  /// Kamera-Presets, dessen Tags bereits als IDs gespeichert sind, ohne
  /// zusätzlichen Namens-Lookup.
  Future<void> tagAssetById(String assetId, String tagId) => into(assetTags)
      .insertOnConflictUpdate(AssetTagsCompanion.insert(assetId: assetId, tagId: tagId));

  // -----------------------------------------------------------------------
  // Export-Voreinstellungen (benannte Ausgabe-Vorgaben)
  // -----------------------------------------------------------------------

  Stream<List<ExportPresetData>> watchExportPresets() =>
      (select(exportPresets)..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();

  Future<List<ExportPresetData>> alleExportPresets() =>
      (select(exportPresets)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();

  /// Legt eine Vorgabe an oder aktualisiert sie. Der Aufrufer setzt [id] nur
  /// beim Bearbeiten; ohne [id] vergibt SQLite eine neue.
  ///
  /// Der Konflikt wird über die Nummer aufgelöst, nicht über den Namen: Ein
  /// zweiter Eintrag mit belegtem Namen soll NICHT stillschweigend den
  /// ersten überschreiben, sondern an der `unique`-Spalte scheitern. Wer
  /// speichert, fragt vorher [exportPresetNameVergeben] und sagt es dem
  /// Nutzer – siehe ExportPresetsScreen.
  Future<void> upsertExportPreset(ExportPresetsCompanion vorgabe) =>
      into(exportPresets).insertOnConflictUpdate(vorgabe);

  /// Ob [name] schon vergeben ist – [ausserId] nimmt die gerade bearbeitete
  /// Vorgabe aus, sonst kollidierte jede Vorgabe mit sich selbst.
  Future<bool> exportPresetNameVergeben(String name, {int? ausserId}) async {
    final abfrage = select(exportPresets)..where((t) => t.name.equals(name));
    if (ausserId != null) {
      abfrage.where((t) => t.id.equals(ausserId).not());
    }
    return (await abfrage.get()).isNotEmpty;
  }

  Future<void> deleteExportPreset(int id) =>
      (delete(exportPresets)..where((t) => t.id.equals(id))).go();

  // -----------------------------------------------------------------------
  // Kamera-Presets (automatische Aktionen beim Import je erkannter Kamera)
  // -----------------------------------------------------------------------

  Stream<List<CameraPresetData>> watchCameraPresets() => (select(cameraPresets)
        ..orderBy([(t) => OrderingTerm.asc(t.cameraMake), (t) => OrderingTerm.asc(t.cameraModel)]))
      .watch();

  /// Tag-Zuordnungen ALLER Presets auf einmal (presetId -> Tag-IDs), reaktiv
  /// – für die Presets-Liste, die sonst pro sichtbarer Kachel eine eigene
  /// Abfrage bräuchte (N+1, und bei einem einfachen `FutureBuilder` pro
  /// Kachel entweder bei jedem Rebuild neu abgefragt oder – bei
  /// zwischengespeichertem Future – nach einer Tag-Änderung veraltet
  /// stehenbleibt). Die Tabelle selbst ist immer klein (Presets × Tags pro
  /// Preset), ein voller Select ist hier günstiger als N Einzelabfragen.
  Stream<Map<String, List<String>>> watchAllCameraPresetTagIds() {
    return select(cameraPresetTags).watch().map((rows) {
      final map = <String, List<String>>{};
      for (final row in rows) {
        map.putIfAbsent(row.presetId, () => []).add(row.tagId);
      }
      return map;
    });
  }

  Future<void> upsertCameraPreset(CameraPresetsCompanion preset) =>
      into(cameraPresets).insertOnConflictUpdate(preset);

  Future<void> deleteCameraPreset(String id) async {
    await (delete(cameraPresetTags)..where((t) => t.presetId.equals(id))).go();
    await (delete(cameraPresets)..where((t) => t.id.equals(id))).go();
  }

  Future<List<String>> tagIdsForCameraPreset(String presetId) async {
    final rows = await (select(cameraPresetTags)..where((t) => t.presetId.equals(presetId))).get();
    return rows.map((r) => r.tagId).toList();
  }

  /// Ersetzt die komplette Tag-Zuordnung eines Presets auf einmal (statt
  /// einzelner Hinzufügen-/Entfernen-Aufrufe) – der Editor übergibt bei
  /// jedem Speichern die vollständige, gewünschte Tag-Menge.
  Future<void> setCameraPresetTags(String presetId, List<String> tagIds) async {
    await (delete(cameraPresetTags)..where((t) => t.presetId.equals(presetId))).go();
    if (tagIds.isEmpty) return;
    await batch((b) {
      b.insertAll(
        cameraPresetTags,
        tagIds.map((tagId) => CameraPresetTagsCompanion.insert(presetId: presetId, tagId: tagId)),
      );
    });
  }

  /// Das Preset für eine erkannte Kamera, falls eines existiert – `null`,
  /// solange Hersteller/Modell unbekannt sind (z.B. Videos ohne EXIF-Kamera)
  /// oder kein Preset für genau diese Kombination angelegt wurde. Bewusst
  /// über `.get()` + erste Zeile statt `getSingleOrNull()`, damit ein aus
  /// Versehen doppelt angelegtes Preset für dieselbe Kamera nicht den
  /// gesamten Importvorgang mit einer Exception abbricht.
  Future<CameraPresetData?> cameraPresetFor(String? cameraMake, String? cameraModel) async {
    if (cameraMake == null || cameraModel == null) return null;
    final rows = await (select(cameraPresets)
          ..where((t) => t.cameraMake.equals(cameraMake) & t.cameraModel.equals(cameraModel))
          ..limit(1))
        .get();
    return rows.isEmpty ? null : rows.first;
  }

  // -----------------------------------------------------------------------
  // Automatisierungs-Regelwerk (Verallgemeinerung der Kamera-Presets auf
  // Ort/Datum/KI-Tag, siehe AutomationRules-Tabelle)
  // -----------------------------------------------------------------------

  Stream<List<AutomationRuleData>> watchAutomationRules() =>
      (select(automationRules)..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();

  /// Alle Regeln auf einmal statt eines gezielten Lookups (anders als
  /// [cameraPresetFor]): die Bedingungen sind zu unterschiedlich geformt
  /// (Umkreis/Datumsbereich/KI-Tag), um sie in einem einzelnen SQL-WHERE
  /// zusammenzufassen – die Tabelle ist wie CameraPresets klein, ein voller
  /// Scan mit Auswertung in Dart (siehe LibraryState.applyAutomationRules)
  /// ist hier güngstiger als der Aufwand einer typspezifischen Abfrage.
  Future<List<AutomationRuleData>> allAutomationRules() => select(automationRules).get();

  /// Tag-Zuordnungen ALLER Regeln auf einmal, reaktiv – siehe
  /// [watchAllCameraPresetTagIds] für die Begründung (N+1/Veralten
  /// vermeiden).
  Stream<Map<String, List<String>>> watchAllAutomationRuleTagIds() {
    return select(automationRuleTags).watch().map((rows) {
      final map = <String, List<String>>{};
      for (final row in rows) {
        map.putIfAbsent(row.ruleId, () => []).add(row.tagId);
      }
      return map;
    });
  }

  Future<void> upsertAutomationRule(AutomationRulesCompanion rule) =>
      into(automationRules).insertOnConflictUpdate(rule);

  Future<void> deleteAutomationRule(String id) async {
    await (delete(automationRuleTags)..where((t) => t.ruleId.equals(id))).go();
    await (delete(automationRules)..where((t) => t.id.equals(id))).go();
  }

  Future<List<String>> tagIdsForAutomationRule(String ruleId) async {
    final rows = await (select(automationRuleTags)..where((t) => t.ruleId.equals(ruleId))).get();
    return rows.map((r) => r.tagId).toList();
  }

  /// Ersetzt die komplette Tag-Zuordnung einer Regel auf einmal, siehe
  /// [setCameraPresetTags].
  Future<void> setAutomationRuleTags(String ruleId, List<String> tagIds) async {
    await (delete(automationRuleTags)..where((t) => t.ruleId.equals(ruleId))).go();
    if (tagIds.isEmpty) return;
    await batch((b) {
      b.insertAll(
        automationRuleTags,
        tagIds.map((tagId) => AutomationRuleTagsCompanion.insert(ruleId: ruleId, tagId: tagId)),
      );
    });
  }

  Future<List<TagData>> tagsForAsset(String assetId) async {
    final query = select(tags).join([
      innerJoin(assetTags, assetTags.tagId.equalsExp(tags.id)),
    ])
      ..where(assetTags.assetId.equals(assetId));
    final rows = await query.get();
    return rows.map((r) => r.readTable(tags)).toList();
  }

  /// Tag-Namen ALLER Assets in einer einzigen Abfrage (assetId -> Tag-Namen)
  /// – für den Metadaten-Export beim Backup, damit nicht pro Foto eine
  /// eigene Datenbankabfrage nötig ist ([tagsForAsset] wäre dort ein
  /// N+1-Problem, das bei großen Bibliotheken spürbar Zeit kostet).
  Future<Map<String, List<String>>> allTagNamesByAssetId() async {
    final query = select(assetTags).join([
      innerJoin(tags, tags.id.equalsExp(assetTags.tagId)),
    ]);
    final rows = await query.get();
    final result = <String, List<String>>{};
    for (final row in rows) {
      final assetId = row.readTable(assetTags).assetId;
      final tagName = row.readTable(tags).name;
      result.putIfAbsent(assetId, () => []).add(tagName);
    }
    return result;
  }

  // -----------------------------------------------------------------------
  // KI-Tagging-Vokabular (AiTaggingService)
  // -----------------------------------------------------------------------

  /// Für die Einstellungen (reaktiv, damit Änderungen sofort sichtbar sind).
  Stream<List<AiTagVocabularyData>> watchAiTagVocabulary() =>
      (select(aiTagVocabulary)..orderBy([(t) => OrderingTerm.asc(t.term)])).watch();

  /// Idempotent (Muster: [ensureTag]) – ein Doppel-Tap auf "Hinzufügen"
  /// erzeugt keinen doppelten Eintrag und keinen UNIQUE-Constraint-Fehler.
  Future<void> addAiTagTerm(String term) async {
    final trimmed = term.trim();
    if (trimmed.isEmpty) return;
    final existing =
        await (select(aiTagVocabulary)..where((t) => t.term.equals(trimmed))).getSingleOrNull();
    if (existing != null) return;
    await into(aiTagVocabulary).insert(AiTagVocabularyCompanion.insert(term: trimmed));
  }

  Future<void> removeAiTagTerm(int id) =>
      (delete(aiTagVocabulary)..where((t) => t.id.equals(id))).go();

  /// Einmaliger, nicht-reaktiver Read für Aufrufer, die keinen Stream
  /// brauchen (Import-Pipeline, Backfill) – analog zu [tagsForAsset].
  Future<List<String>> aiTagVocabularyTerms() async {
    final rows =
        await (select(aiTagVocabulary)..orderBy([(t) => OrderingTerm.asc(t.term)])).get();
    return rows.map((r) => r.term).toList();
  }

  /// Kombinierte Suche über alle Filter des Suchoptionen-Panels (siehe
  /// [SearchFilters]) – alle aktiven Filter werden UND-verknüpft (z.B.
  /// Person UND Kamera UND Zeitraum), mehrere ausgewählte Personen bzw. Tags
  /// werden untereinander ebenfalls UND-verknüpft ("muss alle enthalten",
  /// nicht "mindestens einen").
  ///
  /// [restrictToIds] schränkt zusätzlich auf eine vorgegebene ID-Menge ein.
  ///
  /// Der "Kontext"-Modus (KI-Bildsuche) nutzt das bewusst NICHT mehr: Er
  /// filtert erst hier und rankt die Treffer danach über [ClipService].
  /// Andersherum – erst ranken, dann filtern – entschied das
  /// bibliotheksweite Top-N darüber, was die Filter überhaupt noch zu sehen
  /// bekamen, und ließ Treffer in kleinen Alben verschwinden (Audit-Fund).
  /// Der Suchtext selbst wird unten im Kontext-Modus absichtlich nicht als
  /// LIKE-Bedingung angewendet – dafür ist gerade das Embedding zuständig.
  Future<List<AssetData>> searchAssets(SearchFilters filters, {List<String>? restrictToIds}) {
    final query = select(assets)
      ..where((t) =>
          t.isTrashed.equals(false) &
          t.isLocked.equals(false) &
          // Live-Photo-Partner (das .mov zu einem Standbild) und
          // nicht-Titelbild-Stapelmitglieder werden hier wie überall sonst
          // (Timeline, Alben, Kartenansicht) ausgeblendet – sichtbar/
          // abspielbar bleiben sie weiterhin über das verknüpfte Foto bzw.
          // das Titelbild, nur nicht als zusätzlicher, eigenständiger Treffer.
          _isPrimaryGridEntry(t));

    if (restrictToIds != null) {
      query.where((t) => t.id.isIn(restrictToIds));
    }

    final text = filters.query.trim();
    if (text.isNotEmpty && filters.textMode == SearchTextMode.filename) {
      query.where((t) => t.originalFileName.like('%$text%'));
    } else if (text.isNotEmpty && filters.textMode == SearchTextMode.description) {
      query.where((t) => t.description.like('%$text%'));
    } else if (text.isNotEmpty && filters.textMode == SearchTextMode.ocr) {
      query.where((t) => t.ocrText.like('%$text%'));
    } else if (text.isNotEmpty && filters.textMode == SearchTextMode.caption) {
      // Beide Fassungen: Wer die Übersetzung erst später einschaltet, hat
      // Fotos mit nur englischer und Fotos mit beiden Beschreibungen. Nur
      // in einer zu suchen liesse einen Teil der Bibliothek unauffindbar.
      query.where((t) => t.aiCaption.like('%$text%') | t.aiCaptionDe.like('%$text%'));
    }

    if (filters.cameraMake != null) {
      query.where((t) => t.cameraMake.equals(filters.cameraMake!));
    }
    if (filters.cameraModel != null) {
      query.where((t) => t.cameraModel.equals(filters.cameraModel!));
    }
    if (filters.lensModel != null) {
      query.where((t) => t.lensModel.equals(filters.lensModel!));
    }

    if (filters.locationCountry != null) {
      query.where((t) => t.locationCountry.equals(filters.locationCountry!));
    }
    if (filters.locationState != null) {
      query.where((t) => t.locationState.equals(filters.locationState!));
    }
    if (filters.locationCity != null) {
      query.where((t) => t.locationCity.equals(filters.locationCity!));
    }

    if (filters.startDate != null) {
      final start = filters.startDate!;
      query.where((t) => t.fileCreatedAt
          .isBiggerOrEqualValue(DateTime(start.year, start.month, start.day)));
    }
    if (filters.endDate != null) {
      final end = filters.endDate!;
      // Enddatum inklusive -> bis zum letzten Millisekunde des gewählten Tages.
      query.where((t) => t.fileCreatedAt
          .isSmallerOrEqualValue(DateTime(end.year, end.month, end.day, 23, 59, 59, 999)));
    }

    if (filters.mediaType == MediaTypeFilter.image) {
      query.where((t) => t.type.equals('IMAGE'));
    } else if (filters.mediaType == MediaTypeFilter.video) {
      query.where((t) => t.type.equals('VIDEO'));
    }

    if (filters.favoritesOnly) {
      query.where((t) => t.isFavorite.equals(true));
    }

    if (filters.notInAnyAlbum) {
      query.where((t) =>
          notExistsQuery(select(albumAssets)..where((aa) => aa.assetId.equalsExp(t.id))));
    }

    if (filters.minRating != null) {
      query.where((t) => t.rating.isBiggerOrEqualValue(filters.minRating!));
    }
    if (filters.colorLabels.isNotEmpty) {
      query.where((t) => t.colorLabel.isIn(filters.colorLabels));
    }
    if (filters.minIso != null) {
      query.where((t) => t.iso.isBiggerOrEqualValue(filters.minIso!));
    }
    if (filters.maxIso != null) {
      query.where((t) => t.iso.isSmallerOrEqualValue(filters.maxIso!));
    }
    if (filters.minFNumber != null) {
      query.where((t) => t.fNumber.isBiggerOrEqualValue(filters.minFNumber!));
    }
    if (filters.maxFNumber != null) {
      query.where((t) => t.fNumber.isSmallerOrEqualValue(filters.maxFNumber!));
    }
    if (filters.minFocalLengthMm != null) {
      query.where((t) => t.focalLengthMm.isBiggerOrEqualValue(filters.minFocalLengthMm!));
    }
    if (filters.maxFocalLengthMm != null) {
      query.where((t) => t.focalLengthMm.isSmallerOrEqualValue(filters.maxFocalLengthMm!));
    }
    if (filters.maxSharpnessScore != null) {
      query.where((t) => t.sharpnessScore.isSmallerOrEqualValue(filters.maxSharpnessScore!));
    }

    for (final personId in filters.personIds) {
      query.where((t) => existsQuery(
          select(faces)..where((f) => f.assetId.equalsExp(t.id) & f.personId.equals(personId))));
    }

    if (filters.noTag) {
      query.where(
          (t) => notExistsQuery(select(assetTags)..where((at) => at.assetId.equalsExp(t.id))));
    } else {
      for (final tagId in filters.tagIds) {
        query.where((t) => existsQuery(
            select(assetTags)..where((at) => at.assetId.equalsExp(t.id) & at.tagId.equals(tagId))));
      }
    }

    query.orderBy([(t) => OrderingTerm.desc(t.fileCreatedAt)]);
    return query.get();
  }

  /// Alle in der Bibliothek tatsächlich vorkommenden, nicht-leeren Werte
  /// einer Text-Spalte – für die Dropdowns im Suchoptionen-Panel (Kamera-
  /// Marke/-Modell/Objektiv), damit dort nur Werte auswählbar sind, die auch
  /// wirklich zu einem Treffer führen können.
  Future<List<String>> _distinctNonNullValues(GeneratedColumn<String> column) async {
    final query = selectOnly(assets, distinct: true)
      ..addColumns([column])
      ..where(column.isNotNull())
      ..orderBy([OrderingTerm.asc(column)]);
    final rows = await query.get();
    return rows.map((r) => r.read(column)!).toList();
  }

  Future<List<String>> distinctCameraMakes() => _distinctNonNullValues(assets.cameraMake);
  Future<List<String>> distinctCameraModels() => _distinctNonNullValues(assets.cameraModel);
  Future<List<String>> distinctLensModels() => _distinctNonNullValues(assets.lensModel);

  /// Alle in der Bibliothek bereits vorkommenden Kamera-Kombinationen
  /// (Hersteller + Modell zusammen, nicht unabhängig wie
  /// [distinctCameraMakes]/[distinctCameraModels]) – als Vorauswahl beim
  /// Anlegen eines Kamera-Presets (siehe CameraPresetsScreen), damit
  /// Tippfehler kein Preset erzeugen, das nie zu einem echten Foto passt.
  Future<List<(String, String)>> distinctCameras() async {
    final query = selectOnly(assets, distinct: true)
      ..addColumns([assets.cameraMake, assets.cameraModel])
      ..where(assets.cameraMake.isNotNull() & assets.cameraModel.isNotNull())
      ..orderBy([OrderingTerm.asc(assets.cameraMake), OrderingTerm.asc(assets.cameraModel)]);
    final rows = await query.get();
    return [
      for (final row in rows)
        (row.read<String>(assets.cameraMake)!, row.read<String>(assets.cameraModel)!),
    ];
  }

  Future<List<String>> distinctCountries() => _distinctNonNullValues(assets.locationCountry);

  /// Wie [distinctCountries], aber nur Bundesländer/Provinzen innerhalb eines
  /// bestimmten Landes – für das kaskadierende Land->Bundesland->Stadt-Dropdown
  /// im Suchoptionen-Panel (jede Ebene schränkt die darunterliegende ein).
  Future<List<String>> distinctStates(String country) async {
    final query = selectOnly(assets, distinct: true)
      ..addColumns([assets.locationState])
      ..where(assets.locationState.isNotNull() & assets.locationCountry.equals(country))
      ..orderBy([OrderingTerm.asc(assets.locationState)]);
    final rows = await query.get();
    return rows.map((r) => r.read(assets.locationState)!).toList();
  }

  /// Wie [distinctStates], aber Städte innerhalb eines bestimmten
  /// Bundeslands/einer Provinz.
  Future<List<String>> distinctCities(String state) async {
    final query = selectOnly(assets, distinct: true)
      ..addColumns([assets.locationCity])
      ..where(assets.locationCity.isNotNull() & assets.locationState.equals(state))
      ..orderBy([OrderingTerm.asc(assets.locationCity)]);
    final rows = await query.get();
    return rows.map((r) => r.read(assets.locationCity)!).toList();
  }

  // -----------------------------------------------------------------------
  // Gespeicherte Suchen ("Intelligente Alben")
  // -----------------------------------------------------------------------

  Future<void> createSavedSearch(String id, String name, SearchFilters filters) =>
      into(savedSearches).insert(SavedSearchesCompanion.insert(
        id: id,
        name: name,
        filtersJson: jsonEncode(filters.toJson()),
        createdAt: DateTime.now(),
      ));

  Stream<List<SavedSearchData>> watchSavedSearches() =>
      (select(savedSearches)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();

  Future<void> deleteSavedSearch(String id) =>
      (delete(savedSearches)..where((t) => t.id.equals(id))).go();

  /// Deserialisiert die bei [createSavedSearch] gespeicherten Filter. Ein
  /// beschädigtes JSON (sollte nicht vorkommen, aber die Datei liegt
  /// außerhalb der Kontrolle der App) liefert leere Filter statt die ganze
  /// App abstürzen zu lassen.
  SearchFilters decodeSavedSearchFilters(String filtersJson) {
    try {
      return SearchFilters.fromJson(jsonDecode(filtersJson) as Map<String, dynamic>);
    } catch (_) {
      return const SearchFilters();
    }
  }

  // -----------------------------------------------------------------------
  // Personen / Gesichter
  // -----------------------------------------------------------------------

  Stream<List<PersonData>> watchPeople() => select(people).watch();

  Stream<PersonData?> watchPerson(String id) =>
      (select(people)..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<void> createPerson(PeopleCompanion person) => into(people).insert(person);

  Future<void> insertFace(FacesCompanion face) => into(faces).insert(face);

  /// Unbenannte Gesichter für den "Unbenannte Gesichter"-Tab – über einen
  /// Join gegen Assets gefiltert, damit Gesichter aus gelöschten oder
  /// gesperrten Fotos dort nicht auftauchen (sonst würde ein Foto-Crop aus
  /// dem gesperrten Ordner beiläufig sichtbar, obwohl das zugehörige Foto
  /// selbst versteckt ist).
  Future<List<FaceData>> unassignedFaces({int limit = 200}) async {
    final query = select(faces).join([
      innerJoin(assets, assets.id.equalsExp(faces.assetId)),
    ])
      ..where(faces.personId.isNull() &
          faces.isIgnored.equals(false) &
          assets.isTrashed.equals(false) &
          assets.isLocked.equals(false))
      ..limit(limit);
    final rows = await query.get();
    return rows.map((r) => r.readTable(faces)).toList();
  }

  /// Unlimitierte Variante von [unassignedFaces] – ein vollständiger
  /// Clustering-Lauf (siehe face_clustering_service.dart) braucht alle
  /// unzugeordneten Gesichter, nicht nur die ersten 200 (Standard-Limit für
  /// die Rasteransicht im "Unbenannte Gesichter"-Tab).
  Future<List<FaceData>> allUnassignedFaces() async {
    final query = select(faces).join([
      innerJoin(assets, assets.id.equalsExp(faces.assetId)),
    ])..where(faces.personId.isNull() &
        faces.isIgnored.equals(false) &
        assets.isTrashed.equals(false) &
        assets.isLocked.equals(false));
    final rows = await query.get();
    return rows.map((r) => r.readTable(faces)).toList();
  }

  /// Beiseitegelegte Gesichter für den Tab „Ignoriert" – dieselbe
  /// Absicherung über Assets wie [unassignedFaces], damit auch hier kein
  /// Ausschnitt aus einem gesperrten Foto sichtbar wird.
  Future<List<FaceData>> ignoredFaces({int limit = 200}) async {
    final query = select(faces).join([
      innerJoin(assets, assets.id.equalsExp(faces.assetId)),
    ])
      ..where(faces.isIgnored.equals(true) &
          assets.isTrashed.equals(false) &
          assets.isLocked.equals(false))
      ..limit(limit);
    final rows = await query.get();
    return rows.map((r) => r.readTable(faces)).toList();
  }

  /// Wie viele Gesichter insgesamt beiseitegelegt sind – für die Zahl am
  /// Tab, damit auch jenseits des Anzeigelimits von 200 ersichtlich ist,
  /// wie viel dort liegt.
  Future<int> ignoredFacesCount() async {
    final anzahl = faces.id.count();
    final query = selectOnly(faces).join([
      innerJoin(assets, assets.id.equalsExp(faces.assetId)),
    ])
      ..addColumns([anzahl])
      ..where(faces.isIgnored.equals(true) &
          assets.isTrashed.equals(false) &
          assets.isLocked.equals(false));
    final row = await query.getSingle();
    return row.read(anzahl) ?? 0;
  }

  /// Legt alle noch unbenannten Gesichter auf einen Schlag beiseite und
  /// liefert, wie viele es waren.
  ///
  /// Für den Fall, dass die Erkennung überwiegend Unbrauchbares gefunden
  /// hat – Plakate, Statuen, Passanten. Von Hand wären das hunderte Klicks;
  /// danach holt man sich unter „Ignoriert" die wenigen zurück, die man
  /// wirklich benennen will.
  ///
  /// Bereits benannte Gesichter bleiben unberührt: Sie sind ja gerade das
  /// Ergebnis der Arbeit, die hier nicht verloren gehen darf.
  Future<int> ignoriereAlleUnbenannten() async {
    final betroffen = await allUnassignedFaces();
    if (betroffen.isEmpty) return 0;
    await setFacesIgnored([for (final f in betroffen) f.id], true);
    return betroffen.length;
  }

  /// Löscht alle unbenannten Erkennungen und liefert ihre Zahl sowie die
  /// Pfade ihrer Ausschnitte, damit der Aufrufer auch die Dateien wegräumen
  /// kann.
  ///
  /// Beides getrennt, weil es nicht dasselbe ist: Ein Gesicht ohne
  /// Embedding-Modell bekommt zwar eine Zeile, aber nicht zwangsläufig
  /// einen Ausschnitt. Die Pfade zu zählen und das Ergebnis als Zahl der
  /// gelöschten Erkennungen zu melden, ergäbe eine zu kleine Zahl.
  ///
  /// Anders als das Beiseitelegen ist das **nicht dauerhaft**: Der nächste
  /// Gesichts-Scan findet dieselben Stellen wieder und legt sie neu an.
  /// Dafür wird der Platz auf der Platte frei. Wer die Erkennungen
  /// endgültig loswerden will, legt sie beiseite – siehe
  /// [ignoriereAlleUnbenannten].
  ///
  /// Beiseitegelegte werden mitgelöscht: Wer „alle Erkennungen löschen"
  /// wählt, meint auch die, die schon aussortiert waren.
  Future<({int anzahl, List<String> pfade})> loescheAlleUnbenanntenErkennungen() async {
    final query = select(faces).join([
      innerJoin(assets, assets.id.equalsExp(faces.assetId)),
    ])..where(faces.personId.isNull() &
        assets.isTrashed.equals(false) &
        assets.isLocked.equals(false));
    final betroffen = (await query.get()).map((r) => r.readTable(faces)).toList();
    if (betroffen.isEmpty) return (anzahl: 0, pfade: const <String>[]);
    await (delete(faces)..where((t) => t.id.isIn([for (final f in betroffen) f.id]))).go();
    return (
      anzahl: betroffen.length,
      pfade: [
        for (final f in betroffen)
          if (f.cropRelativePath != null) f.cropRelativePath!,
      ],
    );
  }

  /// Wie viele unbenannte Erkennungen es insgesamt gibt – für die Zahlen in
  /// der Rückfrage, die über das Anzeigelimit von 200 hinausgeht.
  Future<int> unassignedFacesCount() async {
    final anzahl = faces.id.count();
    final query = selectOnly(faces).join([
      innerJoin(assets, assets.id.equalsExp(faces.assetId)),
    ])
      ..addColumns([anzahl])
      ..where(faces.personId.isNull() &
          faces.isIgnored.equals(false) &
          assets.isTrashed.equals(false) &
          assets.isLocked.equals(false));
    return (await query.getSingle()).read(anzahl) ?? 0;
  }

  /// Legt Gesichter beiseite bzw. holt sie zurück.
  ///
  /// Beim Beiseitelegen wird eine bestehende Personen-Zuordnung entfernt:
  /// Ein Gesicht, das noch als „Anna" zählte und zugleich ignoriert wäre,
  /// hinge zwischen beiden Zuständen – es erschiene weiter in Annas Fotos,
  /// wäre aber unter „Ignoriert" gelistet.
  Future<void> setFacesIgnored(List<String> faceIds, bool ignoriert) async {
    if (faceIds.isEmpty) return;
    await (update(faces)..where((t) => t.id.isIn(faceIds))).write(FacesCompanion(
      isIgnored: Value(ignoriert),
      personId: ignoriert ? const Value(null) : const Value.absent(),
    ));
  }

  /// Alle erkannten (und ggf. manuell hinzugefügten) Gesichter eines
  /// einzelnen Fotos – für die Foto-Detailansicht mit Gesichts-Overlay.
  Future<List<FaceData>> facesForAsset(String assetId) =>
      (select(faces)..where((t) => t.assetId.equals(assetId))).get();

  /// Für die Bibliotheks-Integritätsprüfung – ein einzelner Full-Table-Select
  /// statt N+1-Abfragen pro Asset.
  Future<List<FaceData>> allFaces() => select(faces).get();

  /// Alle Gesichter, die bereits einer bestimmten Person zugeordnet sind –
  /// z.B. um in der Personen-Detailansicht ein anderes Profilbild auswählen
  /// zu lassen. Ebenfalls ohne gelöschte/gesperrte Fotos (siehe
  /// [unassignedFaces]), sonst ließe sich darüber ein Profilbild aus einem
  /// gesperrten Foto auswählen.
  Future<List<FaceData>> facesForPerson(String personId) async {
    final query = select(faces).join([
      innerJoin(assets, assets.id.equalsExp(faces.assetId)),
    ])
      ..where(faces.personId.equals(personId) &
          assets.isTrashed.equals(false) &
          assets.isLocked.equals(false));
    final rows = await query.get();
    return rows.map((r) => r.readTable(faces)).toList();
  }

  /// Benannte Personen, die auf diesem Foto erkannt wurden (über die
  /// zugeordneten Gesichter) – für die "Personen"-Sektion der Info-Ansicht.
  Future<List<PersonData>> peopleForAsset(String assetId) async {
    final query = select(people).join([
      innerJoin(faces, faces.personId.equalsExp(people.id)),
    ])
      ..where(faces.assetId.equals(assetId));
    final rows = await query.get();
    final seen = <String>{};
    final result = <PersonData>[];
    for (final row in rows) {
      final person = row.readTable(people);
      if (seen.add(person.id)) result.add(person);
    }
    return result;
  }

  Future<void> assignFacesToPerson(List<String> faceIds, String personId) async {
    // Wer einem beiseitegelegten Gesicht einen Namen gibt, hat es damit
    // zurückgeholt – sonst verschwände es unmittelbar nach dem Benennen
    // wieder aus der Personenansicht.
    await (update(faces)..where((t) => t.id.isIn(faceIds)))
        .write(FacesCompanion(personId: Value(personId), isIgnored: const Value(false)));
    final assignedFaces = await (select(faces)..where((t) => t.id.isIn(faceIds))).get();
    final withCrop = assignedFaces.where((f) => f.cropRelativePath != null);
    if (withCrop.isNotEmpty) {
      await setPersonCoverIfUnset(personId, withCrop.first.cropRelativePath!);
    }
  }

  // -----------------------------------------------------------------------
  // Lernende Wiedererkennung (siehe face_threshold.dart)
  // -----------------------------------------------------------------------

  /// Hält Entscheidungen über Wiedererkennungs-Vorschläge fest und führt
  /// die persönliche Schwelle der Person in einem Zug nach.
  ///
  /// Beides zusammen in einer Transaktion, damit die gespeicherte Schwelle
  /// nie zu einem anderen Satz Rückmeldungen gehört als dem, der in der
  /// Oberfläche als Begründung angezeigt wird.
  Future<void> merkeGesichtsEntscheidungen(
    String personId,
    List<({String faceId, bool accepted, double similarity})> entscheidungen, {
    required double allgemeineSchwelle,
  }) async {
    if (entscheidungen.isEmpty) return;
    await transaction(() async {
      final jetzt = DateTime.now();
      await batch((b) => b.insertAll(faceMatchFeedback, [
            for (final e in entscheidungen)
              FaceMatchFeedbackCompanion.insert(
                personId: personId,
                faceId: e.faceId,
                accepted: e.accepted,
                similarity: e.similarity,
                createdAt: jetzt,
              ),
          ]));
      await _aktualisiereSchwelle(personId, allgemeineSchwelle);
    });
  }

  Future<void> _aktualisiereSchwelle(String personId, double allgemein) async {
    final rueckmeldungen = await gesichtsRueckmeldungen(personId);
    final abgeleitet = leiteSchwelleAb(rueckmeldungen, allgemein);
    await (update(people)..where((t) => t.id.equals(personId))).write(
      // Genau die allgemeine Schwelle wird als "nichts Eigenes" gespeichert
      // – sonst wanderte sie nicht mit, wenn der Nutzer die allgemeine
      // später in den Werkzeugen ändert.
      PeopleCompanion(similarityThreshold: Value(abgeleitet == allgemein ? null : abgeleitet)),
    );
  }

  Future<List<GesichtsRueckmeldung>> gesichtsRueckmeldungen(String personId) async {
    final rows = await (select(faceMatchFeedback)..where((t) => t.personId.equals(personId))).get();
    return [
      for (final r in rows)
        GesichtsRueckmeldung(bestaetigt: r.accepted, aehnlichkeit: r.similarity),
    ];
  }

  /// Verwirft alles Gelernte zu einer Person – der Ausweg, wenn die
  /// Anpassung einmal danebenliegt und der Nutzer nicht nachvollziehen
  /// kann, warum.
  Future<void> vergissGesichtsEntscheidungen(String personId) => transaction(() async {
        await (delete(faceMatchFeedback)..where((t) => t.personId.equals(personId))).go();
        await (update(people)..where((t) => t.id.equals(personId)))
            .write(const PeopleCompanion(similarityThreshold: Value(null)));
      });

  /// Rechnet die persönlichen Schwellen aller Personen neu.
  ///
  /// Nötig, wenn der Nutzer die allgemeine Schwelle ändert: Die
  /// persönlichen sind daran gebunden (Ausgangspunkt und Deckel), sonst
  /// hätte der Regler in den Werkzeugen für gelernte Personen keine
  /// Wirkung mehr.
  Future<void> rechneAlleSchwellenNeu(double allgemein) async {
    for (final person in await select(people).get()) {
      await _aktualisiereSchwelle(person.id, allgemein);
    }
  }

  /// Setzt das Profilbild einer Person auf den Foto-Ausschnitt (Crop) eines
  /// bestimmten Gesichts – sowohl für die automatische Erstzuordnung als
  /// auch für die manuelle Auswahl in der Personen-Detailansicht.
  Future<void> setPersonCover(String personId, String cropRelativePath) =>
      (update(people)..where((t) => t.id.equals(personId)))
          .write(PeopleCompanion(coverFaceCropPath: Value(cropRelativePath)));

  /// Wie [setPersonCover], setzt das Profilbild aber nur, wenn die Person
  /// noch keins hat – wird beim automatischen Zuordnen eines Gesichts
  /// aufgerufen, damit ein bereits manuell gewähltes Profilbild nicht
  /// überschrieben wird.
  Future<void> setPersonCoverIfUnset(String personId, String cropRelativePath) async {
    final person = await (select(people)..where((t) => t.id.equals(personId))).getSingleOrNull();
    if (person != null && person.coverFaceCropPath == null) {
      await setPersonCover(personId, cropRelativePath);
    }
  }

  /// Führt zwei Personen zusammen: alle Gesichter von [removePersonId] werden
  /// [keepPersonId] zugeordnet, anschließend wird die überflüssige
  /// Personen-Zeile gelöscht. Nützlich, wenn die Gesichtserkennung
  /// dieselbe reale Person versehentlich als zwei Personen angelegt hat.
  Future<void> mergePeople({required String keepPersonId, required String removePersonId}) async {
    await (update(faces)..where((t) => t.personId.equals(removePersonId)))
        .write(FacesCompanion(personId: Value(keepPersonId)));
    await (delete(people)..where((t) => t.id.equals(removePersonId))).go();
  }

  Stream<List<AssetData>> watchAssetsForPerson(String personId) {
    final query = select(assets).join([
      innerJoin(faces, faces.assetId.equalsExp(assets.id)),
    ])
      ..where(faces.personId.equals(personId) &
          assets.isTrashed.equals(false) &
          assets.isLocked.equals(false))
      ..orderBy([OrderingTerm.desc(assets.fileCreatedAt)]);
    return query.watch().map((rows) {
      final seen = <String>{};
      final result = <AssetData>[];
      for (final row in rows) {
        final a = row.readTable(assets);
        if (seen.add(a.id)) result.add(a);
      }
      return result;
    });
  }

  /// Liefert alle Bild-Assets, die für einen (erneuten) Gesichts-Scan
  /// infrage kommen. Bei [onlyNew] werden nur Fotos zurückgegeben, die noch
  /// nie durch die Gesichtserkennung gelaufen sind.
  Future<List<AssetData>> assetsForFaceScan({required bool onlyNew}) {
    // Gesperrte Fotos bewusst ausgeschlossen: sonst würden ihre Gesichter im
    // "Unbenannte Gesichter"-Tab auftauchen, obwohl das Foto selbst versteckt
    // ist (siehe [unassignedFaces]).
    final query = select(assets)
      ..where((t) => t.type.equals('IMAGE') & t.isTrashed.equals(false) & t.isLocked.equals(false));
    if (onlyNew) {
      query.where((t) => t.facesScanned.equals(false));
    }
    return query.get();
  }

  /// Zählvariante von [assetsForFaceScan], siehe [countLocationBackfill].
  Future<int> countFaceScan({required bool onlyNew}) {
    var predicate = assets.type.equals('IMAGE') & assets.isTrashed.equals(false) & assets.isLocked.equals(false);
    if (onlyNew) predicate = predicate & assets.facesScanned.equals(false);
    return _countWhere(predicate);
  }

  Future<void> markFacesScanned(List<String> assetIds) => (update(assets)
        ..where((t) => t.id.isIn(assetIds)))
      .write(const AssetsCompanion(facesScanned: Value(true)));

  /// Löscht bereits erkannte, aber noch keiner Person zugeordnete Gesichter
  /// eines Assets, bevor ein erneuter Scan neue Erkennungen einfügt – manuell
  /// zugeordnete Gesichter (mit personId) bleiben dabei bewusst unangetastet.
  ///
  /// Beiseitegelegte Gesichter bleiben ebenfalls stehen. Sonst wäre das
  /// Ignorieren beim ersten „alle Fotos erneut scannen" stillschweigend
  /// wieder weg – und genau davor soll es schützen (siehe [Faces.isIgnored]).
  Future<void> deleteUnassignedFacesForAsset(String assetId) => (delete(faces)
        ..where((t) =>
            t.assetId.equals(assetId) &
            t.personId.isNull() &
            t.isIgnored.equals(false)))
      .go();

  // -----------------------------------------------------------------------
  // CLIP-Bild-Embeddings (KI-Suche)
  // -----------------------------------------------------------------------

  Future<void> saveEmbedding(String assetId, Float32List vector) async {
    await into(imageEmbeddings).insertOnConflictUpdate(
      ImageEmbeddingsCompanion.insert(
        assetId: assetId,
        vector: blobFromEmbeddingFloats(vector),
      ),
    );
    _embeddingsGeneration++;
  }

  Future<bool> hasEmbedding(String assetId) async {
    final row = await (select(imageEmbeddings)..where((t) => t.assetId.equals(assetId)))
        .getSingleOrNull();
    return row != null;
  }

  /// Einzelnes gespeichertes CLIP-Embedding (falls vorhanden) – für das
  /// automatische KI-Tagging, das das beim Import ohnehin berechnete
  /// Bild-Embedding wiederverwendet, statt das Bild erneut zu dekodieren.
  Future<Float32List?> embeddingForAsset(String assetId) async {
    final row = await (select(imageEmbeddings)..where((t) => t.assetId.equals(assetId)))
        .getSingleOrNull();
    if (row == null) return null;
    return floatsFromEmbeddingBlob(row.vector);
  }

  /// Fotos ohne CLIP-Embedding – z.B. weil sie importiert wurden, bevor das
  /// CLIP-Modell installiert war (Embeddings werden sonst automatisch beim
  /// Import berechnet). Für das nachträgliche Berechnen in den Werkzeugen.
  Future<List<AssetData>> assetsForEmbeddingBackfill() async {
    final query = select(assets).join([
      leftOuterJoin(imageEmbeddings, imageEmbeddings.assetId.equalsExp(assets.id)),
    ])
      ..where(assets.type.equals('IMAGE') &
          assets.isTrashed.equals(false) &
          // Gesperrte Fotos ausgenommen, siehe [assetsForOcrBackfill]: Ein
          // CLIP-Embedding beschreibt den Bildinhalt und ist damit ebenso
          // wenig für die unverschlüsselte Datenbank gedacht.
          assets.isLocked.equals(false) &
          imageEmbeddings.assetId.isNull());
    final rows = await query.get();
    return rows.map((r) => r.readTable(assets)).toList();
  }

  /// Zählvariante von [assetsForEmbeddingBackfill], siehe [countLocationBackfill].
  Future<int> countEmbeddingBackfill() async {
    final countExpr = assets.id.count();
    final query = selectOnly(assets).join([
      leftOuterJoin(imageEmbeddings, imageEmbeddings.assetId.equalsExp(assets.id)),
    ])
      ..addColumns([countExpr])
      ..where(assets.type.equals('IMAGE') &
          assets.isTrashed.equals(false) &
          assets.isLocked.equals(false) &
          imageEmbeddings.assetId.isNull());
    final row = await query.getSingle();
    return row.read<int>(countExpr) ?? 0;
  }

  /// Bild-Assets, die für automatisches KI-Tagging infrage kommen (nicht
  /// gelöscht/gesperrt – gesperrte Fotos werden bewusst nicht verarbeitet,
  /// solange sie versteckt sind).
  ///
  /// Bei [onlyUntagged] nur Fotos, die noch nie durch die Verschlagwortung
  /// gelaufen sind ([Assets.aiTagsScanned]) UND noch keinen Tag tragen.
  /// Das Flag ist dabei das entscheidende Kriterium: Ein Foto, zu dem CLIP
  /// keinen passenden Begriff gefunden hat, bleibt für immer ohne Tags und
  /// wäre ohne das Flag bei jedem Lauf erneut Kandidat – siehe dort.
  /// Die zusätzliche Tag-Prüfung hält Fotos draussen, die vor Einführung
  /// des Flags bereits verschlagwortet wurden.
  ///
  /// Wer stattdessen "Alle" wählt, ergänzt passende KI-Tags auch bei
  /// bereits getaggten Fotos, ohne vorhandene (auch manuelle) Tags zu
  /// entfernen.
  Future<List<AssetData>> assetsForAiTagging({required bool onlyUntagged}) async {
    if (!onlyUntagged) {
      return (select(assets)
            ..where((t) => t.type.equals('IMAGE') & t.isTrashed.equals(false) & t.isLocked.equals(false)))
          .get();
    }
    final query = select(assets).join([
      leftOuterJoin(assetTags, assetTags.assetId.equalsExp(assets.id)),
    ])
      ..where(assets.type.equals('IMAGE') &
          assets.isTrashed.equals(false) &
          assets.isLocked.equals(false) &
          assets.aiTagsScanned.equals(false) &
          assetTags.assetId.isNull());
    final rows = await query.get();
    return rows.map((r) => r.readTable(assets)).toList();
  }

  /// Vermerkt, dass ein Foto die Verschlagwortung durchlaufen hat –
  /// unabhängig davon, ob dabei Tags heraussprangen.
  Future<void> markAiTagsScanned(List<String> assetIds) =>
      (update(assets)..where((t) => t.id.isIn(assetIds)))
          .write(const AssetsCompanion(aiTagsScanned: Value(true)));

  /// Zählvariante von [assetsForAiTagging], siehe [countLocationBackfill].
  Future<int> countAiTagging({required bool onlyUntagged}) async {
    if (!onlyUntagged) {
      return _countWhere(
          assets.type.equals('IMAGE') & assets.isTrashed.equals(false) & assets.isLocked.equals(false));
    }
    final countExpr = assets.id.count();
    final query = selectOnly(assets).join([
      leftOuterJoin(assetTags, assetTags.assetId.equalsExp(assets.id)),
    ])
      ..addColumns([countExpr])
      ..where(assets.type.equals('IMAGE') &
          assets.isTrashed.equals(false) &
          assets.isLocked.equals(false) &
          // Muss deckungsgleich mit assetsForAiTagging bleiben, sonst zeigt
          // die Hintergrundaufgaben-Übersicht Wartende an, die keine sind.
          assets.aiTagsScanned.equals(false) &
          assetTags.assetId.isNull());
    final row = await query.getSingle();
    return row.read<int>(countExpr) ?? 0;
  }

  /// Lädt alle gespeicherten Embeddings (assetId -> Vektor) für die
  /// Brute-Force-Ähnlichkeitssuche im ClipService (KI-Suche & Duplikate).
  /// Über einen Join gegen Assets gefiltert, damit gelöschte oder gesperrte
  /// Fotos dort nicht auftauchen können.
  Future<Map<String, Float32List>> allEmbeddings() async {
    final query = select(imageEmbeddings).join([
      innerJoin(assets, assets.id.equalsExp(imageEmbeddings.assetId)),
    ])
      ..where(assets.isTrashed.equals(false) & assets.isLocked.equals(false));
    final rows = await query.get();
    return {
      for (final r in rows)
        r.readTable(imageEmbeddings).assetId:
            floatsFromEmbeddingBlob(r.readTable(imageEmbeddings).vector)
    };
  }

  // -----------------------------------------------------------------------
  // Backup
  // -----------------------------------------------------------------------

  /// Gesperrte Fotos werden bewusst NIE ins (unverschlüsselte, oft in einen
  /// Cloud-Sync-Ordner zeigende) Backup aufgenommen – das würde den Zweck
  /// des gesperrten Ordners aushebeln.
  Future<List<AssetData>> assetsNotBackedUp() => (select(assets)
        ..where((t) => t.backedUp.equals(false) & t.isTrashed.equals(false) & t.isLocked.equals(false)))
      .get();

  Future<void> markBackedUp(List<String> assetIds) => (update(assets)
        ..where((t) => t.id.isIn(assetIds)))
      .write(const AssetsCompanion(backedUp: Value(true)));

  Future<void> insertBackupRecord(BackupRecordsCompanion record) =>
      into(backupRecords).insert(record);

  Future<BackupRecordData?> lastBackupRecord() =>
      (select(backupRecords)..orderBy([(t) => OrderingTerm.desc(t.performedAt)]))
          .getSingleOrNull();

  // -----------------------------------------------------------------------
  // Backup-Verschlüsselung + automatisches Backup
  // -----------------------------------------------------------------------
  //
  // Analog zum gesperrten Ordner: die eigentliche Kryptografie läuft über
  // VaultCrypto/LibraryState, hier wird nur der verpackte Backup-Master-Key
  // und die Konfiguration des automatischen Backups gespeichert.

  Future<bool> hasBackupKey() async {
    final row = await (select(backupSettings)..where((t) => t.id.equals(0))).getSingleOrNull();
    return row?.wrappedMasterKey != null;
  }

  Future<BackupSettingsData?> backupSettingsRow() =>
      (select(backupSettings)..where((t) => t.id.equals(0))).getSingleOrNull();

  Future<void> saveBackupKey({
    required Uint8List kdfSalt,
    required Uint8List nonce,
    required Uint8List wrapped,
  }) =>
      into(backupSettings).insertOnConflictUpdate(BackupSettingsCompanion.insert(
        id: const Value(0),
        kdfSalt: Value(kdfSalt),
        wrappedMasterKeyNonce: Value(nonce),
        wrappedMasterKey: Value(wrapped),
      ));

  /// Entfernt nur die lokale Einrichtung der Backup-Verschlüsselung –
  /// bereits vorhandene verschlüsselte Backups am Zielort bleiben davon
  /// unberührt (sie lassen sich weiterhin mit der Passphrase entschlüsseln,
  /// die App merkt sich nur den Schlüssel nicht mehr).
  Future<void> clearBackupKey() =>
      (update(backupSettings)..where((t) => t.id.equals(0))).write(const BackupSettingsCompanion(
        kdfSalt: Value(null),
        wrappedMasterKeyNonce: Value(null),
        wrappedMasterKey: Value(null),
      ));

  /// [destination] und [intervalHours] werden nur geschrieben, wenn sie
  /// angegeben sind – `null` heißt "unverändert lassen", nicht "löschen".
  ///
  /// Vorher wurde das Ziel immer geschrieben: Ein Umstellen des Intervalls
  /// oder auch nur des Aktiv-Schalters übergab kein Ziel und löschte damit
  /// den zuvor gewählten Ordner, der dann erneut ausgewählt werden musste.
  /// Zum bewussten Entfernen gibt es [clearAutoBackupDestination].
  Future<void> setAutoBackupConfig({required bool enabled, String? destination, int? intervalHours}) =>
      into(backupSettings).insertOnConflictUpdate(BackupSettingsCompanion.insert(
        id: const Value(0),
        autoBackupEnabled: Value(enabled),
        autoBackupDestination:
            destination != null ? Value(destination) : const Value.absent(),
        autoBackupIntervalHours:
            intervalHours != null ? Value(intervalHours) : const Value.absent(),
      ));

  Future<void> setAutoBackupMaxMbPerRun(int mb) =>
      into(backupSettings).insertOnConflictUpdate(BackupSettingsCompanion.insert(
        id: const Value(0),
        autoBackupMaxMbPerRun: Value(mb),
      ));

  /// Entfernt das Sicherungsziel ausdrücklich (siehe [setAutoBackupConfig]).
  Future<void> clearAutoBackupDestination() =>
      (update(backupSettings)..where((t) => t.id.equals(0)))
          .write(const BackupSettingsCompanion(autoBackupDestination: Value(null)));

  Future<void> setLastAutoBackupAt(DateTime when) =>
      (update(backupSettings)..where((t) => t.id.equals(0)))
          .write(BackupSettingsCompanion(lastAutoBackupAt: Value(when)));

  /// Wie [assetsNotBackedUp], aber mit eigenem Tracking-Flag für das
  /// automatische Backup (siehe [Assets.autoBackedUp]).
  Future<List<AssetData>> assetsNotAutoBackedUp() => (select(assets)
        ..where((t) =>
            t.autoBackedUp.equals(false) & t.isTrashed.equals(false) & t.isLocked.equals(false)))
      .get();

  Future<void> markAutoBackedUp(List<String> assetIds) => (update(assets)
        ..where((t) => t.id.isIn(assetIds)))
      .write(const AssetsCompanion(autoBackedUp: Value(true)));

  // -----------------------------------------------------------------------
  // Gesperrter Ordner (PIN-Schutz + echte Verschlüsselung für private Fotos)
  // -----------------------------------------------------------------------
  //
  // Die eigentliche Kryptografie (Master-Key erzeugen/verpacken/entpacken,
  // Dateien ver-/entschlüsseln) läuft über VaultCrypto/LibraryState – hier
  // wird nur das Ergebnis (verpackter Master-Key + Salt/Nonce) gespeichert
  // bzw. ausgelesen.

  Future<bool> hasPinSet() async {
    final row = await (select(privacySettings)..where((t) => t.id.equals(0))).getSingleOrNull();
    return row?.wrappedMasterKey != null;
  }

  Future<PrivacySettingsData?> privacySettingsRow() =>
      (select(privacySettings)..where((t) => t.id.equals(0))).getSingleOrNull();

  Future<void> saveVaultKey({
    required Uint8List kdfSalt,
    required Uint8List nonce,
    required Uint8List wrapped,
  }) =>
      into(privacySettings).insertOnConflictUpdate(PrivacySettingsCompanion.insert(
        id: const Value(0),
        kdfSalt: Value(kdfSalt),
        wrappedMasterKeyNonce: Value(nonce),
        wrappedMasterKey: Value(wrapped),
      ));

  Future<void> clearVaultKey() => (delete(privacySettings)..where((t) => t.id.equals(0))).go();

  Future<void> setAssetsLocked(List<String> assetIds, bool locked) async {
    await (update(assets)..where((t) => t.id.isIn(assetIds)))
        .write(AssetsCompanion(isLocked: Value(locked)));
    _embeddingsGeneration++;
  }

  /// Entfernt die maschinell aus dem BILDINHALT abgeleiteten Daten eines
  /// Assets: erkannten Text, KI-Bildunterschrift und CLIP-Embedding.
  ///
  /// Wird beim Sperren aufgerufen. Ohne das blieb der Inhalt eines
  /// gesperrten Fotos in der unverschlüsselten `library.sqlite` lesbar –
  /// bei einem abfotografierten Dokument also genau der Text, wegen dem es
  /// gesperrt wurde (Audit-Fund). Über die Oberfläche war er zwar nicht
  /// erreichbar (searchAssets filtert `isLocked`), wohl aber für jeden mit
  /// Dateizugriff.
  ///
  /// Verlustfrei, nur nicht kostenlos: Die `*Scanned`-Flags werden
  /// zurückgesetzt, sodass die Hintergrundanalyse alles neu berechnet,
  /// sobald das Foto wieder entsperrt ist.
  ///
  /// Bewusst NICHT angetastet:
  /// - [description] – Nutzer-Freitext, kein abgeleiteter Wert.
  /// - Tags – können von Hand vergeben worden sein; sie zu löschen wäre
  ///   ein echter Datenverlust, nicht nur eine Neuberechnung.
  /// - [sharpnessScore] – eine Zahl über die Bildschärfe verrät nichts
  ///   über den Bildinhalt und wird für die Ausschuss-Sichtung gebraucht.
  Future<void> clearDerivedContentData(List<String> assetIds) async {
    await (update(assets)..where((t) => t.id.isIn(assetIds))).write(const AssetsCompanion(
      ocrText: Value(null),
      ocrScanned: Value(false),
      aiCaption: Value(null),
      aiCaptionScanned: Value(false),
    ));
    await (delete(imageEmbeddings)..where((t) => t.assetId.isIn(assetIds))).go();
    _embeddingsGeneration++;
  }

  Stream<List<AssetData>> watchLockedAssets() => (select(assets)
        ..where((t) => t.isLocked.equals(true) & t.isTrashed.equals(false))
        ..orderBy([(t) => OrderingTerm.desc(t.fileCreatedAt)]))
      .watch();
}
