import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:http/retry.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../services/eigenkarte.dart';
import '../services/kachelmitschnitt.dart';
import '../theme/app_spacing.dart';
import 'wisch_zoom.dart';

/// Der eigene CARTO-Schlüssel, oder null.
///
/// Modulweit und nicht als Parameter durchgereicht, aus demselben Grund
/// wie beim Kachelspeicher: [buildMapTileLayer] wird an sechs Stellen
/// ohne jeden Zustand aufgerufen. Ein zusätzlicher Parameter müsste
/// durch jeden dieser Bildschirme wandern, obwohl es um eine einzige,
/// app-weite Angabe geht.
String? _cartoSchluessel;

/// Der gerade geltende CARTO-Schlüssel, oder null.
String? get cartoSchluessel => _cartoSchluessel;

/// Setzt den CARTO-Schlüssel für alle Karten dieser App.
///
/// Leer und null sind dasselbe: kein Schlüssel. Das ist wichtiger, als
/// es aussieht – eine leere Zeichenkette ergäbe die Adresse `…?key=`,
/// und darauf antwortet CARTO mit derselben gestempelten Kachel wie
/// ganz ohne Schlüssel.
void setzeCartoSchluessel(String? schluessel) {
  final wert = schluessel?.trim();
  _cartoSchluessel = wert == null || wert.isEmpty ? null : wert;
}

/// Die eingerichtete eigene Kartenquelle, oder null.
Eigenkarte? _eigeneKarte;

/// Die gerade geltende eigene Kartenquelle, oder null.
Eigenkarte? get eigeneKarte => _eigeneKarte;

/// Setzt die eigene Kartenquelle für alle Karten dieser App.
///
/// Modulweit aus demselben Grund wie beim CARTO-Schlüssel: Es ist eine
/// app-weite Angabe, und [buildMapTileLayer] wird an sechs Stellen ohne
/// jeden Zustand aufgerufen.
void setzeEigeneKarte(Eigenkarte? karte) => _eigeneKarte = karte;

/// Die verfügbaren Kartenstile.
///
/// Ein Aufzählungstyp und kein `bool dark` mehr: Ein dritter Stil passt
/// nicht in einen Wahrheitswert, und „hell oder eben nicht hell" hätte
/// bei jeder weiteren Ergänzung erneut umgebaut werden müssen.
enum Kartenstil {
  /// OpenStreetMap-Standard statt Google Maps: quelloffen, kein
  /// API-Schlüssel nötig – passt zur restlichen App (keine proprietären
  /// Cloud-Dienste ausser den einmaligen KI-Modell-Downloads, siehe
  /// README).
  hell(
    kachelUrl: _osmKacheln,
    namensnennung: _osmNennung,
    // Ausdrücklich, nicht über die Vorgabe: Ab Stufe 20 antwortet der
    // Server mit 400, nachgemessen.
    hoechsteEchteStufe: 19,
  ),

  /// Die dunkle Karte – **mit zwei Gesichtern**, je nachdem, ob ein
  /// CARTO-Schlüssel hinterlegt ist.
  ///
  /// Bis August 2026 lag hier CARTO Dark Matter, kostenlos und ohne
  /// Schlüssel. Das ist vorbei: CARTO schreibt seither quer über jede
  /// ausgelieferte Kachel „API KEY REQUIRED / carto.com/basemaps/apikey".
  /// An einer Kachel Berlin-Mitte nachgesehen, und zwar auf jeder Stufe:
  ///
  /// ```
  /// z10  z14  z16  z18  z20   -> Stempel auf allen
  /// cartodb-basemaps-a.global.ssl.fastly.net (alter Name) -> ebenso
  /// ```
  ///
  /// Beim Herauszoomen deckt eine Kachel den halben Schirm und der
  /// Schriftzug steht einmal im Bild; beim Hereinzoomen kacheln sich die
  /// Stempel. Deshalb fällt es erst dort auf – der Fehler war aber immer
  /// da.
  ///
  /// **Ohne Schlüssel** zeichnet dieser Stil deshalb dieselben
  /// OSM-Kacheln wie [hell], invertiert und im Farbton um 180° gedreht
  /// (siehe [invertieren]). Kein zweiter Anbieter, keine Anmeldung, und
  /// die Karte ist sofort dunkel. Grün bleibt grün, Wasser wird
  /// dunkelblau, Beschriftung hell – nachgesehen, bevor das hier stand.
  ///
  /// **Mit Schlüssel** kommt Dark Matter zurück, samt Stufe 20. CARTO
  /// gibt Schlüssel kostenlos und ohne Konto aus (5 Millionen Kacheln im
  /// Monat). Dass die Rasterkacheln laut CARTO „being retired" sind, ist
  /// der zweite Grund, warum der schlüssellose Weg die Vorgabe ist und
  /// nicht der Notnagel: Fällt CARTO eines Tages ganz weg, ändert sich
  /// für alle, die keinen Schlüssel eingetragen haben, gar nichts.
  dunkel(
    kachelUrl: _osmKacheln,
    namensnennung: _osmNennung,
    hoechsteEchteStufe: 19,
  ),

  /// OpenTopoMap: Höhenlinien und Schummerung. Das Relief steckt in den
  /// Kacheln, nicht in einer 3D-Maschine – deshalb ist es hier ohne neue
  /// Abhängigkeit und auf allen drei Plattformen zu haben.
  ///
  /// **Nur bis Zoomstufe 17**, und das ist wichtiger als es klingt:
  /// Oberhalb davon antwortet der Server nicht etwa mit 404, sondern
  /// mit **HTTP 200 und einer einfarbigen Kachel**. An der Zugspitze
  /// nachgemessen:
  ///
  /// ```
  /// Zoom 16  200  53031 B  256 Farben
  /// Zoom 17  200  51161 B  255 Farben
  /// Zoom 18  200   4343 B    1 Farbe
  /// Zoom 19  200   4343 B    1 Farbe
  /// ```
  ///
  /// Ohne [hoechsteEchteStufe] wäre die Karte beim Hereinzoomen also
  /// schlicht leer – ohne Fehler, ohne Meldung, ohne Anhaltspunkt. Mit
  /// der Angabe vergrössert flutter_map die Kachel von Stufe 17.
  topo(
    kachelUrl: 'https://tile.opentopomap.org/{z}/{x}/{y}.png',
    namensnennung: '© OpenStreetMap contributors, SRTM | © opentopomap.org (CC-BY-SA)',
    hoechsteEchteStufe: 17,
  ),

  /// Die selbst eingetragene Quelle – Adresse, Namensnennung und
  /// Zoomgrenze kommen aus den Einstellungen (siehe [Eigenkarte]).
  ///
  /// **Der einzige Stil ohne feste Adresse**, und deshalb der einzige,
  /// der `null` liefern kann: Ist keine Quelle eingerichtet, taucht er
  /// im Kartenmenü gar nicht erst auf (siehe `Kartenansicht`). Die
  /// Ausweichwerte hier sind nur da, damit ein versehentlicher Aufruf
  /// nicht wirft – die Karte fiele dann auf OpenStreetMap zurück, was
  /// sichtbar falsch ist und nichts kaputt macht.
  eigene(
    kachelUrl: _osmKacheln,
    namensnennung: _osmNennung,
    hoechsteEchteStufe: 19,
  );

