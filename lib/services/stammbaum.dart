/// Die Verwandtschaftslogik des Stammbaums – ohne Datenbank und ohne
/// Oberfläche.
///
/// Hier liegt der Teil, den man am fertigen Bild nicht beurteilen kann:
/// Ein Stammbaum sieht auch dann richtig aus, wenn eine Person versehentlich
/// ihre eigene Urgroßmutter ist – bis eine Auswertung im Kreis läuft. Als
/// Funktionen ist beides nachrechenbar.
library;

/// Wie zwei Personen zusammenhängen.
enum Verwandtschaft {
  /// Die andere Person ist ein Elternteil. Gerichtet: Die Gegenrichtung
  /// heißt „Kind" und steckt in derselben Kante.
  elternteil,

  /// Adoptivelternteil. Zählt überall als Elternteil – im Baum, im
  /// Fächer, bei der Kreisprüfung –, nur die Bezeichnung ist eine andere.
  ///
  /// Als eigene Kantenart und nicht als Merkmal an der Person: Wer wen
  /// adoptiert hat, ist eine Eigenschaft der Verbindung, nicht des
  /// Menschen. Dieselbe Person kann leiblicher Vater des einen und
  /// Adoptivvater des anderen Kindes sein.
  adoptivelternteil,

  /// Pflegeelternteil. Wie [adoptivelternteil], aber ohne die
  /// Rechtsfolge – für Familien, die das unterscheiden.
  pflegeelternteil,

  /// Partnerschaft. Ungerichtet, deshalb nur einmal je Paar gespeichert.
  partner,
}

/// Die drei Arten, auf die jemand Elternteil sein kann.
const elternArten = {
  Verwandtschaft.elternteil,
  Verwandtschaft.adoptivelternteil,
  Verwandtschaft.pflegeelternteil,
};

bool istElternArt(Verwandtschaft art) => elternArten.contains(art);

/// Der Datenbankwert einer [Verwandtschaft]. Ausgeschrieben statt über
/// `index`, damit eine spätere Ergänzung der Aufzählung nicht die
/// Bedeutung bereits gespeicherter Zeilen verschiebt.
String artZuText(Verwandtschaft art) => switch (art) {
      Verwandtschaft.elternteil => 'elternteil',
      Verwandtschaft.adoptivelternteil => 'adoptiv',
      Verwandtschaft.pflegeelternteil => 'pflege',
      Verwandtschaft.partner => 'partner',
    };

Verwandtschaft? artAusText(String text) => switch (text) {
      'elternteil' => Verwandtschaft.elternteil,
      'adoptiv' => Verwandtschaft.adoptivelternteil,
      'pflege' => Verwandtschaft.pflegeelternteil,
      'partner' => Verwandtschaft.partner,
      _ => null,
    };

/// Eine gespeicherte Kante, gelesen wie in [Verwandtschaft] beschrieben.
typedef Kante = ({String personId, String andereId, Verwandtschaft art});

Kante kante(String personId, String andereId, Verwandtschaft art) =>
    (personId: personId, andereId: andereId, art: art);

/// Bringt eine Partnerkante in ihre gespeicherte Form: die kleinere
/// Kennung zuerst.
///
/// Ohne diese Festlegung entstünden für dasselbe Paar je nach
/// Eingaberichtung zwei verschiedene Zeilen – und ein späteres Entfernen
/// träfe nur eine davon.
Kante partnerKanteFuer(String a, String b) =>
    a.compareTo(b) <= 0 ? kante(a, b, Verwandtschaft.partner) : kante(b, a, Verwandtschaft.partner);

/// Alle Kanten in nachschlagbarer Form.
class Verwandtschaftsnetz {
  /// personId -> Elternteile
  final Map<String, Set<String>> _eltern = {};

  /// personId -> Kinder
  final Map<String, Set<String>> _kinder = {};

  /// personId -> Partner
  final Map<String, Set<String>> _partner = {};

  /// personId -> (Elternteil -> auf welche Art)
  ///
  /// Getrennt von [_eltern], damit alle Auswertungen – Baum, Fächer,
  /// Kreisprüfung – Adoptiv- und Pflegeeltern ohne Sonderfall als Eltern
  /// behandeln und trotzdem nachschlagen können, wie die Verbindung
  /// zustande kam.
  final Map<String, Map<String, Verwandtschaft>> _elternArt = {};

