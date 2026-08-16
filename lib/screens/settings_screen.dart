import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../db/database.dart';
import '../services/geo_data_catalog.dart';
import '../services/library_location.dart';
import '../services/model_catalog.dart';
import '../state/library_state.dart';
import '../services/platform/reveal_in_file_manager.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../widgets/pin_dialogs.dart';
import '../widgets/progress_dialog.dart';
import '../widgets/typed_confirm_dialog.dart';
import 'background_tasks_screen.dart';
import 'locked_folder_screen.dart';

class SettingsScreen extends StatefulWidget {
  final LibraryState library;
  const SettingsScreen({super.key, required this.library});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int? _sizeBytes;
  BackupRecordData? _lastBackup;
  final Set<String> _downloading = {};
  bool _encryptManualBackup = false;
  bool _downloadingGeoData = false;
  double _geoDataProgress = 0;
  final TextEditingController _aiTagVocabularyController = TextEditingController();

  @override
  void dispose() {
    _aiTagVocabularyController.dispose();
    super.dispose();
  }

  Future<void> _addAiTagVocabularyTerm() async {
    final term = _aiTagVocabularyController.text.trim();
    if (term.isEmpty) return;
    _aiTagVocabularyController.clear();
    await widget.library.db.addAiTagTerm(term);
  }

