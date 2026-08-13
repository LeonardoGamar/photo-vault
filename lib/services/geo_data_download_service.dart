import 'dart:async';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import 'geo_data_catalog.dart';

class GeoDataDownloadProgress {
  final String fileName;
  final int receivedBytes;
  final int totalBytes;
  GeoDataDownloadProgress(this.fileName, this.receivedBytes, this.totalBytes);

  double get fraction => totalBytes <= 0 ? 0 : receivedBytes / totalBytes;
}

/// Lädt den GeoNames-Datensatz (siehe [GeoDataCatalog]) in einen lokalen
/// Ordner herunter und entpackt die Städteliste – danach steht
/// [ReverseGeocoder] komplett offline zur Verfügung. Bewusst analog zu
/// ModelDownloadService aufgebaut (gleiches Download-/Fortschritts-Muster),
/// aber eine eigenständige, kleinere Klasse: anders als bei den KI-Modellen
/// gibt es keine Prüfsummen-Verifikation (siehe GeoDataCatalog) und ein
/// Entpack-Schritt kommt hinzu.
class GeoDataDownloadService {
  GeoDataDownloadService(this.geoDataDir);

  final String geoDataDir;
  final Dio _dio = Dio();

  bool get isInstalled =>
      File(p.join(geoDataDir, GeoDataCatalog.citiesFileName)).existsSync() &&
      File(p.join(geoDataDir, GeoDataCatalog.admin1FileName)).existsSync() &&
      File(p.join(geoDataDir, GeoDataCatalog.countryFileName)).existsSync();

  File get citiesFile => File(p.join(geoDataDir, GeoDataCatalog.citiesFileName));
  File get admin1File => File(p.join(geoDataDir, GeoDataCatalog.admin1FileName));
  File get countryFile => File(p.join(geoDataDir, GeoDataCatalog.countryFileName));

  Stream<GeoDataDownloadProgress> download() {
    late StreamController<GeoDataDownloadProgress> controller;
    controller = StreamController<GeoDataDownloadProgress>(onListen: () async {
      for (final file in GeoDataCatalog.files) {
        final targetPath = p.join(geoDataDir, file.fileName);
        final tmpPath = '$targetPath.part';
        try {
          await _dio.download(
            file.url,
            tmpPath,
            onReceiveProgress: (received, total) {
              controller.add(GeoDataDownloadProgress(file.fileName, received, total));
            },
          );
          await File(tmpPath).rename(targetPath);
        } catch (e) {
          final partial = File(tmpPath);
          if (await partial.exists()) await partial.delete();
          controller.addError(Exception('Download von ${file.fileName} fehlgeschlagen: $e'));
          await controller.close();
          return;
        }
      }

      try {
        await _extractCitiesZip();
      } catch (e) {
        controller.addError(Exception('Entpacken von ${GeoDataCatalog.citiesZipFileName} fehlgeschlagen: $e'));
        await controller.close();
        return;
      }

      await controller.close();
    });
    return controller.stream;
  }

  /// Entpackt `cities1000.txt` aus dem heruntergeladenen Zip und löscht das
  /// Zip anschließend wieder – nur die entpackte Textdatei wird dauerhaft
  /// gebraucht.
  Future<void> _extractCitiesZip() async {
    final zipFile = File(p.join(geoDataDir, GeoDataCatalog.citiesZipFileName));
    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    final entry = archive.files.firstWhere(
      (f) => f.isFile && p.basename(f.name) == GeoDataCatalog.citiesFileName,
      orElse: () => throw StateError('${GeoDataCatalog.citiesFileName} nicht im Zip gefunden.'),
    );
    final targetFile = File(p.join(geoDataDir, GeoDataCatalog.citiesFileName));
    await targetFile.writeAsBytes(entry.content as List<int>);
    await zipFile.delete();
  }

  Future<void> deleteAll() async {
    for (final f in [citiesFile, admin1File, countryFile]) {
      if (await f.exists()) await f.delete();
    }
  }
}
