import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_vault/theme/app_theme.dart';

/// Lesbarkeit kleiner Beschriftungen.
///
/// Anlass: In der App stehen mehrere Beschriftungen in `Colors.grey` auf
/// dunklem Grund, teils bei 9 oder 10 Punkten. Ob das reicht, laesst sich
/// rechnen statt schaetzen - WCAG verlangt 4,5:1 fuer kleinen Text, 3:1
/// fuer grossen (ab 18,66 px fett bzw. 24 px).
double _kanal(double c) =>
    c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();

double helligkeit(Color f) =>
    0.2126 * _kanal(f.r) + 0.7152 * _kanal(f.g) + 0.0722 * _kanal(f.b);

double kontrast(Color a, Color b) {
  final ha = helligkeit(a), hb = helligkeit(b);
  final hell = math.max(ha, hb), dunkel = math.min(ha, hb);
  return (hell + 0.05) / (dunkel + 0.05);
}

void main() {
  final dunkel = buildDarkTheme().colorScheme;

  test('die gemessenen Werte, zum Nachlesen', () {
    // ignore: avoid_print
    print('Grundflaeche: ${dunkel.surface}');
    for (final (name, farbe) in [
      ('onSurface', dunkel.onSurface),
      ('onSurfaceVariant', dunkel.onSurfaceVariant),
      ('outline', dunkel.outline),
      ('Colors.grey', Colors.grey),
      ('Colors.white', Colors.white),
    ]) {
      // ignore: avoid_print
      print('  $name: ${kontrast(farbe, dunkel.surface).toStringAsFixed(2)}:1');
    }
  });

  test('die Grundfarben des dunklen Themas tragen', () {
    expect(kontrast(dunkel.onSurface, dunkel.surface), greaterThan(4.5),
        reason: 'Fliesstext auf der Grundflaeche');
    expect(kontrast(dunkel.onSurfaceVariant, dunkel.surface),
        greaterThan(4.5),
        reason: 'die zweite Textfarbe, in der die meisten Beschriftungen '
            'stehen');
  });

  test('Colors.grey als Beschriftungsfarbe auf dunklem Grund', () {
    // Genau die Kombination aus map_screen.dart:471 und
    // second_library_compare_screen.dart:278, beide bei 10 Punkten.
    final wert = kontrast(Colors.grey, dunkel.surface);
    expect(wert, greaterThan(4.5),
        reason: 'Colors.grey (#9E9E9E) auf ${dunkel.surface} '
            'ergibt ${wert.toStringAsFixed(2)}:1 - '
            'onSurfaceVariant waere die Farbe des Themas');
  });

  test('der Umriss ist keine Textfarbe', () {
    // people_screen.dart:877 setzt `colorScheme.outline` als Textfarbe bei
    // 9 Punkten. `outline` ist fuer Linien gedacht, nicht fuer Schrift.
    final wert = kontrast(dunkel.outline, dunkel.surface);
    expect(wert, greaterThan(4.5),
        reason: 'outline auf surface ergibt ${wert.toStringAsFixed(2)}:1');
  });
}
