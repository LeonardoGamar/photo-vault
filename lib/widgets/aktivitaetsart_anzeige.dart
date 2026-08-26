/// Wie eine Aktivitätsart aussieht und heisst.
///
/// An einer Stelle, damit Liste, Vorschlag, Kapitel und Detailansicht
/// nicht auseinanderlaufen: Ein Symbol, das in der Liste ein Fahrrad und
/// im Kapitel ein Auto ist, macht aus einer Ordnung ein Rätsel.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../services/aktivitaeten.dart';

IconData symbolFuerArt(Aktivitaetsart art) => switch (art) {
      Aktivitaetsart.wanderung => Icons.hiking,
      Aktivitaetsart.radtour => Icons.directions_bike,
      Aktivitaetsart.ausflug => Icons.directions_car_outlined,
      Aktivitaetsart.besichtigung => Icons.museum_outlined,
      Aktivitaetsart.bootsfahrt => Icons.directions_boat_outlined,
      Aktivitaetsart.sonstiges => Icons.explore_outlined,
    };

String nameFuerArt(AppTexte t, Aktivitaetsart art) => switch (art) {
      Aktivitaetsart.wanderung => t.aktArtWanderung,
      Aktivitaetsart.radtour => t.aktArtRadtour,
      Aktivitaetsart.ausflug => t.aktArtAusflug,
      Aktivitaetsart.besichtigung => t.aktArtBesichtigung,
      Aktivitaetsart.bootsfahrt => t.aktArtBootsfahrt,
      Aktivitaetsart.sonstiges => t.aktArtSonstiges,
    };

/// Eine Dauer, wie man sie sagt: „3 h 20 min", unter einer Stunde nur
/// die Minuten.
String dauertext(AppTexte t, Duration d) {
  final minuten = d.inMinutes;
  if (minuten < 60) return t.aktivitaetenDauerKurz(minuten);
  return t.aktivitaetenDauer(minuten ~/ 60, minuten % 60);
}

/// Eine Strecke mit einer Nachkommastelle – „12,4 km".
///
/// Eine Stelle und nicht drei: Die Zahl entsteht aus Luftlinien zwischen
/// Fotos. Sie auf Meter genau zu drucken wäre eine Genauigkeit, die
/// nirgends herkommt.
///
/// Über [NumberFormat] und nicht über `toStringAsFixed`: Das Komma
/// gehört zur Sprache, und „12.4 km" liest sich auf Deutsch falsch.
String streckentext(AppTexte t, Locale locale, double km) =>
    t.aktivitaetenStrecke(NumberFormat.decimalPatternDigits(
      locale: locale.toString(),
      decimalDigits: 1,
    ).format(km));