  const Kartenstil({
    required String kachelUrl,
    required String namensnennung,
    List<String> unterbereiche = const <String>[],
    int? hoechsteEchteStufe,
  })  : _kachelUrl = kachelUrl,
        _namensnennung = namensnennung,
        _unterbereiche = unterbereiche,
        _hoechsteEchteStufe = hoechsteEchteStufe;

  final String _kachelUrl;
  final String _namensnennung;
  final List<String> _unterbereiche;
  final int? _hoechsteEchteStufe;

  /// Ob dieser Stil gerade auf CARTO zeigt – also nur die dunkle Karte,
  /// und nur mit hinterlegtem Schlüssel.
  bool get _ueberCarto => this == dunkel && _cartoSchluessel != null;

  /// Die Adresse der Kacheln.
  ///
  /// Der Fragezeichen-Teil steckt mit in [_cartoKacheln] und nicht hier:
  /// Ein Literal `'?key='` an dieser Stelle sähe für
  /// `keine_festen_texte_test.dart` wie ein vergessener
  /// Oberflächentext aus – „key" sind drei Buchstaben am Stück. Als Teil
  /// einer Adresse, die mit `https` beginnt, ist es eindeutig keiner.
  String get kachelUrl {
    if (this == eigene && _eigeneKarte != null) return _eigeneKarte!.url;
    return _ueberCarto ? '$_cartoKacheln$_cartoSchluessel' : _kachelUrl;
  }

  /// Die Namensnennung – eine Lizenzauflage, und sie muss zu den
  /// Kacheln passen, die tatsächlich im Bild stehen. CARTO verlangt sie
  /// ausdrücklich auch bei Nutzung mit Schlüssel.
  String get namensnennung {
    if (this == eigene && _eigeneKarte != null) return _eigeneKarte!.nennung;
    return _ueberCarto ? _cartoNennung : _namensnennung;
  }

  List<String> get unterbereiche =>
      _ueberCarto ? _cartoUnterbereiche : _unterbereiche;

  /// Ob die Kacheln beim Zeichnen invertiert werden müssen.
  ///
  /// Nur für die dunkle Karte ohne Schlüssel: Dort liegen helle
  /// OSM-Kacheln an, die erst durch die Farbmatrix dunkel werden.
  bool get invertieren => this == dunkel && _cartoSchluessel == null;

  /// Höchste Stufe, für die der Anbieter echte Kacheln liefert. `null`
  /// heisst „so weit wie die Karte zoomt".
  int? get hoechsteEchteStufe {
    if (this == eigene && _eigeneKarte != null) {
      return _eigeneKarte!.hoechsteEchteStufe;
    }
    return _ueberCarto ? 20 : _hoechsteEchteStufe;
  }

  /// Bis hierhin darf die Karte zoomen.
  ///
  /// **Ohne diese Grenze zoomt die Karte ins Nichts.** Oberhalb der
  /// echten Stufe vergrössert flutter_map die letzte vorhandene Kachel
  /// weiter und weiter: auf Anzeigestufe 24 deckt eine einzige
  /// Topo-Kachel 32.768 Punkte ab, auf Stufe 28 über eine halbe Million.
  /// So etwas kann keine Grafikeinheit mehr zeichnen – und am Bildschirm
  /// sieht es aus, als würden die Kacheln „nicht mehr laden".
  ///
  /// Zwei Stufen darüber sind bewusst erlaubt statt hart bei der echten
  /// Stufe abzuschneiden: Die Kachel wird dabei vierfach vergrössert,
  /// also unschärfer, aber sie ist **da**. Ein hartes Ende fühlte sich
  /// wie ein Defekt an, ein leerer Bildschirm erst recht.
  ///
  /// An den Servern nachgemessen, mitten in Berlin:
  ///
  /// ```
  /// OSM     z19 200,  z20 400            -> harte Grenze bei 19
  /// CARTO   z20 200 (3.765 B, Inhalt)    -> trägt bis 20
  /// Topo    z17 200,  z18 200 aber 4.343 B einfarbig -> Ende bei 17
  /// ```
  int get hoechsteAnzeigeStufe => (hoechsteEchteStufe ?? 19) + 2;
}

const _osmKacheln = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const _osmNennung = '© OpenStreetMap contributors';
/// Die CARTO-Adresse **einschliesslich** des Schlüsselparameters – der
/// Schlüssel selbst wird angehängt (siehe [Kartenstil.kachelUrl]).
const _cartoKacheln =
    'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png?key=';
const _cartoNennung = '© OpenStreetMap contributors © CARTO';
const _cartoUnterbereiche = ['a', 'b', 'c', 'd'];

/// Wie lange eine einmal geholte Kachel als frisch gilt.
///
/// **Ohne diese Angabe richtet sich flutter_map nach `max-age` der
/// Antwort – und genau dort liegt das Problem.** OpenTopoMap rendert
/// Kacheln bei Bedarf und gibt ausgerechnet den frisch gerenderten die
/// kürzeste Haltbarkeit. Gemessen an echten Abrufen:
///
/// ```
/// x-cache-status: MISS   max-age=15875   (4,4 h)   Abruf 1,72 s
/// x-cache-status: MISS   max-age=13615   (3,8 h)   Abruf 1,63 s
/// x-cache-status: MISS   max-age=12590   (3,5 h)   Abruf 1,48 s
/// vorgerendert           max-age=604800  (7 Tage)  Abruf 0,09 s
/// ```
///
/// Die teuersten Kacheln laufen also nach wenigen Stunden ab, und
/// flutter_map macht dann **vor** der Anzeige einen blockierenden
/// Rückfrage-Umlauf. Am selben Ort einen Tag später wartet man erneut.
///
/// Dreissig Tage sind hier vertretbar: Höhenlinien und Geländeschatten
/// ändern sich über Jahre, nicht über Stunden, und die Karte ist
/// Hintergrund für Fotopins, kein Navigationsgerät. Es schont zugleich
/// die freiwillig betriebenen Kachelserver.
const kartenKachelFrische = Duration(days: 30);

/// Obergrenze des Kachelspeichers auf der Platte.
///
/// **Von 300 MB auf 4 GB angehoben**, seit sich Gebiete vorladen lassen
/// (siehe `services/kachelvorrat.dart`). An der echten Bibliothek
/// gerechnet: 1.092 verortete Aufnahmen ergeben neun Gebiete, und die
/// bis Stufe 14 vorzuhalten sind 29.039 Kacheln – rund 850 MB. Für
/// einen zweiten Kartenstil noch einmal so viel. Mit der alten Grenze
/// hätte der Aufräumer weggeworfen, was gerade erst geholt wurde.
///
/// Vier Gigabyte sind viel für einen Zwischenspeicher und wenig neben
/// einer Fotobibliothek. Wer nichts vorlädt, merkt davon nichts: Der
/// Speicher wächst nur mit dem, was tatsächlich angesehen wird.
const kartenSpeicherGrenze = 4 * 1024 * 1024 * 1024;

