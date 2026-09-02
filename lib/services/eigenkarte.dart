import 'dart:convert';

import 'package:http/http.dart';

/// Eine selbst eingetragene Kartenquelle.
///
/// **Warum es sie gibt.** Die drei mitgelieferten Stile hängen an frei
/// betriebenen Servern, und die hören früh auf: OpenStreetMap liefert
/// echte Kacheln bis Zoomstufe 19, OpenTopoMap bis 17. Wer
/// Gebäudeumrisse, Hausnummern oder ein Luftbild braucht, kommt an
/// einem Anbieter mit Schlüssel nicht vorbei.
///
/// **Warum eine Adressvorlage und keine Anbieterliste im Programm.**
/// Jeder Anbieter hängt seinen Schlüssel woanders hin – Mapbox als
/// `?access_token=`, MapTiler als `?key=`, Thunderforest als
/// `?apikey=`, Google als `?session=…&key=`. Eine Liste fest eingebauter
/// Anbieter wäre bei jedem weiteren wieder falsch. Die Vorlagen aus
/// [kartenvorlagen] füllen deshalb nur das Feld vor; was am Ende
/// abgerufen wird, steht vollständig in [url].
class Eigenkarte {
  const Eigenkarte({
    required this.name,
    required this.url,
    required this.nennung,
    this.stufe,
    this.zugestimmt = false,
  });

  /// Anzeigename im Kartenmenü.
  final String name;

  /// Adressvorlage mit `{z}`, `{x}`, `{y}` – Schlüssel inbegriffen.
  final String url;

  /// Namensnennung. **Pflichtfeld**, und zwar nicht aus Ordnungsliebe:
  /// Praktisch jeder Anbieter verlangt sie in seinen Nutzungsregeln.
  final String nennung;

  /// Höchste Stufe mit echten Kacheln. Ohne Angabe gilt 19.
  final int? stufe;

  /// Ob der Hinweis zu Datenübermittlung und Offline-Nutzung bestätigt
  /// wurde.
  final bool zugestimmt;

  int get hoechsteEchteStufe => stufe ?? 19;

  /// Baut eine Quelle aus den Spalten der Einstellungen – oder `null`,
  /// wenn etwas Wesentliches fehlt.
  ///
  /// Alles oder nichts: Eine halb ausgefüllte Quelle wäre schlimmer als
  /// keine. Ohne Adresse bliebe die Karte leer, ohne Namensnennung wäre
  /// die Lizenzauflage verletzt, und ohne Zustimmung hätte niemand
  /// gelesen, wohin die Abrufe gehen.
  static Eigenkarte? aus({
    String? name,
    String? url,
    String? nennung,
    int? stufe,
    bool zugestimmt = false,
  }) {
    final a = url?.trim() ?? '';
    final n = nennung?.trim() ?? '';
    if (a.isEmpty || n.isEmpty || !zugestimmt) return null;
    if (adressfehler(a) != null) return null;
    final b = name?.trim() ?? '';
    return Eigenkarte(
      name: b.isEmpty ? 'Eigene Karte' : b,
      url: a,
      nennung: n,
      stufe: stufe,
      zugestimmt: true,
    );
  }

  /// Platzhalter, die flutter_map in einer Adressvorlage kennt.
  ///
  /// `nachfassen` steht mit dabei, weil die Kachelschicht ihn als
  /// Zusatzangabe mitgibt (siehe `Kachelschicht`); die übrigen sind die
  /// der Bibliothek.
  static const bekanntePlatzhalter = {'z', 'x', 'y', 's', 'r', 'd', 'nachfassen'};

