import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Größe der Klartext-Chunks beim Ver-/Entschlüsseln einer Datei – erlaubt
/// Streaming mit konstantem Speicherbedarf, auch für mehrere Gigabyte große
/// Videos, statt eine Datei komplett in den Speicher zu laden.
const int _chunkSize = 1 << 20; // 1 MiB

/// Länge des AES-256-GCM-Authentifizierungs-Tags in Bytes.
const int _macLength = 16;

const List<int> _magic = [0x50, 0x56, 0x45, 0x31]; // "PVE1"

/// Ergebnis von [VaultCrypto.createMasterKey]/[VaultCrypto.wrapMasterKey]:
/// alles, was zusätzlich zum Master-Key selbst in [PrivacySettings]
/// gespeichert werden muss, um ihn später mit demselben PIN wieder
/// entpacken zu können.
class WrappedMasterKey {
  final SecretKey masterKey;
  final Uint8List kdfSalt;
  final Uint8List nonce;
  final Uint8List wrapped;
  const WrappedMasterKey({
    required this.masterKey,
    required this.kdfSalt,
    required this.nonce,
    required this.wrapped,
  });
}

/// AES-256-GCM-Dateiverschlüsselung + PIN-basiertes "Envelope Encryption"
/// für den gesperrten Ordner (siehe Klassenkommentar in [PrivacySettings]).
///
/// Architektur: ein einmalig zufällig erzeugter 256-Bit-"Master-Key"
/// verschlüsselt tatsächlich die Dateien. Der PIN selbst verschlüsselt (=
/// "wrapped") nur diesen Master-Key – über Argon2id, damit ein Angreifer mit
/// Zugriff auf die Datenbank nicht einfach alle 10.000-1.000.000
/// PIN-Kombinationen durchprobieren kann. Der Vorteil dieser Trennung: ein
/// PIN-Wechsel muss nur den (kurzen) Master-Key neu verpacken, nicht alle
/// Dateien neu verschlüsseln.
///
/// WICHTIG: Es gibt bewusst keine Wiederherstellung ohne PIN – wer den PIN
/// vergisst, kann die gesperrten Fotos nicht mehr entschlüsseln. Das ist der
/// Preis für echte Verschlüsselung statt eines reinen Anzeige-Filters.
class VaultCrypto {
  VaultCrypto._();

  static final AesGcm _cipher = AesGcm.with256bits();

  /// Bewusst moderate statt maximale Argon2id-Parameter: die reine
  /// Dart-Implementierung (keine native Beschleunigung, siehe pubspec.yaml)
  /// wäre bei OWASP-Empfehlungswerten spürbar langsam beim Entsperren. Immer
  /// noch deutlich widerstandsfähiger gegen Offline-Brute-Force als ein
  /// einfacher, schneller Hash.
  static final Argon2id _kdf = Argon2id(
    parallelism: 1,
    memory: 65536, // 64 MiB
    iterations: 3,
    hashLength: 32,
  );

  static Uint8List _randomBytes(int length) {
    final rnd = Random.secure();
    return Uint8List.fromList(List.generate(length, (_) => rnd.nextInt(256)));
  }

  static Future<SecretKey> _deriveWrappingKey(String pin, List<int> salt) =>
      _kdf.deriveKeyFromPassword(password: pin, nonce: salt);

  /// Erzeugt einen neuen zufälligen Master-Key und verpackt ihn direkt mit
  /// [pin] – für die Erst-Einrichtung des gesperrten Ordners.
  static Future<WrappedMasterKey> createMasterKey(String pin) async {
    final masterKey = await _cipher.newSecretKey();
    return wrapMasterKey(masterKey, pin);
  }

  /// Verpackt einen (neuen oder bestehenden) Master-Key mit [pin] – für die
  /// Erst-Einrichtung und für einen PIN-Wechsel (dort mit dem unverändert
  /// bleibenden, bereits vorhandenen Master-Key).
  static Future<WrappedMasterKey> wrapMasterKey(SecretKey masterKey, String pin) async {
    final salt = _randomBytes(16);
    final wrappingKey = await _deriveWrappingKey(pin, salt);
    final masterKeyBytes = await masterKey.extractBytes();
    final nonce = _cipher.newNonce();
    final box = await _cipher.encrypt(masterKeyBytes, secretKey: wrappingKey, nonce: nonce);
    return WrappedMasterKey(
      masterKey: masterKey,
      kdfSalt: salt,
      nonce: Uint8List.fromList(nonce),
      wrapped: Uint8List.fromList([...box.cipherText, ...box.mac.bytes]),
    );
  }