  Verwandtschaftsnetz(Iterable<Kante> kanten) {
    for (final k in kanten) {
      ergaenze(k);
    }
  }

  /// Trägt eine weitere Kante nach.
  ///
  /// Für Abläufe, die Kante um Kante gegen den **fortgeschriebenen**
  /// Stand prüfen – das Einlesen einer GEDCOM-Datei etwa. Der Weg über
  /// einen neuen `Verwandtschaftsnetz([...alt, neu])` je Kante wäre
  /// quadratisch und bei dreitausend Personen spürbar.
  void ergaenze(Kante k) {
    switch (k.art) {
      case Verwandtschaft.elternteil:
      case Verwandtschaft.adoptivelternteil:
      case Verwandtschaft.pflegeelternteil:
        _eltern.putIfAbsent(k.personId, () => {}).add(k.andereId);
        _kinder.putIfAbsent(k.andereId, () => {}).add(k.personId);
        _elternArt.putIfAbsent(k.personId, () => {})[k.andereId] = k.art;
      case Verwandtschaft.partner:
        // In beide Richtungen eingetragen, obwohl nur eine Zeile
        // gespeichert ist: Beim Nachschlagen soll die Richtung keine
        // Rolle spielen.
        _partner.putIfAbsent(k.personId, () => {}).add(k.andereId);
        _partner.putIfAbsent(k.andereId, () => {}).add(k.personId);
    }
  }

  Set<String> eltern(String id) => _eltern[id] ?? const {};

  /// Auf welche Art [elternteil] Elternteil von [kind] ist.
  ///
  /// `null`, wenn zwischen den beiden gar keine Elternkante steht.
  Verwandtschaft? elternArt(String kind, String elternteil) =>
      _elternArt[kind]?[elternteil];
  Set<String> kinder(String id) => _kinder[id] ?? const {};
  Set<String> partner(String id) => _partner[id] ?? const {};

  /// Geschwister: alle weiteren Kinder der eigenen Eltern.
  ///
  /// Halbgeschwister zählen mit – ein gemeinsamer Elternteil genügt. Die
  /// Unterscheidung wäre eine eigene Angabe, die hier niemand gemacht hat.
  Set<String> geschwister(String id) {
    final ergebnis = <String>{};
    for (final e in eltern(id)) {
      ergebnis.addAll(kinder(e));
    }
    return ergebnis..remove(id);
  }

  /// Ob [moeglicherVorfahre] über Elternkanten von [id] aus erreichbar ist
  /// – die Person selbst zählt mit.
  ///
  /// Die Suche merkt sich Besuchtes. Das ist nicht nur Beschleunigung:
  /// Enthält der Bestand bereits einen Kreis (etwa aus einer früheren
  /// Fassung ohne diese Prüfung), liefe sie sonst nicht mehr zurück.
  bool istVorfahreVon(String moeglicherVorfahre, String id) {
    final gesehen = <String>{};
    final rand = <String>[id];
    while (rand.isNotEmpty) {
      final aktuell = rand.removeLast();
      if (aktuell == moeglicherVorfahre) return true;
      if (!gesehen.add(aktuell)) continue;
      rand.addAll(eltern(aktuell));
    }
    return false;
  }
}

/// Warum sich eine Verwandtschaft nicht eintragen lässt.
enum Beziehungsfehler {
  /// Eine Person kann nicht mit sich selbst verwandt sein.
  mitSichSelbst,

  /// Der neue Elternteil ist bereits ein Nachkomme – die Kante würde einen
  /// Kreis schließen, in dem jede Auswertung nach oben endlos liefe.
  kreis,

  /// Genau diese Verwandtschaft steht schon fest.
  schonVorhanden,
}