/// Richtet den Kachelspeicher ein. **Einmal beim Start, vor der ersten
/// Karte.**
///
/// Der Weg über `getOrCreateInstance` ist Absicht und der Grund, warum
/// hier kein eigener `NetworkTileProvider` gebaut wird: Der Speicher ist
/// ein Einzelstück, dessen Angaben nur beim ERSTEN Aufruf wirken.
/// flutter_map holt sich später von sich aus dasselbe Stück – und
/// bekommt damit unsere Einstellungen, ohne dass wir uns in die
/// Kachelabfrage einmischen müssen.
///
/// Ein eigener `NetworkTileProvider` wäre die naheliegende Lösung
/// gewesen und wäre ein Leck geworden: [buildMapTileLayer] läuft bei
/// jedem Neuaufbau, `TileLayer.didUpdateWidget` entsorgt den alten
/// Anbieter aber nicht – jeder Aufbau hinterliesse einen offenen
/// HTTP-Client.
///
/// Auch [kartenKachelspeicher] führt hierher – siehe dort.
void kartenSpeicherEinrichten() => kartenKachelspeicher();

/// Der eine Kachelspeicher dieser App, zum Mitbenutzen.
///
/// Nicht nur die Karten holen Kacheln: Die Geländeansicht holt dieselben
/// OpenTopoMap-Bilder und dazu die Höhenkacheln
/// (`services/gelaende_laden.dart`). Ginge sie am Speicher vorbei, lüde
/// sie beim zweiten Öffnen derselben Wanderung alles noch einmal – und
/// ohne Netz gar nichts, während die Karte daneben ihre Kacheln von der
/// Platte nimmt.
///
/// Die Angaben stehen bei jedem Aufruf dabei und nicht nur beim ersten.
/// Sie wirken zwar ohnehin nur beim ersten – aber so kann kein zweiter
/// Aufrufer versehentlich ANDERE mitgeben und sich wundern, dass sie
/// nichts tun. Genau das prüft `karten_kachelspeicher_test.dart`.
MapCachingProvider kartenKachelspeicher() =>
    BuiltInMapCachingProvider.getOrCreateInstance(
      overrideFreshAge: kartenKachelFrische,
      maxCacheSize: kartenSpeicherGrenze,
    );

/// Bei welchen Statuscodes ein zweiter Versuch sinnvoll ist.
///
/// **404 steht hier mit Absicht, und das ist der Kern der Sache.**
/// OpenTopoMap rendert Kacheln bei Bedarf; ist eine noch nicht fertig,
/// antwortet der Server nicht mit „warte", sondern mit 404. An einer
/// echten Kartenfahrt im Alpenraum gemessen:
///
/// ```
/// 170 Kachelabrufe -> 126 x 200, 44 x 404   (alle auf Stufe 17)
/// dieselben 404-Kacheln Sekunden später -> 200, in 70-90 ms
/// ```
///
/// Dieselbe Fahrt kurz darauf: 142 Abrufe, kein einziger Fehler. Es ist
/// also nichts, was man beim Programmieren sieht – und für den
/// Betrachter bleibt eine graue Lücke im Kartenbild, dauerhaft.
///
/// Denn ohne diese Liste hilft niemand nach: Der Vorgabe-[RetryClient]
/// von flutter_map wiederholt **allein bei 503**, und
/// [EvictErrorTileStrategy.none] behält die gescheiterte Kachel für
/// immer. Ein einziger Fehlschlag wird so zu einem Loch, das bis zum
/// nächsten Programmstart bleibt.
///
/// Bei OSM und CARTO ist ein 404 dagegen echt. Der Preis dafür sind
/// zwei überflüssige Abrufe für eine Kachel, die es ohnehin nicht gibt –
/// gegenüber einer Lücke im Bild ist das der bessere Handel.
bool kachelNochmalVersuchen(int status) =>
    status == 404 || // noch nicht gerendert, siehe oben
    status == 408 || // Zeitüberschreitung beim Server
    status == 429 || // zu viele Abrufe, gleich wieder gut
    (status >= 500 && status < 600);

/// Ob ein geworfener Fehler einen zweiten Versuch verdient.
///
/// Abgebrochene Abrufe gehören ausdrücklich **nicht** dazu: flutter_map
/// bricht selbst ab, wenn eine Kachel beim schnellen Ziehen gar nicht
/// mehr gebraucht wird. Die zu wiederholen hiesse, dem Server Arbeit für
/// Bilder aufzuladen, die niemand mehr sieht.
bool kachelFehlerNochmalVersuchen(Object fehler) {
  if (fehler is ClientException) {
    final m = fehler.message.toLowerCase();
    if (m.contains('cancel') || m.contains('abort')) return false;
    return true;
  }
  return fehler is SocketException ||
      fehler is HttpException ||
      fehler is TimeoutException;
}

/// Wartezeit vor dem Versuch nach dem [versuch]-ten Fehlschlag.
///
/// Kurz genug, dass die Kachel noch im Bild ist, wenn sie ankommt, und
/// lang genug, dass ein Renderer sie fertigstellen kann. Zwei Versuche
/// sind die Obergrenze: Die Kachelserver werden gespendet.
Duration kachelWartezeit(int versuch) =>
    Duration(milliseconds: 400 * (versuch + 1) * (versuch + 1));

/// Wie oft ein gescheiterter Kachelabruf wiederholt wird.
const kachelVersuche = 2;

/// Wie viele Kachelabrufe gleichzeitig zum selben Server laufen dürfen.
///
/// **Ohne Grenze sind es so viele, wie das Bild Kacheln hat.** Dart legt
/// für jeden gleichzeitigen Abruf eine eigene Verbindung an, und
/// flutter_map fordert beim Ziehen alle sichtbaren Kacheln auf einmal
/// an: bei einem grossen Fenster sechzig TLS-Handschläge in einem Zug,
/// bei jedem Ruck neu. Die Kachelserver werden gespendet, und die
/// Nutzungsregeln von OpenStreetMap bitten ausdrücklich um Zurückhaltung.
///
/// Sechs ist die Zahl, mit der auch Browser seit jeher arbeiten.
/// Gemessen an vier Wellen zu je 60 Kacheln, echte Abrufe:
///
/// ```
/// ohne Grenze   189, 72, 54, 53 ms
/// Grenze 6      259, 198, 215, 200 ms
/// Grenze 4      328, 291, 326, 288 ms
/// ```
///
/// Der Preis ist also gut eine Zehntelsekunde je Bildschirmfüllung –
/// nicht zu sehen – und dafür sechs Verbindungen statt sechzig.
const kachelVerbindungen = 6;

