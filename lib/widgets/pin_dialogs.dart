import 'package:flutter/material.dart';

import '../state/library_state.dart';
import '../theme/app_spacing.dart';

/// Fragt einen PIN ab (z.B. um den gesperrten Ordner zu öffnen oder eine
/// Änderung zu bestätigen). Gibt `null` zurück, wenn abgebrochen wurde.
/// `maxLength` deckt auch schon bestehende, mit einer älteren (4-6-stelligen)
/// Richtlinie eingerichtete PINs ab – siehe [showSetPinDialog].
Future<String?> showEnterPinDialog(BuildContext context, {String title = 'PIN eingeben'}) async {
  final ctrl = TextEditingController();
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        obscureText: true,
        keyboardType: TextInputType.number,
        maxLength: 10,
        decoration: const InputDecoration(labelText: 'PIN', counterText: ''),
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
        FilledButton(onPressed: () => Navigator.pop(context, ctrl.text), child: const Text('OK')),
      ],
    ),
  );
  ctrl.dispose();
  return result;
}

/// Lässt einen neuen PIN zweimal eingeben (Bestätigung), validiert
/// clientseitig auf 8-10 Ziffern und Übereinstimmung. Mindestlänge bewusst
/// auf 8 angehoben (statt zuvor 6) – bei einem exfiltrierten
/// `library.sqlite` lässt sich der verpackte Master-Key offline durchprobieren,
/// ganz ohne Sperre nach Fehlversuchen (die es bei einer rein lokalen App ohne
/// Server naturgemäß nicht geben kann). Selbst mit dem bewusst kostspieligen
/// Argon2id (siehe VaultCrypto) bleibt ein 6-stelliger PIN (nur 1 Million
/// Kombinationen) in einem für einen entschlossenen Angreifer praktikablen
/// Zeitrahmen knackbar; 8 Stellen (100 Millionen Kombinationen) verschieben
/// das in einen deutlich unpraktikableren Bereich, ohne die App auf ein
/// alphanumerisches Passwort umzustellen. Gibt den neuen PIN zurück oder
/// `null` bei Abbruch.
Future<String?> showSetPinDialog(BuildContext context) async {
  final pinCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  String? error;
  final result = await showDialog<String>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('PIN festlegen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pinCtrl,
              autofocus: true,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 10,
              decoration: const InputDecoration(labelText: 'Neuer PIN (8-10 Ziffern)', counterText: ''),
            ),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 10,
              decoration: const InputDecoration(labelText: 'PIN wiederholen', counterText: ''),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
            const Padding(
              padding: EdgeInsets.only(top: AppSpacing.md),
              child: Text(
                'Wichtig: Fotos im gesperrten Ordner werden echt verschlüsselt (AES-256). '
                'Ohne diesen PIN gibt es KEINE Möglichkeit, sie wiederherzustellen – auch '
                'nicht durch Zurücksetzen der App.',
                style: TextStyle(fontSize: 12, color: Colors.orange),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
          FilledButton(
            onPressed: () {
              final pin = pinCtrl.text.trim();
              final confirm = confirmCtrl.text.trim();
              if (pin.length < 8 || pin.length > 10 || int.tryParse(pin) == null) {
                setState(() => error = 'PIN muss aus 8-10 Ziffern bestehen.');
                return;
              }
              if (pin != confirm) {
                setState(() => error = 'PINs stimmen nicht überein.');
                return;
              }
              Navigator.pop(context, pin);
            },
            child: const Text('Festlegen'),
          ),
        ],
      ),
    ),
  );
  pinCtrl.dispose();
  confirmCtrl.dispose();
  return result;
}