  /// Was an einer Adressvorlage nicht stimmt – oder `null`, wenn sie
  /// taugt. Die Kennung passt zu den Texten in der Oberfläche.
  ///
  /// **Der wichtigste Fall ist der unbekannte Platzhalter**, und er ist
  /// nicht offensichtlich: flutter_map ersetzt `{…}` über eine feste
  /// Tabelle und **wirft** bei allem, was nicht darin steht
  /// (`ArgumentError: Missing value for placeholder`). Ein
  /// stehengebliebenes `{SCHLUESSEL}` aus einer Vorlage brächte also
  /// nicht etwa eine leere Karte, sondern einen Fehler bei jeder
  /// einzelnen Kachel.
  static Adressfehler? adressfehler(String vorlage) {
    final a = vorlage.trim();
    if (a.isEmpty) return Adressfehler.leer;
    if (!a.startsWith('http://') && !a.startsWith('https://')) {
      return Adressfehler.keinHttp;
    }
    for (final teil in ['{z}', '{x}', '{y}']) {
      if (!a.contains(teil)) return Adressfehler.platzhalterFehlt;
    }
    for (final treffer in RegExp('{([^{}]*)}').allMatches(a)) {
      if (!bekanntePlatzhalter.contains(treffer.group(1))) {
        return Adressfehler.platzhalterUnbekannt;
      }
    }
    // Die Marke aus einer Vorlage, die niemand ersetzt hat. Sie steht
    // bewusst OHNE geschweifte Klammern da (siehe [schluesselMarke]) und
    // rutscht deshalb durch die Platzhalterpruefung – der Anbieter
    // antwortete dann mit einem Rechtefehler, und am Bildschirm saehe es
    // aus wie eine kaputte Karte.
    if (a.contains(schluesselMarke)) return Adressfehler.schluesselFehlt;
    return null;
  }
}

/// Woran eine Adressvorlage scheitert.
enum Adressfehler {
  leer,
  keinHttp,
  platzhalterFehlt,
  platzhalterUnbekannt,
  schluesselFehlt,
}

/// Was in eine Vorlage anstelle des Schlüssels eingesetzt wird.
///
/// Kein `{SCHLUESSEL}` in geschweiften Klammern: Bliebe es stehen, hielte
/// flutter_map es für einen Platzhalter und würfe bei jeder Kachel (siehe
/// [Eigenkarte.adressfehler]). In Grossbuchstaben ohne Klammern fällt es
/// im Textfeld genauso auf, richtet aber keinen Schaden an.
const schluesselMarke = 'DEIN_SCHLUESSEL';

/// Eine ausfüllbare Vorlage für die eigene Kartenquelle.
class Kartenvorlage {
  const Kartenvorlage({
    required this.name,
    required this.url,
    required this.nennung,
    required this.stufe,
    this.brauchtSchluessel = false,
    this.sitzungNoetig = false,
    this.gemessen = false,
    this.woher,
  });

  final String name;
  final String url;
  final String nennung;

  /// Höchste Stufe mit echten Kacheln.
  final int stufe;

  final bool brauchtSchluessel;

  /// Ob vor dem ersten Abruf eine Sitzung geholt werden muss – bislang
  /// nur bei Google (siehe [googleSitzung]).
  final bool sitzungNoetig;

  /// Ob [stufe] an echten Abrufen nachgemessen wurde oder aus der
  /// Anbieterdokumentation stammt.
  ///
  /// **Der Unterschied ist bezahlt worden.** OpenTopoMap antwortet
  /// oberhalb seiner Datenlage nicht mit 404, sondern mit HTTP 200 und
  /// einer einfarbigen Kachel – die Karte wäre leer, ohne Fehler, ohne
  /// Anhaltspunkt. Esri macht dasselbe: Ab Stufe 21 kommt überall
  /// dieselbe 2.521 Byte grosse Ersatzkachel mit 123 Farben.
  final bool gemessen;

  /// Wo es den Schlüssel gibt.
  final String? woher;
}