  // Als Felder statt inline im FutureBuilder in build() erzeugt: ein dort
  // direkt aufgerufenes `future: someQuery()` würde bei JEDEM Rebuild dieses
  // Screens (z.B. durch den App-weiten Consumer<LibraryState>) ein neues
  // Future anstoßen und den jeweiligen FutureBuilder kurz in den Ladezustand
  // zurückfallen lassen. Gezielt per _reloadX() nach den Aktionen aktualisiert,
  // die den jeweiligen Wert tatsächlich ändern können.
  late Future<bool> _isCustomLocationFuture;
  late Future<bool> _hasPinSetFuture;
  late Future<bool> _hasBackupKeyFuture;
  late Future<BackupSettingsData?> _backupSettingsFuture;
  late Future<TrashSettingsData?> _trashSettingsFuture;
  late Future<List<BibliothekMitZustand>> _bibliothekenFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
    _isCustomLocationFuture = LibraryLocation.isCustom;
    _bibliothekenFuture = LibraryLocation.bekannte();
    _hasPinSetFuture = widget.library.db.hasPinSet();
    _hasBackupKeyFuture = widget.library.db.hasBackupKey();
    _backupSettingsFuture = widget.library.db.backupSettingsRow();
    _trashSettingsFuture = widget.library.db.trashSettingsRow();
  }

  void _reloadPinState() => setState(() => _hasPinSetFuture = widget.library.db.hasPinSet());
  void _reloadBackupKeyState() => setState(() => _hasBackupKeyFuture = widget.library.db.hasBackupKey());
  void _reloadBackupSettings() =>
      setState(() => _backupSettingsFuture = widget.library.db.backupSettingsRow());
  void _reloadTrashSettings() =>
      setState(() => _trashSettingsFuture = widget.library.db.trashSettingsRow());

  Future<void> _refresh() async {
    final size = await widget.library.paths.totalOriginalsSizeBytes();
    final last = await widget.library.db.lastBackupRecord();
    if (mounted) {
      setState(() {
        _sizeBytes = size;
        _lastBackup = last;
      });
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  Future<void> _openInFinder(String path) async {
    final opened = await revealInFileManager(path);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ordner konnte nicht geöffnet werden: $path')),
      );
    }
  }

  Future<void> _downloadModel(ModelCatalogEntry entry) async {
    setState(() => _downloading.add(entry.id));
    double progress = 0;
    void Function(void Function())? sheetSetState;

    // WICHTIG: hier bewusst NICHT auf showModalBottomSheet warten – das
    // Future davon löst erst auf, wenn das Sheet geschlossen wird (also
    // erst im finally unten). Würden wir hier awaiten, würde der Code
    // darunter (der eigentliche Download) nie ausgeführt werden.
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => StatefulBuilder(builder: (context, setSheetState) {
        sheetSetState = setSheetState;
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Lade "${entry.title}" herunter …',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              LinearProgressIndicator(value: progress > 0 ? progress : null),
              const SizedBox(height: 8),
              Text('${(progress * 100).toStringAsFixed(0)} %'),
            ],
          ),
        );
      }),
    );

    try {
      await for (final p in widget.library.modelDownloadService.download(entry)) {
        progress = p.fraction;
        sheetSetState?.call(() {});
      }
      await widget.library.reloadModels();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
      setState(() => _downloading.remove(entry.id));
    }
  }

  Future<void> _deleteModel(ModelCatalogEntry entry) async {
    await widget.library.modelDownloadService.deleteEntry(entry);
    await widget.library.reloadModels();
    setState(() {});
  }

  Future<void> _downloadGeoData() async {
    setState(() {
      _downloadingGeoData = true;
      _geoDataProgress = 0;
    });
    void Function(void Function())? sheetSetState;

    // Wie bei _downloadModel bewusst nicht auf das Sheet-Future warten – das
    // löst erst nach dem Schließen im finally unten auf.
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => StatefulBuilder(builder: (context, setSheetState) {
        sheetSetState = setSheetState;
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Lade Standortdaten herunter …', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              LinearProgressIndicator(value: _geoDataProgress > 0 ? _geoDataProgress : null),
              const SizedBox(height: 8),
              Text('${(_geoDataProgress * 100).toStringAsFixed(0)} %'),
            ],
          ),
        );
      }),
    );

    try {
      await for (final p in widget.library.geoDataDownloadService.download()) {
        _geoDataProgress = p.fraction;
        sheetSetState?.call(() {});
      }
      await widget.library.reloadGeoData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
      setState(() => _downloadingGeoData = false);
    }
  }

  Future<void> _deleteGeoData() async {
    await widget.library.geoDataDownloadService.deleteAll();
    await widget.library.reloadGeoData();
    setState(() {});
  }

  /// Wechselt die geöffnete Bibliothek. Verschiebt NICHTS – siehe
  /// [LibraryLocation.wechsleZu]. Danach ist ein Neustart nötig, weil
  /// Datenbankverbindung, StoragePaths und sämtliche Zwischenspeicher am
  /// alten Ort hängen.
  Future<void> _wechsleBibliothek(BibliothekMitZustand ziel) async {
    final bestaetigt = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Zu „${ziel.eintrag.name}" wechseln?'),
        content: const Text(
          'Die App wird danach geschlossen und öffnet beim nächsten Start die '
          'gewählte Bibliothek.\n\n'
          'Es werden keine Fotos verschoben oder gelöscht – beide Bibliotheken '
          'bleiben unverändert an ihrem Ort.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Wechseln')),
        ],
      ),
    );
    if (bestaetigt != true || !mounted) return;

    await _runRelocation(
      loadingText: 'Wechsle Bibliothek …',
      restartMessage: 'Die Bibliothek wurde gewechselt. Es wurden keine Daten '
          'verschoben. Die App wird jetzt geschlossen – bitte danach manuell '
          'neu öffnen.',
      errorPrefix: 'Wechseln fehlgeschlagen',
      action: () async {
        // Reihenfolge mit Bedacht: ERST den Zeiger schreiben, DANN die
        // Datenbank schliessen. Andersherum liefe die App bei einem Fehler
        // im Schreibvorgang mit geschlossener Datenbank weiter und wäre
        // unbrauchbar, obwohl gar nichts passiert ist. Das Schliessen ist
        // hier ohnehin nur Höflichkeit vor dem Beenden (WAL sauber
        // abschliessen) – der Wechsel selbst rührt die Bibliothek nicht an.
        await LibraryLocation.wechsleZu(ziel.eintrag);
        await widget.library.db.close();
      },
    );
  }

  /// Nimmt einen Ordner in die Liste auf, ohne ihn zu öffnen.
  Future<void> _bibliothekHinzufuegen() async {
    final picked = await LibraryLocation.pickFolder(
      dialogMessage: 'Ordner einer bestehenden Bibliothek wählen – oder einen leeren '
          'Ordner für eine neue. Es wird nichts verschoben.',
    );
    if (picked == null || !mounted) return;

    final vorhanden = File(p.join(picked.path, 'library.sqlite')).existsSync();
    await LibraryLocation.fuegeHinzu(picked);
    if (!mounted) return;
    setState(() => _bibliothekenFuture = LibraryLocation.bekannte());
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(vorhanden
          ? 'Bestehende Bibliothek hinzugefügt.'
          : 'Leerer Ordner hinzugefügt – beim Wechseln dorthin entsteht eine neue, leere Bibliothek.'),
    ));
  }

  /// Streicht einen Eintrag aus der Liste. Die Fotos bleiben, wo sie sind.
  Future<void> _entferneBibliothek(BibliothekMitZustand b) async {
    final bestaetigt = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('„${b.eintrag.name}" aus der Liste entfernen?'),
        content: const Text(
          'Die Bibliothek verschwindet nur aus dieser Liste. Fotos, Datenbank '
          'und Ordner bleiben unverändert erhalten und lassen sich jederzeit '
          'wieder hinzufügen.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Entfernen')),
        ],
      ),
    );
    if (bestaetigt != true) return;
    await LibraryLocation.entferneAusListe(b.eintrag.path);
    if (!mounted) return;
    setState(() => _bibliothekenFuture = LibraryLocation.bekannte());
  }

  Future<void> _changeLibraryLocation() async {
    final picked = await LibraryLocation.pickFolder(
      // "Neuer Ordner" im nativen Dialog funktioniert bei ad-hoc-signierten
      // Entwickler-Builds auf macOS 26 nicht (bekannte, von Apple auf
      // XPC-Ebene eingeführte Einschränkung für Apps ohne Entwickler-
      // Zertifikat) – für PhotoVault reicht aber jeder bereits vorhandene
      // Ordner, ein neuer muss also nicht extra im Dialog angelegt werden.
      dialogMessage:
          'Fotos, Videos, Thumbnails und die Datenbank werden in diesen Ordner verschoben. '
          'Bitte einen bereits vorhandenen Ordner wählen (falls nötig vorher im Finder anlegen).',
    );
    if (picked == null || !mounted) return;

    await _runRelocation(
      loadingText: 'Verschiebe Bibliothek …',
      action: () => LibraryLocation.applyRoot(picked, beforeMove: () => widget.library.db.close()),
    );
  }

  Future<void> _resetLibraryLocation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Speicherort zurücksetzen?'),
        content: const Text(
          'Die Bibliothek wird zurück in den Standard-App-Support-Ordner '
          'verschoben. Die App wird danach automatisch geschlossen – bitte '
          'anschließend neu öffnen.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Zurücksetzen')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await _runRelocation(
      loadingText: 'Setze Speicherort zurück …',
      action: () => widget.library.resetLibraryLocation(),
    );
  }

  /// Gemeinsamer Ablauf für Verlegen/Zurücksetzen/Reset: Ladeanzeige → Aktion
  /// ausführen (schließt dabei die DB-Verbindung) → bei Erfolg zum Neustart
  /// auffordern und die App schließen, bei Fehler die bisherigen Daten
  /// unangetastet lassen (siehe [LibraryLocation]) und den Fehler anzeigen.
  Future<void> _runRelocation({
    required String loadingText,
    required Future<void> Function() action,
    String restartMessage = 'Der Speicherort wurde geändert. Die App wird jetzt geschlossen '
        '– bitte danach manuell neu öffnen, damit sie die Bibliothek am '
        'neuen Ort lädt.',
    String errorPrefix = 'Verschieben fehlgeschlagen',
  }) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: 16),
            Expanded(child: Text(loadingText)),
          ],
        ),
      ),
    );

    try {
      await action();
      if (!mounted) return;
      Navigator.of(context).pop(); // Ladeanzeige schließen
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Neustart erforderlich'),
          content: Text(restartMessage),
          actions: [
            FilledButton(onPressed: () => exit(0), child: const Text('Schließen')),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Ladeanzeige schließen
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$errorPrefix: $e')));
      }
    }
  }

  /// Fragt per Wort-Bestätigung nach (siehe [showTypedConfirmDialog], reicht
  /// ein normales Ja/Nein bei so einer unumkehrbaren Aktion nicht) und löscht
  /// danach über [LibraryState.eraseLibraryCompletely] wirklich ALLES – jede
  /// Original-/Vorschaudatei und die komplette Datenbank. Nutzt denselben
  /// Ladeanzeige-/Neustart-Ablauf wie das Verlegen des Speicherorts, da beide
  /// Fälle strukturell identisch sind: die laufende DB-Datei wird unter der
  /// offenen Verbindung weggenommen, ein Neustart ist deshalb zwingend.
  Future<void> _resetDatabase() async {
    final confirmed = await showTypedConfirmDialog(
      context,
      title: 'Datenbank wirklich zurücksetzen?',
      message:
          'Löscht UNWIDERRUFLICH alle Fotos, Videos, Thumbnails und die gesamte '
          'Datenbank dieser Bibliothek (Alben, Personen, Tags, Orte, Favoriten, '
          'gesperrter Ordner, Papierkorb, gespeicherte Suchen, …). '
          'Heruntergeladene KI-Modelle und Geodaten bleiben erhalten. '
          'Erstelle vorher ein Backup, falls du dir nicht sicher bist – '
          'diese Aktion lässt sich NICHT rückgängig machen.',
      confirmationWord: 'ZURÜCKSETZEN',
      confirmLabel: 'Endgültig zurücksetzen',
    );
    if (!confirmed || !mounted) return;

    await _runRelocation(
      loadingText: 'Lösche Bibliothek …',
      action: () => widget.library.eraseLibraryCompletely(),
      restartMessage: 'Die Bibliothek wurde vollständig gelöscht. Die App wird jetzt '
          'geschlossen – bitte danach manuell neu öffnen, um mit einer leeren '
          'Bibliothek neu zu beginnen.',
      errorPrefix: 'Zurücksetzen fehlgeschlagen',
    );
  }

  Future<void> _setupPin() async {
    final ok = await ensureVaultUnlocked(context, widget.library);
    if (ok && mounted) _reloadPinState();
  }

  Future<void> _openLockedFolder() async {
    final ok = await ensureVaultUnlocked(context, widget.library);
    if (!ok || !mounted) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => LockedFolderScreen(library: widget.library)));
  }

  Future<void> _changePin() async {
    final unlocked = await ensureVaultUnlocked(context, widget.library);
    if (!unlocked || !mounted) return;
    final newPin = await showSetPinDialog(context);
    if (newPin == null) return;
    await widget.library.changeVaultPin(newPin);
  }

  Future<void> _removePin() async {
    final unlocked = await ensureVaultUnlocked(context, widget.library);
    if (!unlocked || !mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PIN-Schutz entfernen?'),
        content: const Text(
          'Alle Fotos im gesperrten Ordner werden entschlüsselt und wieder normal sichtbar '
          '(Timeline, Suche, Alben, Personen, Karte, Backup). Das lässt sich nicht rückgängig machen.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Entfernen')),
        ],
      ),
    );
    if (confirm == true) {
      await widget.library.removeVaultPin();
      if (mounted) _reloadPinState();
    }
  }

  Future<void> _lockVaultSession() async {
    widget.library.lockVaultSession();
    await widget.library.clearDecryptCache();
    if (mounted) setState(() {});
  }

  Future<void> _runBackup() async {
    if (_encryptManualBackup) {
      final ok = await ensureBackupKeyAvailable(context, widget.library);
      if (!ok || !mounted) return;
    }
    final destination = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Backup-Ziel wählen (z.B. dein Dropbox- oder Google-Drive-Ordner)',
    );
    if (destination == null || !mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgressDialog(
        title: 'Sichere Bibliothek …',
        stream: widget.library.runManualBackup(destination, encrypt: _encryptManualBackup).map(
              (p) => '${p.done} / ${p.total}${p.currentFile != null ? ' — ${p.currentFile}' : ''}',
            ),
      ),
    );
    _refresh();
  }

  Future<void> _runRestore() async {
    final source = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Backup-Ordner wählen (enthält "PhotoVault-Backup" bzw. "originals")',
    );
    if (source == null || !mounted) return;

    String? passphrase;
    if (await File(p.join(source, 'vault.key')).exists()) {
      if (!mounted) return;
      passphrase = await showEnterPassphraseDialog(context, title: 'Backup-Passphrase eingeben');
      if (passphrase == null) return;
    }

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgressDialog(
        title: 'Stelle Bibliothek wieder her …',
        stream: widget.library.backupService
            .restoreFromBackup(source, widget.library.importService, passphrase: passphrase)
            .map((p) => '${p.done} / ${p.total}${p.currentFile != null ? ' — ${p.currentFile}' : ''}'),
      ),
    );
    _refresh();
  }

  Future<void> _setupBackupPassphrase() async {
    final ok = await ensureBackupKeyAvailable(context, widget.library);
    if (ok && mounted) _reloadBackupKeyState();
  }

  Future<void> _changeBackupPassphrase() async {
    final unlocked = await ensureBackupKeyAvailable(context, widget.library);
    if (!unlocked || !mounted) return;
    final newPass = await showSetPassphraseDialog(context);
    if (newPass == null) return;
    await widget.library.changeBackupPassphrase(newPass);
  }

  Future<void> _removeBackupEncryption() async {
    final unlocked = await ensureBackupKeyAvailable(context, widget.library);
    if (!unlocked || !mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup-Verschlüsselung entfernen?'),
        content: const Text(
          'Neue Backups werden danach nicht mehr verschlüsselt. Bereits bestehende '
          'verschlüsselte Backups am Zielort bleiben unverändert und weiterhin nur mit der '
          'bisherigen Passphrase entschlüsselbar.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Entfernen')),
        ],
      ),
    );
    if (confirm == true) {
      await widget.library.removeBackupEncryption();
      if (mounted) _reloadBackupKeyState();
    }
  }

  Future<void> _runAutoBackupNow() async {
    final ok = await ensureBackupKeyAvailable(context, widget.library);
    if (!ok || !mounted) return;
    final config = await widget.library.db.backupSettingsRow();
    final destination = config?.autoBackupDestination;
    if (destination == null || !mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgressDialog(
        title: 'Automatisches Backup läuft …',
        stream: widget.library.runAutoBackupNow(destination).map(
              (p) => p.total == 0
                  ? 'Keine neuen Dateien – Datenbank-Schnappschuss wird aktualisiert.'
                  : '${p.done} / ${p.total}${p.currentFile != null ? ' — ${p.currentFile}' : ''}',
            ),
      ),
    );
    if (mounted) _reloadBackupSettings();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('Erscheinungsbild', style: Theme.of(context).textTheme.titleMedium),
        Card(
          child: StreamBuilder<AppSettingsData?>(
            stream: widget.library.db.watchAppSettings(),
            builder: (context, snapshot) {
              final mode = themeModeFromString(snapshot.data?.themeMode);
              return ListTile(
                leading: const Icon(Icons.contrast_outlined),
                title: const Text('Design'),
                subtitle: SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(value: ThemeMode.light, label: Text('Hell'), icon: Icon(Icons.light_mode_outlined)),
                    ButtonSegment(value: ThemeMode.dark, label: Text('Dunkel'), icon: Icon(Icons.dark_mode_outlined)),
                    ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.brightness_auto_outlined)),
                  ],
                  selected: {mode},
                  onSelectionChanged: (selection) =>
                      widget.library.db.setThemeMode(themeModeToString(selection.first)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Text('Bibliotheken', style: Theme.of(context).textTheme.titleMedium),
        Card(
          child: FutureBuilder<List<BibliothekMitZustand>>(
            future: _bibliothekenFuture,
            builder: (context, snapshot) {
              final eintraege = snapshot.data;
              if (eintraege == null) {
                return const Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                );
              }
              return Column(
                children: [
                  for (final b in eintraege)
                    ListTile(
                      leading: Icon(
                        b.istAktiv ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                        color: b.istAktiv ? Theme.of(context).colorScheme.primary : null,
                      ),
                      title: Text(
                        b.eintrag.name,
                        style: b.erreichbar
                            ? null
                            : TextStyle(color: Theme.of(context).disabledColor),
                      ),
                      subtitle: Text(
                        b.erreichbar
                            ? b.eintrag.path
                            : 'Ordner nicht gefunden – Laufwerk eingebunden?',
                      ),
                      // `enabled` steuert die Einfärbung, nicht die
                      // Antippbarkeit: Die aktive Bibliothek ist zwar nicht
                      // antippbar (man ist ja schon drin), darf aber nicht
                      // ausgegraut erscheinen – ausgegraut heißt hier
                      // "nicht erreichbar".
                      enabled: b.erreichbar,
                      onTap: b.erreichbar && !b.istAktiv ? () => _wechsleBibliothek(b) : null,
                      trailing: b.istAktiv
                          ? const Text('aktiv')
                          : IconButton(
                              icon: const Icon(Icons.playlist_remove),
                              tooltip: 'Aus der Liste entfernen (löscht keine Fotos)',
                              onPressed: () => _entferneBibliothek(b),
                            ),
                    ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _bibliothekHinzufuegen,
                            icon: const Icon(Icons.library_add_outlined),
                            label: const Text('Bibliothek hinzufügen…'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                    child: Text(
                      'Ein Wechsel biegt nur um, welche Bibliothek geöffnet wird – '
                      'es werden keine Fotos verschoben. Zum Verlegen der aktuellen '
                      'Bibliothek an einen anderen Ort dient „Speicherort ändern" weiter unten.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Text('Speicherort der aktiven Bibliothek',
            style: Theme.of(context).textTheme.titleMedium),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: const Text('Speicherort'),
                subtitle: Text(widget.library.paths.root.path),
                trailing: IconButton(
                  icon: const Icon(Icons.open_in_new),
                  tooltip: 'Im Finder anzeigen',
                  onPressed: () => _openInFinder(widget.library.paths.root.path),
                ),
              ),
              const Divider(height: 1),
              FutureBuilder<bool>(
                future: _isCustomLocationFuture,
                builder: (context, snapshot) {
                  final isCustom = snapshot.data ?? false;
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _changeLibraryLocation,
                            icon: const Icon(Icons.drive_file_move_outline),
                            label: const Text('Ändern…'),
                          ),
                        ),
                        if (isCustom) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _resetLibraryLocation,
                              icon: const Icon(Icons.restart_alt),
                              label: const Text('Zurücksetzen'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.sd_storage_outlined),
                title: const Text('Speicherbedarf (Originale)'),
                subtitle: Text(_sizeBytes == null ? 'wird berechnet …' : _formatBytes(_sizeBytes!)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('KI-Modelle (lokal & quelloffen)', style: Theme.of(context).textTheme.titleMedium),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Text(
            'Wie bei digiKam laufen alle KI-Funktionen offline auf diesem Rechner. '
            'Die Modelldateien werden nicht mitgeliefert, sondern bei Bedarf aus '
            'offiziellen Open-Source-Quellen heruntergeladen (einmalig, danach '
            'komplett offline nutzbar).',
            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline),
          ),
        ),
        FutureBuilder<bool>(
          future: widget.library.db.autoAnalyzeAfterImportEnabled(),
          builder: (context, snapshot) {
            final an = snapshot.data ?? true;
            return Card(
              child: SwitchListTile(
                value: an,
                onChanged: (v) async {
                  await widget.library.db.setAutoAnalyzeAfterImport(v);
                  if (mounted) setState(() {});
                },
                secondary: const Icon(Icons.schedule_outlined),
                title: const Text('KI-Auswertung nach dem Import automatisch nachholen'),
                isThreeLine: true,
                subtitle: const Text(
                  'Der Import legt die Fotos nur ab und bleibt dadurch schnell. '
                  'Gesichter, Texterkennung, Bildsuche und Bildbeschreibung laufen '
                  'danach im Hintergrund nach. Ausgeschaltet lässt sich das '
                  'jederzeit unter Werkzeuge von Hand anstoßen.',
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        for (final entry in ModelCatalog.all)
          _ModelCard(
            entry: entry,
            installed: widget.library.isModelInstalled(entry),
            downloading: _downloading.contains(entry.id),
            groesse: widget.library.isModelInstalled(entry)
                ? _formatBytes(widget.library.modelDownloadService.belegteBytes(entry))
                : null,
            onDownload: () => _downloadModel(entry),
            onDelete: () => _deleteModel(entry),
          ),
        // Der Modellordner wächst schnell auf über ein Gigabyte, ohne dass
        // das bisher irgendwo stand.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            'Belegter Platz aller Modelle: '
            '${_formatBytes(widget.library.modelDownloadService.gesamteBytes())}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.face_outlined),
            title: const Text('Gesichtserkennung aktiv'),
            subtitle: Text(widget.library.faceDetectionAvailable
                ? (widget.library.faceRecognitionAvailable
                    ? 'Erkennung + Wiedererkennungs-Embeddings aktiv'
                    : 'Nur Erkennung aktiv (Wiedererkennung: SFace-Modell fehlt noch)')
                : 'Inaktiv – YuNet-Modell oben herunterladen'),
          ),
        ),
        const SizedBox(height: 20),
        Text('Hintergrundaufgaben', style: Theme.of(context).textTheme.titleMedium),
        Card(
          child: ListTile(
            leading: const Icon(Icons.pending_actions_outlined),
            title: const Text('Aufgaben-Übersicht'),
            subtitle: const Text('Alle Auswertungen mit Anzahl noch offener Fotos, einzeln anstoßbar'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => BackgroundTasksScreen(library: widget.library)),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('KI-Tagging-Vokabular', style: Theme.of(context).textTheme.titleMedium),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Text(
            'Begriffe, die automatisch per KI-Bildsuche-Modell (CLIP) auf neu importierte Fotos '
            'angewendet werden. Änderungen hier gelten nur für künftige Fotos – um sie '
            'rückwirkend auf die vorhandene Bibliothek anzuwenden, siehe Werkzeuge → '
            '"KI-Tags berechnen" → "Alle Fotos".',
            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder<List<AiTagVocabularyData>>(
                  stream: widget.library.db.watchAiTagVocabulary(),
                  builder: (context, snapshot) {
                    final terms = snapshot.data ?? [];
                    if (terms.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final entry in terms)
                            InputChip(
                              label: Text(entry.term),
                              onDeleted: () => widget.library.db.removeAiTagTerm(entry.id),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _aiTagVocabularyController,
                        decoration: const InputDecoration(
                          hintText: 'Begriff hinzufügen …',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _addAiTagVocabularyTerm(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      tooltip: 'Begriff hinzufügen',
                      onPressed: _addAiTagVocabularyTerm,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('Standortdaten (lokal & quelloffen)', style: Theme.of(context).textTheme.titleMedium),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Text(
            'Ordnet dem GPS-Ort eines Fotos Land, Bundesland/Provinz und Stadt zu – komplett '
            'lokal über die nächstgelegene bekannte Stadt (GeoNames-Datensatz), ohne Anfrage an '
            'einen Online-Kartendienst. Für die Land-/Bundesland-/Stadt-Filter in den '
            'Suchoptionen nötig.',
            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(
              widget.library.geoDataAvailable ? Icons.check_circle : Icons.cloud_download_outlined,
              color: widget.library.geoDataAvailable ? Colors.green : null,
            ),
            title: const Text('GeoNames – Städte, Länder, Bundesländer'),
            subtitle: const Text(
              'Städte ab 1000 Einwohnern weltweit (~10 MB). Lizenz: ${GeoDataCatalog.license}.',
            ),
            trailing: _downloadingGeoData
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                : widget.library.geoDataAvailable
                    ? IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'GeoNames-Datensatz löschen',
                        onPressed: _deleteGeoData,
                      )
                    : FilledButton(onPressed: _downloadGeoData, child: const Text('Herunterladen')),
          ),
        ),
        const SizedBox(height: 20),
        Text('Gesperrter Ordner', style: Theme.of(context).textTheme.titleMedium),
        Card(
          child: FutureBuilder<bool>(
            future: _hasPinSetFuture,
            builder: (context, snapshot) {
              final hasPin = snapshot.data ?? false;
              if (!hasPin) {
                return ListTile(
                  leading: const Icon(Icons.enhanced_encryption_outlined),
                  title: const Text('PIN einrichten'),
                  subtitle: const Text(
                    'Verschlüsselt private Fotos mit AES-256 (echte Verschlüsselung, nicht '
                    'nur ein Anzeige-Filter) und blendet sie überall sonst (Timeline, Suche, '
                    'Alben, Personen, Karte, Backup) aus. Ohne den PIN gibt es keine '
                    'Wiederherstellung.',
                  ),
                  isThreeLine: true,
                  trailing: FilledButton(onPressed: _setupPin, child: const Text('Einrichten')),
                );
              }
              final unlocked = widget.library.vaultUnlockedThisSession;
              return Column(
                children: [
                  ListTile(
                    leading: Icon(unlocked ? Icons.lock_open_outlined : Icons.lock_outline),
                    title: const Text('Gesperrter Ordner'),
                    subtitle: Text(unlocked
                        ? 'PIN eingerichtet – für diese Sitzung bereits entsperrt.'
                        : 'PIN eingerichtet.'),
                    trailing: FilledButton.icon(
                      onPressed: _openLockedFolder,
                      icon: const Icon(Icons.lock_open_outlined),
                      label: const Text('Öffnen'),
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(onPressed: _changePin, child: const Text('PIN ändern')),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(onPressed: _removePin, child: const Text('PIN entfernen')),
                        ),
                      ],
                    ),
                  ),
                  if (unlocked)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                      child: SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: _lockVaultSession,
                          icon: const Icon(Icons.lock_clock_outlined),
                          label: const Text('Sitzung jetzt sperren'),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Text('Backup-Verschlüsselung', style: Theme.of(context).textTheme.titleMedium),
        Card(
          child: FutureBuilder<bool>(
            future: _hasBackupKeyFuture,
            builder: (context, snapshot) {
              final hasKey = snapshot.data ?? false;
              if (!hasKey) {
                return ListTile(
                  leading: const Icon(Icons.enhanced_encryption_outlined),
                  title: const Text('Passphrase einrichten'),
                  subtitle: const Text(
                    'Ermöglicht, manuelle und automatische Backups mit AES-256 zu '
                    'verschlüsseln. Eigene Passphrase, unabhängig vom PIN des gesperrten '
                    'Ordners – ein Backup landet oft extern und muss auch ohne diesen '
                    'Rechner entschlüsselbar sein.',
                  ),
                  isThreeLine: true,
                  trailing: FilledButton(onPressed: _setupBackupPassphrase, child: const Text('Einrichten')),
                );
              }
              final unlocked = widget.library.backupKeyAvailableThisSession;
              return Column(
                children: [
                  ListTile(
                    leading: Icon(unlocked ? Icons.lock_open_outlined : Icons.lock_outline),
                    title: const Text('Backup-Passphrase'),
                    subtitle: Text(unlocked
                        ? 'Eingerichtet – für diese Sitzung bereits entsperrt.'
                        : 'Eingerichtet – wird beim nächsten Backup abgefragt.'),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                              onPressed: _changeBackupPassphrase, child: const Text('Ändern')),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                              onPressed: _removeBackupEncryption, child: const Text('Entfernen')),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Text('Manuelles Cloud-Backup', style: Theme.of(context).textTheme.titleMedium),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Letztes Backup'),
                subtitle: Text(_lastBackup == null
                    ? 'Noch nie gesichert.'
                    : '${_lastBackup!.performedAt.day}.${_lastBackup!.performedAt.month}.'
                        '${_lastBackup!.performedAt.year} – ${_lastBackup!.fileCount} Datei(en) nach '
                        '${_lastBackup!.destinationPath}'),
              ),
              const Divider(height: 1),
              CheckboxListTile(
                value: _encryptManualBackup,
                onChanged: (v) => setState(() => _encryptManualBackup = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('Backup verschlüsseln'),
                subtitle: const Text('Fragt bei Bedarf die Backup-Passphrase von oben ab.'),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _runBackup,
                        icon: const Icon(Icons.backup_outlined),
                        label: const Text('Jetzt sichern'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _runRestore,
                        icon: const Icon(Icons.settings_backup_restore),
                        label: const Text('Wiederherstellen'),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                child: Text(
                  'Wähle als Ziel z.B. deinen lokalen Dropbox- oder Google-Drive-'
                  'Ordner – die Desktop-App des jeweiligen Anbieters lädt die '
                  'Dateien dann automatisch in die Cloud hoch.',
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('Automatisches Backup', style: Theme.of(context).textTheme.titleMedium),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Text(
            'Läuft nur, während die App geöffnet ist (kein Hintergrunddienst) – prüft beim '
            'Start und danach alle 30 Minuten, ob das Intervall abgelaufen ist. Sichert immer '
            'verschlüsselt, zusätzlich zu den Originaldateien auch einen Schnappschuss der '
            'gesamten Datenbank (Gesichter, Orte, Tags, Alben, Favoriten, …), damit sich bei '
            'Datenverlust der komplette Zustand wiederherstellen lässt. Löscht am Zielort nie '
            'etwas – lokale Löschungen werden bewusst nicht nachvollzogen.',
            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline),
          ),
        ),
        Card(
          child: FutureBuilder<BackupSettingsData?>(
            future: _backupSettingsFuture,
            builder: (context, snapshot) {
              final config = snapshot.data;
              final enabled = config?.autoBackupEnabled ?? false;
              final destination = config?.autoBackupDestination;
              final intervalHours = config?.autoBackupIntervalHours ?? 24;
              final maxMbPerRun = config?.autoBackupMaxMbPerRun ?? 0;
              final lastRun = config?.lastAutoBackupAt;
              final keyReady = widget.library.backupKeyAvailableThisSession;

              return Column(
                children: [
                  SwitchListTile(
                    value: enabled,
                    onChanged: destination == null
                        ? null
                        : (v) async {
                            await widget.library.db.setAutoBackupConfig(enabled: v);
                            if (mounted) _reloadBackupSettings();
                          },
                    title: const Text('Aktiv'),
                    subtitle: Text(destination ?? 'Zuerst einen Zielordner wählen.'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.folder_outlined),
                    title: const Text('Zielordner'),
                    subtitle: Text(destination ?? 'Kein Ordner gewählt.'),
                    trailing: OutlinedButton(
                      onPressed: () async {
                        final picked = await FilePicker.platform.getDirectoryPath(
                          dialogTitle: 'Zielordner für automatisches Backup wählen',
                        );
                        if (picked == null) return;
                        await widget.library.db
                            .setAutoBackupConfig(enabled: enabled, destination: picked);
                        if (mounted) _reloadBackupSettings();
                      },
                      child: const Text('Wählen…'),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.schedule_outlined),
                    title: const Text('Intervall'),
                    trailing: DropdownButton<int>(
                      value: intervalHours,
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Stündlich')),
                        DropdownMenuItem(value: 6, child: Text('Alle 6 Stunden')),
                        DropdownMenuItem(value: 24, child: Text('Täglich')),
                        DropdownMenuItem(value: 168, child: Text('Wöchentlich')),
                      ],
                      onChanged: (v) async {
                        if (v == null) return;
                        await widget.library.db
                            .setAutoBackupConfig(enabled: enabled, intervalHours: v);
                        if (mounted) _reloadBackupSettings();
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.speed_outlined),
                    title: const Text('Menge je Lauf'),
                    subtitle: const Text(
                      'Begrenzt, wie viel pro Durchlauf ins Ziel geschrieben wird. '
                      'Sinnvoll bei Cloud-Ordnern: Der Upload kommt sonst tagelang '
                      'nicht hinterher. Der Rest folgt beim nächsten Intervall.',
                      style: TextStyle(fontSize: 12),
                    ),
                    isThreeLine: true,
                    trailing: DropdownButton<int>(
                      value: maxMbPerRun,
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('Unbegrenzt')),
                        DropdownMenuItem(value: 500, child: Text('500 MB')),
                        DropdownMenuItem(value: 2000, child: Text('2 GB')),
                        DropdownMenuItem(value: 10000, child: Text('10 GB')),
                      ],
                      onChanged: (v) async {
                        if (v == null) return;
                        await widget.library.db.setAutoBackupMaxMbPerRun(v);
                        if (mounted) _reloadBackupSettings();
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('Letzter Lauf'),
                    subtitle: Text(lastRun == null
                        ? 'Noch nie ausgeführt.'
                        : '${lastRun.day}.${lastRun.month}.${lastRun.year} – '
                            '${lastRun.hour.toString().padLeft(2, '0')}:'
                            '${lastRun.minute.toString().padLeft(2, '0')}'),
                  ),
                  if (enabled && !keyReady)
                    const Padding(
                      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xs),
                      child: Text(
                        'Backup-Passphrase muss für diese Sitzung noch entsperrt werden, bevor '
                        'das automatische Backup laufen kann – z.B. über "Jetzt synchronisieren".',
                        style: TextStyle(fontSize: 12, color: Colors.orange),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: destination == null ? null : _runAutoBackupNow,
                        icon: const Icon(Icons.sync),
                        label: const Text('Jetzt synchronisieren'),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Text('Papierkorb automatisch leeren', style: Theme.of(context).textTheme.titleMedium),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Text(
            'Löscht in den Papierkorb verschobene Fotos/Videos nach Ablauf der '
            'gewählten Frist endgültig – unwiderruflich, auch aus dem PIN-geschützten '
            'Papierkorb des gesperrten Ordners. Standardmäßig deaktiviert.',
            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline),
          ),
        ),
        Card(
          child: FutureBuilder<TrashSettingsData?>(
            future: _trashSettingsFuture,
            builder: (context, snapshot) {
              final config = snapshot.data;
              final enabled = config?.autoDeleteEnabled ?? false;
              final afterDays = config?.autoDeleteAfterDays ?? 30;
              final lastRun = config?.lastPurgeAt;

              return Column(
                children: [
                  SwitchListTile(
                    value: enabled,
                    onChanged: (v) async {
                      await widget.library.db.setTrashAutoDeleteConfig(enabled: v);
                      if (mounted) _reloadTrashSettings();
                    },
                    title: const Text('Aktiv'),
                    subtitle: const Text('Papierkorb-Ablauf ist standardmäßig ausgeschaltet.'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.timelapse_outlined),
                    title: const Text('Nach'),
                    trailing: DropdownButton<int>(
                      value: afterDays,
                      items: const [
                        DropdownMenuItem(value: 7, child: Text('7 Tagen')),
                        DropdownMenuItem(value: 14, child: Text('14 Tagen')),
                        DropdownMenuItem(value: 30, child: Text('30 Tagen')),
                        DropdownMenuItem(value: 60, child: Text('60 Tagen')),
                        DropdownMenuItem(value: 90, child: Text('90 Tagen')),
                      ],
                      onChanged: (v) async {
                        if (v == null) return;
                        await widget.library.db.setTrashAutoDeleteConfig(enabled: enabled, afterDays: v);
                        if (mounted) _reloadTrashSettings();
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('Letzter Lauf'),
                    subtitle: Text(lastRun == null
                        ? 'Noch nie ausgeführt.'
                        : '${lastRun.day}.${lastRun.month}.${lastRun.year} – '
                            '${lastRun.hour.toString().padLeft(2, '0')}:'
                            '${lastRun.minute.toString().padLeft(2, '0')}'),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 28),
        Text('Gefahrenzone',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.error)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Text(
            'Löscht unwiderruflich ALLE Fotos, Videos und die gesamte Datenbank dieser '
            'Bibliothek und beginnt danach mit einer leeren Bibliothek neu. Heruntergeladene '
            'KI-Modelle und Geodaten bleiben erhalten (kein erneuter Download nötig).',
            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline),
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: BorderSide(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.4)),
          ),
          child: ListTile(
            leading: Icon(Icons.warning_amber_outlined, color: Theme.of(context).colorScheme.error),
            title: const Text('Datenbank zurücksetzen'),
            subtitle: const Text('Löscht alle Medien und Metadaten – nicht rückgängig zu machen.'),
            trailing: OutlinedButton(
              style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              onPressed: _resetDatabase,
              child: const Text('Zurücksetzen…'),
            ),
          ),
        ),
      ],
    );
  }
}

class _ModelCard extends StatelessWidget {
  final ModelCatalogEntry entry;
  final bool installed;
  final bool downloading;
  /// Belegter Platz, bereits lesbar formatiert – null, solange das Modell
  /// nicht installiert ist. Vorher lässt sich die Grösse nicht angeben:
  /// Der Katalog führt nur Dateinamen und Prüfsummen, keine Längen.
  final String? groesse;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  const _ModelCard({
    required this.entry,
    required this.installed,
    required this.downloading,
    required this.groesse,
    required this.onDownload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          installed ? Icons.check_circle : Icons.cloud_download_outlined,
          color: installed ? Colors.green : null,
        ),
        title: Text(entry.title),
        subtitle: Text('${entry.description}\nLizenz: ${entry.license}'
            '${groesse != null ? ' · $groesse' : ''}'),
        isThreeLine: true,
        trailing: downloading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
            : installed
                ? IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Modell löschen',
                    onPressed: onDelete,
                  )
                : FilledButton(onPressed: onDownload, child: const Text('Herunterladen')),
      ),
    );
  }
}

