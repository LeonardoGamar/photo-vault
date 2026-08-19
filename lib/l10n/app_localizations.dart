import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppTexte
/// returned by `AppTexte.of(context)`.
///
/// Applications need to include `AppTexte.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppTexte.localizationsDelegates,
///   supportedLocales: AppTexte.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppTexte.supportedLocales
/// property.
abstract class AppTexte {
  AppTexte(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppTexte of(BuildContext context) {
    return Localizations.of<AppTexte>(context, AppTexte)!;
  }

  static const LocalizationsDelegate<AppTexte> delegate = _AppTexteDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en')
  ];

  /// Verwirft einen Dialog, ohne etwas zu ändern.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get allgAbbrechen;

  /// No description provided for @allgSpeichern.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get allgSpeichern;

  /// No description provided for @allgSchliessen.
  ///
  /// In de, this message translates to:
  /// **'Schließen'**
  String get allgSchliessen;

  /// No description provided for @allgErstellen.
  ///
  /// In de, this message translates to:
  /// **'Erstellen'**
  String get allgErstellen;

  /// No description provided for @allgStarten.
  ///
  /// In de, this message translates to:
  /// **'Starten'**
  String get allgStarten;

  /// No description provided for @allgName.
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get allgName;

  /// No description provided for @allgMehr.
  ///
  /// In de, this message translates to:
  /// **'Mehr'**
  String get allgMehr;

  /// No description provided for @allgAlleAnzeigen.
  ///
  /// In de, this message translates to:
  /// **'Alle anzeigen'**
  String get allgAlleAnzeigen;

  /// No description provided for @navTimeline.
  ///
  /// In de, this message translates to:
  /// **'Timeline'**
  String get navTimeline;

  /// No description provided for @navErkunden.
  ///
  /// In de, this message translates to:
  /// **'Erkunden'**
  String get navErkunden;

  /// No description provided for @navKalender.
  ///
  /// In de, this message translates to:
  /// **'Kalender'**
  String get navKalender;

  /// No description provided for @navKarte.
  ///
  /// In de, this message translates to:
  /// **'Karte'**
  String get navKarte;

  /// No description provided for @navSuche.
  ///
  /// In de, this message translates to:
  /// **'Suche'**
  String get navSuche;

  /// No description provided for @navPersonen.
  ///
  /// In de, this message translates to:
  /// **'Personen'**
  String get navPersonen;

  /// No description provided for @navAlben.
  ///
  /// In de, this message translates to:
  /// **'Alben'**
  String get navAlben;

  /// No description provided for @navWerkzeuge.
  ///
  /// In de, this message translates to:
  /// **'Werkzeuge'**
  String get navWerkzeuge;

  /// No description provided for @navEinstellungen.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get navEinstellungen;

  /// No description provided for @importierenTooltip.
  ///
  /// In de, this message translates to:
  /// **'Fotos/Videos importieren'**
  String get importierenTooltip;

  /// Nur sichtbar, wenn mehr als eine Bibliothek bekannt ist.
  ///
  /// In de, this message translates to:
  /// **'Geöffnete Bibliothek: {name}'**
  String geoeffneteBibliothek(String name);

  /// No description provided for @restaurierungLaeuft.
  ///
  /// In de, this message translates to:
  /// **'KI-Restaurierung läuft – Kachel {fertig}/{gesamt}'**
  String restaurierungLaeuft(int fertig, int gesamt);

  /// No description provided for @restaurierungLaeuftMitWarteschlange.
  ///
  /// In de, this message translates to:
  /// **'KI-Restaurierung läuft – Kachel {fertig}/{gesamt} · {wartend} in Warteschlange'**
  String restaurierungLaeuftMitWarteschlange(
      int fertig, int gesamt, int wartend);

  /// No description provided for @restaurierungWirdVorbereitet.
  ///
  /// In de, this message translates to:
  /// **'KI-Restaurierung wird vorbereitet …'**
  String get restaurierungWirdVorbereitet;

  /// No description provided for @restaurierungWartend.
  ///
  /// In de, this message translates to:
  /// **'{anzahl, plural, =1{1 Foto in der Warteschlange für die KI-Restaurierung} other{{anzahl} Fotos in der Warteschlange für die KI-Restaurierung}}'**
  String restaurierungWartend(int anzahl);

  /// fortschritt ist entweder leer oder etwa ', 12/340' – als fertiger Text übergeben, weil er nur bei bekannter Gesamtzahl erscheint.
  ///
  /// In de, this message translates to:
  /// **'{stufe} wird berechnet (Schritt {nummer} von {gesamt}{fortschritt})'**
  String analyseLaeuft(
      String stufe, int nummer, int gesamt, String fortschritt);

  /// No description provided for @kuerzelTitel.
  ///
  /// In de, this message translates to:
  /// **'Tastaturkürzel'**
  String get kuerzelTitel;

  /// No description provided for @kuerzelNavigation.
  ///
  /// In de, this message translates to:
  /// **'Navigation'**
  String get kuerzelNavigation;

  /// No description provided for @kuerzelVollbild.
  ///
  /// In de, this message translates to:
  /// **'Vollbildansicht'**
  String get kuerzelVollbild;

  /// No description provided for @kuerzelSichtung.
  ///
  /// In de, this message translates to:
  /// **'Sichtungs-Modus (Culling)'**
  String get kuerzelSichtung;

  /// No description provided for @kuerzelBereicheWechseln.
  ///
  /// In de, this message translates to:
  /// **'Zwischen den Hauptbereichen wechseln'**
  String get kuerzelBereicheWechseln;

  /// No description provided for @kuerzelUebersichtOeffnen.
  ///
  /// In de, this message translates to:
  /// **'Diese Übersicht öffnen'**
  String get kuerzelUebersichtOeffnen;

  /// No description provided for @kuerzelVorherigesNaechstes.
  ///
  /// In de, this message translates to:
  /// **'Vorheriges / nächstes Foto'**
  String get kuerzelVorherigesNaechstes;

  /// No description provided for @kuerzelLeertaste.
  ///
  /// In de, this message translates to:
  /// **'Leertaste'**
  String get kuerzelLeertaste;

  /// No description provided for @kuerzelNaechstesFoto.
  ///
  /// In de, this message translates to:
  /// **'Nächstes Foto'**
  String get kuerzelNaechstesFoto;

  /// No description provided for @kuerzelBewertungSetzen.
  ///
  /// In de, this message translates to:
  /// **'Sternebewertung setzen'**
  String get kuerzelBewertungSetzen;

  /// No description provided for @kuerzelFavoritUmschalten.
  ///
  /// In de, this message translates to:
  /// **'Favorit umschalten'**
  String get kuerzelFavoritUmschalten;

  /// No description provided for @kuerzelPapierkorbMitBestaetigung.
  ///
  /// In de, this message translates to:
  /// **'In den Papierkorb verschieben (mit Bestätigung)'**
  String get kuerzelPapierkorbMitBestaetigung;

  /// No description provided for @kuerzelSofortAblehnen.
  ///
  /// In de, this message translates to:
  /// **'Sofort ablehnen und weiter (ohne Bestätigung)'**
  String get kuerzelSofortAblehnen;

  /// No description provided for @timelineLeer.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Fotos in der Bibliothek.'**
  String get timelineLeer;

  /// No description provided for @loeschenTitel.
  ///
  /// In de, this message translates to:
  /// **'{anzahl, plural, =1{Foto löschen?} other{{anzahl} Fotos löschen?}}'**
  String loeschenTitel(int anzahl);

  /// No description provided for @loeschenHinweis.
  ///
  /// In de, this message translates to:
  /// **'{anzahl, plural, =1{Wird in den Papierkorb verschoben.} other{Diese Fotos werden in den Papierkorb verschoben.}}'**
  String loeschenHinweis(int anzahl);

  /// No description provided for @albumNeu.
  ///
  /// In de, this message translates to:
  /// **'Neues Album'**
  String get albumNeu;

  /// No description provided for @albumName.
  ///
  /// In de, this message translates to:
  /// **'Albumname'**
  String get albumName;

  /// No description provided for @albenLeer.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Alben vorhanden.'**
  String get albenLeer;

  /// No description provided for @erkundenPersonen.
  ///
  /// In de, this message translates to:
  /// **'Personen'**
  String get erkundenPersonen;

  /// No description provided for @erkundenOrte.
  ///
  /// In de, this message translates to:
  /// **'Orte'**
  String get erkundenOrte;

  /// No description provided for @erkundenLetzteAlben.
  ///
  /// In de, this message translates to:
  /// **'Zuletzt hinzugefügte Alben'**
  String get erkundenLetzteAlben;

  /// No description provided for @erkundenLetzteFotos.
  ///
  /// In de, this message translates to:
  /// **'Zuletzt hinzugefügte Fotos'**
  String get erkundenLetzteFotos;

  /// No description provided for @erkundenErinnerungen.
  ///
  /// In de, this message translates to:
  /// **'Erinnerungen'**
  String get erkundenErinnerungen;

  /// No description provided for @ohneOrtLeer.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Fotos mit bekanntem Ort.'**
  String get ohneOrtLeer;

  /// No description provided for @karteTitel.
  ///
  /// In de, this message translates to:
  /// **'Karte'**
  String get karteTitel;

  /// No description provided for @karteAnsicht.
  ///
  /// In de, this message translates to:
  /// **'Kartenansicht'**
  String get karteAnsicht;

  /// No description provided for @karteTexturNachweis.
  ///
  /// In de, this message translates to:
  /// **'Erd-/Sternentextur: Solar System Scope (CC BY 4.0)'**
  String get karteTexturNachweis;

  /// No description provided for @kalenderLeer.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Fotos für eine Jahresübersicht.'**
  String get kalenderLeer;

  /// No description provided for @kalenderJahrLeer.
  ///
  /// In de, this message translates to:
  /// **'Keine Fotos in diesem Jahr.'**
  String get kalenderJahrLeer;

  /// No description provided for @kalenderAnzahlFotos.
  ///
  /// In de, this message translates to:
  /// **'{anzahl, plural, =1{{anzahl} Foto/Video} other{{anzahl} Fotos/Videos}}'**
  String kalenderAnzahlFotos(int anzahl);

  /// No description provided for @sucheSpeichernTitel.
  ///
  /// In de, this message translates to:
  /// **'Suche speichern'**
  String get sucheSpeichernTitel;

  /// No description provided for @sucheModellFehlt.
  ///
  /// In de, this message translates to:
  /// **'Für die Kontext-Suche fehlt das Bildsuche-Modell. Es lässt sich in den Einstellungen unter „KI-Modelle“ laden.'**
  String get sucheModellFehlt;

  /// No description provided for @sucheModellLaedt.
  ///
  /// In de, this message translates to:
  /// **'Modell für die Bildsuche wird geladen …'**
  String get sucheModellLaedt;

  /// No description provided for @sucheFehlgeschlagen.
  ///
  /// In de, this message translates to:
  /// **'Suche fehlgeschlagen: {fehler}'**
  String sucheFehlgeschlagen(String fehler);

  /// No description provided for @suchePlatzhalterKontext.
  ///
  /// In de, this message translates to:
  /// **'z.B. „Sonnenuntergang am Meer“, „Hund im Schnee“ …'**
  String get suchePlatzhalterKontext;

  /// No description provided for @suchePlatzhalterDateiname.
  ///
  /// In de, this message translates to:
  /// **'Dateiname …'**
  String get suchePlatzhalterDateiname;

  /// No description provided for @suchePlatzhalterBeschreibung.
  ///
  /// In de, this message translates to:
  /// **'Beschreibung …'**
  String get suchePlatzhalterBeschreibung;

  /// No description provided for @suchePlatzhalterText.
  ///
  /// In de, this message translates to:
  /// **'Text im Foto …'**
  String get suchePlatzhalterText;

  /// No description provided for @suchePlatzhalterBildunterschrift.
  ///
  /// In de, this message translates to:
  /// **'z.B. „dog“, „sunset“ …'**
  String get suchePlatzhalterBildunterschrift;

  /// No description provided for @sucheOptionen.
  ///
  /// In de, this message translates to:
  /// **'Suchoptionen'**
  String get sucheOptionen;

  /// No description provided for @sucheAusloesen.
  ///
  /// In de, this message translates to:
  /// **'Suchen'**
  String get sucheAusloesen;

  /// No description provided for @sucheAnleitung.
  ///
  /// In de, this message translates to:
  /// **'Gib einen Suchbegriff ein oder wähle Suchoptionen.'**
  String get sucheAnleitung;

  /// No description provided for @sucheKeineTreffer.
  ///
  /// In de, this message translates to:
  /// **'Keine Treffer.'**
  String get sucheKeineTreffer;

  /// No description provided for @viewerInfo.
  ///
  /// In de, this message translates to:
  /// **'Info'**
  String get viewerInfo;

  /// No description provided for @viewerTeilen.
  ///
  /// In de, this message translates to:
  /// **'Teilen'**
  String get viewerTeilen;

  /// No description provided for @viewerExportieren.
  ///
  /// In de, this message translates to:
  /// **'Exportieren'**
  String get viewerExportieren;

  /// No description provided for @viewerEntwickeln.
  ///
  /// In de, this message translates to:
  /// **'Entwickeln'**
  String get viewerEntwickeln;

  /// No description provided for @viewerBearbeiten.
  ///
  /// In de, this message translates to:
  /// **'Bearbeiten'**
  String get viewerBearbeiten;

  /// No description provided for @viewerZuschneiden.
  ///
  /// In de, this message translates to:
  /// **'Zuschneiden'**
  String get viewerZuschneiden;

  /// No description provided for @viewerDiaschauStarten.
  ///
  /// In de, this message translates to:
  /// **'Diaschau starten'**
  String get viewerDiaschauStarten;

  /// No description provided for @viewerDiaschauStoppen.
  ///
  /// In de, this message translates to:
  /// **'Diaschau stoppen'**
  String get viewerDiaschauStoppen;

  /// No description provided for @viewerFavoritSetzen.
  ///
  /// In de, this message translates to:
  /// **'Als Favorit markieren (F)'**
  String get viewerFavoritSetzen;

  /// No description provided for @viewerFavoritEntfernen.
  ///
  /// In de, this message translates to:
  /// **'Favorit entfernen (F)'**
  String get viewerFavoritEntfernen;

  /// No description provided for @viewerInGesperrtenOrdner.
  ///
  /// In de, this message translates to:
  /// **'In gesperrten Ordner verschieben (verschlüsselt)'**
  String get viewerInGesperrtenOrdner;

  /// No description provided for @viewerInPapierkorb.
  ///
  /// In de, this message translates to:
  /// **'In den Papierkorb verschieben (⌫)'**
  String get viewerInPapierkorb;

  /// No description provided for @viewerVorherigesFoto.
  ///
  /// In de, this message translates to:
  /// **'Vorheriges Foto'**
  String get viewerVorherigesFoto;

  /// No description provided for @viewerNaechstesFoto.
  ///
  /// In de, this message translates to:
  /// **'Nächstes Foto'**
  String get viewerNaechstesFoto;

  /// No description provided for @viewerInTimelineZeigen.
  ///
  /// In de, this message translates to:
  /// **'Foto in der Timeline anzeigen'**
  String get viewerInTimelineZeigen;

  /// No description provided for @viewerAehnlicheZeigen.
  ///
  /// In de, this message translates to:
  /// **'Ähnliche Bilder anzeigen'**
  String get viewerAehnlicheZeigen;

  /// No description provided for @viewerMetadatenBearbeiten.
  ///
  /// In de, this message translates to:
  /// **'Metadaten bearbeiten'**
  String get viewerMetadatenBearbeiten;

  /// No description provided for @viewerGesichterBearbeiten.
  ///
  /// In de, this message translates to:
  /// **'Gesichter bearbeiten'**
  String get viewerGesichterBearbeiten;

  /// No description provided for @viewerEntwicklungAnwenden.
  ///
  /// In de, this message translates to:
  /// **'Kopierte Entwicklung anwenden'**
  String get viewerEntwicklungAnwenden;

  /// No description provided for @viewerEntwicklungAnwendenLang.
  ///
  /// In de, this message translates to:
  /// **'Kopierte Entwicklung auf dieses Foto anwenden'**
  String get viewerEntwicklungAnwendenLang;

  /// No description provided for @viewerGeschlosseneAugen.
  ///
  /// In de, this message translates to:
  /// **'Mindestens ein Gesicht mit geschlossenen Augen erkannt'**
  String get viewerGeschlosseneAugen;

  /// No description provided for @viewerFokusPeaking.
  ///
  /// In de, this message translates to:
  /// **'Fokus-Peaking (scharfe Kanten hervorheben)'**
  String get viewerFokusPeaking;

  /// No description provided for @viewerFlachesSchwenken.
  ///
  /// In de, this message translates to:
  /// **'Flaches Schwenken statt 3D-Kugel'**
  String get viewerFlachesSchwenken;

  /// No description provided for @viewerFlacheVorschau.
  ///
  /// In de, this message translates to:
  /// **'Flache Vorschau statt 360°-Ansicht'**
  String get viewerFlacheVorschau;

  /// No description provided for @viewerExportZielordner.
  ///
  /// In de, this message translates to:
  /// **'Zielordner zum Exportieren wählen'**
  String get viewerExportZielordner;

  /// No description provided for @viewerExportiert.
  ///
  /// In de, this message translates to:
  /// **'Exportiert: {dateien}'**
  String viewerExportiert(String dateien);

  /// No description provided for @viewerExportFehlgeschlagen.
  ///
  /// In de, this message translates to:
  /// **'Export fehlgeschlagen: {fehler}'**
  String viewerExportFehlgeschlagen(String fehler);

  /// No description provided for @viewerTeilenFehlgeschlagen.
  ///
  /// In de, this message translates to:
  /// **'Teilen fehlgeschlagen: {fehler}'**
  String viewerTeilenFehlgeschlagen(String fehler);

  /// No description provided for @personenTab.
  ///
  /// In de, this message translates to:
  /// **'Personen'**
  String get personenTab;

  /// No description provided for @personenUnbenannteTab.
  ///
  /// In de, this message translates to:
  /// **'Unbenannte Gesichter'**
  String get personenUnbenannteTab;

  /// No description provided for @personenLeer.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Personen angelegt. Wechsle zum Tab „Unbenannte Gesichter“, wähle ein paar Gesichter aus und ordne sie einer neuen Person zu.'**
  String get personenLeer;

  /// No description provided for @personenLangeDruecken.
  ///
  /// In de, this message translates to:
  /// **'lange drücken: zusammenführen'**
  String get personenLangeDruecken;

  /// No description provided for @personenKeineUnbenannten.
  ///
  /// In de, this message translates to:
  /// **'Keine unbenannten Gesichter (mehr). Neue erscheinen hier automatisch, sobald du weitere Fotos importierst oder erneut nach Gesichtern suchst. Einzelne kannst du auch selbst markieren: Foto öffnen, Rechtsklick → „Gesichter bearbeiten“, dann oben rechts auf „Gesicht manuell hinzufügen“.'**
  String get personenKeineUnbenannten;

  /// No description provided for @personenSchwellenHinweis.
  ///
  /// In de, this message translates to:
  /// **'Ähnlichkeitsschwelle einstellbar unter Werkzeuge → Gesichtserkennung.'**
  String get personenSchwellenHinweis;

  /// No description provided for @personenDoppelklickHinweis.
  ///
  /// In de, this message translates to:
  /// **'Doppelklick auf ein Gesicht öffnet das ganze Foto zur Kontrolle.'**
  String get personenDoppelklickHinweis;

  /// No description provided for @personenAutomatischGruppieren.
  ///
  /// In de, this message translates to:
  /// **'Automatisch gruppieren'**
  String get personenAutomatischGruppieren;

  /// No description provided for @personenAehnlicheAuswaehlen.
  ///
  /// In de, this message translates to:
  /// **'Ähnliche mit auswählen'**
  String get personenAehnlicheAuswaehlen;

  /// No description provided for @personenAehnlicheAbwaehlen.
  ///
  /// In de, this message translates to:
  /// **'Ähnliche abwählen'**
  String get personenAehnlicheAbwaehlen;

  /// No description provided for @personenZuordnen.
  ///
  /// In de, this message translates to:
  /// **'{anzahl, plural, =1{Gesicht zuordnen} other{{anzahl} Gesichter zuordnen}}'**
  String personenZuordnen(int anzahl);

  /// No description provided for @personenModellFehlt.
  ///
  /// In de, this message translates to:
  /// **'Für die Ähnlichkeitssuche wird das SFace-Modell benötigt (siehe Einstellungen → Modelle).'**
  String get personenModellFehlt;

  /// No description provided for @personenKeineAehnlichen.
  ///
  /// In de, this message translates to:
  /// **'Keine ähnlichen Gesichter über der Schwelle {schwelle} gefunden.'**
  String personenKeineAehnlichen(String schwelle);

  /// No description provided for @personenZuWenigeFuerClustering.
  ///
  /// In de, this message translates to:
  /// **'Nicht genug unbenannte Gesichter mit Embedding für ein Clustering.'**
  String get personenZuWenigeFuerClustering;

  /// No description provided for @personenKeineGruppen.
  ///
  /// In de, this message translates to:
  /// **'Keine ähnlichen Gruppen gefunden.'**
  String get personenKeineGruppen;

  /// No description provided for @personenDauertTitel.
  ///
  /// In de, this message translates to:
  /// **'Das kann etwas dauern'**
  String get personenDauertTitel;

  /// No description provided for @personenDauertText.
  ///
  /// In de, this message translates to:
  /// **'{anzahl} unbenannte Gesichter gefunden. Die automatische Gruppierung vergleicht jedes mit jedem und kann bei so vielen Gesichtern einige Zeit dauern (die App bleibt währenddessen bedienbar). Trotzdem starten?'**
  String personenDauertText(int anzahl);

  /// No description provided for @personenZusammenfuehrenMit.
  ///
  /// In de, this message translates to:
  /// **'„{name}“ zusammenführen mit …'**
  String personenZusammenfuehrenMit(String name);

  /// No description provided for @personenZusammenfuehrenTitel.
  ///
  /// In de, this message translates to:
  /// **'Zusammenführen bestätigen'**
  String get personenZusammenfuehrenTitel;

  /// No description provided for @personenZusammenfuehrenText.
  ///
  /// In de, this message translates to:
  /// **'Alle Fotos von „{quelle}“ werden „{ziel}“ zugeordnet. „{quelle}“ wird danach gelöscht. Das lässt sich nicht rückgängig machen.'**
  String personenZusammenfuehrenText(String quelle, String ziel);

  /// No description provided for @personenZusammenfuehren.
  ///
  /// In de, this message translates to:
  /// **'Zusammenführen'**
  String get personenZusammenfuehren;

  /// No description provided for @spracheTitel.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get spracheTitel;

  /// No description provided for @spracheSystem.
  ///
  /// In de, this message translates to:
  /// **'Systemsprache'**
  String get spracheSystem;

  /// No description provided for @spracheDeutsch.
  ///
  /// In de, this message translates to:
  /// **'Deutsch'**
  String get spracheDeutsch;

  /// No description provided for @spracheEnglisch.
  ///
  /// In de, this message translates to:
  /// **'English'**
  String get spracheEnglisch;

  /// No description provided for @spracheHinweis.
  ///
  /// In de, this message translates to:
  /// **'Betrifft nur die Oberfläche. Deine Alben, Schlagwörter und Personennamen bleiben, wie sie sind.'**
  String get spracheHinweis;

  /// No description provided for @spracheVokabularTitel.
  ///
  /// In de, this message translates to:
  /// **'Schlagwort-Vokabular mitübersetzen?'**
  String get spracheVokabularTitel;

  /// No description provided for @spracheVokabularText.
  ///
  /// In de, this message translates to:
  /// **'{bekannt} der {gesamt} Begriffe im Vokabular stammen aus der mitgelieferten Startbestückung und lassen sich zuverlässig übersetzen. Bereits vergebene Schlagwörter wandern mit, es geht nichts verloren.'**
  String spracheVokabularText(int bekannt, int gesamt);

  /// No description provided for @spracheVokabularSelbstAngelegt.
  ///
  /// In de, this message translates to:
  /// **'{anzahl, plural, =0{} =1{Ein selbst hinzugefügter Begriff bleibt unverändert.} other{{anzahl} selbst hinzugefügte Begriffe bleiben unverändert.}}'**
  String spracheVokabularSelbstAngelegt(int anzahl);

  /// No description provided for @spracheVokabularUebersetzen.
  ///
  /// In de, this message translates to:
  /// **'Übersetzen'**
  String get spracheVokabularUebersetzen;

  /// No description provided for @spracheVokabularBehalten.
  ///
  /// In de, this message translates to:
  /// **'Unverändert lassen'**
  String get spracheVokabularBehalten;

  /// No description provided for @spracheVokabularFertig.
  ///
  /// In de, this message translates to:
  /// **'{anzahl, plural, =1{Ein Begriff übersetzt.} other{{anzahl} Begriffe übersetzt.}}'**
  String spracheVokabularFertig(int anzahl);

  /// No description provided for @erkundenKeinePersonen.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Personen benannt.'**
  String get erkundenKeinePersonen;

  /// No description provided for @erkundenKeineOrte.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Orte aufgelöst (siehe Werkzeuge → Orte).'**
  String get erkundenKeineOrte;

  /// No description provided for @erkundenKeineFotos.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Fotos importiert.'**
  String get erkundenKeineFotos;

  /// No description provided for @karteKeineOrteLang.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Fotos mit bekanntem Ort.\n\nDer Ort wird beim Import automatisch aus den GPS-Daten eines Fotos übernommen (falls vorhanden) oder lässt sich in der Info-Ansicht eines Fotos/Videos (Vollbildvorschau → ⓘ) manuell festlegen.'**
  String get karteKeineOrteLang;

  /// No description provided for @einstOrdnerNichtGeoeffnet.
  ///
  /// In de, this message translates to:
  /// **'Ordner konnte nicht geöffnet werden: {pfad}'**
  String einstOrdnerNichtGeoeffnet(String pfad);

  /// No description provided for @einstBibWechselnTitel.
  ///
  /// In de, this message translates to:
  /// **'Zu „{name}“ wechseln?'**
  String einstBibWechselnTitel(String name);

  /// No description provided for @einstBibWechselnText.
  ///
  /// In de, this message translates to:
  /// **'Die App wird danach geschlossen und öffnet beim nächsten Start die gewählte Bibliothek.\n\nEs werden keine Fotos verschoben oder gelöscht – beide Bibliotheken bleiben unverändert an ihrem Ort.'**
  String get einstBibWechselnText;

  /// No description provided for @einstBibGewechselt.
  ///
  /// In de, this message translates to:
  /// **'Die Bibliothek wurde gewechselt. Es wurden keine Daten verschoben. Die App wird jetzt geschlossen – bitte danach manuell neu öffnen.'**
  String get einstBibGewechselt;

  /// No description provided for @einstBibHinzufuegenAuswahl.
  ///
  /// In de, this message translates to:
  /// **'Ordner einer bestehenden Bibliothek wählen – oder einen leeren Ordner für eine neue. Es wird nichts verschoben.'**
  String get einstBibHinzufuegenAuswahl;

  /// No description provided for @einstBibBestehendHinzugefuegt.
  ///
  /// In de, this message translates to:
  /// **'Bestehende Bibliothek hinzugefügt.'**
  String get einstBibBestehendHinzugefuegt;

  /// No description provided for @einstBibLeerHinzugefuegt.
  ///
  /// In de, this message translates to:
  /// **'Leerer Ordner hinzugefügt – beim Wechseln dorthin entsteht eine neue, leere Bibliothek.'**
  String get einstBibLeerHinzugefuegt;

  /// No description provided for @einstBibEntfernenTitel.
  ///
  /// In de, this message translates to:
  /// **'„{name}“ aus der Liste entfernen?'**
  String einstBibEntfernenTitel(String name);

  /// No description provided for @einstBibEntfernenText.
  ///
  /// In de, this message translates to:
  /// **'Die Bibliothek verschwindet nur aus dieser Liste. Fotos, Datenbank und Ordner bleiben unverändert erhalten und lassen sich jederzeit wieder hinzufügen.'**
  String get einstBibEntfernenText;

  /// No description provided for @einstBibNichtEntfernbar.
  ///
  /// In de, this message translates to:
  /// **'Dieser Eintrag lässt sich nicht entfernen.'**
  String get einstBibNichtEntfernbar;

  /// No description provided for @einstBibListe.
  ///
  /// In de, this message translates to:
  /// **'Bibliotheken'**
  String get einstBibListe;

  /// No description provided for @einstBibHinzufuegen.
  ///
  /// In de, this message translates to:
  /// **'Bibliothek hinzufügen…'**
  String get einstBibHinzufuegen;

  /// No description provided for @einstBibAusListeEntfernen.
  ///
  /// In de, this message translates to:
  /// **'Aus der Liste entfernen (löscht keine Fotos)'**
  String get einstBibAusListeEntfernen;

  /// No description provided for @einstBibNichtGefunden.
  ///
  /// In de, this message translates to:
  /// **'Ordner nicht gefunden – Laufwerk eingebunden?'**
  String get einstBibNichtGefunden;

