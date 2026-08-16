import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:photo_vault/db/database.dart';
import 'package:photo_vault/services/backup_service.dart';
import 'package:photo_vault/services/captioning_service.dart';
import 'package:photo_vault/services/clip_service.dart';
import 'package:photo_vault/services/eye_state_service.dart';
import 'package:photo_vault/services/face_engine_service.dart';
import 'package:photo_vault/services/modell_halter.dart';
import 'package:photo_vault/services/storage_paths.dart';
import 'package:photo_vault/state/library_state.dart';

/// Die Hintergrundanalyse läuft bei jedem Programmstart automatisch an.
/// Lieh sie sich ihre Modelle, BEVOR sie nachsah, ob überhaupt Fotos offen
/// sind, belegte die App bei fertig ausgewerteter Bibliothek 1076 statt
/// 214 MB – ohne ein einziges Foto anzufassen. Damit war der Zweck des
/// bedarfsweisen Ladens für den Normalfall aufgehoben.
///
/// Dieser Test hält fest, dass keine Stufe ein Modell anfordert, solange es
/// nichts zu tun gibt.
void main() {
  test('ohne offene Fotos fordert keine Analysestufe ein Modell an', () async {
    final tempRoot = Directory.systemTemp.createTempSync('pv_lazy_');
    addTearDown(() => tempRoot.deleteSync(recursive: true));
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final paths = await StoragePaths.forTesting(Directory(p.join(tempRoot.path, 'lib')));

    // Jeder Ladeversuch wird vermerkt und schlägt dann fehl. Echte Modelle
    // gibt es im Test nicht (die ONNX-Anbindung läuft über einen
    // Plattformkanal) – gebraucht werden sie hier auch nicht, denn erwartet
    // wird ja gerade, dass NICHT geladen wird. Dass die Stufen den Fehler
    // ihrerseits abfangen, ist gewollt und ändert am Vermerk nichts.
    final versuche = <String>[];
    ModellHalter<T> falle<T>(String name) => ModellHalter<T>(
          name: name,
          installiert: true,
          laden: () async {
            versuche.add(name);
            throw StateError('$name hätte nicht geladen werden dürfen');
          },
          entsorgen: (_) async {},
        );

    final lib = LibraryState()
      ..db = db
      ..paths = paths
      ..backupService = BackupService(db, paths)
      ..faceEngineHalter = falle<FaceEngineService>('Gesichter')
      ..eyeStateHalter = falle<EyeStateService>('Augen')
      ..clipBildHalter = falle<ClipService>('CLIP-Bild')
      ..clipTextHalter = falle<ClipService>('CLIP-Text')
      ..captioningHalter = falle<CaptioningService>('Bildbeschreibung');

    // Leere Bibliothek: keine Stufe hat etwas zu tun.
    await lib.starteHintergrundanalyse();

    expect(versuche, isEmpty,
        reason: 'ohne offene Fotos darf kein Modell in den Speicher – '
            'angefordert wurde aber: ${versuche.join(", ")}');
  });
}
