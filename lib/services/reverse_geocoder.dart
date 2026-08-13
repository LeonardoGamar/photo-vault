import 'dart:io';
import 'dart:math' as math;

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
  final double lat;
  final double lon;
  final String countryCode;
  final String admin1Code;
  const _GeoCity(this.name, this.lat, this.lon, this.countryCode, this.admin1Code);
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
  ReverseGeocoder._(this._cities, this._countryNames, this._admin1Names) {
    for (var i = 0; i < _cities.length; i++) {
      final key = _cellKey(_cities[i].lat.floor(), _cities[i].lon.floor());
      _grid.putIfAbsent(key, () => []).add(i);
    }
  }

  final List<_GeoCity> _cities;
  final Map<String, String> _countryNames; // ISO-Code -> Ländername
  final Map<String, String> _admin1Names; // "US.CA" -> "California"
  final Map<int, List<int>> _grid = {};

  static const _maxRadiusDegrees = 30;

  static Future<ReverseGeocoder> loadFromFiles({
    required File citiesFile,
    required File admin1File,
    required File countryFile,
  }) async {
    final countryNames = await _parseCountryInfo(countryFile);
    final admin1Names = await _parseAdmin1Codes(admin1File);
    final cities = await _parseCities(citiesFile);
    return ReverseGeocoder._(cities, countryNames, admin1Names);
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
    var bestDistanceKm = _haversineKm(lat, lon, _cities[bestIndex].lat, _cities[bestIndex].lon);
    for (final index in candidates.skip(1)) {
      final distanceKm = _haversineKm(lat, lon, _cities[index].lat, _cities[index].lon);
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

  static double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) * math.cos(_degToRad(lat2)) * math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _degToRad(double deg) => deg * math.pi / 180;

  /// `countryInfo.txt`: Kommentarzeilen beginnen mit "#", Spalte 0 = ISO-Code,
  /// Spalte 4 = Ländername.
  static Future<Map<String, String>> _parseCountryInfo(File file) async {
    final lines = await file.readAsLines();
    final map = <String, String>{};
    for (final line in lines) {
      if (line.isEmpty || line.startsWith('#')) continue;
      final cols = line.split('\t');
      if (cols.length < 5) continue;
      map[cols[0]] = cols[4];
    }
    return map;
  }

  /// `admin1CodesASCII.txt`: Spalte 0 = Code (z.B. "US.CA"), Spalte 1 = Name.
  static Future<Map<String, String>> _parseAdmin1Codes(File file) async {
    final lines = await file.readAsLines();
    final map = <String, String>{};
    for (final line in lines) {
      if (line.isEmpty) continue;
      final cols = line.split('\t');
      if (cols.length < 2) continue;
      map[cols[0]] = cols[1];
    }
    return map;
  }

  /// `cities1000.txt`: Spalte 1 = Name, 4 = Breitengrad, 5 = Längengrad,
  /// 8 = Länder-Code, 10 = Bundesland-/Provinz-Code (kann leer sein).
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
      result.add(_GeoCity(cols[1], lat, lon, cols[8], cols[10]));
    }
    return result;
  }
}