  /// No description provided for @einstBibWechselHinweis.
  ///
  /// In de, this message translates to:
  /// **'Ein Wechsel biegt nur um, welche Bibliothek geöffnet wird – es werden keine Fotos verschoben. Zum Verlegen der aktuellen Bibliothek an einen anderen Ort dient „Speicherort ändern\" weiter unten.'**
  String get einstBibWechselHinweis;

  /// No description provided for @einstSpeicherortTitel.
  ///
  /// In de, this message translates to:
  /// **'Speicherort der aktiven Bibliothek'**
  String get einstSpeicherortTitel;

  /// No description provided for @einstSpeicherortWaehlen.
  ///
  /// In de, this message translates to:
  /// **'Fotos, Videos, Thumbnails und die Datenbank werden in diesen Ordner verschoben. Bitte einen bereits vorhandenen Ordner wählen (falls nötig vorher im Finder anlegen).'**
  String get einstSpeicherortWaehlen;

  /// No description provided for @einstSpeicherortZuruecksetzenTitel.
  ///
  /// In de, this message translates to:
  /// **'Speicherort zurücksetzen?'**
  String get einstSpeicherortZuruecksetzenTitel;

  /// No description provided for @einstSpeicherortZuruecksetzenText.
  ///
  /// In de, this message translates to:
  /// **'Die Bibliothek wird zurück in den Standard-App-Support-Ordner verschoben. Die App wird danach automatisch geschlossen – bitte anschließend neu öffnen.'**
  String get einstSpeicherortZuruecksetzenText;

  /// No description provided for @einstSpeicherortZuruecksetzenLaeuft.
  ///
  /// In de, this message translates to:
  /// **'Setze Speicherort zurück …'**
  String get einstSpeicherortZuruecksetzenLaeuft;

  /// No description provided for @einstSpeicherortGeaendert.
  ///
  /// In de, this message translates to:
  /// **'Der Speicherort wurde geändert. Die App wird jetzt geschlossen – bitte danach manuell neu öffnen, damit sie die Bibliothek am neuen Ort lädt.'**
  String get einstSpeicherortGeaendert;

  /// No description provided for @einstImFinderAnzeigen.
  ///
  /// In de, this message translates to:
  /// **'Im Finder anzeigen'**
  String get einstImFinderAnzeigen;

  /// No description provided for @einstAendern.
  ///
  /// In de, this message translates to:
  /// **'Ändern…'**
  String get einstAendern;

  /// No description provided for @einstZuruecksetzen.
  ///
  /// In de, this message translates to:
  /// **'Zurücksetzen'**
  String get einstZuruecksetzen;

  /// No description provided for @einstWirdBerechnet.
  ///
  /// In de, this message translates to:
  /// **'wird berechnet …'**
  String get einstWirdBerechnet;

  /// No description provided for @einstUeberwachtTitel.
  ///
  /// In de, this message translates to:
  /// **'Überwachter Ordner'**
  String get einstUeberwachtTitel;

  /// No description provided for @einstUeberwachtKeiner.
  ///
  /// In de, this message translates to:
  /// **'Kein Ordner eingerichtet'**
  String get einstUeberwachtKeiner;

  /// No description provided for @einstUeberwachtErklaerung.
  ///
  /// In de, this message translates to:
  /// **'Was in einem gewählten Ordner auftaucht, wird von selbst in die Bibliothek aufgenommen – alle fünf Minuten und bei jedem Start.'**
  String get einstUeberwachtErklaerung;

  /// No description provided for @einstUeberwachtAktiv.
  ///
  /// In de, this message translates to:
  /// **'Wird alle fünf Minuten geprüft. Die Dateien bleiben dort liegen.'**
  String get einstUeberwachtAktiv;

  /// No description provided for @einstUeberwachtWaehlen.
  ///
  /// In de, this message translates to:
  /// **'Ordner wählen…'**
  String get einstUeberwachtWaehlen;

  /// No description provided for @einstUeberwachtAndererWaehlen.
  ///
  /// In de, this message translates to:
  /// **'Anderen Ordner…'**
  String get einstUeberwachtAndererWaehlen;

  /// No description provided for @einstUeberwachtBeenden.
  ///
  /// In de, this message translates to:
  /// **'Nicht mehr überwachen'**
  String get einstUeberwachtBeenden;

  /// No description provided for @einstUeberwachtAuswahl.
  ///
  /// In de, this message translates to:
  /// **'Ordner wählen, der laufend auf neue Fotos geprüft werden soll. Die Dateien bleiben dort liegen; sie werden nur zusätzlich in die Bibliothek aufgenommen.'**
  String get einstUeberwachtAuswahl;

  /// No description provided for @einstUeberwachtUebernommen.
  ///
  /// In de, this message translates to:
  /// **'{anzahl, plural, =1{1 neues Foto aus dem Ordner übernommen.} other{{anzahl} neue Fotos aus dem Ordner übernommen.}}'**
  String einstUeberwachtUebernommen(int anzahl);

  /// No description provided for @einstKiHinweis.
  ///
  /// In de, this message translates to:
  /// **'Wie bei digiKam laufen alle KI-Funktionen offline auf diesem Rechner. Die Modelldateien werden nicht mitgeliefert, sondern bei Bedarf aus offiziellen Open-Source-Quellen heruntergeladen (einmalig, danach komplett offline nutzbar).'**
  String get einstKiHinweis;

  /// No description provided for @einstAutoAnalyseTitel.
  ///
  /// In de, this message translates to:
  /// **'KI-Auswertung nach dem Import automatisch nachholen'**
  String get einstAutoAnalyseTitel;

  /// No description provided for @einstAutoAnalyseText.
  ///
  /// In de, this message translates to:
  /// **'Der Import legt die Fotos nur ab und bleibt dadurch schnell. Gesichter, Texterkennung, Bildsuche und Bildbeschreibung laufen danach im Hintergrund nach. Ausgeschaltet lässt sich das jederzeit unter Werkzeuge von Hand anstoßen.'**
  String get einstAutoAnalyseText;

  /// No description provided for @einstNurErkennung.
  ///
  /// In de, this message translates to:
  /// **'Nur Erkennung aktiv (Wiedererkennung: SFace-Modell fehlt noch)'**
  String get einstNurErkennung;

  /// No description provided for @einstAufgabenTitel.
  ///
  /// In de, this message translates to:
  /// **'Aufgaben-Übersicht'**
  String get einstAufgabenTitel;

  /// No description provided for @einstAufgabenText.
  ///
  /// In de, this message translates to:
  /// **'Alle Auswertungen mit Anzahl noch offener Fotos, einzeln anstoßbar'**
  String get einstAufgabenText;

  /// No description provided for @einstModellLoeschen.
  ///
  /// In de, this message translates to:
  /// **'Modell löschen'**
  String get einstModellLoeschen;

  /// No description provided for @einstModellNichtGeladen.
  ///
  /// In de, this message translates to:
  /// **'{beschreibung}\n\nDas zugehörige Modell ist noch nicht geladen.'**
  String einstModellNichtGeladen(String beschreibung);

  /// No description provided for @einstVokabularText.
  ///
  /// In de, this message translates to:
  /// **'Begriffe, die automatisch per KI-Bildsuche-Modell (CLIP) auf neu importierte Fotos angewendet werden. Änderungen hier gelten nur für künftige Fotos – um sie rückwirkend auf die vorhandene Bibliothek anzuwenden, siehe Werkzeuge → \"KI-Tags berechnen\" → \"Alle Fotos\".'**
  String get einstVokabularText;

  /// No description provided for @einstBegriffHinzufuegenFeld.
  ///
  /// In de, this message translates to:
  /// **'Begriff hinzufügen …'**
  String get einstBegriffHinzufuegenFeld;

  /// No description provided for @einstBegriffHinzufuegen.
  ///
  /// In de, this message translates to:
  /// **'Begriff hinzufügen'**
  String get einstBegriffHinzufuegen;

  /// No description provided for @einstOrteText.
  ///
  /// In de, this message translates to:
  /// **'Ordnet dem GPS-Ort eines Fotos Land, Bundesland/Provinz und Stadt zu – komplett lokal über die nächstgelegene bekannte Stadt (GeoNames-Datensatz), ohne Anfrage an einen Online-Kartendienst. Für die Land-/Bundesland-/Stadt-Filter in den Suchoptionen nötig.'**
  String get einstOrteText;

  /// No description provided for @einstGeoTitel.
  ///
  /// In de, this message translates to:
  /// **'GeoNames – Städte, Länder, Bundesländer'**
  String get einstGeoTitel;

  /// No description provided for @einstGeoText.
  ///
  /// In de, this message translates to:
  /// **'Städte ab 1000 Einwohnern weltweit (~10 MB). Lizenz: {lizenz}.'**
  String einstGeoText(String lizenz);

  /// No description provided for @einstGeoLoeschen.
  ///
  /// In de, this message translates to:
  /// **'GeoNames-Datensatz löschen'**
  String get einstGeoLoeschen;

  /// No description provided for @einstGesperrtText.
  ///
  /// In de, this message translates to:
  /// **'Verschlüsselt private Fotos mit AES-256 (echte Verschlüsselung, nicht nur ein Anzeige-Filter) und blendet sie überall sonst (Timeline, Suche, Alben, Personen, Karte, Backup) aus. Ohne den PIN gibt es keine Wiederherstellung.'**
  String get einstGesperrtText;

  /// No description provided for @einstGesperrtEntsperrt.
  ///
  /// In de, this message translates to:
  /// **'PIN eingerichtet – für diese Sitzung bereits entsperrt.'**
  String get einstGesperrtEntsperrt;

  /// No description provided for @einstGesperrtOeffnen.
  ///
  /// In de, this message translates to:
  /// **'Öffnen'**
  String get einstGesperrtOeffnen;

  /// No description provided for @einstPinAendern.
  ///
  /// In de, this message translates to:
  /// **'PIN ändern'**
  String get einstPinAendern;

  /// No description provided for @einstGesperrtAufloesenText.
  ///
  /// In de, this message translates to:
  /// **'Alle Fotos im gesperrten Ordner werden entschlüsselt und wieder normal sichtbar (Timeline, Suche, Alben, Personen, Karte, Backup). Das lässt sich nicht rückgängig machen.'**
  String get einstGesperrtAufloesenText;

  /// No description provided for @einstBackupVerschluesselungTitel.
  ///
  /// In de, this message translates to:
  /// **'Backup-Verschlüsselung'**
  String get einstBackupVerschluesselungTitel;

  /// No description provided for @einstBackupVerschluesselungText.
  ///
  /// In de, this message translates to:
  /// **'Ermöglicht, manuelle und automatische Backups mit AES-256 zu verschlüsseln. Eigene Passphrase, unabhängig vom PIN des gesperrten Ordners – ein Backup landet oft extern und muss auch ohne diesen Rechner entschlüsselbar sein.'**
  String get einstBackupVerschluesselungText;

  /// No description provided for @einstBackupEntsperrt.
  ///
  /// In de, this message translates to:
  /// **'Eingerichtet – für diese Sitzung bereits entsperrt.'**
  String get einstBackupEntsperrt;

  /// No description provided for @einstBackupGesperrt.
  ///
  /// In de, this message translates to:
  /// **'Eingerichtet – wird beim nächsten Backup abgefragt.'**
  String get einstBackupGesperrt;

  /// No description provided for @einstBackupAendern.
  ///
  /// In de, this message translates to:
  /// **'Ändern'**
  String get einstBackupAendern;

  /// No description provided for @einstBackupNieGesichert.
  ///
  /// In de, this message translates to:
  /// **'Noch nie gesichert.'**
  String get einstBackupNieGesichert;

  /// No description provided for @einstBackupVerschluesseln.
  ///
  /// In de, this message translates to:
  /// **'Backup verschlüsseln'**
  String get einstBackupVerschluesseln;

  /// No description provided for @einstBackupPassphraseAbfrage.
  ///
  /// In de, this message translates to:
  /// **'Fragt bei Bedarf die Backup-Passphrase von oben ab.'**
  String get einstBackupPassphraseAbfrage;

  /// No description provided for @einstBackupZielWaehlen.
  ///
  /// In de, this message translates to:
  /// **'Backup-Ziel wählen (z.B. dein Dropbox- oder Google-Drive-Ordner)'**
  String get einstBackupZielWaehlen;

  /// No description provided for @einstBackupOrdnerWaehlen.
  ///
  /// In de, this message translates to:
  /// **'Backup-Ordner wählen (enthält \"PhotoVault-Backup\" bzw. \"originals\")'**
  String get einstBackupOrdnerWaehlen;

  /// No description provided for @einstBackupEntschluesselnTitel.
  ///
  /// In de, this message translates to:
  /// **'Backup-Verschlüsselung entfernen?'**
  String get einstBackupEntschluesselnTitel;

  /// No description provided for @einstBackupEntschluesselnText.
  ///
  /// In de, this message translates to:
  /// **'Neue Backups werden danach nicht mehr verschlüsselt. Bereits bestehende verschlüsselte Backups am Zielort bleiben unverändert und weiterhin nur mit der bisherigen Passphrase entschlüsselbar.'**
  String get einstBackupEntschluesselnText;

  /// No description provided for @einstBackupLaeuft.
  ///
  /// In de, this message translates to:
  /// **'Automatisches Backup läuft …'**
  String get einstBackupLaeuft;

  /// No description provided for @einstBackupKeineNeuen.
  ///
  /// In de, this message translates to:
  /// **'Keine neuen Dateien – Datenbank-Schnappschuss wird aktualisiert.'**
  String get einstBackupKeineNeuen;

  /// No description provided for @einstBackupZielHinweis.
  ///
  /// In de, this message translates to:
  /// **'Wähle als Ziel z.B. deinen lokalen Dropbox- oder Google-Drive-Ordner – die Desktop-App des jeweiligen Anbieters lädt die Dateien dann automatisch in die Cloud hoch.'**
  String get einstBackupZielHinweis;

  /// No description provided for @einstBackupAutoHinweis.
  ///
  /// In de, this message translates to:
  /// **'Läuft nur, während die App geöffnet ist (kein Hintergrunddienst) – prüft beim Start und danach alle 30 Minuten, ob das Intervall abgelaufen ist. Sichert immer verschlüsselt, zusätzlich zu den Originaldateien auch einen Schnappschuss der gesamten Datenbank (Gesichter, Orte, Tags, Alben, Favoriten, …), damit sich bei Datenverlust der komplette Zustand wiederherstellen lässt. Löscht am Zielort nie etwas – lokale Löschungen werden bewusst nicht nachvollzogen.'**
  String get einstBackupAutoHinweis;

  /// No description provided for @einstBackupZuerstZiel.
  ///
  /// In de, this message translates to:
  /// **'Zuerst einen Zielordner wählen.'**
  String get einstBackupZuerstZiel;

  /// No description provided for @einstBackupKeinOrdner.
  ///
  /// In de, this message translates to:
  /// **'Kein Ordner gewählt.'**
  String get einstBackupKeinOrdner;

  /// No description provided for @einstBackupAutoZielWaehlen.
  ///
  /// In de, this message translates to:
  /// **'Zielordner für automatisches Backup wählen'**
  String get einstBackupAutoZielWaehlen;

  /// No description provided for @einstWaehlen.
  ///
  /// In de, this message translates to:
  /// **'Wählen…'**
  String get einstWaehlen;

  /// No description provided for @einstStuendlich.
  ///
  /// In de, this message translates to:
  /// **'Stündlich'**
  String get einstStuendlich;

  /// No description provided for @einstTaeglich.
  ///
  /// In de, this message translates to:
  /// **'Täglich'**
  String get einstTaeglich;

  /// No description provided for @einstWoechentlich.
  ///
  /// In de, this message translates to:
  /// **'Wöchentlich'**
  String get einstWoechentlich;

  /// No description provided for @einstBackupGrenzeText.
  ///
  /// In de, this message translates to:
  /// **'Begrenzt, wie viel pro Durchlauf ins Ziel geschrieben wird. Sinnvoll bei Cloud-Ordnern: Der Upload kommt sonst tagelang nicht hinterher. Der Rest folgt beim nächsten Intervall.'**
  String get einstBackupGrenzeText;

  /// No description provided for @einstNieAusgefuehrt.
  ///
  /// In de, this message translates to:
  /// **'Noch nie ausgeführt.'**
  String get einstNieAusgefuehrt;

  /// No description provided for @einstBackupPassphraseGesperrt.
  ///
  /// In de, this message translates to:
  /// **'Backup-Passphrase muss für diese Sitzung noch entsperrt werden, bevor das automatische Backup laufen kann – z.B. über \"Jetzt synchronisieren\".'**
  String get einstBackupPassphraseGesperrt;

  /// No description provided for @einstPapierkorbText.
  ///
  /// In de, this message translates to:
  /// **'Löscht in den Papierkorb verschobene Fotos/Videos nach Ablauf der gewählten Frist endgültig – unwiderruflich, auch aus dem PIN-geschützten Papierkorb des gesperrten Ordners. Standardmäßig deaktiviert.'**
  String get einstPapierkorbText;

  /// No description provided for @einstPapierkorbAus.
  ///
  /// In de, this message translates to:
  /// **'Papierkorb-Ablauf ist standardmäßig ausgeschaltet.'**
  String get einstPapierkorbAus;

  /// No description provided for @einstResetText.
  ///
  /// In de, this message translates to:
  /// **'Löscht unwiderruflich ALLE Fotos, Videos und die gesamte Datenbank dieser Bibliothek und beginnt danach mit einer leeren Bibliothek neu. Heruntergeladene KI-Modelle und Geodaten bleiben erhalten (kein erneuter Download nötig).'**
  String get einstResetText;

  /// No description provided for @einstResetTitel.
  ///
  /// In de, this message translates to:
  /// **'Datenbank zurücksetzen'**
  String get einstResetTitel;

  /// No description provided for @einstResetKurz.
  ///
  /// In de, this message translates to:
  /// **'Löscht alle Medien und Metadaten – nicht rückgängig zu machen.'**
  String get einstResetKurz;

  /// No description provided for @einstResetKnopf.
  ///
  /// In de, this message translates to:
  /// **'Zurücksetzen…'**
  String get einstResetKnopf;

  /// No description provided for @einstResetBestaetigenTitel.
  ///
  /// In de, this message translates to:
  /// **'Datenbank wirklich zurücksetzen?'**
  String get einstResetBestaetigenTitel;

  /// No description provided for @einstResetBestaetigenText.
  ///
  /// In de, this message translates to:
  /// **'Löscht UNWIDERRUFLICH alle Fotos, Videos, Thumbnails und die gesamte Datenbank dieser Bibliothek (Alben, Personen, Tags, Orte, Favoriten, gesperrter Ordner, Papierkorb, gespeicherte Suchen, …). Heruntergeladene KI-Modelle und Geodaten bleiben erhalten. Erstelle vorher ein Backup, falls du dir nicht sicher bist – diese Aktion lässt sich NICHT rückgängig machen.'**
  String get einstResetBestaetigenText;

  /// No description provided for @einstResetWort.
  ///
  /// In de, this message translates to:
  /// **'ZURÜCKSETZEN'**
  String get einstResetWort;

  /// No description provided for @einstResetEndgueltig.
  ///
  /// In de, this message translates to:
  /// **'Endgültig zurücksetzen'**
  String get einstResetEndgueltig;

  /// No description provided for @einstResetLaeuft.
  ///
  /// In de, this message translates to:
  /// **'Lösche Bibliothek …'**
  String get einstResetLaeuft;

  /// No description provided for @einstResetFertig.
  ///
  /// In de, this message translates to:
  /// **'Die Bibliothek wurde vollständig gelöscht. Die App wird jetzt geschlossen – bitte danach manuell neu öffnen, um mit einer leeren Bibliothek neu zu beginnen.'**
  String get einstResetFertig;

  /// No description provided for @einstResetFehlgeschlagen.
  ///
  /// In de, this message translates to:
  /// **'Zurücksetzen fehlgeschlagen'**
  String get einstResetFehlgeschlagen;

  /// No description provided for @einstUeberTitel.
  ///
  /// In de, this message translates to:
  /// **'Über diese App'**
  String get einstUeberTitel;

  /// No description provided for @einstKeineModelle.
  ///
  /// In de, this message translates to:
  /// **'Keine KI-Modelle geladen'**
  String get einstKeineModelle;

  /// No description provided for @einstModelleGeladen.
  ///
  /// In de, this message translates to:
  /// **'{geladen} von {gesamt} KI-Modellen geladen'**
  String einstModelleGeladen(int geladen, int gesamt);

  /// No description provided for @einstModelleUnbenutzt.
  ///
  /// In de, this message translates to:
  /// **'Die KI-Funktionen bleiben ohne sie unbenutzt.'**
  String get einstModelleUnbenutzt;

  /// No description provided for @einstAktualisierungHinweis.
  ///
  /// In de, this message translates to:
  /// **'Die Prüfung fragt einmalig beim öffentlichen Veröffentlichungsverzeichnis nach der neuesten Versionsnummer. Es wird nichts über die Bibliothek übertragen, und es geschieht nur auf diesen Knopfdruck – nie von selbst.'**
  String get einstAktualisierungHinweis;

  /// No description provided for @einstAktualisierungNeuer.
  ///
  /// In de, this message translates to:
  /// **'Neuere Fassung verfügbar: {version}'**
  String einstAktualisierungNeuer(String version);

  /// No description provided for @einstAktualisierungAktuell.
  ///
  /// In de, this message translates to:
  /// **'Diese Fassung ist aktuell.'**
  String get einstAktualisierungAktuell;

  /// No description provided for @einstAktualisierungFehler.
  ///
  /// In de, this message translates to:
  /// **'Prüfung fehlgeschlagen: {fehler}'**
  String einstAktualisierungFehler(String fehler);

  /// No description provided for @einstVerschiebenFehlgeschlagen.
  ///
  /// In de, this message translates to:
  /// **'Verschieben fehlgeschlagen'**
  String get einstVerschiebenFehlgeschlagen;

  /// No description provided for @einstWechselnFehlgeschlagen.
  ///
  /// In de, this message translates to:
  /// **'Wechseln fehlgeschlagen'**
  String get einstWechselnFehlgeschlagen;

  /// No description provided for @einstNeustartTitel.
  ///
  /// In de, this message translates to:
  /// **'Neustart erforderlich'**
  String get einstNeustartTitel;

  /// No description provided for @einstUebersetzeBeschreibungTitel.
  ///
  /// In de, this message translates to:
  /// **'Bildbeschreibungen in die Oberflächensprache übersetzen'**
  String get einstUebersetzeBeschreibungTitel;

  /// No description provided for @einstUebersetzeBeschreibungText.
  ///
  /// In de, this message translates to:
  /// **'Das Beschreibungsmodell liefert nur Englisch – es gibt kein vergleichbar kleines deutsches. Ist das Modell „Übersetzung Englisch → Deutsch“ geladen, wird jede neue Beschreibung zusätzlich übersetzt. Das englische Original bleibt erhalten, die Suche findet beide.'**
  String get einstUebersetzeBeschreibungText;

  /// No description provided for @einstUebersetzeSucheTitel.
  ///
  /// In de, this message translates to:
  /// **'Suche und Schlagwörter übersetzen'**
  String get einstUebersetzeSucheTitel;

  /// No description provided for @einstUebersetzeSucheText.
  ///
  /// In de, this message translates to:
  /// **'Der Text-Teil des Bildsuche-Modells versteht nur Englisch, das Schlagwort-Vokabular ist aber deutsch. Eingeschaltet wandern Suchanfrage und Vokabelbegriffe vorher durch die Übersetzung. An 103 Fotos gemessen trifft das bei 33 von 56 Begriffen genauer, bei 19 schlechter – und es vergibt deutlich weniger Schlagwörter. Deshalb zum Ausprobieren, nicht als Vorgabe.'**
  String get einstUebersetzeSucheText;

  /// No description provided for @allgEntfernen.
  ///
  /// In de, this message translates to:
  /// **'Entfernen'**
  String get allgEntfernen;

  /// No description provided for @allgEinrichten.
  ///
  /// In de, this message translates to:
  /// **'Einrichten'**
  String get allgEinrichten;

  /// No description provided for @allgHerunterladen.
  ///
  /// In de, this message translates to:
  /// **'Herunterladen'**
  String get allgHerunterladen;

  /// No description provided for @allgAktiv.
  ///
  /// In de, this message translates to:
  /// **'Aktiv'**
  String get allgAktiv;

  /// No description provided for @einstAbschnittErscheinungsbild.
  ///
  /// In de, this message translates to:
  /// **'Erscheinungsbild'**
  String get einstAbschnittErscheinungsbild;

  /// No description provided for @einstAbschnittModelle.
  ///
  /// In de, this message translates to:
  /// **'KI-Modelle (lokal & quelloffen)'**
  String get einstAbschnittModelle;

  /// No description provided for @einstAbschnittHintergrund.
  ///
  /// In de, this message translates to:
  /// **'Hintergrundaufgaben'**
  String get einstAbschnittHintergrund;

  /// No description provided for @einstAbschnittVokabular.
  ///
  /// In de, this message translates to:
  /// **'KI-Tagging-Vokabular'**
  String get einstAbschnittVokabular;

  /// No description provided for @einstAbschnittStandortdaten.
  ///
  /// In de, this message translates to:
  /// **'Standortdaten (lokal & quelloffen)'**
  String get einstAbschnittStandortdaten;

  /// No description provided for @einstAbschnittGesperrterOrdner.
  ///
  /// In de, this message translates to:
  /// **'Gesperrter Ordner'**
  String get einstAbschnittGesperrterOrdner;

  /// No description provided for @einstAbschnittManuellesBackup.
  ///
  /// In de, this message translates to:
  /// **'Manuelles Cloud-Backup'**
  String get einstAbschnittManuellesBackup;

  /// No description provided for @einstAbschnittAutoBackup.
  ///
  /// In de, this message translates to:
  /// **'Automatisches Backup'**
  String get einstAbschnittAutoBackup;

  /// No description provided for @einstAbschnittPapierkorb.
  ///
  /// In de, this message translates to:
  /// **'Papierkorb automatisch leeren'**
  String get einstAbschnittPapierkorb;

  /// No description provided for @einstAbschnittGefahrenzone.
  ///
  /// In de, this message translates to:
  /// **'Gefahrenzone'**
  String get einstAbschnittGefahrenzone;

  /// No description provided for @einstDesign.
  ///
  /// In de, this message translates to:
  /// **'Design'**
  String get einstDesign;

  /// No description provided for @einstDesignHell.
  ///
  /// In de, this message translates to:
  /// **'Hell'**
  String get einstDesignHell;

  /// No description provided for @einstDesignDunkel.
  ///
  /// In de, this message translates to:
  /// **'Dunkel'**
  String get einstDesignDunkel;

  /// No description provided for @einstDesignSystem.
  ///
  /// In de, this message translates to:
  /// **'System'**
  String get einstDesignSystem;

  /// No description provided for @einstUeberwachtNichtsNeues.
  ///
  /// In de, this message translates to:
  /// **'Ordner eingerichtet – nichts Neues gefunden.'**
  String get einstUeberwachtNichtsNeues;

  /// No description provided for @einstBibWechselnAktion.
  ///
  /// In de, this message translates to:
  /// **'Wechseln'**
  String get einstBibWechselnAktion;

  /// No description provided for @einstBibWechselnLaeuft.
  ///
  /// In de, this message translates to:
  /// **'Wechsle Bibliothek …'**
  String get einstBibWechselnLaeuft;

  /// No description provided for @einstBibAktiv.
  ///
  /// In de, this message translates to:
  /// **'aktiv'**
  String get einstBibAktiv;

  /// No description provided for @einstBibImmerVorhanden.
  ///
  /// In de, this message translates to:
  /// **'immer vorhanden'**
  String get einstBibImmerVorhanden;

  /// No description provided for @einstSpeicherort.
  ///
  /// In de, this message translates to:
  /// **'Speicherort'**
  String get einstSpeicherort;

  /// No description provided for @einstSpeicherortVerschiebenLaeuft.
  ///
  /// In de, this message translates to:
  /// **'Verschiebe Bibliothek …'**
  String get einstSpeicherortVerschiebenLaeuft;

  /// No description provided for @einstSpeicherbedarf.
  ///
  /// In de, this message translates to:
  /// **'Speicherbedarf (Originale)'**
  String get einstSpeicherbedarf;

  /// No description provided for @einstModellLaedt.
  ///
  /// In de, this message translates to:
  /// **'Lade „{titel}“ herunter …'**
  String einstModellLaedt(String titel);

  /// No description provided for @einstModelleBelegterPlatz.
  ///
  /// In de, this message translates to:
  /// **'Belegter Platz aller Modelle: {groesse}'**
  String einstModelleBelegterPlatz(String groesse);

  /// No description provided for @einstModellLizenzZeile.
  ///
  /// In de, this message translates to:
  /// **'Lizenz: {lizenz}'**
  String einstModellLizenzZeile(String lizenz);

