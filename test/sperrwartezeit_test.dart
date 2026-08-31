import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_vault/db/database.dart';
import 'package:sqlite3/sqlite3.dart' as raw;

/// **Was passiert, wenn zwei auf dieselbe Datenbank schreiben.**
///
/// SQLites Vorgabe für `busy_timeout` ist **null**: Wer auf eine belegte
/// Datei trifft, bekommt sofort „database is locked" und keinen zweiten
/// Versuch. Das ist so lange folgenlos, wie genau ein Prozess die Datei
/// anfasst – und genau das ist nicht zugesichert. Nichts in diesem
/// Programm hindert jemanden daran, es zweimal zu starten; auf dem
/// Windows-Prüfrechner liefen bei der 22. Prüfrunde zwei Fassungen
/// stundenlang nebeneinander, ohne dass eine davon etwas gemerkt hätte.
///
/// An zwei echten Prozessen gemessen (400 Zeilen jeder, gleichzeitig):
///
/// ```
/// ohne Wartezeit    734 von 800 Schreibvorgängen scheitern
/// 5 Sekunden          0 von 800, zusammen 170 ms
/// ```
void main() {
  late Directory ordner;
  late File datei;

  setUp(() {
    ordner = Directory.systemTemp.createTempSync('pv_sperre_');
    datei = File('${ordner.path}/library.sqlite');
  });
  tearDown(() => ordner.deleteSync(recursive: true));

  test('die Vorgabe wird gesetzt und ist nicht null', () async {
    final db = AppDatabase(
        NativeDatabase(datei, setup: AppDatabase.bereiteVerbindungVor));
    addTearDown(db.close);
    final zeile = await db.customSelect('PRAGMA busy_timeout').getSingle();
    expect(zeile.data.values.first, AppDatabase.sperrwartezeitMs);
    expect(AppDatabase.sperrwartezeitMs, greaterThan(0),
        reason: 'null hiesse: sofort aufgeben, und das war der Befund');
  });

  test('eine fremde Sperre lässt den Schreibvorgang nicht scheitern',
      () async {
    // Der zweite Zugriff ist hier eine eigene sqlite3-Verbindung mit einer
    // OFFENEN Schreibtransaktion – dasselbe, was ein zweiter Prozess tut,
    // nur ohne einen zweiten Prozess starten zu müssen.
    // **Im Hintergrund-Isolat, wie im Betrieb.** Mit dem einfachen
    // `NativeDatabase` läuft SQLite auf demselben Isolat: Die Wartezeit
    // blockiert dann die Ereignisschleife, und der Timer, der die Sperre
    // gleich wieder löst, käme nie dran – der Test hinge fünf Sekunden an
    // sich selbst und fiele.
    //
    // Dasselbe gilt im Betrieb, und deshalb ist es kein Testkniff,
    // sondern der Grund, warum fünf Sekunden vertretbar sind:
    // [AppDatabase.open] nimmt `createInBackground`, also wartet nicht
    // die Oberfläche, sondern ein Isolat, das ohnehin nichts anderes tut.
    final db = AppDatabase(NativeDatabase.createInBackground(datei,
        setup: AppDatabase.bereiteVerbindungVor));
    addTearDown(db.close);
    // Erst einmal anlegen, damit beide dieselbe Datei meinen.
    await db.customSelect('SELECT 1').get();

    final fremd = raw.sqlite3.open(datei.path);
    addTearDown(fremd.close);
    fremd.execute('PRAGMA busy_timeout = 0');
    fremd.execute('BEGIN IMMEDIATE');
    fremd.execute(
        'CREATE TABLE IF NOT EXISTS fremd (id INTEGER PRIMARY KEY)');

    // Die Sperre nach kurzer Zeit wieder lösen – die App muss so lange
    // warten statt aufzugeben.
    unawaited(Future.delayed(
        const Duration(milliseconds: 300), () => fremd.execute('COMMIT')));

    final uhr = Stopwatch()..start();
    await db.insertAsset(AssetsCompanion.insert(
      id: 'a',
      relativePath: 'originals/a.jpg',
      originalFileName: 'a.jpg',
      type: 'IMAGE',
      checksum: 'a',
      fileCreatedAt: DateTime(2026),
      importedAt: DateTime(2026),
      isTrashed: const Value(false),
    ));
    uhr.stop();

    expect(await db.assetById('a'), isNotNull,
        reason: 'geschrieben werden muss es, nicht abgelehnt');
    expect(uhr.elapsedMilliseconds, greaterThan(100),
        reason: 'es hat wirklich gewartet – sonst prüft dieser Test nichts');
  }, timeout: const Timeout(Duration(seconds: 30)));

  test('ohne Wartezeit scheitert derselbe Schreibvorgang', () async {
    // Die Gegenprobe im selben Test: Mit der Vorgabe von SQLite gibt es
    // keinen zweiten Versuch, und genau das war der Befund.
    final db = AppDatabase(NativeDatabase.createInBackground(datei,
        setup: (d) => d.execute('PRAGMA busy_timeout = 0')));
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();

    final fremd = raw.sqlite3.open(datei.path);
    addTearDown(fremd.close);
    fremd.execute('PRAGMA busy_timeout = 0');
    fremd.execute('BEGIN IMMEDIATE');
    fremd.execute('CREATE TABLE IF NOT EXISTS fremd (id INTEGER PRIMARY KEY)');

    await expectLater(
      db.insertAsset(AssetsCompanion.insert(
        id: 'b',
        relativePath: 'originals/b.jpg',
        originalFileName: 'b.jpg',
        type: 'IMAGE',
        checksum: 'b',
        fileCreatedAt: DateTime(2026),
        importedAt: DateTime(2026),
        isTrashed: const Value(false),
      )),
      throwsA(predicate((e) => '$e'.contains('locked'))),
    );
    fremd.execute('COMMIT');
  }, timeout: const Timeout(Duration(seconds: 30)));
}

/// Ein Future bewusst nicht abwarten, ohne dass die Prüfung meckert.
void unawaited(Future<void> _) {}
