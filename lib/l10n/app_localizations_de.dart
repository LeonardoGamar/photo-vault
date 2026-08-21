// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppTexteDe extends AppTexte {
  AppTexteDe([String locale = 'de']) : super(locale);

  @override
  String get allgAbbrechen => 'Abbrechen';

  @override
  String get allgSpeichern => 'Speichern';

  @override
  String get allgSchliessen => 'Schließen';

  @override
  String get allgErstellen => 'Erstellen';

  @override
  String get allgStarten => 'Starten';

  @override
  String get allgName => 'Name';

  @override
  String get allgMehr => 'Mehr';

  @override
  String get allgAlleAnzeigen => 'Alle anzeigen';

  @override
  String get navTimeline => 'Timeline';

  @override
  String get navErkunden => 'Erkunden';

  @override
  String get navKalender => 'Kalender';

  @override
  String get navKarte => 'Karte';

  @override
  String get navSuche => 'Suche';

  @override
  String get navPersonen => 'Personen';

  @override
  String get navAlben => 'Alben';

  @override
  String get navWerkzeuge => 'Werkzeuge';

  @override
  String get navEinstellungen => 'Einstellungen';

  @override
  String get importierenTooltip => 'Fotos/Videos importieren';

  @override
  String geoeffneteBibliothek(String name) {
    return 'Geöffnete Bibliothek: $name';
  }

  @override
  String restaurierungLaeuft(int fertig, int gesamt) {
    return 'KI-Restaurierung läuft – Kachel $fertig/$gesamt';
  }

  @override
  String restaurierungLaeuftMitWarteschlange(
      int fertig, int gesamt, int wartend) {
    return 'KI-Restaurierung läuft – Kachel $fertig/$gesamt · $wartend in Warteschlange';
  }

  @override
  String get restaurierungWirdVorbereitet =>
      'KI-Restaurierung wird vorbereitet …';

  @override
  String restaurierungWartend(int anzahl) {
    String _temp0 = intl.Intl.pluralLogic(
      anzahl,
      locale: localeName,
      other: '$anzahl Fotos in der Warteschlange für die KI-Restaurierung',
      one: '1 Foto in der Warteschlange für die KI-Restaurierung',
    );
    return '$_temp0';
  }

  @override
  String analyseLaeuft(
      String stufe, int nummer, int gesamt, String fortschritt) {
    return '$stufe wird berechnet (Schritt $nummer von $gesamt$fortschritt)';
  }

  @override
  String get kuerzelTitel => 'Tastaturkürzel';

  @override
  String get kuerzelNavigation => 'Navigation';

  @override
  String get kuerzelVollbild => 'Vollbildansicht';

  @override
  String get kuerzelSichtung => 'Sichtungs-Modus (Culling)';

  @override
  String get kuerzelBereicheWechseln => 'Zwischen den Hauptbereichen wechseln';

  @override
  String get kuerzelUebersichtOeffnen => 'Diese Übersicht öffnen';

  @override
  String get kuerzelVorherigesNaechstes => 'Vorheriges / nächstes Foto';

  @override
  String get kuerzelLeertaste => 'Leertaste';

  @override
  String get kuerzelNaechstesFoto => 'Nächstes Foto';

  @override
  String get kuerzelBewertungSetzen => 'Sternebewertung setzen';

  @override
  String get kuerzelFavoritUmschalten => 'Favorit umschalten';

  @override
  String get kuerzelPapierkorbMitBestaetigung =>
      'In den Papierkorb verschieben (mit Bestätigung)';

  @override
  String get kuerzelSofortAblehnen =>
      'Sofort ablehnen und weiter (ohne Bestätigung)';

  @override
  String get timelineLeer => 'Noch keine Fotos in der Bibliothek.';

  @override
  String loeschenTitel(int anzahl) {
    String _temp0 = intl.Intl.pluralLogic(
      anzahl,
      locale: localeName,
      other: '$anzahl Fotos löschen?',
      one: 'Foto löschen?',
    );
    return '$_temp0';
  }

  @override
  String loeschenHinweis(int anzahl) {
    String _temp0 = intl.Intl.pluralLogic(
      anzahl,
      locale: localeName,
      other: 'Diese Fotos werden in den Papierkorb verschoben.',
      one: 'Wird in den Papierkorb verschoben.',
    );
    return '$_temp0';
  }

  @override
  String get albumNeu => 'Neues Album';

  @override
  String get albumName => 'Albumname';

  @override
  String get albenLeer => 'Noch keine Alben vorhanden.';

  @override
  String get erkundenPersonen => 'Personen';

  @override
  String get erkundenOrte => 'Orte';

  @override
  String get erkundenLetzteAlben => 'Zuletzt hinzugefügte Alben';

  @override
  String get erkundenLetzteFotos => 'Zuletzt hinzugefügte Fotos';

  @override
  String get erkundenErinnerungen => 'Erinnerungen';

  @override
  String get ohneOrtLeer => 'Noch keine Fotos mit bekanntem Ort.';

  @override
  String get karteTitel => 'Karte';

  @override
  String get karteAnsicht => 'Kartenansicht';

  @override
  String get karteTexturNachweis =>
      'Erd-/Sternentextur: Solar System Scope (CC BY 4.0)';

  @override
  String get kalenderLeer => 'Noch keine Fotos für eine Jahresübersicht.';

  @override
  String get kalenderJahrLeer => 'Keine Fotos in diesem Jahr.';

  @override
  String kalenderAnzahlFotos(int anzahl) {
    String _temp0 = intl.Intl.pluralLogic(
      anzahl,
      locale: localeName,
      other: '$anzahl Fotos/Videos',
      one: '$anzahl Foto/Video',
    );
    return '$_temp0';
  }

  @override
  String get sucheSpeichernTitel => 'Suche speichern';

  @override
  String get sucheModellFehlt =>
      'Für die Kontext-Suche fehlt das Bildsuche-Modell. Es lässt sich in den Einstellungen unter „KI-Modelle“ laden.';

  @override
  String get sucheModellLaedt => 'Modell für die Bildsuche wird geladen …';

  @override
  String sucheFehlgeschlagen(String fehler) {
    return 'Suche fehlgeschlagen: $fehler';
  }

  @override
  String get suchePlatzhalterKontext =>
      'z.B. „Sonnenuntergang am Meer“, „Hund im Schnee“ …';

  @override
  String get suchePlatzhalterDateiname => 'Dateiname …';

  @override
  String get suchePlatzhalterBeschreibung => 'Beschreibung …';

  @override
  String get suchePlatzhalterText => 'Text im Foto …';

  @override
  String get suchePlatzhalterBildunterschrift => 'z.B. „dog“, „sunset“ …';

  @override
  String get sucheOptionen => 'Suchoptionen';

  @override
  String get sucheAusloesen => 'Suchen';

  @override
  String get sucheAnleitung =>
      'Gib einen Suchbegriff ein oder wähle Suchoptionen.';

  @override
  String get sucheKeineTreffer => 'Keine Treffer.';

  @override
  String get viewerInfo => 'Info';

  @override
  String get viewerTeilen => 'Teilen';

  @override
  String get viewerExportieren => 'Exportieren';

  @override
  String get viewerEntwickeln => 'Entwickeln';

  @override
  String get viewerBearbeiten => 'Bearbeiten';

  @override
  String get viewerZuschneiden => 'Zuschneiden';

  @override
  String get viewerDiaschauStarten => 'Diaschau starten';

  @override
  String get viewerDiaschauStoppen => 'Diaschau stoppen';

  @override
  String get viewerFavoritSetzen => 'Als Favorit markieren (F)';

  @override
  String get viewerFavoritEntfernen => 'Favorit entfernen (F)';

  @override
  String get viewerInGesperrtenOrdner =>
      'In gesperrten Ordner verschieben (verschlüsselt)';

  @override
  String get viewerInPapierkorb => 'In den Papierkorb verschieben (⌫)';

  @override
  String get viewerVorherigesFoto => 'Vorheriges Foto';

  @override
  String get viewerNaechstesFoto => 'Nächstes Foto';

  @override
  String get viewerInTimelineZeigen => 'Foto in der Timeline anzeigen';

  @override
  String get viewerAehnlicheZeigen => 'Ähnliche Bilder anzeigen';

  @override
  String get viewerMetadatenBearbeiten => 'Metadaten bearbeiten';

  @override
  String get viewerGesichterBearbeiten => 'Gesichter bearbeiten';

  @override
  String get viewerEntwicklungAnwenden => 'Kopierte Entwicklung anwenden';

  @override
  String get viewerEntwicklungAnwendenLang =>
      'Kopierte Entwicklung auf dieses Foto anwenden';

  @override
  String get viewerGeschlosseneAugen =>
      'Mindestens ein Gesicht mit geschlossenen Augen erkannt';

  @override
  String get viewerFokusPeaking => 'Fokus-Peaking (scharfe Kanten hervorheben)';

  @override
  String get viewerFlachesSchwenken => 'Flaches Schwenken statt 3D-Kugel';

  @override
  String get viewerFlacheVorschau => 'Flache Vorschau statt 360°-Ansicht';

  @override
  String get viewerExportZielordner => 'Zielordner zum Exportieren wählen';

  @override
  String viewerExportiert(String dateien) {
    return 'Exportiert: $dateien';
  }

  @override
  String viewerExportFehlgeschlagen(String fehler) {
    return 'Export fehlgeschlagen: $fehler';
  }

  @override
  String viewerTeilenFehlgeschlagen(String fehler) {
    return 'Teilen fehlgeschlagen: $fehler';
  }

  @override
  String get personenTab => 'Personen';

  @override
  String get personenUnbenannteTab => 'Unbenannte Gesichter';

  @override
  String get personenLeer =>
      'Noch keine Personen angelegt. Wechsle zum Tab „Unbenannte Gesichter“, wähle ein paar Gesichter aus und ordne sie einer neuen Person zu.';

  @override
  String get personenLangeDruecken => 'lange drücken: zusammenführen';

  @override
  String get personenKeineUnbenannten =>
      'Keine unbenannten Gesichter (mehr). Neue erscheinen hier automatisch, sobald du weitere Fotos importierst oder erneut nach Gesichtern suchst. Einzelne kannst du auch selbst markieren: Foto öffnen, Rechtsklick → „Gesichter bearbeiten“, dann oben rechts auf „Gesicht manuell hinzufügen“.';

  @override
  String get personenSchwellenHinweis =>
      'Ähnlichkeitsschwelle einstellbar unter Werkzeuge → Gesichtserkennung.';

  @override
  String get personenDoppelklickHinweis =>
      'Doppelklick auf ein Gesicht öffnet das ganze Foto zur Kontrolle.';

  @override
  String get personenAutomatischGruppieren => 'Automatisch gruppieren';

  @override
  String get personenAehnlicheAuswaehlen => 'Ähnliche mit auswählen';

  @override
  String get personenAehnlicheAbwaehlen => 'Ähnliche abwählen';

  @override
  String personenZuordnen(int anzahl) {
    String _temp0 = intl.Intl.pluralLogic(
      anzahl,
      locale: localeName,
      other: '$anzahl Gesichter zuordnen',
      one: 'Gesicht zuordnen',
    );
    return '$_temp0';
  }

  @override
  String get personenModellFehlt =>
      'Für die Ähnlichkeitssuche wird das SFace-Modell benötigt (siehe Einstellungen → Modelle).';

  @override
  String personenKeineAehnlichen(String schwelle) {
    return 'Keine ähnlichen Gesichter über der Schwelle $schwelle gefunden.';
  }

  @override
  String get personenZuWenigeFuerClustering =>
      'Nicht genug unbenannte Gesichter mit Embedding für ein Clustering.';

  @override
  String get personenKeineGruppen => 'Keine ähnlichen Gruppen gefunden.';

  @override
  String get personenDauertTitel => 'Das kann etwas dauern';

  @override
  String personenDauertText(int anzahl) {
    return '$anzahl unbenannte Gesichter gefunden. Die automatische Gruppierung vergleicht jedes mit jedem und kann bei so vielen Gesichtern einige Zeit dauern (die App bleibt währenddessen bedienbar). Trotzdem starten?';
  }

  @override
  String personenZusammenfuehrenMit(String name) {
    return '„$name“ zusammenführen mit …';
  }

  @override
  String get personenZusammenfuehrenTitel => 'Zusammenführen bestätigen';

  @override
  String personenZusammenfuehrenText(String quelle, String ziel) {
    return 'Alle Fotos von „$quelle“ werden „$ziel“ zugeordnet. „$quelle“ wird danach gelöscht. Das lässt sich nicht rückgängig machen.';
  }

  @override
  String get personenZusammenfuehren => 'Zusammenführen';

  @override
  String get spracheTitel => 'Sprache';

  @override
  String get spracheSystem => 'Systemsprache';

  @override
  String get spracheDeutsch => 'Deutsch';

  @override
  String get spracheEnglisch => 'English';

  @override
  String get spracheHinweis =>
      'Betrifft nur die Oberfläche. Deine Alben, Schlagwörter und Personennamen bleiben, wie sie sind.';

  @override
  String get spracheVokabularTitel => 'Schlagwort-Vokabular mitübersetzen?';

  @override
  String spracheVokabularText(int bekannt, int gesamt) {
    return '$bekannt der $gesamt Begriffe im Vokabular stammen aus der mitgelieferten Startbestückung und lassen sich zuverlässig übersetzen. Bereits vergebene Schlagwörter wandern mit, es geht nichts verloren.';
  }

  @override
  String spracheVokabularSelbstAngelegt(int anzahl) {
    String _temp0 = intl.Intl.pluralLogic(
      anzahl,
      locale: localeName,
      other: '$anzahl selbst hinzugefügte Begriffe bleiben unverändert.',
      one: 'Ein selbst hinzugefügter Begriff bleibt unverändert.',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get spracheVokabularUebersetzen => 'Übersetzen';

  @override
  String get spracheVokabularBehalten => 'Unverändert lassen';

  @override
  String spracheVokabularFertig(int anzahl) {
    String _temp0 = intl.Intl.pluralLogic(
      anzahl,
      locale: localeName,
      other: '$anzahl Begriffe übersetzt.',
      one: 'Ein Begriff übersetzt.',
    );
    return '$_temp0';
  }

  @override
  String get erkundenKeinePersonen => 'Noch keine Personen benannt.';

  @override
  String get erkundenKeineOrte =>
      'Noch keine Orte aufgelöst (siehe Werkzeuge → Orte).';

  @override
  String get erkundenKeineFotos => 'Noch keine Fotos importiert.';

  @override
  String get karteKeineOrteLang =>
      'Noch keine Fotos mit bekanntem Ort.\n\nDer Ort wird beim Import automatisch aus den GPS-Daten eines Fotos übernommen (falls vorhanden) oder lässt sich in der Info-Ansicht eines Fotos/Videos (Vollbildvorschau → ⓘ) manuell festlegen.';

  @override
  String einstOrdnerNichtGeoeffnet(String pfad) {
    return 'Ordner konnte nicht geöffnet werden: $pfad';
  }

  @override
  String einstBibWechselnTitel(String name) {
    return 'Zu „$name“ wechseln?';
  }

  @override
  String get einstBibWechselnText =>
      'Die App wird danach geschlossen und öffnet beim nächsten Start die gewählte Bibliothek.\n\nEs werden keine Fotos verschoben oder gelöscht – beide Bibliotheken bleiben unverändert an ihrem Ort.';

  @override
  String get einstBibGewechselt =>
      'Die Bibliothek wurde gewechselt. Es wurden keine Daten verschoben. Die App wird jetzt geschlossen – bitte danach manuell neu öffnen.';

  @override
  String get einstBibHinzufuegenAuswahl =>
      'Ordner einer bestehenden Bibliothek wählen – oder einen leeren Ordner für eine neue. Es wird nichts verschoben.';

  @override
  String get einstBibBestehendHinzugefuegt =>
      'Bestehende Bibliothek hinzugefügt.';

  @override
  String get einstBibLeerHinzugefuegt =>
      'Leerer Ordner hinzugefügt – beim Wechseln dorthin entsteht eine neue, leere Bibliothek.';

  @override
  String einstBibEntfernenTitel(String name) {
    return '„$name“ aus der Liste entfernen?';
  }

  @override
  String get einstBibEntfernenText =>
      'Die Bibliothek verschwindet nur aus dieser Liste. Fotos, Datenbank und Ordner bleiben unverändert erhalten und lassen sich jederzeit wieder hinzufügen.';

  @override
  String get einstBibNichtEntfernbar =>
      'Dieser Eintrag lässt sich nicht entfernen.';

  @override
  String get einstBibListe => 'Bibliotheken';

  @override
  String get einstBibHinzufuegen => 'Bibliothek hinzufügen…';

  @override
  String get einstBibAusListeEntfernen =>
      'Aus der Liste entfernen (löscht keine Fotos)';

  @override
  String get einstBibNichtGefunden =>
      'Ordner nicht gefunden – Laufwerk eingebunden?';

  @override
  String get einstBibWechselHinweis =>
      'Ein Wechsel biegt nur um, welche Bibliothek geöffnet wird – es werden keine Fotos verschoben. Zum Verlegen der aktuellen Bibliothek an einen anderen Ort dient „Speicherort ändern\" weiter unten.';

  @override
  String get einstSpeicherortTitel => 'Speicherort der aktiven Bibliothek';

  @override
  String get einstSpeicherortWaehlen =>
      'Fotos, Videos, Thumbnails und die Datenbank werden in diesen Ordner verschoben. Bitte einen bereits vorhandenen Ordner wählen (falls nötig vorher im Finder anlegen).';

  @override
  String get einstSpeicherortZuruecksetzenTitel => 'Speicherort zurücksetzen?';

  @override
  String get einstSpeicherortZuruecksetzenText =>
      'Die Bibliothek wird zurück in den Standard-App-Support-Ordner verschoben. Die App wird danach automatisch geschlossen – bitte anschließend neu öffnen.';

  @override
  String get einstSpeicherortZuruecksetzenLaeuft =>
      'Setze Speicherort zurück …';

  @override
  String get einstSpeicherortGeaendert =>
      'Der Speicherort wurde geändert. Die App wird jetzt geschlossen – bitte danach manuell neu öffnen, damit sie die Bibliothek am neuen Ort lädt.';

  @override
  String get einstImFinderAnzeigen => 'Im Finder anzeigen';

  @override
  String get einstAendern => 'Ändern…';

  @override
  String get einstZuruecksetzen => 'Zurücksetzen';

  @override
  String get einstWirdBerechnet => 'wird berechnet …';

  @override
  String get einstUeberwachtTitel => 'Überwachter Ordner';

  @override
  String get einstUeberwachtKeiner => 'Kein Ordner eingerichtet';

  @override
  String get einstUeberwachtErklaerung =>
      'Was in einem gewählten Ordner auftaucht, wird von selbst in die Bibliothek aufgenommen – alle fünf Minuten und bei jedem Start.';

  @override
  String get einstUeberwachtAktiv =>
      'Wird alle fünf Minuten geprüft. Die Dateien bleiben dort liegen.';

  @override
  String get einstUeberwachtWaehlen => 'Ordner wählen…';

  @override
  String get einstUeberwachtAndererWaehlen => 'Anderen Ordner…';

  @override
  String get einstUeberwachtBeenden => 'Nicht mehr überwachen';

  @override
  String get einstUeberwachtAuswahl =>
      'Ordner wählen, der laufend auf neue Fotos geprüft werden soll. Die Dateien bleiben dort liegen; sie werden nur zusätzlich in die Bibliothek aufgenommen.';

  @override
  String einstUeberwachtUebernommen(int anzahl) {
    String _temp0 = intl.Intl.pluralLogic(
      anzahl,
      locale: localeName,
      other: '$anzahl neue Fotos aus dem Ordner übernommen.',
      one: '1 neues Foto aus dem Ordner übernommen.',
    );
    return '$_temp0';
  }

  @override
  String get einstKiHinweis =>
      'Wie bei digiKam laufen alle KI-Funktionen offline auf diesem Rechner. Die Modelldateien werden nicht mitgeliefert, sondern bei Bedarf aus offiziellen Open-Source-Quellen heruntergeladen (einmalig, danach komplett offline nutzbar).';

  @override
  String get einstAutoAnalyseTitel =>
      'KI-Auswertung nach dem Import automatisch nachholen';

  @override
  String get einstAutoAnalyseText =>
      'Der Import legt die Fotos nur ab und bleibt dadurch schnell. Gesichter, Texterkennung, Bildsuche und Bildbeschreibung laufen danach im Hintergrund nach. Ausgeschaltet lässt sich das jederzeit unter Werkzeuge von Hand anstoßen.';

  @override
  String get einstNurErkennung =>
      'Nur Erkennung aktiv (Wiedererkennung: SFace-Modell fehlt noch)';

  @override
  String get einstAufgabenTitel => 'Aufgaben-Übersicht';

  @override
  String get einstAufgabenText =>
      'Alle Auswertungen mit Anzahl noch offener Fotos, einzeln anstoßbar';

  @override
  String get einstModellLoeschen => 'Modell löschen';

  @override
  String einstModellNichtGeladen(String beschreibung) {
    return '$beschreibung\n\nDas zugehörige Modell ist noch nicht geladen.';
  }

  @override
  String get einstVokabularText =>
      'Begriffe, die automatisch per KI-Bildsuche-Modell (CLIP) auf neu importierte Fotos angewendet werden. Änderungen hier gelten nur für künftige Fotos – um sie rückwirkend auf die vorhandene Bibliothek anzuwenden, siehe Werkzeuge → \"KI-Tags berechnen\" → \"Alle Fotos\".';

  @override
  String get einstBegriffHinzufuegenFeld => 'Begriff hinzufügen …';

  @override
  String get einstBegriffHinzufuegen => 'Begriff hinzufügen';

  @override
  String get einstOrteText =>
      'Ordnet dem GPS-Ort eines Fotos Land, Bundesland/Provinz und Stadt zu – komplett lokal über die nächstgelegene bekannte Stadt (GeoNames-Datensatz), ohne Anfrage an einen Online-Kartendienst. Für die Land-/Bundesland-/Stadt-Filter in den Suchoptionen nötig.';

  @override
  String get einstGeoTitel => 'GeoNames – Städte, Länder, Bundesländer';

  @override
  String einstGeoText(String lizenz) {
    return 'Städte ab 1000 Einwohnern weltweit (~10 MB). Lizenz: $lizenz.';
  }

  @override
  String get einstGeoLoeschen => 'GeoNames-Datensatz löschen';

  @override
  String get einstGesperrtText =>
      'Verschlüsselt private Fotos mit AES-256 (echte Verschlüsselung, nicht nur ein Anzeige-Filter) und blendet sie überall sonst (Timeline, Suche, Alben, Personen, Karte, Backup) aus. Ohne den PIN gibt es keine Wiederherstellung.';

  @override
  String get einstGesperrtEntsperrt =>
      'PIN eingerichtet – für diese Sitzung bereits entsperrt.';

  @override
  String get einstGesperrtOeffnen => 'Öffnen';

  @override
  String get einstPinAendern => 'PIN ändern';

  @override
  String get einstGesperrtAufloesenText =>
      'Alle Fotos im gesperrten Ordner werden entschlüsselt und wieder normal sichtbar (Timeline, Suche, Alben, Personen, Karte, Backup). Das lässt sich nicht rückgängig machen.';

  @override
  String get einstBackupVerschluesselungTitel => 'Backup-Verschlüsselung';

  @override
  String get einstBackupVerschluesselungText =>
      'Ermöglicht, manuelle und automatische Backups mit AES-256 zu verschlüsseln. Eigene Passphrase, unabhängig vom PIN des gesperrten Ordners – ein Backup landet oft extern und muss auch ohne diesen Rechner entschlüsselbar sein.';

  @override
  String get einstBackupEntsperrt =>
      'Eingerichtet – für diese Sitzung bereits entsperrt.';

  @override
  String get einstBackupGesperrt =>
      'Eingerichtet – wird beim nächsten Backup abgefragt.';

  @override
  String get einstBackupAendern => 'Ändern';

  @override
  String get einstBackupNieGesichert => 'Noch nie gesichert.';

  @override
  String get einstBackupVerschluesseln => 'Backup verschlüsseln';

  @override
  String get einstBackupPassphraseAbfrage =>
      'Fragt bei Bedarf die Backup-Passphrase von oben ab.';

  @override
  String get einstBackupZielWaehlen =>
      'Backup-Ziel wählen (z.B. dein Dropbox- oder Google-Drive-Ordner)';

  @override
  String get einstBackupOrdnerWaehlen =>
      'Backup-Ordner wählen (enthält \"PhotoVault-Backup\" bzw. \"originals\")';

  @override
  String get einstBackupEntschluesselnTitel =>
      'Backup-Verschlüsselung entfernen?';

  @override
  String get einstBackupEntschluesselnText =>
      'Neue Backups werden danach nicht mehr verschlüsselt. Bereits bestehende verschlüsselte Backups am Zielort bleiben unverändert und weiterhin nur mit der bisherigen Passphrase entschlüsselbar.';

  @override
  String get einstBackupLaeuft => 'Automatisches Backup läuft …';

  @override
  String get einstBackupKeineNeuen =>
      'Keine neuen Dateien – Datenbank-Schnappschuss wird aktualisiert.';

  @override
  String get einstBackupZielHinweis =>
      'Wähle als Ziel z.B. deinen lokalen Dropbox- oder Google-Drive-Ordner – die Desktop-App des jeweiligen Anbieters lädt die Dateien dann automatisch in die Cloud hoch.';

  @override
  String get einstBackupAutoHinweis =>
      'Läuft nur, während die App geöffnet ist (kein Hintergrunddienst) – prüft beim Start und danach alle 30 Minuten, ob das Intervall abgelaufen ist. Sichert immer verschlüsselt, zusätzlich zu den Originaldateien auch einen Schnappschuss der gesamten Datenbank (Gesichter, Orte, Tags, Alben, Favoriten, …), damit sich bei Datenverlust der komplette Zustand wiederherstellen lässt. Löscht am Zielort nie etwas – lokale Löschungen werden bewusst nicht nachvollzogen.';

  @override
  String get einstBackupZuerstZiel => 'Zuerst einen Zielordner wählen.';

  @override
  String get einstBackupKeinOrdner => 'Kein Ordner gewählt.';

  @override
  String get einstBackupAutoZielWaehlen =>
      'Zielordner für automatisches Backup wählen';

  @override
  String get einstWaehlen => 'Wählen…';

  @override
  String get einstStuendlich => 'Stündlich';

  @override
  String get einstTaeglich => 'Täglich';

  @override
  String get einstWoechentlich => 'Wöchentlich';

  @override
  String get einstBackupGrenzeText =>
      'Begrenzt, wie viel pro Durchlauf ins Ziel geschrieben wird. Sinnvoll bei Cloud-Ordnern: Der Upload kommt sonst tagelang nicht hinterher. Der Rest folgt beim nächsten Intervall.';

  @override
  String get einstNieAusgefuehrt => 'Noch nie ausgeführt.';

  @override
  String get einstBackupPassphraseGesperrt =>
      'Backup-Passphrase muss für diese Sitzung noch entsperrt werden, bevor das automatische Backup laufen kann – z.B. über \"Jetzt synchronisieren\".';

  @override
  String get einstPapierkorbText =>
      'Löscht in den Papierkorb verschobene Fotos/Videos nach Ablauf der gewählten Frist endgültig – unwiderruflich, auch aus dem PIN-geschützten Papierkorb des gesperrten Ordners. Standardmäßig deaktiviert.';

  @override
  String get einstPapierkorbAus =>
      'Papierkorb-Ablauf ist standardmäßig ausgeschaltet.';

  @override
  String get einstResetText =>
      'Löscht unwiderruflich ALLE Fotos, Videos und die gesamte Datenbank dieser Bibliothek und beginnt danach mit einer leeren Bibliothek neu. Heruntergeladene KI-Modelle und Geodaten bleiben erhalten (kein erneuter Download nötig).';

  @override
  String get einstResetTitel => 'Datenbank zurücksetzen';

  @override
  String get einstResetKurz =>
      'Löscht alle Medien und Metadaten – nicht rückgängig zu machen.';

  @override
  String get einstResetKnopf => 'Zurücksetzen…';

  @override
  String get einstResetBestaetigenTitel => 'Datenbank wirklich zurücksetzen?';

  @override
  String get einstResetBestaetigenText =>
      'Löscht UNWIDERRUFLICH alle Fotos, Videos, Thumbnails und die gesamte Datenbank dieser Bibliothek (Alben, Personen, Tags, Orte, Favoriten, gesperrter Ordner, Papierkorb, gespeicherte Suchen, …). Heruntergeladene KI-Modelle und Geodaten bleiben erhalten. Erstelle vorher ein Backup, falls du dir nicht sicher bist – diese Aktion lässt sich NICHT rückgängig machen.';

  @override
  String get einstResetWort => 'ZURÜCKSETZEN';

  @override
  String get einstResetEndgueltig => 'Endgültig zurücksetzen';

  @override
  String get einstResetLaeuft => 'Lösche Bibliothek …';

  @override
  String get einstResetFertig =>
      'Die Bibliothek wurde vollständig gelöscht. Die App wird jetzt geschlossen – bitte danach manuell neu öffnen, um mit einer leeren Bibliothek neu zu beginnen.';

  @override
  String get einstResetFehlgeschlagen => 'Zurücksetzen fehlgeschlagen';

  @override
  String get einstUeberTitel => 'Über diese App';

  @override
  String get einstKeineModelle => 'Keine KI-Modelle geladen';

  @override
  String einstModelleGeladen(int geladen, int gesamt) {
    return '$geladen von $gesamt KI-Modellen geladen';
  }

  @override
  String get einstModelleUnbenutzt =>
      'Die KI-Funktionen bleiben ohne sie unbenutzt.';

  @override
  String get einstAktualisierungHinweis =>
      'Die Prüfung fragt einmalig beim öffentlichen Veröffentlichungsverzeichnis nach der neuesten Versionsnummer. Es wird nichts über die Bibliothek übertragen, und es geschieht nur auf diesen Knopfdruck – nie von selbst.';

  @override
  String einstAktualisierungNeuer(String version) {
    return 'Neuere Fassung verfügbar: $version';
  }

  @override
  String get einstAktualisierungAktuell => 'Diese Fassung ist aktuell.';

  @override
  String einstAktualisierungFehler(String fehler) {
    return 'Prüfung fehlgeschlagen: $fehler';
  }

  @override
  String get einstVerschiebenFehlgeschlagen => 'Verschieben fehlgeschlagen';

  @override
  String get einstWechselnFehlgeschlagen => 'Wechseln fehlgeschlagen';

  @override
  String get einstNeustartTitel => 'Neustart erforderlich';

  @override
  String get einstUebersetzeBeschreibungTitel =>
      'Bildbeschreibungen in die Oberflächensprache übersetzen';

  @override
  String get einstUebersetzeBeschreibungText =>
      'Das Beschreibungsmodell liefert nur Englisch – es gibt kein vergleichbar kleines deutsches. Ist das Modell „Übersetzung Englisch → Deutsch“ geladen, wird jede neue Beschreibung zusätzlich übersetzt. Das englische Original bleibt erhalten, die Suche findet beide.';

  @override
  String get einstUebersetzeSucheTitel => 'Suche und Schlagwörter übersetzen';

  @override
  String get einstUebersetzeSucheText =>
      'Der Text-Teil des Bildsuche-Modells versteht nur Englisch, das Schlagwort-Vokabular ist aber deutsch. Eingeschaltet wandern Suchanfrage und Vokabelbegriffe vorher durch die Übersetzung. An 103 Fotos gemessen trifft das bei 33 von 56 Begriffen genauer, bei 19 schlechter – und es vergibt deutlich weniger Schlagwörter. Deshalb zum Ausprobieren, nicht als Vorgabe.';

  @override
  String get allgEntfernen => 'Entfernen';

  @override
  String get allgEinrichten => 'Einrichten';

  @override
  String get allgHerunterladen => 'Herunterladen';

  @override
  String get allgAktiv => 'Aktiv';

  @override
  String get einstAbschnittErscheinungsbild => 'Erscheinungsbild';

  @override
  String get einstAbschnittModelle => 'KI-Modelle (lokal & quelloffen)';

  @override
  String get einstAbschnittHintergrund => 'Hintergrundaufgaben';

  @override
  String get einstAbschnittVokabular => 'KI-Tagging-Vokabular';

  @override
  String get einstAbschnittStandortdaten =>
      'Standortdaten (lokal & quelloffen)';

  @override
  String get einstAbschnittGesperrterOrdner => 'Gesperrter Ordner';

  @override
  String get einstAbschnittManuellesBackup => 'Manuelles Cloud-Backup';

  @override
  String get einstAbschnittAutoBackup => 'Automatisches Backup';

  @override
  String get einstAbschnittPapierkorb => 'Papierkorb automatisch leeren';

  @override
  String get einstAbschnittGefahrenzone => 'Gefahrenzone';

  @override
  String get einstDesign => 'Design';

  @override
  String get einstDesignHell => 'Hell';

  @override
  String get einstDesignDunkel => 'Dunkel';

  @override
  String get einstDesignSystem => 'System';

  @override
  String get einstUeberwachtNichtsNeues =>
      'Ordner eingerichtet – nichts Neues gefunden.';

  @override
  String get einstBibWechselnAktion => 'Wechseln';

  @override
  String get einstBibWechselnLaeuft => 'Wechsle Bibliothek …';

  @override
  String get einstBibAktiv => 'aktiv';

  @override
  String get einstBibImmerVorhanden => 'immer vorhanden';

  @override
  String get einstSpeicherort => 'Speicherort';

  @override
  String get einstSpeicherortVerschiebenLaeuft => 'Verschiebe Bibliothek …';

  @override
  String get einstSpeicherbedarf => 'Speicherbedarf (Originale)';

  @override
  String einstModellLaedt(String titel) {
    return 'Lade „$titel“ herunter …';
  }

  @override
  String einstModelleBelegterPlatz(String groesse) {
    return 'Belegter Platz aller Modelle: $groesse';
  }

  @override
  String einstModellLizenzZeile(String lizenz) {
    return 'Lizenz: $lizenz';
  }

  @override
  String get einstGesichtserkennungAktiv => 'Gesichtserkennung aktiv';

  @override
  String get einstGesichtserkennungBeides =>
      'Erkennung + Wiedererkennungs-Embeddings aktiv';

  @override
  String get einstGesichtserkennungInaktiv =>
      'Inaktiv – YuNet-Modell oben herunterladen';

  @override
  String get einstGeoLaedt => 'Lade Standortdaten herunter …';

  @override
  String get einstPinEinrichten => 'PIN einrichten';

  @override
  String get einstGesperrterOrdner => 'Gesperrter Ordner';

  @override
  String get einstPinEingerichtet => 'PIN eingerichtet.';

  @override
  String get einstPinEntfernen => 'PIN entfernen';

  @override
  String get einstGesperrtAufloesenTitel => 'PIN-Schutz entfernen?';

  @override
  String get einstSitzungSperren => 'Sitzung jetzt sperren';

  @override
  String get einstPassphraseEinrichten => 'Passphrase einrichten';

  @override
  String get einstBackupPassphrase => 'Backup-Passphrase';

  @override
  String get einstBackupPassphraseEingeben => 'Backup-Passphrase eingeben';

  @override
  String get einstBackupSichertLaeuft => 'Sichere Bibliothek …';

  @override
  String get einstBackupWiederherstellenLaeuft =>
      'Stelle Bibliothek wieder her …';

  @override
  String get einstLetztesBackup => 'Letztes Backup';

  @override
  String einstBackupZusammenfassung(String datum, int anzahl, String ziel) {
    return '$datum – $anzahl Datei(en) nach $ziel';
  }

  @override
  String get einstJetztSichern => 'Jetzt sichern';

  @override
  String get einstWiederherstellen => 'Wiederherstellen';

  @override
  String get einstZielordner => 'Zielordner';

  @override
  String get einstIntervall => 'Intervall';

  @override
  String get einstIntervallSechsStunden => 'Alle 6 Stunden';

  @override
  String get einstMengeJeLauf => 'Menge je Lauf';

  @override
  String get einstUnbegrenzt => 'Unbegrenzt';

  @override
  String get einstLetzterLauf => 'Letzter Lauf';

  @override
  String get einstJetztSynchronisieren => 'Jetzt synchronisieren';

  @override
  String get einstNachTagen => 'Nach';

  @override
  String einstTageDropdown(int tage) {
    return '$tage Tagen';
  }

  @override
  String get einstDatenbank => 'Datenbank';

  @override
  String einstDatenbankStand(int version) {
    return 'Stand $version';
  }

  @override
  String einstBauZeile(String bau, String system, String systemversion) {
    return 'Bau $bau · $system $systemversion';
  }

  @override
  String get einstNachAktualisierungSuchen => 'Nach Aktualisierung suchen';

  @override
  String get modellYunetTitel => 'Gesichtserkennung – YuNet';

  @override
  String get modellYunetText =>
      'Erkennt Gesichter (Bounding Boxes) in Fotos. Leichtgewichtiges CNN, Teil von OpenCV Zoo.';

  @override
  String get modellYunetLizenz => 'Apache-2.0';

  @override
  String get modellSfaceTitel => 'Gesichts-Wiedererkennung – SFace';

  @override
  String get modellSfaceText =>
      'Berechnet ein Embedding pro Gesicht, um ähnliche/gleiche Gesichter beim manuellen Zuordnen leichter zu gruppieren. Teil von OpenCV Zoo.';

  @override
  String get modellSfaceLizenz => 'Apache-2.0';

  @override
  String get modellClipTitel => 'KI-Bildsuche – CLIP ViT-B/32';

  @override
  String get modellClipText =>
      'Ermöglicht die Suche nach Fotos in natürlicher Sprache (z.B. \"Sonnenuntergang am Meer\"). OpenAI-Originalgewichte, als separate Bild-/Text-Encoder-ONNX-Graphen exportiert.';

  @override
  String get modellClipLizenz => 'MIT (Gewichte: OpenAI CLIP, siehe Quelle)';

  @override
  String get modellSamTitel => 'KI-Objektmasken – SAM ViT-Base';

  @override
  String get modellSamText =>
      'Erlaubt gezielte Anpassungen nur auf einem ausgewählten Bereich (z.B. nur den Himmel aufhellen) im Entwickeln-Screen, statt jede Anpassung auf das ganze Bild anzuwenden. Nutzer setzt Vordergrund-/Hintergrund-Punkte, ein promptbares Segmentierungsmodell schlägt die passende Maske vor.';

  @override
  String get modellSamLizenz =>
      'Apache-2.0 (Gewichte: Meta Segment Anything, siehe Quelle)';

  @override
  String get modellCaptionTitel =>
      'KI-Bildbeschreibung – Florence-2 (Englisch)';

  @override
  String get modellCaptionText =>
      'Erzeugt automatisch eine Bildunterschrift pro Foto – für die Suche und als schnelle Übersicht. Liest dabei auch Schrift im Bild, etwa Ladenschilder oder Ortstafeln. Ausgabe ist Englisch; auf Wunsch übersetzt die App sie ins Deutsche (eigenes Modell). Ein vergleichbar kleines mehrsprachiges Modell gibt es nicht – die mehrsprachigen liegen im Gigabyte-Bereich.';

  @override
  String get modellCaptionLizenz =>
      'MIT (Basis: microsoft/Florence-2-base-ft, ONNX-Port: onnx-community)';

  @override
  String get modellOcecTitel => 'Geschlossene-Augen-Erkennung – OCEC';

  @override
  String get modellOcecText =>
      'Markiert Gesichter mit geschlossenen Augen in der Sichtung – schnelleres Aussortieren von Fotos mit Blinzlern in Porträt-/Gruppenserien.';

  @override
  String get modellOcecLizenz => 'MIT';

  @override
  String get modellEsrganTitel => 'KI-Restaurierung – Real-ESRGAN x4';

  @override
  String get modellEsrganText =>
      'Skaliert ein Foto um Faktor 4 hoch und entrauscht dabei. Läuft als Hintergrund-Warteschlange (Einstellungen/Entwickeln) und dauert je nach Fotogröße mehrere Minuten.';

  @override
  String get modellEsrganLizenz =>
      'BSD-3-Clause (Real-ESRGAN-Originalgewichte)';

  @override
  String get modellEnDeTitel => 'Übersetzung Englisch → Deutsch – OPUS-MT';

  @override
  String get modellEnDeText =>
      'Übersetzt die automatisch erzeugten Bildbeschreibungen ins Deutsche. Das Beschreibungsmodell selbst liefert nur Englisch; ohne diese Ergänzung muss man auf Englisch suchen, was man auf Deutsch sieht. Rund 100 MB.';

  @override
  String get modellEnDeLizenz =>
      'Apache-2.0 (Basis: Helsinki-NLP/opus-mt-en-de, ONNX-Port: Xenova)';

  @override
  String get modellDeEnTitel => 'Übersetzung Deutsch → Englisch – OPUS-MT';

  @override
  String get modellDeEnText =>
      'Übersetzt deutsche Suchanfragen und Schlagwörter, bevor sie an die KI-Bildsuche gehen – deren Text-Encoder versteht nur Englisch. Rund 100 MB.';

  @override
  String get modellDeEnLizenz =>
      'Apache-2.0 (Basis: Helsinki-NLP/opus-mt-de-en, ONNX-Port: Xenova)';

  @override
  String get werkzKeineUnbewerteten => 'Keine unbewerteten Fotos gefunden.';

  @override
  String get werkzYunetNoetig =>
      'Dafür wird zuerst das YuNet-Modell benötigt (Einstellungen → KI-Modelle).';

  @override
  String get werkzClipNoetig =>
      'Dafür wird zuerst das CLIP-Modell benötigt (Einstellungen → KI-Modelle).';

  @override
  String get werkzBeschreibungsmodellNoetig =>
      'Dafür wird zuerst das Bildbeschreibungs-Modell benötigt (Einstellungen → KI-Modelle).';

  @override
  String get werkzGeoNoetig =>
      'Dafür wird zuerst der GeoNames-Datensatz benötigt (Einstellungen → Standortdaten).';

  @override
  String get werkzKeinePassenden => 'Keine passenden Fotos gefunden.';

  @override
  String get werkzGesichterScannenTitel => 'Gesichter scannen';

  @override
  String get werkzGesichterScannenFrage =>
      'Nur neue Fotos scannen: schnell, überspringt bereits gescannte Fotos.\n\nAlle Fotos erneut scannen: prüft die komplette Bibliothek neu (z.B. sinnvoll nach einem Update der Gesichtserkennung, oder um die Geschlossene-Augen-Erkennung nachträglich für bereits gescannte Fotos zu berechnen) – dauert bei großen Bibliotheken entsprechend länger. Bereits manuell zugeordnete Gesichter bleiben dabei erhalten.';

  @override
  String get werkzNurNeueFotos => 'Nur neue Fotos';

  @override
  String get werkzAlleErneutScannen => 'Alle erneut scannen';

  @override
  String get werkzScanneNeue => 'Scanne neue Fotos …';

  @override
  String get werkzScanneAlle => 'Scanne alle Fotos erneut …';

  @override
  String get werkzVorschauNeuTitel => 'Vorschaubilder neu erstellen';

  @override
  String get werkzVorschauNeuFrage =>
      'Nur fehlende: verarbeitet nur Fotos/Videos, die aktuell kein Thumbnail haben (z.B. HEIC-Fotos, die vor Einrichtung der nativen Bildkonvertierung importiert wurden, oder Videos, die vor Einführung der Video-Thumbnail-Erzeugung importiert wurden).\n\nAlle neu erstellen: erzeugt für die komplette Bibliothek neue Thumbnails/Vorschauen – sinnvoll z.B. nach einem Update der Bild- oder Videokonvertierung. Dauert bei großen Bibliotheken entsprechend länger.';

  @override
  String get werkzNurFehlende => 'Nur fehlende';

  @override
  String get werkzAlleNeuErstellen => 'Alle neu erstellen';

  @override
  String get werkzErstelleFehlende => 'Erstelle fehlende Vorschaubilder …';

  @override
  String get werkzErstelleAlle => 'Erstelle alle Vorschaubilder neu …';

  @override
  String get werkzRendereNeu => 'Rendere entwickelte Fotos neu …';

  @override
  String get werkzKeineEntwickelten => 'Keine entwickelten Fotos gefunden.';

  @override
  String get werkzPruefeLivePhotos => 'Prüfe auf Live-Photo-Paare …';

  @override
  String get werkzKeineUnverknuepften => 'Keine unverknüpften Fotos gefunden.';

  @override
  String get werkzBerechneEmbeddings => 'Berechne CLIP-Embeddings …';

  @override
  String get werkzAlleHabenEmbedding =>
      'Alle Fotos haben bereits ein Embedding.';

  @override
  String get werkzKiTagsTitel => 'KI-Tags berechnen';

  @override
  String get werkzKiTagsFrage =>
      'Nur ungetaggte Fotos: schnell, überspringt Fotos, die schon mindestens einen Tag haben (manuell oder automatisch).\n\nAlle Fotos: prüft die komplette Bibliothek neu und ergänzt zusätzlich passende KI-Tags bei bereits getaggten Fotos – vorhandene Tags bleiben dabei erhalten.';

  @override
  String get werkzNurUngetaggte => 'Nur ungetaggte';

  @override
  String get werkzAlleFotos => 'Alle Fotos';

  @override
  String get werkzBerechneKiTags => 'Berechne KI-Tags …';

  @override
  String get werkzLeseOrte => 'Lese Orte aus Fotos ein …';

  @override
  String get werkzAlleHabenOrt =>
      'Alle Fotos haben bereits einen Ort (oder keine EXIF-GPS-Daten).';

  @override
  String get werkzLoeseOrteAuf => 'Löse Land/Bundesland/Stadt auf …';

  @override
  String get werkzAlleAufgeloest =>
      'Alle Fotos mit bekanntem Ort sind bereits aufgelöst.';

  @override
  String get werkzLeseKameradaten => 'Lese Kameradaten aus Fotos ein …';

  @override
  String get werkzAlleHabenKameradaten =>
      'Alle Fotos haben bereits Kameradaten (oder keine passenden EXIF-Daten).';

  @override
  String get werkzSchreibeXmp => 'Schreibe XMP-Sidecars …';

  @override
  String get werkzKeineFotosGesperrt =>
      'Keine Fotos gefunden (gesperrte Fotos werden übersprungen).';

  @override
  String get werkzErkenneText => 'Erkenne Text in Fotos …';

  @override
  String get werkzAlleTextDurchsucht =>
      'Alle Fotos wurden bereits nach Text durchsucht.';

  @override
  String get werkzErzeugeBeschreibungen => 'Erzeuge Bildbeschreibungen …';

  @override
  String get werkzAlleHabenBeschreibung =>
      'Alle Fotos haben bereits eine KI-Beschreibung.';

  @override
  String get werkzBerechneUnschaerfe => 'Berechne Unschärfe-Scores …';

  @override
  String get werkzAlleHabenUnschaerfe =>
      'Für alle Fotos wurde bereits ein Unschärfe-Score berechnet.';

  @override
  String get werkzAbschnittStatistik => 'Statistik';

  @override
  String get werkzAnalyseseiteTitel => 'Analyseseite';

  @override
  String get werkzAnalyseseiteText =>
      'Anzahl Fotos/Videos, Speicherplatz, Aufnahmen pro Jahr/Monat, häufigste Kameras';

  @override
  String get werkzAbschnittGesichtserkennung => 'Gesichtserkennung';

  @override
  String get werkzGesichterScannenUntertitel =>
      'Manuell auslösen – neue oder alle Fotos';

  @override
  String get werkzSchwelleLabel =>
      'Ähnlichkeitsschwelle für\n\"Ähnliche mit auswählen\"';

  @override
  String get werkzSchwelleErklaerung =>
      'Höhere Werte = strengerer Abgleich (weniger, aber sicherere Treffer). Gilt für den Button \"Ähnliche mit auswählen\" im Personen-Tab bei \"Unbenannte Gesichter\".';

  @override
  String get werkzAbschnittVorschau => 'Vorschaubilder';

  @override
  String get werkzHeicTitel => 'HEIC/HEIF & RAW-Unterstützung';

  @override
  String get werkzHeicAktiv =>
      'Aktiv – iPhone-Fotos (HEIC) und RAW-Dateien (DNG, CR2/CR3, NEF, ARW, RAF, ORF, RW2 & Co.) werden über die native macOS-Bildkonvertierung unterstützt.';

  @override
  String get werkzHeicInaktiv =>
      'Inaktiv – native Swift-Datei muss noch ins Xcode-Projekt eingebunden werden (siehe README). JPG/PNG/WebP/GIF/BMP/TIFF funktionieren auch ohne das.';

  @override
  String get werkzHeicWerkzeugeAktiv =>
      'Aktiv – iPhone-Fotos (HEIC) und RAW-Dateien (DNG, CR2/CR3, NEF, ARW, RAF, ORF, RW2 & Co.) werden über die mitgelieferten Werkzeuge unterstützt.';

  @override
  String werkzHeicWerkzeugeFehlen(String namen) {
    return 'Eingeschränkt – es fehlen: $namen. Die davon abhängigen Formate bleiben ohne Vorschau; JPG/PNG/WebP/GIF/BMP/TIFF funktionieren weiter.';
  }

  @override
  String get werkzVorschauNeuUntertitel =>
      'Für alle Fotos oder nur für noch fehlende';

  @override
  String get werkzAbschnittEntwicklung => 'Entwicklung';

  @override
  String get werkzNeuRendernTitel => 'Entwickelte Fotos neu rendern';

  @override
  String get werkzNeuRendernText =>
      'Rendert alle Fotos mit gespeicherten Entwicklungs-Anpassungen (Belichtung, Weißabgleich & Co.) mit unveränderten Einstellungen neu – z.B. sinnvoll nach einem Update der nativen Bildverarbeitung.';

  @override
  String get werkzAbschnittLivePhotos => 'Live Photos';

  @override
  String get werkzLivePhotoTitel => 'Live-Photo-Paare erneut prüfen';

  @override
  String get werkzLivePhotoText =>
      'Für Fotos/Videos, die vor dieser Funktion importiert wurden – verknüpft HEIC/JPG-Standbilder mit gleichnamigen MOV-Videos.';

  @override
  String get werkzAbschnittOrte => 'Orte';

  @override
  String get werkzOrteEinlesenTitel => 'Orte aus Fotos einlesen';

  @override
  String get werkzOrteEinlesenText =>
      'Für Fotos, die vor Einführung der Kartenansicht importiert wurden – liest EXIF-GPS-Daten nachträglich ein.';

  @override
  String get werkzOrteAufloesenTitel => 'Land/Bundesland/Stadt auflösen';

  @override
  String get werkzOrteAufloesenText =>
      'Ordnet dem GPS-Ort eines Fotos Land, Bundesland/Provinz und Stadt zu – komplett lokal/offline über den GeoNames-Datensatz (siehe Einstellungen → Standortdaten). Für die Land-/Bundesland-/Stadt-Filter in den Suchoptionen nötig.';

  @override
  String get werkzAbschnittKamera => 'Kamera';

  @override
  String get werkzKameradatenTitel => 'Kameradaten aus Fotos einlesen';

  @override
  String get werkzKameradatenText =>
      'Für Fotos, die vor Einführung der Kamera-Anzeige importiert wurden – liest Kamera, Objektiv, Brennweite, Blende, ISO und Belichtungszeit aus den EXIF-Daten nachträglich ein.';

  @override
  String get werkzPresetsTitel => 'Kamera-Presets verwalten';

  @override
  String get werkzPresetsText =>
      'Fotos einer bestimmten Kamera automatisch beim Import einem Album/Tag zuordnen oder favorisieren – analog zu Digikams \"Kamera für den Import voreinstellen\".';

  @override
  String get werkzRegelnTitel => 'Automatisierungsregeln verwalten';

  @override
  String get werkzRegelnText =>
      'Fotos automatisch anhand von Ort, KI-Tag oder Aufnahmedatum einem Album/Tag zuordnen oder favorisieren – wie Kamera-Presets, nur für andere Bedingungen.';

  @override
  String get werkzAbschnittQualitaet => 'Fotoqualität';

  @override
  String get werkzOcrTitel => 'Text in Fotos erkennen';

  @override
  String get werkzOcrText =>
      'Für Fotos, die vor Einführung der Textsuche importiert wurden – erkennt sichtbaren Text (z.B. Schilder, Dokumente) nachträglich, rein lokal über Apples Vision-Framework.';

  @override
  String get werkzBeschreibungenTitel => 'Bildbeschreibungen erzeugen';

  @override
  String get werkzBeschreibungenText =>
      'Für Fotos, die vor Installation des Bildbeschreibungs-Modells importiert wurden – erzeugt eine kurze, englische Bildunterschrift pro Foto, rein lokal.';

  @override
  String get werkzUnschaerfeTitel => 'Unschärfe neu berechnen';

  @override
  String get werkzUnschaerfeText =>
      'Für Fotos, die vor Einführung der Unschärfe-Erkennung importiert wurden – ermöglicht den Suchfilter \"Nur unscharfe Fotos anzeigen\".';

  @override
  String get werkzAbschnittBildsuche => 'KI-Bildsuche';

  @override
  String get werkzAllesNachholenTitel => 'Alle Auswertungen jetzt nachholen';

  @override
  String get werkzAllesNachholenText =>
      'Startet alle rechenintensiven Schritte nacheinander im Hintergrund: Unschärfe, Gesichter, Texterkennung, Bildsuche, Schlagwörter und Bildbeschreibung. Jeder Schritt überspringt, was er schon hat – die App bleibt bedienbar.';

  @override
  String get werkzAnalyseGestartet =>
      'Auswertung läuft im Hintergrund – Fortschritt oben in der Leiste.';

  @override
  String get werkzEmbeddingsTitel => 'CLIP-Embeddings berechnen';

  @override
  String get werkzEmbeddingsText =>
      'Für Fotos, die vor Installation des CLIP-Modells importiert wurden – ohne Embedding tauchen sie in der KI-Bildsuche und der Duplikatsuche nicht auf.';

  @override
  String get werkzEmbeddingsFrage =>
      'Nur fehlende: für Fotos, die vor Installation des CLIP-Modells importiert wurden.\n\nAlle Fotos: rechnet auch vorhandene neu. Nötig nach einer Änderung der Bildvorverarbeitung – seit Version 1.4 wird ein Foto mittig zugeschnitten statt gestaucht, und alte Vektoren stammen noch aus dem gestauchten Bild. Bis das nachgeholt ist, arbeiten Bildsuche und Schlagwörter mit zweierlei Mass.';

  @override
  String get werkzKiTagsKarteText =>
      'Ordnet Fotos automatisch passende Tags aus einer festen Begriffsliste zu (z.B. \"Kind\", \"Draußen\", \"Geburtstag\") – auf Basis des CLIP-Modells, ohne zusätzlichen Download. Tags lassen sich in der Info-Ansicht eines Fotos jederzeit anpassen.';

  @override
  String get werkzAbschnittBibliothek => 'Bibliothek';

  @override
  String get werkzSichtenTitel => 'Unbewertete Fotos sichten';

  @override
  String get werkzSichtenText =>
      'Öffnet alle noch unbewerteten Fotos/Videos im Vollbild-Sichtungs-Modus, zum schnellen Durchgehen und Bewerten.';

  @override
  String get werkzDuplikateTitel => 'Duplikate & ähnliche Fotos suchen';

  @override
  String get werkzDuplikateText => 'Auf Basis der CLIP-Bild-Embeddings';

  @override
  String get werkzStapelTitel => 'Serienbilder gruppieren';

  @override
  String get werkzStapelText =>
      'Findet zeitlich nahe, ähnliche Fotos (z.B. Serienbilder) und fasst sie auf Wunsch zu einem Stapel mit einem Titelbild zusammen.';

  @override
  String get werkzIntegritaetTitel => 'Bibliotheks-Integritätsprüfung';

  @override
  String get werkzIntegritaetText =>
      'Gleicht die Datenbank gegen die tatsächlichen Dateien auf der Platte ab: fehlende Dateien, verwaiste Dateien, optional Prüfsummen-Abweichungen.';

  @override
  String get werkzAbschnittInterop => 'Interoperabilität';

  @override
  String get werkzXmpSchreibenTitel => 'XMP-Sidecars schreiben';

  @override
  String get werkzXmpSchreibenText =>
      'Legt für jedes Foto eine .xmp-Datei mit Bewertung, Farbmarkierung, Beschreibung, Tags und Kamera-Daten daneben ab – für Lightroom, darktable oder digiKam. Gesperrte Fotos werden übersprungen. Passiert automatisch auch beim Exportieren und bei unverschlüsselten Backups.';

  @override
  String get werkzXmpLesenTitel => 'XMP-Sidecars einlesen';

  @override
  String get werkzXmpLesenText =>
      'Liest vorhandene .xmp-Dateien (z.B. extern in Lightroom/darktable/digiKam bearbeitet) und zeigt Abweichungen zur Datenbank – Bewertung, Farbmarkierung, Beschreibung, Tags, Standort.';

  @override
  String sichtungHilfeleiste(int aktuell, int gesamt) {
    return '$aktuell / $gesamt   ·   0–5 Bewertung   ·   ⌫ Ablehnen   ·   ← → weiter';
  }

  @override
  String get ansicht360 => '360°-Ansicht';

  @override
  String personenZuordnenKnopf(int anzahl) {
    return '$anzahl zuordnen';
  }

  @override
  String get aufgStatus => 'Status';

  @override
  String get aufgBereit => 'Bereit';

  @override
  String get aufgLaeuft => 'Auswertung läuft im Hintergrund.';

  @override
  String get aufgJetztStarten => 'Jetzt starten';

  @override
  String get aufgWartend => 'Wartend';

  @override
  String get aufgBetrifft => 'Betrifft';

  @override
  String aufgStufe(
      String stufe, int erledigt, int gesamt, int nummer, int stufenGesamt) {
    return '$stufe ($erledigt/$gesamt) – Stufe $nummer/$stufenGesamt';
  }

  @override
  String aufgModellNoetig(String modell, String wo) {
    return 'Dafür wird zuerst $modell benötigt ($wo).';
  }

  @override
  String get aufgYunetModell => 'das YuNet-Modell';

  @override
  String get aufgClipModell => 'das CLIP-Modell';

  @override
  String get aufgBeschreibungsmodell => 'das Bildbeschreibungs-Modell';

  @override
  String get aufgGeoDatensatz => 'der GeoNames-Datensatz';

  @override
  String get aufgWoModelle => 'Einstellungen → KI-Modelle';

  @override
  String get aufgWoStandortdaten => 'Einstellungen → Standortdaten';

  @override
  String get aufgGesichterText =>
      'Erkennt und ordnet Gesichter zu, sofern das YuNet-Modell installiert ist.';

  @override
  String get aufgNeueFotos => 'Neue Fotos';

  @override
  String get aufgAlleErneut => 'Alle erneut';

  @override
  String get aufgVorschauText =>
      'Erzeugt Thumbnails/Vorschauen für Fotos und Videos.';

  @override
  String get aufgFehlende => 'Fehlende';

  @override
  String get aufgAlleNeu => 'Alle neu';

  @override
  String get aufgOcrTitel => 'Text erkennen (OCR)';

  @override
  String get aufgOcrText =>
      'Erkennt sichtbaren Text in Fotos, rein lokal über Apples Vision-Framework.';

  @override
  String get aufgStarten => 'Starten';

  @override
  String get aufgBeschreibungenTitel => 'Bildbeschreibungen';

  @override
  String get aufgBeschreibungenText =>
      'Erzeugt eine kurze, englische KI-Bildunterschrift pro Foto.';

  @override
  String get aufgEmbeddingsTitel => 'CLIP-Embeddings';

  @override
  String get aufgEmbeddingsText =>
      'Grundlage für KI-Bildsuche und Duplikatsuche.';

  @override
  String get aufgKiTagsTitel => 'KI-Tags';

  @override
  String get aufgKiTagsText =>
      'Ordnet Fotos automatisch passende Tags aus dem Vokabular zu (auf CLIP-Basis).';

  @override
  String get aufgUngetaggte => 'Ungetaggte';

  @override
  String get aufgUnschaerfeTitel => 'Unschärfe';

  @override
  String get aufgUnschaerfeText =>
      'Ermöglicht den Suchfilter \"Nur unscharfe Fotos anzeigen\".';

  @override
  String get aufgOrteTitel => 'Orte einlesen';

  @override
  String get aufgOrteText => 'Liest EXIF-GPS-Daten aus Fotos nachträglich ein.';

  @override
  String get aufgOrteAufloesenText =>
      'Ordnet dem GPS-Ort eines Fotos Land, Bundesland/Provinz und Stadt zu.';

  @override
  String get aufgKameraTitel => 'Kameradaten einlesen';

  @override
  String get aufgKameraText =>
      'Liest Kamera, Objektiv, Brennweite, Blende, ISO und Belichtungszeit aus EXIF ein.';

  @override
  String get aufgLivePhotoTitel => 'Live-Photo-Paare prüfen';

  @override
  String get aufgLivePhotoText =>
      'Verknüpft HEIC/JPG-Standbilder mit gleichnamigen MOV-Videos.';

  @override
  String get aufgRendernText =>
      'Rendert Fotos mit gespeicherten Entwicklungs-Anpassungen unverändert neu.';

  @override
  String get aufgXmpText =>
      'Legt für jedes Foto eine .xmp-Datei für Lightroom/darktable/digiKam daneben ab.';

  @override
  String get auswAufheben => 'Auswahl aufheben';

  @override
  String auswAnzahl(int anzahl) {
    return '$anzahl ausgewählt';
  }

  @override
  String get auswFavorisieren => 'Favorisieren';

  @override
  String get auswZuAlbum => 'Zu Album hinzufügen';

  @override
  String get auswTagHinzufuegen => 'Tag hinzufügen';

  @override
  String get auswBewertungSetzen => 'Bewertung setzen';

  @override
  String get auswFarbeSetzen => 'Farbmarkierung setzen';

  @override
  String get auswMetadaten => 'Metadaten bearbeiten';

  @override
  String get auswEntwicklungUebertragen => 'Kopierte Entwicklung übertragen';

  @override
  String get auswExportieren => 'Exportieren';

  @override
  String get allgLoeschen => 'Löschen';

  @override
  String get allgHinzufuegen => 'Hinzufügen';

  @override
  String get allgWaehlen => 'Wählen';

  @override
  String auswBewertungTitel(int anzahl) {
    return 'Bewertung für $anzahl Foto(s)';
  }

  @override
  String get auswKeineBewertung => 'Keine Bewertung';

  @override
  String auswFarbeTitel(int anzahl) {
    return 'Farbmarkierung für $anzahl Foto(s)';
  }

  @override
  String get auswKeineFarbe => 'Keine Farbe';

  @override
  String auswMetadatenTitel(int anzahl) {
    return 'Metadaten für $anzahl Foto(s) bearbeiten';
  }

  @override
  String get auswBeschreibungFeld => 'Beschreibung (überschreibt bestehende)';

  @override
  String get auswDatumUnveraendert => 'Datum unverändert lassen';

  @override
  String auswDatumGesetzt(String datum) {
    return 'Datum: $datum';
  }

  @override
  String get auswOrtHinweis => 'Ort (unverändert lassen: nicht antippen)';

  @override
  String auswTagTitel(int anzahl) {
    return 'Tag zu $anzahl Foto(s) hinzufügen';
  }

  @override
  String get auswTagFeld => 'Tag';

  @override
  String auswExportTitel(int anzahl) {
    return '$anzahl Foto(s) exportieren';
  }

  @override
  String auswUebertragenTitel(int anzahl) {
    return 'Entwicklung auf $anzahl Foto(s) übertragen?';
  }

  @override
  String get auswUebertragenText =>
      'Die kopierten Werte für Belichtung, Weissabgleich, Kontrast und Schatten werden übernommen; jedes Foto wird dabei neu gerendert.\n\nMasken werden nicht übertragen. Der bisherige Stand jedes Fotos bleibt in dessen Verlauf erhalten.';

  @override
  String get auswUebertragen => 'Übertragen';

  @override
  String get auswUebertrageLaeuft => 'Übertrage Entwicklung …';

  @override
  String get auswKeineGeeigneten =>
      'Keine geeigneten Fotos – gesperrte Fotos und Videos bleiben aussen vor.';

  @override
  String auswZielordner(int anzahl) {
    return 'Zielordner für $anzahl Foto(s) wählen';
  }

  @override
  String auswExportiereLaeuft(int erledigt, int gesamt) {
    return 'Exportiere … ($erledigt / $gesamt)';
  }

  @override
  String auswExportFertig(int erledigt, int gesamt, String ziel) {
    return '$erledigt von $gesamt Foto(s) exportiert nach $ziel';
  }

  @override
  String get exportOriginal => 'Original';

  @override
  String get exportGross => 'Gross – 4096 px';

  @override
  String get exportWeb => 'Web – 2048 px';

  @override
  String get exportEmail => 'E-Mail – 1024 px';

  @override
  String get exportUnveraendert => 'Datei unverändert, mit XMP-Datei daneben';

  @override
  String exportJpegKante(int kante) {
    return 'Als JPEG, lange Kante höchstens $kante px';
  }

  @override
  String get allgUebernehmen => 'Übernehmen';

  @override
  String get allgAlle => 'Alle';

  @override
  String get suchoptTagsWaehlen => 'Tags auswählen';

  @override
  String get suchoptTagsFiltern => 'Tags filtern …';

  @override
  String get suchoptKeineTags => 'Keine Tags gefunden.';

  @override
  String get suchoptTitel => 'Suchoptionen';

  @override
  String get suchoptKeineTreffer =>
      'Keine Fotos gefunden – diese Filterkombination liefert 0 Treffer.';

  @override
  String get suchoptAllesLeeren => 'Alles leeren';

  @override
  String get suchoptSuchen => 'Suche';

  @override
  String get suchoptPersonenFiltern => 'Personen filtern';

  @override
  String get suchoptKeinePersonenBenannt => 'Noch keine Personen benannt.';

  @override
  String get suchoptKeinePersonenGefunden => 'Keine Personen gefunden.';

  @override
  String get suchoptTypTitel => 'Suche nach Typ';

  @override
  String get suchoptTypKontext => 'Kontext';

  @override
  String get suchoptTypDateiname => 'Dateiname';

  @override
  String get suchoptTypBeschreibung => 'Beschreibung';

  @override
  String get suchoptTypOcr => 'Text im Foto (OCR)';

  @override
  String get suchoptTypCaption => 'KI-Beschreibung (Englisch)';

  @override
  String get suchoptNachKontext => 'Suche nach Kontext';

  @override
  String get suchoptNachDateiname => 'Suche nach Dateiname';

  @override
  String get suchoptNachBeschreibung => 'Suche nach Beschreibung';

  @override
  String get suchoptNachOcr => 'Suche nach erkanntem Text im Foto';

  @override
  String get suchoptNachCaption => 'Suche nach KI-Beschreibung (Englisch)';

  @override
  String get suchoptHintKontext =>
      'z.B. \"Sonnenaufgang am Strand\", \"Hund im Schnee\" …';

  @override
  String get suchoptHintDateiname => 'Dateiname …';

  @override
  String get suchoptHintBeschreibung => 'Beschreibung …';

  @override
  String get suchoptHintOcr => 'Text im Foto …';

  @override
  String get suchoptHintCaption => 'z.B. \"dog\", \"sunset\" (Englisch) …';

  @override
  String get suchoptClipFehlt =>
      'KI-Bildsuche nicht verfügbar – Modell fehlt (siehe Einstellungen → KI-Modelle).';

  @override
  String get suchoptCaptionFehlt =>
      'KI-Bildbeschreibung nicht verfügbar – Modell fehlt (siehe Einstellungen → KI-Modelle).';

  @override
  String get suchoptTagsTitel => 'Tags';

  @override
  String get suchoptTagsHint => 'Suche nach Tags …';

  @override
  String get suchoptOhneTag => 'Ohne Tag';

  @override
  String get suchoptMindestbewertung => 'Mindestbewertung';

  @override
  String get suchoptFarbmarkierung => 'Farbmarkierung';

  @override
  String get farbeRot => 'Rot';

  @override
  String get farbeGelb => 'Gelb';

  @override
  String get farbeGruen => 'Grün';

  @override
  String get farbeBlau => 'Blau';

  @override
  String get farbeLila => 'Lila';

  @override
  String get suchoptAufnahmewerte => 'Aufnahmewerte';

  @override
  String get suchoptIsoVon => 'ISO von';

  @override
  String get suchoptIsoBis => 'ISO bis';

  @override
  String get suchoptBlendeVon => 'Blende von (f/…)';

  @override
  String get suchoptBlendeBis => 'Blende bis (f/…)';

  @override
  String get suchoptBrennweiteVon => 'Brennweite von (mm)';

  @override
  String get suchoptBrennweiteBis => 'Brennweite bis (mm)';

  @override
  String get suchoptNurUnscharfe => 'Nur unscharfe Fotos anzeigen';

  @override
  String get suchoptMarke => 'Marke';

  @override
  String get suchoptModell => 'Modell';

  @override
  String get suchoptObjektiv => 'Objektiv';

  @override
  String get suchoptOrtTitel => 'Ort';

  @override
  String get suchoptLand => 'Land';

  @override
  String get suchoptBundesland => 'Bundesland';

  @override
  String get suchoptStadt => 'Stadt';

  @override
  String get suchoptGeoFehlt =>
      'Noch keine Orte aufgelöst – GeoNames-Datensatz herunterladen und Fotos auflösen (siehe Einstellungen → Standortdaten, Werkzeuge → Orte).';

  @override
  String get suchoptAnfangsdatum => 'Anfangsdatum';

  @override
  String get suchoptEnddatum => 'Enddatum';

  @override
  String get suchoptDatumEntfernen => 'Datum entfernen';

  @override
  String get suchoptDatumPlatzhalter => 'tt.mm.jjjj';

  @override
  String get suchoptMedientyp => 'Medientyp';

  @override
  String get suchoptBild => 'Bild';

  @override
  String get suchoptVideo => 'Video';

  @override
  String get suchoptAnzeigeoptionen => 'Anzeigeoptionen';

  @override
  String get suchoptInKeinemAlbum => 'In keinem Album';

  @override
  String get suchoptFavoriten => 'Favoriten';

  @override
  String get entwTitel => 'Entwickeln';

  @override
  String get entwKeinVerlauf =>
      'Noch kein Verlauf vorhanden – ein Eintrag entsteht, sobald du nach einer ersten Anpassung erneut speicherst.';

  @override
  String get entwKopiert =>
      'Einstellungen kopiert. Sie lassen sich jetzt auf andere Fotos übertragen – auch ohne dieses hier zu speichern.';

  @override
  String get entwEingesetzt =>
      'Kopierte Einstellungen eingesetzt – noch nicht gespeichert.';

  @override
  String get entwSpeichernFehlgeschlagen =>
      'Speichern fehlgeschlagen: Bild konnte nicht gerendert werden.';

  @override
  String get entwRestaurierungEingereiht =>
      'Zur Warteschlange für KI-Restaurierung hinzugefügt.';

  @override
  String entwRestaurierungFehler(String fehler) {
    return 'Konnte nicht zur Warteschlange hinzugefügt werden: $fehler';
  }

  @override
  String entwKiAuswahlLadefehler(String fehler) {
    return 'KI-Auswahl konnte nicht geladen werden: $fehler';
  }

  @override
  String get entwVorschauNichtDekodiert =>
      'Vorschaubild konnte nicht für die Maskierung dekodiert werden.';

  @override
  String entwKiAuswahlFehler(String fehler) {
    return 'KI-Auswahl fehlgeschlagen: $fehler';
  }

  @override
  String entwMaskeNummer(int nummer) {
    return 'Maske $nummer';
  }

  @override
  String get entwAufloesungUnbekannt =>
      'Bildauflösung unbekannt – Maske kann nicht gespeichert werden.';

  @override
  String get entwRestaurierungEntfernen => 'KI-Restaurierung entfernen';

  @override
  String get entwRestaurierungModellFehlt =>
      'Benötigt das Restaurierungs-Modell (Einstellungen → KI-Modelle)';

  @override
  String get entwRestaurierungAnwenden =>
      'KI-Restaurierung anwenden (läuft im Hintergrund, dauert mehrere Minuten)';

  @override
  String get entwMaskeHinzufuegen => 'Maske hinzufügen';

  @override
  String get entwVerlauf => 'Verlauf';

  @override
  String get entwEinstellungenKopieren =>
      'Einstellungen kopieren (zum Übertragen auf andere Fotos)';

  @override
  String get entwEinstellungenEinsetzen =>
      'Kopierte Einstellungen in die Regler setzen';

  @override
  String get entwOriginal => 'Original';

  @override
  String get entwVergleichen => 'Zum Vergleichen gedrückt halten';

  @override
  String get entwMaskeErstellen => 'Maske erstellen';

  @override
  String get entwFormKi => 'KI';

  @override
  String get entwFormPinsel => 'Pinsel';

  @override
  String get entwFormEllipse => 'Ellipse';

  @override
  String get entwFormVerlauf => 'Verlauf';

  @override
  String get allgFertig => 'Fertig';

  @override
  String get entwKiHinweis =>
      'Auf den Bereich tippen, den du anpassen möchtest. Mehrere Tipps verfeinern die Auswahl.';

  @override
  String get entwPunktHinzufuegen => 'Hinzufügen';

  @override
  String get entwPunktEntfernen => 'Entfernen';

  @override
  String get entwLetztenPunktEntfernen => 'Letzten Punkt entfernen';

  @override
  String get entwPinselHinweis =>
      'Über den Bereich ziehen, den du anpassen möchtest.';

  @override
  String get entwNeuZeichnen => 'Neu zeichnen';

  @override
  String get entwEllipseHinweis =>
      'Über den Bereich ziehen, um die Ellipse aufzuziehen.';

  @override
  String get entwVerlaufHinweis =>
      'Von einer Kante zur anderen ziehen, um den Verlauf festzulegen.';

  @override
  String get entwAnpassungFuer => 'Anpassung für';

  @override
  String get entwGanzesBild => 'Ganzes Bild';

  @override
  String get entwFormBearbeiten => 'Form bearbeiten';

  @override
  String get entwAutoWeissabgleich => 'Automatischer Weißabgleich';

  @override
  String get entwObjektivkorrektur => 'Objektivkorrektur';

  @override
  String get entwObjektivkorrekturHinweis =>
      'Nur wirksam für RAW-Fotos, deren Kamera/Objektiv unterstützt wird.';

  @override
  String get entwMaskenHinweis =>
      'Diese Anpassungen wirken nur innerhalb der ausgewählten Maske.';

  @override
  String get entwBelichtung => 'Belichtung';

  @override
  String get entwTemperatur => 'Temperatur (K)';

  @override
  String get entwTint => 'Tint';

  @override
  String get entwKontrast => 'Kontrast';

  @override
  String get entwSchatten => 'Schatten';

  @override
  String get entwSchaerfe => 'Schärfe';

  @override
  String get entwRauschunterdrueckung => 'Rauschunterdrückung';

  @override
  String get entwStrichbreite => 'Strichbreite';

  @override
  String get entwRotation => 'Rotation (°)';

  @override
  String get entwWeichzeichnung => 'Weichzeichnung';

  @override
  String get entwGesperrt =>
      'Entwickeln ist für Fotos im gesperrten Ordner nicht verfügbar.';

  @override
  String get entwVorschauFehlt =>
      'Vorschau konnte nicht erzeugt werden – native Bildkonvertierung nicht verfügbar?';

  @override
  String get entwModellLaedt => 'Modell für die KI-Auswahl wird geladen …';

  @override
  String get entwBildWirdVorbereitet =>
      'Bild wird für die Maskierung vorbereitet …';

  @override
  String get allgOder => '— oder —';

  @override
  String get albumBestehendes => 'Bestehendes Album';

  @override
  String get albumNeuAnlegen => 'Neues Album anlegen';

  @override
  String get personZuordnenTitel => 'Person zuordnen';

  @override
  String personAktuell(String name) {
    return 'Aktuell: $name';
  }

  @override
  String get personBestehende => 'Bestehende Person';

  @override
  String get personNeuAnlegen => 'Neue Person anlegen';

  @override
  String get personZuordnenAktion => 'Zuordnen';

  @override
  String get bestaetigEndgueltigLoeschen => 'Endgültig löschen';

  @override
  String get bestaetigTippeVor => 'Tippe zur Bestätigung ';

  @override
  String get bestaetigTippeNach => ' ein:';

  @override
  String fortschrittFehlgeschlagen(String fehler) {
    return 'Fehlgeschlagen: $fehler';
  }

  @override
  String sterneStern(int nummer) {
    return 'Stern $nummer von 5';
  }

  @override
  String sterneSternVoll(int nummer) {
    return 'Stern $nummer von 5, ausgefüllt';
  }

  @override
  String sterneSetzen(int nummer) {
    return 'Bewertung: $nummer von 5 Sternen setzen';
  }

  @override
  String sterneBewertungAnzeige(int nummer) {
    return 'Bewertung $nummer von 5 Sternen';
  }

  @override
  String get scrubberTooltip => 'Schnellnavigation zum Datum';

  @override
  String get farbeViolett => 'Violett';

  @override
  String farbeAusgewaehlt(String farbe) {
    return '$farbe, ausgewählt';
  }

  @override
  String farbeSetzen(String farbe) {
    return 'Farbmarkierung $farbe setzen';
  }

  @override
  String get histogrammTitel => 'Histogramm';

  @override
  String get histogrammKeineVorschau => 'Noch keine Vorschau';

  @override
  String get histogrammHelligkeit => 'Helligkeit';

  @override
  String get livePhotoHalten => 'Gedrückt halten zum Abspielen';

  @override
  String get metaBelichtungBeispiel => 'z.B. 1/125 oder 0.5';

  @override
  String get karteTippenFuerOrt => 'Tippen, um einen Ort festzulegen';

  @override
  String get rasterFotoNichtGefunden => 'Foto nicht in der Timeline gefunden.';

  @override
  String get kameraImportTitel => 'Von Kamera/SD-Karte importieren';

  @override
  String get kameraKeinDatentraeger =>
      'Kein Datenträger mit Fotos/Videos gefunden. Kamera oder SD-Karte per USB einstecken – die Liste aktualisiert sich automatisch, sobald sie erkannt wird.';

  @override
  String get mischerTitel => 'Farbmischer';

  @override
  String get mischerFarbton => 'Farbton';

  @override
  String get mischerSaettigung => 'Sättigung';

  @override
  String get mischerHelligkeit => 'Helligkeit';

  @override
  String get mischerHinweis =>
      'Wirkt nur auf farbige Bildbereiche – Graustufen bleiben unberührt.';

  @override
  String get bandRot => 'Rot';

  @override
  String get bandOrange => 'Orange';

  @override
  String get bandGelb => 'Gelb';

  @override
  String get bandGruen => 'Grün';

  @override
  String get bandAqua => 'Aqua';

  @override
  String get bandBlau => 'Blau';

  @override
  String get bandViolett => 'Violett';

  @override
  String get bandMagenta => 'Magenta';

  @override
  String get kurveTitel => 'Tonwertkurve';

  @override
  String get kurveHinweis =>
      'Ziehen setzt oder verschiebt einen Punkt, langes Drücken entfernt ihn.';

  @override
  String get pinFeld => 'PIN';

  @override
  String get pinFestlegenTitel => 'PIN festlegen';

  @override
  String get pinNeuFeld => 'Neuer PIN (8-10 Ziffern)';

  @override
  String get pinWiederholen => 'PIN wiederholen';

  @override
  String get pinWarnung =>
      'Wichtig: Fotos im gesperrten Ordner werden echt verschlüsselt (AES-256). Ohne diesen PIN gibt es KEINE Möglichkeit, sie wiederherzustellen – auch nicht durch Zurücksetzen der App.';

  @override
  String get pinZiffernFehler => 'PIN muss aus 8-10 Ziffern bestehen.';

  @override
  String get pinUngleich => 'PINs stimmen nicht überein.';

  @override
  String get allgFestlegen => 'Festlegen';

  @override
  String get pinEingebenTitel => 'PIN eingeben';

  @override
  String get pinFalsch => 'Falscher PIN.';

  @override
  String get passphraseFeld => 'Passphrase';

  @override
  String get passphraseFestlegenTitel => 'Backup-Passphrase festlegen';

  @override
  String get passphraseNeuFeld => 'Neue Passphrase (mind. 8 Zeichen)';

  @override
  String get passphraseWiederholen => 'Passphrase wiederholen';

  @override
  String get passphraseWarnung =>
      'Wichtig: Backups werden echt verschlüsselt (AES-256). Ohne diese Passphrase gibt es KEINE Möglichkeit, sie wiederherzustellen – auch nicht auf einem anderen Rechner. Am besten zusätzlich an einem sicheren Ort notieren.';

  @override
  String get passphraseUngleich => 'Passphrasen stimmen nicht überein.';

  @override
  String get passphraseFalsch => 'Falsche Passphrase.';

  @override
  String get allgFoto => 'Foto';

  @override
  String get allgVideo => 'Video';

  @override
  String get kachelFavorisiert => 'favorisiert';

  @override
  String kachelBeschreibung(String typ, String name, String datum) {
    return '$typ $name, $datum';
  }

  @override
  String albumFotosLoeschenTitel(int anzahl) {
    return '$anzahl Foto(s) löschen?';
  }

  @override
  String get albumFotosLoeschenText =>
      'Diese Fotos werden aus dem Album entfernt und in den Papierkorb verschoben.';

  @override
  String albumZielordner(String album) {
    return 'Zielordner für \"$album\" wählen';
  }

  @override
  String get albumExportieren => 'Album exportieren';

  @override
  String get albumLeer => 'Dieses Album enthält noch keine Fotos.';

  @override
  String get regelLoeschenTitel => 'Regel löschen?';

  @override
  String regelLoeschenText(String name) {
    return 'Die Regel \"$name\" wirklich löschen? Bereits angewendete Aktionen bleiben erhalten.';
  }

  @override
  String get regelOrtUnvollstaendig => 'Ort: unvollständig konfiguriert';

  @override
  String get regelDatumUnvollstaendig =>
      'Datumsbereich: unvollständig konfiguriert';

  @override
  String get regelTitel => 'Automatisierungsregeln';

  @override
  String get regelNeu => 'Neue Regel';

  @override
  String get regelLeer =>
      'Noch keine Automatisierungsregeln.\n\nLege eine Regel an, um Fotos automatisch anhand von Ort, KI-Tag oder Aufnahmedatum einem Album/Tag zuzuordnen oder zu favorisieren – wie Kamera-Presets, nur für andere Bedingungen.';

  @override
  String get allgBearbeiten => 'Bearbeiten';

  @override
  String get regelNameNoetig => 'Ein Name für die Regel ist erforderlich.';

  @override
  String get regelKoordinatenUngueltig =>
      'Breiten- und Längengrad müssen gültige Zahlen sein.';

  @override
  String get regelBreitengradBereich =>
      'Der Breitengrad muss zwischen -90 und 90 liegen.';

  @override
  String get regelLaengengradBereich =>
      'Der Längengrad muss zwischen -180 und 180 liegen.';

  @override
  String get regelTagWaehlen => 'Bitte einen KI-Tag-Begriff wählen.';

  @override
  String get regelDatumWaehlen => 'Bitte Start- und Enddatum wählen.';

  @override
  String get regelDatumReihenfolge =>
      'Das Startdatum muss vor dem Enddatum liegen.';

  @override
  String get regelBreitengrad => 'Breitengrad';

  @override
  String get regelLaengengrad => 'Längengrad';

  @override
  String get regelKeinVokabular =>
      'Kein KI-Tag-Vokabular vorhanden (Einstellungen → KI-Tagging-Vokabular).';

  @override
  String get regelTagBegriff => 'KI-Tag-Begriff';

  @override
  String get regelNameFeld => 'Name (z.B. \"Urlaub Italien\")';

  @override
  String get regelBedingung => 'Bedingung';

  @override
  String get presetZielalbum => 'Zielalbum (optional)';

  @override
  String get presetKeinAlbum => 'Kein Album';

  @override
  String get presetNeuesAlbum => 'oder: neues Album anlegen';

  @override
  String get presetFavorisieren => 'Automatisch favorisieren';

  @override
  String get presetTagsWaehlenPlatzhalter => 'Tags auswählen …';

  @override
  String get presetKeineTags => 'Keine Tags vorhanden.';

  @override
  String get presetLoeschenTitel => 'Preset löschen?';

  @override
  String presetLoeschenText(String kamera) {
    return 'Das Kamera-Preset für \"$kamera\" wirklich löschen? Bereits importierte Fotos bleiben unverändert.';
  }

  @override
  String get presetTitel => 'Kamera-Presets';

  @override
  String get presetNeu => 'Neues Preset';

  @override
  String get presetLeer =>
      'Noch keine Kamera-Presets.\n\nLege ein Preset für eine bestimmte Kamera an, um künftig importierte Fotos dieser Kamera automatisch einem Album/Tag zuzuordnen – auch schon bevor das erste Foto dieser Kamera importiert wurde.';

  @override
  String get presetHerstellerModellNoetig =>
      'Hersteller und Modell sind beide erforderlich.';

  @override
  String get presetBekannteKamera => 'Bekannte Kamera übernehmen (optional)';

  @override
  String get presetHersteller => 'Hersteller (z.B. Canon, Apple)';

  @override
  String get presetModell => 'Modell (z.B. EOS R5, iPhone 15 Pro)';

  @override
  String get allgClipNoetigKurz =>
      'Benötigt das CLIP-Modell (Einstellungen → KI-Modelle).';

  @override
  String get duplNichtsLoeschbar =>
      'Nichts automatisch löschbar: In allen Gruppen sind mehrere Fotos favorisiert oder bewertet – die bitte von Hand durchsehen.';

  @override
  String get duplNichtsZuLoeschen => 'Nichts zu löschen.';

  @override
  String get duplPapierkorbTitel => 'Kopien in den Papierkorb?';

  @override
  String duplPapierkorbAnzahl(int fotos, int gruppen) {
    return '$fotos Foto(s) aus $gruppen Gruppe(n) werden in den Papierkorb verschoben.';
  }

  @override
  String get duplBehaltenRegel =>
      'Behalten wird je Gruppe: Favorit, sonst höchste Bewertung, sonst das schärfste, sonst das mit der höchsten Auflösung.';

  @override
  String duplUebersprungen(int anzahl) {
    return '$anzahl Gruppe(n) bleiben unangetastet, weil dort mehrere Fotos favorisiert oder bewertet sind.';
  }

  @override
  String get duplRueckgaengig =>
      'Rückgängig: über den Papierkorb wiederherstellbar.';

  @override
  String get duplInPapierkorb => 'In den Papierkorb';

  @override
  String duplVerschoben(int anzahl) {
    return '$anzahl Foto(s) in den Papierkorb verschoben.';
  }

  @override
  String get duplTitel => 'Duplikate & ähnliche Fotos';

  @override
  String get duplZweiteBibliothek => 'Zweite Bibliothek';

  @override
  String get duplAlleKopienLoeschen => 'Alle Kopien löschen';

  @override
  String get duplAehnlichkeit => 'Ähnlichkeit:';

  @override
  String get duplSchwelleHinweis =>
      'Höhere Werte = nur sehr ähnliche Fotos werden als Gruppe erkannt. Niedrigere Werte finden mehr, aber auch weniger sichere Treffer.';

  @override
  String get duplKeineGruppen => 'Keine ähnlichen Fotogruppen gefunden.';

  @override
  String get duplVerschiebenTooltip => 'In den Papierkorb verschieben';

  @override
  String get clusterTitel => 'Vorschläge prüfen';

  @override
  String get clusterFertig => 'Alle Vorschläge durchgesehen.';

  @override
  String clusterAehnlichZu(String name) {
    return 'Ähnlich zu: $name';
  }

  @override
  String get clusterUeberspringen => 'Überspringen';

  @override
  String get gesichtUmbenennen => 'Person umbenennen/ändern';

  @override
  String get gesichtNeuBenennen => 'Neues Gesicht benennen';

  @override
  String get gesichtGesperrt =>
      'Gesichts-Bearbeitung ist für Fotos im gesperrten Ordner nicht verfügbar.';

  @override
  String get gesichtManuellHinzufuegen => 'Gesicht manuell hinzufügen';

  @override
  String get gesichtHinzufuegenBeenden => 'Hinzufügen beenden';

  @override
  String get gesichtRechteckHinweis =>
      'Ziehe ein Rechteck über ein Gesicht, um es manuell zu markieren.';

  @override
  String get bearbBildNichtLesbar => 'Bild konnte nicht gelesen werden.';

  @override
  String bearbBildNichtLesbarFehler(String fehler) {
    return 'Bild konnte nicht gelesen werden: $fehler';
  }

  @override
  String get bearbSpeichernTitel => 'Änderungen speichern?';

  @override
  String get bearbSpeichernText =>
      'Die Originaldatei wird durch die bearbeitete Version ersetzt. Das lässt sich nicht rückgängig machen.';

  @override
  String get bearbNichtFinalisiert => 'Bild konnte nicht finalisiert werden.';

  @override
  String get bearbZuschneidenAnwenden => 'Zuschneiden anwenden';

  @override
  String get bearbTitel => 'Bearbeiten';

  @override
  String get importWasTitel => 'Was möchtest du importieren?';

  @override
  String get importWasText =>
      'Wähle einzelne Fotos/Videos aus, importiere einen kompletten Ordner (inkl. aller Unterordner), oder importiere direkt von einer angeschlossenen Kamera/SD-Karte.';

  @override
  String get importEinzelneDateien => 'Einzelne Dateien wählen';

  @override
  String get importGanzerOrdner => 'Ganzen Ordner wählen';

  @override
  String get importVonKamera => 'Von Kamera/SD-Karte';

  @override
  String get importOrdnerWaehlen => 'Ordner zum Importieren wählen';

  @override
  String get importNichtsImOrdner =>
      'Keine unterstützten Fotos/Videos in diesem Ordner gefunden.';

  @override
  String get importNichtsAufDatentraeger =>
      'Keine unterstützten Fotos/Videos auf diesem Datenträger gefunden.';

  @override
  String get importAbgeschlossen => 'Import abgeschlossen';

  @override
  String get importLaeuft => 'Importiere Fotos & Videos …';

  @override
  String get importJetztSichten => 'Jetzt sichten';

  @override
  String integPruefungFehlgeschlagen(String fehler) {
    return 'Prüfung fehlgeschlagen: $fehler';
  }

  @override
  String get integOriginalFehlt =>
      'Das Original fehlt auf der Platte – das gesamte Foto/Video wird aus der Bibliothek entfernt.';

  @override
  String get integMaskeFehlt =>
      'Die Maskendatei fehlt – der Maskeneintrag wird entfernt.';

  @override
  String get integCropFehlt =>
      'Der Gesichts-Crop fehlt – nur die Vorschau wird entfernt, die Zuordnung zur Person bleibt erhalten.';

  @override
  String get integPfadEntfernt =>
      'Der Datei-Pfad wird aus der Datenbank entfernt – die Datei lässt sich über \"Werkzeuge → Vorschaubilder neu erstellen\" wieder herstellen.';

  @override
  String get integDateiLoeschenTitel => 'Datei löschen?';

  @override
  String integDateiLoeschenText(String pfad) {
    return '$pfad wird unwiderruflich von der Platte gelöscht.';
  }

  @override
  String get integErneutPruefen => 'Erneut prüfen';

  @override
  String get integPruefsummen => 'Prüfsummen prüfen';

  @override
  String get integPruefsummenHinweis =>
      'Liest jede Originaldatei komplett ein und vergleicht sie mit der beim Import gespeicherten Prüfsumme – bei großen Bibliotheken deutlich langsamer als die reine Existenz-/Verwaisten-Prüfung.';

  @override
  String integKeineProbleme(int anzahl) {
    return 'Keine Probleme gefunden ($anzahl Dateien geprüft).';
  }

  @override
  String get integAusDbEntfernen => 'Aus DB entfernen';

  @override
  String get integDateiLoeschen => 'Datei löschen';

  @override
  String integAbweichungen(int anzahl) {
    return 'Prüfsummen-Abweichungen ($anzahl)';
  }

  @override
  String get integInhaltGeaendert => 'Inhalt hat sich seit dem Import geändert';

  @override
  String get integFotoOeffnen => 'Foto öffnen';

  @override
  String integHeaderProbleme(int anzahl) {
    return 'Verschlüsselte Dateien mit ungültigem Header ($anzahl)';
  }

  @override
  String get integBeschaedigt =>
      'Datei ist evtl. beschädigt – keine gültige verschlüsselte Datei';

  @override
  String get gesperrtLeer =>
      'Keine gesperrten Fotos. In der Vollbildansicht eines Fotos lässt es sich über das Schloss-Symbol oben rechts hierher verschieben (dabei verschlüsselt).';

  @override
  String get gesperrtEntfernen =>
      'Aus dem gesperrten Ordner entfernen (entschlüsseln)';

  @override
  String get gesperrtEndgueltigTitel => 'Endgültig löschen?';

  @override
  String get gesperrtEndgueltigText =>
      'Die Datei wird unwiderruflich gelöscht – auch mit dem richtigen PIN gibt es danach keine Wiederherstellung mehr.';

  @override
  String get gesperrtPapierkorbLeer =>
      'Der gesperrte Papierkorb ist leer.\n\nAus dem gesperrten Ordner gelöschte Fotos landen hier statt im normalen (ungeschützten) Papierkorb.';

  @override
  String get gesperrtWiederherstellen => 'Wiederherstellen (bleibt gesperrt)';

  @override
  String get personKeineGesichter => 'Keine Gesichter dieser Person vorhanden.';

  @override
  String get personProfilbildWaehlen => 'Profilbild auswählen';

  @override
  String get personProfilbildAendern => 'Profilbild ändern';

  @override
  String get personKeineFotos => 'Noch keine Fotos für diese Person.';

  @override
  String get personDoppelklickHinweis =>
      'Doppelklick auf ein Foto öffnet es zur Kontrolle mit allen erkannten Gesichtern.';

  @override
  String get personGelerntesVerworfen =>
      'Gelerntes verworfen – es gilt wieder die allgemeine Schwelle.';

  @override
  String personSchwelleAngepasst(String schwelle, String allgemein) {
    return 'angepasst auf $schwelle statt $allgemein';
  }

  @override
  String personSchwelleWiderspruch(String allgemein) {
    return 'weiterhin $allgemein – die Entscheidungen widersprechen sich, ein abgelehntes Gesicht war ähnlicher als ein bestätigtes';
  }

  @override
  String personSchwelleWirdAngepasst(int anzahl) {
    return 'ab $anzahl Entscheidungen wird angepasst';
  }

  @override
  String get personVerwerfen => 'Verwerfen';

  @override
  String get restaurWartet => 'Wartet in der Warteschlange';

  @override
  String restaurLaeuft(int erledigt, int gesamt) {
    return 'Läuft – Kachel $erledigt von $gesamt';
  }

  @override
  String get restaurTitel => 'KI-Restaurierung – Warteschlange';

  @override
  String get restaurLeer =>
      'Keine Restaurierungs-Aufträge vorhanden.\nIm Entwickeln-Screen eines Fotos lässt sich eine KI-Restaurierung anstoßen.';

  @override
  String get restaurAusListe => 'Aus der Liste entfernen';

  @override
  String restaurFehlgeschlagen(String grund) {
    return 'Fehlgeschlagen: $grund';
  }

  @override
  String get restaurFehlgeschlagenKurz => 'Fehlgeschlagen';

  @override
  String get zweitOrdnerWaehlen =>
      'Ordner der zweiten PhotoVault-Bibliothek wählen';

  @override
  String get zweitTitel => 'Zweite Bibliothek vergleichen';

  @override
  String get allgErneutVersuchen => 'Erneut versuchen';

  @override
  String get zweitErklaerung =>
      'Vergleicht die eigene Bibliothek gegen eine zweite, unabhängige PhotoVault-Bibliothek (z.B. auf einer externen Platte oder einem alten Rechner) per KI-Bildähnlichkeit – findet Fotos, die dort schon liegen, bevor du sie erneut importierst.\n\nGesperrte Fotos der zweiten Bibliothek werden dabei nie einbezogen, ohne dass deren PIN gebraucht wird.';

  @override
  String get zweitOrdnerKnopf => 'Ordner der zweiten Bibliothek wählen';

  @override
  String get zweitSchwelleHinweis =>
      'Höhere Werte = nur sehr ähnliche Fotos gelten als Übereinstimmung.';

  @override
  String get zweitKeineTreffer =>
      'Keine ähnlichen Fotos in der zweiten Bibliothek gefunden.';

  @override
  String zweitTreffer(int anzahl) {
    return '$anzahl mögliche Übereinstimmung(en)';
  }

  @override
  String get zweitAndererOrdner => 'Anderer Ordner';

  @override
  String zweitAehnlichProzent(String prozent) {
    return '$prozent % ähnlich';
  }

  @override
  String get zweitBibliothek => 'zweite Bibliothek';

  @override
  String get aehnlTitel => 'Ähnliche Fotos';

  @override
  String get aehnlClipFehlt =>
      'KI-Bildsuche nicht verfügbar – CLIP-Modell fehlt (siehe Einstellungen → KI-Modelle).';

  @override
  String get aehnlKeineTreffer =>
      'Für dieses Foto liegt noch kein KI-Embedding vor (siehe Werkzeuge → KI-Bildsuche → CLIP-Embeddings berechnen) oder es gibt keine ähnlichen Fotos in der Bibliothek.';

  @override
  String get stapelErklaerung =>
      'Fotos, die sich ähneln UND innerhalb weniger Sekunden aufgenommen wurden, werden hier als Serie vorgeschlagen. \"Übernehmen\" fasst eine Gruppe zu einem Stapel zusammen – nur das Titelbild bleibt danach in der Übersicht sichtbar, nichts wird gelöscht.';

  @override
  String get stapelKeine => 'Keine Serienbilder gefunden.';

  @override
  String get allgVerwerfen => 'Verwerfen';

  @override
  String get statTitel => 'Statistik';

  @override
  String get allgAktualisieren => 'Aktualisieren';

  @override
  String get statLeer => 'Noch keine Fotos oder Videos in der Bibliothek.';

  @override
  String get statProJahr => 'Fotos & Videos pro Jahr';

  @override
  String get statSaisonalitaet => 'Saisonalität – Aufnahmen pro Monat';

  @override
  String get statKameras => 'Häufigste Kameras';

  @override
  String get statInsgesamt => 'Medien insgesamt';

  @override
  String get statFotos => 'Fotos';

  @override
  String get statVideos => 'Videos';

  @override
  String get statSpeicherplatz => 'Speicherplatz';

  @override
  String get statImPapierkorb => 'Im Papierkorb';

  @override
  String statDiagrammJahr(String werte) {
    return 'Balkendiagramm, Fotos und Videos pro Jahr: $werte';
  }

  @override
  String statDiagrammMonat(String werte) {
    return 'Balkendiagramm, Saisonalität pro Monat: $werte';
  }

  @override
  String get papierkorbTitel => 'Papierkorb';

  @override
  String get papierkorbEndgueltigTitel => 'Endgültig löschen?';

  @override
  String papierkorbEndgueltigText(int anzahl) {
    return '$anzahl Datei(en) unwiderruflich löschen.';
  }

  @override
  String get papierkorbLeer => 'Der Papierkorb ist leer.';

  @override
  String get videoNichtGeoeffnet => 'Video konnte nicht geöffnet werden.';

  @override
  String get videoZuschneidenFehler => 'Zuschneiden fehlgeschlagen.';

  @override
  String get videoZuschneiden => 'Zuschneiden';

  @override
  String get xmpAlleUebernehmen => 'Alle übernehmen';

  @override
  String get xmpErneutEinlesen => 'Erneut einlesen';

  @override
  String xmpKeineAbweichungen(int anzahl) {
    return '$anzahl Sidecar(s) geprüft – keine Abweichungen zur Datenbank gefunden.';
  }

  @override
  String get restaurWirdGestartet => 'Wird gestartet …';

  @override
  String get restaurAbgebrochen => 'Abgebrochen';

  @override
  String get restaurGrundModellLaedtNicht =>
      'Das Restaurierungs-Modell liess sich nicht laden.';

  @override
  String get restaurGrundModellWeg => 'Modell nicht mehr verfügbar.';

  @override
  String get restaurGrundFotoWeg => 'Foto wurde inzwischen gelöscht.';

  @override
  String get restaurGrundGesperrt =>
      'KI-Restaurierung ist für gesperrte Fotos nicht verfügbar.';

  @override
  String get restaurGrundAufloesung => 'Bildauflösung unbekannt.';

  @override
  String get restaurGrundNichtGerendert =>
      'Bild konnte nicht gerendert werden.';

  @override
  String get restaurGrundNichtDekodiert =>
      'Gerendertes Bild konnte nicht dekodiert werden.';

  @override
  String get restaurNichtVerfuegbar =>
      'KI-Restaurierung ist nicht verfügbar – Modell nicht installiert.';

  @override
  String personSchwelleWieAllgemein(String allgemein) {
    return 'weiterhin $allgemein';
  }

  @override
  String personWiedererkennung(
      String erklaerung, int bestaetigt, int abgelehnt) {
    String _temp0 = intl.Intl.pluralLogic(
      bestaetigt,
      locale: localeName,
      other: '$bestaetigt Bestätigungen',
      one: 'einer Bestätigung',
    );
    String _temp1 = intl.Intl.pluralLogic(
      abgelehnt,
      locale: localeName,
      other: '$abgelehnt Korrekturen',
      one: 'einer Korrektur',
    );
    return 'Wiedererkennung: $erklaerung. Aus $_temp0 und $_temp1.';
  }

  @override
  String get infoKeineUnbenannten =>
      'Keine unbenannten Gesichter auf diesem Foto gefunden – falls noch keine Gesichtserkennung gelaufen ist, siehe Werkzeuge → Gesichter scannen.';

  @override
  String get infoTitel => 'Info';

  @override
  String get infoBeschreibungHinzufuegen => 'Beschreibung hinzufügen';

  @override
  String get infoKiBeschreibung => 'KI-Beschreibung';

  @override
  String get infoBewertung => 'Bewertung';

  @override
  String get infoNiemandZugeordnet => 'Noch niemand zugeordnet.';

  @override
  String get infoDetails => 'Details';

  @override
  String get infoStandortBekannt => 'Standort bekannt';

  @override
  String get infoOrtNichtAufgeloest =>
      'Ort noch nicht aufgelöst (Werkzeuge → Orte)';

  @override
  String get infoOrtEntfernen => 'Ort entfernen';

  @override
  String infoSerie(int anzahl) {
    return 'Serie: $anzahl Fotos';
  }

  @override
  String get infoNurTitelbild =>
      'Nur das Titelbild ist in der Übersicht sichtbar';

  @override
  String get infoSerieAufloesen => 'Serie auflösen';

  @override
  String get infoTagHinzufuegenPlatzhalter => 'Tag hinzufügen …';

  @override
  String get stufeBildanalyse => 'Bildanalyse';

  @override
  String get stufeTexterkennung => 'Texterkennung';

  @override
  String get stufeSchlagwoerter => 'Schlagwörter';

  @override
  String get stufeBildbeschreibung => 'Bildbeschreibung';

  @override
  String get aktualisierungKeineVeroeffentlichungen =>
      'Keine Veröffentlichungen gefunden.';

  @override
  String get aktualisierungKeineVersion =>
      'Keine Versionsangabe in der Antwort gefunden.';

  @override
  String backupGrenzeErreicht(int anzahl) {
    return 'Grenze erreicht – $anzahl Datei(en) folgen beim nächsten Lauf';
  }

  @override
  String get backupPassphraseNoetig =>
      'Dieses Backup ist verschlüsselt – eine Passphrase wird benötigt.';

  @override
  String downloadPruefsummeFehler(
      String datei, String erhalten, String erwartet) {
    return 'Prüfsumme von $datei stimmt nicht mit der erwarteten SHA-256 überein (erhalten $erhalten, erwartet $erwartet) – Download verworfen. Die Datei am Server hat sich möglicherweise geändert oder wurde beim Transfer verändert.';
  }

  @override
  String downloadFehlgeschlagen(String datei, String fehler) {
    return 'Download von $datei fehlgeschlagen: $fehler';
  }

  @override
  String downloadEntpackenFehler(String datei, String fehler) {
    return 'Entpacken von $datei fehlgeschlagen: $fehler';
  }

  @override
  String downloadNichtImZip(String datei) {
    return '$datei nicht im Zip gefunden.';
  }

  @override
  String get regelAusloeserOrt => 'Ort (Umkreis)';

  @override
  String get regelAusloeserTag => 'KI-Tag';

  @override
  String get regelAusloeserDatum => 'Datumsbereich';

  @override
  String regelUmkreisUm(String km, String breite, String laenge) {
    return 'Umkreis $km km um $breite, $laenge';
  }

  @override
  String regelTagWert(String begriff) {
    return 'KI-Tag: $begriff';
  }

  @override
  String regelDatumBereich(String von, String bis) {
    return '$von – $bis';
  }

  @override
  String regelUmkreis(String km) {
    return 'Umkreis: $km km';
  }

  @override
  String regelAlbumTeil(String name) {
    return 'Album: $name';
  }

  @override
  String regelTagsTeil(String namen) {
    return 'Tags: $namen';
  }

  @override
  String duplGruppe(int nummer, int anzahl) {
    return 'Gruppe $nummer · $anzahl Fotos';
  }

  @override
  String stapelSerie(int nummer, int anzahl) {
    return 'Serie $nummer · $anzahl Fotos';
  }

  @override
  String clusterGesichterZuordnen(int anzahl) {
    return '$anzahl Gesichter zuordnen';
  }

  @override
  String clusterGesichterAnzahl(int anzahl) {
    return '$anzahl Gesichter';
  }

  @override
  String gesichtEmbeddingFehler(String fehler) {
    return 'Wiedererkennungs-Embedding fehlgeschlagen: $fehler';
  }

  @override
  String bearbSpeichernFehler(String fehler) {
    return 'Speichern fehlgeschlagen: $fehler';
  }

  @override
  String integFehlendeDateien(int anzahl) {
    return 'Fehlende Dateien ($anzahl)';
  }

  @override
  String integVerwaisteDateien(int anzahl) {
    return 'Verwaiste Dateien ($anzahl)';
  }

  @override
  String get viewerKugelSchwenken => '3D-Kugel statt flachem Schwenken';

  @override
  String get regelNeuTitel => 'Neue Automatisierungsregel';

  @override
  String get regelBearbeitenTitel => 'Regel bearbeiten';

  @override
  String presetZeileAlbum(String album) {
    return 'Album: $album';
  }

  @override
  String presetZeileTags(String tags) {
    return 'Tags: $tags';
  }

  @override
  String get presetKeineAktion => 'Keine Aktion konfiguriert';

  @override
  String get presetNeuTitel => 'Neues Kamera-Preset';

  @override
  String get presetBearbeitenTitel => 'Kamera-Preset bearbeiten';

  @override
  String allgSucheFehlgeschlagen(String fehler) {
    return 'Suche fehlgeschlagen: $fehler';
  }

  @override
  String get allgUnbekannterFehler => 'Unbekannter Fehler';

  @override
  String erkundenVorJahren(int jahre) {
    String _temp0 = intl.Intl.pluralLogic(
      jahre,
      locale: localeName,
      other: 'Vor $jahre Jahren',
      one: 'Vor 1 Jahr',
    );
    return '$_temp0';
  }

  @override
  String get gesichtBenennen => 'Gesicht benennen';

  @override
  String get gesichtUnbenannt => 'Unbenannt';

  @override
  String get bearbZuschneiden => 'Zuschneiden';

  @override
  String get bearbLinksDrehen => 'Nach links drehen';

  @override
  String get bearbRechtsDrehen => 'Nach rechts drehen';

  @override
  String get bearbHorizontalSpiegeln => 'Horizontal spiegeln';

  @override
  String get bearbVertikalSpiegeln => 'Vertikal spiegeln';

  @override
  String get integAusDbEntfernenTitel => 'Aus Datenbank entfernen?';

  @override
  String get integArtOriginal => 'Original';

  @override
  String get integArtThumbnail => 'Thumbnail';

  @override
  String get integArtVorschau => 'Vorschau';

  @override
  String get integArtEntwickelt => 'Entwickeltes Bild';

  @override
  String get integArtRestauriert => 'KI-restauriertes Bild';

  @override
  String get integArtVideoZuschnitt => 'Geschnittenes Video';

  @override
  String get integArtGesichtsCrop => 'Gesichts-Crop';

  @override
  String get integArtMaske => 'KI-Maske';

  @override
  String get integAlleVerwaistenLoeschen => 'Alle löschen';

  @override
  String get integAlleVerwaistenTitel => 'Alle verwaisten Dateien löschen?';

  @override
  String integAlleVerwaistenText(int anzahl, String groesse) {
    return '$anzahl Dateien mit zusammen $groesse werden unwiderruflich von der Platte gelöscht. Sie sind in keiner Datenbankzeile verzeichnet – die Bibliothek verliert dadurch nichts, was sie anzeigen könnte.';
  }

  @override
  String integVerwaisteGeloescht(int anzahl) {
    return '$anzahl verwaiste Dateien gelöscht.';
  }

  @override
  String integWeitereEintraege(int anzahl, int gezeigt) {
    return '… und $anzahl weitere. Die Liste zeigt nur die ersten $gezeigt; „Alle löschen“ räumt auch den Rest weg.';
  }

  @override
  String get gesperrtTabFotos => 'Fotos';

  @override
  String get gesperrtTabPapierkorb => 'Papierkorb';

  @override
  String get karteHell => 'Hell';

  @override
  String get karteDunkel => 'Dunkel';

  @override
  String get karteGlobus => 'Globus';

  @override
  String zweitVergleichFehlgeschlagen(String fehler) {
    return 'Vergleich fehlgeschlagen: $fehler';
  }

  @override
  String xmpEinlesenFehlgeschlagen(String fehler) {
    return 'Einlesen fehlgeschlagen: $fehler';
  }

  @override
  String get xmpFeldBewertung => 'Bewertung';

  @override
  String get xmpFeldFarbmarkierung => 'Farbmarkierung';

  @override
  String get xmpFeldBeschreibung => 'Beschreibung';

  @override
  String get xmpFeldNeueTags => 'Neue Tags';

  @override
  String get xmpFeldStandort => 'Standort';

  @override
  String get xmpKeineSidecars => 'Keine XMP-Sidecars gefunden.';

  @override
  String get liveWiedergabeStoppen => 'Wiedergabe stoppen';

  @override
  String get liveDauerschleife => 'In Dauerschleife abspielen';

  @override
  String get metaHersteller => 'Kamera-Hersteller';

  @override
  String get metaModell => 'Kamera-Modell';

  @override
  String get metaObjektiv => 'Objektiv';

  @override
  String get metaBrennweite => 'Brennweite (mm)';

  @override
  String get metaBlende => 'Blende (f/…)';

  @override
  String get metaBelichtungszeit => 'Belichtungszeit';

  @override
  String get passphraseZuKurz =>
      'Passphrase muss mindestens 8 Zeichen lang sein.';

  @override
  String get exportVorgabenTitel => 'Export-Voreinstellungen';

  @override
  String get exportVorgabenLeer =>
      'Noch keine Voreinstellung. Eine Voreinstellung merkt sich Grösse, Qualität und Dateibenennung – für alles, was Sie öfter als einmal exportieren.';

  @override
  String get exportVorgabeNeu => 'Neue Voreinstellung';

  @override
  String get exportVorgabeNeuTitel => 'Neue Export-Voreinstellung';

  @override
  String get exportVorgabeBearbeitenTitel => 'Voreinstellung bearbeiten';

  @override
  String get exportVorgabeName => 'Name';

  @override
  String get exportVorgabeNameNoetig => 'Bitte einen Namen vergeben.';

  @override
  String get exportVorgabeNachJpeg => 'Nach JPEG rendern';

  @override
  String get exportVorgabeNachJpegHinweis =>
      'Ohne das wird die Datei unverändert kopiert – der einzige Weg, der RAW und Videos unangetastet lässt.';

  @override
  String get exportVorgabeKante => 'Längere Kante (Pixel)';

  @override
  String get exportVorgabeKanteLeer => 'leer = volle Auflösung';

  @override
  String get exportVorgabeKanteUngueltig =>
      'Die Kantenlänge muss zwischen 64 und 20000 liegen.';

  @override
  String exportVorgabeQualitaet(int prozent) {
    return 'JPEG-Qualität: $prozent %';
  }

  @override
  String get exportVorgabeMuster => 'Namensmuster';

  @override
  String get exportVorgabeMusterNoetig =>
      'Das Namensmuster darf nicht leer sein.';

  @override
  String get exportVorgabeMusterHinweis =>
      'Die Endung wird immer selbst ergänzt. Die laufende Nummer zählt innerhalb eines Export-Laufs und wird vierstellig aufgefüllt.';

  @override
  String get exportVorgabeXmp => 'XMP-Beistelldatei mitschreiben';

  @override
  String get exportVorgabeXmpHinweis =>
      'Bewertung, Schlagwörter und Ort für andere Programme – als eigene Datei neben dem Foto.';

  @override
  String exportVorgabeJpegVoll(int prozent) {
    return 'JPEG, volle Auflösung, $prozent %';
  }

  @override
  String exportVorgabeJpegKante(int kante, int prozent) {
    return 'JPEG, lange Kante $kante px, $prozent %';
  }

  @override
  String get exportVorgabeOhneXmp => 'ohne XMP';

  @override
  String get exportVorgabeLoeschenTitel => 'Voreinstellung löschen?';

  @override
  String exportVorgabeLoeschenText(String name) {
    return '„$name\" wird entfernt. Bereits exportierte Dateien bleiben unberührt.';
  }

  @override
  String get exportEigeneVorgaben => 'Eigene Voreinstellungen';

  @override
  String get exportVorgabenVerwalten => 'Voreinstellungen verwalten …';

  @override
  String get werkzExportVorgabenTitel => 'Export-Voreinstellungen';

  @override
  String get werkzExportVorgabenText =>
      'Benannte Ausgabe-Vorgaben für den Export: Grösse, JPEG-Qualität, Dateibenennung und ob eine XMP-Beistelldatei mitgeschrieben wird.';

  @override
  String get exportVorgabeNameVergeben => 'Diesen Namen gibt es schon.';

  @override
  String get entwObjektivkorrekturKeinRaw =>
      'Kein RAW – die Kamera hat Verzeichnung und Vignettierung bereits korrigiert.';

  @override
  String get entwObjektivkorrekturVerfuegbar =>
      'Kamera und Objektiv sind bekannt: Verzeichnung und Vignettierung werden korrigiert.';

  @override
  String get entwObjektivkorrekturUnbekanntesObjektiv =>
      'Für diese Kamera gibt es kein Profil. Bei ProRAW-Aufnahmen ist das kein Mangel – die Korrektur steckt schon in der Datei.';

  @override
  String get entwObjektivkorrekturNichtLesbar =>
      'Die RAW-Daten dieser Datei lassen sich nicht öffnen. Auch die übrigen Regler wirken deshalb nur auf die eingebettete Vorschau.';

  @override
  String get einstSuche => 'Suche nach Einstellungen';

  @override
  String get einstNichtsGefunden => 'Keine Einstellung passt zu dieser Suche.';

  @override
  String get einstBeschrErscheinungsbild => 'Hell, dunkel oder wie das System';

  @override
  String get einstBeschrSprache =>
      'Sprache der Oberfläche und der Schlagwörter';

  @override
  String get einstBeschrUeberwacht =>
      'Ordner, aus denen neue Fotos von selbst hereinkommen';

  @override
  String get einstBeschrBibliotheken =>
      'Zwischen mehreren Bibliotheken wechseln';

  @override
  String get einstBeschrSpeicherort =>
      'Wo die Bibliothek liegt und wie viel Platz sie braucht';

  @override
  String get einstBeschrModelle =>
      'Herunterladen und entfernen der lokalen Modelle';

  @override
  String get einstBeschrHintergrund =>
      'Ob nach dem Import automatisch ausgewertet wird';

  @override
  String get einstBeschrVokabular =>
      'Die Begriffe, nach denen Fotos beschlagwortet werden';

  @override
  String get einstBeschrStandortdaten =>
      'Ortsnamen zu GPS-Koordinaten, offline';

  @override
  String get einstBeschrGesperrt => 'PIN, Verschlüsselung und was darin liegt';

  @override
  String get einstBeschrBackupSchluessel =>
      'Passphrase für verschlüsselte Sicherungen';

  @override
  String get einstBeschrBackupManuell => 'Eine Sicherung von Hand anstoßen';

  @override
  String get einstBeschrBackupAuto =>
      'Regelmäßig sichern, ohne daran zu denken';

  @override
  String get einstBeschrPapierkorb =>
      'Wann gelöschte Fotos endgültig verschwinden';

  @override
  String get einstBeschrGefahr =>
      'Schritte, die sich nicht rückgängig machen lassen';

  @override
  String get einstBeschrUeber => 'Version, Lizenzen und Aktualisierungen';

  @override
  String get allgRueckgaengig => 'Rückgängig';

  @override
  String get personenIgnoriertTab => 'Ignoriert';

  @override
  String tabMitZahl(String beschriftung, int anzahl) {
    return '$beschriftung ($anzahl)';
  }

  @override
  String get personenIgnorierenTooltip => 'Ausgewählte Gesichter ignorieren';

  @override
  String personenIgnoriertMeldung(int anzahl) {
    String _temp0 = intl.Intl.pluralLogic(
      anzahl,
      locale: localeName,
      other: '$anzahl Gesichter ignoriert.',
      one: 'Ein Gesicht ignoriert.',
    );
    return '$_temp0';
  }

  @override
  String get personenIgnoriertLeer =>
      'Keine ignorierten Gesichter. Was du unter „Unbenannte Gesichter“ beiseitelegst – Plakate, Spiegelungen, Statuen –, sammelt sich hier und lässt sich jederzeit zurückholen.';

  @override
  String get personenIgnoriertHinweis =>
      'Ignorierte Gesichter erscheinen nicht mehr im Raster und werden nicht mehr gruppiert. Doppelklick öffnet das ganze Foto.';

  @override
  String personenIgnoriertTeilHinweis(int gezeigt, int gesamt) {
    return '$gezeigt von $gesamt ignorierten Gesichtern. Doppelklick öffnet das ganze Foto.';
  }

  @override
  String personenZurueckholenKnopf(int anzahl) {
    return '$anzahl zurückholen';
  }

  @override
  String get clusterPhaseLaden => 'Gesichter werden geladen …';

  @override
  String get clusterPhaseVergleichen => 'Gesichter werden verglichen …';

  @override
  String get clusterPhaseVorschlaege => 'Vorschläge werden vorbereitet …';

  @override
  String get clusterOhneProzent => 'Läuft …';

  @override
  String clusterFehlgeschlagen(String fehler) {
    return 'Die automatische Gruppierung ist fehlgeschlagen: $fehler';
  }

  @override
  String get clusterIgnorierenTooltip => 'Ganze Gruppe ignorieren';

  @override
  String get gesichtIgnorieren => 'Ignorieren';

  @override
  String get gesichtIgnoriert => 'Ignoriert';

  @override
  String get gesichtZurueckgeholt => 'Gesicht wird wieder berücksichtigt.';

  @override
  String gesichtPosition(int nummer, int gesamt) {
    return '$nummer von $gesamt';
  }

  @override
  String get gesichtVoriges => 'Vorheriges Foto (Pfeil links)';

  @override
  String get gesichtNaechstes => 'Nächstes Foto (Pfeil rechts)';

  @override
  String get clusterUnerwartetBeendet =>
      'Die automatische Gruppierung wurde unerwartet beendet.';

  @override
  String get aufgAktiv => 'Aktiv';

  @override
  String aufgStufeKurz(int nummer, int gesamt) {
    return 'Stufe $nummer/$gesamt';
  }

  @override
  String get personenAlleIgnorieren => 'Alle unbenannten Gesichter ignorieren';

  @override
  String personenAlleIgnorierenHinweis(int anzahl) {
    String _temp0 = intl.Intl.pluralLogic(
      anzahl,
      locale: localeName,
      other: '$anzahl Gesichter wandern nach „Ignoriert“',
      one: 'Ein Gesicht wandert nach „Ignoriert“',
      zero: 'Nichts mehr offen',
    );
    return '$_temp0';
  }

  @override
  String personenAlleIgnoriertMeldung(int anzahl) {
    String _temp0 = intl.Intl.pluralLogic(
      anzahl,
      locale: localeName,
      other:
          '$anzahl Gesichter ignoriert. Unter „Ignoriert“ holst du einzelne zurück.',
      one: 'Ein Gesicht ignoriert. Unter „Ignoriert“ holst du einzelne zurück.',
      zero: 'Es war nichts zu ignorieren.',
    );
    return '$_temp0';
  }

  @override
  String get personenAlleErkennungenLoeschen =>
      'Alle unbenannten Erkennungen löschen';

  @override
  String get personenAlleErkennungenLoeschenHinweis =>
      'Gibt Platz frei, kommt beim nächsten Scan aber wieder';

  @override
  String get personenErkennungenLoeschenTitel =>
      'Erkennungen wirklich löschen?';

  @override
  String get personenErkennungenLoeschenText =>
      'Alle unbenannten Erkennungen werden samt ihrer Ausschnitte von der Platte gelöscht – auch die bereits ignorierten. Benannte Personen bleiben unberührt.\n\nDas ist nicht dauerhaft: Der nächste Gesichts-Scan findet dieselben Stellen wieder. Wenn du sie dauerhaft loswerden willst, nimm stattdessen „Alle unbenannten Gesichter ignorieren“ – das überlebt auch einen erneuten Scan.';

  @override
  String personenErkennungenGeloeschtMeldung(int anzahl) {
    String _temp0 = intl.Intl.pluralLogic(
      anzahl,
      locale: localeName,
      other: '$anzahl Erkennungen gelöscht.',
      one: 'Eine Erkennung gelöscht.',
      zero: 'Es gab keine Erkennungen zum Löschen.',
    );
    return '$_temp0';
  }

  @override
  String get gesichtZuordnungLoesen => 'Zuordnung lösen';

  @override
  String get gesichtNichtMehrIgnorieren => 'Nicht mehr ignorieren';

  @override
  String get gesichtFotoLoeschen => 'Foto löschen';

  @override
  String get gesichtErkennungLoeschen => 'Erkennung löschen';

  @override
  String gesichtAlleUnbenanntenIgnorieren(int anzahl) {
    String _temp0 = intl.Intl.pluralLogic(
      anzahl,
      locale: localeName,
      other: '$anzahl unbenannte Gesichter ignorieren',
      one: 'Unbenanntes Gesicht ignorieren',
      zero: 'Keine unbenannten Gesichter',
    );
    return '$_temp0';
  }

  @override
  String get personWeitereFotosSuchen => 'Weitere Fotos suchen';

  @override
  String vorschlagTitel(String name) {
    return 'Vorschläge für $name';
  }

  @override
  String get vorschlagHinweis =>
      'Alles ist ausgewählt. Nimm heraus, was nicht stimmt – auch das lernt die Erkennung: Eine Ablehnung schiebt die Schwelle für diese Person nach oben.';

  @override
  String get vorschlagAlleWaehlen => 'Alle wählen';

  @override
  String get vorschlagKeineWaehlen => 'Keine wählen';

  @override
  String vorschlagUebernehmen(int anzahl) {
    String _temp0 = intl.Intl.pluralLogic(
      anzahl,
      locale: localeName,
      other: '$anzahl Gesichter zuordnen',
      one: 'Ein Gesicht zuordnen',
      zero: 'Nichts ausgewählt',
    );
    return '$_temp0';
  }

  @override
  String vorschlagUebernommenMeldung(int anzahl) {
    String _temp0 = intl.Intl.pluralLogic(
      anzahl,
      locale: localeName,
      other: '$anzahl Fotos hinzugefügt.',
      one: 'Ein Foto hinzugefügt.',
      zero: 'Nichts übernommen – die Rückmeldung ist trotzdem gespeichert.',
    );
    return '$_temp0';
  }

  @override
  String get vorschlagKeineEmbeddings =>
      'Für diese Person gibt es noch keine Wiedererkennungs-Daten. Sie entstehen beim Gesichts-Scan, sobald das SFace-Modell installiert ist.';

  @override
  String get vorschlagKeineKandidaten =>
      'Es gibt keine unbenannten Gesichter, die vorgeschlagen werden könnten.';

  @override
  String vorschlagNichtsGefunden(String schwelle) {
    return 'Kein unbenanntes Gesicht liegt über der Schwelle $schwelle dieser Person.';
  }

  @override
  String get gesichtRahmenAusblenden => 'Rahmen ausblenden';

  @override
  String get gesichtRahmenEinblenden => 'Rahmen einblenden';

  @override
  String get entwKlarheit => 'Klarheit';

  @override
  String get entwVignettierung => 'Vignettierung';

  @override
  String get entwLutKeine => 'Keine Farbtabelle';

  @override
  String get entwLutWaehlen => 'Farbtabelle wählen (.cube)';

  @override
  String get entwLutEntfernen => 'Farbtabelle entfernen';

  @override
  String get entwLutStaerke => 'Stärke';

  @override
  String entwLutFehlt(String name) {
    return 'Die Farbtabelle „$name“ lässt sich nicht mehr lesen und wurde entfernt.';
  }

  @override
  String entwLutNichtLesbar(String fehler) {
    return 'Die Datei lässt sich nicht lesen: $fehler';
  }

  @override
  String get entwLutEindimensional =>
      'Das ist eine eindimensionale Tabelle – sie beschreibt eine Kurve, keinen Farbraum. Dafür gibt es hier die Tonwertkurve.';

  @override
  String get entwLutOhneGroesse => 'In der Datei fehlt die Angabe LUT_3D_SIZE.';

  @override
  String entwLutGroesse(int zeile) {
    return 'Die Kantenlänge in Zeile $zeile liegt außerhalb des Erlaubten (2 bis 256).';
  }

  @override
  String get entwLutZeilenzahl =>
      'Die Datei enthält nicht so viele Werte, wie ihre Kantenlänge verlangt.';

  @override
  String entwLutZeile(int zeile) {
    return 'Zeile $zeile lässt sich nicht lesen.';
  }

  @override
  String get histogrammWaveform => 'Waveform';

  @override
  String get histogrammParade => 'Parade';

  @override
  String get entwFormRechteck => 'Rechteck';

  @override
  String get entwFormFarbe => 'Farbe';

  @override
  String get entwRechteckHinweis =>
      'Ziehe ein Rechteck auf. Drehung und weiche Kante stellst du darunter ein.';

  @override
  String get entwFarbauswahlHinweis =>
      'Tippe auf eine Farbe im Bild. Ausgewählt wird alles, was ihr ähnlich genug ist – auch heller oder dunkler, denn Farbe zählt mehr als Helligkeit.';

  @override
  String entwFarbeAufgenommen(int rot, int gruen, int blau) {
    return 'R $rot · G $gruen · B $blau';
  }

  @override
  String get entwToleranz => 'Toleranz';

  @override
  String get vergleichTitel => 'Zwei Fotos vergleichen';

  @override
  String get vergleichNebeneinander => 'Nebeneinander';

  @override
  String get vergleichUebereinander => 'Übereinander';

  @override
  String get vergleichKoppeln => 'Ansichten koppeln';

  @override
  String get vergleichEntkoppeln => 'Ansichten entkoppeln';

  @override
  String get vergleichZuruecksetzen => 'Zoom zurücksetzen';

  @override
  String get auswVergleichen => 'Die zwei ausgewählten Fotos vergleichen';

  @override
  String get listeOhneKamera => 'Ohne Kameraangabe';

  @override
  String get ansichtRaster => 'Raster';

  @override
  String get ansichtListe => 'Liste';

  @override
  String get gruppeMonat => 'Nach Monat';

  @override
  String get gruppeKamera => 'Nach Kamera';

  @override
  String get gruppeKeine => 'Ohne Gliederung';

  @override
  String get bearbGeradeziehen => 'Geradeziehen';

  @override
  String get bearbPerspektive => 'Perspektive';

  @override
  String get bearbPerspektiveAnwenden => 'Entzerren';

  @override
  String get modellLamaTitel => 'Objektentfernung (LaMa)';

  @override
  String get modellLamaText =>
      'Füllt eine markierte Stelle aus der Umgebung neu auf – für Staubflecken, Passanten oder den Mülleimer am Bildrand. Mit 208 MB das grösste Modell hier; ein Durchgang dauert rund eine Sekunde.';

  @override
  String get modellLamaLizenz =>
      'Apache 2.0 (Samsung Research), ONNX-Export von Carve';

  @override
  String get bearbRetusche => 'Objekt entfernen';

  @override
  String get bearbRetuscheAnwenden => 'Entfernen';

  @override
  String get bearbRetuscheZurueck => 'Letzten Strich zurücknehmen';

  @override
  String get bearbPinselbreite => 'Pinselbreite';

  @override
  String bearbRetuscheFehler(String fehler) {
    return 'Das Entfernen ist fehlgeschlagen: $fehler';
  }

  @override
  String get stammbaumTitel => 'Stammbaum';

  @override
  String stammbaumTitelVon(String name) {
    return 'Stammbaum: $name';
  }

  @override
  String get stammbaumEltern => 'Eltern';

  @override
  String get stammbaumGeschwister => 'Geschwister';

  @override
  String get stammbaumPartner => 'Partner';

  @override
  String get stammbaumKinder => 'Kinder';

  @override
  String get stammbaumElternteilHinzufuegen => 'Elternteil hinzufügen';

  @override
  String get stammbaumPartnerHinzufuegen => 'Partner hinzufügen';

  @override
  String get stammbaumKindHinzufuegen => 'Kind hinzufügen';

  @override
  String get stammbaumInDieMitte => 'In die Mitte rücken';

  @override
  String get stammbaumLebensdaten => 'Lebensdaten …';

  @override
  String get stammbaumFotosZeigen => 'Fotos dieser Person';

  @override
  String get stammbaumVerbindungEntfernen => 'Verbindung entfernen';

  @override
  String stammbaumVerbindungEntfernenFrage(String eine, String andere) {
    return 'Die Verwandtschaft zwischen $eine und $andere wird gelöst. Beide Personen und ihre Fotos bleiben erhalten.';
  }

  @override
  String get stammbaumFehlerSelbst =>
      'Eine Person kann nicht mit sich selbst verwandt sein.';

  @override
  String get stammbaumFehlerKreis =>
      'Das ginge im Kreis: Die Person steht bereits weiter unten im selben Zweig.';

  @override
  String get stammbaumFehlerVorhanden =>
      'Diese Verwandtschaft ist schon eingetragen.';

  @override
  String get stammbaumLeer =>
      'Für diese Person ist noch keine Verwandtschaft eingetragen. Oben rechts lassen sich Eltern, Partner und Kinder hinzufügen – entweder aus den bereits benannten Personen oder als neuer Name, auch ohne ein einziges Foto.';

  @override
  String get stammbaumPersonFehlt => 'Diese Person gibt es nicht mehr.';

  @override
  String get stammbaumGeboren => 'Geboren';

  @override
  String get stammbaumGestorben => 'Gestorben';

  @override
  String get stammbaumUnbekannt => 'unbekannt';

  @override
  String get stammbaumNurJahrHinweis =>
      'Ist nur das Jahr bekannt, wähle einen beliebigen Tag darin – angezeigt wird ohnehin nur die Jahreszahl.';

  @override
  String get gradSelbst => 'diese Person';

  @override
  String gradEltern(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Mutter',
        'm': 'Vater',
        'other': 'Elternteil',
      },
    );
    return '$_temp0';
  }

  @override
  String gradGrosseltern(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Großmutter',
        'm': 'Großvater',
        'other': 'Großelternteil',
      },
    );
    return '$_temp0';
  }

  @override
  String gradUrgrosseltern(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Urgroßmutter',
        'm': 'Urgroßvater',
        'other': 'Urgroßelternteil',
      },
    );
    return '$_temp0';
  }

  @override
  String gradUrurgrosseltern(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Ururgroßmutter',
        'm': 'Ururgroßvater',
        'other': 'Ururgroßelternteil',
      },
    );
    return '$_temp0';
  }

  @override
  String gradVorfahreN(int stufe) {
    return 'Vorfahre der $stufe. Generation';
  }

  @override
  String gradKind(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Tochter',
        'm': 'Sohn',
        'other': 'Kind',
      },
    );
    return '$_temp0';
  }

  @override
  String gradEnkel(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Enkelin',
        'm': 'Enkel',
        'other': 'Enkelkind',
      },
    );
    return '$_temp0';
  }

  @override
  String gradUrenkel(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Urenkelin',
        'm': 'Urenkel',
        'other': 'Urenkelkind',
      },
    );
    return '$_temp0';
  }

  @override
  String gradUrurenkel(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Ururenkelin',
        'm': 'Ururenkel',
        'other': 'Ururenkelkind',
      },
    );
    return '$_temp0';
  }

  @override
  String gradNachkommeN(int stufe) {
    return 'Nachkomme der $stufe. Generation';
  }

  @override
  String gradGeschwister(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Schwester',
        'm': 'Bruder',
        'other': 'Geschwister',
      },
    );
    return '$_temp0';
  }

  @override
  String gradHalbgeschwister(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Halbschwester',
        'm': 'Halbbruder',
        'other': 'Halbgeschwister',
      },
    );
    return '$_temp0';
  }

  @override
  String gradNeffeNichte(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Nichte',
        'm': 'Neffe',
        'other': 'Geschwisterkind',
      },
    );
    return '$_temp0';
  }

  @override
  String gradGrossneffeNichte(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Großnichte',
        'm': 'Großneffe',
        'other': 'Großgeschwisterkind',
      },
    );
    return '$_temp0';
  }

  @override
  String gradGeschwisterNachkommeN(int stufe) {
    return 'Nachkomme eines Geschwisters, $stufe Stufen entfernt';
  }

  @override
  String gradOnkelTante(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Tante',
        'm': 'Onkel',
        'other': 'Elterngeschwister',
      },
    );
    return '$_temp0';
  }

  @override
  String gradGrossonkelTante(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Großtante',
        'm': 'Großonkel',
        'other': 'Großelterngeschwister',
      },
    );
    return '$_temp0';
  }

  @override
  String gradVorfahrengeschwisterN(int stufe) {
    return 'Geschwister eines Vorfahren der $stufe. Generation';
  }

  @override
  String gradCousin(String geschlecht, int stufe) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Cousine',
        'm': 'Cousin',
        'other': 'Cousin/Cousine',
      },
    );
    return '$_temp0 $stufe. Grades';
  }

  @override
  String gradEntfernt(int stufe, String bezeichnung) {
    return '$bezeichnung, $stufe-fach entfernt';
  }

  @override
  String gradPartner(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Partnerin',
        'm': 'Partner',
        'other': 'Partner',
      },
    );
    return '$_temp0';
  }

  @override
  String gradSchwager(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Schwägerin',
        'm': 'Schwager',
        'other': 'Schwager/Schwägerin',
      },
    );
    return '$_temp0';
  }

  @override
  String gradSchwiegereltern(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Schwiegermutter',
        'm': 'Schwiegervater',
        'other': 'Schwiegerelternteil',
      },
    );
    return '$_temp0';
  }

  @override
  String gradSchwiegerkind(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Schwiegertochter',
        'm': 'Schwiegersohn',
        'other': 'Schwiegerkind',
      },
    );
    return '$_temp0';
  }

  @override
  String gradStiefeltern(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Stiefmutter',
        'm': 'Stiefvater',
        'other': 'Stiefelternteil',
      },
    );
    return '$_temp0';
  }

  @override
  String gradStiefkind(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Stieftochter',
        'm': 'Stiefsohn',
        'other': 'Stiefkind',
      },
    );
    return '$_temp0';
  }

  @override
  String gradStiefgeschwister(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Stiefschwester',
        'm': 'Stiefbruder',
        'other': 'Stiefgeschwister',
      },
    );
    return '$_temp0';
  }

  @override
  String get gradAngeheiratet => 'angeheiratet';

  @override
  String get gradKeine => 'nicht verwandt';

  @override
  String get navStammbaum => 'Stammbaum';

  @override
  String get stammbaumAndereWaehlen => 'Andere Person in die Mitte';

  @override
  String get stammbaumAnsichtBaum => 'Baum';

  @override
  String get stammbaumAnsichtListe => 'Verwandte';

  @override
  String stammbaumListeKopf(String name, int anzahl) {
    String _temp0 = intl.Intl.pluralLogic(
      anzahl,
      locale: localeName,
      other:
          '$anzahl Personen sind mit $name verwandt – von den nächsten zu den entferntesten.',
      one: 'Eine Person ist mit $name verwandt.',
    );
    return '$_temp0';
  }

  @override
  String get stammbaumKeinePersonen =>
      'Es sind noch keine Personen angelegt. Benenne im Tab „Personen\" ein paar Gesichter, oder lege hier über „Andere Person in die Mitte\" jemanden von Hand an.';

  @override
  String get stammbaumGeschlecht => 'Geschlecht';

  @override
  String get stammbaumGeschlechtWeiblich => 'weiblich';

  @override
  String get stammbaumGeschlechtMaennlich => 'männlich';

  @override
  String get stammbaumGeschlechtDivers => 'divers';

  @override
  String get stammbaumGeschlechtOffen => 'keine Angabe';

  @override
  String get stammbaumGeschlechtHinweis =>
      'Wird nur für die Verwandtschaftsbezeichnungen gebraucht – ohne Angabe steht dort „Geschwister\" statt „Schwester\".';

  @override
  String get stammbaumAngaben => 'Angaben zur Person';

  @override
  String get stammbaumAnsichtFaecher => 'Fächer';

  @override
  String get stammbaumAnsichtNachfahren => 'Nachfahren';

  @override
  String get stammbaumKeineVorfahren =>
      'Für diese Person sind noch keine Vorfahren eingetragen. Der Fächer zeigt Eltern, Großeltern und Urgroßeltern – füge oben rechts einen Elternteil hinzu, und er füllt sich von innen nach außen.';

  @override
  String get stammbaumKeineNachfahren =>
      'Für diese Person sind noch keine Kinder eingetragen. Die Gliederung zeigt alle Nachkommen, eingerückt nach Generation.';

  @override
  String get stammbaumFamilienfotos => 'Fotos der Familie';

  @override
  String stammbaumFamilienfotosVon(String name) {
    return 'Fotos der Familie von $name';
  }

  @override
  String get stammbaumKeineFamilienfotos =>
      'Auf keinem Foto wurde bisher jemand aus dieser Familie erkannt.';

  @override
  String get stammbaumGedcomExport => 'Als GEDCOM ausgeben …';

  @override
  String stammbaumGedcomFertig(int anzahl) {
    String _temp0 = intl.Intl.pluralLogic(
      anzahl,
      locale: localeName,
      other: '$anzahl Personen ausgegeben.',
      one: 'Eine Person ausgegeben.',
    );
    return '$_temp0';
  }

  @override
  String gradAdoptiveltern(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Adoptivmutter',
        'm': 'Adoptivvater',
        'other': 'Adoptivelternteil',
      },
    );
    return '$_temp0';
  }

  @override
  String gradPflegeeltern(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Pflegemutter',
        'm': 'Pflegevater',
        'other': 'Pflegeelternteil',
      },
    );
    return '$_temp0';
  }

  @override
  String gradAdoptivkind(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Adoptivtochter',
        'm': 'Adoptivsohn',
        'other': 'Adoptivkind',
      },
    );
    return '$_temp0';
  }

  @override
  String gradPflegekind(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Pflegetochter',
        'm': 'Pflegesohn',
        'other': 'Pflegekind',
      },
    );
    return '$_temp0';
  }

  @override
  String get stammbaumLeiblich => 'Leiblich';

  @override
  String get stammbaumAdoptiv => 'Adoptiv';

  @override
  String get stammbaumPflege => 'Pflege';

  @override
  String get stammbaumAnsichtSanduhr => 'Sanduhr';

  @override
  String get stammbaumSeitenlinien => 'Seitenlinie';

  @override
  String get stammbaumSeitenlinienHinweis =>
      'Geschwister neben der Person, deren Kinder darunter – so werden auch Neffen, Nichten und Schwäger sichtbar.';

  @override
  String lebenslaufVon(String name) {
    return 'Lebenslauf: $name';
  }

  @override
  String get lebenslaufHinzufuegen => 'Ereignis hinzufügen';

  @override
  String get lebenslaufLeer =>
      'Für diese Person ist noch nichts eingetragen. Geburt und Tod stehen bei den Angaben zur Person; hier kommen Hochzeit, Umzug, Beruf und alles Weitere hin.';

  @override
  String get lebenslaufGeburt => 'Geboren';

  @override
  String get lebenslaufTod => 'Gestorben';

  @override
  String get lebenslaufHochzeit => 'Hochzeit';

  @override
  String get lebenslaufUmzug => 'Umzug';

  @override
  String get lebenslaufBeruf => 'Beruf';

  @override
  String get lebenslaufAusbildung => 'Ausbildung';

  @override
  String get lebenslaufSonstiges => 'Sonstiges';

  @override
  String get lebenslaufOhneDatum => 'ohne Datum';

  @override
  String get lebenslaufOrt => 'Ort';

  @override
  String get lebenslaufNotiz => 'Notiz';

  @override
  String get stammbaumLebenslauf => 'Lebenslauf …';

  @override
  String get orteIch => 'Diese Person';

  @override
  String get orteVorfahren => 'Vorfahren';

  @override
  String get orteNachkommen => 'Nachkommen';

  @override
  String get orteSeitenlinie => 'Seitenlinie';

  @override
  String get orteAngeheiratet => 'Angeheiratet';

  @override
  String get orteNichtsGewaehlt => 'Keine Gruppe ausgewählt.';

  @override
  String get stammbaumFamilienorte => 'Orte der Familie';

  @override
  String get stammbaumMenue => 'Mehr zu dieser Person';

  @override
  String get stammbaumVerbindungsart => 'Art der Verbindung …';

  @override
  String stammbaumVerbindungsartTitel(String kind, String elternteil) {
    return 'Wie ist $kind mit $elternteil verbunden?';
  }

  @override
  String get stammbaumVerbindungsartHinweis =>
      'Adoptiv- und Pflegeeltern zählen überall als Eltern – nur die Bezeichnung und die gestrichelte Linie unterscheiden sie.';

  @override
  String get stammbaumNichtsEntfernt => 'Diese Verbindung war schon gelöst.';

  @override
  String get stammbaumWeitereVerwandte => 'Weitere Verwandte';

  @override
  String get stammbaumVerwandtenHinzufuegen => 'Verwandten hinzufügen …';

  @override
  String get stammbaumGruppeVorfahren => 'Vorfahren';

  @override
  String get stammbaumGruppeNachkommen => 'Nachkommen';

  @override
  String get stammbaumGruppeSeitenlinie => 'Seitenlinie';

  @override
  String get stammbaumGruppeAngeheiratet => 'Angeheiratet';

  @override
  String get stammbaumGradGrosselternteil => 'Großelternteil';

  @override
  String get stammbaumGradUrgrosselternteil => 'Urgroßelternteil';

  @override
  String get stammbaumGradEnkelkind => 'Enkelkind';

  @override
  String get stammbaumGradUrenkelkind => 'Urenkelkind';

  @override
  String get stammbaumGradGeschwisterkind => 'Geschwisterkind';

  @override
  String get stammbaumGradHalbgeschwisterkind => 'Halbgeschwisterkind';

  @override
  String get stammbaumGradOnkelTante => 'Onkel oder Tante';

  @override
  String get stammbaumGradNeffeNichte => 'Neffe oder Nichte';

  @override
  String get stammbaumGradCousin => 'Cousin oder Cousine';

  @override
  String get stammbaumGradSchwiegerelternteil => 'Schwiegerelternteil';

  @override
  String get stammbaumGradSchwiegerkind => 'Schwiegerkind';

  @override
  String get stammbaumGradSchwager => 'Schwager oder Schwägerin';

  @override
  String get stammbaumGradStiefelternteil => 'Stiefelternteil';

  @override
  String get stammbaumGradStiefkind => 'Stiefkind';

  @override
  String stammbaumFehltElternteil(String name) {
    return 'Dafür braucht $name zuerst einen Elternteil.';
  }

  @override
  String stammbaumFehltGrosselternteil(String name) {
    return 'Dafür braucht $name zuerst Großeltern.';
  }

  @override
  String stammbaumFehltKind(String name) {
    return 'Dafür braucht $name zuerst ein Kind.';
  }

  @override
  String stammbaumFehltEnkelkind(String name) {
    return 'Dafür braucht $name zuerst ein Enkelkind.';
  }

  @override
  String stammbaumFehltGeschwister(String name) {
    return 'Dafür braucht $name zuerst ein Geschwisterkind.';
  }

  @override
  String stammbaumFehltOnkelTante(String name) {
    return 'Dafür braucht $name zuerst einen Onkel oder eine Tante.';
  }

  @override
  String stammbaumFehltPartner(String name) {
    return 'Dafür braucht $name zuerst einen Partner.';
  }

  @override
  String stammbaumFehltGeschwisterOderPartner(String name) {
    return 'Dafür braucht $name zuerst ein Geschwisterkind oder einen Partner.';
  }

  @override
  String stammbaumUeberWen(String grad) {
    return '$grad – über wen?';
  }

  @override
  String stammbaumVerwandterEingetragen(String name, String bezeichnung) {
    return '$name ist eingetragen – $bezeichnung.';
  }

  @override
  String stammbaumNurEintragbares(String name) {
    return 'Gezeigt wird, was sich für $name eintragen lässt. Grau bedeutet: Dafür fehlt noch eine Zwischenperson.';
  }

  @override
  String stammbaumFamilienorteVon(String name) {
    return 'Orte der Familie von $name';
  }

  @override
  String get stammbaumKeineFamilienorte =>
      'Von dieser Familie ist kein Foto mit Ortsangabe vorhanden.';

  @override
  String get stammbaumTafelDrucken => 'Tafel als PDF …';

  @override
  String get stammbaumTafelFertig => 'Die Tafel wurde geschrieben.';

  @override
  String get aufgWirdErmittelt => 'Wird ermittelt …';

  @override
  String aufgAbgebrochenBei(int erledigt, int gesamt) {
    return 'Abgebrochen bei $erledigt von $gesamt';
  }

  @override
  String aufgFertigMit(int gesamt) {
    return 'Fertig – $gesamt bearbeitet';
  }

  @override
  String get beendenTitel => 'Es wird noch ausgewertet';

  @override
  String get beendenText =>
      'Beim Beenden geht die gerade bearbeitete Datei verloren; alles bereits Ausgewertete bleibt erhalten. Noch am Laufen:';

  @override
  String get beendenTrotzdem => 'Trotzdem beenden';

  @override
  String get beendenWeiterlaufen => 'Weiterlaufen lassen';

  @override
  String get aufgUebersetzenTitel => 'Beschreibungen übersetzen';

  @override
  String get aufgUebersetzenText =>
      'Überträgt die vorhandenen englischen KI-Bildunterschriften ins Deutsche – ohne das Beschreibungsmodell erneut laufen zu lassen.';

  @override
  String get aufgUebersetzungsmodell =>
      'das Übersetzungsmodell Englisch → Deutsch';

  @override
  String get werkzUebersetzeBeschreibungen => 'Übersetze Bildbeschreibungen …';

  @override
  String get werkzAlleUebersetzt => 'Alle Beschreibungen sind übersetzt.';

  @override
  String werkzLaeuftSchon(String titel) {
    return 'Läuft bereits als Hintergrundaufgabe: $titel';
  }

  @override
  String get aufgLaeuftSchon => 'Diese Auswertung läuft bereits.';

  @override
  String get aufgAndereLaeuft =>
      'Es läuft bereits eine andere Auswertung. Teure Auswertungen laufen nacheinander, damit nicht mehrere KI-Modelle gleichzeitig im Speicher liegen.';

  @override
  String get aufgAnalyseLaeuft =>
      'Die Hintergrundanalyse arbeitet gerade dieselben Schritte ab. Sie lässt sich oben in der Karte „Alles nachholen“ anhalten.';

  @override
  String get infoKiBeschreibungVonHand => 'KI-Beschreibung, von Hand geändert';

  @override
  String get infoKiVonHandHinweis =>
      'Bleibt bei „Alle Fotos“ erhalten. Zum Neuberechnen das Feld leeren.';

  @override
  String get infoSpracheDe => 'DE';

  @override
  String get infoSpracheEn => 'EN';

  @override
  String get infoKiPlatzhalterDe => 'Deutsche Fassung eintragen';

  @override
  String get infoKiPlatzhalterEn => 'Englische Fassung eintragen';

  @override
  String duplGefunden(int gruppen, int fotos) {
    return '$gruppen Gruppen mit $fotos Fotos';
  }

  @override
  String get duplNichtsGefunden => 'Keine Gruppen gefunden';

  @override
  String get duplGruppeIgnorieren => 'Übergehen';

  @override
  String duplGruppeIgnoriert(int anzahl) {
    return '$anzahl Fotos werden bei der Duplikatsuche künftig übergangen.';
  }

  @override
  String duplAusnahmenZahl(int anzahl) {
    return '$anzahl übergangen';
  }

  @override
  String get duplAusnahmenTitel => 'Übergangene wieder anzeigen';

  @override
  String duplAusnahmenFrage(int anzahl) {
    return '$anzahl Paare sind von der Suche ausgenommen. Sollen alle wieder berücksichtigt werden?';
  }

  @override
  String get duplAusnahmenLoeschen => 'Alle wieder anzeigen';

  @override
  String get entwNurMitCoreImage =>
      'Schärfe, Rauschunterdrückung, Klarheit und Vignettierung brauchen Rechenschritte, die es nur unter macOS gibt. Die übrigen Regler wirken hier vollständig.';

  @override
  String get modellOcrTitel => 'Texterkennung (PaddleOCR)';

  @override
  String get modellOcrText =>
      'Findet Text in Fotos und liest ihn – zwei Modelle, zusammen 13,7 MB. Deckt das lateinische Alphabet samt Umlauten und ß ab. Unter macOS nicht nötig: Dort erledigt das Apples Vision-Framework ohne Download.';

  @override
  String get modellOcrLizenz => 'Apache 2.0 (PaddleOCR)';

  @override
  String get aufgOcrModell => 'das Texterkennungs-Modell';
}
