import 'dart:io';

import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

import 'library_location.dart';

/// Kapselt sämtliche Pfade der lokalen Bibliothek. Layout (Wurzelverzeichnis
/// standardmäßig im App-Support-Ordner, siehe [LibraryLocation] – kann in
/// den Einstellungen auf einen beliebigen anderen Ordner verlegt werden):
///
/// <Speicherort>/
///   library/
///     originals/{yyyy}/{mm}/{assetId}.{ext}
///     thumbnails/{assetId}.jpg
///     previews/{assetId}.jpg          (nur für HEIC/DNG & Co.: von Flutter
///                                       nicht direkt darstellbare Formate)
///     developed/{assetId}.jpg        (nur mit Entwicklungs-Anpassungen, siehe DevelopScreen)
///     restored/{assetId}.jpg         (nur mit KI-Restaurierung, siehe RestoreQueueService)
///     trimmed/{assetId}.mp4          (nur mit Video-Zuschnitt, siehe VideoTrimScreen)
///     masks/{maskId}.png             (KI-Objektmasken, siehe MaskEditor)
///     luts/{name}.cube               (importierte Farbtabellen)
///     faces/{faceId}.jpg
///     trash/{assetId}.{ext}          (physisch verschoben bis "Papierkorb leeren")
///   library.sqlite
class StoragePaths {
  StoragePaths._(this.root);

  final Directory root;

  static StoragePaths? _instance;

  static Future<StoragePaths> instance() async {
    if (_instance != null) return _instance!;
    final libraryRoot = await LibraryLocation.currentRoot();
    final root = Directory(p.join(libraryRoot.path, 'library'));
    _instance = await _createAt(root);
    return _instance!;
  }

  /// Erzeugt eine eigenständige [StoragePaths]-Instanz unter einem
  /// beliebigen Wurzelverzeichnis, ohne das `path_provider`-Plugin (das
  /// echte Platform-Channels braucht) zu berühren und ohne das
  /// App-weite Singleton zu setzen. Nur für Tests gedacht, damit
  /// ImportService/BackupService dort mit einem temporären Verzeichnis
  /// statt dem echten App-Support-Ordner arbeiten können.
  @visibleForTesting
  static Future<StoragePaths> forTesting(Directory root) => _createAt(root);

  static Future<StoragePaths> _createAt(Directory root) async {
    for (final sub in [
      'originals',
      'thumbnails',
      'previews',
      'developed',
      'restored',
      'trimmed',
      'masks',
      'faces',
      'luts',
      'trash',
    ]) {
      await Directory(p.join(root.path, sub)).create(recursive: true);
    }
    return StoragePaths._(root);
  }

  Directory get originalsDir => Directory(p.join(root.path, 'originals'));
  Directory get thumbnailsDir => Directory(p.join(root.path, 'thumbnails'));
  Directory get previewsDir => Directory(p.join(root.path, 'previews'));
  Directory get developedDir => Directory(p.join(root.path, 'developed'));
  Directory get restoredDir => Directory(p.join(root.path, 'restored'));
  Directory get trimmedDir => Directory(p.join(root.path, 'trimmed'));
  /// Importierte Farbtabellen (`.cube`).
  ///
  /// Sie werden in die Bibliothek kopiert statt nur verwiesen: Eine
  /// Entwicklung, die auf eine Datei im Download-Ordner zeigt, sähe nach
  /// dem nächsten Aufräumen anders aus – und ein Backup enthielte den Look
  /// nicht.
  Directory get lutsDir => Directory(p.join(root.path, 'luts'));

  String lutRelativePath(String dateiname) => p.join('luts', dateiname);

  Directory get masksDir => Directory(p.join(root.path, 'masks'));
  Directory get facesDir => Directory(p.join(root.path, 'faces'));
  Directory get trashDir => Directory(p.join(root.path, 'trash'));

  String originalRelativePath(DateTime fileCreatedAt, String assetId, String extension) {
    final yyyy = fileCreatedAt.year.toString().padLeft(4, '0');
    final mm = fileCreatedAt.month.toString().padLeft(2, '0');
    return p.join('originals', yyyy, mm, '$assetId$extension');
  }

  String thumbnailRelativePath(String assetId) => p.join('thumbnails', '$assetId.jpg');