  /// No description provided for @einstGesichtserkennungAktiv.
  ///
  /// In de, this message translates to:
  /// **'Gesichtserkennung aktiv'**
  String get einstGesichtserkennungAktiv;

  /// No description provided for @einstGesichtserkennungBeides.
  ///
  /// In de, this message translates to:
  /// **'Erkennung + Wiedererkennungs-Embeddings aktiv'**
  String get einstGesichtserkennungBeides;

  /// No description provided for @einstGesichtserkennungInaktiv.
  ///
  /// In de, this message translates to:
  /// **'Inaktiv – YuNet-Modell oben herunterladen'**
  String get einstGesichtserkennungInaktiv;

  /// No description provided for @einstGeoLaedt.
  ///
  /// In de, this message translates to:
  /// **'Lade Standortdaten herunter …'**
  String get einstGeoLaedt;

  /// No description provided for @einstPinEinrichten.
  ///
  /// In de, this message translates to:
  /// **'PIN einrichten'**
  String get einstPinEinrichten;

  /// No description provided for @einstGesperrterOrdner.
  ///
  /// In de, this message translates to:
  /// **'Gesperrter Ordner'**
  String get einstGesperrterOrdner;

  /// No description provided for @einstPinEingerichtet.
  ///
  /// In de, this message translates to:
  /// **'PIN eingerichtet.'**
  String get einstPinEingerichtet;

  /// No description provided for @einstPinEntfernen.
  ///
  /// In de, this message translates to:
  /// **'PIN entfernen'**
  String get einstPinEntfernen;

  /// No description provided for @einstGesperrtAufloesenTitel.
  ///
  /// In de, this message translates to:
  /// **'PIN-Schutz entfernen?'**
  String get einstGesperrtAufloesenTitel;

  /// No description provided for @einstSitzungSperren.
  ///
  /// In de, this message translates to:
  /// **'Sitzung jetzt sperren'**
  String get einstSitzungSperren;

  /// No description provided for @einstPassphraseEinrichten.
  ///
  /// In de, this message translates to:
  /// **'Passphrase einrichten'**
  String get einstPassphraseEinrichten;

  /// No description provided for @einstBackupPassphrase.
  ///
  /// In de, this message translates to:
  /// **'Backup-Passphrase'**
  String get einstBackupPassphrase;

  /// No description provided for @einstBackupPassphraseEingeben.
  ///
  /// In de, this message translates to:
  /// **'Backup-Passphrase eingeben'**
  String get einstBackupPassphraseEingeben;

  /// No description provided for @einstBackupSichertLaeuft.
  ///
  /// In de, this message translates to:
  /// **'Sichere Bibliothek …'**
  String get einstBackupSichertLaeuft;

  /// No description provided for @einstBackupWiederherstellenLaeuft.
  ///
  /// In de, this message translates to:
  /// **'Stelle Bibliothek wieder her …'**
  String get einstBackupWiederherstellenLaeuft;

  /// No description provided for @einstLetztesBackup.
  ///
  /// In de, this message translates to:
  /// **'Letztes Backup'**
  String get einstLetztesBackup;

  /// No description provided for @einstBackupZusammenfassung.
  ///
  /// In de, this message translates to:
  /// **'{datum} – {anzahl} Datei(en) nach {ziel}'**
  String einstBackupZusammenfassung(String datum, int anzahl, String ziel);

  /// No description provided for @einstJetztSichern.
  ///
  /// In de, this message translates to:
  /// **'Jetzt sichern'**
  String get einstJetztSichern;

  /// No description provided for @einstWiederherstellen.
  ///
  /// In de, this message translates to:
  /// **'Wiederherstellen'**
  String get einstWiederherstellen;

  /// No description provided for @einstZielordner.
  ///
  /// In de, this message translates to:
  /// **'Zielordner'**
  String get einstZielordner;

  /// No description provided for @einstIntervall.
  ///
  /// In de, this message translates to:
  /// **'Intervall'**
  String get einstIntervall;

  /// No description provided for @einstIntervallSechsStunden.
  ///
  /// In de, this message translates to:
  /// **'Alle 6 Stunden'**
  String get einstIntervallSechsStunden;

  /// No description provided for @einstMengeJeLauf.
  ///
  /// In de, this message translates to:
  /// **'Menge je Lauf'**
  String get einstMengeJeLauf;

  /// No description provided for @einstUnbegrenzt.
  ///
  /// In de, this message translates to:
  /// **'Unbegrenzt'**
  String get einstUnbegrenzt;

  /// No description provided for @einstLetzterLauf.
  ///
  /// In de, this message translates to:
  /// **'Letzter Lauf'**
  String get einstLetzterLauf;

  /// No description provided for @einstJetztSynchronisieren.
  ///
  /// In de, this message translates to:
  /// **'Jetzt synchronisieren'**
  String get einstJetztSynchronisieren;

  /// No description provided for @einstNachTagen.
  ///
  /// In de, this message translates to:
  /// **'Nach'**
  String get einstNachTagen;

  /// No description provided for @einstTageDropdown.
  ///
  /// In de, this message translates to:
  /// **'{tage} Tagen'**
  String einstTageDropdown(int tage);

  /// No description provided for @einstDatenbank.
  ///
  /// In de, this message translates to:
  /// **'Datenbank'**
  String get einstDatenbank;

  /// No description provided for @einstDatenbankStand.
  ///
  /// In de, this message translates to:
  /// **'Stand {version}'**
  String einstDatenbankStand(int version);

  /// No description provided for @einstBauZeile.
  ///
  /// In de, this message translates to:
  /// **'Bau {bau} · {system} {systemversion}'**
  String einstBauZeile(String bau, String system, String systemversion);

  /// No description provided for @einstNachAktualisierungSuchen.
  ///
  /// In de, this message translates to:
  /// **'Nach Aktualisierung suchen'**
  String get einstNachAktualisierungSuchen;

  /// No description provided for @modellYunetTitel.
  ///
  /// In de, this message translates to:
  /// **'Gesichtserkennung – YuNet'**
  String get modellYunetTitel;

  /// No description provided for @modellYunetText.
  ///
  /// In de, this message translates to:
  /// **'Erkennt Gesichter (Bounding Boxes) in Fotos. Leichtgewichtiges CNN, Teil von OpenCV Zoo.'**
  String get modellYunetText;

  /// No description provided for @modellYunetLizenz.
  ///
  /// In de, this message translates to:
  /// **'Apache-2.0'**
  String get modellYunetLizenz;

  /// No description provided for @modellSfaceTitel.
  ///
  /// In de, this message translates to:
  /// **'Gesichts-Wiedererkennung – SFace'**
  String get modellSfaceTitel;

  /// No description provided for @modellSfaceText.
  ///
  /// In de, this message translates to:
  /// **'Berechnet ein Embedding pro Gesicht, um ähnliche/gleiche Gesichter beim manuellen Zuordnen leichter zu gruppieren. Teil von OpenCV Zoo.'**
  String get modellSfaceText;

  /// No description provided for @modellSfaceLizenz.
  ///
  /// In de, this message translates to:
  /// **'Apache-2.0'**
  String get modellSfaceLizenz;

  /// No description provided for @modellClipTitel.
  ///
  /// In de, this message translates to:
  /// **'KI-Bildsuche – CLIP ViT-B/32'**
  String get modellClipTitel;

  /// No description provided for @modellClipText.
  ///
  /// In de, this message translates to:
  /// **'Ermöglicht die Suche nach Fotos in natürlicher Sprache (z.B. \"Sonnenuntergang am Meer\"). OpenAI-Originalgewichte, als separate Bild-/Text-Encoder-ONNX-Graphen exportiert.'**
  String get modellClipText;

  /// No description provided for @modellClipLizenz.
  ///
  /// In de, this message translates to:
  /// **'MIT (Gewichte: OpenAI CLIP, siehe Quelle)'**
  String get modellClipLizenz;

  /// No description provided for @modellSamTitel.
  ///
  /// In de, this message translates to:
  /// **'KI-Objektmasken – SAM ViT-Base'**
  String get modellSamTitel;

  /// No description provided for @modellSamText.
  ///
  /// In de, this message translates to:
  /// **'Erlaubt gezielte Anpassungen nur auf einem ausgewählten Bereich (z.B. nur den Himmel aufhellen) im Entwickeln-Screen, statt jede Anpassung auf das ganze Bild anzuwenden. Nutzer setzt Vordergrund-/Hintergrund-Punkte, ein promptbares Segmentierungsmodell schlägt die passende Maske vor.'**
  String get modellSamText;

  /// No description provided for @modellSamLizenz.
  ///
  /// In de, this message translates to:
  /// **'Apache-2.0 (Gewichte: Meta Segment Anything, siehe Quelle)'**
  String get modellSamLizenz;

  /// No description provided for @modellCaptionTitel.
  ///
  /// In de, this message translates to:
  /// **'KI-Bildbeschreibung – ViT-GPT2 (Englisch)'**
  String get modellCaptionTitel;

  /// No description provided for @modellCaptionText.
  ///
  /// In de, this message translates to:
  /// **'Erzeugt automatisch eine kurze, englische Bildunterschrift pro Foto (z.B. für die Suche oder als schnelle Übersicht). Es gibt aktuell kein vergleichbar kleines deutsches Modell – Ausgabe ist immer Englisch.'**
  String get modellCaptionText;

  /// No description provided for @modellCaptionLizenz.
  ///
  /// In de, this message translates to:
  /// **'Apache-2.0 (Basis: nlpconnect/vit-gpt2-image-captioning, ONNX-Port: Xenova)'**
  String get modellCaptionLizenz;

  /// No description provided for @modellOcecTitel.
  ///
  /// In de, this message translates to:
  /// **'Geschlossene-Augen-Erkennung – OCEC'**
  String get modellOcecTitel;

  /// No description provided for @modellOcecText.
  ///
  /// In de, this message translates to:
  /// **'Markiert Gesichter mit geschlossenen Augen in der Sichtung – schnelleres Aussortieren von Fotos mit Blinzlern in Porträt-/Gruppenserien.'**
  String get modellOcecText;

  /// No description provided for @modellOcecLizenz.
  ///
  /// In de, this message translates to:
  /// **'MIT'**
  String get modellOcecLizenz;

  /// No description provided for @modellEsrganTitel.
  ///
  /// In de, this message translates to:
  /// **'KI-Restaurierung – Real-ESRGAN x4'**
  String get modellEsrganTitel;

  /// No description provided for @modellEsrganText.
  ///
  /// In de, this message translates to:
  /// **'Skaliert ein Foto um Faktor 4 hoch und entrauscht dabei. Läuft als Hintergrund-Warteschlange (Einstellungen/Entwickeln) und dauert je nach Fotogröße mehrere Minuten.'**
  String get modellEsrganText;

  /// No description provided for @modellEsrganLizenz.
  ///
  /// In de, this message translates to:
  /// **'BSD-3-Clause (Real-ESRGAN-Originalgewichte)'**
  String get modellEsrganLizenz;

  /// No description provided for @modellEnDeTitel.
  ///
  /// In de, this message translates to:
  /// **'Übersetzung Englisch → Deutsch – OPUS-MT'**
  String get modellEnDeTitel;

  /// No description provided for @modellEnDeText.
  ///
  /// In de, this message translates to:
  /// **'Übersetzt die automatisch erzeugten Bildbeschreibungen ins Deutsche. Das Beschreibungsmodell selbst liefert nur Englisch; ohne diese Ergänzung muss man auf Englisch suchen, was man auf Deutsch sieht. Rund 100 MB.'**
  String get modellEnDeText;

  /// No description provided for @modellEnDeLizenz.
  ///
  /// In de, this message translates to:
  /// **'Apache-2.0 (Basis: Helsinki-NLP/opus-mt-en-de, ONNX-Port: Xenova)'**
  String get modellEnDeLizenz;

  /// No description provided for @modellDeEnTitel.
  ///
  /// In de, this message translates to:
  /// **'Übersetzung Deutsch → Englisch – OPUS-MT'**
  String get modellDeEnTitel;

  /// No description provided for @modellDeEnText.
  ///
  /// In de, this message translates to:
  /// **'Übersetzt deutsche Suchanfragen und Schlagwörter, bevor sie an die KI-Bildsuche gehen – deren Text-Encoder versteht nur Englisch. Rund 100 MB.'**
  String get modellDeEnText;

  /// No description provided for @modellDeEnLizenz.
  ///
  /// In de, this message translates to:
  /// **'Apache-2.0 (Basis: Helsinki-NLP/opus-mt-de-en, ONNX-Port: Xenova)'**
  String get modellDeEnLizenz;

  /// No description provided for @werkzKeineUnbewerteten.
  ///
  /// In de, this message translates to:
  /// **'Keine unbewerteten Fotos gefunden.'**
  String get werkzKeineUnbewerteten;

  /// No description provided for @werkzYunetNoetig.
  ///
  /// In de, this message translates to:
  /// **'Dafür wird zuerst das YuNet-Modell benötigt (Einstellungen → KI-Modelle).'**
  String get werkzYunetNoetig;

  /// No description provided for @werkzClipNoetig.
  ///
  /// In de, this message translates to:
  /// **'Dafür wird zuerst das CLIP-Modell benötigt (Einstellungen → KI-Modelle).'**
  String get werkzClipNoetig;

  /// No description provided for @werkzBeschreibungsmodellNoetig.
  ///
  /// In de, this message translates to:
  /// **'Dafür wird zuerst das Bildbeschreibungs-Modell benötigt (Einstellungen → KI-Modelle).'**
  String get werkzBeschreibungsmodellNoetig;

  /// No description provided for @werkzGeoNoetig.
  ///
  /// In de, this message translates to:
  /// **'Dafür wird zuerst der GeoNames-Datensatz benötigt (Einstellungen → Standortdaten).'**
  String get werkzGeoNoetig;

  /// No description provided for @werkzKeinePassenden.
  ///
  /// In de, this message translates to:
  /// **'Keine passenden Fotos gefunden.'**
  String get werkzKeinePassenden;

  /// No description provided for @werkzGesichterScannenTitel.
  ///
  /// In de, this message translates to:
  /// **'Gesichter scannen'**
  String get werkzGesichterScannenTitel;

  /// No description provided for @werkzGesichterScannenFrage.
  ///
  /// In de, this message translates to:
  /// **'Nur neue Fotos scannen: schnell, überspringt bereits gescannte Fotos.\n\nAlle Fotos erneut scannen: prüft die komplette Bibliothek neu (z.B. sinnvoll nach einem Update der Gesichtserkennung, oder um die Geschlossene-Augen-Erkennung nachträglich für bereits gescannte Fotos zu berechnen) – dauert bei großen Bibliotheken entsprechend länger. Bereits manuell zugeordnete Gesichter bleiben dabei erhalten.'**
  String get werkzGesichterScannenFrage;

  /// No description provided for @werkzNurNeueFotos.
  ///
  /// In de, this message translates to:
  /// **'Nur neue Fotos'**
  String get werkzNurNeueFotos;

  /// No description provided for @werkzAlleErneutScannen.
  ///
  /// In de, this message translates to:
  /// **'Alle erneut scannen'**
  String get werkzAlleErneutScannen;

  /// No description provided for @werkzScanneNeue.
  ///
  /// In de, this message translates to:
  /// **'Scanne neue Fotos …'**
  String get werkzScanneNeue;

  /// No description provided for @werkzScanneAlle.
  ///
  /// In de, this message translates to:
  /// **'Scanne alle Fotos erneut …'**
  String get werkzScanneAlle;

  /// No description provided for @werkzVorschauNeuTitel.
  ///
  /// In de, this message translates to:
  /// **'Vorschaubilder neu erstellen'**
  String get werkzVorschauNeuTitel;

  /// No description provided for @werkzVorschauNeuFrage.
  ///
  /// In de, this message translates to:
  /// **'Nur fehlende: verarbeitet nur Fotos/Videos, die aktuell kein Thumbnail haben (z.B. HEIC-Fotos, die vor Einrichtung der nativen Bildkonvertierung importiert wurden, oder Videos, die vor Einführung der Video-Thumbnail-Erzeugung importiert wurden).\n\nAlle neu erstellen: erzeugt für die komplette Bibliothek neue Thumbnails/Vorschauen – sinnvoll z.B. nach einem Update der Bild- oder Videokonvertierung. Dauert bei großen Bibliotheken entsprechend länger.'**
  String get werkzVorschauNeuFrage;

  /// No description provided for @werkzNurFehlende.
  ///
  /// In de, this message translates to:
  /// **'Nur fehlende'**
  String get werkzNurFehlende;

  /// No description provided for @werkzAlleNeuErstellen.
  ///
  /// In de, this message translates to:
  /// **'Alle neu erstellen'**
  String get werkzAlleNeuErstellen;

  /// No description provided for @werkzErstelleFehlende.
  ///
  /// In de, this message translates to:
  /// **'Erstelle fehlende Vorschaubilder …'**
  String get werkzErstelleFehlende;

  /// No description provided for @werkzErstelleAlle.
  ///
  /// In de, this message translates to:
  /// **'Erstelle alle Vorschaubilder neu …'**
  String get werkzErstelleAlle;

  /// No description provided for @werkzRendereNeu.
  ///
  /// In de, this message translates to:
  /// **'Rendere entwickelte Fotos neu …'**
  String get werkzRendereNeu;

  /// No description provided for @werkzKeineEntwickelten.
  ///
  /// In de, this message translates to:
  /// **'Keine entwickelten Fotos gefunden.'**
  String get werkzKeineEntwickelten;

  /// No description provided for @werkzPruefeLivePhotos.
  ///
  /// In de, this message translates to:
  /// **'Prüfe auf Live-Photo-Paare …'**
  String get werkzPruefeLivePhotos;

  /// No description provided for @werkzKeineUnverknuepften.
  ///
  /// In de, this message translates to:
  /// **'Keine unverknüpften Fotos gefunden.'**
  String get werkzKeineUnverknuepften;

  /// No description provided for @werkzBerechneEmbeddings.
  ///
  /// In de, this message translates to:
  /// **'Berechne CLIP-Embeddings …'**
  String get werkzBerechneEmbeddings;

  /// No description provided for @werkzAlleHabenEmbedding.
  ///
  /// In de, this message translates to:
  /// **'Alle Fotos haben bereits ein Embedding.'**
  String get werkzAlleHabenEmbedding;

  /// No description provided for @werkzKiTagsTitel.
  ///
  /// In de, this message translates to:
  /// **'KI-Tags berechnen'**
  String get werkzKiTagsTitel;

  /// No description provided for @werkzKiTagsFrage.
  ///
  /// In de, this message translates to:
  /// **'Nur ungetaggte Fotos: schnell, überspringt Fotos, die schon mindestens einen Tag haben (manuell oder automatisch).\n\nAlle Fotos: prüft die komplette Bibliothek neu und ergänzt zusätzlich passende KI-Tags bei bereits getaggten Fotos – vorhandene Tags bleiben dabei erhalten.'**
  String get werkzKiTagsFrage;

  /// No description provided for @werkzNurUngetaggte.
  ///
  /// In de, this message translates to:
  /// **'Nur ungetaggte'**
  String get werkzNurUngetaggte;

  /// No description provided for @werkzAlleFotos.
  ///
  /// In de, this message translates to:
  /// **'Alle Fotos'**
  String get werkzAlleFotos;

  /// No description provided for @werkzBerechneKiTags.
  ///
  /// In de, this message translates to:
  /// **'Berechne KI-Tags …'**
  String get werkzBerechneKiTags;

  /// No description provided for @werkzLeseOrte.
  ///
  /// In de, this message translates to:
  /// **'Lese Orte aus Fotos ein …'**
  String get werkzLeseOrte;

  /// No description provided for @werkzAlleHabenOrt.
  ///
  /// In de, this message translates to:
  /// **'Alle Fotos haben bereits einen Ort (oder keine EXIF-GPS-Daten).'**
  String get werkzAlleHabenOrt;

  /// No description provided for @werkzLoeseOrteAuf.
  ///
  /// In de, this message translates to:
  /// **'Löse Land/Bundesland/Stadt auf …'**
  String get werkzLoeseOrteAuf;

  /// No description provided for @werkzAlleAufgeloest.
  ///
  /// In de, this message translates to:
  /// **'Alle Fotos mit bekanntem Ort sind bereits aufgelöst.'**
  String get werkzAlleAufgeloest;

  /// No description provided for @werkzLeseKameradaten.
  ///
  /// In de, this message translates to:
  /// **'Lese Kameradaten aus Fotos ein …'**
  String get werkzLeseKameradaten;

  /// No description provided for @werkzAlleHabenKameradaten.
  ///
  /// In de, this message translates to:
  /// **'Alle Fotos haben bereits Kameradaten (oder keine passenden EXIF-Daten).'**
  String get werkzAlleHabenKameradaten;

  /// No description provided for @werkzSchreibeXmp.
  ///
  /// In de, this message translates to:
  /// **'Schreibe XMP-Sidecars …'**
  String get werkzSchreibeXmp;

  /// No description provided for @werkzKeineFotosGesperrt.
  ///
  /// In de, this message translates to:
  /// **'Keine Fotos gefunden (gesperrte Fotos werden übersprungen).'**
  String get werkzKeineFotosGesperrt;

  /// No description provided for @werkzErkenneText.
  ///
  /// In de, this message translates to:
  /// **'Erkenne Text in Fotos …'**
  String get werkzErkenneText;

  /// No description provided for @werkzAlleTextDurchsucht.
  ///
  /// In de, this message translates to:
  /// **'Alle Fotos wurden bereits nach Text durchsucht.'**
  String get werkzAlleTextDurchsucht;

  /// No description provided for @werkzErzeugeBeschreibungen.
  ///
  /// In de, this message translates to:
  /// **'Erzeuge Bildbeschreibungen …'**
  String get werkzErzeugeBeschreibungen;

  /// No description provided for @werkzAlleHabenBeschreibung.
  ///
  /// In de, this message translates to:
  /// **'Alle Fotos haben bereits eine KI-Beschreibung.'**
  String get werkzAlleHabenBeschreibung;

  /// No description provided for @werkzBerechneUnschaerfe.
  ///
  /// In de, this message translates to:
  /// **'Berechne Unschärfe-Scores …'**
  String get werkzBerechneUnschaerfe;

  /// No description provided for @werkzAlleHabenUnschaerfe.
  ///
  /// In de, this message translates to:
  /// **'Für alle Fotos wurde bereits ein Unschärfe-Score berechnet.'**
  String get werkzAlleHabenUnschaerfe;

  /// No description provided for @werkzAbschnittStatistik.
  ///
  /// In de, this message translates to:
  /// **'Statistik'**
  String get werkzAbschnittStatistik;

  /// No description provided for @werkzAnalyseseiteTitel.
  ///
  /// In de, this message translates to:
  /// **'Analyseseite'**
  String get werkzAnalyseseiteTitel;

  /// No description provided for @werkzAnalyseseiteText.
  ///
  /// In de, this message translates to:
  /// **'Anzahl Fotos/Videos, Speicherplatz, Aufnahmen pro Jahr/Monat, häufigste Kameras'**
  String get werkzAnalyseseiteText;

  /// No description provided for @werkzAbschnittGesichtserkennung.
  ///
  /// In de, this message translates to:
  /// **'Gesichtserkennung'**
  String get werkzAbschnittGesichtserkennung;

  /// No description provided for @werkzGesichterScannenUntertitel.
  ///
  /// In de, this message translates to:
  /// **'Manuell auslösen – neue oder alle Fotos'**
  String get werkzGesichterScannenUntertitel;

  /// No description provided for @werkzSchwelleLabel.
  ///
  /// In de, this message translates to:
  /// **'Ähnlichkeitsschwelle für\n\"Ähnliche mit auswählen\"'**
  String get werkzSchwelleLabel;

  /// No description provided for @werkzSchwelleErklaerung.
  ///
  /// In de, this message translates to:
  /// **'Höhere Werte = strengerer Abgleich (weniger, aber sicherere Treffer). Gilt für den Button \"Ähnliche mit auswählen\" im Personen-Tab bei \"Unbenannte Gesichter\".'**
  String get werkzSchwelleErklaerung;

  /// No description provided for @werkzAbschnittVorschau.
  ///
  /// In de, this message translates to:
  /// **'Vorschaubilder'**
  String get werkzAbschnittVorschau;

  /// No description provided for @werkzHeicTitel.
  ///
  /// In de, this message translates to:
  /// **'HEIC/HEIF & RAW-Unterstützung'**
  String get werkzHeicTitel;

  /// No description provided for @werkzHeicAktiv.
  ///
  /// In de, this message translates to:
  /// **'Aktiv – iPhone-Fotos (HEIC) und RAW-Dateien (DNG, CR2/CR3, NEF, ARW, RAF, ORF, RW2 & Co.) werden über die native macOS-Bildkonvertierung unterstützt.'**
  String get werkzHeicAktiv;

  /// No description provided for @werkzHeicInaktiv.
  ///
  /// In de, this message translates to:
  /// **'Inaktiv – native Swift-Datei muss noch ins Xcode-Projekt eingebunden werden (siehe README). JPG/PNG/WebP/GIF/BMP/TIFF funktionieren auch ohne das.'**
  String get werkzHeicInaktiv;

  /// No description provided for @werkzVorschauNeuUntertitel.
  ///
  /// In de, this message translates to:
  /// **'Für alle Fotos oder nur für noch fehlende'**
  String get werkzVorschauNeuUntertitel;

  /// No description provided for @werkzAbschnittEntwicklung.
  ///
  /// In de, this message translates to:
  /// **'Entwicklung'**
  String get werkzAbschnittEntwicklung;

  /// No description provided for @werkzNeuRendernTitel.
  ///
  /// In de, this message translates to:
  /// **'Entwickelte Fotos neu rendern'**
  String get werkzNeuRendernTitel;

  /// No description provided for @werkzNeuRendernText.
  ///
  /// In de, this message translates to:
  /// **'Rendert alle Fotos mit gespeicherten Entwicklungs-Anpassungen (Belichtung, Weißabgleich & Co.) mit unveränderten Einstellungen neu – z.B. sinnvoll nach einem Update der nativen Bildverarbeitung.'**
  String get werkzNeuRendernText;

  /// No description provided for @werkzAbschnittLivePhotos.
  ///
  /// In de, this message translates to:
  /// **'Live Photos'**
  String get werkzAbschnittLivePhotos;

  /// No description provided for @werkzLivePhotoTitel.
  ///
  /// In de, this message translates to:
  /// **'Live-Photo-Paare erneut prüfen'**
  String get werkzLivePhotoTitel;

  /// No description provided for @werkzLivePhotoText.
  ///
  /// In de, this message translates to:
  /// **'Für Fotos/Videos, die vor dieser Funktion importiert wurden – verknüpft HEIC/JPG-Standbilder mit gleichnamigen MOV-Videos.'**
  String get werkzLivePhotoText;

  /// No description provided for @werkzAbschnittOrte.
  ///
  /// In de, this message translates to:
  /// **'Orte'**
  String get werkzAbschnittOrte;

  /// No description provided for @werkzOrteEinlesenTitel.
  ///
  /// In de, this message translates to:
  /// **'Orte aus Fotos einlesen'**
  String get werkzOrteEinlesenTitel;

  /// No description provided for @werkzOrteEinlesenText.
  ///
  /// In de, this message translates to:
  /// **'Für Fotos, die vor Einführung der Kartenansicht importiert wurden – liest EXIF-GPS-Daten nachträglich ein.'**
  String get werkzOrteEinlesenText;

  /// No description provided for @werkzOrteAufloesenTitel.
  ///
  /// In de, this message translates to:
  /// **'Land/Bundesland/Stadt auflösen'**
  String get werkzOrteAufloesenTitel;

  /// No description provided for @werkzOrteAufloesenText.
  ///
  /// In de, this message translates to:
  /// **'Ordnet dem GPS-Ort eines Fotos Land, Bundesland/Provinz und Stadt zu – komplett lokal/offline über den GeoNames-Datensatz (siehe Einstellungen → Standortdaten). Für die Land-/Bundesland-/Stadt-Filter in den Suchoptionen nötig.'**
  String get werkzOrteAufloesenText;

  /// No description provided for @werkzAbschnittKamera.
  ///
  /// In de, this message translates to:
  /// **'Kamera'**
  String get werkzAbschnittKamera;

  /// No description provided for @werkzKameradatenTitel.
  ///
  /// In de, this message translates to:
  /// **'Kameradaten aus Fotos einlesen'**
  String get werkzKameradatenTitel;

  /// No description provided for @werkzKameradatenText.
  ///
  /// In de, this message translates to:
  /// **'Für Fotos, die vor Einführung der Kamera-Anzeige importiert wurden – liest Kamera, Objektiv, Brennweite, Blende, ISO und Belichtungszeit aus den EXIF-Daten nachträglich ein.'**
  String get werkzKameradatenText;

  /// No description provided for @werkzPresetsTitel.
  ///
  /// In de, this message translates to:
  /// **'Kamera-Presets verwalten'**
  String get werkzPresetsTitel;