/// Wie lange ein Kachelabruf schweigen darf, bevor er abgebrochen wird.
///
/// **Bis hierher stand im ganzen Kachelweg keine einzige Zeitgrenze** –
/// weder am Verbinden noch am Warten auf die Antwort. Das klingt nach
/// einer Kleinigkeit und ist der Unterschied zwischen einer Karte, die
/// sich erholt, und einer, die für den Rest der Sitzung grau bleibt.
///
/// Denn [kachelVerbindungen] deckelt die Zahl gleichzeitiger
/// Verbindungen zu einem Server auf sechs. Bleiben sechs Antworten aus –
/// halboffene Verbindungen nach Ruhezustand, Netzwechsel oder einem
/// Server, der annimmt und schweigt –, wartet **jeder weitere Abruf auf
/// einen Platz, der nie frei wird**. An einem Server nachgestellt, der
/// annimmt und nichts sagt:
///
/// ```
/// nach 2 s : 6 Verbindungen offen, 0 Abrufe fertig
/// nach 10 s: siebter Abruf immer noch nicht fertig
/// ```
///
/// Und weil dieser siebte Abruf nie **scheitert**, sondern schlicht
/// wartet, meldet flutter_map auch keine gescheiterte Kachel. Die
/// Nachfass-Staffel aus [kachelNachfassen] wird damit nie ausgelöst: Es
/// gibt ja keinen Fehler, an dem sie sich festmachen könnte. Die Kachel
/// bleibt für immer im Zustand „lädt".
///
/// **`connectionTimeout` ist dafür der falsche Griff**, und das war der
/// erste Anlauf: Die Verbindung STEHT ja – sie wird angenommen, es kommt
/// nur nichts zurück. Im selben Versuch gemessen: mit
/// `connectionTimeout: 1 s` brach nach zwanzig Sekunden **kein
/// einziger** der acht Abrufe ab. Es braucht eine Frist auf die
/// **Antwort**, und sie muss die Verbindung wirklich abräumen, nicht nur
/// das Warten aufgeben.
///
/// Fünfzehn Sekunden, und die Uhr wird einmal neu gestellt, sobald die
/// Kopfzeilen da sind: einmal fürs Verbinden und Antworten, einmal für
/// den Rumpf. Zum Vergleich die gemessenen Wirklichkeiten – 36 Kacheln
/// in einem Zug, echte Abrufe:
///
/// ```
/// OSM  z12  138 ms      OSM  z19  2.080 ms
/// Topo z12  213 ms      Topo z17    135 ms
/// OpenTopoMap frisch gerendert (MISS): 1,72 s
/// ```
///
/// **Eine Frist auf Stille wäre schöner gewesen und ist nicht zu
/// haben.** Der erste Entwurf stellte die Uhr bei jedem angekommenen
/// Stück neu, damit ein langsamer, aber laufender Abruf nicht
/// abgeschnitten wird. Der Prüfstand zeigte, dass dieses Stück nie
/// einzeln ankommt: `HttpClientResponse` gibt den Rumpf **am Stück**
/// heraus, nachdem er vollständig gelesen ist. An einem Server
/// gemessen, der acht Stücke im Abstand von 250 ms schickt:
///
/// ```
/// Server: Stueck 0 .. 7 raus, 60410 .. 62182 ms
/// Client: 8 x 128 B, alle bei 62437 ms
/// ```
///
/// Das Neustellen steht trotzdem im Code – es kostet nichts und wäre
/// richtig, falls eine Plattform doch stückweise liefert. Verlassen darf
/// man sich nicht darauf: In der Praxis deckt die zweite Uhr den ganzen
/// Rumpf ab.
const kachelZeitgrenze = Duration(seconds: 15);

/// Der Client, der einen schweigenden Abruf nicht ewig laufen lässt.
///
/// **Warum ein eigener Client und nicht `Future.timeout`.** Eine Frist
/// auf das Future gibt nur das Warten auf – die Verbindung darunter
/// bleibt belegt, und genau darum geht es hier. Der Abbruch muss bis zum
/// Socket durchschlagen. `package:http` kann das seit 1.6 über
/// [Abortable]: `IOClient` hängt sich an den `abortTrigger` und ruft
/// `HttpClientRequest.abort`.
///
/// Deshalb wird die Anfrage hier **umkopiert** – mit einem Auslöser, der
/// entweder von der Frist oder vom ursprünglichen Auslöser kommt. Der
/// muss mit, sonst verlöre die Karte ihre eigene Abbruchmöglichkeit für
/// Kacheln, die beim Ziehen aus dem Bild laufen.
///
/// **Und der Fehler muss die Farbe wechseln.** flutter_map behandelt
/// [RequestAbortedException] als geplanten Abbruch: durchsichtige Kachel,
/// kein Fehler, kein neuer Versuch. Für einen Abbruch beim Ziehen ist das
/// richtig, für eine abgelaufene Frist genau falsch – die Kachel bliebe
/// stumm leer. Wer wegen der Frist stirbt, stirbt deshalb als
/// [ClientException], und damit greifen [kachelFehlerNochmalVersuchen],
/// der `RetryClient` und am Ende die Staffel aus [Kachelschicht].
class ZeitgrenzeClient extends BaseClient {
  ZeitgrenzeClient(this._innen, {this.frist = kachelZeitgrenze});

  final Client _innen;
  final Duration frist;

  @override
  Future<StreamedResponse> send(BaseRequest anfrage) async {
    final abbruch = Completer<void>();
    var wegenFrist = false;
    Timer? uhr;

    void stelleUhr() {
      uhr?.cancel();
      uhr = Timer(frist, () {
        if (abbruch.isCompleted) return;
        wegenFrist = true;
        abbruch.complete();
      });
    }

    void ausschalten() {
      uhr?.cancel();
      uhr = null;
    }

    // Der eigene Auslöser der Karte muss weiter durchschlagen – siehe
    // Klassenkommentar.
    if (anfrage case Abortable(:final abortTrigger?)) {
      unawaited(abortTrigger.whenComplete(() {
        if (!abbruch.isCompleted) abbruch.complete();
      }));
    }
    stelleUhr();

    Never uebersetze(Object fehler, StackTrace spur) {
      if (wegenFrist) {
        Error.throwWithStackTrace(
          // Englisch wie die uebrigen Meldungen dieser Schicht: Sie
          // landen unveraendert im Kachelmitschnitt, neben denen von
          // dart:io, und werden nicht uebersetzt.
          ClientException(
              'Aborted: no response within ${frist.inSeconds} s', anfrage.url),
          spur,
        );
      }
      Error.throwWithStackTrace(fehler, spur);
    }

    final kopie = AbortableStreamedRequest(anfrage.method, anfrage.url,
        abortTrigger: abbruch.future)
      ..followRedirects = anfrage.followRedirects
      ..headers.addAll(anfrage.headers)
      ..maxRedirects = anfrage.maxRedirects
      ..persistentConnection = anfrage.persistentConnection;
    if (anfrage.contentLength != null) {
      kopie.contentLength = anfrage.contentLength;
    }
    unawaited(anfrage.finalize().forEach(kopie.sink.add).then(
          (_) => kopie.sink.close(),
          onError: (Object f, StackTrace s) => kopie.sink.addError(f, s),
        ));

    final StreamedResponse antwort;
    try {
      antwort = await _innen.send(kopie);
    } catch (fehler, spur) {
      ausschalten();
      uebersetze(fehler, spur);
    }
    // Die Kopfzeilen sind da – ab hier zählt die Stille im Rumpf.
    stelleUhr();

    final durchgereicht = StreamController<List<int>>();
    late final StreamSubscription<List<int>> abo;
    abo = antwort.stream.listen(
      (stueck) {
        stelleUhr();
        durchgereicht.add(stueck);
      },
      onError: (Object fehler, StackTrace spur) {
        ausschalten();
        if (wegenFrist) {
          durchgereicht.addError(
              ClientException(
                  'Aborted: response body stalled for ${frist.inSeconds} s',
                  anfrage.url),
              spur);
        } else {
          durchgereicht.addError(fehler, spur);
        }
        durchgereicht.close();
      },
      onDone: () {
        ausschalten();
        durchgereicht.close();
      },
    );
    durchgereicht.onCancel = () {
      ausschalten();
      return abo.cancel();
    };

    return StreamedResponse(
      durchgereicht.stream,
      antwort.statusCode,
      contentLength: antwort.contentLength,
      request: antwort.request,
      headers: antwort.headers,
      isRedirect: antwort.isRedirect,
      persistentConnection: antwort.persistentConnection,
      reasonPhrase: antwort.reasonPhrase,
    );
  }

