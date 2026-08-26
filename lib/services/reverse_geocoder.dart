import 'dart:io';
import 'dart:math' as math;

import 'laenderkatalog.dart';

/// Ergebnis einer Umkehr-Geokodierung: die nächstgelegene bekannte Stadt
/// sowie deren Land/Bundesland (soweit auflösbar). [city] ist immer gesetzt,
/// sobald [ReverseGeocoder.lookup] überhaupt ein Ergebnis liefert –
/// [country]/[state] können fehlen, falls der jeweilige Code im
/// GeoNames-Datensatz nicht auflösbar ist.
class GeoLookupResult {
  final String? country;
  final String? state;
  final String city;
  const GeoLookupResult({this.country, this.state, required this.city});
}

class _GeoCity {
  final String name;

  /// Derselbe Name ohne diakritische Zeichen, wie GeoNames ihn mitliefert
  /// („Zurich" zu „Zürich"). Damit findet auch, wer ohne Sonderzeichen
  /// tippt. **Keine Umschrift:** GeoNames macht aus „ü" ein „u", nicht
  /// „ue" – „Muenchen" führt deshalb zu keinem Treffer.
  final String asciiName;

  final double lat;
  final double lon;
  final String countryCode;
  final String admin1Code;

  /// Einwohnerzahl. Nur für die Vorwärtssuche: Wer „Berlin" eingibt und
  /// keinen weiteren Anhaltspunkt gibt, meint fast immer das grosse.
  final int einwohner;

  const _GeoCity(this.name, this.asciiName, this.lat, this.lon,
      this.countryCode, this.admin1Code, this.einwohner);
}

/// Ein über seinen Namen gefundener Ort.
///
/// [weitere] ist der eigentliche Grund für eine eigene Klasse: Die Suche
/// muss sagen dürfen, dass sie sich entschieden **hat**. „Springfield"
/// gibt es in den USA über zwanzig Mal; eine Koordinate ohne diesen
/// Hinweis sähe aus wie eine Tatsache.
class OrtsTreffer {
  final String name;
  final double breite;
  final double laenge;

  /// Ausgeschriebener Ländername, soweit auflösbar.
  final String? land;

  /// Wie viele gleichnamige Orte es ausserdem gab.
  final int weitere;

  const OrtsTreffer({
    required this.name,
    required this.breite,
    required this.laenge,
    this.land,
    this.weitere = 0,
  });

  /// Ob die Angabe mehrdeutig war und die Auswahl damit eine Vermutung ist.
  bool get mehrdeutig => weitere > 0;
}

/// Lokale/offline Umkehr-Geokodierung auf Basis eines GeoNames-Auszugs (siehe
/// GeoDataCatalog/GeoDataDownloadService) – ordnet GPS-Koordinaten der
/// nächstgelegenen bekannten Stadt zu ("Nächster-Punkt"-Näherung, keine
/// echte Gemeindegrenzen-Prüfung; dieselbe Vereinfachung, die auch andere
/// offline Reverse-Geocoder verwenden). Läuft komplett ohne Netzwerkzugriff,
/// sobald der Datensatz einmal heruntergeladen ist.
///
/// Für schnelle Nachbarschaftssuche werden die Städte einmalig in ein Grob-
/// Gitter (1°-Zellen) einsortiert – bei ca. 150.000 Städten weltweit macht
/// das eine lineare Suche über alle Punkte pro Foto unnötig.
class ReverseGeocoder {
  ReverseGeocoder._(this._cities, this.laenderkatalog, this._admin1Names)
      : _countryNames = {
          for (final l in laenderkatalog.laender) l.iso: l.name,
        },
        isoNachName = {
          for (final l in laenderkatalog.laender) l.name: l.iso,
        } {
    for (final e in _admin1Names.entries) {
      final punkt = e.key.indexOf('.');
      if (punkt <= 0) continue;
      regionscodes['${e.key.substring(0, punkt)}|${e.value}'] = e.key;
    }
    for (var i = 0; i < _cities.length; i++) {
      final key = _cellKey(_cities[i].lat.floor(), _cities[i].lon.floor());
      _grid.putIfAbsent(key, () => []).add(i);
    }
  }

