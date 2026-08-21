import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:photo_vault/services/platform/linux_image_tools.dart';

/// Die Linux-Fassung ruft Kommandozeilenwerkzeuge auf und muss vorher
/// wissen, welche davon es gibt. Diese Suche lief über `which` – ein
/// eigenes Programm, das in einem knapp geschnürten Flatpak- oder
/// Container-Abbild fehlen kann. Fehlt es, meldete die Prüfung „kein
/// einziges Werkzeug vorhanden", obwohl alle da sind, und die halbe App
/// schaltete sich grundlos ab.
///
/// Die Suche läuft deshalb selbst über den PATH. Das ist plattformgleich
/// und lässt sich hier auf macOS prüfen, obwohl das Ziel Linux ist.
void main() {
  setUp(LinuxImageTools.vergissWerkzeuge);

  test('findet ein Programm, das es überall gibt', () async {
    expect(await LinuxImageTools.imPfad('sh'), isTrue);
  });

  test('findet nichts, wo nichts ist', () async {
    expect(await LinuxImageTools.imPfad('gibt-es-ganz-sicher-nicht-xyz'), isFalse);
  });

  test('ein gleichnamiges Verzeichnis gilt nicht als Werkzeug', () async {
    // Ohne die Rechte-Prüfung genügte ein Ordner namens „ffmpeg" im PATH,
    // um die App glauben zu lassen, sie könne Videos verarbeiten.
    final temp = Directory.systemTemp.createTempSync('pv_pfad_');
    addTearDown(() => temp.deleteSync(recursive: true));
    Directory('${temp.path}/ffmpeg').createSync();

    final vorher = Platform.environment['PATH'];
    expect(vorher, isNotNull);
    // Der PATH lässt sich im Prozess nicht ändern – deshalb über den
    // absoluten Pfad, der denselben Zweig nimmt.
    expect(await LinuxImageTools.imPfad('${temp.path}/ffmpeg'), isFalse);
  });

  test('eine nicht ausführbare Datei gilt nicht als Werkzeug', () async {
    final temp = Directory.systemTemp.createTempSync('pv_pfad2_');
    addTearDown(() => temp.deleteSync(recursive: true));
    final datei = File('${temp.path}/ffmpeg')..writeAsStringSync('kein Programm');

    expect(await LinuxImageTools.imPfad(datei.path), isFalse);

    // Mit gesetztem Ausführungsrecht dagegen schon.
    Process.runSync('chmod', ['+x', datei.path]);
    expect(await LinuxImageTools.imPfad(datei.path), isTrue);
  });

  test('die Werkzeugliste nennt zu jedem Eintrag einen Zweck', () {
    // ffprobe muss einzeln dabeistehen: videoDauer ruft ausschliesslich
    // ffprobe auf, nur ffmpeg zu prüfen behauptete eine ungeprüfte
    // Verfügbarkeit.
    expect(LinuxImageTools.werkzeuge.keys,
        containsAll(['heif-convert', 'dcraw_emu', 'ffmpeg', 'ffprobe']));
    for (final zweck in LinuxImageTools.werkzeuge.values) {
      expect(zweck, isNotEmpty);
    }
  });
}
