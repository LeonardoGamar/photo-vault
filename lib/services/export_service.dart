import 'dart:io';

import 'package:path/path.dart' as p;

import '../db/database.dart';
import '../state/library_state.dart';
import 'storage_paths.dart';
import 'xmp_writer.dart';

/// Exportiert Original-Dateien aus der verwalteten Bibliothek zurück in
/// einen normalen Ordner – z.B. um ein Foto extern weiterzubearbeiten oder zu
/// teilen. Bewusst von [BackupService] getrennt: ein Backup sichert die
/// GESAMTE Bibliothek (inkl. Metadaten-Export, Delta-Abgleich), ein Export
/// legt gezielt einzelne Original-Dateien an einem frei gewählten Ort ab.
class ExportService {
  const ExportService(this._paths, {LibraryState? library}) : _library = library;

  final StoragePaths _paths;
  final LibraryState? _library;

  /// Liefert die tatsächliche Quelldatei eines Assets – gesperrte
  /// (verschlüsselte) Assets werden dafür einmalig über
  /// [LibraryState.decryptForViewing] entschlüsselt (dafür muss [library]
  /// beim Erzeugen übergeben worden sein und der gesperrte Ordner für diese
  /// Sitzung bereits entsperrt sein). Gemeinsam genutzt von [exportAsset]
  /// (Kopie in einen Ordner) und dem nativen Teilen-Dialog in
  /// AssetViewerScreen (Kopie an eine andere App wie Mail/AirDrop).
  Future<File> resolveSourceFile(AssetData asset) async {
    return asset.isLocked && _library != null
        ? await _library.decryptForViewing(asset.relativePath)
        : _paths.absolute(asset.relativePath);
  }

  /// Exportiert die Originaldatei eines Assets in [destinationDir] und gibt
  /// den verwendeten Dateinamen zurück (bei einer Namenskollision am
  /// Zielort mit angehängter Nummerierung). Legt zusätzlich eine
  /// `.xmp`-Sidecar-Datei mit den Metadaten daneben (siehe xmp_writer.dart)
  /// – anders als beim Bulk-Export/Backup werden hier bewusst AUCH gesperrte
  /// Assets mit einbezogen: der Nutzer hat das Entschlüsseln/Exportieren an
  /// dieser Stelle bereits aktiv angestoßen (siehe [resolveSourceFile]).
  Future<String> exportAsset(AssetData asset, String destinationDir) async {
    final sourceFile = await resolveSourceFile(asset);
    final targetPath = _uniqueDestinationPath(destinationDir, asset.originalFileName);
    await sourceFile.copy(targetPath);

    final tagNames = _library != null
        ? (await _library.db.tagsForAsset(asset.id)).map((t) => t.name).toList()
        : const <String>[];
    final xmp = buildXmpPacket(asset, tagNames);
    await File(_paths.xmpSidecarPath(targetPath)).writeAsString(xmp);

    return p.basename(targetPath);
  }

  /// Hängt bei einer bereits vorhandenen Datei gleichen Namens am Zielort
  /// "(1)", "(2)", … an den Dateinamen an, statt die vorhandene Datei
  /// stillschweigend zu überschreiben.
  ///
  /// [fileName] wird zusätzlich über `p.basename()` geführt – reine
  /// Verteidigung in der Tiefe: der Name stammt aus [AssetData.originalFileName],
  /// das schon beim Import bzw. beim Backup-Restore auf den Basisnamen
  /// reduziert wird, aber ein Export-Ziel sollte auch bei einer künftigen
  /// Änderung dieser Invariante nie außerhalb von [dir] landen können.
  String _uniqueDestinationPath(String dir, String fileName) {
    final safeName = p.basename(fileName);
    var candidate = p.join(dir, safeName);
    if (!File(candidate).existsSync()) return candidate;
    final stem = p.basenameWithoutExtension(safeName);
    final ext = p.extension(safeName);
    var i = 1;
    while (File(candidate).existsSync()) {
      candidate = p.join(dir, '$stem ($i)$ext');
      i++;
    }
    return candidate;
  }
}
