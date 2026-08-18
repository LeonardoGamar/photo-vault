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

/// Farben für Warnung und Erfolg.
///
/// Sie fehlen im Material-Farbschema, das nur `error` kennt – und genau
/// deshalb standen vorher überall `Colors.orange` und `Colors.green` im
/// Quelltext. Die sind für den dunklen Modus gemacht: Gegen die helle
/// Oberfläche dieser App gemessen kommt `Colors.orange` auf 2,05:1 und
/// `Colors.green` auf 2,65:1, wo die Zugänglichkeitsrichtlinie 4,5:1
/// verlangt. Die Werte hier sind je Helligkeit eigens gewählt.
class AppSemantik extends ThemeExtension<AppSemantik> {
  /// Für Hinweise, die etwas verhindern oder einschränken – fehlendes
  /// Modell, gesperrte Passphrase, unvollständige Bedingung.
  final Color warnung;

  /// Für gelungene Abschlüsse.
  final Color erfolg;

  const AppSemantik({required this.warnung, required this.erfolg});

  static const _hell = AppSemantik(
    warnung: Color(0xFF8A5000), // 5,9:1 auf heller Oberfläche
    erfolg: Color(0xFF1B5E20), // 8,3:1
  );

  static const _dunkel = AppSemantik(
    warnung: Color(0xFFFFB74D),
    erfolg: Color(0xFF81C784),
  );

  @override
  AppSemantik copyWith({Color? warnung, Color? erfolg}) => AppSemantik(
        warnung: warnung ?? this.warnung,
        erfolg: erfolg ?? this.erfolg,
      );

  @override
  AppSemantik lerp(covariant AppSemantik? other, double t) => other == null
      ? this
      : AppSemantik(
          warnung: Color.lerp(warnung, other.warnung, t)!,
          erfolg: Color.lerp(erfolg, other.erfolg, t)!,
        );
}

/// Farben für die dauerhaft dunklen Arbeitsflächen – Entwickeln, Betrachter,
/// Histogramm, Kurve, Farbmischer.
///
/// Diese Bildschirme richten sich bewusst NICHT nach Hell/Dunkel: Ein Foto
/// beurteilt man vor neutralem Schwarz, sonst färbt die Oberfläche das
/// Urteil. Deshalb stehen die Werte hier fest und nicht in [AppSemantik].
///
/// Die Zahlen daneben sind gemessen (WCAG-Kontrastformel gegen [grund]),
/// nicht geschätzt. Der Anlass: `Colors.white38` stand an sechs Stellen
/// unter erklärendem Text in 11 px – bei 3,44:1, wo 4,5:1 gefordert sind.
/// Als benannte Rolle ist schwerer zu übersehen, welcher Wert wofür gedacht
/// ist.
abstract final class DunkleFlaeche {
  /// Der Grund, gegen den alles andere gemessen ist.
  static const grund = Colors.black;

  /// Beschriftungen und Werte, die man lesen muss. 21:1.
  static const text = Colors.white;

  /// Zweitrangiges, das noch gut lesbar bleibt. 10,0:1.
  static const zweitText = Colors.white70;

  /// Erklärende Hinweise unter Bedienelementen. 6,1:1 – der Material-übliche
  /// Wert für sekundären Text auf dunklem Grund.
  static const hinweis = Colors.white54;

  /// NUR für abgeschaltete Bedienelemente. 3,4:1 – zu wenig für Text, den
  /// jemand lesen soll, aber richtig für etwas, das gerade nicht gilt (die
  /// Zugänglichkeitsrichtlinie nimmt inaktive Elemente ausdrücklich aus).
  static const inaktiv = Colors.white38;

  /// Trennlinien und Rahmen. Kein Text.
  static const linie = Colors.white24;
}

/// Kurzer Weg zu [AppSemantik] – `Theme.of(context).extension<…>()!` an
/// jeder Aufrufstelle wäre nur Lärm.
extension AppSemantikZugriff on BuildContext {
  AppSemantik get semantik => Theme.of(this).extension<AppSemantik>()!;
}

ThemeData buildLightTheme() => ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.teal,
      brightness: Brightness.light,
      fontFamily: _fontFamily,
      extensions: const [AppSemantik._hell],
    );

ThemeData buildDarkTheme() => ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.teal,
      brightness: Brightness.dark,
      fontFamily: _fontFamily,
      extensions: const [AppSemantik._dunkel],
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

/// Wandelt den in [AppSettings.sprache] gespeicherten String
/// ('system'|'de'|'en') in eine [Locale] um.
///
/// `null` als Rückgabe ist kein Fehlerfall, sondern die Antwort auf
/// „Systemsprache": Flutter wählt dann selbst aus [supportedLocales] die
/// passende aus. Es braucht dafür also keinen Sonderfall im Aufrufer.
///
/// Unbekannte Angaben – etwa aus einer neueren Fassung, die schon mehr
/// Sprachen kennt – gelten ebenfalls als Systemsprache, statt den Start
/// zu verhindern.
Locale? localeFromString(String? value) {
  switch (value) {
    case 'de':
      return const Locale('de');
    case 'en':
      return const Locale('en');
    default:
      return null;
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