/// Sorgt dafür, dass der Master-Key des gesperrten Ordners für die laufende
/// Sitzung im Speicher vorliegt: fragt bei Bedarf den PIN ab, oder führt bei
/// noch nicht eingerichtetem PIN direkt durch die Einrichtung. Wird sowohl
/// beim Sperren eines Fotos (Vollbildansicht) als auch beim Öffnen des
/// gesperrten Ordners (Einstellungen) aufgerufen – dank
/// [LibraryState.vaultUnlockedThisSession] muss dadurch nicht mehrfach pro
/// Sitzung nach dem PIN gefragt werden. Gibt `true` zurück, wenn der
/// gesperrte Ordner danach entsperrt ist.
Future<bool> ensureVaultUnlocked(BuildContext context, LibraryState library) async {
  if (library.vaultUnlockedThisSession) return true;

  if (!await library.db.hasPinSet()) {
    if (!context.mounted) return false;
    final pin = await showSetPinDialog(context);
    if (pin == null) return false;
    await library.setupVaultPin(pin);
    return true;
  }

  if (!context.mounted) return false;
  final pin = await showEnterPinDialog(context, title: 'PIN eingeben');
  if (pin == null) return false;
  try {
    await library.unlockVaultWithPin(pin);
    return true;
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Falscher PIN.')));
    }
    return false;
  }
}

/// Fragt eine Backup-Passphrase ab (z.B. um verschlüsselte Backups zu
/// entsperren). Anders als der PIN des gesperrten Ordners bewusst kein
/// Zahlenfeld/keine Längenbegrenzung – ein Backup liegt oft langfristig
/// extern (Cloud-Ordner, externe Platte), eine kurze PIN wäre dafür zu
/// schwach. Gibt `null` zurück, wenn abgebrochen wurde.
Future<String?> showEnterPassphraseDialog(BuildContext context, {String title = 'Backup-Passphrase eingeben'}) async {
  final ctrl = TextEditingController();
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        obscureText: true,
        decoration: const InputDecoration(labelText: 'Passphrase'),
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
        FilledButton(onPressed: () => Navigator.pop(context, ctrl.text), child: const Text('OK')),
      ],
    ),
  );
  ctrl.dispose();
  return result;
}

/// Lässt eine neue Backup-Passphrase zweimal eingeben (Bestätigung),
/// validiert clientseitig auf mindestens 8 Zeichen und Übereinstimmung.
/// Gibt die neue Passphrase zurück oder `null` bei Abbruch.
Future<String?> showSetPassphraseDialog(BuildContext context) async {
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  String? error;
  final result = await showDialog<String>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Backup-Passphrase festlegen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: passCtrl,
              autofocus: true,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Neue Passphrase (mind. 8 Zeichen)'),
            ),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Passphrase wiederholen'),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
            const Padding(
              padding: EdgeInsets.only(top: AppSpacing.md),
              child: Text(
                'Wichtig: Backups werden echt verschlüsselt (AES-256). Ohne diese '
                'Passphrase gibt es KEINE Möglichkeit, sie wiederherzustellen – auch '
                'nicht auf einem anderen Rechner. Am besten zusätzlich an einem sicheren '
                'Ort notieren.',
                style: TextStyle(fontSize: 12, color: Colors.orange),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
          FilledButton(
            onPressed: () {
              final pass = passCtrl.text;
              final confirm = confirmCtrl.text;
              if (pass.length < 8) {
                setState(() => error = 'Passphrase muss mindestens 8 Zeichen lang sein.');
                return;
              }
              if (pass != confirm) {
                setState(() => error = 'Passphrasen stimmen nicht überein.');
                return;
              }
              Navigator.pop(context, pass);
            },
            child: const Text('Festlegen'),
          ),
        ],
      ),
    ),
  );
  passCtrl.dispose();
  confirmCtrl.dispose();
  return result;
}

/// Sorgt dafür, dass der Backup-Master-Key für die laufende Sitzung im
/// Speicher vorliegt – analog zu [ensureVaultUnlocked], aber für die
/// Backup-Verschlüsselung (eigene Passphrase, eigener Schlüssel). Wird vor
/// jedem manuellen oder automatischen verschlüsselten Backup aufgerufen.
Future<bool> ensureBackupKeyAvailable(BuildContext context, LibraryState library) async {
  if (library.backupKeyAvailableThisSession) return true;

  if (!await library.db.hasBackupKey()) {
    if (!context.mounted) return false;
    final pass = await showSetPassphraseDialog(context);
    if (pass == null) return false;
    await library.setupBackupPassphrase(pass);
    return true;
  }

  if (!context.mounted) return false;
  final pass = await showEnterPassphraseDialog(context);
  if (pass == null) return false;
  try {
    await library.unlockBackupKeyWithPassphrase(pass);
    return true;
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Falsche Passphrase.')));
    }
    return false;
  }
}
