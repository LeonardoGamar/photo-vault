import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_vault/services/bilddekodierung.dart';

/// Die Regel: **Kein Bild wird ohne Deckel dekodiert.**
///
/// Sie stand vorher an genau einer Stelle – in der Vollbildansicht – und
/// galt deshalb auch nur dort. Die 17. Prüfrunde fand drei weitere
/// Stellen, die dieselben Dateien zeigten und dabei die volle Grösse in
/// den Speicher holten: der Vergleich zweier Fotos (und der zeigt zwei
/// gleichzeitig), die Fokus-Hervorhebung im selben Betrachter, dessen
/// anderer Zweig sehr wohl deckelte, und die 360°-Ansicht, deren Dateien
/// die grössten der ganzen Bibliothek sind.
///
/// Dieser Prüfstand liest den Quelltext, weil das die Form des Fehlers
/// ist: nicht ein falsches Ergebnis, sondern eine vergessene Stelle.
void main() {
  /// Jedes Vorkommen von [muster] in [quelle] samt Klammerinhalt.
  List<_Aufruf> aufrufe(String quelle, String muster) {
    final treffer = <_Aufruf>[];
    var ab = 0;
    while (true) {
      final start = quelle.indexOf(muster, ab);
      if (start < 0) break;
      var i = start + muster.length;
      var tiefe = 1;
      while (i < quelle.length && tiefe > 0) {
        if (quelle[i] == '(') tiefe++;
        if (quelle[i] == ')') tiefe--;
        i++;
      }
      treffer.add(_Aufruf(
        zeile: '\n'.allMatches(quelle.substring(0, start)).length + 1,
        rumpf: quelle.substring(start, i),
        davor: quelle.substring(start < 60 ? 0 : start - 60, start),
      ));
      ab = start + muster.length;
    }
    return treffer;
  }

  Iterable<File> quelldateien() sync* {
    for (final ordner in ['lib/screens', 'lib/widgets']) {
      for (final e in Directory(ordner).listSync(recursive: true)) {
        if (e is File && e.path.endsWith('.dart')) yield e;
      }
    }
  }

  test('kein Image.file und kein FileImage ohne Deckel', () {
    final ohne = <String>[];
    for (final datei in quelldateien()) {
      final quelle = datei.readAsStringSync();
      for (final muster in ['Image.file(', 'FileImage(']) {
        for (final a in aufrufe(quelle, muster)) {
          // Zwei erlaubte Wege: `cacheWidth` (dann steht die Zielgrösse
          // beim Aufruf) oder [begrenztesBild] (dann steht sie an der
          // einen Stelle, an der sie hingehört).
          if (a.rumpf.contains('cacheWidth')) continue;
          // `ResizeImage(FileImage(...))` ist derselbe Deckel, nur von
          // Hand geschrieben. Geprüft wird das Stück davor, nicht die
          // Einrückung: Die verschiebt sich mit jeder Formatierung.
          if (muster == 'FileImage(' && a.davorEnthaelt('ResizeImage(')) {
            continue;
          }
          ohne.add('${datei.path}:${a.zeile}  $muster');
        }
      }
    }
    expect(
      ohne,
      isEmpty,
      reason: 'Diese Stellen dekodieren eine Datei in ihrer vollen Grösse. '
          'Ein Original der Prüfbibliothek misst 20383 × 4077 Punkte und '
          'belegt damit 317 MB. Entweder cacheWidth angeben oder '
          'begrenztesBild() benutzen:\n${ohne.join('\n')}',
    );
  });

  test('die Stellen, um die es ging, gehen wirklich über den Deckel', () {
    // Gegenprobe zur Regel oben: Sie liesse sich auch dadurch erfüllen,
    // dass jemand die Zeile ganz entfernt. Diese drei Bildschirme müssen
    // das Bild weiterhin zeigen – nur eben begrenzt.
    for (final pfad in [
      'lib/screens/photo_compare_screen.dart',
      'lib/screens/asset_viewer_screen.dart',
      'lib/widgets/panorama_360_view.dart',
    ]) {
      expect(File(pfad).readAsStringSync(), contains('begrenztesBild('),
          reason: '$pfad zeigt ein Original und braucht den Deckel');
    }
  });

  group('begrenztesBild', () {
    final datei = File('test/fixtures/werkzeuge/probe.heic');

    test('deckelt auf die gemeinsame Kante', () {
      final bild = begrenztesBild(datei) as ResizeImage;
      expect(bild.width, maxDekodierKante);
      expect(bild.height, maxDekodierKante);
      // `fit`, nicht `exact`: Ein Panorama darf nicht zum Quadrat werden.
      expect(bild.policy, ResizeImagePolicy.fit);
      // Ein kleines Foto soll nicht aufgeblasen werden – das kostete
      // Speicher, ohne einen Punkt mehr zu zeigen.
      expect(bild.allowUpscaling, isFalse);
    });

    test('eine engere Kante lässt sich verlangen', () {
      expect((begrenztesBild(datei, kante: 512) as ResizeImage).width, 512);
    });
  });
}

/// Ein gefundener Aufruf samt dem, was unmittelbar davor steht.
class _Aufruf {
  _Aufruf({required this.zeile, required this.rumpf, required this.davor});
  final int zeile;
  final String rumpf;
  final String davor;

  bool davorEnthaelt(String was) => davor.contains(was);
}
