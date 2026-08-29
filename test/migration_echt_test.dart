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

      // Die damals neuen Tabellen lassen sich lesen, und an den Aufnahmen
      // hat sich nichts geändert.
      //
      // Früher stand hier `isEmpty`: Als die Tabellen dazukamen, war das die
      // richtige Prüfung. Inzwischen sind in der grossen Bibliothek
      // Aktivitäten und Reisen erkannt worden, und eine leere Tabelle wäre
      // gerade das Alarmzeichen. Geprüft wird deshalb, dass die Abfrage
      // durchläuft – die Migration darf sie weder verlieren noch
      // unlesbar machen.
      await db.alleAktivitaeten();
      await db.alleSpuren();
      final nachher = await db.customSelect('SELECT count(*) AS n FROM assets')
          .map((r) => r.read<int>('n'))
          .getSingle();
      expect(nachher, vorher, reason: name);

      // Und die Reisen stehen noch – die Tabelle daneben.
      await db.alleReisen();

      // Schema 60: die Spalte ist da, und der bereits erkannte Text ist
      // unangetastet geblieben. Die Stellen dazu holt erst ein neuer Lauf
      // der Texterkennung – bis dahin steht dort überall null, und genau
      // diese Fotos muss der Nachlauf wieder aufgreifen.
      final offen = await db.countOcrBackfill();
      // Dieselben Filter wie [_ocrOffen]: Papierkorb und Tresor bleiben
      // aussen vor. In der grossen Bibliothek trennt genau das 2406
      // erkannte Texte von 2256 erneut erreichbaren – der Rest liegt im
      // Papierkorb oder gesperrt, und beides soll die Texterkennung nicht
      // anfassen.
      final mitText = await db
          .customSelect('SELECT count(*) AS n FROM assets '
              "WHERE type = 'IMAGE' AND is_trashed = 0 AND is_locked = 0 "
              "AND ocr_text IS NOT NULL AND ocr_text <> '' AND ocr_boxen IS NULL")
          .map((r) => r.read<int>('n'))
          .getSingle();
      expect(offen, greaterThanOrEqualTo(mitText), reason: name);
      // ignore: avoid_print
      print('$name: $mitText Aufnahmen mit Text, aber ohne Stellen; '
          '$offen offen fuer die Texterkennung');
      await db.close();
      // ignore: avoid_print
      print('$name: $vorher Aufnahmen, Fassung $fassung');
    }
  });
}