  /// No description provided for @werkzPresetsText.
  ///
  /// In de, this message translates to:
  /// **'Fotos einer bestimmten Kamera automatisch beim Import einem Album/Tag zuordnen oder favorisieren – analog zu Digikams \"Kamera für den Import voreinstellen\".'**
  String get werkzPresetsText;

  /// No description provided for @werkzRegelnTitel.
  ///
  /// In de, this message translates to:
  /// **'Automatisierungsregeln verwalten'**
  String get werkzRegelnTitel;

  /// No description provided for @werkzRegelnText.
  ///
  /// In de, this message translates to:
  /// **'Fotos automatisch anhand von Ort, KI-Tag oder Aufnahmedatum einem Album/Tag zuordnen oder favorisieren – wie Kamera-Presets, nur für andere Bedingungen.'**
  String get werkzRegelnText;

  /// No description provided for @werkzAbschnittQualitaet.
  ///
  /// In de, this message translates to:
  /// **'Fotoqualität'**
  String get werkzAbschnittQualitaet;

  /// No description provided for @werkzOcrTitel.
  ///
  /// In de, this message translates to:
  /// **'Text in Fotos erkennen'**
  String get werkzOcrTitel;

  /// No description provided for @werkzOcrText.
  ///
  /// In de, this message translates to:
  /// **'Für Fotos, die vor Einführung der Textsuche importiert wurden – erkennt sichtbaren Text (z.B. Schilder, Dokumente) nachträglich, rein lokal über Apples Vision-Framework.'**
  String get werkzOcrText;

  /// No description provided for @werkzBeschreibungenTitel.
  ///
  /// In de, this message translates to:
  /// **'Bildbeschreibungen erzeugen'**
  String get werkzBeschreibungenTitel;

  /// No description provided for @werkzBeschreibungenText.
  ///
  /// In de, this message translates to:
  /// **'Für Fotos, die vor Installation des Bildbeschreibungs-Modells importiert wurden – erzeugt eine kurze, englische Bildunterschrift pro Foto, rein lokal.'**
  String get werkzBeschreibungenText;

  /// No description provided for @werkzUnschaerfeTitel.
  ///
  /// In de, this message translates to:
  /// **'Unschärfe neu berechnen'**
  String get werkzUnschaerfeTitel;

  /// No description provided for @werkzUnschaerfeText.
  ///
  /// In de, this message translates to:
  /// **'Für Fotos, die vor Einführung der Unschärfe-Erkennung importiert wurden – ermöglicht den Suchfilter \"Nur unscharfe Fotos anzeigen\".'**
  String get werkzUnschaerfeText;

  /// No description provided for @werkzAbschnittBildsuche.
  ///
  /// In de, this message translates to:
  /// **'KI-Bildsuche'**
  String get werkzAbschnittBildsuche;

  /// No description provided for @werkzAllesNachholenTitel.
  ///
  /// In de, this message translates to:
  /// **'Alle Auswertungen jetzt nachholen'**
  String get werkzAllesNachholenTitel;

  /// No description provided for @werkzAllesNachholenText.
  ///
  /// In de, this message translates to:
  /// **'Startet alle rechenintensiven Schritte nacheinander im Hintergrund: Unschärfe, Gesichter, Texterkennung, Bildsuche, Schlagwörter und Bildbeschreibung. Jeder Schritt überspringt, was er schon hat – die App bleibt bedienbar.'**
  String get werkzAllesNachholenText;

  /// No description provided for @werkzAnalyseGestartet.
  ///
  /// In de, this message translates to:
  /// **'Auswertung läuft im Hintergrund – Fortschritt oben in der Leiste.'**
  String get werkzAnalyseGestartet;

  /// No description provided for @werkzEmbeddingsTitel.
  ///
  /// In de, this message translates to:
  /// **'CLIP-Embeddings berechnen'**
  String get werkzEmbeddingsTitel;

  /// No description provided for @werkzEmbeddingsText.
  ///
  /// In de, this message translates to:
  /// **'Für Fotos, die vor Installation des CLIP-Modells importiert wurden – ohne Embedding tauchen sie in der KI-Bildsuche und der Duplikatsuche nicht auf.'**
  String get werkzEmbeddingsText;

  /// No description provided for @werkzKiTagsKarteText.
  ///
  /// In de, this message translates to:
  /// **'Ordnet Fotos automatisch passende Tags aus einer festen Begriffsliste zu (z.B. \"Kind\", \"Draußen\", \"Geburtstag\") – auf Basis des CLIP-Modells, ohne zusätzlichen Download. Tags lassen sich in der Info-Ansicht eines Fotos jederzeit anpassen.'**
  String get werkzKiTagsKarteText;

  /// No description provided for @werkzAbschnittBibliothek.
  ///
  /// In de, this message translates to:
  /// **'Bibliothek'**
  String get werkzAbschnittBibliothek;

  /// No description provided for @werkzSichtenTitel.
  ///
  /// In de, this message translates to:
  /// **'Unbewertete Fotos sichten'**
  String get werkzSichtenTitel;

  /// No description provided for @werkzSichtenText.
  ///
  /// In de, this message translates to:
  /// **'Öffnet alle noch unbewerteten Fotos/Videos im Vollbild-Sichtungs-Modus, zum schnellen Durchgehen und Bewerten.'**
  String get werkzSichtenText;

  /// No description provided for @werkzDuplikateTitel.
  ///
  /// In de, this message translates to:
  /// **'Duplikate & ähnliche Fotos suchen'**
  String get werkzDuplikateTitel;

  /// No description provided for @werkzDuplikateText.
  ///
  /// In de, this message translates to:
  /// **'Auf Basis der CLIP-Bild-Embeddings'**
  String get werkzDuplikateText;

  /// No description provided for @werkzStapelTitel.
  ///
  /// In de, this message translates to:
  /// **'Serienbilder gruppieren'**
  String get werkzStapelTitel;

  /// No description provided for @werkzStapelText.
  ///
  /// In de, this message translates to:
  /// **'Findet zeitlich nahe, ähnliche Fotos (z.B. Serienbilder) und fasst sie auf Wunsch zu einem Stapel mit einem Titelbild zusammen.'**
  String get werkzStapelText;

  /// No description provided for @werkzIntegritaetTitel.
  ///
  /// In de, this message translates to:
  /// **'Bibliotheks-Integritätsprüfung'**
  String get werkzIntegritaetTitel;

  /// No description provided for @werkzIntegritaetText.
  ///
  /// In de, this message translates to:
  /// **'Gleicht die Datenbank gegen die tatsächlichen Dateien auf der Platte ab: fehlende Dateien, verwaiste Dateien, optional Prüfsummen-Abweichungen.'**
  String get werkzIntegritaetText;

  /// No description provided for @werkzAbschnittInterop.
  ///
  /// In de, this message translates to:
  /// **'Interoperabilität'**
  String get werkzAbschnittInterop;

  /// No description provided for @werkzXmpSchreibenTitel.
  ///
  /// In de, this message translates to:
  /// **'XMP-Sidecars schreiben'**
  String get werkzXmpSchreibenTitel;

  /// No description provided for @werkzXmpSchreibenText.
  ///
  /// In de, this message translates to:
  /// **'Legt für jedes Foto eine .xmp-Datei mit Bewertung, Farbmarkierung, Beschreibung, Tags und Kamera-Daten daneben ab – für Lightroom, darktable oder digiKam. Gesperrte Fotos werden übersprungen. Passiert automatisch auch beim Exportieren und bei unverschlüsselten Backups.'**
  String get werkzXmpSchreibenText;

  /// No description provided for @werkzXmpLesenTitel.
  ///
  /// In de, this message translates to:
  /// **'XMP-Sidecars einlesen'**
  String get werkzXmpLesenTitel;

  /// No description provided for @werkzXmpLesenText.
  ///
  /// In de, this message translates to:
  /// **'Liest vorhandene .xmp-Dateien (z.B. extern in Lightroom/darktable/digiKam bearbeitet) und zeigt Abweichungen zur Datenbank – Bewertung, Farbmarkierung, Beschreibung, Tags, Standort.'**
  String get werkzXmpLesenText;

  /// No description provided for @sichtungHilfeleiste.
  ///
  /// In de, this message translates to:
  /// **'{aktuell} / {gesamt}   ·   0–5 Bewertung   ·   ⌫ Ablehnen   ·   ← → weiter'**
  String sichtungHilfeleiste(int aktuell, int gesamt);

  /// No description provided for @ansicht360.
  ///
  /// In de, this message translates to:
  /// **'360°-Ansicht'**
  String get ansicht360;

  /// Knopf unter den ausgewählten Gesichtern – knapper als der Dialogtitel.
  ///
  /// In de, this message translates to:
  /// **'{anzahl} zuordnen'**
  String personenZuordnenKnopf(int anzahl);

  /// No description provided for @aufgStatus.
  ///
  /// In de, this message translates to:
  /// **'Status'**
  String get aufgStatus;

  /// No description provided for @aufgBereit.
  ///
  /// In de, this message translates to:
  /// **'Bereit'**
  String get aufgBereit;

  /// No description provided for @aufgLaeuft.
  ///
  /// In de, this message translates to:
  /// **'Auswertung läuft im Hintergrund.'**
  String get aufgLaeuft;

  /// No description provided for @aufgJetztStarten.
  ///
  /// In de, this message translates to:
  /// **'Jetzt starten'**
  String get aufgJetztStarten;

  /// No description provided for @aufgWartend.
  ///
  /// In de, this message translates to:
  /// **'Wartend'**
  String get aufgWartend;

  /// No description provided for @aufgBetrifft.
  ///
  /// In de, this message translates to:
  /// **'Betrifft'**
  String get aufgBetrifft;

  /// No description provided for @aufgStufe.
  ///
  /// In de, this message translates to:
  /// **'{stufe} ({erledigt}/{gesamt}) – Stufe {nummer}/{stufenGesamt}'**
  String aufgStufe(
      String stufe, int erledigt, int gesamt, int nummer, int stufenGesamt);

  /// No description provided for @aufgModellNoetig.
  ///
  /// In de, this message translates to:
  /// **'Dafür wird zuerst {modell} benötigt ({wo}).'**
  String aufgModellNoetig(String modell, String wo);

  /// No description provided for @aufgYunetModell.
  ///
  /// In de, this message translates to:
  /// **'das YuNet-Modell'**
  String get aufgYunetModell;

  /// No description provided for @aufgClipModell.
  ///
  /// In de, this message translates to:
  /// **'das CLIP-Modell'**
  String get aufgClipModell;

  /// No description provided for @aufgBeschreibungsmodell.
  ///
  /// In de, this message translates to:
  /// **'das Bildbeschreibungs-Modell'**
  String get aufgBeschreibungsmodell;

  /// No description provided for @aufgGeoDatensatz.
  ///
  /// In de, this message translates to:
  /// **'der GeoNames-Datensatz'**
  String get aufgGeoDatensatz;

  /// No description provided for @aufgWoModelle.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen → KI-Modelle'**
  String get aufgWoModelle;

  /// No description provided for @aufgWoStandortdaten.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen → Standortdaten'**
  String get aufgWoStandortdaten;

  /// No description provided for @aufgGesichterText.
  ///
  /// In de, this message translates to:
  /// **'Erkennt und ordnet Gesichter zu, sofern das YuNet-Modell installiert ist.'**
  String get aufgGesichterText;

  /// No description provided for @aufgNeueFotos.
  ///
  /// In de, this message translates to:
  /// **'Neue Fotos'**
  String get aufgNeueFotos;

  /// No description provided for @aufgAlleErneut.
  ///
  /// In de, this message translates to:
  /// **'Alle erneut'**
  String get aufgAlleErneut;

  /// No description provided for @aufgVorschauText.
  ///
  /// In de, this message translates to:
  /// **'Erzeugt Thumbnails/Vorschauen für Fotos und Videos.'**
  String get aufgVorschauText;

  /// No description provided for @aufgFehlende.
  ///
  /// In de, this message translates to:
  /// **'Fehlende'**
  String get aufgFehlende;

  /// No description provided for @aufgAlleNeu.
  ///
  /// In de, this message translates to:
  /// **'Alle neu'**
  String get aufgAlleNeu;

  /// No description provided for @aufgOcrTitel.
  ///
  /// In de, this message translates to:
  /// **'Text erkennen (OCR)'**
  String get aufgOcrTitel;

  /// No description provided for @aufgOcrText.
  ///
  /// In de, this message translates to:
  /// **'Erkennt sichtbaren Text in Fotos, rein lokal über Apples Vision-Framework.'**
  String get aufgOcrText;

  /// No description provided for @aufgStarten.
  ///
  /// In de, this message translates to:
  /// **'Starten'**
  String get aufgStarten;

  /// No description provided for @aufgBeschreibungenTitel.
  ///
  /// In de, this message translates to:
  /// **'Bildbeschreibungen'**
  String get aufgBeschreibungenTitel;

  /// No description provided for @aufgBeschreibungenText.
  ///
  /// In de, this message translates to:
  /// **'Erzeugt eine kurze, englische KI-Bildunterschrift pro Foto.'**
  String get aufgBeschreibungenText;

  /// No description provided for @aufgEmbeddingsTitel.
  ///
  /// In de, this message translates to:
  /// **'CLIP-Embeddings'**
  String get aufgEmbeddingsTitel;

  /// No description provided for @aufgEmbeddingsText.
  ///
  /// In de, this message translates to:
  /// **'Grundlage für KI-Bildsuche und Duplikatsuche.'**
  String get aufgEmbeddingsText;

  /// No description provided for @aufgKiTagsTitel.
  ///
  /// In de, this message translates to:
  /// **'KI-Tags'**
  String get aufgKiTagsTitel;

  /// No description provided for @aufgKiTagsText.
  ///
  /// In de, this message translates to:
  /// **'Ordnet Fotos automatisch passende Tags aus dem Vokabular zu (auf CLIP-Basis).'**
  String get aufgKiTagsText;

  /// No description provided for @aufgUngetaggte.
  ///
  /// In de, this message translates to:
  /// **'Ungetaggte'**
  String get aufgUngetaggte;

  /// No description provided for @aufgUnschaerfeTitel.
  ///
  /// In de, this message translates to:
  /// **'Unschärfe'**
  String get aufgUnschaerfeTitel;

  /// No description provided for @aufgUnschaerfeText.
  ///
  /// In de, this message translates to:
  /// **'Ermöglicht den Suchfilter \"Nur unscharfe Fotos anzeigen\".'**
  String get aufgUnschaerfeText;

  /// No description provided for @aufgOrteTitel.
  ///
  /// In de, this message translates to:
  /// **'Orte einlesen'**
  String get aufgOrteTitel;

  /// No description provided for @aufgOrteText.
  ///
  /// In de, this message translates to:
  /// **'Liest EXIF-GPS-Daten aus Fotos nachträglich ein.'**
  String get aufgOrteText;

  /// No description provided for @aufgOrteAufloesenText.
  ///
  /// In de, this message translates to:
  /// **'Ordnet dem GPS-Ort eines Fotos Land, Bundesland/Provinz und Stadt zu.'**
  String get aufgOrteAufloesenText;

  /// No description provided for @aufgKameraTitel.
  ///
  /// In de, this message translates to:
  /// **'Kameradaten einlesen'**
  String get aufgKameraTitel;

  /// No description provided for @aufgKameraText.
  ///
  /// In de, this message translates to:
  /// **'Liest Kamera, Objektiv, Brennweite, Blende, ISO und Belichtungszeit aus EXIF ein.'**
  String get aufgKameraText;

  /// No description provided for @aufgLivePhotoTitel.
  ///
  /// In de, this message translates to:
  /// **'Live-Photo-Paare prüfen'**
  String get aufgLivePhotoTitel;

  /// No description provided for @aufgLivePhotoText.
  ///
  /// In de, this message translates to:
  /// **'Verknüpft HEIC/JPG-Standbilder mit gleichnamigen MOV-Videos.'**
  String get aufgLivePhotoText;

  /// No description provided for @aufgRendernText.
  ///
  /// In de, this message translates to:
  /// **'Rendert Fotos mit gespeicherten Entwicklungs-Anpassungen unverändert neu.'**
  String get aufgRendernText;

  /// No description provided for @aufgXmpText.
  ///
  /// In de, this message translates to:
  /// **'Legt für jedes Foto eine .xmp-Datei für Lightroom/darktable/digiKam daneben ab.'**
  String get aufgXmpText;

  /// No description provided for @auswAufheben.
  ///
  /// In de, this message translates to:
  /// **'Auswahl aufheben'**
  String get auswAufheben;

  /// No description provided for @auswAnzahl.
  ///
  /// In de, this message translates to:
  /// **'{anzahl} ausgewählt'**
  String auswAnzahl(int anzahl);

  /// No description provided for @auswFavorisieren.
  ///
  /// In de, this message translates to:
  /// **'Favorisieren'**
  String get auswFavorisieren;

  /// No description provided for @auswZuAlbum.
  ///
  /// In de, this message translates to:
  /// **'Zu Album hinzufügen'**
  String get auswZuAlbum;

  /// No description provided for @auswTagHinzufuegen.
  ///
  /// In de, this message translates to:
  /// **'Tag hinzufügen'**
  String get auswTagHinzufuegen;

  /// No description provided for @auswBewertungSetzen.
  ///
  /// In de, this message translates to:
  /// **'Bewertung setzen'**
  String get auswBewertungSetzen;

  /// No description provided for @auswFarbeSetzen.
  ///
  /// In de, this message translates to:
  /// **'Farbmarkierung setzen'**
  String get auswFarbeSetzen;

  /// No description provided for @auswMetadaten.
  ///
  /// In de, this message translates to:
  /// **'Metadaten bearbeiten'**
  String get auswMetadaten;

  /// No description provided for @auswEntwicklungUebertragen.
  ///
  /// In de, this message translates to:
  /// **'Kopierte Entwicklung übertragen'**
  String get auswEntwicklungUebertragen;

  /// No description provided for @auswExportieren.
  ///
  /// In de, this message translates to:
  /// **'Exportieren'**
  String get auswExportieren;

  /// No description provided for @allgLoeschen.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get allgLoeschen;

  /// No description provided for @allgHinzufuegen.
  ///
  /// In de, this message translates to:
  /// **'Hinzufügen'**
  String get allgHinzufuegen;

  /// No description provided for @allgWaehlen.
  ///
  /// In de, this message translates to:
  /// **'Wählen'**
  String get allgWaehlen;

  /// No description provided for @auswBewertungTitel.
  ///
  /// In de, this message translates to:
  /// **'Bewertung für {anzahl} Foto(s)'**
  String auswBewertungTitel(int anzahl);

  /// No description provided for @auswKeineBewertung.
  ///
  /// In de, this message translates to:
  /// **'Keine Bewertung'**
  String get auswKeineBewertung;

  /// No description provided for @auswFarbeTitel.
  ///
  /// In de, this message translates to:
  /// **'Farbmarkierung für {anzahl} Foto(s)'**
  String auswFarbeTitel(int anzahl);

  /// No description provided for @auswKeineFarbe.
  ///
  /// In de, this message translates to:
  /// **'Keine Farbe'**
  String get auswKeineFarbe;

  /// No description provided for @auswMetadatenTitel.
  ///
  /// In de, this message translates to:
  /// **'Metadaten für {anzahl} Foto(s) bearbeiten'**
  String auswMetadatenTitel(int anzahl);

  /// No description provided for @auswBeschreibungFeld.
  ///
  /// In de, this message translates to:
  /// **'Beschreibung (überschreibt bestehende)'**
  String get auswBeschreibungFeld;

  /// No description provided for @auswDatumUnveraendert.
  ///
  /// In de, this message translates to:
  /// **'Datum unverändert lassen'**
  String get auswDatumUnveraendert;

  /// No description provided for @auswDatumGesetzt.
  ///
  /// In de, this message translates to:
  /// **'Datum: {datum}'**
  String auswDatumGesetzt(String datum);

  /// No description provided for @auswOrtHinweis.
  ///
  /// In de, this message translates to:
  /// **'Ort (unverändert lassen: nicht antippen)'**
  String get auswOrtHinweis;

  /// No description provided for @auswTagTitel.
  ///
  /// In de, this message translates to:
  /// **'Tag zu {anzahl} Foto(s) hinzufügen'**
  String auswTagTitel(int anzahl);

  /// No description provided for @auswTagFeld.
  ///
  /// In de, this message translates to:
  /// **'Tag'**
  String get auswTagFeld;

  /// No description provided for @auswExportTitel.
  ///
  /// In de, this message translates to:
  /// **'{anzahl} Foto(s) exportieren'**
  String auswExportTitel(int anzahl);

  /// No description provided for @auswUebertragenTitel.
  ///
  /// In de, this message translates to:
  /// **'Entwicklung auf {anzahl} Foto(s) übertragen?'**
  String auswUebertragenTitel(int anzahl);

  /// No description provided for @auswUebertragenText.
  ///
  /// In de, this message translates to:
  /// **'Die kopierten Werte für Belichtung, Weissabgleich, Kontrast und Schatten werden übernommen; jedes Foto wird dabei neu gerendert.\n\nMasken werden nicht übertragen. Der bisherige Stand jedes Fotos bleibt in dessen Verlauf erhalten.'**
  String get auswUebertragenText;

  /// No description provided for @auswUebertragen.
  ///
  /// In de, this message translates to:
  /// **'Übertragen'**
  String get auswUebertragen;

  /// No description provided for @auswUebertrageLaeuft.
  ///
  /// In de, this message translates to:
  /// **'Übertrage Entwicklung …'**
  String get auswUebertrageLaeuft;

  /// No description provided for @auswKeineGeeigneten.
  ///
  /// In de, this message translates to:
  /// **'Keine geeigneten Fotos – gesperrte Fotos und Videos bleiben aussen vor.'**
  String get auswKeineGeeigneten;

  /// No description provided for @auswZielordner.
  ///
  /// In de, this message translates to:
  /// **'Zielordner für {anzahl} Foto(s) wählen'**
  String auswZielordner(int anzahl);

  /// No description provided for @auswExportiereLaeuft.
  ///
  /// In de, this message translates to:
  /// **'Exportiere … ({erledigt} / {gesamt})'**
  String auswExportiereLaeuft(int erledigt, int gesamt);

  /// No description provided for @auswExportFertig.
  ///
  /// In de, this message translates to:
  /// **'{erledigt} von {gesamt} Foto(s) exportiert nach {ziel}'**
  String auswExportFertig(int erledigt, int gesamt, String ziel);

  /// No description provided for @exportOriginal.
  ///
  /// In de, this message translates to:
  /// **'Original'**
  String get exportOriginal;

  /// No description provided for @exportGross.
  ///
  /// In de, this message translates to:
  /// **'Gross – 4096 px'**
  String get exportGross;

  /// No description provided for @exportWeb.
  ///
  /// In de, this message translates to:
  /// **'Web – 2048 px'**
  String get exportWeb;

  /// No description provided for @exportEmail.
  ///
  /// In de, this message translates to:
  /// **'E-Mail – 1024 px'**
  String get exportEmail;

  /// No description provided for @exportUnveraendert.
  ///
  /// In de, this message translates to:
  /// **'Datei unverändert, mit XMP-Datei daneben'**
  String get exportUnveraendert;

  /// No description provided for @exportJpegKante.
  ///
  /// In de, this message translates to:
  /// **'Als JPEG, lange Kante höchstens {kante} px'**
  String exportJpegKante(int kante);

  /// No description provided for @allgUebernehmen.
  ///
  /// In de, this message translates to:
  /// **'Übernehmen'**
  String get allgUebernehmen;

  /// No description provided for @allgAlle.
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get allgAlle;

  /// No description provided for @suchoptTagsWaehlen.
  ///
  /// In de, this message translates to:
  /// **'Tags auswählen'**
  String get suchoptTagsWaehlen;

  /// No description provided for @suchoptTagsFiltern.
  ///
  /// In de, this message translates to:
  /// **'Tags filtern …'**
  String get suchoptTagsFiltern;

  /// No description provided for @suchoptKeineTags.
  ///
  /// In de, this message translates to:
  /// **'Keine Tags gefunden.'**
  String get suchoptKeineTags;

  /// No description provided for @suchoptTitel.
  ///
  /// In de, this message translates to:
  /// **'Suchoptionen'**
  String get suchoptTitel;

  /// No description provided for @suchoptKeineTreffer.
  ///
  /// In de, this message translates to:
  /// **'Keine Fotos gefunden – diese Filterkombination liefert 0 Treffer.'**
  String get suchoptKeineTreffer;

  /// No description provided for @suchoptAllesLeeren.
  ///
  /// In de, this message translates to:
  /// **'Alles leeren'**
  String get suchoptAllesLeeren;

  /// No description provided for @suchoptSuchen.
  ///
  /// In de, this message translates to:
  /// **'Suche'**
  String get suchoptSuchen;

  /// No description provided for @suchoptPersonenFiltern.
  ///
  /// In de, this message translates to:
  /// **'Personen filtern'**
  String get suchoptPersonenFiltern;

  /// No description provided for @suchoptKeinePersonenBenannt.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Personen benannt.'**
  String get suchoptKeinePersonenBenannt;

  /// No description provided for @suchoptKeinePersonenGefunden.
  ///
  /// In de, this message translates to:
  /// **'Keine Personen gefunden.'**
  String get suchoptKeinePersonenGefunden;

  /// No description provided for @suchoptTypTitel.
  ///
  /// In de, this message translates to:
  /// **'Suche nach Typ'**
  String get suchoptTypTitel;

  /// No description provided for @suchoptTypKontext.
  ///
  /// In de, this message translates to:
  /// **'Kontext'**
  String get suchoptTypKontext;

  /// No description provided for @suchoptTypDateiname.
  ///
  /// In de, this message translates to:
  /// **'Dateiname'**
  String get suchoptTypDateiname;

  /// No description provided for @suchoptTypBeschreibung.
  ///
  /// In de, this message translates to:
  /// **'Beschreibung'**
  String get suchoptTypBeschreibung;

  /// No description provided for @suchoptTypOcr.
  ///
  /// In de, this message translates to:
  /// **'Text im Foto (OCR)'**
  String get suchoptTypOcr;

  /// No description provided for @suchoptTypCaption.
  ///
  /// In de, this message translates to:
  /// **'KI-Beschreibung (Englisch)'**
  String get suchoptTypCaption;

  /// No description provided for @suchoptNachKontext.
  ///
  /// In de, this message translates to:
  /// **'Suche nach Kontext'**
  String get suchoptNachKontext;

  /// No description provided for @suchoptNachDateiname.
  ///
  /// In de, this message translates to:
  /// **'Suche nach Dateiname'**
  String get suchoptNachDateiname;

  /// No description provided for @suchoptNachBeschreibung.
  ///
  /// In de, this message translates to:
  /// **'Suche nach Beschreibung'**
  String get suchoptNachBeschreibung;

  /// No description provided for @suchoptNachOcr.
  ///
  /// In de, this message translates to:
  /// **'Suche nach erkanntem Text im Foto'**
  String get suchoptNachOcr;

  /// No description provided for @suchoptNachCaption.
  ///
  /// In de, this message translates to:
  /// **'Suche nach KI-Beschreibung (Englisch)'**
  String get suchoptNachCaption;

  /// No description provided for @suchoptHintKontext.
  ///
  /// In de, this message translates to:
  /// **'z.B. \"Sonnenaufgang am Strand\", \"Hund im Schnee\" …'**
  String get suchoptHintKontext;

  /// No description provided for @suchoptHintDateiname.
  ///
  /// In de, this message translates to:
  /// **'Dateiname …'**
  String get suchoptHintDateiname;

  /// No description provided for @suchoptHintBeschreibung.
  ///
  /// In de, this message translates to:
  /// **'Beschreibung …'**
  String get suchoptHintBeschreibung;

  /// No description provided for @suchoptHintOcr.
  ///
  /// In de, this message translates to:
  /// **'Text im Foto …'**
  String get suchoptHintOcr;

  /// No description provided for @suchoptHintCaption.
  ///
  /// In de, this message translates to:
  /// **'z.B. \"dog\", \"sunset\" (Englisch) …'**
  String get suchoptHintCaption;

  /// No description provided for @suchoptClipFehlt.
  ///
  /// In de, this message translates to:
  /// **'KI-Bildsuche nicht verfügbar – Modell fehlt (siehe Einstellungen → KI-Modelle).'**
  String get suchoptClipFehlt;

  /// No description provided for @suchoptCaptionFehlt.
  ///
  /// In de, this message translates to:
  /// **'KI-Bildbeschreibung nicht verfügbar – Modell fehlt (siehe Einstellungen → KI-Modelle).'**
  String get suchoptCaptionFehlt;

  /// No description provided for @suchoptTagsTitel.
  ///
  /// In de, this message translates to:
  /// **'Tags'**
  String get suchoptTagsTitel;

  /// No description provided for @suchoptTagsHint.
  ///
  /// In de, this message translates to:
  /// **'Suche nach Tags …'**
  String get suchoptTagsHint;

  /// No description provided for @suchoptOhneTag.
  ///
  /// In de, this message translates to:
  /// **'Ohne Tag'**
  String get suchoptOhneTag;

  /// No description provided for @suchoptMindestbewertung.
  ///
  /// In de, this message translates to:
  /// **'Mindestbewertung'**
  String get suchoptMindestbewertung;

