import 'package:flutter/material.dart';

/// Zentrale Theme-Definition für Light/Dark Mode (siehe
/// [AppSettings.themeMode] in database.dart für die Persistenz, main.dart
/// für die Umschaltung). Beide Helligkeiten teilen sich denselben Seed
/// (Teal), damit der Markencharakter erhalten bleibt und nicht zwei
/// unabhängig gepflegte Paletten auseinanderlaufen können.
///
/// `.AppleSystemUIFont` löst macOS intern auf San Francisco auf – kein
/// Font-Bundling nötig (reines System-Font-Referencing, keine Lizenzfrage),
/// sorgt aber für ein deutlich natives Schriftbild statt Flutters
/// Material-3-Standard (Roboto-Fallback).
const _fontFamily = '.AppleSystemUIFont';

ThemeData buildLightTheme() => ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.teal,
      brightness: Brightness.light,
      fontFamily: _fontFamily,
    );

ThemeData buildDarkTheme() => ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.teal,
      brightness: Brightness.dark,
      fontFamily: _fontFamily,
    );

/// Wandelt den in [AppSettings.themeMode] gespeicherten String
/// ('system'|'light'|'dark') in ein [ThemeMode] um – unbekannte/fehlende
/// Werte (z.B. noch keine Zeile in der DB) fallen auf System zurück.
ThemeMode themeModeFromString(String? value) {
  switch (value) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}

String themeModeToString(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return 'light';
    case ThemeMode.dark:
      return 'dark';
    case ThemeMode.system:
      return 'system';
  }
}
