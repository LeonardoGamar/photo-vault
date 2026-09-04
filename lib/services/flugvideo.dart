/// **Den Überflug als Video – zum Weitergeben.**
///
/// Ein Überflug, den nur die App zeigen kann, endet in der App. Wer eine
/// Wanderung jemandem zeigen will, der kein PhotoVault hat, braucht eine
/// Datei. Genau das ist bei Strava und Relive der Grund, warum überhaupt
/// jemand einen Flyover erzeugt.
///
/// **Rohe Bildpunkte über `stdin`, nicht tausend PNG-Dateien.** Die
/// Bilder entstehen ohnehin; sie einzeln auf die Platte zu schreiben und
/// von dort wieder einzulesen wäre bei dreissig Sekunden in 1920 × 1080
/// ein Umweg über rund neunhundert Dateien und mehrere Gigabyte
/// Zwischenablage. `ffmpeg` nimmt sie stattdessen als Strom entgegen und
/// gibt sie sofort in den Kodierer.
///
/// **ffmpeg liegt unter Linux und Windows im Paket, unter macOS nicht.**
/// Dort greift die vorhandene Werkzeugsuche ([DesktopImageTools]), und
/// fehlt es, sagt die App das – statt still nichts zu tun.
///
/// **An einem echten Lauf gemessen** (TestKubuntu, ffmpeg 8.0.1,
/// `tool/flugvideo_probe_test.dart`):
///
/// ```
/// 90 Bilder in 1920 x 1080   4,4 s   516 kB
/// ffprobe: h264, 1920x1080, nb_read_frames=90
/// ```
///
/// Rund 49 ms je Bild, und das unter der Softwarewiedergabe von
/// `flutter test`. Ein Überflug von dreissig Sekunden kostet damit etwa
/// eine Dreiviertelminute – dazu kommt, was die Kacheln brauchen, die
/// noch nicht auf der Platte liegen.
library;

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'platform/desktop_image_tools.dart';

/// Wie ein Lauf ausgegangen ist.
enum Videoausgang {
  fertig,

  /// Kein ffmpeg gefunden – unter macOS der Regelfall, solange niemand
  /// eines installiert hat.
  keinWerkzeug,

  /// Der Aufrufer hat abgebrochen.
  abgebrochen,

  /// ffmpeg hat sich beschwert. Was es gesagt hat, steht in
  /// [Videoergebnis.meldung].
  fehler,
}

typedef Videoergebnis = ({Videoausgang ausgang, String? meldung});

/// Wie viele Bilder je Sekunde.
///
/// **Dreissig und nicht sechzig.** Ein Überflug ist eine gleichmässige
/// Bewegung ohne schnelle Wechsel; sechzig Bilder verdoppeln Rechenzeit
/// und Dateigrösse und sind daneben nicht zu unterscheiden. Fünfundzwanzig
/// wären europäisches Fernsehen, dreissig ist das, was Telefone
/// aufnehmen und was jede Plattform ohne Umrechnung annimmt.
const int videoBilderJeSekunde = 30;

/// Ob ein Videoexport überhaupt möglich ist.
Future<String?> ffmpegPfad() => DesktopImageTools.aufruf('ffmpeg');

