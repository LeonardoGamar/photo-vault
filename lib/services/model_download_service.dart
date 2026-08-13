import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import 'model_catalog.dart';

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
            controller.addError(Exception(
              'Prüfsumme von ${file.fileName} stimmt nicht mit der erwarteten SHA-256 '
              'überein (erhalten $actualHash, erwartet $expectedHash) – Download '
              'verworfen. Die Datei am Server hat sich möglicherweise geändert oder '
              'wurde beim Transfer verändert.',
            ));
            await controller.close();
            return;
          }

          await File(tmpPath).rename(targetPath);
        } catch (e) {
          final partial = File(tmpPath);
          if (await partial.exists()) await partial.delete();
          controller.addError(Exception('Download von ${file.fileName} fehlgeschlagen: $e'));
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
    for (final file in entry.files) {
      final f = File(p.join(modelsDir, file.fileName));
      if (await f.exists()) await f.delete();
    }
  }
}