  final List<_GeoCity> _cities;

  /// Alle Länder samt Hauptstadt, Erdteil und Regionenzahl.
  final Laenderkatalog laenderkatalog;

  final Map<String, String> _countryNames; // ISO-Code -> Ländername

  /// Die Gegenrichtung: „Germany" -> „DE".
  ///
  /// Die Fotos tragen den **Namen** des Landes, der Katalog rechnet mit
  /// dem Code. Beide stammen aus derselben Datei, der Name trifft also
  /// immer – eine gepflegte zweite Liste wäre hier eine zweite Wahrheit.
  final Map<String, String> isoNachName;

  /// „DE|Hamburg" -> „DE.04".
  ///
  /// Damit ein von Hand gesetzter Haken auf einer Region und ein Foto aus
  /// derselben Region **eine** Region sind und nicht zwei.
  final Map<String, String> regionscodes = {};

  final Map<String, String> _admin1Names; // "US.CA" -> "California"
  final Map<int, List<int>> _grid = {};

  /// Alle Länder und Gebiete, die der Datensatz kennt – ISO-Code auf
  /// Namen.
  ///
  /// Für den Reisefortschritt. **Es sind 252 und nicht 195:**
  /// `countryInfo.txt` führt neben den souveränen Staaten auch Gebiete,
  /// Überseedepartements und die Antarktis-Sektoren. Eine gepflegte Liste
  /// der 195 wäre eine zweite Wahrheit neben dem Datensatz, nach dem die
  /// Fotos tatsächlich eingeordnet werden – und die erste Aufnahme aus
  /// Grönland oder Puerto Rico fiele dann durch.
  Map<String, String> get laenderverzeichnis =>
      Map.unmodifiable(_countryNames);

  /// Ein Punkt auf der Karte für ein Land, eine Region oder einen Ort.
  ///
  /// **Aus demselben Datensatz und nicht aus einer zweiten Datei.** Die
  /// Weltkarte soll ein Land dort anzeigen, wo die Fotos es verorten
  /// würden – ein zweiter Satz Mittelpunkte könnte davon abweichen, und
  /// dann stünde die Marke woanders als das Bild.
  ///
  /// Für ein Land ist das die **Hauptstadt**, sonst der einwohnerstärkste
  /// bekannte Ort. Ein Flächenschwerpunkt wäre ehrlicher gemeint und in
  /// der Anschauung schlechter: Bei Norwegen läge er auf einem Berg, bei
  /// Indonesien im Meer.
  ({double breite, double laenge})? landpunkt(String iso) =>
      _punkte(_landpunkte, iso.toUpperCase());

  /// Für eine Region („DE.02") der einwohnerstärkste bekannte Ort darin.
  ({double breite, double laenge})? regionspunkt(String code) =>
      _punkte(_regionspunkte, code);

  /// Für einen Ort seine eigene Koordinate.
  ({double breite, double laenge})? ortspunkt(String iso, String name) =>
      _punkte(_ortspunkte, '${iso.toUpperCase()}|$name');

  ({double breite, double laenge})? _punkte(
      Map<String, int> index, String schluessel) {
    _bauePunkte();
    final i = index[schluessel];
    return i == null ? null : (breite: _cities[i].lat, laenge: _cities[i].lon);
  }

  final Map<String, int> _landpunkte = {};
  final Map<String, int> _regionspunkte = {};
  final Map<String, int> _ortspunkte = {};
  bool _punkteGebaut = false;

