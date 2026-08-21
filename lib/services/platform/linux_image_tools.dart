import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute, visibleForTesting;
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

/// Linux-Entsprechung zu den nativen macOS-Funktionen aus
/// `macos/Runner/ImageConverter.swift`.
///
/// Unter Linux gibt es kein ImageIO und kein AVFoundation. Statt eigene
/// FFI-Wrapper für libheif/LibRaw/libavcodec zu bauen (für keine dieser
/// Bibliotheken existiert ein brauchbares Dart-Paket, siehe
/// docs/plan_linux.md), werden die etablierten Kommandozeilenwerkzeuge
/// aufgerufen. Ausgeliefert als Flatpak sind sie mit im Bundle und damit
/// garantiert vorhanden.
///
/// Jede Funktion gibt `null`/`false` zurück, wenn das jeweilige Werkzeug
/// fehlt – die App bleibt dann benutzbar, nur diese eine Fähigkeit fehlt.
class LinuxImageTools {
  LinuxImageTools._();

  /// Ergebnis von [pruefeWerkzeuge].
  static Map<String, bool>? _verfuegbar;

  /// Gebrauchte Werkzeuge und wofür.
  ///
  /// `ffprobe` steht einzeln dabei, obwohl es meist zusammen mit `ffmpeg`
  /// installiert wird: [videoDauer] ruft ausschliesslich ffprobe auf. Nur
  /// ffmpeg zu prüfen hiesse, eine Verfügbarkeit zu behaupten, die man
  /// nicht geprüft hat – und die Videolänge fiele still auf null zurück.
  static const werkzeuge = <String, String>{
    'heif-convert': 'HEIC/HEIF-Fotos (Paket libheif-examples)',
    'dcraw_emu': 'RAW-Fotos (Paket libraw-bin)',
    'ffmpeg': 'Video-Vorschaubilder und Videoschnitt',
    'ffprobe': 'Videolänge (Teil von ffmpeg)',
  };

  /// Verwirft das gemerkte Ergebnis – für Tests und für den Fall, dass
  /// jemand ein Werkzeug nachinstalliert, ohne die App neu zu starten.
  static void vergissWerkzeuge() => _verfuegbar = null;

  /// Prüft einmalig, welche Werkzeuge im PATH liegen.
  static Future<Map<String, bool>> pruefeWerkzeuge() async {
    if (_verfuegbar != null) return _verfuegbar!;
    final ergebnis = <String, bool>{};
    for (final w in werkzeuge.keys) {
      ergebnis[w] = await _vorhanden(w);
    }
    return _verfuegbar = ergebnis;
  }

  /// Ob [befehl] im PATH liegt.
  ///
  /// Selbst nachgesehen statt `which` aufzurufen. `which` ist ein eigenes
  /// Programm (debianutils), kein eingebauter Befehl – in einem knapp
  /// geschnürten Flatpak- oder Container-Abbild fehlt es leicht. Dann
  /// meldete diese Prüfung „kein einziges Werkzeug vorhanden", obwohl alle
  /// da sind, und die halbe App schaltete sich grundlos ab. Nebenbei
  /// entfällt ein Prozessstart je Werkzeug.
  @visibleForTesting
  static Future<bool> imPfad(String befehl) => _vorhanden(befehl);

  static Future<bool> _vorhanden(String befehl) async {
    // Ein Pfad im Namen wäre keine PATH-Suche mehr – dann direkt prüfen.
    if (befehl.contains(Platform.pathSeparator)) {
      return _istAusfuehrbar(befehl);
    }
    final pfad = Platform.environment['PATH'];
    if (pfad == null || pfad.isEmpty) return false;
    for (final ordner in pfad.split(':')) {
      if (ordner.isEmpty) continue;
      if (await _istAusfuehrbar(p.join(ordner, befehl))) return true;
    }
    return false;
  }

  static Future<bool> _istAusfuehrbar(String pfad) async {
    try {
      final datei = File(pfad);
      if (!await datei.exists()) return false;
      // Vorhanden genügt nicht – ein Verzeichnis oder eine nicht
      // ausführbare Datei gleichen Namens darf nicht als Werkzeug gelten.
      final rechte = (await datei.stat()).mode;
      return rechte & 0x49 != 0; // --x--x--x
    } catch (_) {
      return false;
    }
  }