  /// No description provided for @suchoptFarbmarkierung.
  ///
  /// In de, this message translates to:
  /// **'Farbmarkierung'**
  String get suchoptFarbmarkierung;

  /// No description provided for @farbeRot.
  ///
  /// In de, this message translates to:
  /// **'Rot'**
  String get farbeRot;

  /// No description provided for @farbeGelb.
  ///
  /// In de, this message translates to:
  /// **'Gelb'**
  String get farbeGelb;

  /// No description provided for @farbeGruen.
  ///
  /// In de, this message translates to:
  /// **'Grün'**
  String get farbeGruen;

  /// No description provided for @farbeBlau.
  ///
  /// In de, this message translates to:
  /// **'Blau'**
  String get farbeBlau;

  /// No description provided for @farbeLila.
  ///
  /// In de, this message translates to:
  /// **'Lila'**
  String get farbeLila;

  /// No description provided for @suchoptAufnahmewerte.
  ///
  /// In de, this message translates to:
  /// **'Aufnahmewerte'**
  String get suchoptAufnahmewerte;

  /// No description provided for @suchoptIsoVon.
  ///
  /// In de, this message translates to:
  /// **'ISO von'**
  String get suchoptIsoVon;

  /// No description provided for @suchoptIsoBis.
  ///
  /// In de, this message translates to:
  /// **'ISO bis'**
  String get suchoptIsoBis;

  /// No description provided for @suchoptBlendeVon.
  ///
  /// In de, this message translates to:
  /// **'Blende von (f/…)'**
  String get suchoptBlendeVon;

  /// No description provided for @suchoptBlendeBis.
  ///
  /// In de, this message translates to:
  /// **'Blende bis (f/…)'**
  String get suchoptBlendeBis;

  /// No description provided for @suchoptBrennweiteVon.
  ///
  /// In de, this message translates to:
  /// **'Brennweite von (mm)'**
  String get suchoptBrennweiteVon;

  /// No description provided for @suchoptBrennweiteBis.
  ///
  /// In de, this message translates to:
  /// **'Brennweite bis (mm)'**
  String get suchoptBrennweiteBis;

  /// No description provided for @suchoptNurUnscharfe.
  ///
  /// In de, this message translates to:
  /// **'Nur unscharfe Fotos anzeigen'**
  String get suchoptNurUnscharfe;

  /// No description provided for @suchoptMarke.
  ///
  /// In de, this message translates to:
  /// **'Marke'**
  String get suchoptMarke;

  /// No description provided for @suchoptModell.
  ///
  /// In de, this message translates to:
  /// **'Modell'**
  String get suchoptModell;

  /// No description provided for @suchoptObjektiv.
  ///
  /// In de, this message translates to:
  /// **'Objektiv'**
  String get suchoptObjektiv;

  /// No description provided for @suchoptOrtTitel.
  ///
  /// In de, this message translates to:
  /// **'Ort'**
  String get suchoptOrtTitel;

  /// No description provided for @suchoptLand.
  ///
  /// In de, this message translates to:
  /// **'Land'**
  String get suchoptLand;

  /// No description provided for @suchoptBundesland.
  ///
  /// In de, this message translates to:
  /// **'Bundesland'**
  String get suchoptBundesland;

  /// No description provided for @suchoptStadt.
  ///
  /// In de, this message translates to:
  /// **'Stadt'**
  String get suchoptStadt;

  /// No description provided for @suchoptGeoFehlt.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Orte aufgelöst – GeoNames-Datensatz herunterladen und Fotos auflösen (siehe Einstellungen → Standortdaten, Werkzeuge → Orte).'**
  String get suchoptGeoFehlt;

  /// No description provided for @suchoptAnfangsdatum.
  ///
  /// In de, this message translates to:
  /// **'Anfangsdatum'**
  String get suchoptAnfangsdatum;

  /// No description provided for @suchoptEnddatum.
  ///
  /// In de, this message translates to:
  /// **'Enddatum'**
  String get suchoptEnddatum;

  /// No description provided for @suchoptDatumEntfernen.
  ///
  /// In de, this message translates to:
  /// **'Datum entfernen'**
  String get suchoptDatumEntfernen;

  /// No description provided for @suchoptDatumPlatzhalter.
  ///
  /// In de, this message translates to:
  /// **'tt.mm.jjjj'**
  String get suchoptDatumPlatzhalter;

  /// No description provided for @suchoptMedientyp.
  ///
  /// In de, this message translates to:
  /// **'Medientyp'**
  String get suchoptMedientyp;

  /// No description provided for @suchoptBild.
  ///
  /// In de, this message translates to:
  /// **'Bild'**
  String get suchoptBild;

  /// No description provided for @suchoptVideo.
  ///
  /// In de, this message translates to:
  /// **'Video'**
  String get suchoptVideo;

  /// No description provided for @suchoptAnzeigeoptionen.
  ///
  /// In de, this message translates to:
  /// **'Anzeigeoptionen'**
  String get suchoptAnzeigeoptionen;

  /// No description provided for @suchoptInKeinemAlbum.
  ///
  /// In de, this message translates to:
  /// **'In keinem Album'**
  String get suchoptInKeinemAlbum;

  /// No description provided for @suchoptFavoriten.
  ///
  /// In de, this message translates to:
  /// **'Favoriten'**
  String get suchoptFavoriten;

  /// No description provided for @entwTitel.
  ///
  /// In de, this message translates to:
  /// **'Entwickeln'**
  String get entwTitel;

  /// No description provided for @entwKeinVerlauf.
  ///
  /// In de, this message translates to:
  /// **'Noch kein Verlauf vorhanden – ein Eintrag entsteht, sobald du nach einer ersten Anpassung erneut speicherst.'**
  String get entwKeinVerlauf;

  /// No description provided for @entwKopiert.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen kopiert. Sie lassen sich jetzt auf andere Fotos übertragen – auch ohne dieses hier zu speichern.'**
  String get entwKopiert;

  /// No description provided for @entwEingesetzt.
  ///
  /// In de, this message translates to:
  /// **'Kopierte Einstellungen eingesetzt – noch nicht gespeichert.'**
  String get entwEingesetzt;

  /// No description provided for @entwSpeichernFehlgeschlagen.
  ///
  /// In de, this message translates to:
  /// **'Speichern fehlgeschlagen: Bild konnte nicht gerendert werden.'**
  String get entwSpeichernFehlgeschlagen;

  /// No description provided for @entwRestaurierungEingereiht.
  ///
  /// In de, this message translates to:
  /// **'Zur Warteschlange für KI-Restaurierung hinzugefügt.'**
  String get entwRestaurierungEingereiht;

  /// No description provided for @entwRestaurierungFehler.
  ///
  /// In de, this message translates to:
  /// **'Konnte nicht zur Warteschlange hinzugefügt werden: {fehler}'**
  String entwRestaurierungFehler(String fehler);

  /// No description provided for @entwKiAuswahlLadefehler.
  ///
  /// In de, this message translates to:
  /// **'KI-Auswahl konnte nicht geladen werden: {fehler}'**
  String entwKiAuswahlLadefehler(String fehler);

  /// No description provided for @entwVorschauNichtDekodiert.
  ///
  /// In de, this message translates to:
  /// **'Vorschaubild konnte nicht für die Maskierung dekodiert werden.'**
  String get entwVorschauNichtDekodiert;

  /// No description provided for @entwKiAuswahlFehler.
  ///
  /// In de, this message translates to:
  /// **'KI-Auswahl fehlgeschlagen: {fehler}'**
  String entwKiAuswahlFehler(String fehler);

  /// No description provided for @entwMaskeNummer.
  ///
  /// In de, this message translates to:
  /// **'Maske {nummer}'**
  String entwMaskeNummer(int nummer);

  /// No description provided for @entwAufloesungUnbekannt.
  ///
  /// In de, this message translates to:
  /// **'Bildauflösung unbekannt – Maske kann nicht gespeichert werden.'**
  String get entwAufloesungUnbekannt;

  /// No description provided for @entwRestaurierungEntfernen.
  ///
  /// In de, this message translates to:
  /// **'KI-Restaurierung entfernen'**
  String get entwRestaurierungEntfernen;

  /// No description provided for @entwRestaurierungModellFehlt.
  ///
  /// In de, this message translates to:
  /// **'Benötigt das Restaurierungs-Modell (Einstellungen → KI-Modelle)'**
  String get entwRestaurierungModellFehlt;

  /// No description provided for @entwRestaurierungAnwenden.
  ///
  /// In de, this message translates to:
  /// **'KI-Restaurierung anwenden (läuft im Hintergrund, dauert mehrere Minuten)'**
  String get entwRestaurierungAnwenden;

  /// No description provided for @entwMaskeHinzufuegen.
  ///
  /// In de, this message translates to:
  /// **'Maske hinzufügen'**
  String get entwMaskeHinzufuegen;

  /// No description provided for @entwVerlauf.
  ///
  /// In de, this message translates to:
  /// **'Verlauf'**
  String get entwVerlauf;

  /// No description provided for @entwEinstellungenKopieren.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen kopieren (zum Übertragen auf andere Fotos)'**
  String get entwEinstellungenKopieren;

  /// No description provided for @entwEinstellungenEinsetzen.
  ///
  /// In de, this message translates to:
  /// **'Kopierte Einstellungen in die Regler setzen'**
  String get entwEinstellungenEinsetzen;

  /// No description provided for @entwOriginal.
  ///
  /// In de, this message translates to:
  /// **'Original'**
  String get entwOriginal;

  /// No description provided for @entwVergleichen.
  ///
  /// In de, this message translates to:
  /// **'Zum Vergleichen gedrückt halten'**
  String get entwVergleichen;

  /// No description provided for @entwMaskeErstellen.
  ///
  /// In de, this message translates to:
  /// **'Maske erstellen'**
  String get entwMaskeErstellen;

  /// No description provided for @entwFormKi.
  ///
  /// In de, this message translates to:
  /// **'KI'**
  String get entwFormKi;

  /// No description provided for @entwFormPinsel.
  ///
  /// In de, this message translates to:
  /// **'Pinsel'**
  String get entwFormPinsel;

  /// No description provided for @entwFormEllipse.
  ///
  /// In de, this message translates to:
  /// **'Ellipse'**
  String get entwFormEllipse;

  /// No description provided for @entwFormVerlauf.
  ///
  /// In de, this message translates to:
  /// **'Verlauf'**
  String get entwFormVerlauf;

  /// No description provided for @allgFertig.
  ///
  /// In de, this message translates to:
  /// **'Fertig'**
  String get allgFertig;

  /// No description provided for @entwKiHinweis.
  ///
  /// In de, this message translates to:
  /// **'Auf den Bereich tippen, den du anpassen möchtest. Mehrere Tipps verfeinern die Auswahl.'**
  String get entwKiHinweis;

  /// No description provided for @entwPunktHinzufuegen.
  ///
  /// In de, this message translates to:
  /// **'Hinzufügen'**
  String get entwPunktHinzufuegen;

  /// No description provided for @entwPunktEntfernen.
  ///
  /// In de, this message translates to:
  /// **'Entfernen'**
  String get entwPunktEntfernen;

  /// No description provided for @entwLetztenPunktEntfernen.
  ///
  /// In de, this message translates to:
  /// **'Letzten Punkt entfernen'**
  String get entwLetztenPunktEntfernen;

  /// No description provided for @entwPinselHinweis.
  ///
  /// In de, this message translates to:
  /// **'Über den Bereich ziehen, den du anpassen möchtest.'**
  String get entwPinselHinweis;

  /// No description provided for @entwNeuZeichnen.
  ///
  /// In de, this message translates to:
  /// **'Neu zeichnen'**
  String get entwNeuZeichnen;

  /// No description provided for @entwEllipseHinweis.
  ///
  /// In de, this message translates to:
  /// **'Über den Bereich ziehen, um die Ellipse aufzuziehen.'**
  String get entwEllipseHinweis;

  /// No description provided for @entwVerlaufHinweis.
  ///
  /// In de, this message translates to:
  /// **'Von einer Kante zur anderen ziehen, um den Verlauf festzulegen.'**
  String get entwVerlaufHinweis;

  /// No description provided for @entwAnpassungFuer.
  ///
  /// In de, this message translates to:
  /// **'Anpassung für'**
  String get entwAnpassungFuer;

  /// No description provided for @entwGanzesBild.
  ///
  /// In de, this message translates to:
  /// **'Ganzes Bild'**
  String get entwGanzesBild;

  /// No description provided for @entwFormBearbeiten.
  ///
  /// In de, this message translates to:
  /// **'Form bearbeiten'**
  String get entwFormBearbeiten;

  /// No description provided for @entwAutoWeissabgleich.
  ///
  /// In de, this message translates to:
  /// **'Automatischer Weißabgleich'**
  String get entwAutoWeissabgleich;

  /// No description provided for @entwObjektivkorrektur.
  ///
  /// In de, this message translates to:
  /// **'Objektivkorrektur'**
  String get entwObjektivkorrektur;

  /// No description provided for @entwObjektivkorrekturHinweis.
  ///
  /// In de, this message translates to:
  /// **'Nur wirksam für RAW-Fotos, deren Kamera/Objektiv unterstützt wird.'**
  String get entwObjektivkorrekturHinweis;

  /// No description provided for @entwMaskenHinweis.
  ///
  /// In de, this message translates to:
  /// **'Diese Anpassungen wirken nur innerhalb der ausgewählten Maske.'**
  String get entwMaskenHinweis;

  /// No description provided for @entwBelichtung.
  ///
  /// In de, this message translates to:
  /// **'Belichtung'**
  String get entwBelichtung;

  /// No description provided for @entwTemperatur.
  ///
  /// In de, this message translates to:
  /// **'Temperatur (K)'**
  String get entwTemperatur;

  /// No description provided for @entwTint.
  ///
  /// In de, this message translates to:
  /// **'Tint'**
  String get entwTint;

  /// No description provided for @entwKontrast.
  ///
  /// In de, this message translates to:
  /// **'Kontrast'**
  String get entwKontrast;

  /// No description provided for @entwSchatten.
  ///
  /// In de, this message translates to:
  /// **'Schatten'**
  String get entwSchatten;

  /// No description provided for @entwSchaerfe.
  ///
  /// In de, this message translates to:
  /// **'Schärfe'**
  String get entwSchaerfe;

  /// No description provided for @entwRauschunterdrueckung.
  ///
  /// In de, this message translates to:
  /// **'Rauschunterdrückung'**
  String get entwRauschunterdrueckung;

  /// No description provided for @entwStrichbreite.
  ///
  /// In de, this message translates to:
  /// **'Strichbreite'**
  String get entwStrichbreite;

  /// No description provided for @entwRotation.
  ///
  /// In de, this message translates to:
  /// **'Rotation (°)'**
  String get entwRotation;

  /// No description provided for @entwWeichzeichnung.
  ///
  /// In de, this message translates to:
  /// **'Weichzeichnung'**
  String get entwWeichzeichnung;

  /// No description provided for @entwGesperrt.
  ///
  /// In de, this message translates to:
  /// **'Entwickeln ist für Fotos im gesperrten Ordner nicht verfügbar.'**
  String get entwGesperrt;

  /// No description provided for @entwVorschauFehlt.
  ///
  /// In de, this message translates to:
  /// **'Vorschau konnte nicht erzeugt werden – native Bildkonvertierung nicht verfügbar?'**
  String get entwVorschauFehlt;

  /// No description provided for @entwModellLaedt.
  ///
  /// In de, this message translates to:
  /// **'Modell für die KI-Auswahl wird geladen …'**
  String get entwModellLaedt;

  /// No description provided for @entwBildWirdVorbereitet.
  ///
  /// In de, this message translates to:
  /// **'Bild wird für die Maskierung vorbereitet …'**
  String get entwBildWirdVorbereitet;

  /// No description provided for @allgOder.
  ///
  /// In de, this message translates to:
  /// **'— oder —'**
  String get allgOder;

  /// No description provided for @albumBestehendes.
  ///
  /// In de, this message translates to:
  /// **'Bestehendes Album'**
  String get albumBestehendes;

  /// No description provided for @albumNeuAnlegen.
  ///
  /// In de, this message translates to:
  /// **'Neues Album anlegen'**
  String get albumNeuAnlegen;

  /// No description provided for @personZuordnenTitel.
  ///
  /// In de, this message translates to:
  /// **'Person zuordnen'**
  String get personZuordnenTitel;

  /// No description provided for @personAktuell.
  ///
  /// In de, this message translates to:
  /// **'Aktuell: {name}'**
  String personAktuell(String name);

  /// No description provided for @personBestehende.
  ///
  /// In de, this message translates to:
  /// **'Bestehende Person'**
  String get personBestehende;

  /// No description provided for @personNeuAnlegen.
  ///
  /// In de, this message translates to:
  /// **'Neue Person anlegen'**
  String get personNeuAnlegen;

  /// No description provided for @personZuordnenAktion.
  ///
  /// In de, this message translates to:
  /// **'Zuordnen'**
  String get personZuordnenAktion;

  /// No description provided for @bestaetigEndgueltigLoeschen.
  ///
  /// In de, this message translates to:
  /// **'Endgültig löschen'**
  String get bestaetigEndgueltigLoeschen;

  /// No description provided for @bestaetigTippeVor.
  ///
  /// In de, this message translates to:
  /// **'Tippe zur Bestätigung '**
  String get bestaetigTippeVor;

  /// No description provided for @bestaetigTippeNach.
  ///
  /// In de, this message translates to:
  /// **' ein:'**
  String get bestaetigTippeNach;

  /// No description provided for @fortschrittFehlgeschlagen.
  ///
  /// In de, this message translates to:
  /// **'Fehlgeschlagen: {fehler}'**
  String fortschrittFehlgeschlagen(String fehler);

  /// No description provided for @sterneStern.
  ///
  /// In de, this message translates to:
  /// **'Stern {nummer} von 5'**
  String sterneStern(int nummer);

  /// No description provided for @sterneSternVoll.
  ///
  /// In de, this message translates to:
  /// **'Stern {nummer} von 5, ausgefüllt'**
  String sterneSternVoll(int nummer);

  /// No description provided for @sterneSetzen.
  ///
  /// In de, this message translates to:
  /// **'Bewertung: {nummer} von 5 Sternen setzen'**
  String sterneSetzen(int nummer);

  /// No description provided for @sterneBewertungAnzeige.
  ///
  /// In de, this message translates to:
  /// **'Bewertung {nummer} von 5 Sternen'**
  String sterneBewertungAnzeige(int nummer);

  /// No description provided for @scrubberTooltip.
  ///
  /// In de, this message translates to:
  /// **'Schnellnavigation zum Datum'**
  String get scrubberTooltip;

  /// No description provided for @farbeViolett.
  ///
  /// In de, this message translates to:
  /// **'Violett'**
  String get farbeViolett;

  /// No description provided for @farbeAusgewaehlt.
  ///
  /// In de, this message translates to:
  /// **'{farbe}, ausgewählt'**
  String farbeAusgewaehlt(String farbe);

  /// No description provided for @farbeSetzen.
  ///
  /// In de, this message translates to:
  /// **'Farbmarkierung {farbe} setzen'**
  String farbeSetzen(String farbe);

  /// No description provided for @histogrammTitel.
  ///
  /// In de, this message translates to:
  /// **'Histogramm'**
  String get histogrammTitel;

  /// No description provided for @histogrammKeineVorschau.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Vorschau'**
  String get histogrammKeineVorschau;

  /// No description provided for @histogrammHelligkeit.
  ///
  /// In de, this message translates to:
  /// **'Helligkeit'**
  String get histogrammHelligkeit;

  /// No description provided for @livePhotoHalten.
  ///
  /// In de, this message translates to:
  /// **'Gedrückt halten zum Abspielen'**
  String get livePhotoHalten;

  /// No description provided for @metaBelichtungBeispiel.
  ///
  /// In de, this message translates to:
  /// **'z.B. 1/125 oder 0.5'**
  String get metaBelichtungBeispiel;

  /// No description provided for @karteTippenFuerOrt.
  ///
  /// In de, this message translates to:
  /// **'Tippen, um einen Ort festzulegen'**
  String get karteTippenFuerOrt;

  /// No description provided for @rasterFotoNichtGefunden.
  ///
  /// In de, this message translates to:
  /// **'Foto nicht in der Timeline gefunden.'**
  String get rasterFotoNichtGefunden;

  /// No description provided for @kameraImportTitel.
  ///
  /// In de, this message translates to:
  /// **'Von Kamera/SD-Karte importieren'**
  String get kameraImportTitel;

  /// No description provided for @kameraKeinDatentraeger.
  ///
  /// In de, this message translates to:
  /// **'Kein Datenträger mit Fotos/Videos gefunden. Kamera oder SD-Karte per USB einstecken – die Liste aktualisiert sich automatisch, sobald sie erkannt wird.'**
  String get kameraKeinDatentraeger;

  /// No description provided for @mischerTitel.
  ///
  /// In de, this message translates to:
  /// **'Farbmischer'**
  String get mischerTitel;

  /// No description provided for @mischerFarbton.
  ///
  /// In de, this message translates to:
  /// **'Farbton'**
  String get mischerFarbton;

  /// No description provided for @mischerSaettigung.
  ///
  /// In de, this message translates to:
  /// **'Sättigung'**
  String get mischerSaettigung;

  /// No description provided for @mischerHelligkeit.
  ///
  /// In de, this message translates to:
  /// **'Helligkeit'**
  String get mischerHelligkeit;

  /// No description provided for @mischerHinweis.
  ///
  /// In de, this message translates to:
  /// **'Wirkt nur auf farbige Bildbereiche – Graustufen bleiben unberührt.'**
  String get mischerHinweis;

  /// No description provided for @bandRot.
  ///
  /// In de, this message translates to:
  /// **'Rot'**
  String get bandRot;

  /// No description provided for @bandOrange.
  ///
  /// In de, this message translates to:
  /// **'Orange'**
  String get bandOrange;

  /// No description provided for @bandGelb.
  ///
  /// In de, this message translates to:
  /// **'Gelb'**
  String get bandGelb;

  /// No description provided for @bandGruen.
  ///
  /// In de, this message translates to:
  /// **'Grün'**
  String get bandGruen;

  /// No description provided for @bandAqua.
  ///
  /// In de, this message translates to:
  /// **'Aqua'**
  String get bandAqua;

  /// No description provided for @bandBlau.
  ///
  /// In de, this message translates to:
  /// **'Blau'**
  String get bandBlau;

  /// No description provided for @bandViolett.
  ///
  /// In de, this message translates to:
  /// **'Violett'**
  String get bandViolett;

  /// No description provided for @bandMagenta.
  ///
  /// In de, this message translates to:
  /// **'Magenta'**
  String get bandMagenta;

  /// No description provided for @kurveTitel.
  ///
  /// In de, this message translates to:
  /// **'Tonwertkurve'**
  String get kurveTitel;

  /// No description provided for @kurveHinweis.
  ///
  /// In de, this message translates to:
  /// **'Ziehen setzt oder verschiebt einen Punkt, langes Drücken entfernt ihn.'**
  String get kurveHinweis;

  /// No description provided for @pinFeld.
  ///
  /// In de, this message translates to:
  /// **'PIN'**
  String get pinFeld;

  /// No description provided for @pinFestlegenTitel.
  ///
  /// In de, this message translates to:
  /// **'PIN festlegen'**
  String get pinFestlegenTitel;

  /// No description provided for @pinNeuFeld.
  ///
  /// In de, this message translates to:
  /// **'Neuer PIN (8-10 Ziffern)'**
  String get pinNeuFeld;

  /// No description provided for @pinWiederholen.
  ///
  /// In de, this message translates to:
  /// **'PIN wiederholen'**
  String get pinWiederholen;

  /// No description provided for @pinWarnung.
  ///
  /// In de, this message translates to:
  /// **'Wichtig: Fotos im gesperrten Ordner werden echt verschlüsselt (AES-256). Ohne diesen PIN gibt es KEINE Möglichkeit, sie wiederherzustellen – auch nicht durch Zurücksetzen der App.'**
  String get pinWarnung;

  /// No description provided for @pinZiffernFehler.
  ///
  /// In de, this message translates to:
  /// **'PIN muss aus 8-10 Ziffern bestehen.'**
  String get pinZiffernFehler;

  /// No description provided for @pinUngleich.
  ///
  /// In de, this message translates to:
  /// **'PINs stimmen nicht überein.'**
  String get pinUngleich;

  /// No description provided for @allgFestlegen.
  ///
  /// In de, this message translates to:
  /// **'Festlegen'**
  String get allgFestlegen;

  /// No description provided for @pinEingebenTitel.
  ///
  /// In de, this message translates to:
  /// **'PIN eingeben'**
  String get pinEingebenTitel;

  /// No description provided for @pinFalsch.
  ///
  /// In de, this message translates to:
  /// **'Falscher PIN.'**
  String get pinFalsch;

  /// No description provided for @passphraseFeld.
  ///
  /// In de, this message translates to:
  /// **'Passphrase'**
  String get passphraseFeld;

  /// No description provided for @passphraseFestlegenTitel.
  ///
  /// In de, this message translates to:
  /// **'Backup-Passphrase festlegen'**
  String get passphraseFestlegenTitel;

  /// No description provided for @passphraseNeuFeld.
  ///
  /// In de, this message translates to:
  /// **'Neue Passphrase (mind. 8 Zeichen)'**
  String get passphraseNeuFeld;

  /// No description provided for @passphraseWiederholen.
  ///
  /// In de, this message translates to:
  /// **'Passphrase wiederholen'**
  String get passphraseWiederholen;

  /// No description provided for @passphraseWarnung.
  ///
  /// In de, this message translates to:
  /// **'Wichtig: Backups werden echt verschlüsselt (AES-256). Ohne diese Passphrase gibt es KEINE Möglichkeit, sie wiederherzustellen – auch nicht auf einem anderen Rechner. Am besten zusätzlich an einem sicheren Ort notieren.'**
  String get passphraseWarnung;

  /// No description provided for @passphraseUngleich.
  ///
  /// In de, this message translates to:
  /// **'Passphrasen stimmen nicht überein.'**
  String get passphraseUngleich;

  /// No description provided for @passphraseFalsch.
  ///
  /// In de, this message translates to:
  /// **'Falsche Passphrase.'**
  String get passphraseFalsch;

  /// No description provided for @allgFoto.
  ///
  /// In de, this message translates to:
  /// **'Foto'**
  String get allgFoto;

  /// No description provided for @allgVideo.
  ///
  /// In de, this message translates to:
  /// **'Video'**
  String get allgVideo;

  /// No description provided for @kachelFavorisiert.
  ///
  /// In de, this message translates to:
  /// **'favorisiert'**
  String get kachelFavorisiert;

  /// No description provided for @kachelBeschreibung.
  ///
  /// In de, this message translates to:
  /// **'{typ} {name}, {datum}'**
  String kachelBeschreibung(String typ, String name, String datum);

  /// No description provided for @albumFotosLoeschenTitel.
  ///
  /// In de, this message translates to:
  /// **'{anzahl} Foto(s) löschen?'**
  String albumFotosLoeschenTitel(int anzahl);

  /// No description provided for @albumFotosLoeschenText.
  ///
  /// In de, this message translates to:
  /// **'Diese Fotos werden aus dem Album entfernt und in den Papierkorb verschoben.'**
  String get albumFotosLoeschenText;

  /// No description provided for @albumZielordner.
  ///
  /// In de, this message translates to:
  /// **'Zielordner für \"{album}\" wählen'**
  String albumZielordner(String album);

  /// No description provided for @albumExportieren.
  ///
  /// In de, this message translates to:
  /// **'Album exportieren'**
  String get albumExportieren;

  /// No description provided for @albumLeer.
  ///
  /// In de, this message translates to:
  /// **'Dieses Album enthält noch keine Fotos.'**
  String get albumLeer;

  /// No description provided for @regelLoeschenTitel.
  ///
  /// In de, this message translates to:
  /// **'Regel löschen?'**
  String get regelLoeschenTitel;

  /// No description provided for @regelLoeschenText.
  ///
  /// In de, this message translates to:
  /// **'Die Regel \"{name}\" wirklich löschen? Bereits angewendete Aktionen bleiben erhalten.'**
  String regelLoeschenText(String name);

  /// No description provided for @regelOrtUnvollstaendig.
  ///
  /// In de, this message translates to:
  /// **'Ort: unvollständig konfiguriert'**
  String get regelOrtUnvollstaendig;

  /// No description provided for @regelDatumUnvollstaendig.
  ///
  /// In de, this message translates to:
  /// **'Datumsbereich: unvollständig konfiguriert'**
  String get regelDatumUnvollstaendig;

  /// No description provided for @regelTitel.
  ///
  /// In de, this message translates to:
  /// **'Automatisierungsregeln'**
  String get regelTitel;

  /// No description provided for @regelNeu.
  ///
  /// In de, this message translates to:
  /// **'Neue Regel'**
  String get regelNeu;

