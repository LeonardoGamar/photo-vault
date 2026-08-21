import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import 'model_catalog.dart';

/// Warum ein Modell-Download gescheitert ist.
///
/// Kein fertiger Satz: Dieser Dienst kennt keine Oberflächensprache. Die
/// Teile (Dateiname, Prüfsummen) reicht er mit, den Satz baut der
/// Einstellungs-Bildschirm.
class ModellDownloadFehler implements Exception {
  final String datei;

  /// Gesetzt, wenn die Prüfsumme nicht stimmte – dann ist der Download
  /// bewusst verworfen worden.
  final String? erhalten;
  final String? erwartet;

  /// Gesetzt, wenn die Übertragung selbst fehlschlug.
  final String? ursache;

  const ModellDownloadFehler.pruefsumme(this.datei, this.erhalten, this.erwartet)
      : ursache = null;
  const ModellDownloadFehler.uebertragung(this.datei, this.ursache)
      : erhalten = null,
        erwartet = null;
}


class ModelDownloadProgress {
  final String fileName;
  final int receivedBytes;
  final int totalBytes;
  ModelDownloadProgress(this.fileName, this.receivedBytes, this.totalBytes);

  double get fraction => totalBytes <= 0 ? 0 : receivedBytes / totalBytes;
}

/// Lädt die Dateien eines [ModelCatalogEntry] in den lokalen Modell-Ordner
/// herunter. Bewusst ein simpler, direkter HTTP-Download ohne
/// Cloud-Zwischendienst – die App spricht dabei ausschließlich mit den in
/// [ModelCatalog] hinterlegten, öffentlichen Open-Source-Quellen
/// (GitHub/HuggingFace), nie mit einem eigenen Server.
class ModelDownloadService {
  ModelDownloadService(this.modelsDir);

  final String modelsDir;
  final Dio _dio = Dio();

  bool isEntryInstalled(ModelCatalogEntry entry) {
    return entry.files.every((f) => File(p.join(modelsDir, f.fileName)).existsSync());
  }

  /// Lädt alle Dateien eines Katalog-Eintrags herunter und meldet dabei
  /// laufend den Byte-Fortschritt der jeweils aktiven Datei.
  Stream<ModelDownloadProgress> download(ModelCatalogEntry entry) {
    late StreamController<ModelDownloadProgress> controller;
    controller = StreamController<ModelDownloadProgress>(onListen: () async {
      for (final file in entry.files) {
        final targetPath = p.join(modelsDir, file.fileName);
        final tmpPath = '$targetPath.part';
        try {
          await _dio.download(
            file.url,
            tmpPath,
            onReceiveProgress: (received, total) {
              controller.add(ModelDownloadProgress(file.fileName, received, total));
            },
          );

          final actualHash = await _sha256OfFile(File(tmpPath));
          final expectedHash = file.sha256.toLowerCase();
          if (actualHash != expectedHash) {
            await File(tmpPath).delete();
            controller.addError(ModellDownloadFehler.pruefsumme(
                file.fileName, actualHash, expectedHash));
            await controller.close();
            return;
          }

          await File(tmpPath).rename(targetPath);
        } catch (e) {
          final partial = File(tmpPath);
          if (await partial.exists()) await partial.delete();
          controller.addError(
              ModellDownloadFehler.uebertragung(file.fileName, '$e'));
          await controller.close();
          return;
        }
      }
      await controller.close();
    });
    return controller.stream;
  }

  /// Berechnet die SHA-256-Prüfsumme streamend (statt die Datei komplett in
  /// den Speicher zu laden – die CLIP-ONNX-Dateien sind mehrere hundert MB
  /// groß).
  Future<String> _sha256OfFile(File file) async {
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString();
  }

  Future<void> deleteEntry(ModelCatalogEntry entry) async {
    for (final name in [
      ...entry.files.map((f) => f.fileName),
      // Selbst erzeugte Dateien gehören mit weg. Wer etwas anlegt, muss
      // aufräumen, sonst tut es niemand – siehe [raeumeAbgeloesteModelle].
      ...entry.abgeleiteteDateien,
    ]) {
      final f = File(p.join(modelsDir, name));
      if (await f.exists()) await f.delete();
    }
  }