  @override
  void close() => _innen.close();
}

/// Der Anbieter, bei dem ein zweiter Anlauf auch wirklich einer ist.
///
/// **Warum es ihn braucht.** [Kachelschicht] zählt nach einem Fehlschlag
/// eine Zusatzangabe hoch, damit flutter_map `reloadImages` ausführt.
/// Das tut es auch – aber `TileImage.load` hängt seinen Horcher nur an,
/// wenn der **Bildschlüssel** sich geändert hat:
///
/// ```dart
/// _imageStream = imageProvider.resolve(ImageConfiguration.empty);
/// if (_imageStream!.key != oldImageStream?.key) { ... addListener ... }
/// ```
///
/// `NetworkTileImageProvider` vergleicht sich über `Object.hash(url,
/// fallbackUrl)`, und die Runde stand bewusst in keiner Adresse. Also
/// blieb der Schlüssel gleich, es kam kein Horcher dazu, und damit wurde
/// **nie wieder ein Fehler gemeldet**. Gemessen, eine Kachel in der
/// Bildmitte, die dauerhaft scheitert:
///
/// ```
///                        Nachfassen  1  2  3  4  5  6
/// Schlüssel gleich (echt)             1  0  0  0  0  0
/// Schlüssel je Abruf neu (Prüfstand)  1  0  0  1  0  0
/// ```
///
/// Die Staffel 5 s / 15 s / 45 s ([kachelNachfassen]) wurde also nie
/// erreicht: Wer nach fünf Sekunden noch fehlte, fehlte für immer. Der
/// vorhandene Prüfstand sah das nicht, weil sein Anbieter jedem Abruf
/// eine eigene Nummer gibt – ein Kunstgriff gegen den Bildspeicher, der
/// zugleich genau das Verhalten herstellte, das dem echten Anbieter
/// fehlt.
///
/// **Wie es hier gelöst ist.** Nur die Adresse einer Kachel, die schon
/// gescheitert ist, bekommt einen Anhang – und zwar als
/// **Rautenteil**. Der wird von dart:io nicht mitgeschickt: Der Server
/// sieht denselben Abruf wie immer, aber Flutter sieht einen anderen
/// Schlüssel und hängt seinen Horcher an. Die Kacheln, die schon liegen,
/// behalten ihre Adresse und damit ihren Platz im Bildspeicher – sonst
/// zöge jedes Nachfassen den ganzen Bildschirm neu über die Leitung, und
/// die Kachelserver werden gespendet.
/// Der Kachelspeicher, der den Nachfass-Anhang nicht mitzaehlt.
///
/// **Warum es ihn braucht.** [Nachfassanbieter] haengt an die Adresse
/// einer gescheiterten Kachel einen Rautenteil `#1`, `#2` … Das ist fuer
/// den Server unsichtbar (dart:io schneidet ihn ab) und fuer Flutters
/// Bildspeicher genau der gewuenschte Unterschied. Fuer den
/// **Kachelspeicher auf der Platte** ist es einer zu viel: Dessen
/// Schluessel ist eine UUID Fassung 5 ueber der vollen Adresse, und die
/// aendert sich mit jedem Zeichen. Nachgerechnet:
///
/// ```
/// .../12/2148/1370.png     -> 1a3d912d-cc8b-5121-842d-fccfb3a86bd6
/// .../12/2148/1370.png#1   -> 257e26da-952e-5b88-960d-b5c1ac48d0be
/// .../12/2148/1370.png#2   -> 0af6f85d-700f-586e-8b5e-60482706d685
/// ```
///
/// Zwei Schaeden folgen daraus, und beide treffen genau den Fall, fuer
/// den es das Vorladen gibt. **Erstens** wird eine Kachel, die einmal
/// gescheitert ist, danach nie wieder auf der Platte gesucht – die
/// vorgeladene Fassung liegt da und wird nicht mehr gefunden. Ohne Netz
/// bleibt das Loch also stehen, obwohl das Bild bereits im Haus ist.
/// **Zweitens** landete dieselbe Kachel bei Erfolg ein zweites Mal im
/// Speicher, unter dem verunreinigten Schluessel.
///
/// Hier wird der Rautenteil deshalb abgeschnitten, bevor gelesen oder
/// geschrieben wird. Der Bildspeicher sieht weiterhin zwei verschiedene
/// Adressen, die Platte nur eine.
class FragmentloserSpeicher implements MapCachingProvider {
  /// Um einen bereits gebauten Speicher herum – für Prüfstände.
  FragmentloserSpeicher(MapCachingProvider innen) : _bauen = (() => innen);

  /// **Erst beim ersten Zugriff** den Speicher anlegen.
  ///
  /// Nicht der Ordnung halber, sondern weil es sonst bricht:
  /// [BuiltInMapCachingProvider.getOrCreateInstance] fragt über
  /// `path_provider` nach dem Zwischenspeicher-Verzeichnis, und das geht
  /// über einen Plattformkanal. Wer ihn schon im Konstruktor von
  /// [Nachfassanbieter] anlegt, verlangt damit eine fertige Bindung –
  /// und ein Prüfstand, der bloss den Anbieter baut, fällt mit
  /// „Binding has not yet been initialized" um. Genau so ist es beim
  /// ersten Anlauf passiert.
  FragmentloserSpeicher.spaet([MapCachingProvider Function()? bauen])
      : _bauen = bauen ?? kartenKachelspeicher;

  final MapCachingProvider Function() _bauen;
  MapCachingProvider? _gebaut;
  MapCachingProvider get _innen => _gebaut ??= _bauen();

  /// Sichtbar fuer den Pruefstand: Was aus einer Adresse mit Anhang wird.
  static String ohneAnhang(String adresse) {
    final raute = adresse.indexOf('#');
    return raute < 0 ? adresse : adresse.substring(0, raute);
  }

  @override
  bool get isSupported => _innen.isSupported;

  @override
  Future<CachedMapTile?> getTile(String url) => _innen.getTile(ohneAnhang(url));

  @override
  Future<void> putTile({
    required String url,
    required CachedMapTileMetadata metadata,
    Uint8List? bytes,
  }) =>
      _innen.putTile(
          url: ohneAnhang(url), metadata: metadata, bytes: bytes);
}

class Nachfassanbieter extends NetworkTileProvider {
  Nachfassanbieter({super.httpClient})
      : super(cachingProvider: FragmentloserSpeicher.spaet());

  /// Kachel -> wie oft sie schon gescheitert ist. Nur Einträge für
  /// Kacheln, die tatsächlich fehlgeschlagen sind.
  final _gescheitert = <TileCoordinates, int>{};

  @visibleForTesting
  int get offeneFehlschlaege => _gescheitert.length;

  @override
  String getTileUrl(TileCoordinates coordinates, TileLayer options) {
    final adresse = super.getTileUrl(coordinates, options);
    final versuch = _gescheitert[coordinates];
    return versuch == null ? adresse : '$adresse#$versuch';
  }