  /// Nur für Formate relevant, die Flutter nicht direkt rendern kann
  /// (HEIC/HEIF, DNG & Co.) – eine größere, konvertierte JPEG-Version für
  /// die Vollbildansicht (Thumbnails bleiben separat und kleiner).
  String previewRelativePath(String assetId) => p.join('previews', '$assetId.jpg');

  /// Gerendertes Ergebnis der nicht-destruktiven Entwicklung (siehe
  /// DevelopScreen) – separat von [previewRelativePath], damit sich beide
  /// unabhängig regenerieren lassen (die reine Vorschau z.B. beim
  /// HEIC/RAW-Import, das entwickelte Bild nur bei geänderten Reglern).
  String developedRelativePath(String assetId) => p.join('developed', '$assetId.jpg');

  /// Ergebnis einer KI-Restaurierung (siehe RestoreQueueService,
  /// RestoreJobs) – separat von [developedRelativePath], da beide
  /// unabhängig voneinander existieren können (Restaurierung nimmt das
  /// bereits entwickelte Ergebnis als Eingabe, falls vorhanden).
  String restoredRelativePath(String assetId) => p.join('restored', '$assetId.jpg');

  /// Ergebnis des nicht-destruktiven Video-Zuschnitts (siehe
  /// VideoTrimScreen) – separat von [originalRelativePath], die
  /// Originaldatei wird nie angetastet.
  String trimmedRelativePath(String assetId) => p.join('trimmed', '$assetId.mp4');

  String faceRelativePath(String faceId) => p.join('faces', '$faceId.jpg');

  /// Grauwert-Alphamaske einer KI-Objektmaske (siehe MaskEditor,
  /// SegmentationService.maskToOriginalResolution). Nimmt bewusst eine vom
  /// Aufrufer erzeugte UUID statt der Auto-Increment-`id` der DevelopMasks-
  /// Zeile entgegen – die ist erst NACH dem Einfügen der Zeile bekannt, der
  /// Dateiname muss aber schon vorher feststehen, um die Datei zu schreiben.
  String maskRelativePath(String maskFileId) => p.join('masks', '$maskFileId.png');

  /// XMP-Sidecar-Pfad zu einer beliebigen bereits vorhandenen Datei (siehe
  /// xmp_writer.dart) – ein Sidecar muss denselben Basisnamen wie die
  /// tatsächlich auf der Platte liegende Datei tragen, damit Lightroom/
  /// darktable/digiKam ihn beim Ordner-Scan zuordnen. Nimmt bewusst
  /// [filePath] statt einer Asset-ID entgegen und tauscht nur die Endung
  /// aus – funktioniert dadurch gleichermaßen für relative Pfade innerhalb
  /// der Bibliothek (`{assetId}`-basiert) UND für absolute Export-/Backup-
  /// Zielpfade (`originalFileName`-basiert, siehe
  /// ExportService._uniqueDestinationPath), ohne eigene Fallunterscheidung.
  String xmpSidecarPath(String filePath) => p.setExtension(filePath, '.xmp');

  File absolute(String relativePath) => File(p.join(root.path, relativePath));

  /// Verschiebt eine Originaldatei physisch in den Papierkorb-Ordner (wird
  /// beim "Papierkorb leeren" endgültig gelöscht). Gibt den neuen relativen
  /// Pfad zurück.
  Future<String> moveToPhysicalTrash(String currentRelativePath) async {
    final source = absolute(currentRelativePath);
    final target = File(p.join(trashDir.path, p.basename(currentRelativePath)));
    if (await source.exists()) {
      await source.rename(target.path);
    }
    return p.join('trash', p.basename(currentRelativePath));
  }

  Future<void> deletePermanently(String relativePath) async {
    final file = absolute(relativePath);
    if (await file.exists()) await file.delete();
  }

  /// Gesamtgröße aller Originaldateien in Bytes (für die Speicheranzeige in
  /// den Einstellungen).
  Future<int> totalOriginalsSizeBytes() async {
    var total = 0;
    if (!await originalsDir.exists()) return 0;
    await for (final entity in originalsDir.list(recursive: true, followLinks: false)) {
      if (entity is File) total += await entity.length();
    }
    return total;
  }
}