  /// No description provided for @regelLeer.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Automatisierungsregeln.\n\nLege eine Regel an, um Fotos automatisch anhand von Ort, KI-Tag oder Aufnahmedatum einem Album/Tag zuzuordnen oder zu favorisieren – wie Kamera-Presets, nur für andere Bedingungen.'**
  String get regelLeer;

  /// No description provided for @allgBearbeiten.
  ///
  /// In de, this message translates to:
  /// **'Bearbeiten'**
  String get allgBearbeiten;

  /// No description provided for @regelNameNoetig.
  ///
  /// In de, this message translates to:
  /// **'Ein Name für die Regel ist erforderlich.'**
  String get regelNameNoetig;

  /// No description provided for @regelKoordinatenUngueltig.
  ///
  /// In de, this message translates to:
  /// **'Breiten- und Längengrad müssen gültige Zahlen sein.'**
  String get regelKoordinatenUngueltig;

  /// No description provided for @regelBreitengradBereich.
  ///
  /// In de, this message translates to:
  /// **'Der Breitengrad muss zwischen -90 und 90 liegen.'**
  String get regelBreitengradBereich;

  /// No description provided for @regelLaengengradBereich.
  ///
  /// In de, this message translates to:
  /// **'Der Längengrad muss zwischen -180 und 180 liegen.'**
  String get regelLaengengradBereich;

  /// No description provided for @regelTagWaehlen.
  ///
  /// In de, this message translates to:
  /// **'Bitte einen KI-Tag-Begriff wählen.'**
  String get regelTagWaehlen;

  /// No description provided for @regelDatumWaehlen.
  ///
  /// In de, this message translates to:
  /// **'Bitte Start- und Enddatum wählen.'**
  String get regelDatumWaehlen;

  /// No description provided for @regelDatumReihenfolge.
  ///
  /// In de, this message translates to:
  /// **'Das Startdatum muss vor dem Enddatum liegen.'**
  String get regelDatumReihenfolge;

  /// No description provided for @regelBreitengrad.
  ///
  /// In de, this message translates to:
  /// **'Breitengrad'**
  String get regelBreitengrad;

  /// No description provided for @regelLaengengrad.
  ///
  /// In de, this message translates to:
  /// **'Längengrad'**
  String get regelLaengengrad;

  /// No description provided for @regelKeinVokabular.
  ///
  /// In de, this message translates to:
  /// **'Kein KI-Tag-Vokabular vorhanden (Einstellungen → KI-Tagging-Vokabular).'**
  String get regelKeinVokabular;

  /// No description provided for @regelTagBegriff.
  ///
  /// In de, this message translates to:
  /// **'KI-Tag-Begriff'**
  String get regelTagBegriff;

  /// No description provided for @regelNameFeld.
  ///
  /// In de, this message translates to:
  /// **'Name (z.B. \"Urlaub Italien\")'**
  String get regelNameFeld;

  /// No description provided for @regelBedingung.
  ///
  /// In de, this message translates to:
  /// **'Bedingung'**
  String get regelBedingung;

  /// No description provided for @presetZielalbum.
  ///
  /// In de, this message translates to:
  /// **'Zielalbum (optional)'**
  String get presetZielalbum;

  /// No description provided for @presetKeinAlbum.
  ///
  /// In de, this message translates to:
  /// **'Kein Album'**
  String get presetKeinAlbum;

  /// No description provided for @presetNeuesAlbum.
  ///
  /// In de, this message translates to:
  /// **'oder: neues Album anlegen'**
  String get presetNeuesAlbum;

  /// No description provided for @presetFavorisieren.
  ///
  /// In de, this message translates to:
  /// **'Automatisch favorisieren'**
  String get presetFavorisieren;

  /// No description provided for @presetTagsWaehlenPlatzhalter.
  ///
  /// In de, this message translates to:
  /// **'Tags auswählen …'**
  String get presetTagsWaehlenPlatzhalter;

  /// No description provided for @presetKeineTags.
  ///
  /// In de, this message translates to:
  /// **'Keine Tags vorhanden.'**
  String get presetKeineTags;

  /// No description provided for @presetLoeschenTitel.
  ///
  /// In de, this message translates to:
  /// **'Preset löschen?'**
  String get presetLoeschenTitel;

  /// No description provided for @presetLoeschenText.
  ///
  /// In de, this message translates to:
  /// **'Das Kamera-Preset für \"{kamera}\" wirklich löschen? Bereits importierte Fotos bleiben unverändert.'**
  String presetLoeschenText(String kamera);

  /// No description provided for @presetTitel.
  ///
  /// In de, this message translates to:
  /// **'Kamera-Presets'**
  String get presetTitel;

  /// No description provided for @presetNeu.
  ///
  /// In de, this message translates to:
  /// **'Neues Preset'**
  String get presetNeu;

  /// No description provided for @presetLeer.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Kamera-Presets.\n\nLege ein Preset für eine bestimmte Kamera an, um künftig importierte Fotos dieser Kamera automatisch einem Album/Tag zuzuordnen – auch schon bevor das erste Foto dieser Kamera importiert wurde.'**
  String get presetLeer;

  /// No description provided for @presetHerstellerModellNoetig.
  ///
  /// In de, this message translates to:
  /// **'Hersteller und Modell sind beide erforderlich.'**
  String get presetHerstellerModellNoetig;

  /// No description provided for @presetBekannteKamera.
  ///
  /// In de, this message translates to:
  /// **'Bekannte Kamera übernehmen (optional)'**
  String get presetBekannteKamera;

  /// No description provided for @presetHersteller.
  ///
  /// In de, this message translates to:
  /// **'Hersteller (z.B. Canon, Apple)'**
  String get presetHersteller;

  /// No description provided for @presetModell.
  ///
  /// In de, this message translates to:
  /// **'Modell (z.B. EOS R5, iPhone 15 Pro)'**
  String get presetModell;

  /// No description provided for @allgClipNoetigKurz.
  ///
  /// In de, this message translates to:
  /// **'Benötigt das CLIP-Modell (Einstellungen → KI-Modelle).'**
  String get allgClipNoetigKurz;

  /// No description provided for @duplNichtsLoeschbar.
  ///
  /// In de, this message translates to:
  /// **'Nichts automatisch löschbar: In allen Gruppen sind mehrere Fotos favorisiert oder bewertet – die bitte von Hand durchsehen.'**
  String get duplNichtsLoeschbar;

  /// No description provided for @duplNichtsZuLoeschen.
  ///
  /// In de, this message translates to:
  /// **'Nichts zu löschen.'**
  String get duplNichtsZuLoeschen;

  /// No description provided for @duplPapierkorbTitel.
  ///
  /// In de, this message translates to:
  /// **'Kopien in den Papierkorb?'**
  String get duplPapierkorbTitel;

  /// No description provided for @duplPapierkorbAnzahl.
  ///
  /// In de, this message translates to:
  /// **'{fotos} Foto(s) aus {gruppen} Gruppe(n) werden in den Papierkorb verschoben.'**
  String duplPapierkorbAnzahl(int fotos, int gruppen);

  /// No description provided for @duplBehaltenRegel.
  ///
  /// In de, this message translates to:
  /// **'Behalten wird je Gruppe: Favorit, sonst höchste Bewertung, sonst das schärfste, sonst das mit der höchsten Auflösung.'**
  String get duplBehaltenRegel;

  /// No description provided for @duplUebersprungen.
  ///
  /// In de, this message translates to:
  /// **'{anzahl} Gruppe(n) bleiben unangetastet, weil dort mehrere Fotos favorisiert oder bewertet sind.'**
  String duplUebersprungen(int anzahl);

  /// No description provided for @duplRueckgaengig.
  ///
  /// In de, this message translates to:
  /// **'Rückgängig: über den Papierkorb wiederherstellbar.'**
  String get duplRueckgaengig;

  /// No description provided for @duplInPapierkorb.
  ///
  /// In de, this message translates to:
  /// **'In den Papierkorb'**
  String get duplInPapierkorb;

  /// No description provided for @duplVerschoben.
  ///
  /// In de, this message translates to:
  /// **'{anzahl} Foto(s) in den Papierkorb verschoben.'**
  String duplVerschoben(int anzahl);

  /// No description provided for @duplTitel.
  ///
  /// In de, this message translates to:
  /// **'Duplikate & ähnliche Fotos'**
  String get duplTitel;

  /// No description provided for @duplZweiteBibliothek.
  ///
  /// In de, this message translates to:
  /// **'Zweite Bibliothek'**
  String get duplZweiteBibliothek;

  /// No description provided for @duplAlleKopienLoeschen.
  ///
  /// In de, this message translates to:
  /// **'Alle Kopien löschen'**
  String get duplAlleKopienLoeschen;

  /// No description provided for @duplAehnlichkeit.
  ///
  /// In de, this message translates to:
  /// **'Ähnlichkeit:'**
  String get duplAehnlichkeit;

  /// No description provided for @duplSchwelleHinweis.
  ///
  /// In de, this message translates to:
  /// **'Höhere Werte = nur sehr ähnliche Fotos werden als Gruppe erkannt. Niedrigere Werte finden mehr, aber auch weniger sichere Treffer.'**
  String get duplSchwelleHinweis;

  /// No description provided for @duplKeineGruppen.
  ///
  /// In de, this message translates to:
  /// **'Keine ähnlichen Fotogruppen gefunden.'**
  String get duplKeineGruppen;

  /// No description provided for @duplVerschiebenTooltip.
  ///
  /// In de, this message translates to:
  /// **'In den Papierkorb verschieben'**
  String get duplVerschiebenTooltip;

  /// No description provided for @clusterTitel.
  ///
  /// In de, this message translates to:
  /// **'Vorschläge prüfen'**
  String get clusterTitel;

  /// No description provided for @clusterFertig.
  ///
  /// In de, this message translates to:
  /// **'Alle Vorschläge durchgesehen.'**
  String get clusterFertig;

  /// No description provided for @clusterAehnlichZu.
  ///
  /// In de, this message translates to:
  /// **'Ähnlich zu: {name}'**
  String clusterAehnlichZu(String name);

  /// No description provided for @clusterUeberspringen.
  ///
  /// In de, this message translates to:
  /// **'Überspringen'**
  String get clusterUeberspringen;

  /// No description provided for @gesichtUmbenennen.
  ///
  /// In de, this message translates to:
  /// **'Person umbenennen/ändern'**
  String get gesichtUmbenennen;

  /// No description provided for @gesichtNeuBenennen.
  ///
  /// In de, this message translates to:
  /// **'Neues Gesicht benennen'**
  String get gesichtNeuBenennen;

  /// No description provided for @gesichtGesperrt.
  ///
  /// In de, this message translates to:
  /// **'Gesichts-Bearbeitung ist für Fotos im gesperrten Ordner nicht verfügbar.'**
  String get gesichtGesperrt;

  /// No description provided for @gesichtManuellHinzufuegen.
  ///
  /// In de, this message translates to:
  /// **'Gesicht manuell hinzufügen'**
  String get gesichtManuellHinzufuegen;

  /// No description provided for @gesichtHinzufuegenBeenden.
  ///
  /// In de, this message translates to:
  /// **'Hinzufügen beenden'**
  String get gesichtHinzufuegenBeenden;

  /// No description provided for @gesichtRechteckHinweis.
  ///
  /// In de, this message translates to:
  /// **'Ziehe ein Rechteck über ein Gesicht, um es manuell zu markieren.'**
  String get gesichtRechteckHinweis;

  /// No description provided for @bearbBildNichtLesbar.
  ///
  /// In de, this message translates to:
  /// **'Bild konnte nicht gelesen werden.'**
  String get bearbBildNichtLesbar;

  /// No description provided for @bearbBildNichtLesbarFehler.
  ///
  /// In de, this message translates to:
  /// **'Bild konnte nicht gelesen werden: {fehler}'**
  String bearbBildNichtLesbarFehler(String fehler);

  /// No description provided for @bearbSpeichernTitel.
  ///
  /// In de, this message translates to:
  /// **'Änderungen speichern?'**
  String get bearbSpeichernTitel;

  /// No description provided for @bearbSpeichernText.
  ///
  /// In de, this message translates to:
  /// **'Die Originaldatei wird durch die bearbeitete Version ersetzt. Das lässt sich nicht rückgängig machen.'**
  String get bearbSpeichernText;

  /// No description provided for @bearbNichtFinalisiert.
  ///
  /// In de, this message translates to:
  /// **'Bild konnte nicht finalisiert werden.'**
  String get bearbNichtFinalisiert;

  /// No description provided for @bearbZuschneidenAnwenden.
  ///
  /// In de, this message translates to:
  /// **'Zuschneiden anwenden'**
  String get bearbZuschneidenAnwenden;

  /// No description provided for @bearbTitel.
  ///
  /// In de, this message translates to:
  /// **'Bearbeiten'**
  String get bearbTitel;

  /// No description provided for @importWasTitel.
  ///
  /// In de, this message translates to:
  /// **'Was möchtest du importieren?'**
  String get importWasTitel;

  /// No description provided for @importWasText.
  ///
  /// In de, this message translates to:
  /// **'Wähle einzelne Fotos/Videos aus, importiere einen kompletten Ordner (inkl. aller Unterordner), oder importiere direkt von einer angeschlossenen Kamera/SD-Karte.'**
  String get importWasText;

  /// No description provided for @importEinzelneDateien.
  ///
  /// In de, this message translates to:
  /// **'Einzelne Dateien wählen'**
  String get importEinzelneDateien;

  /// No description provided for @importGanzerOrdner.
  ///
  /// In de, this message translates to:
  /// **'Ganzen Ordner wählen'**
  String get importGanzerOrdner;

  /// No description provided for @importVonKamera.
  ///
  /// In de, this message translates to:
  /// **'Von Kamera/SD-Karte'**
  String get importVonKamera;

  /// No description provided for @importOrdnerWaehlen.
  ///
  /// In de, this message translates to:
  /// **'Ordner zum Importieren wählen'**
  String get importOrdnerWaehlen;

  /// No description provided for @importNichtsImOrdner.
  ///
  /// In de, this message translates to:
  /// **'Keine unterstützten Fotos/Videos in diesem Ordner gefunden.'**
  String get importNichtsImOrdner;

  /// No description provided for @importNichtsAufDatentraeger.
  ///
  /// In de, this message translates to:
  /// **'Keine unterstützten Fotos/Videos auf diesem Datenträger gefunden.'**
  String get importNichtsAufDatentraeger;

  /// No description provided for @importAbgeschlossen.
  ///
  /// In de, this message translates to:
  /// **'Import abgeschlossen'**
  String get importAbgeschlossen;

  /// No description provided for @importLaeuft.
  ///
  /// In de, this message translates to:
  /// **'Importiere Fotos & Videos …'**
  String get importLaeuft;

  /// No description provided for @importJetztSichten.
  ///
  /// In de, this message translates to:
  /// **'Jetzt sichten'**
  String get importJetztSichten;

  /// No description provided for @integPruefungFehlgeschlagen.
  ///
  /// In de, this message translates to:
  /// **'Prüfung fehlgeschlagen: {fehler}'**
  String integPruefungFehlgeschlagen(String fehler);

  /// No description provided for @integOriginalFehlt.
  ///
  /// In de, this message translates to:
  /// **'Das Original fehlt auf der Platte – das gesamte Foto/Video wird aus der Bibliothek entfernt.'**
  String get integOriginalFehlt;

  /// No description provided for @integMaskeFehlt.
  ///
  /// In de, this message translates to:
  /// **'Die Maskendatei fehlt – der Maskeneintrag wird entfernt.'**
  String get integMaskeFehlt;

  /// No description provided for @integCropFehlt.
  ///
  /// In de, this message translates to:
  /// **'Der Gesichts-Crop fehlt – nur die Vorschau wird entfernt, die Zuordnung zur Person bleibt erhalten.'**
  String get integCropFehlt;

  /// No description provided for @integPfadEntfernt.
  ///
  /// In de, this message translates to:
  /// **'Der Datei-Pfad wird aus der Datenbank entfernt – die Datei lässt sich über \"Werkzeuge → Vorschaubilder neu erstellen\" wieder herstellen.'**
  String get integPfadEntfernt;

  /// No description provided for @integDateiLoeschenTitel.
  ///
  /// In de, this message translates to:
  /// **'Datei löschen?'**
  String get integDateiLoeschenTitel;

  /// No description provided for @integDateiLoeschenText.
  ///
  /// In de, this message translates to:
  /// **'{pfad} wird unwiderruflich von der Platte gelöscht.'**
  String integDateiLoeschenText(String pfad);

  /// No description provided for @integErneutPruefen.
  ///
  /// In de, this message translates to:
  /// **'Erneut prüfen'**
  String get integErneutPruefen;

  /// No description provided for @integPruefsummen.
  ///
  /// In de, this message translates to:
  /// **'Prüfsummen prüfen'**
  String get integPruefsummen;

  /// No description provided for @integPruefsummenHinweis.
  ///
  /// In de, this message translates to:
  /// **'Liest jede Originaldatei komplett ein und vergleicht sie mit der beim Import gespeicherten Prüfsumme – bei großen Bibliotheken deutlich langsamer als die reine Existenz-/Verwaisten-Prüfung.'**
  String get integPruefsummenHinweis;

  /// No description provided for @integKeineProbleme.
  ///
  /// In de, this message translates to:
  /// **'Keine Probleme gefunden ({anzahl} Dateien geprüft).'**
  String integKeineProbleme(int anzahl);

  /// No description provided for @integAusDbEntfernen.
  ///
  /// In de, this message translates to:
  /// **'Aus DB entfernen'**
  String get integAusDbEntfernen;

  /// No description provided for @integDateiLoeschen.
  ///
  /// In de, this message translates to:
  /// **'Datei löschen'**
  String get integDateiLoeschen;

  /// No description provided for @integAbweichungen.
  ///
  /// In de, this message translates to:
  /// **'Prüfsummen-Abweichungen ({anzahl})'**
  String integAbweichungen(int anzahl);

  /// No description provided for @integInhaltGeaendert.
  ///
  /// In de, this message translates to:
  /// **'Inhalt hat sich seit dem Import geändert'**
  String get integInhaltGeaendert;

  /// No description provided for @integFotoOeffnen.
  ///
  /// In de, this message translates to:
  /// **'Foto öffnen'**
  String get integFotoOeffnen;

  /// No description provided for @integHeaderProbleme.
  ///
  /// In de, this message translates to:
  /// **'Verschlüsselte Dateien mit ungültigem Header ({anzahl})'**
  String integHeaderProbleme(int anzahl);

  /// No description provided for @integBeschaedigt.
  ///
  /// In de, this message translates to:
  /// **'Datei ist evtl. beschädigt – keine gültige verschlüsselte Datei'**
  String get integBeschaedigt;

  /// No description provided for @gesperrtLeer.
  ///
  /// In de, this message translates to:
  /// **'Keine gesperrten Fotos. In der Vollbildansicht eines Fotos lässt es sich über das Schloss-Symbol oben rechts hierher verschieben (dabei verschlüsselt).'**
  String get gesperrtLeer;

  /// No description provided for @gesperrtEntfernen.
  ///
  /// In de, this message translates to:
  /// **'Aus dem gesperrten Ordner entfernen (entschlüsseln)'**
  String get gesperrtEntfernen;

  /// No description provided for @gesperrtEndgueltigTitel.
  ///
  /// In de, this message translates to:
  /// **'Endgültig löschen?'**
  String get gesperrtEndgueltigTitel;

  /// No description provided for @gesperrtEndgueltigText.
  ///
  /// In de, this message translates to:
  /// **'Die Datei wird unwiderruflich gelöscht – auch mit dem richtigen PIN gibt es danach keine Wiederherstellung mehr.'**
  String get gesperrtEndgueltigText;

  /// No description provided for @gesperrtPapierkorbLeer.
  ///
  /// In de, this message translates to:
  /// **'Der gesperrte Papierkorb ist leer.\n\nAus dem gesperrten Ordner gelöschte Fotos landen hier statt im normalen (ungeschützten) Papierkorb.'**
  String get gesperrtPapierkorbLeer;

  /// No description provided for @gesperrtWiederherstellen.
  ///
  /// In de, this message translates to:
  /// **'Wiederherstellen (bleibt gesperrt)'**
  String get gesperrtWiederherstellen;

  /// No description provided for @personKeineGesichter.
  ///
  /// In de, this message translates to:
  /// **'Keine Gesichter dieser Person vorhanden.'**
  String get personKeineGesichter;

  /// No description provided for @personProfilbildWaehlen.
  ///
  /// In de, this message translates to:
  /// **'Profilbild auswählen'**
  String get personProfilbildWaehlen;

  /// No description provided for @personProfilbildAendern.
  ///
  /// In de, this message translates to:
  /// **'Profilbild ändern'**
  String get personProfilbildAendern;

  /// No description provided for @personKeineFotos.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Fotos für diese Person.'**
  String get personKeineFotos;

  /// No description provided for @personDoppelklickHinweis.
  ///
  /// In de, this message translates to:
  /// **'Doppelklick auf ein Foto öffnet es zur Kontrolle mit allen erkannten Gesichtern.'**
  String get personDoppelklickHinweis;

  /// No description provided for @personGelerntesVerworfen.
  ///
  /// In de, this message translates to:
  /// **'Gelerntes verworfen – es gilt wieder die allgemeine Schwelle.'**
  String get personGelerntesVerworfen;

  /// No description provided for @personSchwelleAngepasst.
  ///
  /// In de, this message translates to:
  /// **'angepasst auf {schwelle} statt {allgemein}'**
  String personSchwelleAngepasst(String schwelle, String allgemein);

  /// No description provided for @personSchwelleWiderspruch.
  ///
  /// In de, this message translates to:
  /// **'weiterhin {allgemein} – die Entscheidungen widersprechen sich, ein abgelehntes Gesicht war ähnlicher als ein bestätigtes'**
  String personSchwelleWiderspruch(String allgemein);

  /// No description provided for @personSchwelleWirdAngepasst.
  ///
  /// In de, this message translates to:
  /// **'ab {anzahl} Entscheidungen wird angepasst'**
  String personSchwelleWirdAngepasst(int anzahl);

  /// No description provided for @personVerwerfen.
  ///
  /// In de, this message translates to:
  /// **'Verwerfen'**
  String get personVerwerfen;

  /// No description provided for @restaurWartet.
  ///
  /// In de, this message translates to:
  /// **'Wartet in der Warteschlange'**
  String get restaurWartet;

  /// No description provided for @restaurLaeuft.
  ///
  /// In de, this message translates to:
  /// **'Läuft – Kachel {erledigt} von {gesamt}'**
  String restaurLaeuft(int erledigt, int gesamt);

  /// No description provided for @restaurTitel.
  ///
  /// In de, this message translates to:
  /// **'KI-Restaurierung – Warteschlange'**
  String get restaurTitel;

  /// No description provided for @restaurLeer.
  ///
  /// In de, this message translates to:
  /// **'Keine Restaurierungs-Aufträge vorhanden.\nIm Entwickeln-Screen eines Fotos lässt sich eine KI-Restaurierung anstoßen.'**
  String get restaurLeer;

  /// No description provided for @restaurAusListe.
  ///
  /// In de, this message translates to:
  /// **'Aus der Liste entfernen'**
  String get restaurAusListe;

  /// No description provided for @restaurFehlgeschlagen.
  ///
  /// In de, this message translates to:
  /// **'Fehlgeschlagen: {grund}'**
  String restaurFehlgeschlagen(String grund);

  /// No description provided for @restaurFehlgeschlagenKurz.
  ///
  /// In de, this message translates to:
  /// **'Fehlgeschlagen'**
  String get restaurFehlgeschlagenKurz;

  /// No description provided for @zweitOrdnerWaehlen.
  ///
  /// In de, this message translates to:
  /// **'Ordner der zweiten PhotoVault-Bibliothek wählen'**
  String get zweitOrdnerWaehlen;

  /// No description provided for @zweitTitel.
  ///
  /// In de, this message translates to:
  /// **'Zweite Bibliothek vergleichen'**
  String get zweitTitel;

  /// No description provided for @allgErneutVersuchen.
  ///
  /// In de, this message translates to:
  /// **'Erneut versuchen'**
  String get allgErneutVersuchen;

  /// No description provided for @zweitErklaerung.
  ///
  /// In de, this message translates to:
  /// **'Vergleicht die eigene Bibliothek gegen eine zweite, unabhängige PhotoVault-Bibliothek (z.B. auf einer externen Platte oder einem alten Rechner) per KI-Bildähnlichkeit – findet Fotos, die dort schon liegen, bevor du sie erneut importierst.\n\nGesperrte Fotos der zweiten Bibliothek werden dabei nie einbezogen, ohne dass deren PIN gebraucht wird.'**
  String get zweitErklaerung;

  /// No description provided for @zweitOrdnerKnopf.
  ///
  /// In de, this message translates to:
  /// **'Ordner der zweiten Bibliothek wählen'**
  String get zweitOrdnerKnopf;

  /// No description provided for @zweitSchwelleHinweis.
  ///
  /// In de, this message translates to:
  /// **'Höhere Werte = nur sehr ähnliche Fotos gelten als Übereinstimmung.'**
  String get zweitSchwelleHinweis;

  /// No description provided for @zweitKeineTreffer.
  ///
  /// In de, this message translates to:
  /// **'Keine ähnlichen Fotos in der zweiten Bibliothek gefunden.'**
  String get zweitKeineTreffer;

  /// No description provided for @zweitTreffer.
  ///
  /// In de, this message translates to:
  /// **'{anzahl} mögliche Übereinstimmung(en)'**
  String zweitTreffer(int anzahl);

  /// No description provided for @zweitAndererOrdner.
  ///
  /// In de, this message translates to:
  /// **'Anderer Ordner'**
  String get zweitAndererOrdner;

  /// No description provided for @zweitAehnlichProzent.
  ///
  /// In de, this message translates to:
  /// **'{prozent} % ähnlich'**
  String zweitAehnlichProzent(String prozent);

  /// No description provided for @zweitBibliothek.
  ///
  /// In de, this message translates to:
  /// **'zweite Bibliothek'**
  String get zweitBibliothek;

  /// No description provided for @aehnlTitel.
  ///
  /// In de, this message translates to:
  /// **'Ähnliche Fotos'**
  String get aehnlTitel;

  /// No description provided for @aehnlClipFehlt.
  ///
  /// In de, this message translates to:
  /// **'KI-Bildsuche nicht verfügbar – CLIP-Modell fehlt (siehe Einstellungen → KI-Modelle).'**
  String get aehnlClipFehlt;

  /// No description provided for @aehnlKeineTreffer.
  ///
  /// In de, this message translates to:
  /// **'Für dieses Foto liegt noch kein KI-Embedding vor (siehe Werkzeuge → KI-Bildsuche → CLIP-Embeddings berechnen) oder es gibt keine ähnlichen Fotos in der Bibliothek.'**
  String get aehnlKeineTreffer;

  /// No description provided for @stapelErklaerung.
  ///
  /// In de, this message translates to:
  /// **'Fotos, die sich ähneln UND innerhalb weniger Sekunden aufgenommen wurden, werden hier als Serie vorgeschlagen. \"Übernehmen\" fasst eine Gruppe zu einem Stapel zusammen – nur das Titelbild bleibt danach in der Übersicht sichtbar, nichts wird gelöscht.'**
  String get stapelErklaerung;

  /// No description provided for @stapelKeine.
  ///
  /// In de, this message translates to:
  /// **'Keine Serienbilder gefunden.'**
  String get stapelKeine;

  /// No description provided for @allgVerwerfen.
  ///
  /// In de, this message translates to:
  /// **'Verwerfen'**
  String get allgVerwerfen;

  /// No description provided for @statTitel.
  ///
  /// In de, this message translates to:
  /// **'Statistik'**
  String get statTitel;

  /// No description provided for @allgAktualisieren.
  ///
  /// In de, this message translates to:
  /// **'Aktualisieren'**
  String get allgAktualisieren;

  /// No description provided for @statLeer.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Fotos oder Videos in der Bibliothek.'**
  String get statLeer;

  /// No description provided for @statProJahr.
  ///
  /// In de, this message translates to:
  /// **'Fotos & Videos pro Jahr'**
  String get statProJahr;

  /// No description provided for @statSaisonalitaet.
  ///
  /// In de, this message translates to:
  /// **'Saisonalität – Aufnahmen pro Monat'**
  String get statSaisonalitaet;

  /// No description provided for @statKameras.
  ///
  /// In de, this message translates to:
  /// **'Häufigste Kameras'**
  String get statKameras;

  /// No description provided for @statInsgesamt.
  ///
  /// In de, this message translates to:
  /// **'Medien insgesamt'**
  String get statInsgesamt;

  /// No description provided for @statFotos.
  ///
  /// In de, this message translates to:
  /// **'Fotos'**
  String get statFotos;

  /// No description provided for @statVideos.
  ///
  /// In de, this message translates to:
  /// **'Videos'**
  String get statVideos;

  /// No description provided for @statSpeicherplatz.
  ///
  /// In de, this message translates to:
  /// **'Speicherplatz'**
  String get statSpeicherplatz;