  /// Entpackt den Master-Key mit [pin]. Wirft [SecretBoxAuthenticationError],
  /// wenn der PIN falsch ist (GCM-Authentifizierung schlägt fehl) – das ist
  /// zugleich die einzige PIN-Prüfung der App, es gibt keinen separat
  /// gespeicherten PIN-Hash mehr.
  static Future<SecretKey> unwrapMasterKey(
    String pin, {
    required List<int> kdfSalt,
    required List<int> nonce,
    required List<int> wrapped,
  }) async {
    final wrappingKey = await _deriveWrappingKey(pin, kdfSalt);
    final cipherText = wrapped.sublist(0, wrapped.length - _macLength);
    final mac = Mac(wrapped.sublist(wrapped.length - _macLength));
    final box = SecretBox(cipherText, nonce: nonce, mac: mac);
    final masterKeyBytes = await _cipher.decrypt(box, secretKey: wrappingKey);
    return SecretKey(masterKeyBytes);
  }

  /// Verschlüsselt [source] chunkweise nach [destination]. Dateiformat:
  /// 4 Bytes Magic, danach beliebig viele Chunks aus je
  /// [4 Bytes Klartextlänge][12 Bytes Nonce][Chiffretext][16 Bytes GCM-Tag].
  /// Jeder Chunk ist unabhängig authentifiziert.
  static Future<void> encryptFile(File source, File destination, SecretKey masterKey) async {
    final input = await source.open(mode: FileMode.read);
    final sink = destination.openWrite();
    try {
      sink.add(_magic);
      while (true) {
        final chunk = await input.read(_chunkSize);
        if (chunk.isEmpty) break;
        final nonce = _cipher.newNonce();
        final box = await _cipher.encrypt(chunk, secretKey: masterKey, nonce: nonce);
        final header = ByteData(4)..setUint32(0, chunk.length, Endian.big);
        sink.add(header.buffer.asUint8List());
        sink.add(nonce);
        sink.add(box.cipherText);
        sink.add(box.mac.bytes);
      }
      await sink.flush();
    } finally {
      await input.close();
      await sink.close();
    }
  }

  /// Entschlüsselt eine mit [encryptFile] erzeugte Datei. Wirft
  /// [FormatException] bei falschem Datei-Format bzw.
  /// [SecretBoxAuthenticationError], wenn ein Chunk manipuliert/beschädigt
  /// ist oder der falsche Master-Key übergeben wurde.
  static Future<void> decryptFile(File source, File destination, SecretKey masterKey) async {
    final input = await source.open(mode: FileMode.read);
    final sink = destination.openWrite();
    try {
      final magic = await input.read(_magic.length);
      if (magic.length != _magic.length || !_bytesEqual(magic, _magic)) {
        throw const FormatException('Keine gültige verschlüsselte Vault-Datei.');
      }
      while (true) {
        final header = await input.read(4);
        if (header.isEmpty) break;
        final plainLength = ByteData.sublistView(Uint8List.fromList(header)).getUint32(0, Endian.big);
        final nonce = await input.read(12);
        final cipherText = await input.read(plainLength);
        final macBytes = await input.read(_macLength);
        final box = SecretBox(cipherText, nonce: nonce, mac: Mac(macBytes));
        final plain = await _cipher.decrypt(box, secretKey: masterKey);
        sink.add(plain);
      }
      await sink.flush();
    } finally {
      await input.close();
      await sink.close();
    }
  }

  /// Billiger Sanity-Check für die Bibliotheks-Integritätsprüfung: prüft nur
  /// die ersten 4 Bytes (Magic Header), ohne den Rest zu entschlüsseln. Ein
  /// [SecretKey] wird bewusst nicht gebraucht – geht nicht um Entschlüsseln,
  /// sondern nur darum, offensichtlich beschädigte/verkürzte Dateien zu
  /// erkennen (z.B. durch einen abgebrochenen Schreibvorgang).
  static Future<bool> hasValidEncryptedHeader(File file) async {
    final raf = await file.open(mode: FileMode.read);
    try {
      final magic = await raf.read(_magic.length);
      return magic.length == _magic.length && _bytesEqual(magic, _magic);
    } finally {
      await raf.close();
    }
  }

  static bool _bytesEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
