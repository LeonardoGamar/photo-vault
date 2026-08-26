import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_vault/db/database.dart';

/// Die jüngste Migration an **Kopien echter Bibliotheken**.
///
/// Läuft nur, wenn die Kopien dort liegen, wo die Umgebungsvariable
/// `PV_MIGRATION_DIR` hinzeigt – sonst hinge die ganze Suite an Dateien,
/// die es auf keiner anderen Maschine gibt. Der Grund für den Test:
/// Eine Migration, die auf einer leeren Datenbank läuft, sagt nichts
/// darüber, ob sie auf einer gewachsenen läuft.
void main() {
  final ordner = Platform.environment['PV_MIGRATION_DIR'];

  test('drei gewachsene Bibliotheken kommen auf die neueste Fassung',
      () async {
    if (ordner == null) {
      markTestSkipped('PV_MIGRATION_DIR nicht gesetzt');
      return;
    }
    for (final name in ['gross.sqlite', 'alt32.sqlite', 'alt27.sqlite']) {
      final datei = File('$ordner/$name');
      expect(datei.existsSync(), isTrue, reason: '$name fehlt');

      final db = AppDatabase(NativeDatabase(datei));
      // Die erste Abfrage löst die Migration aus.
      final vorher = await db.customSelect('SELECT count(*) AS n FROM assets')
          .map((r) => r.read<int>('n'))
          .getSingle();
      final fassung = await db
          .customSelect('PRAGMA user_version')
          .map((r) => r.read<int>('user_version'))
          .getSingle();
      expect(fassung, db.schemaVersion, reason: name);

      final tabellen = {
        for (final z in await db
            .customSelect("SELECT name FROM sqlite_master WHERE type='table'")
            .get())
          z.data['name'] as String
      };
      for (final erwartet in [
        'aktivitaeten',
        'aktivitaet_aufnahmen',
        'verworfene_aktivitaeten',
        'spuren',
        'spurpunkte',
      ]) {
        expect(tabellen, contains(erwartet), reason: '$name: $erwartet');
      }

      // Die neuen Tabellen sind leer, und an den Aufnahmen hat sich
      // nichts geändert: Ohne einen einzigen Eintrag verhält sich alles
      // wie zuvor.
      expect(await db.alleAktivitaeten(), isEmpty, reason: name);
      expect(await db.alleSpuren(), isEmpty, reason: name);
      final nachher = await db.customSelect('SELECT count(*) AS n FROM assets')
          .map((r) => r.read<int>('n'))
          .getSingle();
      expect(nachher, vorher, reason: name);

      // Und die Reisen stehen noch – die Tabelle daneben.
      await db.alleReisen();
      await db.close();
      // ignore: avoid_print
      print('$name: $vorher Aufnahmen, Fassung $fassung');
    }
  });
}