/// Schreibt den Flug als MP4.
///
/// [maleBild] wird je Bild gerufen und bekommt den Fortschritt von 0 bis
/// 1. [vorBild] darf vorher noch etwas holen – der Landschaftsflug lädt
/// dort die Kacheln nach, die in genau diesem Bild stehen.
/// [fortschritt] meldet, wie weit der Lauf ist – für die Anzeige.
/// [abbruch] wird vor jedem Bild gefragt; sagt es `true`, hört der Lauf
/// auf und die halbfertige Datei wird **gelöscht**. Eine abgebrochene
/// Ausgabe soll keine unbrauchbare Datei hinterlassen.
Future<Videoergebnis> schreibeFlugvideo({
  required File ziel,
  required int breite,
  required int hoehe,
  required Duration dauer,
  required void Function(ui.Canvas leinwand, ui.Size flaeche, double t)
      maleBild,
  Future<void> Function(double t)? vorBild,
  int bilderJeSekunde = videoBilderJeSekunde,
  void Function(double anteil)? fortschritt,
  bool Function()? abbruch,
  String? ffmpeg,
}) async {
  final werkzeug = ffmpeg ?? await ffmpegPfad();
  if (werkzeug == null) {
    return (ausgang: Videoausgang.keinWerkzeug, meldung: null);
  }

  // **Gerade Kantenlängen.** `yuv420p` tastet die Farbe halb so fein ab
  // wie die Helligkeit; eine ungerade Kante lässt sich nicht halbieren,
  // und ffmpeg bricht mit „width not divisible by 2" ab.
  final b = breite - (breite % 2);
  final h = hoehe - (hoehe % 2);
  final bilder = (dauer.inMilliseconds * bilderJeSekunde / 1000).round();
  if (b < 2 || h < 2 || bilder < 1) {
    // Kein Satz für die Oberfläche: Eine Grösse oder Dauer von null ist
    // ein Programmierfehler, kein Zustand, in den jemand gerät.
    return (ausgang: Videoausgang.fehler, meldung: 'size=${b}x$h frames=$bilder');
  }

  // **Der Start selbst kann werfen.** Ein Pfad, der zwischen Suche und
  // Aufruf verschwindet – ein deinstalliertes Homebrew, ein
  // ausgehängtes Laufwerk – lässt `Process.start` mit einer
  // `ProcessException` abbrechen, und die fiel bis hierher durch bis in
  // die Oberfläche. Gefunden hat es der Test mit einem Pfad, den es
  // absichtlich nicht gibt.
  final Process prozess;
  try {
    prozess = await Process.start(werkzeug, [
      '-y',
      '-f', 'rawvideo',
      '-pixel_format', 'rgba',
      '-video_size', '${b}x$h',
      '-framerate', '$bilderJeSekunde',
      '-i', '-',
      '-c:v', 'libx264',
      '-preset', 'medium',
      // 20 ist sichtbar verlustfrei und ergibt bei dreissig Sekunden in
      // 1920 x 1080 rund 15 MB - klein genug zum Verschicken.
      '-crf', '20',
      '-pix_fmt', 'yuv420p',
      // Der Index nach vorn: Ohne das faengt ein Abspieler im Netz erst
      // an, wenn die ganze Datei da ist.
      '-movflags', '+faststart',
      ziel.path,
    ]);
  } catch (e) {
    return (ausgang: Videoausgang.fehler, meldung: '$e');
  }

  // **Die Fehlerausgabe muss mitgelesen werden, auch wenn sie niemanden
  // interessiert.** Ein Prozess, dessen `stderr` niemand leert, bleibt
  // stehen, sobald die Puffergrösse des Betriebssystems erreicht ist –
  // und ffmpeg schreibt bei jedem Bild eine Zeile.
  final meldungen = StringBuffer();
  final fehlerstrom = prozess.stderr
      .transform(const SystemEncoding().decoder)
      .listen(meldungen.write);

  var abgebrochen = false;
  try {
    for (var i = 0; i < bilder; i++) {
      if (abbruch?.call() ?? false) {
        abgebrochen = true;
        break;
      }
      final t = bilder == 1 ? 0.0 : i / (bilder - 1);
      // **Vor dem Malen, nicht danach.** Was hier nachgeladen wird,
      // gehört in genau dieses Bild; ein Video hat kein „ein Bild
      // später".
      await vorBild?.call(t);
      final sammler = ui.PictureRecorder();
      maleBild(ui.Canvas(sammler), ui.Size(b.toDouble(), h.toDouble()), t);
      final aufnahme = sammler.endRecording();
      ui.Image bild;
      try {
        bild = await aufnahme.toImage(b, h);
      } finally {
        aufnahme.dispose();
      }
      try {
        final roh = await bild.toByteData(format: ui.ImageByteFormat.rawRgba);
        if (roh == null) continue;
        prozess.stdin.add(roh.buffer.asUint8List());
        // Nach jedem Bild leeren: Sonst sammelt Dart die Bilder im
        // eigenen Puffer, und aus dem Strom wird wieder ein Gigabyte im
        // Speicher – genau das, was der Weg über `stdin` vermeiden soll.
        await prozess.stdin.flush();
      } finally {
        bild.dispose();
      }
      fortschritt?.call((i + 1) / bilder);
    }
    await prozess.stdin.close();
  } catch (e) {
    prozess.kill();
    await fehlerstrom.cancel();
    return (ausgang: Videoausgang.fehler, meldung: '$e');
  }

  final code = await prozess.exitCode;
  await fehlerstrom.cancel();

  if (abgebrochen) {
    // Eine halbfertige Datei sieht aus wie eine fertige und laesst sich
    // nicht abspielen.
    try {
      if (ziel.existsSync()) await ziel.delete();
    } catch (_) {
      // Nicht loeschen zu koennen ist kein Grund, den Abbruch zu einem
      // Fehler zu machen.
    }
    return (ausgang: Videoausgang.abgebrochen, meldung: null);
  }
  if (code != 0) {
    return (
      ausgang: Videoausgang.fehler,
      // Nur die letzten Zeilen: ffmpeg schreibt bei dreissig Sekunden
      // neunhundert Fortschrittszeilen, und der Grund steht am Ende.
      meldung: _letzteZeilen(meldungen.toString(), 6),
    );
  }
  return (ausgang: Videoausgang.fertig, meldung: null);
}

String _letzteZeilen(String text, int wieviele) {
  final zeilen = text
      .split(RegExp(r'[\r\n]+'))
      .where((z) => z.trim().isNotEmpty)
      .toList();
  if (zeilen.length <= wieviele) return zeilen.join('\n');
  return zeilen.sublist(zeilen.length - wieviele).join('\n');
}
