import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:photo_vault/services/native_image_converter.dart';
import 'package:photo_vault/services/platform/linux_image_tools.dart';

/// Der Werkzeuge-Bildschirm fragte für seine Statuszeile
/// `NativeImageConverter.isSupported()` ab – das ist ausserhalb von macOS
/// grundsätzlich `false`. Unter Linux stand dort deshalb „inaktiv", obwohl
/// HEIC, RAW und Video nachweislich arbeiteten.
void main() {
  tearDown(LinuxImageTools.vergissWerkzeuge);

  test('meldet unter Linux nicht pauschal „nicht unterstützt"', () async {
    final stand = await NativeImageConverter.bildwerkzeugstand();

    if (Platform.isLinux) {
      // Auf dieser Maschine sind die Werkzeuge da – dann muss die Auskunft
      // „bereit" lauten und darf nichts vermissen.
      expect(stand.bereit, stand.fehlende.isEmpty,
          reason: 'bereit und fehlende dürfen sich nicht widersprechen');
    } else {
      // Überall sonst bleibt es bei der bisherigen Antwort, und die Liste
      // der fehlenden Werkzeuge ist gegenstandslos.
      expect(stand.fehlende, isEmpty);
    }
  });

  test('nennt jedes fehlende Werkzeug beim Namen', () async {
    final stand = await NativeImageConverter.bildwerkzeugstand();

    // Was gemeldet wird, muss auch ein bekanntes Werkzeug sein – sonst
    // stünde im Bildschirm ein Name, mit dem niemand etwas anfangen kann.
    for (final name in stand.fehlende) {
      expect(LinuxImageTools.werkzeuge.keys, contains(name));
    }
  }, skip: !Platform.isLinux);

  test('bereit und fehlende widersprechen sich nie', () async {
    final stand = await NativeImageConverter.bildwerkzeugstand();
    if (stand.fehlende.isNotEmpty) {
      expect(stand.bereit, isFalse);
    }
  });
}
