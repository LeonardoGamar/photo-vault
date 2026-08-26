/// Das Verzeichnis aller Länder – Name, Hauptstadt, Erdteil, Regionen.
///
/// Bisher wurde aus `countryInfo.txt` nur eine einzige Spalte gelesen: der
/// Ländername. Die Datei liegt aber vollständig auf der Platte und führt
/// neunzehn Spalten, darunter **Hauptstadt und Erdteil**. Und
/// `admin1CodesASCII.txt` weiß, aus wie vielen Regionen ein Land besteht –
/// die Zahl, gegen die sich „3 von 16 Bundesländern" überhaupt erst
/// zählen lässt.
///
/// Rein und ohne Dateizugriff: Die Zerlegung bekommt Zeilen, keine
/// Pfade. Nur so lässt sich nachrechnen, was am fertigen Balken niemand
/// mehr sieht.
library;

/// Ein Land, wie der Datensatz es kennt.
typedef Landeintragung = ({
  /// Zweibuchstabiger Code, „DE".
  String iso,

  /// Ausgeschriebener Name, wie GeoNames ihn führt – **englisch**.
  String name,

  /// Hauptstadt, soweit die Datei eine nennt.
  String? hauptstadt,

  /// Erdteilkürzel: EU, AS, NA, SA, AF, OC, AN.
  String kontinent,

  /// Wie viele Regionen (Bundesländer, Provinzen …) das Land hat.
  ///
  /// **Kann 0 sein.** Kleinstaaten wie Monaco und der Vatikan haben in
  /// `admin1CodesASCII.txt` keinen einzigen Eintrag. Ein Fortschritt „x
  /// von 0" wäre eine Division durch nichts – wer damit rechnet, muss
  /// den Fall vorher abfangen.
  int regionen,
});

/// Alle Länder, nach Namen sortiert.
class Laenderkatalog {
  final List<Landeintragung> laender;
  final Map<String, Landeintragung> _nachIso;

  Laenderkatalog._(this.laender, this._nachIso);

  int get anzahl => laender.length;

  Landeintragung? nachIso(String iso) => _nachIso[iso.toUpperCase()];

  /// Baut den Katalog aus den Zeilen beider Dateien.
  ///
  /// [admin1Zeilen] darf leer sein – dann hat jedes Land 0 Regionen und
  /// die Ansicht zeigt eben keinen Regionenfortschritt. Das ist besser
  /// als gar kein Katalog: Die Länderliste selbst hängt nicht daran.
  factory Laenderkatalog.aus({
    required Iterable<String> countryInfoZeilen,
    required Iterable<String> admin1Zeilen,
  }) {
    // Regionen je Land zählen. Der Code steht als „DE.02" vorn; alles vor
    // dem ersten Punkt ist das Land.
    final regionen = <String, int>{};
    for (final zeile in admin1Zeilen) {
      if (zeile.isEmpty) continue;
      final punkt = zeile.indexOf('.');
      if (punkt <= 0) continue;
      final land = zeile.substring(0, punkt);
      // Nicht auf den Tabulator warten: Eine kaputte Zeile ohne Namen
      // zählt trotzdem als vorhandene Region, und die Zahl soll die des
      // Datensatzes sein und nicht die der wohlgeformten Zeilen.
      regionen[land] = (regionen[land] ?? 0) + 1;
    }

    final liste = <Landeintragung>[];
    final nachIso = <String, Landeintragung>{};
    for (final zeile in countryInfoZeilen) {
      if (zeile.isEmpty || zeile.startsWith('#')) continue;
      final s = zeile.split('\t');
      // Spalte 0 ISO, 4 Name, 5 Hauptstadt, 8 Erdteil.
      if (s.length < 9) continue;
      final iso = s[0].trim();
      final name = s[4].trim();
      if (iso.isEmpty || name.isEmpty) continue;
      final hauptstadt = s[5].trim();
      final eintrag = (
        iso: iso,
        name: name,
        hauptstadt: hauptstadt.isEmpty ? null : hauptstadt,
        kontinent: s[8].trim(),
        regionen: regionen[iso] ?? 0,
      );
      if (nachIso.containsKey(iso)) continue;
      nachIso[iso] = eintrag;
      liste.add(eintrag);
    }
    liste.sort((a, b) => a.name.compareTo(b.name));
    return Laenderkatalog._(List.unmodifiable(liste), nachIso);
  }
}

/// Die Flagge zum Ländercode, als Emoji.
///
/// Zwei Buchstaben, je 127397 hochgezählt, ergeben die beiden regionalen
/// Anzeigezeichen – aus „DE" wird 🇩🇪. **Keine einzige Bilddatei**: 252
/// Flaggen als Grafik wären mehrere Megabyte im Paket, und sie müssten
/// gepflegt werden, sobald sich eine ändert.
///
/// Gibt `null` zurück, wenn der Code keine zwei Buchstaben hat. Der Aufrufer
/// zeigt dann nichts an statt zweier leerer Kästchen.
String? flaggeAus(String iso) {
  if (iso.length != 2) return null;
  final gross = iso.toUpperCase();
  final a = gross.codeUnitAt(0);
  final b = gross.codeUnitAt(1);
  if (a < 0x41 || a > 0x5A || b < 0x41 || b > 0x5A) return null;
  return String.fromCharCodes([a + 127397, b + 127397]);
}