  /// Wie viel Platz die Dateien eines Eintrags tatsächlich belegen.
  /// Fehlende Dateien zählen als 0, ein nicht installierter Eintrag ergibt
  /// also 0.
  ///
  /// Bewusst synchron und ohne Zwischenspeicher: Es sind eine Handvoll
  /// `stat`-Aufrufe, und die Oberfläche prüft an derselben Stelle ohnehin
  /// schon synchron auf Vorhandensein (siehe [isEntryInstalled]).
  int belegteBytes(ModelCatalogEntry entry) {
    var summe = 0;
    for (final name in [
      ...entry.files.map((f) => f.fileName),
      ...entry.abgeleiteteDateien,
    ]) {
      final datei = File(p.join(modelsDir, name));
      if (datei.existsSync()) summe += datei.lengthSync();
    }
    return summe;
  }

  /// Gesamter Platzbedarf des Modellordners – auch Dateien, die zu keinem
  /// Katalog-Eintrag (mehr) gehören. Der Ordner wächst schnell auf über ein
  /// Gigabyte, ohne dass die App das bisher irgendwo auswies.
  int gesamteBytes() {
    final dir = Directory(modelsDir);
    if (!dir.existsSync()) return 0;
    var summe = 0;
    for (final e in dir.listSync()) {
      if (e is File) summe += e.lengthSync();
    }
    return summe;
  }

  /// Entfernt liegengebliebene `.part`-Dateien abgebrochener Downloads.
  ///
  /// Der Fehlerpfad des Downloads räumt selbst auf; wird die App aber
  /// mitten im Herunterladen beendet oder stürzt ab, bleibt die halbe
  /// Datei zurück – bis zu 335 MB, ohne dass irgendwo etwas darauf
  /// hinweist. Wiederaufnehmen lässt sie sich ohnehin nicht (der Download
  /// beginnt jedes Mal von vorn), sie ist also reiner Ballast
  /// (Audit-Fund).
  ///
  /// Nur beim Programmstart aufrufen: Während ein Download läuft, wäre
  /// genau diese Datei in Benutzung.
  Future<int> raeumeAbgebrocheneDownloads() async {
    final dir = Directory(modelsDir);
    if (!await dir.exists()) return 0;
    var entfernt = 0;
    await for (final eintrag in dir.list()) {
      if (eintrag is File && eintrag.path.endsWith('.part')) {
        try {
          await eintrag.delete();
          entfernt++;
        } catch (e) {
          debugPrint('Rest eines Downloads liess sich nicht entfernen: $e');
        }
      }
    }
    return entfernt;
  }

  /// Dateien des abgelösten Beschreibungsmodells (ViT-GPT2), das seit
  /// Version 1.4 durch Florence-2 ersetzt ist.
  ///
  /// Sie stehen in keinem Katalogeintrag mehr und liessen sich deshalb
  /// auch nicht mehr über die Modellverwaltung löschen – 246 MB, die
  /// niemand je wieder anfasst. Dasselbe Muster wie bei den verwaisten
  /// Gesichtsausschnitten der achten Prüfrunde: Wer etwas ablöst, muss
  /// aufräumen, sonst tut es niemand.
  ///
  /// Nur beim Programmstart aufrufen, aus demselben Grund wie oben.
  Future<int> raeumeAbgeloesteModelle() async {
    const abgeloest = [
      'caption_encoder.onnx',
      'caption_decoder.onnx',
      'caption_vocab.json',
    ];
    var bytes = 0;
    for (final name in abgeloest) {
      final f = File('$modelsDir/$name');
      try {
        if (await f.exists()) {
          bytes += await f.length();
          await f.delete();
        }
      } catch (e) {
        debugPrint('Abgelöste Modelldatei $name liess sich nicht entfernen: $e');
      }
    }
    return bytes;
  }
}