/// Die mitgelieferten Vorlagen.
///
/// **Die Stufenangaben der ersten vier sind nachgemessen**, an echten
/// Abrufen über Hannover, Stufe 17 bis 22 – Statuscode, Bytezahl und
/// Farbanzahl der gelieferten Kachel:
///
/// ```
/// Esri Weltbild       z20 200  8.647 B  6.785 Farben   z21 200 2.521 B 123 Farben
/// Esri Strassenkarte  z19 200  8.329 B  3.794 Farben   z20 200 2.521 B 123 Farben
/// OSM Deutschland     z20 200  9.941 B    255 Farben   z21 404
/// CyclOSM             z20 200 11.276 B                 z21 422
/// ```
///
/// Die 2.521 Byte mit 123 Farben sind bei Esri auf jeder zu hohen Stufe
/// dieselbe Ersatzkachel – ein Fall wie bei OpenTopoMap: HTTP 200, und
/// trotzdem keine Karte.
///
/// **Die Stufen der Anbieter mit Schlüssel stehen ungemessen da**, weil
/// sich ohne Schlüssel nichts abrufen lässt. Sie stammen aus deren
/// Dokumentation und sind im Feld änderbar; [Kartenvorlage.gemessen]
/// sagt, welche welche sind.
const kartenvorlagen = <Kartenvorlage>[
  Kartenvorlage(
    name: 'Esri Weltbild (Luftbild)',
    url: 'https://server.arcgisonline.com/ArcGIS/rest/services/'
        'World_Imagery/MapServer/tile/{z}/{y}/{x}',
    nennung: '© Esri, Maxar, Earthstar Geographics',
    stufe: 20,
    gemessen: true,
  ),
  Kartenvorlage(
    name: 'Esri Strassenkarte',
    url: 'https://server.arcgisonline.com/ArcGIS/rest/services/'
        'World_Street_Map/MapServer/tile/{z}/{y}/{x}',
    nennung: '© Esri, HERE, Garmin, © OpenStreetMap contributors',
    stufe: 19,
    gemessen: true,
  ),
  Kartenvorlage(
    name: 'OpenStreetMap Deutschland',
    url: 'https://tile.openstreetmap.de/{z}/{x}/{y}.png',
    nennung: '© OpenStreetMap contributors',
    stufe: 20,
    gemessen: true,
  ),
  Kartenvorlage(
    name: 'CyclOSM (Radwege)',
    url: 'https://a.tile-cyclosm.openstreetmap.fr/cyclosm/{z}/{x}/{y}.png',
    nennung: '© OpenStreetMap contributors, CyclOSM',
    stufe: 20,
    gemessen: true,
  ),
  Kartenvorlage(
    name: 'Mapbox Streets',
    url: 'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/256/'
        '{z}/{x}/{y}?access_token=$schluesselMarke',
    nennung: '© Mapbox © OpenStreetMap contributors',
    stufe: 22,
    brauchtSchluessel: true,
    woher: 'account.mapbox.com',
  ),
  Kartenvorlage(
    name: 'MapTiler Streets',
    url: 'https://api.maptiler.com/maps/streets-v2/256/{z}/{x}/{y}.png'
        '?key=$schluesselMarke',
    nennung: '© MapTiler © OpenStreetMap contributors',
    stufe: 20,
    brauchtSchluessel: true,
    woher: 'cloud.maptiler.com',
  ),
  Kartenvorlage(
    name: 'Thunderforest Outdoors',
    url: 'https://tile.thunderforest.com/outdoors/{z}/{x}/{y}.png'
        '?apikey=$schluesselMarke',
    nennung: '© Thunderforest, © OpenStreetMap contributors',
    stufe: 22,
    brauchtSchluessel: true,
    woher: 'thunderforest.com/pricing',
  ),
  Kartenvorlage(
    name: 'Google Karten',
    url: 'https://tile.googleapis.com/v1/2dtiles/{z}/{x}/{y}'
        '?session=SITZUNG&key=$schluesselMarke',
    nennung: '© Google',
    stufe: 22,
    brauchtSchluessel: true,
    sitzungNoetig: true,
    woher: 'console.cloud.google.com – Map Tiles API',
  ),
];