  void merkeFehlschlag(TileCoordinates koordinaten) {
    _gescheitert[koordinaten] = (_gescheitert[koordinaten] ?? 0) + 1;
  }

  /// Nach überstandener Störung wieder bei den blanken Adressen anfangen
  /// – sonst wüchse die Liste über die ganze Laufzeit.
  void vergissFehlschlaege() => _gescheitert.clear();
}

Nachfassanbieter? _kachelAnbieter;

/// Der gemeinsame Kachelanbieter samt Wiederholungen.
///
/// Ein **Einzelstück**, aus demselben Grund wie beim Speicher: Ein
/// eigener Anbieter je Aufbau wäre ein Leck, denn
/// `TileLayer.didUpdateWidget` entsorgt den alten nicht. Hier ist es
/// zusätzlich ungefährlich, den einen weiterzureichen – der Anbieter
/// schliesst in `dispose()` nur einen selbst erzeugten HTTP-Client, und
/// unserer wird von aussen übergeben.
Nachfassanbieter kartenKachelAnbieter() =>
    _kachelAnbieter ??= Nachfassanbieter(httpClient: kachelNetzClient());

Client? _kachelNetz;

/// Der Client, über den alle Kacheln kommen: mit Wiederholungen und mit
/// gedeckelter Zahl gleichzeitiger Verbindungen ([kachelVerbindungen]).
///
/// Öffentlich, damit ein Prüfstand ihn gegen einen eigenen Server
/// laufen lassen kann – die Deckelung ist sonst nirgends abzulesen.
Client kachelNetzClient() => _kachelNetz ??= RetryClient(
      // Die Frist sitzt UNTER dem Mitschnitt und IM RetryClient: unter dem
      // Mitschnitt, damit ein abgelaufener Abruf dort als Fehlschlag steht
      // und nicht als Abruf, den es nie gab; im RetryClient, damit ein
      // schweigender Server einen zweiten Anlauf bekommt, statt die Kachel
      // gleich grau zu lassen.
      MitschnittClient(ZeitgrenzeClient(IOClient(kachelHttpClient())),
          Kachelmitschnitt.instanz),
      retries: kachelVersuche,
      when: (antwort) => kachelNochmalVersuchen(antwort.statusCode),
      whenError: (fehler, _) => kachelFehlerNochmalVersuchen(fehler),
      delay: kachelWartezeit,
    );

/// Der `HttpClient` unter allem: gedeckelte Verbindungszahl – und eine
/// Verbindungsfabrik, deren einzige Aufgabe das Zählen ist.
///
/// **Warum die Fabrik und nicht der Client darüber zählt.** Ein
/// HTTP-Abruf ist nicht dasselbe wie eine Verbindung: Bleibt sie offen,
/// laufen zwanzig Abrufe über eine einzige. Genau dieser Unterschied ist
/// die offene Frage bei den grauen Kacheln – von aussen waren 5702
/// Verbindungen für 496 Kacheln zu sehen, ohne dass sich sagen liesse,
/// ob zu oft abgerufen oder zu oft neu verbunden wurde.
/// `connectionFactory` wird von dart:io **genau dann** gerufen, wenn eine
/// neue Verbindung entsteht. Damit steht die Zahl unmittelbar.
@visibleForTesting
HttpClient kachelHttpClient() => HttpClient()
  ..maxConnectionsPerHost = kachelVerbindungen
  // Deckt nur das Verbinden ab, nicht das Warten auf die Antwort – dafür
  // ist [ZeitgrenzeClient] da, und dort steht auch, warum diese Zeile
  // allein nichts gerettet hätte.
  ..connectionTimeout = const Duration(seconds: 10)
  ..connectionFactory = kachelVerbindung;

/// Öffnet die Verbindung, die ein Kachelabruf braucht – und zählt sie.
///
/// **Die Falle, in die ich hier zuerst gelaufen bin.** Wer eine
/// `connectionFactory` setzt, übernimmt damit auch die Verschlüsselung:
/// `HttpClient` legt **kein** TLS über einen Socket, den es nicht selbst
/// geöffnet hat. Mit einem schlichten `Socket.startConnect` ging jeder
/// Abruf also unverschlüsselt an Port 443 – und der Server sagte, was zu
/// erwarten war:
///
/// ```
/// 400 The plain HTTP request was sent to HTTPS port
/// connection: close
/// ```
///
/// Nicht eine einzige Kachel kam an, und weil nginx nach diesem Fehler
/// zumacht, kostete jeder Abruf eine eigene Verbindung. Aufgefallen ist
/// es dem Mitschnitt, für den die Fabrik gebaut wurde – im Prüfstand
/// nicht, denn der lief über `http://` auf der eigenen Maschine, und dort
/// ist genau nichts zu verschlüsseln.
///
/// Bei einem Proxy bleibt es beim nackten Socket: Dorthin spricht
/// `HttpClient` erst `CONNECT` und baut den TLS-Tunnel danach selbst auf.
@visibleForTesting
Future<ConnectionTask<Socket>> kachelVerbindung(
    Uri ziel, String? proxyRechner, int? proxyTor) {
  Kachelmitschnitt.instanz.verbindungGeoeffnet();
  if (proxyRechner != null) {
    return Socket.startConnect(proxyRechner, proxyTor!);
  }
  return ziel.scheme == 'https'
      ? SecureSocket.startConnect(ziel.host, ziel.port)
      : Socket.startConnect(ziel.host, ziel.port);
}

/// Untergeschobener Anbieter für Tests – sonst `null`.
///
/// Ein Prüfstand braucht Kacheln, die auf Ansage scheitern; über das
/// Netz ist ein Fehlschlag nicht zu bestellen.
@visibleForTesting
TileProvider? kachelAnbieterFuerTest;

