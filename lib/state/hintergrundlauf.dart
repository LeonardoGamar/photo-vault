import 'dart:async';

import '../l10n/app_localizations.dart';

/// Ein Nachholvorgang, der wirklich im Hintergrund läuft.
///
/// Bis hierher öffnete jede Aufgabe der Übersicht ein Fortschrittsfenster,
/// das den Bildschirm sperrte und sich nicht wegklicken liess – „im
/// Hintergrund" war daran nur der Name. Ein solcher Lauf hängt jetzt an
/// [LibraryState] statt am Bildschirm: Er überlebt das Wegnavigieren, und
/// mehrere Bildschirme können denselben Zustand anzeigen.
///
/// Bewusst veränderlich statt als unveränderliches Abbild je Ereignis: Ein
/// Lauf über 8000 Fotos meldet 8000 Fortschritte; jedes Mal ein neues Objekt
/// samt Karte anzulegen wäre reine Müllproduktion. Die Oberfläche liest die
/// Felder ohnehin erst im nächsten Aufbau.
class Hintergrundlauf {
  Hintergrundlauf({
    required this.schluessel,
    required this.titel,
    required this.leermeldung,
    this.rechenintensiv = false,
  });

  /// Identifiziert die Aufgabe – dieselbe Kennung wie die Karte, die sie
  /// anzeigt. Verhindert zugleich, dass dieselbe Arbeit zweimal parallel
  /// startet.
  final String schluessel;

  /// Was gerade getan wird, in der Sprache der Oberfläche (z.B.
  /// „Bildbeschreibungen werden erzeugt").
  final String titel;

  /// Was statt „0 / 0" dasteht, wenn es nichts nachzuholen gab („Alle Fotos
  /// sind bereits durchsucht.").
  ///
  /// Am Lauf und nicht am Bildschirm: Der Lauf überlebt das Wegnavigieren,
  /// der Bildschirmzustand nicht – bei der Rückkehr wüsste sonst niemand
  /// mehr, welche der beiden Aktionen einer Karte gestartet wurde.
  final String leermeldung;

  /// Ob dieser Lauf zu den teuren Auswertungen gehört – entweder weil er
  /// ein KI-Modell in den Speicher holt oder weil die Hintergrundanalyse
  /// dieselbe Arbeit als eine ihrer Stufen erledigt. Nur solche Läufe
  /// schliessen sich gegenseitig aus (siehe `LibraryState.pruefeStart`).
  final bool rechenintensiv;

  int erledigt = 0;
  int gesamt = 0;
  String? datei;

  /// Gesetzt, sobald der Strom durch ist – gleich ob erfolgreich,
  /// abgebrochen oder mit Fehler. Der Eintrag bleibt danach stehen, damit
  /// das Ergebnis sichtbar wird; er verschwindet erst, wenn ihn jemand
  /// wegräumt (siehe `LibraryState.verwerfeLauf`).
  bool beendet = false;
  bool abgebrochen = false;
  Object? fehler;

  /// Das Abonnement des zugrunde liegenden `Stream<ImportProgress>`.
  ///
  /// Abbrechen heisst hier: das Abonnement kündigen. Ein `async*`-Generator
  /// hält dann bei seinem nächsten `yield` an und durchläuft seine
  /// `finally`-Blöcke – genau dort geben die Nachholvorgänge ihre geliehenen
  /// Modelle zurück. Ein Abbruchsschalter, den jede Schleife selbst abfragen
  /// müsste, wäre an jeder der 20 Stellen einzeln zu pflegen.
  StreamSubscription<Object?>? abo;

  final Completer<void> _abschluss = Completer<void>();

  /// Wird erfüllt, sobald der Lauf endet – auf welchem Weg auch immer.
  ///
  /// Braucht es, weil ein gekündigtes Abonnement KEIN `onDone` mehr meldet:
  /// Ohne diesen gemeinsamen Endpunkt würde `LibraryState.starteAufgabe`
  /// nach einem Abbruch für immer auf ein Ereignis warten, das nicht mehr
  /// kommt.
  Future<void> get abschluss => _abschluss.future;

  /// Meldet das Ende. Mehrfaches Aufrufen ist erlaubt und folgenlos – Fehler
  /// und Abbruch können zeitlich zusammenfallen.
  void schliesseAb() {
    if (!_abschluss.isCompleted) _abschluss.complete();
  }

  bool get laeuft => !beendet;

  /// Anteil 0..1, oder `null` solange die Gesamtzahl noch nicht feststeht –
  /// dann zeigt die Oberfläche einen unbestimmten Balken statt eines
  /// Balkens, der bei 0 klebt.
  double? get anteil {
    if (gesamt <= 0) return null;
    return (erledigt / gesamt).clamp(0.0, 1.0);
  }
}

/// Warum eine Aufgabe gerade nicht starten kann.
///
/// Eine Aufzählung statt eines fertigen Satzes: Dieser Zustand kennt keine
/// Oberflächensprache, und derselbe Grund wird an zwei Stellen angezeigt
/// (Aufgabenübersicht und Werkzeuge).
enum Startabweisung {
  /// Genau diese Arbeit läuft schon.
  laeuftBereits,

  /// Eine andere rechenintensive Aufgabe belegt gerade den Speicher.
  andereAufgabe,

  /// Die Hintergrundanalyse arbeitet dieselben Stufen ab.
  analyseLaeuft,
}

/// Der Grund als Satz in der Oberflächensprache.
///
/// Dasselbe Muster wie `analysestufeName`: Die Aufzählung bleibt sprachfrei,
/// die Zuordnung steht hier. Beide Einstiegspunkte (Aufgabenübersicht und
/// Werkzeuge) greifen darauf zu, damit derselbe Grund nicht zweimal
/// unterschiedlich formuliert wird.
String abweisungstext(AppTexte t, Startabweisung grund) => switch (grund) {
      Startabweisung.laeuftBereits => t.aufgLaeuftSchon,
      Startabweisung.andereAufgabe => t.aufgAndereLaeuft,
      Startabweisung.analyseLaeuft => t.aufgAnalyseLaeuft,
    };