  /// Einmalig über alle Städte, nicht je Abfrage.
  ///
  /// Gemessen an 150.000 Städten liefe eine Suche je Land 252 Mal über die
  /// ganze Liste. Einmal darüber und dabei alle drei Karten füllen kostet
  /// einen Durchgang.
  void _bauePunkte() {
    if (_punkteGebaut) return;
    _punkteGebaut = true;
    final hauptstaedte = {
      for (final l in laenderkatalog.laender)
        if (l.hauptstadt case final h?) '${l.iso}|$h': true,
    };
    final besteEinwohner = <String, int>{};
    for (var i = 0; i < _cities.length; i++) {
      final c = _cities[i];
      final landSchluessel = c.countryCode;

      // Die Hauptstadt schlägt jede Einwohnerzahl – sonst gewönne bei den
      // USA New York gegen Washington.
      final istHauptstadt = hauptstaedte.containsKey('$landSchluessel|${c.name}') ||
          hauptstaedte.containsKey('$landSchluessel|${c.asciiName}');
      final gewicht = istHauptstadt ? 1 << 40 : c.einwohner;
      if (gewicht > (besteEinwohner[landSchluessel] ?? -1)) {
        besteEinwohner[landSchluessel] = gewicht;
        _landpunkte[landSchluessel] = i;
      }

      if (c.admin1Code.isNotEmpty) {
        final r = '$landSchluessel.${c.admin1Code}';
        if (c.einwohner > (besteEinwohner[r] ?? -1)) {
          besteEinwohner[r] = c.einwohner;
          _regionspunkte[r] = i;
        }
      }

      for (final name in {c.name, c.asciiName}) {
        final o = '$landSchluessel|$name';
        if (c.einwohner > (besteEinwohner[o] ?? -1)) {
          besteEinwohner[o] = c.einwohner;
          _ortspunkte[o] = i;
        }
      }
    }
  }

  static const _maxRadiusDegrees = 30;

  static Future<ReverseGeocoder> loadFromFiles({
    required File citiesFile,
    required File admin1File,
    required File countryFile,
  }) async {
    final countryZeilen = await countryFile.readAsLines();
    final admin1Zeilen = await admin1File.readAsLines();
    final katalog = Laenderkatalog.aus(
      countryInfoZeilen: countryZeilen,
      admin1Zeilen: admin1Zeilen,
    );
    final admin1Names = _admin1AusZeilen(admin1Zeilen);
    final cities = await _parseCities(citiesFile);
    return ReverseGeocoder._(cities, katalog, admin1Names);
  }

  /// Liefert die nächstgelegene bekannte Stadt zu den übergebenen
  /// Koordinaten, oder `null`, wenn im Umkreis von [_maxRadiusDegrees] Grad
  /// (~3300 km) keine Stadt bekannt ist (z.B. offene See).
  GeoLookupResult? lookup(double lat, double lon) {
    if (_cities.isEmpty) return null;
    final latCell = lat.floor();
    final lonCell = lon.floor();

    var radius = 1;
    var found = _collectBox(latCell, lonCell, radius);
    while (found.isEmpty && radius <= _maxRadiusDegrees) {
      radius *= 2;
      found = _collectBox(latCell, lonCell, radius);
    }
    if (found.isEmpty) return null;

    // Sicherheitsspanne: eine größere Box erneut prüfen, falls ein näherer
    // Punkt knapp außerhalb der Box liegt, in der der erste Treffer gefunden
    // wurde (die Box ist quadratisch, der gesuchte Radius aber kreisförmig).
    final safetyRadius = math.min(radius * 2, _maxRadiusDegrees);
    final candidates = safetyRadius > radius ? _collectBox(latCell, lonCell, safetyRadius) : found;

    var bestIndex = candidates.first;
    var bestDistanceKm = haversineKm(lat, lon, _cities[bestIndex].lat, _cities[bestIndex].lon);
    for (final index in candidates.skip(1)) {
      final distanceKm = haversineKm(lat, lon, _cities[index].lat, _cities[index].lon);
      if (distanceKm < bestDistanceKm) {
        bestDistanceKm = distanceKm;
        bestIndex = index;
      }
    }

    final city = _cities[bestIndex];
    final admin1Key = '${city.countryCode}.${city.admin1Code}';
    return GeoLookupResult(
      country: _countryNames[city.countryCode],
      state: city.admin1Code.isEmpty ? null : _admin1Names[admin1Key],
      city: city.name,
    );
  }