  /// No description provided for @statImPapierkorb.
  ///
  /// In de, this message translates to:
  /// **'Im Papierkorb'**
  String get statImPapierkorb;

  /// No description provided for @statDiagrammJahr.
  ///
  /// In de, this message translates to:
  /// **'Balkendiagramm, Fotos und Videos pro Jahr: {werte}'**
  String statDiagrammJahr(String werte);

  /// No description provided for @statDiagrammMonat.
  ///
  /// In de, this message translates to:
  /// **'Balkendiagramm, Saisonalität pro Monat: {werte}'**
  String statDiagrammMonat(String werte);

  /// No description provided for @papierkorbTitel.
  ///
  /// In de, this message translates to:
  /// **'Papierkorb'**
  String get papierkorbTitel;

  /// No description provided for @papierkorbEndgueltigTitel.
  ///
  /// In de, this message translates to:
  /// **'Endgültig löschen?'**
  String get papierkorbEndgueltigTitel;

  /// No description provided for @papierkorbEndgueltigText.
  ///
  /// In de, this message translates to:
  /// **'{anzahl} Datei(en) unwiderruflich löschen.'**
  String papierkorbEndgueltigText(int anzahl);

  /// No description provided for @papierkorbLeer.
  ///
  /// In de, this message translates to:
  /// **'Der Papierkorb ist leer.'**
  String get papierkorbLeer;

  /// No description provided for @videoNichtGeoeffnet.
  ///
  /// In de, this message translates to:
  /// **'Video konnte nicht geöffnet werden.'**
  String get videoNichtGeoeffnet;

  /// No description provided for @videoZuschneidenFehler.
  ///
  /// In de, this message translates to:
  /// **'Zuschneiden fehlgeschlagen.'**
  String get videoZuschneidenFehler;

  /// No description provided for @videoZuschneiden.
  ///
  /// In de, this message translates to:
  /// **'Zuschneiden'**
  String get videoZuschneiden;

  /// No description provided for @xmpAlleUebernehmen.
  ///
  /// In de, this message translates to:
  /// **'Alle übernehmen'**
  String get xmpAlleUebernehmen;

  /// No description provided for @xmpErneutEinlesen.
  ///
  /// In de, this message translates to:
  /// **'Erneut einlesen'**
  String get xmpErneutEinlesen;

  /// No description provided for @xmpKeineAbweichungen.
  ///
  /// In de, this message translates to:
  /// **'{anzahl} Sidecar(s) geprüft – keine Abweichungen zur Datenbank gefunden.'**
  String xmpKeineAbweichungen(int anzahl);

  /// No description provided for @restaurWirdGestartet.
  ///
  /// In de, this message translates to:
  /// **'Wird gestartet …'**
  String get restaurWirdGestartet;

  /// No description provided for @restaurAbgebrochen.
  ///
  /// In de, this message translates to:
  /// **'Abgebrochen'**
  String get restaurAbgebrochen;

  /// No description provided for @restaurGrundModellLaedtNicht.
  ///
  /// In de, this message translates to:
  /// **'Das Restaurierungs-Modell liess sich nicht laden.'**
  String get restaurGrundModellLaedtNicht;

  /// No description provided for @restaurGrundModellWeg.
  ///
  /// In de, this message translates to:
  /// **'Modell nicht mehr verfügbar.'**
  String get restaurGrundModellWeg;

  /// No description provided for @restaurGrundFotoWeg.
  ///
  /// In de, this message translates to:
  /// **'Foto wurde inzwischen gelöscht.'**
  String get restaurGrundFotoWeg;

  /// No description provided for @restaurGrundGesperrt.
  ///
  /// In de, this message translates to:
  /// **'KI-Restaurierung ist für gesperrte Fotos nicht verfügbar.'**
  String get restaurGrundGesperrt;

  /// No description provided for @restaurGrundAufloesung.
  ///
  /// In de, this message translates to:
  /// **'Bildauflösung unbekannt.'**
  String get restaurGrundAufloesung;

  /// No description provided for @restaurGrundNichtGerendert.
  ///
  /// In de, this message translates to:
  /// **'Bild konnte nicht gerendert werden.'**
  String get restaurGrundNichtGerendert;

  /// No description provided for @restaurGrundNichtDekodiert.
  ///
  /// In de, this message translates to:
  /// **'Gerendertes Bild konnte nicht dekodiert werden.'**
  String get restaurGrundNichtDekodiert;

  /// No description provided for @restaurNichtVerfuegbar.
  ///
  /// In de, this message translates to:
  /// **'KI-Restaurierung ist nicht verfügbar – Modell nicht installiert.'**
  String get restaurNichtVerfuegbar;

  /// No description provided for @personSchwelleWieAllgemein.
  ///
  /// In de, this message translates to:
  /// **'weiterhin {allgemein}'**
  String personSchwelleWieAllgemein(String allgemein);

  /// No description provided for @personWiedererkennung.
  ///
  /// In de, this message translates to:
  /// **'Wiedererkennung: {erklaerung}. Aus {bestaetigt, plural, =1{einer Bestätigung} other{{bestaetigt} Bestätigungen}} und {abgelehnt, plural, =1{einer Korrektur} other{{abgelehnt} Korrekturen}}.'**
  String personWiedererkennung(
      String erklaerung, int bestaetigt, int abgelehnt);

  /// No description provided for @infoKeineUnbenannten.
  ///
  /// In de, this message translates to:
  /// **'Keine unbenannten Gesichter auf diesem Foto gefunden – falls noch keine Gesichtserkennung gelaufen ist, siehe Werkzeuge → Gesichter scannen.'**
  String get infoKeineUnbenannten;

  /// No description provided for @infoTitel.
  ///
  /// In de, this message translates to:
  /// **'Info'**
  String get infoTitel;

  /// No description provided for @infoBeschreibungHinzufuegen.
  ///
  /// In de, this message translates to:
  /// **'Beschreibung hinzufügen'**
  String get infoBeschreibungHinzufuegen;

  /// No description provided for @infoKiBeschreibung.
  ///
  /// In de, this message translates to:
  /// **'KI-Beschreibung · Englisch'**
  String get infoKiBeschreibung;

  /// No description provided for @infoBewertung.
  ///
  /// In de, this message translates to:
  /// **'Bewertung'**
  String get infoBewertung;

  /// No description provided for @infoNiemandZugeordnet.
  ///
  /// In de, this message translates to:
  /// **'Noch niemand zugeordnet.'**
  String get infoNiemandZugeordnet;

  /// No description provided for @infoDetails.
  ///
  /// In de, this message translates to:
  /// **'Details'**
  String get infoDetails;

  /// No description provided for @infoStandortBekannt.
  ///
  /// In de, this message translates to:
  /// **'Standort bekannt'**
  String get infoStandortBekannt;

  /// No description provided for @infoOrtNichtAufgeloest.
  ///
  /// In de, this message translates to:
  /// **'Ort noch nicht aufgelöst (Werkzeuge → Orte)'**
  String get infoOrtNichtAufgeloest;

  /// No description provided for @infoOrtEntfernen.
  ///
  /// In de, this message translates to:
  /// **'Ort entfernen'**
  String get infoOrtEntfernen;

  /// No description provided for @infoSerie.
  ///
  /// In de, this message translates to:
  /// **'Serie: {anzahl} Fotos'**
  String infoSerie(int anzahl);

  /// No description provided for @infoNurTitelbild.
  ///
  /// In de, this message translates to:
  /// **'Nur das Titelbild ist in der Übersicht sichtbar'**
  String get infoNurTitelbild;

  /// No description provided for @infoSerieAufloesen.
  ///
  /// In de, this message translates to:
  /// **'Serie auflösen'**
  String get infoSerieAufloesen;

  /// No description provided for @infoTagHinzufuegenPlatzhalter.
  ///
  /// In de, this message translates to:
  /// **'Tag hinzufügen …'**
  String get infoTagHinzufuegenPlatzhalter;

  /// No description provided for @stufeBildanalyse.
  ///
  /// In de, this message translates to:
  /// **'Bildanalyse'**
  String get stufeBildanalyse;

  /// No description provided for @stufeTexterkennung.
  ///
  /// In de, this message translates to:
  /// **'Texterkennung'**
  String get stufeTexterkennung;

  /// No description provided for @stufeSchlagwoerter.
  ///
  /// In de, this message translates to:
  /// **'Schlagwörter'**
  String get stufeSchlagwoerter;

  /// No description provided for @stufeBildbeschreibung.
  ///
  /// In de, this message translates to:
  /// **'Bildbeschreibung'**
  String get stufeBildbeschreibung;

  /// No description provided for @aktualisierungKeineVeroeffentlichungen.
  ///
  /// In de, this message translates to:
  /// **'Keine Veröffentlichungen gefunden.'**
  String get aktualisierungKeineVeroeffentlichungen;

  /// No description provided for @aktualisierungKeineVersion.
  ///
  /// In de, this message translates to:
  /// **'Keine Versionsangabe in der Antwort gefunden.'**
  String get aktualisierungKeineVersion;

  /// No description provided for @backupGrenzeErreicht.
  ///
  /// In de, this message translates to:
  /// **'Grenze erreicht – {anzahl} Datei(en) folgen beim nächsten Lauf'**
  String backupGrenzeErreicht(int anzahl);

  /// No description provided for @backupPassphraseNoetig.
  ///
  /// In de, this message translates to:
  /// **'Dieses Backup ist verschlüsselt – eine Passphrase wird benötigt.'**
  String get backupPassphraseNoetig;

  /// No description provided for @downloadPruefsummeFehler.
  ///
  /// In de, this message translates to:
  /// **'Prüfsumme von {datei} stimmt nicht mit der erwarteten SHA-256 überein (erhalten {erhalten}, erwartet {erwartet}) – Download verworfen. Die Datei am Server hat sich möglicherweise geändert oder wurde beim Transfer verändert.'**
  String downloadPruefsummeFehler(
      String datei, String erhalten, String erwartet);

  /// No description provided for @downloadFehlgeschlagen.
  ///
  /// In de, this message translates to:
  /// **'Download von {datei} fehlgeschlagen: {fehler}'**
  String downloadFehlgeschlagen(String datei, String fehler);

  /// No description provided for @downloadEntpackenFehler.
  ///
  /// In de, this message translates to:
  /// **'Entpacken von {datei} fehlgeschlagen: {fehler}'**
  String downloadEntpackenFehler(String datei, String fehler);

  /// No description provided for @downloadNichtImZip.
  ///
  /// In de, this message translates to:
  /// **'{datei} nicht im Zip gefunden.'**
  String downloadNichtImZip(String datei);

  /// No description provided for @regelAusloeserOrt.
  ///
  /// In de, this message translates to:
  /// **'Ort (Umkreis)'**
  String get regelAusloeserOrt;

  /// No description provided for @regelAusloeserTag.
  ///
  /// In de, this message translates to:
  /// **'KI-Tag'**
  String get regelAusloeserTag;

  /// No description provided for @regelAusloeserDatum.
  ///
  /// In de, this message translates to:
  /// **'Datumsbereich'**
  String get regelAusloeserDatum;

  /// No description provided for @regelUmkreisUm.
  ///
  /// In de, this message translates to:
  /// **'Umkreis {km} km um {breite}, {laenge}'**
  String regelUmkreisUm(String km, String breite, String laenge);

  /// No description provided for @regelTagWert.
  ///
  /// In de, this message translates to:
  /// **'KI-Tag: {begriff}'**
  String regelTagWert(String begriff);

  /// No description provided for @regelDatumBereich.
  ///
  /// In de, this message translates to:
  /// **'{von} – {bis}'**
  String regelDatumBereich(String von, String bis);

  /// No description provided for @regelUmkreis.
  ///
  /// In de, this message translates to:
  /// **'Umkreis: {km} km'**
  String regelUmkreis(String km);

  /// No description provided for @regelAlbumTeil.
  ///
  /// In de, this message translates to:
  /// **'Album: {name}'**
  String regelAlbumTeil(String name);

  /// No description provided for @regelTagsTeil.
  ///
  /// In de, this message translates to:
  /// **'Tags: {namen}'**
  String regelTagsTeil(String namen);

  /// No description provided for @duplGruppe.
  ///
  /// In de, this message translates to:
  /// **'Gruppe {nummer} · {anzahl} Fotos'**
  String duplGruppe(int nummer, int anzahl);

  /// No description provided for @stapelSerie.
  ///
  /// In de, this message translates to:
  /// **'Serie {nummer} · {anzahl} Fotos'**
  String stapelSerie(int nummer, int anzahl);

  /// No description provided for @clusterGesichterZuordnen.
  ///
  /// In de, this message translates to:
  /// **'{anzahl} Gesichter zuordnen'**
  String clusterGesichterZuordnen(int anzahl);

  /// No description provided for @clusterGesichterAnzahl.
  ///
  /// In de, this message translates to:
  /// **'{anzahl} Gesichter'**
  String clusterGesichterAnzahl(int anzahl);

  /// No description provided for @gesichtEmbeddingFehler.
  ///
  /// In de, this message translates to:
  /// **'Wiedererkennungs-Embedding fehlgeschlagen: {fehler}'**
  String gesichtEmbeddingFehler(String fehler);

  /// No description provided for @bearbSpeichernFehler.
  ///
  /// In de, this message translates to:
  /// **'Speichern fehlgeschlagen: {fehler}'**
  String bearbSpeichernFehler(String fehler);

  /// No description provided for @integFehlendeDateien.
  ///
  /// In de, this message translates to:
  /// **'Fehlende Dateien ({anzahl})'**
  String integFehlendeDateien(int anzahl);

  /// No description provided for @integVerwaisteDateien.
  ///
  /// In de, this message translates to:
  /// **'Verwaiste Dateien ({anzahl})'**
  String integVerwaisteDateien(int anzahl);

  /// No description provided for @viewerKugelSchwenken.
  ///
  /// In de, this message translates to:
  /// **'3D-Kugel statt flachem Schwenken'**
  String get viewerKugelSchwenken;

  /// No description provided for @regelNeuTitel.
  ///
  /// In de, this message translates to:
  /// **'Neue Automatisierungsregel'**
  String get regelNeuTitel;

  /// No description provided for @regelBearbeitenTitel.
  ///
  /// In de, this message translates to:
  /// **'Regel bearbeiten'**
  String get regelBearbeitenTitel;

  /// No description provided for @presetZeileAlbum.
  ///
  /// In de, this message translates to:
  /// **'Album: {album}'**
  String presetZeileAlbum(String album);

  /// No description provided for @presetZeileTags.
  ///
  /// In de, this message translates to:
  /// **'Tags: {tags}'**
  String presetZeileTags(String tags);

  /// No description provided for @presetKeineAktion.
  ///
  /// In de, this message translates to:
  /// **'Keine Aktion konfiguriert'**
  String get presetKeineAktion;

  /// No description provided for @presetNeuTitel.
  ///
  /// In de, this message translates to:
  /// **'Neues Kamera-Preset'**
  String get presetNeuTitel;

  /// No description provided for @presetBearbeitenTitel.
  ///
  /// In de, this message translates to:
  /// **'Kamera-Preset bearbeiten'**
  String get presetBearbeitenTitel;

  /// No description provided for @allgSucheFehlgeschlagen.
  ///
  /// In de, this message translates to:
  /// **'Suche fehlgeschlagen: {fehler}'**
  String allgSucheFehlgeschlagen(String fehler);

  /// No description provided for @allgUnbekannterFehler.
  ///
  /// In de, this message translates to:
  /// **'Unbekannter Fehler'**
  String get allgUnbekannterFehler;

  /// No description provided for @erkundenVorJahren.
  ///
  /// In de, this message translates to:
  /// **'{jahre, plural, =1{Vor 1 Jahr} other{Vor {jahre} Jahren}}'**
  String erkundenVorJahren(int jahre);

  /// No description provided for @gesichtBenennen.
  ///
  /// In de, this message translates to:
  /// **'Gesicht benennen'**
  String get gesichtBenennen;

  /// No description provided for @gesichtUnbenannt.
  ///
  /// In de, this message translates to:
  /// **'Unbenannt'**
  String get gesichtUnbenannt;

  /// No description provided for @bearbZuschneiden.
  ///
  /// In de, this message translates to:
  /// **'Zuschneiden'**
  String get bearbZuschneiden;

  /// No description provided for @bearbLinksDrehen.
  ///
  /// In de, this message translates to:
  /// **'Nach links drehen'**
  String get bearbLinksDrehen;

  /// No description provided for @bearbRechtsDrehen.
  ///
  /// In de, this message translates to:
  /// **'Nach rechts drehen'**
  String get bearbRechtsDrehen;

  /// No description provided for @bearbHorizontalSpiegeln.
  ///
  /// In de, this message translates to:
  /// **'Horizontal spiegeln'**
  String get bearbHorizontalSpiegeln;

  /// No description provided for @bearbVertikalSpiegeln.
  ///
  /// In de, this message translates to:
  /// **'Vertikal spiegeln'**
  String get bearbVertikalSpiegeln;

  /// No description provided for @integAusDbEntfernenTitel.
  ///
  /// In de, this message translates to:
  /// **'Aus Datenbank entfernen?'**
  String get integAusDbEntfernenTitel;

  /// No description provided for @integArtOriginal.
  ///
  /// In de, this message translates to:
  /// **'Original'**
  String get integArtOriginal;

  /// No description provided for @integArtThumbnail.
  ///
  /// In de, this message translates to:
  /// **'Thumbnail'**
  String get integArtThumbnail;

  /// No description provided for @integArtVorschau.
  ///
  /// In de, this message translates to:
  /// **'Vorschau'**
  String get integArtVorschau;

  /// No description provided for @integArtEntwickelt.
  ///
  /// In de, this message translates to:
  /// **'Entwickeltes Bild'**
  String get integArtEntwickelt;

  /// No description provided for @integArtRestauriert.
  ///
  /// In de, this message translates to:
  /// **'KI-restauriertes Bild'**
  String get integArtRestauriert;

  /// No description provided for @integArtVideoZuschnitt.
  ///
  /// In de, this message translates to:
  /// **'Geschnittenes Video'**
  String get integArtVideoZuschnitt;

  /// No description provided for @integArtGesichtsCrop.
  ///
  /// In de, this message translates to:
  /// **'Gesichts-Crop'**
  String get integArtGesichtsCrop;

  /// No description provided for @integArtMaske.
  ///
  /// In de, this message translates to:
  /// **'KI-Maske'**
  String get integArtMaske;

  /// No description provided for @gesperrtTabFotos.
  ///
  /// In de, this message translates to:
  /// **'Fotos'**
  String get gesperrtTabFotos;

  /// No description provided for @gesperrtTabPapierkorb.
  ///
  /// In de, this message translates to:
  /// **'Papierkorb'**
  String get gesperrtTabPapierkorb;

  /// No description provided for @karteHell.
  ///
  /// In de, this message translates to:
  /// **'Hell'**
  String get karteHell;

  /// No description provided for @karteDunkel.
  ///
  /// In de, this message translates to:
  /// **'Dunkel'**
  String get karteDunkel;

  /// No description provided for @karteGlobus.
  ///
  /// In de, this message translates to:
  /// **'Globus'**
  String get karteGlobus;

  /// No description provided for @zweitVergleichFehlgeschlagen.
  ///
  /// In de, this message translates to:
  /// **'Vergleich fehlgeschlagen: {fehler}'**
  String zweitVergleichFehlgeschlagen(String fehler);

  /// No description provided for @xmpEinlesenFehlgeschlagen.
  ///
  /// In de, this message translates to:
  /// **'Einlesen fehlgeschlagen: {fehler}'**
  String xmpEinlesenFehlgeschlagen(String fehler);

  /// No description provided for @xmpFeldBewertung.
  ///
  /// In de, this message translates to:
  /// **'Bewertung'**
  String get xmpFeldBewertung;

  /// No description provided for @xmpFeldFarbmarkierung.
  ///
  /// In de, this message translates to:
  /// **'Farbmarkierung'**
  String get xmpFeldFarbmarkierung;

  /// No description provided for @xmpFeldBeschreibung.
  ///
  /// In de, this message translates to:
  /// **'Beschreibung'**
  String get xmpFeldBeschreibung;

  /// No description provided for @xmpFeldNeueTags.
  ///
  /// In de, this message translates to:
  /// **'Neue Tags'**
  String get xmpFeldNeueTags;

  /// No description provided for @xmpFeldStandort.
  ///
  /// In de, this message translates to:
  /// **'Standort'**
  String get xmpFeldStandort;

  /// No description provided for @xmpKeineSidecars.
  ///
  /// In de, this message translates to:
  /// **'Keine XMP-Sidecars gefunden.'**
  String get xmpKeineSidecars;

  /// No description provided for @liveWiedergabeStoppen.
  ///
  /// In de, this message translates to:
  /// **'Wiedergabe stoppen'**
  String get liveWiedergabeStoppen;

  /// No description provided for @liveDauerschleife.
  ///
  /// In de, this message translates to:
  /// **'In Dauerschleife abspielen'**
  String get liveDauerschleife;

  /// No description provided for @metaHersteller.
  ///
  /// In de, this message translates to:
  /// **'Kamera-Hersteller'**
  String get metaHersteller;

  /// No description provided for @metaModell.
  ///
  /// In de, this message translates to:
  /// **'Kamera-Modell'**
  String get metaModell;

  /// No description provided for @metaObjektiv.
  ///
  /// In de, this message translates to:
  /// **'Objektiv'**
  String get metaObjektiv;

  /// No description provided for @metaBrennweite.
  ///
  /// In de, this message translates to:
  /// **'Brennweite (mm)'**
  String get metaBrennweite;

  /// No description provided for @metaBlende.
  ///
  /// In de, this message translates to:
  /// **'Blende (f/…)'**
  String get metaBlende;

  /// No description provided for @metaBelichtungszeit.
  ///
  /// In de, this message translates to:
  /// **'Belichtungszeit'**
  String get metaBelichtungszeit;

  /// No description provided for @passphraseZuKurz.
  ///
  /// In de, this message translates to:
  /// **'Passphrase muss mindestens 8 Zeichen lang sein.'**
  String get passphraseZuKurz;

  /// No description provided for @exportVorgabenTitel.
  ///
  /// In de, this message translates to:
  /// **'Export-Voreinstellungen'**
  String get exportVorgabenTitel;

  /// No description provided for @exportVorgabenLeer.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Voreinstellung. Eine Voreinstellung merkt sich Grösse, Qualität und Dateibenennung – für alles, was Sie öfter als einmal exportieren.'**
  String get exportVorgabenLeer;

  /// No description provided for @exportVorgabeNeu.
  ///
  /// In de, this message translates to:
  /// **'Neue Voreinstellung'**
  String get exportVorgabeNeu;

  /// No description provided for @exportVorgabeNeuTitel.
  ///
  /// In de, this message translates to:
  /// **'Neue Export-Voreinstellung'**
  String get exportVorgabeNeuTitel;

  /// No description provided for @exportVorgabeBearbeitenTitel.
  ///
  /// In de, this message translates to:
  /// **'Voreinstellung bearbeiten'**
  String get exportVorgabeBearbeitenTitel;

  /// No description provided for @exportVorgabeName.
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get exportVorgabeName;

  /// No description provided for @exportVorgabeNameNoetig.
  ///
  /// In de, this message translates to:
  /// **'Bitte einen Namen vergeben.'**
  String get exportVorgabeNameNoetig;

  /// No description provided for @exportVorgabeNachJpeg.
  ///
  /// In de, this message translates to:
  /// **'Nach JPEG rendern'**
  String get exportVorgabeNachJpeg;

  /// No description provided for @exportVorgabeNachJpegHinweis.
  ///
  /// In de, this message translates to:
  /// **'Ohne das wird die Datei unverändert kopiert – der einzige Weg, der RAW und Videos unangetastet lässt.'**
  String get exportVorgabeNachJpegHinweis;

  /// No description provided for @exportVorgabeKante.
  ///
  /// In de, this message translates to:
  /// **'Längere Kante (Pixel)'**
  String get exportVorgabeKante;

  /// No description provided for @exportVorgabeKanteLeer.
  ///
  /// In de, this message translates to:
  /// **'leer = volle Auflösung'**
  String get exportVorgabeKanteLeer;

  /// No description provided for @exportVorgabeKanteUngueltig.
  ///
  /// In de, this message translates to:
  /// **'Die Kantenlänge muss zwischen 64 und 20000 liegen.'**
  String get exportVorgabeKanteUngueltig;

  /// No description provided for @exportVorgabeQualitaet.
  ///
  /// In de, this message translates to:
  /// **'JPEG-Qualität: {prozent} %'**
  String exportVorgabeQualitaet(int prozent);

  /// No description provided for @exportVorgabeMuster.
  ///
  /// In de, this message translates to:
  /// **'Namensmuster'**
  String get exportVorgabeMuster;

  /// No description provided for @exportVorgabeMusterNoetig.
  ///
  /// In de, this message translates to:
  /// **'Das Namensmuster darf nicht leer sein.'**
  String get exportVorgabeMusterNoetig;

  /// No description provided for @exportVorgabeMusterHinweis.
  ///
  /// In de, this message translates to:
  /// **'Die Endung wird immer selbst ergänzt. Die laufende Nummer zählt innerhalb eines Export-Laufs und wird vierstellig aufgefüllt.'**
  String get exportVorgabeMusterHinweis;

  /// No description provided for @exportVorgabeXmp.
  ///
  /// In de, this message translates to:
  /// **'XMP-Beistelldatei mitschreiben'**
  String get exportVorgabeXmp;

  /// No description provided for @exportVorgabeXmpHinweis.
  ///
  /// In de, this message translates to:
  /// **'Bewertung, Schlagwörter und Ort für andere Programme – als eigene Datei neben dem Foto.'**
  String get exportVorgabeXmpHinweis;

  /// No description provided for @exportVorgabeJpegVoll.
  ///
  /// In de, this message translates to:
  /// **'JPEG, volle Auflösung, {prozent} %'**
  String exportVorgabeJpegVoll(int prozent);

  /// No description provided for @exportVorgabeJpegKante.
  ///
  /// In de, this message translates to:
  /// **'JPEG, lange Kante {kante} px, {prozent} %'**
  String exportVorgabeJpegKante(int kante, int prozent);

  /// No description provided for @exportVorgabeOhneXmp.
  ///
  /// In de, this message translates to:
  /// **'ohne XMP'**
  String get exportVorgabeOhneXmp;

  /// No description provided for @exportVorgabeLoeschenTitel.
  ///
  /// In de, this message translates to:
  /// **'Voreinstellung löschen?'**
  String get exportVorgabeLoeschenTitel;

  /// No description provided for @exportVorgabeLoeschenText.
  ///
  /// In de, this message translates to:
  /// **'„{name}\" wird entfernt. Bereits exportierte Dateien bleiben unberührt.'**
  String exportVorgabeLoeschenText(String name);

  /// No description provided for @exportEigeneVorgaben.
  ///
  /// In de, this message translates to:
  /// **'Eigene Voreinstellungen'**
  String get exportEigeneVorgaben;

  /// No description provided for @exportVorgabenVerwalten.
  ///
  /// In de, this message translates to:
  /// **'Voreinstellungen verwalten …'**
  String get exportVorgabenVerwalten;

  /// No description provided for @werkzExportVorgabenTitel.
  ///
  /// In de, this message translates to:
  /// **'Export-Voreinstellungen'**
  String get werkzExportVorgabenTitel;

  /// No description provided for @werkzExportVorgabenText.
  ///
  /// In de, this message translates to:
  /// **'Benannte Ausgabe-Vorgaben für den Export: Grösse, JPEG-Qualität, Dateibenennung und ob eine XMP-Beistelldatei mitgeschrieben wird.'**
  String get werkzExportVorgabenText;

  /// No description provided for @exportVorgabeNameVergeben.
  ///
  /// In de, this message translates to:
  /// **'Diesen Namen gibt es schon.'**
  String get exportVorgabeNameVergeben;

  /// No description provided for @entwObjektivkorrekturKeinRaw.
  ///
  /// In de, this message translates to:
  /// **'Kein RAW – die Kamera hat Verzeichnung und Vignettierung bereits korrigiert.'**
  String get entwObjektivkorrekturKeinRaw;

  /// No description provided for @entwObjektivkorrekturVerfuegbar.
  ///
  /// In de, this message translates to:
  /// **'Kamera und Objektiv sind bekannt: Verzeichnung und Vignettierung werden korrigiert.'**
  String get entwObjektivkorrekturVerfuegbar;

  /// No description provided for @entwObjektivkorrekturUnbekanntesObjektiv.
  ///
  /// In de, this message translates to:
  /// **'Für diese Kamera gibt es kein Profil. Bei ProRAW-Aufnahmen ist das kein Mangel – die Korrektur steckt schon in der Datei.'**
  String get entwObjektivkorrekturUnbekanntesObjektiv;

  /// No description provided for @entwObjektivkorrekturNichtLesbar.
  ///
  /// In de, this message translates to:
  /// **'Die RAW-Daten dieser Datei lassen sich nicht öffnen. Auch die übrigen Regler wirken deshalb nur auf die eingebettete Vorschau.'**
  String get entwObjektivkorrekturNichtLesbar;

