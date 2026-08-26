// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppTexteEn extends AppTexte {
  AppTexteEn([String locale = 'en']) : super(locale);

  @override
  String get allgAbbrechen => 'Cancel';

  @override
  String get allgSpeichern => 'Save';

  @override
  String get allgSchliessen => 'Close';

  @override
  String get allgErstellen => 'Create';

  @override
  String get allgStarten => 'Start';

  @override
  String get allgName => 'Name';

  @override
  String get allgMehr => 'More';

  @override
  String get allgAlleAnzeigen => 'Show all';

  @override
  String get navTimeline => 'Timeline';

  @override
  String get navErkunden => 'Explore';

  @override
  String get navKalender => 'Calendar';

  @override
  String get navKarte => 'Map';

  @override
  String get navSuche => 'Search';

  @override
  String get navPersonen => 'People';

  @override
  String get navAlben => 'Albums';

  @override
  String get navWerkzeuge => 'Tools';

  @override
  String get navEinstellungen => 'Settings';

  @override
  String get importierenTooltip => 'Import photos and videos';

  @override
  String geoeffneteBibliothek(String name) {
    return 'Open library: $name';
  }

  @override
  String restaurierungLaeuft(int fertig, int gesamt) {
    return 'Restoring – tile $fertig of $gesamt';
  }

  @override
  String restaurierungLaeuftMitWarteschlange(
      int fertig, int gesamt, int wartend) {
    return 'Restoring – tile $fertig of $gesamt · $wartend queued';
  }

  @override
  String get restaurierungWirdVorbereitet => 'Preparing restoration …';

  @override
  String restaurierungWartend(int anzahl) {
    String _temp0 = intl.Intl.pluralLogic(
      anzahl,
      locale: localeName,
      other: '$anzahl photos queued for restoration',
      one: '1 photo queued for restoration',
    );
    return '$_temp0';
  }

  @override
  String analyseLaeuft(
      String stufe, int nummer, int gesamt, String fortschritt) {
    return 'Computing $stufe (step $nummer of $gesamt$fortschritt)';
  }

  @override
  String get kuerzelTitel => 'Keyboard shortcuts';

  @override
  String get kuerzelNavigation => 'Navigation';

  @override
  String get kuerzelVollbild => 'Full screen';

  @override
  String get kuerzelSichtung => 'Culling mode';

  @override
  String get kuerzelBereicheWechseln => 'Switch between the main sections';

  @override
  String get kuerzelUebersichtOeffnen => 'Open this list';

  @override
  String get kuerzelVorherigesNaechstes => 'Previous / next photo';

  @override
  String get kuerzelLeertaste => 'Space';

  @override
  String get kuerzelNaechstesFoto => 'Next photo';

  @override
  String get kuerzelBewertungSetzen => 'Set star rating';

  @override
  String get kuerzelFavoritUmschalten => 'Toggle favourite';

  @override
  String get kuerzelPapierkorbMitBestaetigung => 'Move to trash (asks first)';

  @override
  String get kuerzelSofortAblehnen => 'Reject and move on (no confirmation)';

  @override
  String get timelineLeer => 'No photos in this library yet.';

  @override
  String loeschenTitel(int anzahl) {
    String _temp0 = intl.Intl.pluralLogic(
      anzahl,
      locale: localeName,
      other: 'Delete $anzahl photos?',
      one: 'Delete photo?',
    );
    return '$_temp0';
  }

  @override
  String loeschenHinweis(int anzahl) {
    String _temp0 = intl.Intl.pluralLogic(
      anzahl,
      locale: localeName,
      other: 'They will be moved to the trash.',
      one: 'It will be moved to the trash.',
    );
    return '$_temp0';
  }

  @override
  String get albumNeu => 'New album';

  @override
  String get albumName => 'Album name';

  @override
  String get albenLeer => 'No albums yet.';

  @override
  String get erkundenPersonen => 'People';

  @override
  String get erkundenOrte => 'Places';

  @override
  String get erkundenLetzteAlben => 'Recently added albums';

  @override
  String get erkundenLetzteFotos => 'Recently added photos';

  @override
  String get erkundenErinnerungen => 'Memories';

  @override
  String get ohneOrtLeer => 'No photos with a known location yet.';

  @override
  String get karteTitel => 'Map';

  @override
  String get karteAnsicht => 'Map view';

  @override
  String get karteTexturNachweis =>
      'Earth/star textures: Solar System Scope (CC BY 4.0)';

  @override
  String get kalenderLeer => 'Not enough photos for a year overview yet.';

  @override
  String get kalenderJahrLeer => 'No photos in this year.';

  @override
  String kalenderAnzahlFotos(int anzahl) {
    String _temp0 = intl.Intl.pluralLogic(
      anzahl,
      locale: localeName,
      other: '$anzahl photos/videos',
      one: '$anzahl photo/video',
    );
    return '$_temp0';
  }

  @override
  String get sucheSpeichernTitel => 'Save search';

  @override
  String get sucheModellFehlt =>
      'Context search needs the image search model. You can download it in Settings under “AI models”.';

  @override
  String get sucheModellLaedt => 'Loading the image search model …';

  @override
  String sucheFehlgeschlagen(String fehler) {
    return 'Search failed: $fehler';
  }

  @override
  String get suchePlatzhalterKontext =>
      'e.g. “sunset over the sea”, “dog in the snow” …';

  @override
  String get suchePlatzhalterDateiname => 'File name …';

  @override
  String get suchePlatzhalterBeschreibung => 'Description …';

  @override
  String get suchePlatzhalterText => 'Text in the photo …';

  @override
  String get suchePlatzhalterBildunterschrift => 'e.g. “dog”, “sunset” …';

  @override
  String get sucheOptionen => 'Search options';

  @override
  String get sucheAusloesen => 'Search';

  @override
  String get sucheAnleitung =>
      'Type something to search for, or pick search options.';

  @override
  String get sucheKeineTreffer => 'Nothing found.';

  @override
  String get viewerInfo => 'Info';

  @override
  String get viewerTeilen => 'Share';

  @override
  String get viewerExportieren => 'Export';

  @override
  String get viewerEntwickeln => 'Develop';

  @override
  String get viewerBearbeiten => 'Edit';

  @override
  String get viewerZuschneiden => 'Trim';

  @override
  String get viewerDiaschauStarten => 'Start slideshow';

  @override
  String get viewerDiaschauStoppen => 'Stop slideshow';

  @override
  String get viewerFavoritSetzen => 'Mark as favourite (F)';

  @override
  String get viewerFavoritEntfernen => 'Remove from favourites (F)';

  @override
  String get viewerInGesperrtenOrdner =>
      'Move to the locked folder (encrypted)';

  @override
  String get viewerInPapierkorb => 'Move to trash (⌫)';

  @override
  String get viewerVorherigesFoto => 'Previous photo';

  @override
  String get viewerNaechstesFoto => 'Next photo';

  @override
  String get viewerInTimelineZeigen => 'Show this photo in the timeline';

  @override
  String get viewerAehnlicheZeigen => 'Show similar photos';

  @override
  String get viewerMetadatenBearbeiten => 'Edit metadata';

  @override
  String get viewerGesichterBearbeiten => 'Edit faces';

  @override
  String get viewerEntwicklungAnwenden => 'Paste develop settings';

  @override
  String get viewerEntwicklungAnwendenLang =>
      'Paste the copied develop settings onto this photo';

  @override
  String get viewerGeschlosseneAugen => 'At least one face has its eyes closed';

  @override
  String get viewerFokusPeaking => 'Focus peaking (highlight sharp edges)';

  @override
  String get viewerFlachesSchwenken => 'Pan flat instead of on a sphere';

  @override
  String get viewerFlacheVorschau => 'Flat preview instead of 360° view';

  @override
  String get viewerExportZielordner => 'Choose a folder to export to';

  @override
  String viewerExportiert(String dateien) {
    return 'Exported: $dateien';
  }

  @override
  String viewerExportFehlgeschlagen(String fehler) {
    return 'Export failed: $fehler';
  }

  @override
  String viewerTeilenFehlgeschlagen(String fehler) {
    return 'Sharing failed: $fehler';
  }

  @override
  String get personenTab => 'People';

  @override
  String get personenUnbenannteTab => 'Unnamed faces';

  @override
  String get personenLeer =>
      'No people yet. Switch to the “Unnamed faces” tab, pick a few faces and assign them to a new person.';

  @override
  String get personenLangeDruecken => 'press and hold: merge';

  @override
  String get personenKeineUnbenannten =>
      'No unnamed faces (left). New ones appear here automatically as you import more photos or run another face scan. You can also mark individual ones yourself: open a photo, right-click → “Edit faces”, then use “Add face manually” at the top right.';

  @override
  String get personenSchwellenHinweis =>
      'The similarity threshold lives in Tools → Face recognition.';

  @override
  String get personenDoppelklickHinweis =>
      'Double-click a face to open the whole photo and check it.';

  @override
  String get personenAutomatischGruppieren => 'Group automatically';

  @override
  String get personenAehnlicheAuswaehlen => 'Also select similar';

  @override
  String get personenAehnlicheAbwaehlen => 'Deselect similar';

  @override
  String personenZuordnen(int anzahl) {
    String _temp0 = intl.Intl.pluralLogic(
      anzahl,
      locale: localeName,
      other: 'Assign $anzahl faces',
      one: 'Assign face',
    );
    return '$_temp0';
  }

  @override
  String get personenModellFehlt =>
      'Finding similar faces needs the SFace model (see Settings → Models).';

  @override
  String personenKeineAehnlichen(String schwelle) {
    return 'No faces found above the $schwelle similarity threshold.';
  }

  @override
  String get personenZuWenigeFuerClustering =>
      'Not enough unnamed faces with an embedding to group them.';

  @override
  String get personenKeineGruppen => 'No similar groups found.';

  @override
  String get personenDauertTitel => 'This may take a while';

  @override
  String personenDauertText(int anzahl) {
    return 'Found $anzahl unnamed faces. Grouping compares every face with every other one, which takes a while at this many (the app stays usable meanwhile). Start anyway?';
  }

  @override
  String personenZusammenfuehrenMit(String name) {
    return 'Merge “$name” into …';
  }

  @override
  String get personenZusammenfuehrenTitel => 'Confirm merge';

  @override
  String personenZusammenfuehrenText(String quelle, String ziel) {
    return 'Every photo of “$quelle” will be assigned to “$ziel”. “$quelle” is then deleted. This cannot be undone.';
  }

  @override
  String get personenZusammenfuehren => 'Merge';

  @override
  String get spracheTitel => 'Language';

  @override
  String get spracheSystem => 'System language';

  @override
  String get spracheDeutsch => 'Deutsch';

  @override
  String get spracheEnglisch => 'English';

  @override
  String get spracheHinweis =>
      'Affects the interface only. Your albums, tags and people\'s names stay as they are.';

  @override
  String get spracheVokabularTitel => 'Translate the tag vocabulary too?';

  @override
  String spracheVokabularText(int bekannt, int gesamt) {
    return '$bekannt of the $gesamt terms come from the vocabulary shipped with the app and can be translated reliably. Tags you have already assigned come along; nothing is lost.';
  }

  @override
  String spracheVokabularSelbstAngelegt(int anzahl) {
    String _temp0 = intl.Intl.pluralLogic(
      anzahl,
      locale: localeName,
      other: '$anzahl terms you added yourself stay unchanged.',
      one: 'One term you added yourself stays unchanged.',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get spracheVokabularUebersetzen => 'Translate';

  @override
  String get spracheVokabularBehalten => 'Leave unchanged';

  @override
  String spracheVokabularFertig(int anzahl) {
    String _temp0 = intl.Intl.pluralLogic(
      anzahl,
      locale: localeName,
      other: '$anzahl terms translated.',
      one: 'One term translated.',
    );
    return '$_temp0';
  }

  @override
  String get erkundenKeinePersonen => 'No one has been named yet.';

  @override
  String get erkundenKeineOrte =>
      'No places resolved yet (see Tools → Places).';

  @override
  String get erkundenKeineFotos => 'No photos imported yet.';

  @override
  String get karteKeineOrteLang =>
      'No photos with a known location yet.\n\nLocations come from a photo\'s GPS data during import, if it has any. You can also set one by hand in a photo\'s info panel (full screen → ⓘ).';

  @override
  String einstOrdnerNichtGeoeffnet(String pfad) {
    return 'Could not open the folder: $pfad';
  }

  @override
  String einstBibWechselnTitel(String name) {
    return 'Switch to “$name”?';
  }

  @override
  String get einstBibWechselnText =>
      'The app closes afterwards and opens the chosen library on the next start.\n\nNo photos are moved or deleted – both libraries stay exactly where they are.';

  @override
  String get einstBibGewechselt =>
      'The library has been switched. Nothing was moved. The app is closing now – please open it again.';

  @override
  String get einstBibHinzufuegenAuswahl =>
      'Pick the folder of an existing library – or an empty folder for a new one. Nothing is moved.';

  @override
  String get einstBibBestehendHinzugefuegt => 'Existing library added.';

  @override
  String get einstBibLeerHinzugefuegt =>
      'Empty folder added – switching to it creates a new, empty library.';

  @override
  String einstBibEntfernenTitel(String name) {
    return 'Remove “$name” from the list?';
  }

  @override
  String get einstBibEntfernenText =>
      'The library only disappears from this list. Photos, database and folder stay untouched, and you can add it back at any time.';

  @override
  String get einstBibNichtEntfernbar => 'This entry cannot be removed.';

  @override
  String get einstBibListe => 'Libraries';

  @override
  String get einstBibHinzufuegen => 'Add library…';

  @override
  String get einstBibAusListeEntfernen =>
      'Remove from the list (deletes no photos)';

  @override
  String get einstBibNichtGefunden =>
      'Folder not found – is the drive connected?';

  @override
  String get einstBibWechselHinweis =>
      'Switching only changes which library opens – no photos are moved. To move the current library somewhere else, use “Change location” further down.';

  @override
  String get einstSpeicherortTitel => 'Location of the active library';

  @override
  String get einstSpeicherortWaehlen =>
      'Photos, videos, thumbnails and the database move into this folder. Pick a folder that already exists (create it in Finder first if needed).';

  @override
  String get einstSpeicherortZuruecksetzenTitel => 'Reset the location?';

  @override
  String get einstSpeicherortZuruecksetzenText =>
      'The library moves back into the standard app support folder. The app closes afterwards – please open it again.';

  @override
  String get einstSpeicherortZuruecksetzenLaeuft => 'Resetting the location …';

  @override
  String get einstSpeicherortGeaendert =>
      'The location has changed. The app is closing now – please open it again so it loads the library from its new place.';

  @override
  String get einstImFinderAnzeigen => 'Show in Finder';

  @override
  String get einstAendern => 'Change…';

  @override
  String get einstZuruecksetzen => 'Reset';

  @override
  String get einstWirdBerechnet => 'calculating …';

  @override
  String get einstUeberwachtTitel => 'Watched folder';

  @override
  String get einstUeberwachtKeiner => 'No folder set up';

  @override
  String get einstUeberwachtErklaerung =>
      'Anything that turns up in a chosen folder is taken into the library by itself – every five minutes and on every start.';

  @override
  String get einstUeberwachtAktiv =>
      'Checked every five minutes. The files stay where they are.';

  @override
  String get einstUeberwachtWaehlen => 'Choose folder…';

  @override
  String get einstUeberwachtAndererWaehlen => 'Choose another folder…';

  @override
  String get einstUeberwachtBeenden => 'Stop watching';

  @override
  String get einstUeberwachtAuswahl =>
      'Choose a folder to keep an eye on for new photos. The files stay there; they are only added to the library as well.';

  @override
  String einstUeberwachtUebernommen(int anzahl) {
    String _temp0 = intl.Intl.pluralLogic(
      anzahl,
      locale: localeName,
      other: 'Took $anzahl new photos from the folder.',
      one: 'Took 1 new photo from the folder.',
    );
    return '$_temp0';
  }

  @override
  String get einstKiHinweis =>
      'As in digiKam, every AI feature runs offline on this machine. The model files are not bundled with the app but downloaded on demand from official open-source sources – once, after which everything works offline.';

  @override
  String get einstAutoAnalyseTitel =>
      'Run AI analysis automatically after importing';

  @override
  String get einstAutoAnalyseText =>
      'Importing only files the photos away, which keeps it fast. Faces, text recognition, image search and descriptions follow in the background. Switched off, you can start them by hand under Tools at any time.';

  @override
  String get einstNurErkennung =>
      'Detection only (recognition still needs the SFace model)';

  @override
  String get einstAufgabenTitel => 'Task overview';

  @override
  String get einstAufgabenText =>
      'Every analysis with the number of photos still waiting, each one startable on its own';

  @override
  String get einstModellLoeschen => 'Delete model';

  @override
  String einstModellNichtGeladen(String beschreibung) {
    return '$beschreibung\n\nThe model this needs is not downloaded yet.';
  }

  @override
  String get einstVokabularText =>
      'Terms the image search model (CLIP) applies automatically to newly imported photos. Changes here only affect future photos – to apply them to the existing library, see Tools → “Compute AI tags” → “All photos”.';

  @override
  String get einstBegriffHinzufuegenFeld => 'Add a term …';

  @override
  String get einstBegriffHinzufuegen => 'Add term';

  @override
  String get einstOrteText =>
      'Turns a photo\'s GPS position into country, state or province and city – entirely locally, via the nearest known city (GeoNames data), without asking an online map service. Needed for the country, state and city filters in the search options.';

  @override
  String get einstGeoTitel => 'GeoNames – cities, countries, states';

  @override
  String einstGeoText(String lizenz) {
    return 'Cities from 1000 inhabitants worldwide (~10 MB). Licence: $lizenz.';
  }

  @override
  String get einstGeoLoeschen => 'Delete the GeoNames data';

  @override
  String get einstGesperrtText =>
      'Encrypts private photos with AES-256 – real encryption, not just a display filter – and hides them everywhere else (timeline, search, albums, people, map, backup). Without the PIN there is no way back.';

  @override
  String get einstGesperrtEntsperrt =>
      'PIN set up – already unlocked for this session.';

  @override
  String get einstGesperrtOeffnen => 'Open';

  @override
  String get einstPinAendern => 'Change PIN';

  @override
  String get einstGesperrtAufloesenText =>
      'Every photo in the locked folder is decrypted and becomes visible again everywhere (timeline, search, albums, people, map, backup). This cannot be undone.';

  @override
  String get einstBackupVerschluesselungTitel => 'Backup encryption';

  @override
  String get einstBackupVerschluesselungText =>
      'Lets you encrypt manual and automatic backups with AES-256. Its own passphrase, separate from the locked folder\'s PIN – a backup often ends up elsewhere and has to be decryptable without this machine.';

  @override
  String get einstBackupEntsperrt =>
      'Set up – already unlocked for this session.';

  @override
  String get einstBackupGesperrt =>
      'Set up – you will be asked at the next backup.';

  @override
  String get einstBackupAendern => 'Change';

  @override
  String get einstBackupNieGesichert => 'Never backed up.';

  @override
  String get einstBackupVerschluesseln => 'Encrypt backup';

  @override
  String get einstBackupPassphraseAbfrage =>
      'Asks for the backup passphrase above when needed.';

  @override
  String get einstBackupZielWaehlen =>
      'Choose a backup destination (e.g. your Dropbox or Google Drive folder)';

  @override
  String get einstBackupOrdnerWaehlen =>
      'Choose the backup folder (the one containing “PhotoVault-Backup” or “originals”)';

  @override
  String get einstBackupEntschluesselnTitel => 'Turn off backup encryption?';

  @override
  String get einstBackupEntschluesselnText =>
      'New backups will no longer be encrypted. Encrypted backups already at the destination stay as they are and remain decryptable only with the previous passphrase.';

  @override
  String get einstBackupLaeuft => 'Automatic backup running …';

  @override
  String get einstBackupKeineNeuen =>
      'No new files – refreshing the database snapshot.';

  @override
  String get einstBackupZielHinweis =>
      'Point this at your local Dropbox or Google Drive folder, for instance – that provider\'s desktop app then uploads the files to the cloud for you.';

  @override
  String get einstBackupAutoHinweis =>
      'Runs only while the app is open (there is no background service) – it checks at start-up and every 30 minutes afterwards whether the interval has elapsed. Always encrypted, and alongside the original files it saves a snapshot of the whole database (faces, places, tags, albums, favourites, …) so the complete state can be restored after data loss. It never deletes anything at the destination – local deletions are deliberately not mirrored.';

  @override
  String get einstBackupZuerstZiel => 'Choose a destination folder first.';

  @override
  String get einstBackupKeinOrdner => 'No folder chosen.';

  @override
  String get einstBackupAutoZielWaehlen =>
      'Choose the destination for automatic backups';

  @override
  String get einstWaehlen => 'Choose…';

  @override
  String get einstStuendlich => 'Hourly';

  @override
  String get einstTaeglich => 'Daily';

  @override
  String get einstWoechentlich => 'Weekly';

  @override
  String get einstBackupGrenzeText =>
      'Caps how much each run writes to the destination. Worth setting for cloud folders: otherwise the upload falls behind for days. The rest follows at the next interval.';

  @override
  String get einstNieAusgefuehrt => 'Never run.';

  @override
  String get einstBackupPassphraseGesperrt =>
      'The backup passphrase still needs unlocking for this session before the automatic backup can run – via “Sync now”, for instance.';

  @override
  String get einstPapierkorbText =>
      'Permanently deletes photos and videos once the chosen period has passed since they went to the trash – irreversibly, including from the locked folder\'s PIN-protected trash. Off by default.';

  @override
  String get einstPapierkorbAus => 'Trash expiry is switched off by default.';

  @override
  String get einstResetText =>
      'Irreversibly deletes ALL photos, videos and the entire database of this library, then starts over with an empty one. Downloaded AI models and geo data are kept, so nothing needs downloading again.';

  @override
  String get einstResetTitel => 'Reset the database';

  @override
  String get einstResetKurz =>
      'Deletes all media and metadata – cannot be undone.';

  @override
  String get einstResetKnopf => 'Reset…';

  @override
  String get einstResetBestaetigenTitel => 'Really reset the database?';

  @override
  String get einstResetBestaetigenText =>
      'IRREVERSIBLY deletes all photos, videos, thumbnails and the entire database of this library (albums, people, tags, places, favourites, locked folder, trash, saved searches, …). Downloaded AI models and geo data are kept. Make a backup first if you are unsure – this CANNOT be undone.';

  @override
  String get einstResetWort => 'RESET';

  @override
  String get einstResetEndgueltig => 'Reset for good';

  @override
  String get einstResetLaeuft => 'Deleting the library …';

  @override
  String get einstResetFertig =>
      'The library has been deleted completely. The app is closing now – please open it again to start with an empty library.';

  @override
  String get einstResetFehlgeschlagen => 'Reset failed';

  @override
  String get einstUeberTitel => 'About this app';

  @override
  String get einstKeineModelle => 'No AI models downloaded';

  @override
  String einstModelleGeladen(int geladen, int gesamt) {
    return '$geladen of $gesamt AI models downloaded';
  }

  @override
  String get einstModelleUnbenutzt =>
      'The AI features stay unused without them.';

  @override
  String get einstAktualisierungHinweis =>
      'The check asks the public release list once for the latest version number. Nothing about your library is sent, and it happens only when you press this button – never on its own.';

  @override
  String einstAktualisierungNeuer(String version) {
    return 'A newer version is available: $version';
  }

  @override
  String get einstAktualisierungAktuell => 'This version is up to date.';

  @override
  String einstAktualisierungFehler(String fehler) {
    return 'Check failed: $fehler';
  }

  @override
  String get einstVerschiebenFehlgeschlagen => 'Moving failed';

  @override
  String get einstWechselnFehlgeschlagen => 'Switching failed';

  @override
  String get einstNeustartTitel => 'Restart required';

  @override
  String get einstUebersetzeBeschreibungTitel =>
      'Translate image descriptions into the interface language';

  @override
  String get einstUebersetzeBeschreibungText =>
      'The description model only produces English, and there is no comparably small German one. With the “Translation English → German” model downloaded, every new description is translated as well. The English original is kept, and search finds both.';

  @override
  String get einstUebersetzeSucheTitel => 'Translate search terms and tags';

  @override
  String get einstUebersetzeSucheText =>
      'The text side of the image search model only understands English, while the tag vocabulary is German. Switched on, search terms and vocabulary go through the translation first. Measured across 103 photos it is more precise for 33 of 56 terms and worse for 19 – and it assigns noticeably fewer tags. Worth trying, not worth defaulting to.';

  @override
  String get allgEntfernen => 'Remove';

  @override
  String get allgEinrichten => 'Set up';

  @override
  String get allgHerunterladen => 'Download';

  @override
  String get allgAktiv => 'On';

  @override
  String get einstAbschnittErscheinungsbild => 'Appearance';

  @override
  String get einstAbschnittModelle => 'AI models (local & open source)';

  @override
  String get einstAbschnittHintergrund => 'Background tasks';

  @override
  String get einstAbschnittVokabular => 'AI tagging vocabulary';

  @override
  String get einstAbschnittStandortdaten =>
      'Location data (local & open source)';

  @override
  String get einstAbschnittGesperrterOrdner => 'Locked folder';

  @override
  String get einstAbschnittManuellesBackup => 'Manual cloud backup';

  @override
  String get einstAbschnittAutoBackup => 'Automatic backup';

  @override
  String get einstAbschnittPapierkorb => 'Empty trash automatically';

  @override
  String get einstAbschnittGefahrenzone => 'Danger zone';

  @override
  String get einstDesign => 'Theme';

  @override
  String get einstDesignHell => 'Light';

  @override
  String get einstDesignDunkel => 'Dark';

  @override
  String get einstDesignSystem => 'System';

  @override
  String get einstUeberwachtNichtsNeues => 'Folder set up – nothing new found.';

  @override
  String get einstBibWechselnAktion => 'Switch';

  @override
  String get einstBibWechselnLaeuft => 'Switching library …';

  @override
  String get einstBibAktiv => 'open';

  @override
  String get einstBibImmerVorhanden => 'always present';

  @override
  String get einstSpeicherort => 'Storage location';

  @override
  String get einstSpeicherortVerschiebenLaeuft => 'Moving library …';

  @override
  String get einstSpeicherbedarf => 'Space used (originals)';

  @override
  String einstModellLaedt(String titel) {
    return 'Downloading “$titel” …';
  }

  @override
  String einstModelleBelegterPlatz(String groesse) {
    return 'Space used by all models: $groesse';
  }

  @override
  String einstModellLizenzZeile(String lizenz) {
    return 'Licence: $lizenz';
  }

  @override
  String get einstGesichtserkennungAktiv => 'Face detection active';

  @override
  String get einstGesichtserkennungBeides =>
      'Detection + recognition embeddings active';

  @override
  String get einstGesichtserkennungInaktiv =>
      'Inactive – download the YuNet model above';

  @override
  String get einstGeoLaedt => 'Downloading location data …';

  @override
  String get einstPinEinrichten => 'Set up a PIN';

  @override
  String get einstGesperrterOrdner => 'Locked folder';

  @override
  String get einstPinEingerichtet => 'PIN is set.';

  @override
  String get einstPinEntfernen => 'Remove PIN';

  @override
  String get einstGesperrtAufloesenTitel => 'Remove PIN protection?';

  @override
  String get einstSitzungSperren => 'Lock this session now';

  @override
  String get einstPassphraseEinrichten => 'Set up a passphrase';

  @override
  String get einstBackupPassphrase => 'Backup passphrase';

  @override
  String get einstBackupPassphraseEingeben => 'Enter the backup passphrase';

  @override
  String get einstBackupSichertLaeuft => 'Backing up the library …';

  @override
  String get einstBackupWiederherstellenLaeuft => 'Restoring the library …';

  @override
  String get einstLetztesBackup => 'Last backup';

  @override
  String einstBackupZusammenfassung(String datum, int anzahl, String ziel) {
    return '$datum – $anzahl file(s) to $ziel';
  }

  @override
  String get einstJetztSichern => 'Back up now';

  @override
  String get einstWiederherstellen => 'Restore';

  @override
  String get einstZielordner => 'Destination folder';

  @override
  String get einstIntervall => 'Interval';

  @override
  String get einstIntervallSechsStunden => 'Every 6 hours';

  @override
  String get einstMengeJeLauf => 'Amount per run';

  @override
  String get einstUnbegrenzt => 'Unlimited';

  @override
  String get einstLetzterLauf => 'Last run';

  @override
  String get einstJetztSynchronisieren => 'Synchronise now';

  @override
  String get einstNachTagen => 'After';

  @override
  String einstTageDropdown(int tage) {
    return '$tage days';
  }

  @override
  String get einstDatenbank => 'Database';

  @override
  String einstDatenbankStand(int version) {
    return 'Version $version';
  }

  @override
  String einstBauZeile(String bau, String system, String systemversion) {
    return 'Build $bau · $system $systemversion';
  }

  @override
  String get einstNachAktualisierungSuchen => 'Check for updates';

  @override
  String get modellYunetTitel => 'Face detection – YuNet';

  @override
  String get modellYunetText =>
      'Finds faces (bounding boxes) in photos. A lightweight CNN, part of the OpenCV Zoo.';

  @override
  String get modellYunetLizenz => 'Apache-2.0';

  @override
  String get modellSfaceTitel => 'Face recognition – SFace';

  @override
  String get modellSfaceText =>
      'Computes one embedding per face so that similar or identical faces group together while you assign them by hand. Part of the OpenCV Zoo.';

  @override
  String get modellSfaceLizenz => 'Apache-2.0';

  @override
  String get modellClipTitel => 'AI image search – CLIP ViT-B/32';

  @override
  String get modellClipText =>
      'Lets you search for photos in plain language (for example “sunset over the sea”). Original OpenAI weights, exported as separate image and text encoder ONNX graphs.';

  @override
  String get modellClipLizenz => 'MIT (weights: OpenAI CLIP, see source)';

  @override
  String get modellSamTitel => 'AI object masks – SAM ViT-Base';

  @override
  String get modellSamText =>
      'Lets you adjust one chosen area instead of the whole picture in the develop screen – brightening only the sky, say. You place foreground and background points, and a promptable segmentation model proposes the matching mask.';

  @override
  String get modellSamLizenz =>
      'Apache-2.0 (weights: Meta Segment Anything, see source)';

  @override
  String get modellCaptionTitel => 'AI image captions – Florence-2 (English)';

  @override
  String get modellCaptionText =>
      'Generates a caption for each photo – for search and as a quick overview. It also reads text in the image, such as shop signs or place names. Output is English; the app can translate it into your language with a separate model. There is no comparably small multilingual model – the multilingual ones are gigabytes in size.';

  @override
  String get modellCaptionLizenz =>
      'MIT (base: microsoft/Florence-2-base-ft, ONNX port: onnx-community)';

  @override
  String get modellOcecTitel => 'Closed-eye detection – OCEC';

  @override
  String get modellOcecText =>
      'Marks faces with closed eyes while you cull – a quicker way to weed out blinks from portrait and group series.';

  @override
  String get modellOcecLizenz => 'MIT';

  @override
  String get modellEsrganTitel => 'AI restoration – Real-ESRGAN x4';

  @override
  String get modellEsrganText =>
      'Scales a photo up by a factor of four and removes noise along the way. Runs as a background queue (Settings/Develop) and takes several minutes depending on the size of the photo.';

  @override
  String get modellEsrganLizenz =>
      'BSD-3-Clause (original Real-ESRGAN weights)';

  @override
  String get modellEnDeTitel => 'Translation English → German – OPUS-MT';

  @override
  String get modellEnDeText =>
      'Translates the automatically generated captions into German. The captioning model itself only produces English, so without this you have to search in English for what you see in German. About 100 MB.';

  @override
  String get modellEnDeLizenz =>
      'Apache-2.0 (base: Helsinki-NLP/opus-mt-en-de, ONNX port: Xenova)';

  @override
  String get modellDeEnTitel => 'Translation German → English – OPUS-MT';

  @override
  String get modellDeEnText =>
      'Translates German search terms and tags before they reach the AI image search, whose text encoder only understands English. About 100 MB.';

  @override
  String get modellDeEnLizenz =>
      'Apache-2.0 (base: Helsinki-NLP/opus-mt-de-en, ONNX port: Xenova)';

  @override
  String get werkzKeineUnbewerteten => 'No unrated photos found.';

  @override
  String get werkzYunetNoetig =>
      'This needs the YuNet model first (Settings → AI models).';

  @override
  String get werkzClipNoetig =>
      'This needs the CLIP model first (Settings → AI models).';

  @override
  String get werkzBeschreibungsmodellNoetig =>
      'This needs the image captioning model first (Settings → AI models).';

  @override
  String get werkzGeoNoetig =>
      'This needs the GeoNames dataset first (Settings → Location data).';

  @override
  String get werkzKeinePassenden => 'No matching photos found.';

  @override
  String get werkzGesichterScannenTitel => 'Scan for faces';

  @override
  String get werkzGesichterScannenFrage =>
      'New photos only: quick, and skips photos that have already been scanned.\n\nScan all photos again: goes through the whole library afresh – worth doing after an update to face detection, for instance, or to work out closed-eye detection for photos scanned earlier. On a large library it takes correspondingly longer. Faces you assigned by hand are kept.';

  @override
  String get werkzNurNeueFotos => 'New photos only';

  @override
  String get werkzAlleErneutScannen => 'Scan all again';

  @override
  String get werkzScanneNeue => 'Scanning new photos …';

  @override
  String get werkzScanneAlle => 'Scanning all photos again …';

  @override
  String get werkzVorschauNeuTitel => 'Rebuild previews';

  @override
  String get werkzVorschauNeuFrage =>
      'Missing only: handles just those photos and videos that currently have no thumbnail – HEIC photos imported before native image conversion was set up, say, or videos imported before video thumbnails existed.\n\nRebuild all: creates new thumbnails and previews for the whole library, which is worth doing after an update to image or video conversion. On a large library it takes correspondingly longer.';

  @override
  String get werkzNurFehlende => 'Missing only';

  @override
  String get werkzAlleNeuErstellen => 'Rebuild all';

  @override
  String get werkzErstelleFehlende => 'Creating the missing previews …';

  @override
  String get werkzErstelleAlle => 'Rebuilding all previews …';

  @override
  String get werkzRendereNeu => 'Re-rendering developed photos …';

  @override
  String get werkzKeineEntwickelten => 'No developed photos found.';

  @override
  String get werkzPruefeLivePhotos => 'Looking for Live Photo pairs …';

  @override
  String get werkzKeineUnverknuepften => 'No unlinked photos found.';

  @override
  String get werkzBerechneEmbeddings => 'Computing CLIP embeddings …';

  @override
  String get werkzAlleHabenEmbedding => 'Every photo already has an embedding.';

  @override
  String get werkzKiTagsTitel => 'Compute AI tags';

  @override
  String get werkzKiTagsFrage =>
      'Untagged photos only: quick, and skips photos that already carry at least one tag, whether set by hand or automatically.\n\nAll photos: goes through the whole library afresh and adds fitting AI tags to already tagged photos as well. Existing tags are kept.';

  @override
  String get werkzNurUngetaggte => 'Untagged only';

  @override
  String get werkzAlleFotos => 'All photos';

  @override
  String get werkzBerechneKiTags => 'Computing AI tags …';

  @override
  String get werkzLeseOrte => 'Reading locations from photos …';

  @override
  String get werkzAlleHabenOrt =>
      'Every photo already has a location (or no EXIF GPS data).';

  @override
  String get werkzLoeseOrteAuf => 'Resolving country/region/city …';

  @override
  String get werkzAlleAufgeloest =>
      'Every photo with a known location has already been resolved.';

  @override
  String get werkzLeseKameradaten => 'Reading camera data from photos …';

  @override
  String get werkzAlleHabenKameradaten =>
      'Every photo already has camera data (or no matching EXIF data).';

  @override
  String get werkzSchreibeXmp => 'Writing XMP sidecars …';

  @override
  String get werkzKeineFotosGesperrt =>
      'No photos found (locked photos are skipped).';

  @override
  String get werkzErkenneText => 'Recognising text in photos …';

  @override
  String get werkzAlleTextDurchsucht =>
      'Every photo has already been searched for text.';

  @override
  String get werkzErzeugeBeschreibungen => 'Generating image captions …';

  @override
  String get werkzAlleHabenBeschreibung =>
      'Every photo already has an AI caption.';

  @override
  String get werkzBerechneUnschaerfe => 'Computing blur scores …';

  @override
  String get werkzAlleHabenUnschaerfe =>
      'A blur score has already been computed for every photo.';

  @override
  String get werkzAbschnittStatistik => 'Statistics';

  @override
  String get werkzAnalyseseiteTitel => 'Analysis page';

  @override
  String get werkzAnalyseseiteText =>
      'Number of photos and videos, disk space, shots per year and month, most-used cameras';

  @override
  String get werkzAbschnittGesichtserkennung => 'Face detection';

  @override
  String get werkzGesichterScannenUntertitel =>
      'Run it by hand – new photos or all of them';

  @override
  String get werkzSchwelleLabel =>
      'Similarity threshold for\n\"Select similar as well\"';

  @override
  String get werkzSchwelleErklaerung =>
      'Higher values mean a stricter match: fewer hits, but safer ones. It applies to the \"Select similar as well\" button under \"Unnamed faces\" in the People tab.';

  @override
  String get werkzAbschnittVorschau => 'Previews';

  @override
  String get werkzHeicTitel => 'HEIC/HEIF & RAW support';

  @override
  String get werkzHeicAktiv =>
      'Active – iPhone photos (HEIC) and RAW files (DNG, CR2/CR3, NEF, ARW, RAF, ORF, RW2 and the rest) go through native macOS image conversion.';

  @override
  String get werkzHeicInaktiv =>
      'Inactive – the native Swift file still has to be added to the Xcode project (see the README). JPG/PNG/WebP/GIF/BMP/TIFF work without it.';

  @override
  String get werkzHeicWerkzeugeAktiv =>
      'Active – iPhone photos (HEIC) and RAW files (DNG, CR2/CR3, NEF, ARW, RAF, ORF, RW2 and the rest) go through the bundled tools.';

  @override
  String werkzHeicWerkzeugeFehlen(String namen) {
    return 'Limited – missing: $namen. The formats that depend on them stay without a preview; JPG/PNG/WebP/GIF/BMP/TIFF keep working.';
  }

  @override
  String get werkzVorschauNeuUntertitel =>
      'For every photo, or only for the ones still missing';

  @override
  String get werkzAbschnittEntwicklung => 'Develop';

  @override
  String get werkzNeuRendernTitel => 'Re-render developed photos';

  @override
  String get werkzNeuRendernText =>
      'Renders every photo that has saved develop adjustments (exposure, white balance and the rest) again with those settings unchanged – worth doing after an update to the native image processing.';

  @override
  String get werkzAbschnittLivePhotos => 'Live Photos';

  @override
  String get werkzLivePhotoTitel => 'Check for Live Photo pairs again';

  @override
  String get werkzLivePhotoText =>
      'For photos and videos imported before this feature existed – links HEIC/JPG stills with MOV videos of the same name.';

  @override
  String get werkzAbschnittOrte => 'Locations';

  @override
  String get werkzOrteEinlesenTitel => 'Read locations from photos';

  @override
  String get werkzOrteEinlesenText =>
      'For photos imported before the map view existed – reads their EXIF GPS data after the fact.';

  @override
  String get werkzOrteAufloesenTitel => 'Resolve country/region/city';

  @override
  String get werkzOrteAufloesenText =>
      'Works out the country, state or province and city behind a photo\'s GPS position – entirely local and offline, from the GeoNames dataset (see Settings → Location data). The country, region and city filters in the search options need this.';

  @override
  String get werkzAbschnittKamera => 'Camera';

  @override
  String get werkzKameradatenTitel => 'Read camera data from photos';

  @override
  String get werkzKameradatenText =>
      'For photos imported before the camera display existed – reads camera, lens, focal length, aperture, ISO and shutter speed from the EXIF data after the fact.';

  @override
  String get werkzPresetsTitel => 'Manage camera presets';

  @override
  String get werkzPresetsText =>
      'Automatically put photos from a particular camera into an album or tag, or mark them as favourites, as they are imported – digiKam\'s \"preset the camera for import\" by another name.';

  @override
  String get werkzRegelnTitel => 'Manage automation rules';

  @override
  String get werkzRegelnText =>
      'Automatically put photos into an album or tag, or mark them as favourites, based on location, AI tag or capture date – like camera presets, but for other conditions.';

  @override
  String get werkzAbschnittQualitaet => 'Photo quality';

  @override
  String get werkzOcrTitel => 'Recognise text in photos';

  @override
  String get werkzOcrText =>
      'For photos imported before text search existed – finds visible text such as signs or documents after the fact, entirely locally through Apple\'s Vision framework.';

  @override
  String get werkzBeschreibungenTitel => 'Generate image captions';

  @override
  String get werkzBeschreibungenText =>
      'For photos imported before the captioning model was installed – writes one short English caption per photo, entirely locally.';

  @override
  String get werkzUnschaerfeTitel => 'Recompute blur';

  @override
  String get werkzUnschaerfeText =>
      'For photos imported before blur detection existed – this is what the \"Show blurry photos only\" search filter needs.';

  @override
  String get werkzAbschnittBildsuche => 'AI image search';

  @override
  String get werkzAllesNachholenTitel => 'Catch up on all analysis now';

  @override
  String get werkzAllesNachholenText =>
      'Starts every expensive step one after another in the background: blur, faces, text recognition, image search, tags and captions. Each step skips what it already has, and the app stays usable throughout.';

  @override
  String get werkzAnalyseGestartet =>
      'Analysis is running in the background – progress is shown in the bar at the top.';

  @override
  String get werkzEmbeddingsTitel => 'Compute CLIP embeddings';

  @override
  String get werkzEmbeddingsText =>
      'For photos imported before the CLIP model was installed – without an embedding they show up in neither the AI image search nor the duplicate search.';

  @override
  String get werkzEmbeddingsFrage =>
      'Missing only: for photos imported before the CLIP model was installed.\n\nAll photos: recomputes existing ones too. Needed after a change to image preprocessing – since version 1.4 a photo is centre-cropped instead of squashed, and older vectors still come from the squashed image. Until this is done, search and tagging work to two different standards.';

  @override
  String get werkzKiTagsKarteText =>
      'Automatically assigns photos fitting tags from a fixed list of terms – \"child\", \"outdoors\", \"birthday\" and so on – using the CLIP model, with no extra download. You can change the tags at any time in a photo\'s info view.';

  @override
  String get werkzAbschnittBibliothek => 'Library';

  @override
  String get werkzSichtenTitel => 'Cull unrated photos';

  @override
  String get werkzSichtenText =>
      'Opens every photo and video that is still unrated in full-screen culling mode, for going through and rating them quickly.';

  @override
  String get werkzDuplikateTitel => 'Find duplicates & similar photos';

  @override
  String get werkzDuplikateText => 'Based on the CLIP image embeddings';

  @override
  String get werkzStapelTitel => 'Group burst shots';

  @override
  String get werkzStapelText =>
      'Finds similar photos taken close together in time – burst shots, typically – and, if you want, collapses them into one stack with a cover image.';

  @override
  String get werkzIntegritaetTitel => 'Library integrity check';

  @override
  String get werkzIntegritaetText =>
      'Compares the database against the files actually on disk: missing files, orphaned files and, if you like, checksum mismatches.';

  @override
  String get werkzAbschnittInterop => 'Interoperability';

  @override
  String get werkzXmpSchreibenTitel => 'Write XMP sidecars';

  @override
  String get werkzXmpSchreibenText =>
      'Puts an .xmp file next to every photo holding its rating, colour label, description, tags and camera data – for Lightroom, darktable or digiKam. Locked photos are skipped. This also happens automatically on export and in unencrypted backups.';

  @override
  String get werkzXmpLesenTitel => 'Read XMP sidecars';

  @override
  String get werkzXmpLesenText =>
      'Reads existing .xmp files – edited externally in Lightroom, darktable or digiKam, say – and shows where they differ from the database: rating, colour label, description, tags, location.';

  @override
  String sichtungHilfeleiste(int aktuell, int gesamt) {
    return '$aktuell / $gesamt   ·   0–5 rating   ·   ⌫ reject   ·   ← → next';
  }

  @override
  String get ansicht360 => '360° view';

  @override
  String personenZuordnenKnopf(int anzahl) {
    return 'Assign $anzahl';
  }

  @override
  String get aufgStatus => 'Status';

  @override
  String get aufgBereit => 'Ready';

  @override
  String get aufgLaeuft => 'Analysis is running in the background.';

  @override
  String get aufgJetztStarten => 'Start now';

  @override
  String get aufgWartend => 'Waiting';

  @override
  String get aufgBetrifft => 'Affects';

  @override
  String aufgStufe(
      String stufe, int erledigt, int gesamt, int nummer, int stufenGesamt) {
    return '$stufe ($erledigt/$gesamt) – step $nummer of $stufenGesamt';
  }

  @override
  String aufgModellNoetig(String modell, String wo) {
    return 'This needs $modell first ($wo).';
  }

  @override
  String get aufgYunetModell => 'the YuNet model';

  @override
  String get aufgClipModell => 'the CLIP model';

  @override
  String get aufgBeschreibungsmodell => 'the image captioning model';

  @override
  String get aufgGeoDatensatz => 'the GeoNames dataset';

  @override
  String get aufgWoModelle => 'Settings → AI models';

  @override
  String get aufgWoStandortdaten => 'Settings → Location data';

  @override
  String get aufgGesichterText =>
      'Finds faces and assigns them, as long as the YuNet model is installed.';

  @override
  String get aufgNeueFotos => 'New photos';

  @override
  String get aufgAlleErneut => 'All again';

  @override
  String get aufgVorschauText =>
      'Creates thumbnails and previews for photos and videos.';

  @override
  String get aufgFehlende => 'Missing';

  @override
  String get aufgAlleNeu => 'All anew';

  @override
  String get aufgOcrTitel => 'Recognise text (OCR)';

  @override
  String get aufgOcrText =>
      'Finds visible text in photos, entirely locally through Apple\'s Vision framework.';

  @override
  String get aufgStarten => 'Start';

  @override
  String get aufgBeschreibungenTitel => 'Image captions';

  @override
  String get aufgBeschreibungenText =>
      'Writes one short English AI caption per photo.';

  @override
  String get aufgEmbeddingsTitel => 'CLIP embeddings';

  @override
  String get aufgEmbeddingsText =>
      'The basis for AI image search and duplicate detection.';

  @override
  String get aufgKiTagsTitel => 'AI tags';

  @override
  String get aufgKiTagsText =>
      'Automatically assigns photos fitting tags from the vocabulary, using CLIP.';

  @override
  String get aufgUngetaggte => 'Untagged';

  @override
  String get aufgUnschaerfeTitel => 'Blur';

  @override
  String get aufgUnschaerfeText =>
      'What the \"Show blurry photos only\" search filter needs.';

  @override
  String get aufgOrteTitel => 'Read locations';

  @override
  String get aufgOrteText => 'Reads EXIF GPS data from photos after the fact.';

  @override
  String get aufgOrteAufloesenText =>
      'Works out the country, state or province and city behind a photo\'s GPS position.';

  @override
  String get aufgKameraTitel => 'Read camera data';

  @override
  String get aufgKameraText =>
      'Reads camera, lens, focal length, aperture, ISO and shutter speed from EXIF.';

  @override
  String get aufgLivePhotoTitel => 'Check Live Photo pairs';

  @override
  String get aufgLivePhotoText =>
      'Links HEIC/JPG stills with MOV videos of the same name.';

  @override
  String get aufgRendernText =>
      'Renders photos with saved develop adjustments again, unchanged.';

  @override
  String get aufgXmpText =>
      'Puts an .xmp file next to every photo for Lightroom, darktable or digiKam.';

  @override
  String get auswAufheben => 'Clear selection';

  @override
  String auswAnzahl(int anzahl) {
    return '$anzahl selected';
  }

  @override
  String get auswFavorisieren => 'Mark as favourite';

  @override
  String get auswZuAlbum => 'Add to album';

  @override
  String get auswTagHinzufuegen => 'Add a tag';

  @override
  String get auswBewertungSetzen => 'Set rating';

  @override
  String get auswFarbeSetzen => 'Set colour label';

  @override
  String get auswMetadaten => 'Edit metadata';

  @override
  String get auswEntwicklungUebertragen => 'Paste copied develop settings';

  @override
  String get auswExportieren => 'Export';

  @override
  String get allgLoeschen => 'Delete';

  @override
  String get allgHinzufuegen => 'Add';

  @override
  String get allgWaehlen => 'Choose';

  @override
  String auswBewertungTitel(int anzahl) {
    return 'Rating for $anzahl photo(s)';
  }

  @override
  String get auswKeineBewertung => 'No rating';

  @override
  String auswFarbeTitel(int anzahl) {
    return 'Colour label for $anzahl photo(s)';
  }

  @override
  String get auswKeineFarbe => 'No colour';

  @override
  String auswMetadatenTitel(int anzahl) {
    return 'Edit metadata for $anzahl photo(s)';
  }

  @override
  String get auswBeschreibungFeld => 'Description (overwrites existing ones)';

  @override
  String get auswDatumUnveraendert => 'Leave the date unchanged';

  @override
  String auswDatumGesetzt(String datum) {
    return 'Date: $datum';
  }

  @override
  String get auswOrtHinweis => 'Location (to leave it unchanged, do not tap)';

  @override
  String auswTagTitel(int anzahl) {
    return 'Add a tag to $anzahl photo(s)';
  }

  @override
  String get auswTagFeld => 'Tag';

  @override
  String auswExportTitel(int anzahl) {
    return 'Export $anzahl photo(s)';
  }

  @override
  String get auswVorgabeAnwenden => 'Apply preset';

  @override
  String auswVorgabeAnwendenTitel(int anzahl) {
    return 'Apply preset to $anzahl photo(s)';
  }

  @override
  String auswUebertragenTitel(int anzahl) {
    return 'Paste develop settings onto $anzahl photo(s)?';
  }

  @override
  String get auswUebertragenText =>
      'The copied values for exposure, white balance, contrast and shadows are applied, and each photo is re-rendered.\n\nMasks are not carried over. Each photo\'s previous state stays in its history.';

  @override
  String get auswUebertragen => 'Paste';

  @override
  String get auswUebertrageLaeuft => 'Pasting develop settings …';

  @override
  String get auswKeineGeeigneten =>
      'No suitable photos – locked photos and videos are left out.';

  @override
  String auswZielordner(int anzahl) {
    return 'Choose a destination folder for $anzahl photo(s)';
  }

  @override
  String auswExportiereLaeuft(int erledigt, int gesamt) {
    return 'Exporting … ($erledigt / $gesamt)';
  }

  @override
  String auswExportFertig(int erledigt, int gesamt, String ziel) {
    return 'Exported $erledigt of $gesamt photo(s) to $ziel';
  }

  @override
  String get exportOriginal => 'Original';

  @override
  String get exportGross => 'Large – 4096 px';

  @override
  String get exportWeb => 'Web – 2048 px';

  @override
  String get exportEmail => 'E-mail – 1024 px';

  @override
  String get exportUnveraendert => 'File unchanged, with an XMP file alongside';

  @override
  String exportJpegKante(int kante) {
    return 'As JPEG, long edge at most $kante px';
  }

  @override
  String get allgUebernehmen => 'Apply';

  @override
  String get allgAlle => 'All';

  @override
  String get suchoptTagsWaehlen => 'Choose tags';

  @override
  String get suchoptTagsFiltern => 'Filter tags …';

  @override
  String get suchoptKeineTags => 'No tags found.';

  @override
  String get suchoptTitel => 'Search options';

  @override
  String get suchoptKeineTreffer =>
      'No photos found – this combination of filters returns 0 results.';

  @override
  String get suchoptAllesLeeren => 'Clear everything';

  @override
  String get suchoptSuchen => 'Search';

  @override
  String get suchoptPersonenFiltern => 'Filter people';

  @override
  String get suchoptKeinePersonenBenannt => 'No one has been named yet.';

  @override
  String get suchoptKeinePersonenGefunden => 'No people found.';

  @override
  String get suchoptTypTitel => 'Search by type';

  @override
  String get suchoptTypKontext => 'Context';

  @override
  String get suchoptTypDateiname => 'File name';

  @override
  String get suchoptTypBeschreibung => 'Description';

  @override
  String get suchoptTypOcr => 'Text in the photo (OCR)';

  @override
  String get suchoptTypCaption => 'AI caption (English)';

  @override
  String get suchoptNachKontext => 'Search by context';

  @override
  String get suchoptNachDateiname => 'Search by file name';

  @override
  String get suchoptNachBeschreibung => 'Search by description';

  @override
  String get suchoptNachOcr => 'Search text recognised in the photo';

  @override
  String get suchoptNachCaption => 'Search by AI caption (English)';

  @override
  String get suchoptHintKontext =>
      'e.g. \"sunrise on the beach\", \"dog in the snow\" …';

  @override
  String get suchoptHintDateiname => 'File name …';

  @override
  String get suchoptHintBeschreibung => 'Description …';

  @override
  String get suchoptHintOcr => 'Text in the photo …';

  @override
  String get suchoptHintCaption => 'e.g. \"dog\", \"sunset\" …';

  @override
  String get suchoptClipFehlt =>
      'AI image search is unavailable – the model is missing (see Settings → AI models).';

  @override
  String get suchoptCaptionFehlt =>
      'AI captions are unavailable – the model is missing (see Settings → AI models).';

  @override
  String get suchoptTagsTitel => 'Tags';

  @override
  String get suchoptTagsHint => 'Search for tags …';

  @override
  String get suchoptOhneTag => 'Without a tag';

  @override
  String get suchoptMindestbewertung => 'Minimum rating';

  @override
  String get suchoptFarbmarkierung => 'Colour label';

  @override
  String get farbeRot => 'Red';

  @override
  String get farbeGelb => 'Yellow';

  @override
  String get farbeGruen => 'Green';

  @override
  String get farbeBlau => 'Blue';

  @override
  String get farbeLila => 'Purple';

  @override
  String get suchoptAufnahmewerte => 'Capture settings';

  @override
  String get suchoptIsoVon => 'ISO from';

  @override
  String get suchoptIsoBis => 'ISO to';

  @override
  String get suchoptBlendeVon => 'Aperture from (f/…)';

  @override
  String get suchoptBlendeBis => 'Aperture to (f/…)';

  @override
  String get suchoptBrennweiteVon => 'Focal length from (mm)';

  @override
  String get suchoptBrennweiteBis => 'Focal length to (mm)';

  @override
  String get suchoptNurUnscharfe => 'Show blurry photos only';

  @override
  String get suchoptMarke => 'Make';

  @override
  String get suchoptModell => 'Model';

  @override
  String get suchoptObjektiv => 'Lens';

  @override
  String get suchoptOrtTitel => 'Location';

  @override
  String get suchoptLand => 'Country';

  @override
  String get suchoptBundesland => 'State/province';

  @override
  String get suchoptStadt => 'City';

  @override
  String get suchoptGeoFehlt =>
      'No locations resolved yet – download the GeoNames dataset and resolve your photos (see Settings → Location data, Tools → Locations).';

  @override
  String get suchoptAnfangsdatum => 'Start date';

  @override
  String get suchoptEnddatum => 'End date';

  @override
  String get suchoptDatumEntfernen => 'Clear the date';

  @override
  String get suchoptDatumPlatzhalter => 'dd/mm/yyyy';

  @override
  String get suchoptMedientyp => 'Media type';

  @override
  String get suchoptBild => 'Image';

  @override
  String get suchoptVideo => 'Video';

  @override
  String get suchoptAnzeigeoptionen => 'Display options';

  @override
  String get suchoptInKeinemAlbum => 'In no album';

  @override
  String get suchoptFavoriten => 'Favourites';

  @override
  String get entwTitel => 'Develop';

  @override
  String get entwKeinVerlauf =>
      'No history yet – an entry appears once you save again after a first adjustment.';

  @override
  String get entwKopiert =>
      'Settings copied. You can now paste them onto other photos, even without saving this one.';

  @override
  String get entwEingesetzt => 'Copied settings applied – not saved yet.';

  @override
  String get entwSpeichernFehlgeschlagen =>
      'Saving failed: the image could not be rendered.';

  @override
  String get entwRestaurierungEingereiht =>
      'Added to the AI restoration queue.';

  @override
  String entwRestaurierungFehler(String fehler) {
    return 'Could not be added to the queue: $fehler';
  }

  @override
  String entwKiAuswahlLadefehler(String fehler) {
    return 'AI selection could not be loaded: $fehler';
  }

  @override
  String get entwVorschauNichtDekodiert =>
      'The preview image could not be decoded for masking.';

  @override
  String entwKiAuswahlFehler(String fehler) {
    return 'AI selection failed: $fehler';
  }

  @override
  String entwMaskeNummer(int nummer) {
    return 'Mask $nummer';
  }

  @override
  String get entwAufloesungUnbekannt =>
      'Image resolution unknown – the mask cannot be saved.';

  @override
  String get entwRestaurierungEntfernen => 'Remove AI restoration';

  @override
  String get entwRestaurierungModellFehlt =>
      'Needs the restoration model (Settings → AI models)';

  @override
  String get entwRestaurierungAnwenden =>
      'Apply AI restoration (runs in the background, takes several minutes)';

  @override
  String get entwMaskeHinzufuegen => 'Add a mask';

  @override
  String get entwVerlauf => 'History';

  @override
  String get entwEinstellungenKopieren =>
      'Copy settings (to paste onto other photos)';

  @override
  String get entwEinstellungenEinsetzen =>
      'Put the copied settings into the sliders';

  @override
  String get entwOriginal => 'Original';

  @override
  String get entwVergleichen => 'Press and hold to compare';

  @override
  String get entwMaskeErstellen => 'Create a mask';

  @override
  String get entwFormKi => 'AI';

  @override
  String get entwFormPinsel => 'Brush';

  @override
  String get entwFormEllipse => 'Ellipse';

  @override
  String get entwFormVerlauf => 'Gradient';

  @override
  String get allgFertig => 'Done';

  @override
  String get entwKiHinweis =>
      'Tap the area you want to adjust. Several taps refine the selection.';

  @override
  String get entwPunktHinzufuegen => 'Add';

  @override
  String get entwPunktEntfernen => 'Remove';

  @override
  String get entwLetztenPunktEntfernen => 'Remove the last point';

  @override
  String get entwPinselHinweis => 'Drag across the area you want to adjust.';

  @override
  String get entwNeuZeichnen => 'Draw again';

  @override
  String get entwEllipseHinweis =>
      'Drag across the area to pull open the ellipse.';

  @override
  String get entwVerlaufHinweis =>
      'Drag from one edge to the other to set the gradient.';

  @override
  String get entwAnpassungFuer => 'Adjusting';

  @override
  String get entwGanzesBild => 'The whole image';

  @override
  String get entwFormBearbeiten => 'Edit the shape';

  @override
  String get entwAutoWeissabgleich => 'Automatic white balance';

  @override
  String get entwObjektivkorrektur => 'Lens correction';

  @override
  String get entwObjektivkorrekturHinweis =>
      'Only takes effect on RAW photos whose camera and lens are supported.';

  @override
  String get entwMaskenHinweis =>
      'These adjustments apply only inside the selected mask.';

  @override
  String get entwBelichtung => 'Exposure';

  @override
  String get entwTemperatur => 'Temperature (K)';

  @override
  String get entwTint => 'Tint';

  @override
  String get entwKontrast => 'Contrast';

  @override
  String get entwBeschneidungWarnung =>
      'Show clipping (red = blown, blue = crushed)';

  @override
  String get entwBeschneidungMitMasken =>
      'Clipping cannot be shown while masks are on the photo – the marks come from the shader preview, and it cannot draw masks.';

  @override
  String get entwBeschneidungVorschauHinweis =>
      'Clipping preview – sharpness, noise, clarity and vignette are not shown here';

  @override
  String get entwVorgabeSichern => 'Save as preset';

  @override
  String get entwVorgabeAnwenden => 'Apply preset';

  @override
  String get entwVorgabeWaehlen => 'Choose a preset';

  @override
  String get entwVorgabeName => 'Preset name';

  @override
  String get entwKeineVorgaben => 'There is no develop preset yet.';

  @override
  String entwVorgabeGesichert(String name) {
    return 'Preset “$name” saved';
  }

  @override
  String entwVorgabeNameVergeben(String name) {
    return 'A preset named “$name” already exists.';
  }

  @override
  String get entwAutomatisch => 'Auto exposure and contrast';

  @override
  String get entwAutomatikOhneHistogramm => 'No histogram yet – one moment.';

  @override
  String get entwTiefenmaske => 'Mask from depth map';

  @override
  String get entwTiefenmaskeName => 'Depth';

  @override
  String get entwTiefenKeine =>
      'This photo carries no depth map. Only portrait shots from newer iPhones do.';

  @override
  String get entwTiefenNichtLesbar => 'The depth map could not be evaluated.';

  @override
  String get entwTiefenNurMacos =>
      'This photo may carry a depth map – only the macOS build can read it. There the depth data comes from Apple\'s ImageIO; on Linux and Windows the path runs through LibRaw and libheif, which do not expose the auxiliary image.';

  @override
  String get entwLichter => 'Highlights';

  @override
  String get entwSchatten => 'Shadows';

  @override
  String get entwSchaerfe => 'Sharpness';

  @override
  String get entwRauschunterdrueckung => 'Noise reduction';

  @override
  String get entwStrichbreite => 'Stroke width';

  @override
  String get entwRotation => 'Rotation (°)';

  @override
  String get entwWeichzeichnung => 'Feather';

  @override
  String get entwGesperrt =>
      'Develop is not available for photos in the locked folder.';

  @override
  String get entwVorschauFehlt =>
      'The preview could not be created – is native image conversion unavailable?';

  @override
  String get entwModellLaedt => 'Loading the model for AI selection …';

  @override
  String get entwBildWirdVorbereitet => 'Preparing the image for masking …';

  @override
  String get allgOder => '— or —';

  @override
  String get albumBestehendes => 'Existing album';

  @override
  String get albumNeuAnlegen => 'Create a new album';

  @override
  String get personZuordnenTitel => 'Assign a person';

  @override
  String personAktuell(String name) {
    return 'Currently: $name';
  }

  @override
  String get personBestehende => 'Existing person';

  @override
  String get personNeuAnlegen => 'Create a new person';

  @override
  String get personZuordnenAktion => 'Assign';

  @override
  String get bestaetigEndgueltigLoeschen => 'Delete permanently';

  @override
  String get bestaetigTippeVor => 'Type ';

  @override
  String get bestaetigTippeNach => ' to confirm:';

  @override
  String fortschrittFehlgeschlagen(String fehler) {
    return 'Failed: $fehler';
  }

  @override
  String sterneStern(int nummer) {
    return 'Star $nummer of 5';
  }

  @override
  String sterneSternVoll(int nummer) {
    return 'Star $nummer of 5, filled';
  }

  @override
  String sterneSetzen(int nummer) {
    return 'Set a rating of $nummer out of 5 stars';
  }

  @override
  String sterneBewertungAnzeige(int nummer) {
    return 'Rated $nummer out of 5 stars';
  }

  @override
  String get scrubberTooltip => 'Jump to a date';

  @override
  String get farbeViolett => 'Violet';

  @override
  String farbeAusgewaehlt(String farbe) {
    return '$farbe, selected';
  }

  @override
  String farbeSetzen(String farbe) {
    return 'Set the $farbe colour label';
  }

  @override
  String get histogrammTitel => 'Histogram';

  @override
  String get histogrammKeineVorschau => 'No preview yet';

  @override
  String get histogrammHelligkeit => 'Luminance';

  @override
  String get livePhotoHalten => 'Press and hold to play';

  @override
  String get metaBelichtungBeispiel => 'e.g. 1/125 or 0.5';

  @override
  String get karteTippenFuerOrt => 'Tap to set a location';

  @override
  String get rasterFotoNichtGefunden => 'That photo is not in the timeline.';

  @override
  String get kameraImportTitel => 'Import from a camera or SD card';

  @override
  String get kameraKeinDatentraeger =>
      'No volume with photos or videos found. Plug in a camera or SD card over USB – the list updates by itself as soon as one is recognised.';

  @override
  String get mischerTitel => 'Colour mixer';

  @override
  String get mischerFarbton => 'Hue';

  @override
  String get mischerSaettigung => 'Saturation';

  @override
  String get mischerHelligkeit => 'Luminance';

  @override
  String get mischerHinweis =>
      'Only affects coloured areas – greys are left untouched.';

  @override
  String get bandRot => 'Red';

  @override
  String get bandOrange => 'Orange';

  @override
  String get bandGelb => 'Yellow';

  @override
  String get bandGruen => 'Green';

  @override
  String get bandAqua => 'Aqua';

  @override
  String get bandBlau => 'Blue';

  @override
  String get bandViolett => 'Violet';

  @override
  String get bandMagenta => 'Magenta';

  @override
  String get kurveTitel => 'Tone curve';

  @override
  String get kurveHinweis =>
      'Drag to place or move a point; press and hold to remove one.';

  @override
  String get pinFeld => 'PIN';

  @override
  String get pinFestlegenTitel => 'Set a PIN';

  @override
  String get pinNeuFeld => 'New PIN (8-10 digits)';

  @override
  String get pinWiederholen => 'Repeat the PIN';

  @override
  String get pinWarnung =>
      'Important: photos in the locked folder are genuinely encrypted (AES-256). Without this PIN there is NO way to get them back – not even by resetting the app.';

  @override
  String get pinZiffernFehler => 'The PIN has to be 8 to 10 digits.';

  @override
  String get pinUngleich => 'The PINs do not match.';

  @override
  String get allgFestlegen => 'Set';

  @override
  String get pinEingebenTitel => 'Enter your PIN';

  @override
  String get pinFalsch => 'Wrong PIN.';

  @override
  String get passphraseFeld => 'Passphrase';

  @override
  String get passphraseFestlegenTitel => 'Set a backup passphrase';

  @override
  String get passphraseNeuFeld => 'New passphrase (at least 8 characters)';

  @override
  String get passphraseWiederholen => 'Repeat the passphrase';

  @override
  String get passphraseWarnung =>
      'Important: backups are genuinely encrypted (AES-256). Without this passphrase there is NO way to restore them – not even on another machine. Best write it down somewhere safe as well.';

  @override
  String get passphraseUngleich => 'The passphrases do not match.';

  @override
  String get passphraseFalsch => 'Wrong passphrase.';

  @override
  String get allgFoto => 'Photo';

  @override
  String get allgVideo => 'Video';

  @override
  String get kachelFavorisiert => 'favourite';

  @override
  String kachelBeschreibung(String typ, String name, String datum) {
    return '$typ $name, $datum';
  }

  @override
  String albumFotosLoeschenTitel(int anzahl) {
    return 'Delete $anzahl photo(s)?';
  }

  @override
  String get albumFotosLoeschenText =>
      'These photos are removed from the album and moved to the trash.';

  @override
  String albumZielordner(String album) {
    return 'Choose a destination folder for \"$album\"';
  }

  @override
  String get albumExportieren => 'Export the album';

  @override
  String get albumLeer => 'This album has no photos in it yet.';

  @override
  String get regelLoeschenTitel => 'Delete the rule?';

  @override
  String regelLoeschenText(String name) {
    return 'Really delete the rule \"$name\"? Actions it has already applied are kept.';
  }

  @override
  String get regelOrtUnvollstaendig => 'Location: not fully configured';

  @override
  String get regelDatumUnvollstaendig => 'Date range: not fully configured';

  @override
  String get regelTitel => 'Automation rules';

  @override
  String get regelNeu => 'New rule';

  @override
  String get regelLeer =>
      'No automation rules yet.\n\nCreate a rule to put photos into an album or tag automatically, or mark them as favourites, based on location, AI tag or capture date – like camera presets, but for other conditions.';

  @override
  String get allgBearbeiten => 'Edit';

  @override
  String get regelNameNoetig => 'The rule needs a name.';

  @override
  String get regelKoordinatenUngueltig =>
      'Latitude and longitude have to be valid numbers.';

  @override
  String get regelBreitengradBereich =>
      'Latitude has to be between -90 and 90.';

  @override
  String get regelLaengengradBereich =>
      'Longitude has to be between -180 and 180.';

  @override
  String get regelTagWaehlen => 'Please choose an AI tag term.';

  @override
  String get regelDatumWaehlen => 'Please choose a start and an end date.';

  @override
  String get regelDatumReihenfolge =>
      'The start date has to come before the end date.';

  @override
  String get regelBreitengrad => 'Latitude';

  @override
  String get regelLaengengrad => 'Longitude';

  @override
  String get regelKeinVokabular =>
      'There is no AI tag vocabulary (Settings → AI tagging vocabulary).';

  @override
  String get regelTagBegriff => 'AI tag term';

  @override
  String get regelNameFeld => 'Name (e.g. \"Holiday in Italy\")';

  @override
  String get regelBedingung => 'Condition';

  @override
  String get presetZielalbum => 'Destination album (optional)';

  @override
  String get presetKeinAlbum => 'No album';

  @override
  String get presetNeuesAlbum => 'or: create a new album';

  @override
  String get presetFavorisieren => 'Mark as favourite automatically';

  @override
  String get presetTagsWaehlenPlatzhalter => 'Choose tags …';

  @override
  String get presetKeineTags => 'There are no tags.';

  @override
  String get presetLoeschenTitel => 'Delete the preset?';

  @override
  String presetLoeschenText(String kamera) {
    return 'Really delete the camera preset for \"$kamera\"? Photos already imported stay as they are.';
  }

  @override
  String get presetTitel => 'Camera presets';

  @override
  String get presetNeu => 'New preset';

  @override
  String get presetLeer =>
      'No camera presets yet.\n\nCreate a preset for a particular camera to put its future imports into an album or tag automatically – even before the first photo from that camera has arrived.';

  @override
  String get presetHerstellerModellNoetig =>
      'Both make and model are required.';

  @override
  String get presetBekannteKamera => 'Use a known camera (optional)';

  @override
  String get presetHersteller => 'Make (e.g. Canon, Apple)';

  @override
  String get presetModell => 'Model (e.g. EOS R5, iPhone 15 Pro)';

  @override
  String get allgClipNoetigKurz =>
      'Needs the CLIP model (Settings → AI models).';

  @override
  String get duplNichtsLoeschbar =>
      'Nothing can be deleted automatically: every group has more than one photo marked as a favourite or rated – please go through those by hand.';

  @override
  String get duplNichtsZuLoeschen => 'Nothing to delete.';

  @override
  String get duplPapierkorbTitel => 'Move the copies to the trash?';

  @override
  String duplPapierkorbAnzahl(int fotos, int gruppen) {
    return '$fotos photo(s) from $gruppen group(s) will be moved to the trash.';
  }

  @override
  String get duplBehaltenRegel =>
      'Kept in each group: the favourite, otherwise the highest rating, otherwise the sharpest, otherwise the one with the highest resolution.';

  @override
  String duplUebersprungen(int anzahl) {
    return '$anzahl group(s) are left untouched, because more than one photo there is a favourite or rated.';
  }

  @override
  String get duplRueckgaengig => 'Undo: they can be restored from the trash.';

  @override
  String get duplInPapierkorb => 'Move to trash';

  @override
  String duplVerschoben(int anzahl) {
    return '$anzahl photo(s) moved to the trash.';
  }

  @override
  String get duplTitel => 'Duplicates & similar photos';

  @override
  String get duplZweiteBibliothek => 'Second library';

  @override
  String get duplAlleKopienLoeschen => 'Delete all copies';

  @override
  String get duplAehnlichkeit => 'Similarity:';

  @override
  String get duplSchwelleHinweis =>
      'Higher values mean only very similar photos are recognised as a group. Lower values find more, but less certain, matches.';

  @override
  String get duplKeineGruppen => 'No groups of similar photos found.';

  @override
  String get duplVerschiebenTooltip => 'Move to the trash';

  @override
  String get clusterTitel => 'Review suggestions';

  @override
  String get clusterFertig => 'All suggestions have been reviewed.';

  @override
  String clusterAehnlichZu(String name) {
    return 'Similar to: $name';
  }

  @override
  String get clusterUeberspringen => 'Skip';

  @override
  String get gesichtUmbenennen => 'Rename or change the person';

  @override
  String get gesichtNeuBenennen => 'Name a new face';

  @override
  String get gesichtGesperrt =>
      'Editing faces is not available for photos in the locked folder.';

  @override
  String get gesichtManuellHinzufuegen => 'Add a face by hand';

  @override
  String get gesichtHinzufuegenBeenden => 'Stop adding';

  @override
  String get gesichtRechteckHinweis =>
      'Drag a rectangle over a face to mark it by hand.';

  @override
  String get bearbBildNichtLesbar => 'The image could not be read.';

  @override
  String bearbBildNichtLesbarFehler(String fehler) {
    return 'The image could not be read: $fehler';
  }

  @override
  String get bearbSpeichernTitel => 'Save your changes?';

  @override
  String get bearbSpeichernText =>
      'The original file is replaced by the edited version. This cannot be undone.';

  @override
  String get bearbNichtFinalisiert => 'The image could not be finalised.';

  @override
  String get bearbZuschneidenAnwenden => 'Apply the crop';

  @override
  String get bearbTitel => 'Edit';

  @override
  String get importWasTitel => 'What would you like to import?';

  @override
  String get importWasText =>
      'Pick individual photos and videos, import a whole folder including its subfolders, or import straight from a connected camera or SD card.';

  @override
  String get importEinzelneDateien => 'Choose individual files';

  @override
  String get importGanzerOrdner => 'Choose a whole folder';

  @override
  String get importVonKamera => 'From a camera or SD card';

  @override
  String get importOrdnerWaehlen => 'Choose a folder to import';

  @override
  String get importNichtsImOrdner =>
      'No supported photos or videos found in that folder.';

  @override
  String get importNichtsAufDatentraeger =>
      'No supported photos or videos found on that volume.';

  @override
  String get importAbgeschlossen => 'Import finished';

  @override
  String get importLaeuft => 'Importing photos & videos …';

  @override
  String get importJetztSichten => 'Cull them now';

  @override
  String integPruefungFehlgeschlagen(String fehler) {
    return 'The check failed: $fehler';
  }

  @override
  String get integOriginalFehlt =>
      'The original is missing from disk – the whole photo or video is removed from the library.';

  @override
  String get integMaskeFehlt =>
      'The mask file is missing – the mask entry is removed.';

  @override
  String get integCropFehlt =>
      'The face crop is missing – only the preview is removed; the person it belongs to is kept.';

  @override
  String get integPfadEntfernt =>
      'The file path is removed from the database – the file can be recreated through \"Tools → Rebuild previews\".';

  @override
  String get integDateiLoeschenTitel => 'Delete the file?';

  @override
  String integDateiLoeschenText(String pfad) {
    return '$pfad will be deleted from disk for good.';
  }

  @override
  String get integErneutPruefen => 'Check again';

  @override
  String get integPruefsummen => 'Check checksums';

  @override
  String get integPruefsummenHinweis =>
      'Reads every original file in full and compares it against the checksum stored at import – noticeably slower on a large library than checking only for missing and orphaned files.';

  @override
  String integKeineProbleme(int anzahl) {
    return 'No problems found ($anzahl files checked).';
  }

  @override
  String get integAusDbEntfernen => 'Remove from the database';

  @override
  String get integDateiLoeschen => 'Delete the file';

  @override
  String integAbweichungen(int anzahl) {
    return 'Checksum mismatches ($anzahl)';
  }

  @override
  String get integInhaltGeaendert => 'The contents have changed since import';

  @override
  String get integFotoOeffnen => 'Open the photo';

  @override
  String integHeaderProbleme(int anzahl) {
    return 'Encrypted files with an invalid header ($anzahl)';
  }

  @override
  String get integBeschaedigt =>
      'The file may be damaged – not a valid encrypted file';

  @override
  String get gesperrtLeer =>
      'No locked photos. In a photo\'s full-screen view, the lock icon in the top right moves it here and encrypts it on the way.';

  @override
  String get gesperrtEntfernen => 'Take out of the locked folder (decrypt)';

  @override
  String get gesperrtEndgueltigTitel => 'Delete permanently?';

  @override
  String get gesperrtEndgueltigText =>
      'The file will be deleted for good – there is no recovery afterwards, not even with the right PIN.';

  @override
  String get gesperrtPapierkorbLeer =>
      'The locked trash is empty.\n\nPhotos deleted from the locked folder land here rather than in the normal, unprotected trash.';

  @override
  String get gesperrtWiederherstellen => 'Restore (stays locked)';

  @override
  String get personKeineGesichter => 'There are no faces for this person.';

  @override
  String get personProfilbildWaehlen => 'Choose a profile picture';

  @override
  String get personProfilbildAendern => 'Change the profile picture';

  @override
  String get personKeineFotos => 'No photos for this person yet.';

  @override
  String get personDoppelklickHinweis =>
      'Double-clicking a photo opens it for review with every face that was found.';

  @override
  String get personGelerntesVerworfen =>
      'What was learned has been discarded – the general threshold applies again.';

  @override
  String personSchwelleAngepasst(String schwelle, String allgemein) {
    return 'adjusted to $schwelle instead of $allgemein';
  }

  @override
  String personSchwelleWiderspruch(String allgemein) {
    return 'still $allgemein – the decisions contradict each other; a rejected face was more similar than a confirmed one';
  }

  @override
  String personSchwelleWirdAngepasst(int anzahl) {
    return 'adjusted from $anzahl decisions onwards';
  }

  @override
  String get personVerwerfen => 'Discard';

  @override
  String get restaurWartet => 'Waiting in the queue';

  @override
  String restaurLaeuft(int erledigt, int gesamt) {
    return 'Running – tile $erledigt of $gesamt';
  }

  @override
  String get restaurTitel => 'AI restoration – queue';

  @override
  String get restaurLeer =>
      'There are no restoration jobs.\nYou can start an AI restoration from a photo\'s develop screen.';

  @override
  String get restaurAusListe => 'Remove from the list';

  @override
  String restaurFehlgeschlagen(String grund) {
    return 'Failed: $grund';
  }

  @override
  String get restaurFehlgeschlagenKurz => 'Failed';

  @override
  String get zweitOrdnerWaehlen =>
      'Choose the folder of the second PhotoVault library';

  @override
  String get zweitTitel => 'Compare against a second library';

  @override
  String get allgErneutVersuchen => 'Try again';

  @override
  String get zweitErklaerung =>
      'Compares your own library against a second, independent PhotoVault library – on an external drive or an old machine, say – by AI image similarity, and finds photos that are already there before you import them again.\n\nLocked photos in the second library are never included, and its PIN is never needed.';

  @override
  String get zweitOrdnerKnopf => 'Choose the second library\'s folder';

  @override
  String get zweitSchwelleHinweis =>
      'Higher values mean only very similar photos count as a match.';

  @override
  String get zweitKeineTreffer =>
      'No similar photos found in the second library.';

  @override
  String zweitTreffer(int anzahl) {
    return '$anzahl possible match(es)';
  }

  @override
  String get zweitAndererOrdner => 'A different folder';

  @override
  String zweitAehnlichProzent(String prozent) {
    return '$prozent % similar';
  }

  @override
  String get zweitBibliothek => 'second library';

  @override
  String get aehnlTitel => 'Similar photos';

  @override
  String get aehnlClipFehlt =>
      'AI image search is unavailable – the CLIP model is missing (see Settings → AI models).';

  @override
  String get aehnlKeineTreffer =>
      'There is no AI embedding for this photo yet (see Tools → AI image search → Compute CLIP embeddings), or there are no similar photos in the library.';

  @override
  String get stapelErklaerung =>
      'Photos that look alike AND were taken within a few seconds of each other are suggested here as a series. \"Apply\" collapses a group into one stack – only the cover image stays visible in the overview, and nothing is deleted.';

  @override
  String get stapelKeine => 'No burst series found.';

  @override
  String get allgVerwerfen => 'Discard';

  @override
  String get statTitel => 'Statistics';

  @override
  String get allgAktualisieren => 'Refresh';

  @override
  String get statLeer => 'No photos or videos in the library yet.';

  @override
  String get statProJahr => 'Photos & videos per year';

  @override
  String get statSaisonalitaet => 'Seasonality – shots per month';

  @override
  String get statKameras => 'Most-used cameras';

  @override
  String get statInsgesamt => 'Items in total';

  @override
  String get statFotos => 'Photos';

  @override
  String get statVideos => 'Videos';

  @override
  String get statSpeicherplatz => 'Disk space';

  @override
  String get statImPapierkorb => 'In the trash';

  @override
  String statDiagrammJahr(String werte) {
    return 'Bar chart, photos and videos per year: $werte';
  }

  @override
  String statDiagrammMonat(String werte) {
    return 'Bar chart, seasonality per month: $werte';
  }

  @override
  String get papierkorbTitel => 'Trash';

  @override
  String get papierkorbEndgueltigTitel => 'Delete permanently?';

  @override
  String papierkorbEndgueltigText(int anzahl) {
    return 'Delete $anzahl file(s) for good.';
  }

  @override
  String get papierkorbLeer => 'The trash is empty.';

  @override
  String get videoNichtGeoeffnet => 'The video could not be opened.';

  @override
  String get videoZuschneidenFehler => 'Trimming failed.';

  @override
  String get videoZuschneiden => 'Trim';

  @override
  String get xmpAlleUebernehmen => 'Apply all';

  @override
  String get xmpErneutEinlesen => 'Read again';

  @override
  String xmpKeineAbweichungen(int anzahl) {
    return '$anzahl sidecar(s) checked – no differences from the database found.';
  }

  @override
  String get restaurWirdGestartet => 'Starting …';

  @override
  String get restaurAbgebrochen => 'Cancelled';

  @override
  String get restaurGrundModellLaedtNicht =>
      'The restoration model could not be loaded.';

  @override
  String get restaurGrundModellWeg => 'The model is no longer available.';

  @override
  String get restaurGrundFotoWeg =>
      'The photo has been deleted in the meantime.';

  @override
  String get restaurGrundGesperrt =>
      'AI restoration is not available for locked photos.';

  @override
  String get restaurGrundAufloesung => 'Image resolution unknown.';

  @override
  String get restaurGrundNichtGerendert => 'The image could not be rendered.';

  @override
  String get restaurGrundNichtDekodiert =>
      'The rendered image could not be decoded.';

  @override
  String get restaurNichtVerfuegbar =>
      'AI restoration is not available – the model is not installed.';

  @override
  String personSchwelleWieAllgemein(String allgemein) {
    return 'still $allgemein';
  }

  @override
  String personWiedererkennung(
      String erklaerung, int bestaetigt, int abgelehnt) {
    String _temp0 = intl.Intl.pluralLogic(
      bestaetigt,
      locale: localeName,
      other: '$bestaetigt confirmations',
      one: 'one confirmation',
    );
    String _temp1 = intl.Intl.pluralLogic(
      abgelehnt,
      locale: localeName,
      other: '$abgelehnt corrections',
      one: 'one correction',
    );
    return 'Recognition: $erklaerung. From $_temp0 and $_temp1.';
  }

  @override
  String get infoKeineUnbenannten =>
      'No unnamed faces found on this photo – if face detection has not run yet, see Tools → Scan for faces.';

  @override
  String get infoTitel => 'Info';

  @override
  String get infoBeschreibungHinzufuegen => 'Add a description';

  @override
  String get infoKiBeschreibung => 'AI caption';

  @override
  String get infoBewertung => 'Rating';

  @override
  String get infoNiemandZugeordnet => 'Nobody assigned yet.';

  @override
  String get infoDetails => 'Details';

  @override
  String get infoStandortBekannt => 'Location known';

  @override
  String get infoOrtNichtAufgeloest =>
      'Location not resolved yet (Tools → Locations)';

  @override
  String get infoOrtEntfernen => 'Clear the location';

  @override
  String infoSerie(int anzahl) {
    return 'Series: $anzahl photos';
  }

  @override
  String get infoNurTitelbild =>
      'Only the cover image is visible in the overview';

  @override
  String get infoSerieAufloesen => 'Break up the series';

  @override
  String get infoTagHinzufuegenPlatzhalter => 'Add a tag …';

  @override
  String get stufeBildanalyse => 'Image analysis';

  @override
  String get stufeTexterkennung => 'Text recognition';

  @override
  String get stufeSchlagwoerter => 'Tags';

  @override
  String get stufeBildbeschreibung => 'Captions';

  @override
  String get aktualisierungKeineVeroeffentlichungen => 'No releases found.';

  @override
  String get aktualisierungKeineVersion => 'No version number in the response.';

  @override
  String backupGrenzeErreicht(int anzahl) {
    return 'Limit reached – $anzahl file(s) follow on the next run';
  }

  @override
  String backupNichtGesichert(int anzahl) {
    return '$anzahl file(s) could not be backed up – they will be retried on the next run';
  }

  @override
  String get backupPassphraseNoetig =>
      'This backup is encrypted – a passphrase is needed.';

  @override
  String downloadPruefsummeFehler(
      String datei, String erhalten, String erwartet) {
    return 'The checksum of $datei does not match the expected SHA-256 (got $erhalten, expected $erwartet) – the download was discarded. The file on the server may have changed, or it was altered in transit.';
  }

  @override
  String downloadFehlgeschlagen(String datei, String fehler) {
    return 'Downloading $datei failed: $fehler';
  }

  @override
  String downloadEntpackenFehler(String datei, String fehler) {
    return 'Unpacking $datei failed: $fehler';
  }

  @override
  String downloadNichtImZip(String datei) {
    return '$datei was not found in the zip.';
  }

  @override
  String get regelAusloeserOrt => 'Location (radius)';

  @override
  String get regelAusloeserTag => 'AI tag';

  @override
  String get regelAusloeserDatum => 'Date range';

  @override
  String regelUmkreisUm(String km, String breite, String laenge) {
    return 'Within $km km of $breite, $laenge';
  }

  @override
  String regelTagWert(String begriff) {
    return 'AI tag: $begriff';
  }

  @override
  String regelDatumBereich(String von, String bis) {
    return '$von – $bis';
  }

  @override
  String regelUmkreis(String km) {
    return 'Radius: $km km';
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
    return 'Group $nummer · $anzahl photos';
  }

  @override
  String stapelSerie(int nummer, int anzahl) {
    return 'Series $nummer · $anzahl photos';
  }

  @override
  String clusterGesichterZuordnen(int anzahl) {
    return 'Assign $anzahl faces';
  }

  @override
  String clusterGesichterAnzahl(int anzahl) {
    return '$anzahl faces';
  }

  @override
  String gesichtEmbeddingFehler(String fehler) {
    return 'The recognition embedding failed: $fehler';
  }

  @override
  String bearbSpeichernFehler(String fehler) {
    return 'Saving failed: $fehler';
  }

  @override
  String integFehlendeDateien(int anzahl) {
    return 'Missing files ($anzahl)';
  }

  @override
  String integVerwaisteDateien(int anzahl) {
    return 'Orphaned files ($anzahl)';
  }

  @override
  String get viewerKugelSchwenken => '3D sphere instead of flat panning';

  @override
  String get regelNeuTitel => 'New automation rule';

  @override
  String get regelBearbeitenTitel => 'Edit rule';

  @override
  String presetZeileAlbum(String album) {
    return 'Album: $album';
  }

  @override
  String presetZeileTags(String tags) {
    return 'Tags: $tags';
  }

  @override
  String get presetKeineAktion => 'No action configured';

  @override
  String get presetNeuTitel => 'New camera preset';

  @override
  String get presetBearbeitenTitel => 'Edit camera preset';

  @override
  String allgSucheFehlgeschlagen(String fehler) {
    return 'Search failed: $fehler';
  }

  @override
  String get allgUnbekannterFehler => 'Unknown error';

  @override
  String erkundenVorJahren(int jahre) {
    String _temp0 = intl.Intl.pluralLogic(
      jahre,
      locale: localeName,
      other: '$jahre years ago',
      one: '1 year ago',
    );
    return '$_temp0';
  }

  @override
  String get gesichtBenennen => 'Name face';

  @override
  String get gesichtUnbenannt => 'Unnamed';

  @override
  String get bearbZuschneiden => 'Crop';

  @override
  String get bearbLinksDrehen => 'Rotate left';

  @override
  String get bearbRechtsDrehen => 'Rotate right';

  @override
  String get bearbHorizontalSpiegeln => 'Flip horizontally';

  @override
  String get bearbVertikalSpiegeln => 'Flip vertically';

  @override
  String get integAusDbEntfernenTitel => 'Remove from database?';

  @override
  String get integArtOriginal => 'Original';

  @override
  String get integArtThumbnail => 'Thumbnail';

  @override
  String get integArtVorschau => 'Preview';

  @override
  String get integArtEntwickelt => 'Developed image';

  @override
  String get integArtRestauriert => 'AI-restored image';

  @override
  String get integArtVideoZuschnitt => 'Trimmed video';

  @override
  String get integArtGesichtsCrop => 'Face crop';

  @override
  String get integArtMaske => 'AI mask';

  @override
  String get integAlleVerwaistenLoeschen => 'Delete all';

  @override
  String get integAlleVerwaistenTitel => 'Delete all orphaned files?';

  @override
  String integAlleVerwaistenText(int anzahl, String groesse) {
    return '$anzahl files totalling $groesse will be permanently deleted from disk. No database row refers to them, so the library loses nothing it could have shown.';
  }

  @override
  String integVerwaisteGeloescht(int anzahl) {
    return 'Deleted $anzahl orphaned files.';
  }

  @override
  String integWeitereEintraege(int anzahl, int gezeigt) {
    return '… and $anzahl more. The list shows only the first $gezeigt; “Delete all” clears the rest too.';
  }

  @override
  String get gesperrtTabFotos => 'Photos';

  @override
  String get gesperrtTabPapierkorb => 'Trash';

  @override
  String get karteHell => 'Light';

  @override
  String get karteDunkel => 'Dark';

  @override
  String get karteGlobus => 'Globe';

  @override
  String zweitVergleichFehlgeschlagen(String fehler) {
    return 'Comparison failed: $fehler';
  }

  @override
  String xmpEinlesenFehlgeschlagen(String fehler) {
    return 'Reading failed: $fehler';
  }

  @override
  String get xmpFeldBewertung => 'Rating';

  @override
  String get xmpFeldFarbmarkierung => 'Colour label';

  @override
  String get xmpFeldBeschreibung => 'Description';

  @override
  String get xmpFeldNeueTags => 'New tags';

  @override
  String get xmpFeldStandort => 'Location';

  @override
  String get xmpKeineSidecars => 'No XMP sidecars found.';

  @override
  String get liveWiedergabeStoppen => 'Stop playback';

  @override
  String get liveDauerschleife => 'Play on a loop';

  @override
  String get metaHersteller => 'Camera make';

  @override
  String get metaModell => 'Camera model';

  @override
  String get metaObjektiv => 'Lens';

  @override
  String get metaBrennweite => 'Focal length (mm)';

  @override
  String get metaBlende => 'Aperture (f/…)';

  @override
  String get metaBelichtungszeit => 'Shutter speed';

  @override
  String get passphraseZuKurz =>
      'The passphrase must be at least 8 characters long.';

  @override
  String get exportVorgabenTitel => 'Export presets';

  @override
  String get exportVorgabenLeer =>
      'No presets yet. A preset remembers size, quality and file naming – for everything you export more than once.';

  @override
  String get exportVorgabeNeu => 'New preset';

  @override
  String get exportVorgabeNeuTitel => 'New export preset';

  @override
  String get exportVorgabeBearbeitenTitel => 'Edit preset';

  @override
  String get exportVorgabeName => 'Name';

  @override
  String get exportVorgabeNameNoetig => 'Please give the preset a name.';

  @override
  String get exportVorgabeNachJpeg => 'Render to JPEG';

  @override
  String get exportVorgabeNachJpegHinweis =>
      'Without this the file is copied unchanged – the only way that leaves RAW files and videos untouched.';

  @override
  String get exportVorgabeKante => 'Longer edge (pixels)';

  @override
  String get exportVorgabeKanteLeer => 'empty = full resolution';

  @override
  String get exportVorgabeKanteUngueltig =>
      'The edge length must be between 64 and 20000.';

  @override
  String exportVorgabeQualitaet(int prozent) {
    return 'JPEG quality: $prozent%';
  }

  @override
  String get exportVorgabeMuster => 'File name pattern';

  @override
  String get exportVorgabeMusterNoetig =>
      'The file name pattern must not be empty.';

  @override
  String get exportVorgabeMusterHinweis =>
      'The extension is always added automatically. The running number counts within one export run and is padded to four digits.';

  @override
  String get exportVorgabeXmp => 'Write an XMP sidecar';

  @override
  String get exportVorgabeXmpHinweis =>
      'Rating, keywords and location for other programs – as a separate file next to the photo.';

  @override
  String exportVorgabeJpegVoll(int prozent) {
    return 'JPEG, full resolution, $prozent%';
  }

  @override
  String exportVorgabeJpegKante(int kante, int prozent) {
    return 'JPEG, longer edge $kante px, $prozent%';
  }

  @override
  String get exportVorgabeOhneXmp => 'no XMP';

  @override
  String get exportVorgabeLoeschenTitel => 'Delete preset?';

  @override
  String exportVorgabeLoeschenText(String name) {
    return '“$name” will be removed. Files you have already exported are not affected.';
  }

  @override
  String get exportEigeneVorgaben => 'Your presets';

  @override
  String get exportVorgabenVerwalten => 'Manage presets …';

  @override
  String get werkzExportVorgabenTitel => 'Export presets';

  @override
  String get werkzExportVorgabenText =>
      'Named output settings for exporting: size, JPEG quality, file naming and whether an XMP sidecar is written.';

  @override
  String get exportVorgabeNameVergeben => 'That name is already taken.';

  @override
  String get entwObjektivkorrekturKeinRaw =>
      'Not a RAW file – the camera has already corrected distortion and vignetting.';

  @override
  String get entwObjektivkorrekturVerfuegbar =>
      'Camera and lens are known: distortion and vignetting are corrected.';

  @override
  String get entwObjektivkorrekturUnbekanntesObjektiv =>
      'There is no profile for this camera. With ProRAW that is no loss – the correction is already baked into the file.';

  @override
  String get entwObjektivkorrekturNichtLesbar =>
      'The RAW data in this file cannot be opened. The other sliders therefore only affect the embedded preview.';

  @override
  String get einstSuche => 'Search settings';

  @override
  String get einstNichtsGefunden => 'No setting matches that search.';

  @override
  String get einstBeschrErscheinungsbild => 'Light, dark, or follow the system';

  @override
  String get einstBeschrSprache =>
      'Language of the interface and of the keywords';

  @override
  String get einstBeschrUeberwacht =>
      'Folders that new photos come in from on their own';

  @override
  String get einstBeschrBibliotheken => 'Switch between several libraries';

  @override
  String get einstBeschrSpeicherort =>
      'Where the library lives and how much room it takes';

  @override
  String get einstBeschrModelle => 'Download and remove the local models';

  @override
  String get einstBeschrHintergrund =>
      'Whether analysis starts automatically after an import';

  @override
  String get einstBeschrVokabular => 'The terms photos are tagged with';

  @override
  String get einstBeschrStandortdaten =>
      'Place names for GPS coordinates, offline';

  @override
  String get einstBeschrGesperrt => 'PIN, encryption and what is kept inside';

  @override
  String get einstBeschrBackupSchluessel => 'Passphrase for encrypted backups';

  @override
  String get einstBeschrBackupManuell => 'Start a backup by hand';

  @override
  String get einstBeschrBackupAuto =>
      'Back up regularly without having to think about it';

  @override
  String get einstBeschrPapierkorb => 'When deleted photos disappear for good';

  @override
  String get einstBeschrGefahr => 'Steps that cannot be undone';

  @override
  String get einstBeschrUeber => 'Version, licences and updates';

  @override
  String get allgRueckgaengig => 'Undo';

  @override
  String get personenIgnoriertTab => 'Ignored';

  @override
  String tabMitZahl(String beschriftung, int anzahl) {
    return '$beschriftung ($anzahl)';
  }

  @override
  String get personenIgnorierenTooltip => 'Ignore selected faces';

  @override
  String personenIgnoriertMeldung(int anzahl) {
    String _temp0 = intl.Intl.pluralLogic(
      anzahl,
      locale: localeName,
      other: '$anzahl faces ignored.',
      one: 'One face ignored.',
    );
    return '$_temp0';
  }

  @override
  String get personenIgnoriertLeer =>
      'No ignored faces. Whatever you set aside under “Unnamed faces” – posters, reflections, statues – collects here and can be brought back at any time.';

  @override
  String get personenIgnoriertHinweis =>
      'Ignored faces no longer appear in the grid and are left out of grouping. Double-click opens the whole photo.';

  @override
  String personenIgnoriertTeilHinweis(int gezeigt, int gesamt) {
    return '$gezeigt of $gesamt ignored faces. Double-click opens the whole photo.';
  }

  @override
  String personenZurueckholenKnopf(int anzahl) {
    return 'Bring back $anzahl';
  }

  @override
  String get clusterPhaseLaden => 'Loading faces …';

  @override
  String get clusterPhaseVergleichen => 'Comparing faces …';

  @override
  String get clusterPhaseVorschlaege => 'Preparing suggestions …';

  @override
  String get clusterOhneProzent => 'Working …';

  @override
  String clusterFehlgeschlagen(String fehler) {
    return 'Automatic grouping failed: $fehler';
  }

  @override
  String get clusterIgnorierenTooltip => 'Ignore the whole group';

  @override
  String get gesichtIgnorieren => 'Ignore';

  @override
  String get gesichtIgnoriert => 'Ignored';

  @override
  String get gesichtZurueckgeholt => 'This face counts again.';

  @override
  String gesichtPosition(int nummer, int gesamt) {
    return '$nummer of $gesamt';
  }

  @override
  String get gesichtVoriges => 'Previous photo (left arrow)';

  @override
  String get gesichtNaechstes => 'Next photo (right arrow)';

  @override
  String get clusterUnerwartetBeendet =>
      'Automatic grouping ended unexpectedly.';

  @override
  String get aufgAktiv => 'Active';

  @override
  String aufgStufeKurz(int nummer, int gesamt) {
    return 'Step $nummer/$gesamt';
  }

  @override
  String get personenAlleIgnorieren => 'Ignore all unnamed faces';

  @override
  String personenAlleIgnorierenHinweis(int anzahl) {
    String _temp0 = intl.Intl.pluralLogic(
      anzahl,
      locale: localeName,
      other: '$anzahl faces move to “Ignored”',
      one: 'One face moves to “Ignored”',
      zero: 'Nothing left',
    );
    return '$_temp0';
  }

  @override
  String personenAlleIgnoriertMeldung(int anzahl) {
    String _temp0 = intl.Intl.pluralLogic(
      anzahl,
      locale: localeName,
      other:
          '$anzahl faces ignored. Bring individual ones back under “Ignored”.',
      one: 'One face ignored. Bring individual ones back under “Ignored”.',
      zero: 'There was nothing to ignore.',
    );
    return '$_temp0';
  }

  @override
  String get personenAlleErkennungenLoeschen => 'Delete all unnamed detections';

  @override
  String get personenAlleErkennungenLoeschenHinweis =>
      'Frees space, but comes back on the next scan';

  @override
  String get personenErkennungenLoeschenTitel =>
      'Really delete the detections?';

  @override
  String get personenErkennungenLoeschenText =>
      'All unnamed detections and their crops are deleted from disk – including the ones already ignored. Named people are left untouched.\n\nThis is not permanent: the next face scan finds the same spots again. To be rid of them for good, use “Ignore all unnamed faces” instead – that survives another scan.';

  @override
  String personenErkennungenGeloeschtMeldung(int anzahl) {
    String _temp0 = intl.Intl.pluralLogic(
      anzahl,
      locale: localeName,
      other: '$anzahl detections deleted.',
      one: 'One detection deleted.',
      zero: 'There were no detections to delete.',
    );
    return '$_temp0';
  }

  @override
  String get gesichtZuordnungLoesen => 'Remove assignment';

  @override
  String get gesichtNichtMehrIgnorieren => 'Stop ignoring';

  @override
  String get gesichtFotoLoeschen => 'Delete photo';

  @override
  String get gesichtErkennungLoeschen => 'Delete detection';

  @override
  String gesichtAlleUnbenanntenIgnorieren(int anzahl) {
    String _temp0 = intl.Intl.pluralLogic(
      anzahl,
      locale: localeName,
      other: 'Ignore $anzahl unnamed faces',
      one: 'Ignore unnamed face',
      zero: 'No unnamed faces',
    );
    return '$_temp0';
  }

  @override
  String get personWeitereFotosSuchen => 'Find more photos';

  @override
  String vorschlagTitel(String name) {
    return 'Suggestions for $name';
  }

  @override
  String get vorschlagHinweis =>
      'Everything is selected. Take out what is wrong – the recognition learns from that too: a rejection raises this person\'s threshold.';

  @override
  String get vorschlagAlleWaehlen => 'Select all';

  @override
  String get vorschlagKeineWaehlen => 'Select none';

  @override
  String vorschlagUebernehmen(int anzahl) {
    String _temp0 = intl.Intl.pluralLogic(
      anzahl,
      locale: localeName,
      other: 'Assign $anzahl faces',
      one: 'Assign one face',
      zero: 'Nothing selected',
    );
    return '$_temp0';
  }

  @override
  String vorschlagUebernommenMeldung(int anzahl) {
    String _temp0 = intl.Intl.pluralLogic(
      anzahl,
      locale: localeName,
      other: '$anzahl photos added.',
      one: 'One photo added.',
      zero: 'Nothing taken over – the feedback was still saved.',
    );
    return '$_temp0';
  }

  @override
  String get vorschlagKeineEmbeddings =>
      'There is no recognition data for this person yet. It is created during the face scan once the SFace model is installed.';

  @override
  String get vorschlagKeineKandidaten =>
      'There are no unnamed faces that could be suggested.';

  @override
  String vorschlagNichtsGefunden(String schwelle) {
    return 'No unnamed face is above this person\'s threshold of $schwelle.';
  }

  @override
  String get gesichtRahmenAusblenden => 'Hide boxes';

  @override
  String get gesichtRahmenEinblenden => 'Show boxes';

  @override
  String get entwKlarheit => 'Clarity';

  @override
  String get entwVignettierung => 'Vignette';

  @override
  String get entwLutKeine => 'No colour table';

  @override
  String get entwLutWaehlen => 'Choose colour table (.cube)';

  @override
  String get entwLutEntfernen => 'Remove colour table';

  @override
  String get entwLutStaerke => 'Strength';

  @override
  String entwLutFehlt(String name) {
    return 'The colour table “$name” can no longer be read and was removed.';
  }

  @override
  String entwLutNichtLesbar(String fehler) {
    return 'The file cannot be read: $fehler';
  }

  @override
  String get entwLutEindimensional =>
      'This is a one-dimensional table – it describes a curve, not a colour space. Use the tone curve for that.';

  @override
  String get entwLutOhneGroesse => 'The file is missing the LUT_3D_SIZE entry.';

  @override
  String entwLutGroesse(int zeile) {
    return 'The edge length in line $zeile is outside the allowed range (2 to 256).';
  }

  @override
  String get entwLutZeilenzahl =>
      'The file does not contain as many values as its edge length requires.';

  @override
  String entwLutZeile(int zeile) {
    return 'Line $zeile cannot be read.';
  }

  @override
  String get histogrammWaveform => 'Waveform';

  @override
  String get histogrammParade => 'Parade';

  @override
  String get entwFormRechteck => 'Rectangle';

  @override
  String get entwFormFarbe => 'Colour';

  @override
  String get entwRechteckHinweis =>
      'Drag out a rectangle. Rotation and soft edge are set below.';

  @override
  String get entwFarbauswahlHinweis =>
      'Tap a colour in the photo. Everything close enough to it is selected – lighter and darker too, because colour counts for more than brightness.';

  @override
  String entwFarbeAufgenommen(int rot, int gruen, int blau) {
    return 'R $rot · G $gruen · B $blau';
  }

  @override
  String get entwToleranz => 'Tolerance';

  @override
  String get vergleichTitel => 'Compare two photos';

  @override
  String get vergleichNebeneinander => 'Side by side';

  @override
  String get vergleichUebereinander => 'Stacked';

  @override
  String get vergleichKoppeln => 'Link views';

  @override
  String get vergleichEntkoppeln => 'Unlink views';

  @override
  String get vergleichZuruecksetzen => 'Reset zoom';

  @override
  String get auswVergleichen => 'Compare the two selected photos';

  @override
  String get listeOhneKamera => 'No camera information';

  @override
  String get ansichtRaster => 'Grid';

  @override
  String get ansichtListe => 'List';

  @override
  String get gruppeMonat => 'By month';

  @override
  String get gruppeKamera => 'By camera';

  @override
  String get gruppeKeine => 'No grouping';

  @override
  String get bearbGeradeziehen => 'Straighten';

  @override
  String get bearbPerspektive => 'Perspective';

  @override
  String get bearbPerspektiveAnwenden => 'Correct';

  @override
  String get modellLamaTitel => 'Object removal (LaMa)';

  @override
  String get modellLamaText =>
      'Fills a marked area from its surroundings – for dust spots, passers-by or the bin at the edge of the frame. At 208 MB the largest model here; one pass takes about a second.';

  @override
  String get modellLamaLizenz =>
      'Apache 2.0 (Samsung Research), ONNX export by Carve';

  @override
  String get bearbRetusche => 'Remove object';

  @override
  String get bearbRetuscheAnwenden => 'Remove';

  @override
  String get bearbRetuscheZurueck => 'Undo last stroke';

  @override
  String get bearbPinselbreite => 'Brush width';

  @override
  String bearbRetuscheFehler(String fehler) {
    return 'Removal failed: $fehler';
  }

  @override
  String get stammbaumTitel => 'Family tree';

  @override
  String stammbaumTitelVon(String name) {
    return 'Family tree: $name';
  }

  @override
  String get stammbaumEltern => 'Parents';

  @override
  String get stammbaumGeschwister => 'Siblings';

  @override
  String get stammbaumPartner => 'Partner';

  @override
  String get stammbaumKinder => 'Children';

  @override
  String get stammbaumElternteilHinzufuegen => 'Add parent';

  @override
  String get stammbaumPartnerHinzufuegen => 'Add partner';

  @override
  String get stammbaumKindHinzufuegen => 'Add child';

  @override
  String get stammbaumInDieMitte => 'Move to centre';

  @override
  String get stammbaumLebensdaten => 'Life dates …';

  @override
  String get stammbaumFotosZeigen => 'Photos of this person';

  @override
  String get stammbaumVerbindungEntfernen => 'Remove connection';

  @override
  String stammbaumVerbindungEntfernenFrage(String eine, String andere) {
    return 'The relationship between $eine and $andere will be removed. Both people and their photos stay.';
  }

  @override
  String get stammbaumFehlerSelbst =>
      'A person cannot be related to themselves.';

  @override
  String get stammbaumFehlerKreis =>
      'That would run in a circle: this person already appears further down the same branch.';

  @override
  String get stammbaumFehlerVorhanden =>
      'This relationship is already recorded.';

  @override
  String get stammbaumLeer =>
      'No relatives recorded for this person yet. Use the buttons at the top right to add parents, a partner or children – either from the people you have already named, or as a new name, even without a single photo.';

  @override
  String get stammbaumPersonFehlt => 'This person no longer exists.';

  @override
  String get stammbaumGeboren => 'Born';

  @override
  String get stammbaumGestorben => 'Died';

  @override
  String get stammbaumUnbekannt => 'unknown';

  @override
  String get stammbaumNurJahrHinweis =>
      'If only the year is known, pick any day within it – only the year is shown anyway.';

  @override
  String get gradSelbst => 'this person';

  @override
  String gradEltern(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Mother',
        'm': 'Father',
        'other': 'Parent',
      },
    );
    return '$_temp0';
  }

  @override
  String gradGrosseltern(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Grandmother',
        'm': 'Grandfather',
        'other': 'Grandparent',
      },
    );
    return '$_temp0';
  }

  @override
  String gradUrgrosseltern(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Great-grandmother',
        'm': 'Great-grandfather',
        'other': 'Great-grandparent',
      },
    );
    return '$_temp0';
  }

  @override
  String gradUrurgrosseltern(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Great-great-grandmother',
        'm': 'Great-great-grandfather',
        'other': 'Great-great-grandparent',
      },
    );
    return '$_temp0';
  }

  @override
  String gradVorfahreN(int stufe) {
    return 'Ancestor, $stufe generations up';
  }

  @override
  String gradKind(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Daughter',
        'm': 'Son',
        'other': 'Child',
      },
    );
    return '$_temp0';
  }

  @override
  String gradEnkel(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Granddaughter',
        'm': 'Grandson',
        'other': 'Grandchild',
      },
    );
    return '$_temp0';
  }

  @override
  String gradUrenkel(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Great-granddaughter',
        'm': 'Great-grandson',
        'other': 'Great-grandchild',
      },
    );
    return '$_temp0';
  }

  @override
  String gradUrurenkel(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Great-great-granddaughter',
        'm': 'Great-great-grandson',
        'other': 'Great-great-grandchild',
      },
    );
    return '$_temp0';
  }

  @override
  String gradNachkommeN(int stufe) {
    return 'Descendant, $stufe generations down';
  }

  @override
  String gradGeschwister(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Sister',
        'm': 'Brother',
        'other': 'Sibling',
      },
    );
    return '$_temp0';
  }

  @override
  String gradHalbgeschwister(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Half-sister',
        'm': 'Half-brother',
        'other': 'Half-sibling',
      },
    );
    return '$_temp0';
  }

  @override
  String gradNeffeNichte(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Niece',
        'm': 'Nephew',
        'other': 'Sibling’s child',
      },
    );
    return '$_temp0';
  }

  @override
  String gradGrossneffeNichte(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Great-niece',
        'm': 'Great-nephew',
        'other': 'Sibling’s grandchild',
      },
    );
    return '$_temp0';
  }

  @override
  String gradGeschwisterNachkommeN(int stufe) {
    return 'Descendant of a sibling, $stufe steps down';
  }

  @override
  String gradOnkelTante(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Aunt',
        'm': 'Uncle',
        'other': 'Parent’s sibling',
      },
    );
    return '$_temp0';
  }

  @override
  String gradGrossonkelTante(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Great-aunt',
        'm': 'Great-uncle',
        'other': 'Grandparent’s sibling',
      },
    );
    return '$_temp0';
  }

  @override
  String gradVorfahrengeschwisterN(int stufe) {
    return 'Sibling of an ancestor, $stufe generations up';
  }

  @override
  String gradCousin(String geschlecht, int stufe) {
    String _temp0 = intl.Intl.pluralLogic(
      stufe,
      locale: localeName,
      other: 'Degree-$stufe',
      two: 'Second',
      one: 'First',
    );
    String _temp1 = intl.Intl.selectLogic(
      geschlecht,
      {
        'other': '$_temp0 cousin',
      },
    );
    return '$_temp1';
  }

  @override
  String gradEntfernt(int stufe, String bezeichnung) {
    return '$bezeichnung, $stufe times removed';
  }

  @override
  String gradPartner(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Partner',
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
        'w': 'Sister-in-law',
        'm': 'Brother-in-law',
        'other': 'Sibling-in-law',
      },
    );
    return '$_temp0';
  }

  @override
  String gradSchwiegereltern(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Mother-in-law',
        'm': 'Father-in-law',
        'other': 'Parent-in-law',
      },
    );
    return '$_temp0';
  }

  @override
  String gradSchwiegerkind(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Daughter-in-law',
        'm': 'Son-in-law',
        'other': 'Child-in-law',
      },
    );
    return '$_temp0';
  }

  @override
  String gradStiefeltern(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Stepmother',
        'm': 'Stepfather',
        'other': 'Stepparent',
      },
    );
    return '$_temp0';
  }

  @override
  String gradStiefkind(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Stepdaughter',
        'm': 'Stepson',
        'other': 'Stepchild',
      },
    );
    return '$_temp0';
  }

  @override
  String gradStiefgeschwister(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Stepsister',
        'm': 'Stepbrother',
        'other': 'Stepsibling',
      },
    );
    return '$_temp0';
  }

  @override
  String get gradAngeheiratet => 'related by marriage';

  @override
  String get gradKeine => 'not related';

  @override
  String get navStammbaum => 'Family tree';

  @override
  String get stammbaumAndereWaehlen => 'Put another person at the centre';

  @override
  String get stammbaumAnsichtBaum => 'Tree';

  @override
  String get stammbaumAnsichtListe => 'Relatives';

  @override
  String stammbaumListeKopf(String name, int anzahl) {
    String _temp0 = intl.Intl.pluralLogic(
      anzahl,
      locale: localeName,
      other: '$anzahl people are related to $name – closest relatives first.',
      one: 'One person is related to $name.',
    );
    return '$_temp0';
  }

  @override
  String get stammbaumKeinePersonen =>
      'No people yet. Name a few faces under “People”, or add someone here via “Put another person at the centre”.';

  @override
  String get stammbaumGeschlecht => 'Gender';

  @override
  String get stammbaumGeschlechtWeiblich => 'female';

  @override
  String get stammbaumGeschlechtMaennlich => 'male';

  @override
  String get stammbaumGeschlechtDivers => 'non-binary';

  @override
  String get stammbaumGeschlechtOffen => 'not stated';

  @override
  String get stammbaumGeschlechtHinweis =>
      'Used only for the relationship labels – without it you get “sibling” instead of “sister”.';

  @override
  String get stammbaumAngaben => 'Person details';

  @override
  String get stammbaumAnsichtFaecher => 'Fan';

  @override
  String get stammbaumAnsichtNachfahren => 'Descendants';

  @override
  String get stammbaumKeineVorfahren =>
      'No ancestors recorded for this person yet. The fan shows parents, grandparents and great-grandparents – add a parent at the top right and it fills from the inside out.';

  @override
  String get stammbaumKeineNachfahren =>
      'No children recorded for this person yet. The outline shows all descendants, indented by generation.';

  @override
  String get stammbaumFamilienfotos => 'Photos of this family';

  @override
  String stammbaumFamilienfotosVon(String name) {
    return 'Photos of $name’s family';
  }

  @override
  String get stammbaumKeineFamilienfotos =>
      'Nobody from this family has been recognised in a photo yet.';

  @override
  String get stammbaumGedcomExport => 'Export as GEDCOM …';

  @override
  String stammbaumGedcomFertig(int anzahl) {
    String _temp0 = intl.Intl.pluralLogic(
      anzahl,
      locale: localeName,
      other: '$anzahl people exported.',
      one: 'One person exported.',
    );
    return '$_temp0';
  }

  @override
  String gradAdoptiveltern(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Adoptive mother',
        'm': 'Adoptive father',
        'other': 'Adoptive parent',
      },
    );
    return '$_temp0';
  }

  @override
  String gradPflegeeltern(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Foster mother',
        'm': 'Foster father',
        'other': 'Foster parent',
      },
    );
    return '$_temp0';
  }

  @override
  String gradAdoptivkind(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Adopted daughter',
        'm': 'Adopted son',
        'other': 'Adopted child',
      },
    );
    return '$_temp0';
  }

  @override
  String gradPflegekind(String geschlecht) {
    String _temp0 = intl.Intl.selectLogic(
      geschlecht,
      {
        'w': 'Foster daughter',
        'm': 'Foster son',
        'other': 'Foster child',
      },
    );
    return '$_temp0';
  }

  @override
  String get stammbaumLeiblich => 'Biological';

  @override
  String get stammbaumAdoptiv => 'Adoptive';

  @override
  String get stammbaumPflege => 'Foster';

  @override
  String get stammbaumAnsichtSanduhr => 'Hourglass';

  @override
  String get stammbaumSeitenlinien => 'Collateral line';

  @override
  String get stammbaumSeitenlinienHinweis =>
      'Siblings beside the person, their children below – this is what makes nephews, nieces and in-laws visible.';

  @override
  String lebenslaufVon(String name) {
    return 'Life story: $name';
  }

  @override
  String get lebenslaufHinzufuegen => 'Add event';

  @override
  String get lebenslaufLeer =>
      'Nothing recorded for this person yet. Birth and death live with the person details; weddings, moves, jobs and everything else go here.';

  @override
  String get lebenslaufGeburt => 'Born';

  @override
  String get lebenslaufTod => 'Died';

  @override
  String get lebenslaufHochzeit => 'Marriage';

  @override
  String get lebenslaufUmzug => 'Move';

  @override
  String get lebenslaufBeruf => 'Work';

  @override
  String get lebenslaufAusbildung => 'Education';

  @override
  String get lebenslaufSonstiges => 'Other';

  @override
  String get lebenslaufOhneDatum => 'no date';

  @override
  String get lebenslaufOrt => 'Place';

  @override
  String get lebenslaufNotiz => 'Note';

  @override
  String get stammbaumLebenslauf => 'Life story …';

  @override
  String get orteIch => 'This person';

  @override
  String get orteVorfahren => 'Ancestors';

  @override
  String get orteNachkommen => 'Descendants';

  @override
  String get orteSeitenlinie => 'Collateral line';

  @override
  String get orteAngeheiratet => 'By marriage';

  @override
  String get orteNichtsGewaehlt => 'No group selected.';

  @override
  String get stammbaumFamilienorte => 'Places of this family';

  @override
  String get stammbaumMenue => 'More about this person';

  @override
  String get stammbaumVerbindungsart => 'Kind of connection …';

  @override
  String stammbaumVerbindungsartTitel(String kind, String elternteil) {
    return 'How is $kind connected to $elternteil?';
  }

  @override
  String get stammbaumVerbindungsartHinweis =>
      'Adoptive and foster parents count as parents everywhere – only the term and the dashed line tell them apart.';

  @override
  String get stammbaumNichtsEntfernt => 'That connection was already removed.';

  @override
  String get stammbaumWeitereVerwandte => 'More relatives';

  @override
  String get stammbaumVerwandtenHinzufuegen => 'Add a relative …';

  @override
  String get stammbaumGruppeVorfahren => 'Ancestors';

  @override
  String get stammbaumGruppeNachkommen => 'Descendants';

  @override
  String get stammbaumGruppeSeitenlinie => 'Collateral line';

  @override
  String get stammbaumGruppeAngeheiratet => 'By marriage';

  @override
  String get stammbaumGradGrosselternteil => 'Grandparent';

  @override
  String get stammbaumGradUrgrosselternteil => 'Great-grandparent';

  @override
  String get stammbaumGradEnkelkind => 'Grandchild';

  @override
  String get stammbaumGradUrenkelkind => 'Great-grandchild';

  @override
  String get stammbaumGradGeschwisterkind => 'Sibling';

  @override
  String get stammbaumGradHalbgeschwisterkind => 'Half-sibling';

  @override
  String get stammbaumGradOnkelTante => 'Uncle or aunt';

  @override
  String get stammbaumGradNeffeNichte => 'Nephew or niece';

  @override
  String get stammbaumGradCousin => 'Cousin';

  @override
  String get stammbaumGradSchwiegerelternteil => 'Parent-in-law';

  @override
  String get stammbaumGradSchwiegerkind => 'Child-in-law';

  @override
  String get stammbaumGradSchwager => 'Brother- or sister-in-law';

  @override
  String get stammbaumGradStiefelternteil => 'Step-parent';

  @override
  String get stammbaumGradStiefkind => 'Stepchild';

  @override
  String stammbaumFehltElternteil(String name) {
    return '$name needs a parent first.';
  }

  @override
  String stammbaumFehltGrosselternteil(String name) {
    return '$name needs grandparents first.';
  }

  @override
  String stammbaumFehltKind(String name) {
    return '$name needs a child first.';
  }

  @override
  String stammbaumFehltEnkelkind(String name) {
    return '$name needs a grandchild first.';
  }

  @override
  String stammbaumFehltGeschwister(String name) {
    return '$name needs a sibling first.';
  }

  @override
  String stammbaumFehltOnkelTante(String name) {
    return '$name needs an uncle or aunt first.';
  }

  @override
  String stammbaumFehltPartner(String name) {
    return '$name needs a partner first.';
  }

  @override
  String stammbaumFehltGeschwisterOderPartner(String name) {
    return '$name needs a sibling or a partner first.';
  }

  @override
  String stammbaumUeberWen(String grad) {
    return '$grad – through whom?';
  }

  @override
  String stammbaumVerwandterEingetragen(String name, String bezeichnung) {
    return '$name has been added – $bezeichnung.';
  }

  @override
  String stammbaumNurEintragbares(String name) {
    return 'Shown is what can be added for $name. Greyed out means an intermediate person is still missing.';
  }

  @override
  String stammbaumFamilienorteVon(String name) {
    return 'Places of $name’s family';
  }

  @override
  String get stammbaumKeineFamilienorte =>
      'No photo from this family has a location.';

  @override
  String get stammbaumTafelDrucken => 'Chart as PDF …';

  @override
  String get stammbaumTafelFertig => 'The chart has been written.';

  @override
  String get aufgWirdErmittelt => 'Working out what is left …';

  @override
  String aufgAbgebrochenBei(int erledigt, int gesamt) {
    return 'Cancelled at $erledigt of $gesamt';
  }

  @override
  String aufgFertigMit(int gesamt) {
    return 'Done – $gesamt processed';
  }

  @override
  String get beendenTitel => 'Still analysing';

  @override
  String get beendenText =>
      'Quitting loses the file currently being worked on; everything already analysed stays. Still running:';

  @override
  String get beendenTrotzdem => 'Quit anyway';

  @override
  String get beendenWeiterlaufen => 'Keep running';

  @override
  String get aufgUebersetzenTitel => 'Translate captions';

  @override
  String get aufgUebersetzenText =>
      'Turns the existing English AI captions into German – without running the captioning model again.';

  @override
  String get aufgUebersetzungsmodell =>
      'the English → German translation model';

  @override
  String get werkzUebersetzeBeschreibungen => 'Translating captions …';

  @override
  String get werkzAlleUebersetzt => 'Every caption has been translated.';

  @override
  String werkzLaeuftSchon(String titel) {
    return 'Already running as a background task: $titel';
  }

  @override
  String get aufgLaeuftSchon => 'This analysis is already running.';

  @override
  String get aufgAndereLaeuft =>
      'Another analysis is already running. Expensive ones run one after another so that several AI models are never in memory at once.';

  @override
  String get aufgAnalyseLaeuft =>
      'The background analysis is working through the same steps right now. You can stop it in the “Catch up on everything” card above.';

  @override
  String get infoKiBeschreibungVonHand => 'AI caption, edited by hand';

  @override
  String get infoKiVonHandHinweis =>
      'Survives “All photos”. Clear the field to have it computed again.';

  @override
  String get infoSpracheDe => 'DE';

  @override
  String get infoSpracheEn => 'EN';

  @override
  String get infoKiPlatzhalterDe => 'Write the German version';

  @override
  String get infoKiPlatzhalterEn => 'Write the English version';

  @override
  String duplGefunden(int gruppen, int fotos) {
    return '$gruppen groups with $fotos photos';
  }

  @override
  String get duplNichtsGefunden => 'No groups found';

  @override
  String get duplGruppeIgnorieren => 'Skip';

  @override
  String duplGruppeIgnoriert(int anzahl) {
    return '$anzahl photos will be skipped by the duplicate search from now on.';
  }

  @override
  String duplAusnahmenZahl(int anzahl) {
    return '$anzahl skipped';
  }

  @override
  String get duplAusnahmenTitel => 'Show skipped ones again';

  @override
  String duplAusnahmenFrage(int anzahl) {
    return '$anzahl pairs are excluded from the search. Should all of them be considered again?';
  }

  @override
  String get duplAusnahmenLoeschen => 'Show all again';

  @override
  String get entwNurMitCoreImage =>
      'Sharpening, noise reduction, clarity and vignetting need processing steps that only exist on macOS. Every other slider works fully here.';

  @override
  String get modellOcrTitel => 'Text recognition (PaddleOCR)';

  @override
  String get modellOcrText =>
      'Finds text in photos and reads it – two models, 13.7 MB together. Covers the Latin alphabet including umlauts and ß. Not needed on macOS: Apple\'s Vision framework does it there without a download.';

  @override
  String get modellOcrLizenz => 'Apache 2.0 (PaddleOCR)';

  @override
  String get aufgOcrModell => 'the text recognition model';

  @override
  String get werkzDatumTitel => 'Read capture date from RAW photos';

  @override
  String get werkzDatumText =>
      'Reads date, camera and lens straight from RAW files. Needed for formats such as Canon\'s CR3, which yielded nothing on import – those photos carry the file\'s timestamp instead of the capture time.';

  @override
  String get werkzDatumFrageTitel => 'Correct the capture date?';

  @override
  String get werkzDatumFrage =>
      'Photos whose capture date came from the file timestamp will get the real date from the RAW file. They move to the right place in the timeline and calendar, and on disk into the matching month folder.\n\nThe photos themselves are not modified. The run cannot be undone.';

  @override
  String get werkzDatumStarten => 'Correct';

  @override
  String get werkzKorrigiereDatum => 'Reading capture data from RAW photos …';

  @override
  String get werkzKeineRawFotos => 'No RAW photos in the library.';

  @override
  String get karteGlobusZoomHinweis =>
      'Zooming in further shows no extra detail – the Earth texture is a single image. Tap a pin to switch to the map at that spot.';

  @override
  String get karteHineinzoomen => 'Zoom in';

  @override
  String get karteHerauszoomen => 'Zoom out';

  @override
  String get karteStandortZeigen => 'My location';

  @override
  String get karteStandortNichtErmittelbar =>
      'Could not determine your location. Check System Settings → Privacy & Security → Location Services to see whether Photo Vault may ask.';

  @override
  String get karteStandortSuche => 'Determining location …';
}