/// Liefert die Kacheln des gewählten Stils.
///
/// Ohne [stil] richtet sich das nach dem Theme – da die App aber permanent
/// dunkel eingefärbt ist (siehe main.dart), würde das nie helle Kacheln
/// liefern; [MapScreen] übergibt deshalb den vom Nutzer gewählten Stil
/// ausdrücklich, statt sich auf das App-Theme zu verlassen.
TileLayer buildMapTileLayer(
  BuildContext context, {
  Kartenstil? stil,
  int runde = 0,
  VoidCallback? beiFehler,
}) {
  final gewaehlt = stil ?? _ausTheme(context);
  final anbieter = kachelAnbieterFuerTest ?? kartenKachelAnbieter();
  return TileLayer(
    urlTemplate: gewaehlt.kachelUrl,
    subdomains: gewaehlt.unterbereiche,
    // Der Zähler steht in KEINER Adresse – er ist nur da, damit
    // flutter_map beim Hochzählen `reloadImages` auslöst und die
    // gescheiterten Kacheln neu anfordert. Siehe [Kachelschicht].
    // Zusatzangaben, die in der Vorlage nicht vorkommen, verändern die
    // Adresse nicht, und damit bleibt auch der Speicherschlüssel gleich.
    additionalOptions: runde == 0 ? const {} : {'nachfassen': '$runde'},
    // Die Koordinate geht mit: Nur die gescheiterte Kachel bekommt beim
    // naechsten Anlauf einen anderen Bildschluessel, siehe
    // [Nachfassanbieter].
    errorTileCallback: beiFehler == null
        ? null
        : (kachel, __, ___) {
            if (anbieter is Nachfassanbieter) {
              anbieter.merkeFehlschlag(kachel.coordinates);
            }
            beiFehler();
          },
    // 19 ist die Vorgabe von flutter_map; nur OpenTopoMap hoert
    // frueher auf.
    maxNativeZoom: gewaehlt.hoechsteEchteStufe ?? 19,
    // OpenTopoMap bittet ausdrücklich um einen aussagekräftigen
    // User-Agent statt der Vorgabe der Bibliothek.
    userAgentPackageName: 'com.example.photoVault',
    tileProvider: anbieter,
    // Die dunkle Karte ohne CARTO-Schlüssel bekommt helle OSM-Kacheln
    // geliefert und dreht sie hier um (siehe [Kartenstil.dunkel]).
    // `darkModeTileBuilder` gehört zu flutter_map selbst - es ist eine
    // Farbmatrix, die invertiert und den Farbton um 180 Grad
    // zurückdreht, damit Grünflächen grün und Wasser blau bleiben statt
    // in die Gegenfarbe zu kippen.
    //
    // Am Einzelbild und nicht am Behälter: Die Fassung von flutter_map,
    // die `tilesContainerBuilder` kannte, gibt es nicht mehr - in 8.3.1
    // führt der einzige Weg über `tileBuilder`.
    tileBuilder: gewaehlt.invertieren ? darkModeTileBuilder : null,
    // Bleibt eine Kachel auch nach den Wiederholungen aus, wird sie
    // beim Wegscrollen weggeworfen statt behalten. Die Vorgabe
    // `none` hiesse: Wer zu der Stelle zurückkehrt, sieht dieselbe
    // Lücke wieder - ohne dass je ein neuer Versuch stattfände.
    //
    // Für die Kachel, die im Bild BLEIBT, reicht das nicht: Sie wird
    // nie weggescrollt und damit nie wieder versucht. Dafür ist
    // [Kachelschicht] da.
    evictErrorTileStrategy: EvictErrorTileStrategy.notVisible,
  );
}

/// Wie lange nach einem Fehlschlag bis zum nächsten Anlauf gewartet
/// wird. Der letzte Wert gilt danach weiter.
///
/// Fünf Sekunden, weil die gemessenen Ausfälle kurz waren – dieselben
/// Kacheln kamen Sekunden später in unter 90 ms an. Danach länger, damit
/// ein Rechner ohne Netz nicht alle fünf Sekunden gegen die Wand läuft.
const kachelNachfassen = [
  Duration(seconds: 5),
  Duration(seconds: 15),
  Duration(seconds: 45),
];

/// Bleibt es nach einem Anlauf so lange still, gilt die Störung als
/// vorbei – die nächste fängt dann wieder bei fünf Sekunden an.
const kachelGeheiltNach = Duration(seconds: 4);

/// Die Kachelschicht, die einen Fehlschlag nicht als endgültig nimmt.
///
/// **Der Anlass, an echten Daten abgelesen.** In einer Minute machte die
/// App 951 Verbindungen für 178 angekommene Kacheln – gut fünf Anläufe
/// je Erfolg, also drei Versuche für rund 260 Kacheln, die alle
/// scheiterten. Die Minute davor und die Minute danach standen bei
/// eins zu eins. Ein kurzer Aussetzer beim Kachelserver also, und
/// hinterher fehlten in der Bibliothek 145 von 195 Kacheln des
/// Ausschnitts.
///
/// **Warum daraus ein Dauerschaden wurde:** Wiederholt wird zweimal, mit
/// 0,4 und 1,6 Sekunden Abstand (siehe [kachelWartezeit]). Danach gilt
/// die Kachel als gescheitert. Weggeworfen wird eine gescheiterte Kachel
/// nur, wenn sie aus dem Bild geschoben wird
/// ([EvictErrorTileStrategy.notVisible]) – wer stehen bleibt, sieht
/// seine graue Lücke bis zum Programmende. Genau das zeigten die beiden
/// Bildschirmfotos: eine Karte, die zu drei Vierteln grau blieb, obwohl
/// der Server längst wieder antwortete.
///
/// **Wie sie nachfasst:** Meldet flutter_map eine gescheiterte Kachel,
/// läuft eine Uhr. Wenn sie abgelaufen ist, zählt diese Schicht eine
/// Zusatzangabe hoch, die in keiner Adresse vorkommt. flutter_map
/// vergleicht die Zusatzangaben und lädt daraufhin die Bilder aller
/// Kacheln neu – **ohne** die vorhandenen wegzuwerfen. Für eine Kachel,
/// die schon liegt, ändert sich dabei nichts (gleicher Bildschlüssel,
/// kein neuer Abruf, kein Flackern); die gescheiterte bekommt einen
/// neuen Anlauf.
///
/// Die Alternative wäre der `reset`-Strom von flutter_map gewesen. Der
/// wirft erst alle Kacheln weg und baut sie neu auf – das flackert bei
/// jedem Anlauf über die ganze Karte.
class Kachelschicht extends StatefulWidget {
  const Kachelschicht({super.key, this.stil});

  /// Ohne Angabe richtet sich der Stil nach dem Theme – siehe
  /// [buildMapTileLayer].
  final Kartenstil? stil;

  @override
  State<Kachelschicht> createState() => _KachelschichtState();
}

class _KachelschichtState extends State<Kachelschicht> {
  /// Zählt jeden Anlauf. Steht in keiner Adresse, siehe Klassenkommentar.
  int _runde = 0;

  /// Der wievielte Anlauf dieser Störung – bestimmt die Wartezeit.
  int _stufe = 0;

  Timer? _uhr;
  Timer? _stille;

  void _kachelGescheitert() {
    // Ein neuer Fehler heisst: der letzte Anlauf hat nicht geholfen.
    _stille?.cancel();
    _stille = null;
    // Eine Uhr genügt für alle Kacheln einer Störung – sonst liefen bei
    // sechzig grauen Kacheln sechzig Uhren.
    if (_uhr != null) return;
    final warten = _stufe < kachelNachfassen.length
        ? kachelNachfassen[_stufe]
        : kachelNachfassen.last;
    _uhr = Timer(warten, () {
      _uhr = null;
      if (!mounted) return;
      _stufe++;
      setState(() => _runde++);
      _stille = Timer(kachelGeheiltNach, () {
        _stille = null;
        _stufe = 0;
        // Stoerung vorbei: wieder blanke Adressen, sonst waechst die
        // Liste ueber die ganze Laufzeit (siehe [Nachfassanbieter]).
        final anbieter = kachelAnbieterFuerTest ?? kartenKachelAnbieter();
        if (anbieter is Nachfassanbieter) anbieter.vergissFehlschlaege();
      });
    });
  }