/// Die Adresse einer Vorlage mit eingesetztem Schlüssel.
String vorlageMitSchluessel(Kartenvorlage v, String schluessel) =>
    v.url.replaceAll(schluesselMarke, schluessel.trim());

/// Der Parameter, unter dem Google seine Sitzungskennung erwartet.
const sitzungsparameter = 'session=';

/// Ob diese Adresse eine Google-Sitzung braucht.
bool brauchtSitzung(String adresse) => adresse.contains(sitzungsparameter);

/// Liest den Schlüssel aus `key=…` einer Adresse.
///
/// **Aus der Adresse und nicht aus einem eigenen Feld**: Der Schlüssel
/// steht dort ohnehin (siehe [Eigenkarte.url]), und ein zweites Feld
/// könnte mit ihr auseinanderlaufen. `null`, solange dort noch die
/// [schluesselMarke] aus der Vorlage steht.
String? schluesselAusAdresse(String adresse) {
  final treffer = RegExp('[?&]key=([^&]*)').firstMatch(adresse);
  final wert = treffer?.group(1);
  if (wert == null || wert.isEmpty || wert == schluesselMarke) return null;
  return Uri.decodeQueryComponent(wert);
}

/// Setzt eine geholte Sitzung in die Adresse ein.
String sitzungEinsetzen(String adresse, String sitzung) => adresse.replaceAll(
    RegExp('$sitzungsparameter[^&]*'), '$sitzungsparameter$sitzung');

/// Ergebnis von [googleSitzung].
typedef Sitzungsantwort = ({String? sitzung, String? fehler});

/// Holt bei Google eine Kachelsitzung.
///
/// **Warum Google als einziger Anbieter zwei Schritte braucht.** Seine
/// Kacheln kommen nicht über eine blosse Adresse: Erst wird per
/// `createSession` eine Sitzungskennung erzeugt, und die steht danach in
/// jeder Kachel-Adresse. Sie hält laut Google rund zwei Wochen; danach
/// muss sie erneuert werden.
///
/// **Warum das ein Knopf ist und keine Selbstverwaltung im Hintergrund.**
/// Ein Kachelweg, der sich selbst neue Sitzungen besorgt, müsste
/// Ablauf erkennen, erneuern, nebenläufige Abrufe anhalten und Fehler
/// unterscheiden – und liesse sich hier ohne abrechnungsfähigen
/// Google-Schlüssel an keiner Stelle erproben. Ein Knopf, der die
/// Adresse einmal fertig ins Feld schreibt, hält den Kachelweg dagegen
/// für alle Anbieter gleich: eine Adresse, sonst nichts.
///
/// Ohne Schlüssel antwortet der Dienst nachweislich klar – nachgesehen:
///
/// ```
/// HTTP 403  "Method doesn't allow unregistered callers ..."
/// ```
Future<Sitzungsantwort> googleSitzung(
  String schluessel, {
  Client? netz,
  String sprache = 'de-DE',
  String region = 'DE',
  String kartenart = 'roadmap',
}) async {
  final client = netz ?? Client();
  try {
    final antwort = await client.post(
      Uri.parse('https://tile.googleapis.com/v1/createSession'
          '?key=${Uri.encodeQueryComponent(schluessel.trim())}'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mapType': kartenart,
        'language': sprache,
        'region': region,
      }),
    );
    final inhalt = jsonDecode(antwort.body);
    if (antwort.statusCode == 200 &&
        inhalt is Map &&
        inhalt['session'] is String) {
      return (sitzung: inhalt['session'] as String, fehler: null);
    }
    final meldung = inhalt is Map && inhalt['error'] is Map
        ? '${(inhalt['error'] as Map)['message']}'
        : 'HTTP ${antwort.statusCode}';
    return (sitzung: null, fehler: meldung);
  } catch (fehler) {
    return (sitzung: null, fehler: '$fehler');
  } finally {
    if (netz == null) client.close();
  }
}
