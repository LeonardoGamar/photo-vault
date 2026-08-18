import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_vault/theme/app_theme.dart';

/// Kontrast lässt sich ausrechnen statt einschätzen.
///
/// Diese Prüfung gibt es, weil zweimal hintereinander dasselbe passiert
/// ist: Farben, die auf dunklem Grund entworfen wurden, standen später auf
/// hellem (Colors.orange, 2,05:1) – und Farben für abgeschaltete Elemente
/// standen unter erklärendem Text (Colors.white38, 3,44:1). Beide Male fiel
/// es erst beim Nachrechnen auf.
double _linear(double kanal) => kanal <= 0.03928
    ? kanal / 12.92
    : math.pow((kanal + 0.055) / 1.055, 2.4).toDouble();

double _leuchtdichte(Color c) =>
    0.2126 * _linear(c.r) + 0.7152 * _linear(c.g) + 0.0722 * _linear(c.b);

/// Halbdurchsichtiges Weiss auf einem Grund – das ist, was jemand sieht.
Color _ueberlagert(Color vorn, Color grund) => Color.from(
      alpha: 1,
      red: vorn.r * vorn.a + grund.r * (1 - vorn.a),
      green: vorn.g * vorn.a + grund.g * (1 - vorn.a),
      blue: vorn.b * vorn.a + grund.b * (1 - vorn.a),
    );

double kontrast(Color vorn, Color grund) {
  final a = _leuchtdichte(_ueberlagert(vorn, grund));
  final b = _leuchtdichte(grund);
  return (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05);
}

void main() {
  group('dunkle Arbeitsflächen', () {
    const grund = DunkleFlaeche.grund;

    test('Text, den jemand lesen soll, schafft 4,5:1', () {
      for (final e in {
        'text': DunkleFlaeche.text,
        'zweitText': DunkleFlaeche.zweitText,
        'hinweis': DunkleFlaeche.hinweis,
      }.entries) {
        final wert = kontrast(e.value, grund);
        expect(wert, greaterThanOrEqualTo(4.5),
            reason: '${e.key} kommt nur auf ${wert.toStringAsFixed(2)}:1');
      }
    });

    test('die Rollen sind nach Kontrast geordnet', () {
      // Wäre ein Hinweis heller als der Haupttext, stimmte die Hierarchie
      // nicht mehr – und jemand hätte die Rollen vertauscht.
      expect(kontrast(DunkleFlaeche.text, grund),
          greaterThan(kontrast(DunkleFlaeche.zweitText, grund)));
      expect(kontrast(DunkleFlaeche.zweitText, grund),
          greaterThan(kontrast(DunkleFlaeche.hinweis, grund)));
      expect(kontrast(DunkleFlaeche.hinweis, grund),
          greaterThan(kontrast(DunkleFlaeche.inaktiv, grund)));
      expect(kontrast(DunkleFlaeche.inaktiv, grund),
          greaterThan(kontrast(DunkleFlaeche.linie, grund)));
    });

    test('inaktiv und linie tragen bewusst keinen Text', () {
      // Sie stehen absichtlich unter 4,5:1. Der Test hält fest, dass das
      // eine Entscheidung ist und kein Versehen: Wer sie für Text benutzt,
      // soll hier stolpern, wenn er die Werte anhebt.
      expect(kontrast(DunkleFlaeche.inaktiv, grund), lessThan(4.5));
      expect(kontrast(DunkleFlaeche.linie, grund), lessThan(4.5));
    });
  });

  group('helle und dunkle Oberfläche', () {
    test('Warnung und Erfolg schaffen 4,5:1 in beiden Helligkeiten', () {
      for (final theme in [buildLightTheme(), buildDarkTheme()]) {
        final semantik = theme.extension<AppSemantik>()!;
        final grund = theme.colorScheme.surface;
        for (final e in {
          'warnung': semantik.warnung,
          'erfolg': semantik.erfolg,
        }.entries) {
          final wert = kontrast(e.value, grund);
          expect(wert, greaterThanOrEqualTo(4.5),
              reason: '${e.key} auf ${theme.brightness.name} kommt nur auf '
                  '${wert.toStringAsFixed(2)}:1');
        }
      }
    });
  });
}
