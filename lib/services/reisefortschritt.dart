/// „41 von 252 Ländern" – der Zähler, der süchtig macht.
///
/// Andere Reisetagebücher lassen ihn von Hand füttern. Hier steht er
/// längst in der Datenbank: Jede verortete Aufnahme trägt Land, Region
/// und Ort aus der Umkehr-Geokodierung. Es fehlte nur die Auswertung.
///
/// Rein und ohne Datenbankklassen – am fertigen Balken sieht man nicht,
/// ob „Bayern" einmal oder zweimal gezählt wurde.
library;

/// Was eine Aufnahme über ihren Ort weiß, samt Anzahl.
typedef Besuchsangabe = ({String? land, String? region, String? ort, int anzahl});

/// Ein besuchtes Land mit der Zahl seiner Aufnahmen.
typedef Landeintrag = ({String name, int aufnahmen});

class Reisefortschritt {
  /// Besuchte Länder, häufigste zuerst.
  final List<Landeintrag> laender;

  /// Wie viele Länder und Gebiete der Datensatz überhaupt kennt.
  final int laenderGesamt;

  /// Verschiedene Regionen und Orte.
  final int regionen;
  final int orte;

  /// Gesamtzahl der verorteten Aufnahmen.
  final int aufnahmen;

  const Reisefortschritt({
    required this.laender,
    required this.laenderGesamt,
    required this.regionen,
    required this.orte,
    required this.aufnahmen,
  });

  int get laenderBesucht => laender.length;

  /// Anteil zwischen 0 und 1 – für den Balken.
  double get anteil =>
      laenderGesamt == 0 ? 0 : laenderBesucht / laenderGesamt;

  bool get istLeer => aufnahmen == 0;
}

/// Zählt zusammen.
///
/// **Regionen und Orte werden je Land gezählt.** „Bayern" gibt es einmal,
/// „Springfield" über zwanzigmal – ohne das Land davor wäre der Zähler
/// nicht die Zahl der besuchten Orte, sondern die Zahl der verschiedenen
/// Ortsnamen. Das ist nicht dasselbe und immer zu klein.
Reisefortschritt reisefortschritt(
  Iterable<Besuchsangabe> angaben, {
  required int laenderGesamt,
}) {
  final proLand = <String, int>{};
  final regionen = <String>{};
  final orte = <String>{};
  var summe = 0;

  for (final a in angaben) {
    summe += a.anzahl;
    final land = a.land;
    if (land == null || land.isEmpty) continue;
    proLand[land] = (proLand[land] ?? 0) + a.anzahl;
    final region = a.region;
    if (region != null && region.isNotEmpty) regionen.add('$land|$region');
    final ort = a.ort;
    if (ort != null && ort.isNotEmpty) orte.add('$land|$region|$ort');
  }

  final liste = [
    for (final e in proLand.entries) (name: e.key, aufnahmen: e.value),
  ]..sort((a, b) {
      final z = b.aufnahmen.compareTo(a.aufnahmen);
      return z != 0 ? z : a.name.compareTo(b.name);
    });

  return Reisefortschritt(
    laender: liste,
    laenderGesamt: laenderGesamt,
    regionen: regionen.length,
    orte: orte.length,
    aufnahmen: summe,
  );
}