  List<int> _collectBox(int latCell, int lonCell, int radius) {
    final result = <int>[];
    for (var dLat = -radius; dLat <= radius; dLat++) {
      for (var dLon = -radius; dLon <= radius; dLon++) {
        final indices = _grid[_cellKey(latCell + dLat, lonCell + dLon)];
        if (indices != null) result.addAll(indices);
      }
    }
    return result;
  }

  static int _cellKey(int latCell, int lonCell) => (latCell + 90) * 512 + (lonCell + 180);

  // ---------------------------------------------------------------------
  // Vorwärtssuche: Name -> Koordinate
  // ---------------------------------------------------------------------

  /// Name (kleingeschrieben) -> Zeilen in [_cities].
  ///
  /// Erst beim ersten Gebrauch aufgebaut, nicht im Konstruktor: Der
  /// Datensatz hat rund 150.000 Einträge, und wer keine Lebensereignisse
  /// führt, braucht diese Karte nie.
  Map<String, List<int>>? _namensIndex;

  Map<String, List<int>> get _index {
    final vorhanden = _namensIndex;
    if (vorhanden != null) return vorhanden;
    final neu = <String, List<int>>{};
    for (var i = 0; i < _cities.length; i++) {
      final stadt = _cities[i];
      for (final name in {_normalisiere(stadt.name), _normalisiere(stadt.asciiName)}) {
        if (name.isEmpty) continue;
        neu.putIfAbsent(name, () => []).add(i);
      }
    }
    return _namensIndex = neu;
  }

  static String _normalisiere(String text) => text.trim().toLowerCase();

  /// Sucht einen Ort über seinen Namen.
  ///
  /// Das Gegenstück zu [lookup] und die Grundlage dafür, dass
  /// Lebensereignisse überhaupt auf einer Karte landen können: Sie führen
  /// ihren Ort als **Text**, nicht als Koordinate.
  ///
  /// [eingabe] darf mehrteilig sein – „Paris, Frankreich" oder
  /// „Springfield, Illinois". Der erste Teil ist der Ortsname, alles
  /// dahinter engt auf Land oder Region ein. Genau das ist der
  /// Unterschied zwischen Paris in Frankreich und Paris in Texas.
  ///
  /// Bleibt die Angabe mehrdeutig, entscheidet in dieser Reihenfolge:
  /// 1. der Ort, der [naheBreite]/[naheLaenge] am nächsten liegt – dafür
  ///    übergibt der Aufrufer den Schwerpunkt der verorteten Fotos;
  /// 2. sonst der mit den meisten Einwohnern.
  ///
  /// Beides sind Vermutungen, und [OrtsTreffer.mehrdeutig] sagt es auch.
  /// Ein unbekannter Name liefert `null` statt eines geratenen Punktes.
  OrtsTreffer? sucheOrt(
    String eingabe, {
    double? naheBreite,
    double? naheLaenge,
  }) {
    final teile = eingabe.split(',').map((t) => t.trim()).toList();
    if (teile.isEmpty) return null;
    final ortsname = _normalisiere(teile.first);
    if (ortsname.isEmpty) return null;

    final zeilen = _index[ortsname];
    if (zeilen == null || zeilen.isEmpty) return null;

    // Die Zusätze hinter dem Komma gegen Land und Region prüfen.
    final zusaetze = [
      for (final t in teile.skip(1))
        if (t.isNotEmpty) _normalisiere(t)
    ];
    var kandidaten = zeilen;
    if (zusaetze.isNotEmpty) {
      final gefiltert = [
        for (final i in zeilen)
          if (_passtZuZusatz(_cities[i], zusaetze)) i
      ];
      // Passt kein einziger, gilt der Zusatz als unbrauchbar statt als
      // Ausschluss – „Berlin, Heimat" darf nicht zu „nicht gefunden"
      // führen.
      if (gefiltert.isNotEmpty) kandidaten = gefiltert;
    }

    final besteZeile = _besterKandidat(kandidaten, naheBreite, naheLaenge);
    final stadt = _cities[besteZeile];
    return OrtsTreffer(
      name: stadt.name,
      breite: stadt.lat,
      laenge: stadt.lon,
      land: _countryNames[stadt.countryCode],
      weitere: kandidaten.length - 1,
    );
  }

