import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'security_scoped_bookmark.dart';

export 'security_scoped_bookmark.dart' show PickedFolder;

/// Verwaltet, WO die eigentlichen Bibliotheksdaten (`library.sqlite` +
/// `library/`-Ordner mit Originalen/Thumbnails/Gesichts-Crops) liegen.
/// Standardmäßig im App-Support-Ordner – kann aber auf einen beliebigen
/// anderen Ordner verlegt werden (z.B. externe Festplatte, Cloud-Sync-
/// Ordner), siehe Einstellungen → Speicherort.
///
/// Der Zeiger auf den aktuellen Speicherort (`location.json`) liegt bewusst
/// IMMER am unveränderlichen Standardpfad, nie im verlegten Ordner selbst –
/// sonst wüsste die App beim nächsten Start nicht, wo sie suchen soll. Das
/// `models/`-Modellordner bleibt unabhängig davon immer am Standardpfad
/// (Modelldateien sind jederzeit neu herunterladbar, keine "echten" Nutzerdaten).
class LibraryLocation {
  LibraryLocation._();

  static Future<Directory> _anchorDir() async {
    final support = await getApplicationSupportDirectory();
    final dir = Directory(p.join(support.path, 'PhotoVault'));
    await dir.create(recursive: true);
    return dir;
  }

  static Future<File> _configFile() async {
    final anchor = await _anchorDir();
    return File(p.join(anchor.path, 'location.json'));
  }

  /// Aktuelles Wurzelverzeichnis für `library.sqlite` und den `library/`-
  /// Ordner. Löst dabei – falls ein externer Ordner konfiguriert ist – über
  /// das gespeicherte Security-Scoped-Bookmark erneut den Sandbox-Zugriff
  /// auf, da macOS diesen sonst nach jedem Neustart wieder entzieht.
  static Future<Directory> currentRoot() async {
    final configFile = await _configFile();
    if (!await configFile.exists()) return _anchorDir();

    try {
      final json = jsonDecode(await configFile.readAsString()) as Map<String, dynamic>;
      final bookmark = json['bookmark'] as String?;
      if (bookmark == null) return _anchorDir();

      final resolved = await SecurityScopedBookmark.resolve(bookmark);
      // Bookmark ungültig geworden (z.B. Ordner gelöscht/umbenannt, Laufwerk
      // nicht eingebunden) – auf den Standardordner zurückfallen, statt die
      // App gar nicht erst starten zu lassen.
      if (resolved == null) return _anchorDir();
      return Directory(resolved);
    } catch (_) {
      return _anchorDir();
    }
  }

  /// Ob aktuell ein vom Standard abweichender Speicherort konfiguriert ist.
  static Future<bool> get isCustom async => (await _configFile()).exists();

  /// Zeigt einen nativen Ordnerauswahl-Dialog und erzeugt dabei atomar
  /// (siehe [SecurityScopedBookmark.pickFolderAndCreateBookmark]) ein
  /// dauerhaftes Security-Scoped-Bookmark für den gewählten Ordner. Gibt
  /// `null` zurück, falls der Nutzer abgebrochen hat. Bewusst von
  /// [applyRoot] getrennt: die eigentliche UI (z.B. eine Ladeanzeige) soll
  /// erst nach der Ordnerauswahl erscheinen, nicht schon währenddessen.
  static Future<PickedFolder?> pickFolder({String? dialogMessage}) {
    return SecurityScopedBookmark.pickFolderAndCreateBookmark(message: dialogMessage);
  }

  /// Legt einen zuvor per [pickFolder] gewählten Ordner als neuen
  /// Speicherort fest und verschiebt die vorhandenen Bibliotheksdaten
  /// dorthin. Wirft eine [Exception] mit einer für die UI verständlichen
  /// Meldung, falls das Verschieben fehlschlägt – die bisherigen Daten
  /// bleiben in diesem Fall unangetastet (siehe [_moveLibraryData]).
  ///
  /// [beforeMove] wird erst aufgerufen, nachdem feststeht, dass tatsächlich
  /// verschoben wird (also nicht bei einem No-Op, falls [picked] bereits der
  /// aktuelle Ort ist) – so schließt z.B. [LibraryState] darüber die
  /// Datenbankverbindung erst kurz bevor `library.sqlite` wirklich
  /// verschoben wird, statt vorschnell und ggf. für nichts.
  static Future<String> applyRoot(PickedFolder picked, {Future<void> Function()? beforeMove}) async {
    final oldRoot = await currentRoot();
    final newRoot = Directory(picked.path);
    if (p.equals(oldRoot.path, newRoot.path)) return picked.path;

    if (beforeMove != null) await beforeMove();

    await newRoot.create(recursive: true);
    await _moveLibraryData(oldRoot, newRoot);

    final configFile = await _configFile();
    await configFile.writeAsString(jsonEncode({'path': picked.path, 'bookmark': picked.bookmark}));
    return picked.path;
  }

  /// Setzt den Speicherort zurück auf den Standard-App-Support-Ordner.
  static Future<void> resetToDefault() async {
    final oldRoot = await currentRoot();
    final defaultRoot = await _anchorDir();
    if (p.equals(oldRoot.path, defaultRoot.path)) return;

    await _moveLibraryData(oldRoot, defaultRoot);

    final configFile = await _configFile();
    if (await configFile.exists()) await configFile.delete();
  }

  /// Kopiert `library.sqlite` (+ evtl. WAL/SHM-Nebendateien) und den
  /// `library/`-Ordner von [from] nach [to] und löscht die Originale erst,
  /// wenn das vollständig geklappt hat – bei einem Fehler mitten im Kopieren
  /// (z.B. Speicherplatz voll) bleibt die bisherige Bibliothek so
  /// unverändert erhalten, statt in einem halb verschobenen Zustand zu enden.
  static Future<void> _moveLibraryData(Directory from, Directory to) async {
    if (p.equals(from.path, to.path)) return;

    final dbFrom = File(p.join(from.path, 'library.sqlite'));
    final dbTo = File(p.join(to.path, 'library.sqlite'));
    final libFrom = Directory(p.join(from.path, 'library'));
    final libTo = Directory(p.join(to.path, 'library'));

    if (await dbFrom.exists()) {
      await dbFrom.copy(dbTo.path);
      for (final suffix in ['-wal', '-shm']) {
        final side = File('${dbFrom.path}$suffix');
        if (await side.exists()) await side.copy('${dbTo.path}$suffix');
      }
    }
    if (await libFrom.exists()) {
      await _copyDirectory(libFrom, libTo);
    }

    // Erst nach erfolgreichem Kopieren die Originale löschen.
    if (await dbFrom.exists()) {
      await dbFrom.delete();
      for (final suffix in ['-wal', '-shm']) {
        final side = File('${dbFrom.path}$suffix');
        if (await side.exists()) await side.delete();
      }
    }
    if (await libFrom.exists()) {
      await libFrom.delete(recursive: true);
    }
  }

  static Future<void> _copyDirectory(Directory source, Directory destination) async {
    await destination.create(recursive: true);
    await for (final entity in source.list(recursive: false)) {
      final newPath = p.join(destination.path, p.basename(entity.path));
      if (entity is Directory) {
        await _copyDirectory(entity, Directory(newPath));
      } else if (entity is File) {
        await entity.copy(newPath);
      }
    }
  }
}