  /// No description provided for @einstSuche.
  ///
  /// In de, this message translates to:
  /// **'Suche nach Einstellungen'**
  String get einstSuche;

  /// No description provided for @einstNichtsGefunden.
  ///
  /// In de, this message translates to:
  /// **'Keine Einstellung passt zu dieser Suche.'**
  String get einstNichtsGefunden;

  /// No description provided for @einstBeschrErscheinungsbild.
  ///
  /// In de, this message translates to:
  /// **'Hell, dunkel oder wie das System'**
  String get einstBeschrErscheinungsbild;

  /// No description provided for @einstBeschrSprache.
  ///
  /// In de, this message translates to:
  /// **'Sprache der Oberfläche und der Schlagwörter'**
  String get einstBeschrSprache;

  /// No description provided for @einstBeschrUeberwacht.
  ///
  /// In de, this message translates to:
  /// **'Ordner, aus denen neue Fotos von selbst hereinkommen'**
  String get einstBeschrUeberwacht;

  /// No description provided for @einstBeschrBibliotheken.
  ///
  /// In de, this message translates to:
  /// **'Zwischen mehreren Bibliotheken wechseln'**
  String get einstBeschrBibliotheken;

  /// No description provided for @einstBeschrSpeicherort.
  ///
  /// In de, this message translates to:
  /// **'Wo die Bibliothek liegt und wie viel Platz sie braucht'**
  String get einstBeschrSpeicherort;

  /// No description provided for @einstBeschrModelle.
  ///
  /// In de, this message translates to:
  /// **'Herunterladen und entfernen der lokalen Modelle'**
  String get einstBeschrModelle;

  /// No description provided for @einstBeschrHintergrund.
  ///
  /// In de, this message translates to:
  /// **'Ob nach dem Import automatisch ausgewertet wird'**
  String get einstBeschrHintergrund;

  /// No description provided for @einstBeschrVokabular.
  ///
  /// In de, this message translates to:
  /// **'Die Begriffe, nach denen Fotos beschlagwortet werden'**
  String get einstBeschrVokabular;

  /// No description provided for @einstBeschrStandortdaten.
  ///
  /// In de, this message translates to:
  /// **'Ortsnamen zu GPS-Koordinaten, offline'**
  String get einstBeschrStandortdaten;

  /// No description provided for @einstBeschrGesperrt.
  ///
  /// In de, this message translates to:
  /// **'PIN, Verschlüsselung und was darin liegt'**
  String get einstBeschrGesperrt;

  /// No description provided for @einstBeschrBackupSchluessel.
  ///
  /// In de, this message translates to:
  /// **'Passphrase für verschlüsselte Sicherungen'**
  String get einstBeschrBackupSchluessel;

  /// No description provided for @einstBeschrBackupManuell.
  ///
  /// In de, this message translates to:
  /// **'Eine Sicherung von Hand anstoßen'**
  String get einstBeschrBackupManuell;

  /// No description provided for @einstBeschrBackupAuto.
  ///
  /// In de, this message translates to:
  /// **'Regelmäßig sichern, ohne daran zu denken'**
  String get einstBeschrBackupAuto;

  /// No description provided for @einstBeschrPapierkorb.
  ///
  /// In de, this message translates to:
  /// **'Wann gelöschte Fotos endgültig verschwinden'**
  String get einstBeschrPapierkorb;

  /// No description provided for @einstBeschrGefahr.
  ///
  /// In de, this message translates to:
  /// **'Schritte, die sich nicht rückgängig machen lassen'**
  String get einstBeschrGefahr;

  /// No description provided for @einstBeschrUeber.
  ///
  /// In de, this message translates to:
  /// **'Version, Lizenzen und Aktualisierungen'**
  String get einstBeschrUeber;

  /// No description provided for @allgRueckgaengig.
  ///
  /// In de, this message translates to:
  /// **'Rückgängig'**
  String get allgRueckgaengig;

  /// No description provided for @personenIgnoriertTab.
  ///
  /// In de, this message translates to:
  /// **'Ignoriert'**
  String get personenIgnoriertTab;

  /// Reiterbeschriftung mit der Zahl der darin liegenden Einträge. Als Textbaustein und nicht im Quelltext zusammengesetzt, weil nicht jede Sprache runde Klammern dafür verwendet.
  ///
  /// In de, this message translates to:
  /// **'{beschriftung} ({anzahl})'**
  String tabMitZahl(String beschriftung, int anzahl);

  /// No description provided for @personenIgnorierenTooltip.
  ///
  /// In de, this message translates to:
  /// **'Ausgewählte Gesichter ignorieren'**
  String get personenIgnorierenTooltip;

  /// No description provided for @personenIgnoriertMeldung.
  ///
  /// In de, this message translates to:
  /// **'{anzahl, plural, =1{Ein Gesicht ignoriert.} other{{anzahl} Gesichter ignoriert.}}'**
  String personenIgnoriertMeldung(int anzahl);

  /// No description provided for @personenIgnoriertLeer.
  ///
  /// In de, this message translates to:
  /// **'Keine ignorierten Gesichter. Was du unter „Unbenannte Gesichter“ beiseitelegst – Plakate, Spiegelungen, Statuen –, sammelt sich hier und lässt sich jederzeit zurückholen.'**
  String get personenIgnoriertLeer;

  /// No description provided for @personenIgnoriertHinweis.
  ///
  /// In de, this message translates to:
  /// **'Ignorierte Gesichter erscheinen nicht mehr im Raster und werden nicht mehr gruppiert. Doppelklick öffnet das ganze Foto.'**
  String get personenIgnoriertHinweis;

  /// No description provided for @personenIgnoriertTeilHinweis.
  ///
  /// In de, this message translates to:
  /// **'{gezeigt} von {gesamt} ignorierten Gesichtern. Doppelklick öffnet das ganze Foto.'**
  String personenIgnoriertTeilHinweis(int gezeigt, int gesamt);

  /// No description provided for @personenZurueckholenKnopf.
  ///
  /// In de, this message translates to:
  /// **'{anzahl} zurückholen'**
  String personenZurueckholenKnopf(int anzahl);

  /// No description provided for @clusterPhaseLaden.
  ///
  /// In de, this message translates to:
  /// **'Gesichter werden geladen …'**
  String get clusterPhaseLaden;

  /// No description provided for @clusterPhaseVergleichen.
  ///
  /// In de, this message translates to:
  /// **'Gesichter werden verglichen …'**
  String get clusterPhaseVergleichen;

  /// No description provided for @clusterPhaseVorschlaege.
  ///
  /// In de, this message translates to:
  /// **'Vorschläge werden vorbereitet …'**
  String get clusterPhaseVorschlaege;

  /// No description provided for @clusterOhneProzent.
  ///
  /// In de, this message translates to:
  /// **'Läuft …'**
  String get clusterOhneProzent;

  /// No description provided for @clusterFehlgeschlagen.
  ///
  /// In de, this message translates to:
  /// **'Die automatische Gruppierung ist fehlgeschlagen: {fehler}'**
  String clusterFehlgeschlagen(String fehler);

  /// No description provided for @clusterIgnorierenTooltip.
  ///
  /// In de, this message translates to:
  /// **'Ganze Gruppe ignorieren'**
  String get clusterIgnorierenTooltip;

  /// No description provided for @gesichtIgnorieren.
  ///
  /// In de, this message translates to:
  /// **'Ignorieren'**
  String get gesichtIgnorieren;

  /// No description provided for @gesichtIgnoriert.
  ///
  /// In de, this message translates to:
  /// **'Ignoriert'**
  String get gesichtIgnoriert;

  /// No description provided for @gesichtZurueckgeholt.
  ///
  /// In de, this message translates to:
  /// **'Gesicht wird wieder berücksichtigt.'**
  String get gesichtZurueckgeholt;

  /// No description provided for @gesichtPosition.
  ///
  /// In de, this message translates to:
  /// **'{nummer} von {gesamt}'**
  String gesichtPosition(int nummer, int gesamt);

  /// No description provided for @gesichtVoriges.
  ///
  /// In de, this message translates to:
  /// **'Vorheriges Foto (Pfeil links)'**
  String get gesichtVoriges;

  /// No description provided for @gesichtNaechstes.
  ///
  /// In de, this message translates to:
  /// **'Nächstes Foto (Pfeil rechts)'**
  String get gesichtNaechstes;

  /// No description provided for @clusterUnerwartetBeendet.
  ///
  /// In de, this message translates to:
  /// **'Die automatische Gruppierung wurde unerwartet beendet.'**
  String get clusterUnerwartetBeendet;

  /// No description provided for @aufgAktiv.
  ///
  /// In de, this message translates to:
  /// **'Aktiv'**
  String get aufgAktiv;

  /// No description provided for @aufgStufeKurz.
  ///
  /// In de, this message translates to:
  /// **'Stufe {nummer}/{gesamt}'**
  String aufgStufeKurz(int nummer, int gesamt);

  /// No description provided for @personenAlleIgnorieren.
  ///
  /// In de, this message translates to:
  /// **'Alle unbenannten Gesichter ignorieren'**
  String get personenAlleIgnorieren;

  /// No description provided for @personenAlleIgnorierenHinweis.
  ///
  /// In de, this message translates to:
  /// **'{anzahl, plural, =0{Nichts mehr offen} =1{Ein Gesicht wandert nach „Ignoriert“} other{{anzahl} Gesichter wandern nach „Ignoriert“}}'**
  String personenAlleIgnorierenHinweis(int anzahl);

  /// No description provided for @personenAlleIgnoriertMeldung.
  ///
  /// In de, this message translates to:
  /// **'{anzahl, plural, =0{Es war nichts zu ignorieren.} =1{Ein Gesicht ignoriert. Unter „Ignoriert“ holst du einzelne zurück.} other{{anzahl} Gesichter ignoriert. Unter „Ignoriert“ holst du einzelne zurück.}}'**
  String personenAlleIgnoriertMeldung(int anzahl);

  /// No description provided for @personenAlleErkennungenLoeschen.
  ///
  /// In de, this message translates to:
  /// **'Alle unbenannten Erkennungen löschen'**
  String get personenAlleErkennungenLoeschen;

  /// No description provided for @personenAlleErkennungenLoeschenHinweis.
  ///
  /// In de, this message translates to:
  /// **'Gibt Platz frei, kommt beim nächsten Scan aber wieder'**
  String get personenAlleErkennungenLoeschenHinweis;

  /// No description provided for @personenErkennungenLoeschenTitel.
  ///
  /// In de, this message translates to:
  /// **'Erkennungen wirklich löschen?'**
  String get personenErkennungenLoeschenTitel;

  /// No description provided for @personenErkennungenLoeschenText.
  ///
  /// In de, this message translates to:
  /// **'Alle unbenannten Erkennungen werden samt ihrer Ausschnitte von der Platte gelöscht – auch die bereits ignorierten. Benannte Personen bleiben unberührt.\n\nDas ist nicht dauerhaft: Der nächste Gesichts-Scan findet dieselben Stellen wieder. Wenn du sie dauerhaft loswerden willst, nimm stattdessen „Alle unbenannten Gesichter ignorieren“ – das überlebt auch einen erneuten Scan.'**
  String get personenErkennungenLoeschenText;

  /// No description provided for @personenErkennungenGeloeschtMeldung.
  ///
  /// In de, this message translates to:
  /// **'{anzahl, plural, =0{Es gab keine Erkennungen zum Löschen.} =1{Eine Erkennung gelöscht.} other{{anzahl} Erkennungen gelöscht.}}'**
  String personenErkennungenGeloeschtMeldung(int anzahl);

  /// No description provided for @gesichtZuordnungLoesen.
  ///
  /// In de, this message translates to:
  /// **'Zuordnung lösen'**
  String get gesichtZuordnungLoesen;

  /// No description provided for @gesichtNichtMehrIgnorieren.
  ///
  /// In de, this message translates to:
  /// **'Nicht mehr ignorieren'**
  String get gesichtNichtMehrIgnorieren;

  /// No description provided for @gesichtFotoLoeschen.
  ///
  /// In de, this message translates to:
  /// **'Foto löschen'**
  String get gesichtFotoLoeschen;

  /// No description provided for @gesichtErkennungLoeschen.
  ///
  /// In de, this message translates to:
  /// **'Erkennung löschen'**
  String get gesichtErkennungLoeschen;

  /// No description provided for @gesichtAlleUnbenanntenIgnorieren.
  ///
  /// In de, this message translates to:
  /// **'{anzahl, plural, =0{Keine unbenannten Gesichter} =1{Unbenanntes Gesicht ignorieren} other{{anzahl} unbenannte Gesichter ignorieren}}'**
  String gesichtAlleUnbenanntenIgnorieren(int anzahl);

  /// No description provided for @personWeitereFotosSuchen.
  ///
  /// In de, this message translates to:
  /// **'Weitere Fotos suchen'**
  String get personWeitereFotosSuchen;

  /// No description provided for @vorschlagTitel.
  ///
  /// In de, this message translates to:
  /// **'Vorschläge für {name}'**
  String vorschlagTitel(String name);

  /// No description provided for @vorschlagHinweis.
  ///
  /// In de, this message translates to:
  /// **'Alles ist ausgewählt. Nimm heraus, was nicht stimmt – auch das lernt die Erkennung: Eine Ablehnung schiebt die Schwelle für diese Person nach oben.'**
  String get vorschlagHinweis;

  /// No description provided for @vorschlagAlleWaehlen.
  ///
  /// In de, this message translates to:
  /// **'Alle wählen'**
  String get vorschlagAlleWaehlen;

  /// No description provided for @vorschlagKeineWaehlen.
  ///
  /// In de, this message translates to:
  /// **'Keine wählen'**
  String get vorschlagKeineWaehlen;

  /// No description provided for @vorschlagUebernehmen.
  ///
  /// In de, this message translates to:
  /// **'{anzahl, plural, =0{Nichts ausgewählt} =1{Ein Gesicht zuordnen} other{{anzahl} Gesichter zuordnen}}'**
  String vorschlagUebernehmen(int anzahl);

  /// No description provided for @vorschlagUebernommenMeldung.
  ///
  /// In de, this message translates to:
  /// **'{anzahl, plural, =0{Nichts übernommen – die Rückmeldung ist trotzdem gespeichert.} =1{Ein Foto hinzugefügt.} other{{anzahl} Fotos hinzugefügt.}}'**
  String vorschlagUebernommenMeldung(int anzahl);

  /// No description provided for @vorschlagKeineEmbeddings.
  ///
  /// In de, this message translates to:
  /// **'Für diese Person gibt es noch keine Wiedererkennungs-Daten. Sie entstehen beim Gesichts-Scan, sobald das SFace-Modell installiert ist.'**
  String get vorschlagKeineEmbeddings;

  /// No description provided for @vorschlagKeineKandidaten.
  ///
  /// In de, this message translates to:
  /// **'Es gibt keine unbenannten Gesichter, die vorgeschlagen werden könnten.'**
  String get vorschlagKeineKandidaten;

  /// No description provided for @vorschlagNichtsGefunden.
  ///
  /// In de, this message translates to:
  /// **'Kein unbenanntes Gesicht liegt über der Schwelle {schwelle} dieser Person.'**
  String vorschlagNichtsGefunden(String schwelle);

  /// No description provided for @gesichtRahmenAusblenden.
  ///
  /// In de, this message translates to:
  /// **'Rahmen ausblenden'**
  String get gesichtRahmenAusblenden;

  /// No description provided for @gesichtRahmenEinblenden.
  ///
  /// In de, this message translates to:
  /// **'Rahmen einblenden'**
  String get gesichtRahmenEinblenden;

  /// No description provided for @entwKlarheit.
  ///
  /// In de, this message translates to:
  /// **'Klarheit'**
  String get entwKlarheit;

  /// No description provided for @entwVignettierung.
  ///
  /// In de, this message translates to:
  /// **'Vignettierung'**
  String get entwVignettierung;

  /// No description provided for @entwLutKeine.
  ///
  /// In de, this message translates to:
  /// **'Keine Farbtabelle'**
  String get entwLutKeine;

  /// No description provided for @entwLutWaehlen.
  ///
  /// In de, this message translates to:
  /// **'Farbtabelle wählen (.cube)'**
  String get entwLutWaehlen;

  /// No description provided for @entwLutEntfernen.
  ///
  /// In de, this message translates to:
  /// **'Farbtabelle entfernen'**
  String get entwLutEntfernen;

  /// No description provided for @entwLutStaerke.
  ///
  /// In de, this message translates to:
  /// **'Stärke'**
  String get entwLutStaerke;

  /// No description provided for @entwLutFehlt.
  ///
  /// In de, this message translates to:
  /// **'Die Farbtabelle „{name}“ lässt sich nicht mehr lesen und wurde entfernt.'**
  String entwLutFehlt(String name);

  /// No description provided for @entwLutNichtLesbar.
  ///
  /// In de, this message translates to:
  /// **'Die Datei lässt sich nicht lesen: {fehler}'**
  String entwLutNichtLesbar(String fehler);

  /// No description provided for @entwLutEindimensional.
  ///
  /// In de, this message translates to:
  /// **'Das ist eine eindimensionale Tabelle – sie beschreibt eine Kurve, keinen Farbraum. Dafür gibt es hier die Tonwertkurve.'**
  String get entwLutEindimensional;

  /// No description provided for @entwLutOhneGroesse.
  ///
  /// In de, this message translates to:
  /// **'In der Datei fehlt die Angabe LUT_3D_SIZE.'**
  String get entwLutOhneGroesse;

  /// No description provided for @entwLutGroesse.
  ///
  /// In de, this message translates to:
  /// **'Die Kantenlänge in Zeile {zeile} liegt außerhalb des Erlaubten (2 bis 256).'**
  String entwLutGroesse(int zeile);

  /// No description provided for @entwLutZeilenzahl.
  ///
  /// In de, this message translates to:
  /// **'Die Datei enthält nicht so viele Werte, wie ihre Kantenlänge verlangt.'**
  String get entwLutZeilenzahl;

  /// No description provided for @entwLutZeile.
  ///
  /// In de, this message translates to:
  /// **'Zeile {zeile} lässt sich nicht lesen.'**
  String entwLutZeile(int zeile);

  /// No description provided for @histogrammWaveform.
  ///
  /// In de, this message translates to:
  /// **'Waveform'**
  String get histogrammWaveform;

  /// No description provided for @histogrammParade.
  ///
  /// In de, this message translates to:
  /// **'Parade'**
  String get histogrammParade;

  /// No description provided for @entwFormRechteck.
  ///
  /// In de, this message translates to:
  /// **'Rechteck'**
  String get entwFormRechteck;

  /// No description provided for @entwFormFarbe.
  ///
  /// In de, this message translates to:
  /// **'Farbe'**
  String get entwFormFarbe;

  /// No description provided for @entwRechteckHinweis.
  ///
  /// In de, this message translates to:
  /// **'Ziehe ein Rechteck auf. Drehung und weiche Kante stellst du darunter ein.'**
  String get entwRechteckHinweis;

  /// No description provided for @entwFarbauswahlHinweis.
  ///
  /// In de, this message translates to:
  /// **'Tippe auf eine Farbe im Bild. Ausgewählt wird alles, was ihr ähnlich genug ist – auch heller oder dunkler, denn Farbe zählt mehr als Helligkeit.'**
  String get entwFarbauswahlHinweis;

  /// No description provided for @entwFarbeAufgenommen.
  ///
  /// In de, this message translates to:
  /// **'R {rot} · G {gruen} · B {blau}'**
  String entwFarbeAufgenommen(int rot, int gruen, int blau);

  /// No description provided for @entwToleranz.
  ///
  /// In de, this message translates to:
  /// **'Toleranz'**
  String get entwToleranz;

  /// No description provided for @vergleichTitel.
  ///
  /// In de, this message translates to:
  /// **'Zwei Fotos vergleichen'**
  String get vergleichTitel;

  /// No description provided for @vergleichNebeneinander.
  ///
  /// In de, this message translates to:
  /// **'Nebeneinander'**
  String get vergleichNebeneinander;

  /// No description provided for @vergleichUebereinander.
  ///
  /// In de, this message translates to:
  /// **'Übereinander'**
  String get vergleichUebereinander;

  /// No description provided for @vergleichKoppeln.
  ///
  /// In de, this message translates to:
  /// **'Ansichten koppeln'**
  String get vergleichKoppeln;

  /// No description provided for @vergleichEntkoppeln.
  ///
  /// In de, this message translates to:
  /// **'Ansichten entkoppeln'**
  String get vergleichEntkoppeln;

  /// No description provided for @vergleichZuruecksetzen.
  ///
  /// In de, this message translates to:
  /// **'Zoom zurücksetzen'**
  String get vergleichZuruecksetzen;

  /// No description provided for @auswVergleichen.
  ///
  /// In de, this message translates to:
  /// **'Die zwei ausgewählten Fotos vergleichen'**
  String get auswVergleichen;

  /// No description provided for @listeOhneKamera.
  ///
  /// In de, this message translates to:
  /// **'Ohne Kameraangabe'**
  String get listeOhneKamera;

  /// No description provided for @ansichtRaster.
  ///
  /// In de, this message translates to:
  /// **'Raster'**
  String get ansichtRaster;

  /// No description provided for @ansichtListe.
  ///
  /// In de, this message translates to:
  /// **'Liste'**
  String get ansichtListe;

  /// No description provided for @gruppeMonat.
  ///
  /// In de, this message translates to:
  /// **'Nach Monat'**
  String get gruppeMonat;

  /// No description provided for @gruppeKamera.
  ///
  /// In de, this message translates to:
  /// **'Nach Kamera'**
  String get gruppeKamera;

  /// No description provided for @gruppeKeine.
  ///
  /// In de, this message translates to:
  /// **'Ohne Gliederung'**
  String get gruppeKeine;

  /// No description provided for @bearbGeradeziehen.
  ///
  /// In de, this message translates to:
  /// **'Geradeziehen'**
  String get bearbGeradeziehen;

  /// No description provided for @bearbPerspektive.
  ///
  /// In de, this message translates to:
  /// **'Perspektive'**
  String get bearbPerspektive;

  /// No description provided for @bearbPerspektiveAnwenden.
  ///
  /// In de, this message translates to:
  /// **'Entzerren'**
  String get bearbPerspektiveAnwenden;

  /// No description provided for @modellLamaTitel.
  ///
  /// In de, this message translates to:
  /// **'Objektentfernung (LaMa)'**
  String get modellLamaTitel;

  /// No description provided for @modellLamaText.
  ///
  /// In de, this message translates to:
  /// **'Füllt eine markierte Stelle aus der Umgebung neu auf – für Staubflecken, Passanten oder den Mülleimer am Bildrand. Mit 208 MB das grösste Modell hier; ein Durchgang dauert rund eine Sekunde.'**
  String get modellLamaText;

  /// No description provided for @modellLamaLizenz.
  ///
  /// In de, this message translates to:
  /// **'Apache 2.0 (Samsung Research), ONNX-Export von Carve'**
  String get modellLamaLizenz;

  /// No description provided for @bearbRetusche.
  ///
  /// In de, this message translates to:
  /// **'Objekt entfernen'**
  String get bearbRetusche;

  /// No description provided for @bearbRetuscheAnwenden.
  ///
  /// In de, this message translates to:
  /// **'Entfernen'**
  String get bearbRetuscheAnwenden;

  /// No description provided for @bearbRetuscheZurueck.
  ///
  /// In de, this message translates to:
  /// **'Letzten Strich zurücknehmen'**
  String get bearbRetuscheZurueck;

  /// No description provided for @bearbPinselbreite.
  ///
  /// In de, this message translates to:
  /// **'Pinselbreite'**
  String get bearbPinselbreite;

  /// No description provided for @bearbRetuscheFehler.
  ///
  /// In de, this message translates to:
  /// **'Das Entfernen ist fehlgeschlagen: {fehler}'**
  String bearbRetuscheFehler(String fehler);

  /// No description provided for @stammbaumTitel.
  ///
  /// In de, this message translates to:
  /// **'Stammbaum'**
  String get stammbaumTitel;

  /// No description provided for @stammbaumTitelVon.
  ///
  /// In de, this message translates to:
  /// **'Stammbaum: {name}'**
  String stammbaumTitelVon(String name);

  /// No description provided for @stammbaumEltern.
  ///
  /// In de, this message translates to:
  /// **'Eltern'**
  String get stammbaumEltern;

  /// No description provided for @stammbaumGeschwister.
  ///
  /// In de, this message translates to:
  /// **'Geschwister'**
  String get stammbaumGeschwister;

  /// No description provided for @stammbaumPartner.
  ///
  /// In de, this message translates to:
  /// **'Partner'**
  String get stammbaumPartner;

  /// No description provided for @stammbaumKinder.
  ///
  /// In de, this message translates to:
  /// **'Kinder'**
  String get stammbaumKinder;

  /// No description provided for @stammbaumElternteilHinzufuegen.
  ///
  /// In de, this message translates to:
  /// **'Elternteil hinzufügen'**
  String get stammbaumElternteilHinzufuegen;

  /// No description provided for @stammbaumPartnerHinzufuegen.
  ///
  /// In de, this message translates to:
  /// **'Partner hinzufügen'**
  String get stammbaumPartnerHinzufuegen;

  /// No description provided for @stammbaumKindHinzufuegen.
  ///
  /// In de, this message translates to:
  /// **'Kind hinzufügen'**
  String get stammbaumKindHinzufuegen;

  /// No description provided for @stammbaumInDieMitte.
  ///
  /// In de, this message translates to:
  /// **'In die Mitte rücken'**
  String get stammbaumInDieMitte;

  /// No description provided for @stammbaumLebensdaten.
  ///
  /// In de, this message translates to:
  /// **'Lebensdaten …'**
  String get stammbaumLebensdaten;

  /// No description provided for @stammbaumLebensdatenVon.
  ///
  /// In de, this message translates to:
  /// **'Lebensdaten: {name}'**
  String stammbaumLebensdatenVon(String name);

  /// No description provided for @stammbaumFotosZeigen.
  ///
  /// In de, this message translates to:
  /// **'Fotos dieser Person'**
  String get stammbaumFotosZeigen;

  /// No description provided for @stammbaumVerbindungEntfernen.
  ///
  /// In de, this message translates to:
  /// **'Verbindung entfernen'**
  String get stammbaumVerbindungEntfernen;

  /// No description provided for @stammbaumVerbindungEntfernenFrage.
  ///
  /// In de, this message translates to:
  /// **'Die Verwandtschaft zwischen {eine} und {andere} wird gelöst. Beide Personen und ihre Fotos bleiben erhalten.'**
  String stammbaumVerbindungEntfernenFrage(String eine, String andere);

  /// No description provided for @stammbaumFehlerSelbst.
  ///
  /// In de, this message translates to:
  /// **'Eine Person kann nicht mit sich selbst verwandt sein.'**
  String get stammbaumFehlerSelbst;

  /// No description provided for @stammbaumFehlerKreis.
  ///
  /// In de, this message translates to:
  /// **'Das ginge im Kreis: Die Person steht bereits weiter unten im selben Zweig.'**
  String get stammbaumFehlerKreis;

  /// No description provided for @stammbaumFehlerVorhanden.
  ///
  /// In de, this message translates to:
  /// **'Diese Verwandtschaft ist schon eingetragen.'**
  String get stammbaumFehlerVorhanden;

  /// No description provided for @stammbaumLeer.
  ///
  /// In de, this message translates to:
  /// **'Für diese Person ist noch keine Verwandtschaft eingetragen. Oben rechts lassen sich Eltern, Partner und Kinder hinzufügen – entweder aus den bereits benannten Personen oder als neuer Name, auch ohne ein einziges Foto.'**
  String get stammbaumLeer;

  /// No description provided for @stammbaumPersonFehlt.
  ///
  /// In de, this message translates to:
  /// **'Diese Person gibt es nicht mehr.'**
  String get stammbaumPersonFehlt;

  /// No description provided for @stammbaumGeboren.
  ///
  /// In de, this message translates to:
  /// **'Geboren'**
  String get stammbaumGeboren;

  /// No description provided for @stammbaumGestorben.
  ///
  /// In de, this message translates to:
  /// **'Gestorben'**
  String get stammbaumGestorben;

  /// No description provided for @stammbaumUnbekannt.
  ///
  /// In de, this message translates to:
  /// **'unbekannt'**
  String get stammbaumUnbekannt;

  /// No description provided for @stammbaumNurJahrHinweis.
  ///
  /// In de, this message translates to:
  /// **'Ist nur das Jahr bekannt, wähle einen beliebigen Tag darin – angezeigt wird ohnehin nur die Jahreszahl.'**
  String get stammbaumNurJahrHinweis;
}

class _AppTexteDelegate extends LocalizationsDelegate<AppTexte> {
  const _AppTexteDelegate();

  @override
  Future<AppTexte> load(Locale locale) {
    return SynchronousFuture<AppTexte>(lookupAppTexte(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppTexteDelegate old) => false;
}

AppTexte lookupAppTexte(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppTexteDe();
    case 'en':
      return AppTexteEn();
  }

  throw FlutterError(
      'AppTexte.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