  @override
  void dispose() {
    _uhr?.cancel();
    _stille?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => buildMapTileLayer(
        context,
        stil: widget.stil,
        runde: _runde,
        beiFehler: _kachelGescheitert,
      );
}

Kartenstil _ausTheme(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? Kartenstil.dunkel
        : Kartenstil.hell;

/// Die höchste Zoomstufe, die für den gerade geltenden Stil sinnvoll ist.
///
/// Öffentlich, damit jede Karte in dieser App dieselbe Grenze setzen kann
/// – auch die, die nicht in dieser Datei steht. Ohne Grenze zoomt
/// flutter_map unbegrenzt weiter und fordert Kacheln an, die es nicht
/// gibt (siehe zoomgrenze_test.dart, das genau darauf besteht).
double kartenHoechsteStufe(BuildContext context, {Kartenstil? stil}) =>
    (stil ?? _ausTheme(context)).hoechsteAnzeigeStufe.toDouble();

/// Die Namensnennung der Kartenanbieter – eine Auflage der Lizenz, also
/// muss sie lesbar bleiben.
///
/// Eigenhändig gebaut statt mit `SimpleAttributionWidget`: Jenes setzt den
/// Text in normaler Schriftgröße in eine Zeile fester Breite und stellt
/// ihm noch „flutter_map | ©" voran – ein Hinweis auf die verwendete
/// Programmbibliothek, der mit der Lizenz nichts zu tun hat. In der 340
/// Punkte breiten Info-Ansicht lief die Zeile dadurch um über 400 Punkte
/// über und wurde abgeschnitten; ausgerechnet die Namensnennung war damit
/// unvollständig. Hier steht sie klein, umbricht bei Bedarf und ist auf
/// zwei Drittel der Breite begrenzt, damit sie die Karte nicht zudeckt.
Widget buildMapAttribution(BuildContext context, {Kartenstil? stil}) {
  final gewaehlt = stil ?? _ausTheme(context);
  return Align(
    alignment: Alignment.bottomRight,
    child: LayoutBuilder(
      builder: (context, constraints) => ConstrainedBox(
        constraints: BoxConstraints(maxWidth: constraints.maxWidth * 2 / 3),
        child: ColoredBox(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.75),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              gewaehlt.namensnennung,
              // Elf statt neun Punkte: Ein Rechtevermerk soll nicht ins
              // Auge springen, aber lesbar sein muss er (15. Pruefrunde).
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

const _defaultCenter = ll.LatLng(51.1657, 10.4515); // Mitte Deutschlands
const _defaultZoom = 5.0;
const _pinZoom = 14.0;

/// Kleine, eingebettete Kartenansicht für die Info-Ansicht eines einzelnen
/// Assets: zeigt den gespeicherten Ort als Marker. Ist [onLocationChanged]
/// gesetzt, lässt sich der Ort durch Antippen der Karte festlegen bzw.
/// korrigieren (z.B. wenn ein Video keine EXIF-GPS-Daten hat oder das Foto
/// am falschen Ort geotaggt wurde).
class MiniLocationMap extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final double height;
  final void Function(double latitude, double longitude)? onLocationChanged;

  /// `BorderRadius.zero` für randlose ("full bleed") Darstellung, z.B. am
  /// unteren Rand eines Panels (siehe AssetInfoSheet) statt als abgerundete
  /// Karte innerhalb eines gepolsterten Bereichs.
  final BorderRadius borderRadius;

  const MiniLocationMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.height = 160,
    this.onLocationChanged,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  State<MiniLocationMap> createState() => _MiniLocationMapState();
}

class _MiniLocationMapState extends State<MiniLocationMap> {
  /// Steuert die Karte von aussen – für die beiden Zoomknöpfe und für
  /// den Wischzoom.
  final _steuerung = MapController();

  bool get _hasLocation =>
      widget.latitude != null && widget.longitude != null;

  /// Ein Zoomschritt über die Knöpfe.
  ///
  /// Geklemmt wird selbst: `move` nimmt jeden Wert an und die Karte
  /// stünde dann über den vorhandenen Kacheln (siehe
  /// [Kartenstil.hoechsteAnzeigeStufe]).
  void _zoomen(double schritt) {
    final kamera = _steuerung.camera;
    final grenze = _ausTheme(context).hoechsteAnzeigeStufe.toDouble();
    final neu = (kamera.zoom + schritt).clamp(1.0, grenze);
    if (neu == kamera.zoom) return;
    _steuerung.move(kamera.center, neu);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final center = _hasLocation
        ? ll.LatLng(widget.latitude!, widget.longitude!)
        : _defaultCenter;
    final editable = widget.onLocationChanged != null;
    final hoechsteStufe = _ausTheme(context).hoechsteAnzeigeStufe.toDouble();

    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            // Der Wischzoom sitzt aussen herum, aus demselben Grund wie
            // auf der grossen Karte: Eine Maus ohne Rad (Magic Mouse)
            // und ein Trackpad verschieben sonst nur. Bis hierher liess
            // sich diese Karte damit überhaupt nicht zoomen.
            WischZoom(
              steuerung: _steuerung,
              groesserZoom: hoechsteStufe,
              child: FlutterMap(
              mapController: _steuerung,
              options: MapOptions(
                initialCenter: center,
                initialZoom: _hasLocation ? _pinZoom : _defaultZoom,
                // Auch hier: ohne Grenze zoomt die Karte ueber die
                // vorhandenen Kacheln hinaus – siehe
                // [Kartenstil.hoechsteAnzeigeStufe].
                maxZoom: hoechsteStufe,
                onTap: !editable
                    ? null
                    : (_, point) =>
                        widget.onLocationChanged!(point.latitude, point.longitude),
              ),
              children: [
                const Kachelschicht(),
                buildMapAttribution(context),
                if (_hasLocation)
                  MarkerLayer(markers: [
                    Marker(
                      point: center,
                      width: 32,
                      height: 32,
                      alignment: Alignment.topCenter,
                      child: const Icon(Icons.location_pin, color: Colors.redAccent, size: 32),
                    ),
                  ]),
              ],
            ),
            ),
            // Die beiden Knöpfe – der Weg, der immer geht, egal welches
            // Zeigegerät angeschlossen ist.
            Positioned(
              right: 4,
              bottom: 4,
              child: _Zoomknoepfe(
                beiNaeher: () => _zoomen(1),
                beiWeiter: () => _zoomen(-1),
              ),
            ),
            if (!_hasLocation && editable)
              Positioned.fill(
                child: IgnorePointer(
                  child: ColoredBox(
                    color: Colors.black45,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Text(
                          AppTexte.of(context).karteTippenFuerOrt,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Zwei kleine Knöpfe zum Zoomen.
///
/// Eigenes, kleines Widget statt der `Zoomsteuerung` der grossen
/// Karte: Die trägt Standortabfrage und Ereignisschalter mit sich und
/// wäre in einer 160 Punkte hohen Vorschau zu gross.
class _Zoomknoepfe extends StatelessWidget {
  final VoidCallback beiNaeher;
  final VoidCallback beiWeiter;

  const _Zoomknoepfe({required this.beiNaeher, required this.beiWeiter});

  @override
  Widget build(BuildContext context) {
    final t = AppTexte.of(context);
    return Material(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Knopf(
              symbol: Icons.add,
              hinweis: t.karteHineinzoomen,
              beiDruck: beiNaeher),
          _Knopf(
              symbol: Icons.remove,
              hinweis: t.karteHerauszoomen,
              beiDruck: beiWeiter),
        ],
      ),
    );
  }
}

class _Knopf extends StatelessWidget {
  final IconData symbol;
  final String hinweis;
  final VoidCallback beiDruck;

  const _Knopf(
      {required this.symbol, required this.hinweis, required this.beiDruck});

  @override
  Widget build(BuildContext context) => Tooltip(
        message: hinweis,
        child: InkWell(
          onTap: beiDruck,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(symbol,
                size: 18, color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
      );
}