/// Prüft, ob sich [andereId] als [art] von [personId] eintragen lässt.
///
/// Gibt `null` zurück, wenn nichts dagegen spricht.
Beziehungsfehler? pruefeBeziehung(
  Verwandtschaftsnetz netz,
  String personId,
  String andereId,
  Verwandtschaft art,
) {
  if (personId == andereId) return Beziehungsfehler.mitSichSelbst;
  // Gegen ALLE Elternarten geprüft, nicht nur gegen die gerade gewählte:
  // Jemanden, der schon leiblicher Vater ist, zusätzlich als Adoptivvater
  // einzutragen, wäre eine zweite Kante zwischen denselben beiden – und
  // die Bezeichnung wäre dann nicht mehr entscheidbar.
  final schonDa = istElternArt(art)
      ? netz.eltern(personId).contains(andereId)
      : netz.partner(personId).contains(andereId);
  if (schonDa) return Beziehungsfehler.schonVorhanden;
  if (istElternArt(art) && netz.istVorfahreVon(personId, andereId)) {
    return Beziehungsfehler.kreis;
  }
  return null;
}

/// Der Ausschnitt des Stammbaums, der um eine Person herum gezeigt wird.
///
/// Bewusst nur die unmittelbare Verwandtschaft. Großeltern und Enkel
/// stehen nicht mit im Bild, weil sich für sie keine Verbindungslinie
/// zeichnen lässt, die stimmt: Welcher Großelternteil zu welchem Elternteil
/// gehört, ginge in einer gemeinsamen Reihe verloren. Sie sind einen Klick
/// entfernt – wer auf einen Elternteil tippt, rückt ihn in die Mitte.
/// [weitereOben] und [weitereUnten] sagen vorher, ob dort etwas wartet.
class Stammbaumausschnitt {
  final String fokus;
  final List<String> eltern;
  final List<String> geschwister;
  final List<String> partner;
  final List<String> kinder;

  /// Die Seitenäste – leer, solange sie nicht angefordert werden.
  ///
  /// Der Baum zeigte bisher genau fünf Rollen: Eltern, Geschwister,
  /// Fokus, Partner, Kinder. Wer wissen wollte, wo seine Tante steht,
  /// musste erst auf sie zurücken. Diese vier Mengen sind der Rest der
  /// engeren Verwandtschaft, den man auf einem Blatt noch unterbringt.
  final List<String> grosseltern;

  /// Die Geschwister der Eltern.
  final List<String> onkelTanten;

  /// Die Kinder der Geschwister.
  final List<String> neffenNichten;

  /// Die Eltern der Partner.
  final List<String> schwiegereltern;

  /// Je Person: ob sie ihrerseits Eltern bzw. Kinder hat, die hier nicht
  /// gezeigt werden.
  final Map<String, bool> weitereOben;
  final Map<String, bool> weitereUnten;

  const Stammbaumausschnitt({
    required this.fokus,
    required this.eltern,
    required this.geschwister,
    required this.partner,
    required this.kinder,
    required this.weitereOben,
    required this.weitereUnten,
    this.grosseltern = const [],
    this.onkelTanten = const [],
    this.neffenNichten = const [],
    this.schwiegereltern = const [],
  });

  /// „Leer" heißt weiterhin: um die Person herum steht niemand. Die
  /// Seitenäste zählen dabei nicht mit – sie können ohne Eltern gar nicht
  /// entstehen, und ein Ausschnitt, der nur aus Grosseltern bestünde,
  /// gibt es nicht.
  bool get istLeer =>
      eltern.isEmpty && geschwister.isEmpty && partner.isEmpty && kinder.isEmpty;
}