  /// Wandelt HEIC/HEIF oder RAW in JPEG-Bytes, skaliert auf [maxDimension].
  ///
  /// Die Werkzeuge können selbst nicht skalieren, deshalb wird die
  /// Zwischendatei anschließend mit dem `image`-Paket verkleinert – in
  /// einem Isolate, damit die UI nicht blockiert (Muster: der bestehende
  /// Thumbnail-Pfad in import_service.dart).
  static Future<Uint8List?> convertToJpeg(
    File datei, {
    int maxDimension = 2048,
    int quality = 90,
  }) async {
    final endung = p.extension(datei.path).toLowerCase();
    final tools = await pruefeWerkzeuge();

    Directory? temp;
    try {
      temp = await Directory.systemTemp.createTemp('pv_convert_');
      final ziel = p.join(temp.path, 'out.jpg');

      if (endung == '.heic' || endung == '.heif') {
        if (tools['heif-convert'] != true) return null;
        final r = await Process.run('heif-convert', [datei.path, ziel]);
        if (r.exitCode != 0) return null;
        // Enthält die Datei mehrere Bilder (Serienaufnahmen, Live Photos),
        // schreibt heif-convert nicht "out.jpg", sondern "out-1.jpg" usw.
        // Dann das erste davon nehmen, statt an der fehlenden out.jpg zu
        // scheitern.
        if (!await File(ziel).exists()) {
          final erstes = temp
              .listSync()
              .whereType<File>()
              .where((f) => p.basename(f.path).startsWith('out-'))
              .toList()
            ..sort((a, b) => a.path.compareTo(b.path));
          if (erstes.isEmpty) return null;
          await erstes.first.rename(ziel);
        }
      } else {
        if (tools['dcraw_emu'] != true) return null;
        // -w Kamera-Weißabgleich, -T TIFF (dcraw_emu kann kein JPEG),
        // -Z - schreibt neben die Eingabe; deshalb in den Temp-Ordner
        // kopieren, damit die Bibliothek unangetastet bleibt.
        final kopie = p.join(temp.path, p.basename(datei.path));
        await datei.copy(kopie);
        final r = await Process.run('dcraw_emu', ['-w', '-T', kopie]);
        if (r.exitCode != 0) return null;
        final tiff = '$kopie.tiff';
        if (!await File(tiff).exists()) return null;
        await File(tiff).rename(ziel);
      }

      final rohBytes = await File(ziel).readAsBytes();
      // await ist wichtig: ohne würde das Future erst NACH dem catch
      // abgeschlossen und ein Fehler im Isolate entkäme der Fehlerbehandlung.
      return await compute(
          _skaliereUndKodiere, _SkalierAuftrag(rohBytes, maxDimension, quality));
    } catch (_) {
      return null;
    } finally {
      // Zwischendateien immer aufräumen, auch bei Fehlern.
      try {
        await temp?.delete(recursive: true);
      } catch (_) {}
    }
  }

  /// Extrahiert ein Vorschaubild aus einem Video plus dessen Länge.
  static Future<({Uint8List jpeg, double? dauerSekunden})?> videoThumbnail(
    File datei, {
    int maxDimension = 800,
  }) async {
    final tools = await pruefeWerkzeuge();
    if (tools['ffmpeg'] != true) return null;

    Directory? temp;
    try {
      temp = await Directory.systemTemp.createTemp('pv_thumb_');
      final ziel = p.join(temp.path, 'frame.jpg');
      // Eine Sekunde hinein statt bei 0: der allererste Frame ist bei
      // vielen Videos schwarz.
      Future<bool> greifeFrame(String position) async {
        final r = await Process.run('ffmpeg', [
          '-y', '-ss', position, '-i', datei.path,
          '-frames:v', '1',
          '-vf', "scale='min($maxDimension,iw)':-2",
          ziel,
        ]);
        return r.exitCode == 0 && await File(ziel).exists();
      }

      // Sekunde 1 statt 0, weil der allererste Frame bei vielen Videos
      // schwarz ist – bei Videos unter einer Sekunde gibt es dort aber
      // keinen Frame mehr, dann von vorn.
      if (!await greifeFrame('1') && !await greifeFrame('0')) return null;
      final jpeg = await File(ziel).readAsBytes();
      return (jpeg: jpeg, dauerSekunden: await videoDauer(datei));
    } catch (_) {
      return null;
    } finally {
      try {
        await temp?.delete(recursive: true);
      } catch (_) {}
    }
  }

  /// Videolänge in Sekunden über ffprobe (Teil von ffmpeg).
  static Future<double?> videoDauer(File datei) async {
    if ((await pruefeWerkzeuge())['ffprobe'] != true) return null;
    try {
      final r = await Process.run('ffprobe', [
        '-v', 'error',
        '-show_entries', 'format=duration',
        '-of', 'default=noprint_wrappers=1:nokey=1',
        datei.path,
      ]);
      if (r.exitCode != 0) return null;
      final d = double.tryParse((r.stdout as String).trim());
      return (d != null && d > 0) ? d : null;
    } catch (_) {
      return null;
    }
  }

  /// Schneidet [datei] verlustfrei zwischen [startSekunden] und
  /// [endSekunden] – ohne Neukodierung (`-c copy`), entspricht damit dem
  /// nicht-destruktiven Verhalten unter macOS.
  static Future<bool> trimVideo(
    File datei, {
    required double startSekunden,
    required double endSekunden,
    required String zielPfad,
  }) async {
    final tools = await pruefeWerkzeuge();
    if (tools['ffmpeg'] != true) return false;
    if (endSekunden <= startSekunden) return false;
    try {
      final r = await Process.run('ffmpeg', [
        '-y',
        '-ss', startSekunden.toStringAsFixed(3),
        '-to', endSekunden.toStringAsFixed(3),
        '-i', datei.path,
        '-c', 'copy',
        zielPfad,
      ]);
      return r.exitCode == 0 && await File(zielPfad).exists();
    } catch (_) {
      return false;
    }
  }
}

class _SkalierAuftrag {
  final Uint8List bytes;
  final int maxDimension;
  final int quality;
  const _SkalierAuftrag(this.bytes, this.maxDimension, this.quality);
}

/// Top-Level-Funktion für `compute()` – verkleinert auf die längste Kante
/// und kodiert als JPEG.
Uint8List? _skaliereUndKodiere(_SkalierAuftrag a) {
  final bild = img.decodeImage(a.bytes);
  if (bild == null) return null;
  final laengsteKante = bild.width > bild.height ? bild.width : bild.height;
  final fertig = laengsteKante > a.maxDimension
      ? img.copyResize(
          bild,
          width: bild.width >= bild.height ? a.maxDimension : null,
          height: bild.height > bild.width ? a.maxDimension : null,
          interpolation: img.Interpolation.average,
        )
      : bild;
  return Uint8List.fromList(img.encodeJpg(fertig, quality: a.quality));
}