  bool _passtZuZusatz(_GeoCity stadt, List<String> zusaetze) {
    final land = _normalisiere(_countryNames[stadt.countryCode] ?? '');
    final landCode = _normalisiere(stadt.countryCode);
    final region = _normalisiere(
        _admin1Names['${stadt.countryCode}.${stadt.admin1Code}'] ?? '');
    for (final z in zusaetze) {
      if (z == landCode || (land.isNotEmpty && land == z)) return true;
      if (region.isNotEmpty && region == z) return true;
    }
    return false;
  }

  int _besterKandidat(List<int> zeilen, double? breite, double? laenge) {
    if (zeilen.length == 1) return zeilen.first;
    if (breite != null && laenge != null) {
      var beste = zeilen.first;
      var besteEntfernung =
          haversineKm(breite, laenge, _cities[beste].lat, _cities[beste].lon);
      for (final i in zeilen.skip(1)) {
        final entfernung =
            haversineKm(breite, laenge, _cities[i].lat, _cities[i].lon);
        if (entfernung < besteEntfernung) {
          beste = i;
          besteEntfernung = entfernung;
        }
      }
      return beste;
    }
    var beste = zeilen.first;
    for (final i in zeilen.skip(1)) {
      if (_cities[i].einwohner > _cities[beste].einwohner) beste = i;
    }
    return beste;
  }

  /// Distanz zweier Koordinaten in km – öffentlich, weil auch das
  /// Automatisierungs-Regelwerk (siehe LibraryState.applyAutomationRules)
  /// eine Umkreis-Bedingung damit auswertet, nicht nur die Umkehr-
  /// Geokodierung hier.
  static double haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) * math.cos(_degToRad(lat2)) * math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _degToRad(double deg) => deg * math.pi / 180;

  /// `admin1CodesASCII.txt`: Spalte 0 = Code (z.B. "US.CA"), Spalte 1 = Name.
  ///
  /// Die Ländernamen kommen nicht mehr von hier, sondern aus
  /// [Laenderkatalog] – dieselbe Datei, aber vollständig gelesen statt nur
  /// eine Spalte davon.
  static Map<String, String> _admin1AusZeilen(List<String> lines) {
    final map = <String, String>{};
    for (final line in lines) {
      if (line.isEmpty) continue;
      final cols = line.split('\t');
      if (cols.length < 2) continue;
      map[cols[0]] = cols[1];
    }
    return map;
  }

  /// `cities1000.txt`: Spalte 1 = Name, 2 = Name ohne diakritische
  /// Zeichen, 4 = Breitengrad, 5 = Längengrad, 8 = Länder-Code,
  /// 10 = Bundesland-/Provinz-Code (kann leer sein), 14 = Einwohnerzahl.
  static Future<List<_GeoCity>> _parseCities(File file) async {
    final lines = await file.readAsLines();
    final result = <_GeoCity>[];
    for (final line in lines) {
      if (line.isEmpty) continue;
      final cols = line.split('\t');
      if (cols.length < 11) continue;
      final lat = double.tryParse(cols[4]);
      final lon = double.tryParse(cols[5]);
      if (lat == null || lon == null) continue;
      // Einwohnerzahl fehlt in manchen Zeilen; 0 ist dann die ehrliche
      // Angabe – der Ort verliert damit nur bei Gleichstand.
      final einwohner =
          cols.length > 14 ? (int.tryParse(cols[14]) ?? 0) : 0;
      result.add(_GeoCity(
          cols[1], cols[2], lat, lon, cols[8], cols[10], einwohner));
    }
    return result;
  }
}