/// Stellt den Ausschnitt um [fokus] zusammen.
///
/// [reihenfolge] bestimmt, wie die Personen innerhalb einer Reihe stehen –
/// übergeben wird die nach Geburtsdatum und Name sortierte Liste aller
/// Kennungen. Ohne feste Reihenfolge sprängen die Karten bei jedem Aufbau
/// umher, weil die Mengen oben unsortiert sind.
///
/// [seitenlinien] nimmt Grosseltern, Onkel und Tanten, Neffen und Nichten
/// sowie Schwiegereltern dazu. Standardmäßig aus: Der schmale Ausschnitt
/// ist der, der auf jedem Fenster steht, und wer nur die gerade Linie
/// sucht, soll sie nicht zwischen Seitenästen suchen müssen.
Stammbaumausschnitt ausschnittUm(
  Verwandtschaftsnetz netz,
  String fokus,
  List<String> reihenfolge, {
  bool seitenlinien = false,
}) {
  final rang = {for (var i = 0; i < reihenfolge.length; i++) reihenfolge[i]: i};
  List<String> sortiert(Iterable<String> ids) =>
      ids.toList()..sort((a, b) => (rang[a] ?? 1 << 30).compareTo(rang[b] ?? 1 << 30));

  final eltern = sortiert(netz.eltern(fokus));
  final geschwister = sortiert(netz.geschwister(fokus));
  final partner = sortiert(netz.partner(fokus));
  final kinder = sortiert(netz.kinder(fokus));

  // Die Seitenäste. Jeder wird gegen die schon gezeigten Personen
  // abgezogen: In einer Familie, in der ein Cousin zugleich ein
  // Halbgeschwister ist, stünde dieselbe Karte sonst zweimal im Bild –
  // und zwei Karten für einen Menschen sind kein Baum, sondern ein
  // Fehler.
  final kern = {fokus, ...eltern, ...geschwister, ...partner, ...kinder};
  List<String> ohneKern(Iterable<String> ids, Set<String> schon) =>
      sortiert(ids.where((id) => !kern.contains(id) && !schon.contains(id)));

  var grosseltern = const <String>[];
  var onkelTanten = const <String>[];
  var neffenNichten = const <String>[];
  var schwiegereltern = const <String>[];
  if (seitenlinien) {
    final belegt = <String>{};
    grosseltern = ohneKern(
        [for (final e in eltern) ...netz.eltern(e)], belegt);
    belegt.addAll(grosseltern);
    onkelTanten =
        ohneKern([for (final e in eltern) ...netz.geschwister(e)], belegt);
    belegt.addAll(onkelTanten);
    schwiegereltern =
        ohneKern([for (final p in partner) ...netz.eltern(p)], belegt);
    belegt.addAll(schwiegereltern);
    neffenNichten =
        ohneKern([for (final g in geschwister) ...netz.kinder(g)], belegt);
  }

  // Ein Hinweis bedeutet: „von dieser Person geht es weiter, aber das
  // Weitere steht nicht in diesem Bild". Also genau dann, wenn nicht alle
  // Eltern bzw. Kinder unter den gezeigten Personen sind.
  //
  // Als eine Regel statt als Aufzählung von Sonderfällen. Der erste Versuch
  // setzte den Hinweis an Eltern, Fokus und Kindern von Hand ab – und
  // übersah dabei die Geschwister, deren Eltern ja mit im Bild stehen. Wer
  // dagegen fragt „ist alles Angrenzende zu sehen?", trifft auch die Fälle,
  // an die niemand gedacht hat: das Halbgeschwister mit einem zweiten,
  // nicht gezeigten Elternteil, oder den Partner mit Kindern aus einer
  // früheren Verbindung.
  final imBild = {
    ...kern,
    ...grosseltern,
    ...onkelTanten,
    ...neffenNichten,
    ...schwiegereltern,
  };
  final weitereOben = <String, bool>{};
  final weitereUnten = <String, bool>{};
  for (final id in imBild) {
    weitereOben[id] = !imBild.containsAll(netz.eltern(id));
    weitereUnten[id] = !imBild.containsAll(netz.kinder(id));
  }

  return Stammbaumausschnitt(
    fokus: fokus,
    eltern: eltern,
    geschwister: geschwister,
    partner: partner,
    kinder: kinder,
    grosseltern: grosseltern,
    onkelTanten: onkelTanten,
    neffenNichten: neffenNichten,
    schwiegereltern: schwiegereltern,
    weitereOben: weitereOben,
    weitereUnten: weitereUnten,
  );
}

/// Die Lebensspanne als Zeile unter dem Namen, etwa „1931–2004", „*1972"
/// oder „†2004".
///
/// Gibt `null` zurück, wenn nichts bekannt ist – dann bleibt die Zeile
/// weg, statt einen leeren Gedankenstrich zu zeigen.
String? lebensspanne(DateTime? geburt, DateTime? tod, {String geboren = '*', String gestorben = '†'}) {
  if (geburt == null && tod == null) return null;
  if (geburt != null && tod != null) return '${geburt.year}–${tod.year}';
  if (geburt != null) return '$geboren${geburt.year}';
  return '$gestorben${tod!.year}';
}
