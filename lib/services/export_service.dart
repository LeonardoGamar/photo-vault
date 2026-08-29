import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import '../db/database.dart';
import '../state/library_state.dart';
import 'export_naming.dart';
import 'native_image_converter.dart';
import 'storage_paths.dart';
import '../l10n/app_localizations.dart';
import 'xmp_regionen.dart';
import 'xmp_writer.dart';

/// Größe und Format, in denen exportiert wird.
///
/// [Exportgroesse.original] kopiert die Datei unverändert – der bisherige
/// und weiterhin voreingestellte Fall, und der einzige, der RAW, Videos und
/// alle übrigen Formate unangetastet lässt. Die übrigen Stufen rendern nach
/// JPEG mit begrenzter langer Kante, für Versand und Hochladen.
///
/// Bewusst eine feste, kurze Liste statt frei benannter Voreinstellungen:
/// Die drei Grössen decken die üblichen Fälle ab, und eine Verwaltung
/// eigener Voreinstellungen wäre ein eigenes Stück Oberfläche.
enum Exportgroesse {
  original(null),
  gross(4096),
  web(2048),
  email(1024);

  const Exportgroesse(this.maxKante);
  final int? maxKante;
}

/// Die Beschriftung einer Ausgabegrösse in der Oberflächensprache.
///
/// Wie beim Modellkatalog steht sie nicht im Enum selbst: Enum-Werte sind
/// `const`, ein übersetzter Text braucht den Kontext. Und zwei Fassungen
/// desselben Textes – eine hier, eine in den Sprachdateien – laufen
/// verlässlich auseinander.
String exportgroesseBezeichnung(AppTexte t, Exportgroesse g) => switch (g) {
      Exportgroesse.original => t.exportOriginal,
      Exportgroesse.gross => t.exportGross,
      Exportgroesse.web => t.exportWeb,
      Exportgroesse.email => t.exportEmail,
    };

/// Alles, was ein Export-Lauf über die Ausgabe wissen muss.
///
/// Steht zwischen den beiden Wegen, auf denen ein Export ausgelöst werden
/// kann: der schnellen Auswahl einer der vier festen [Exportgroesse]n und
/// einer gespeicherten Voreinstellung aus der Datenbank. Der Dienst kennt
/// nur noch dieses eine Gebilde – sonst müsste jede neue Einstellung an
/// zwei Stellen durchgereicht werden.
class Exportvorgabe {
  /// Nach JPEG rendern statt die Datei zu kopieren.
  ///
  /// Ohne das bleibt die Datei Bit für Bit, wie sie ist – der einzige Weg,
  /// der RAW, Videos und alles Übrige unangetastet lässt.
  final bool nachJpeg;

  /// Längere Bildkante in Pixeln, `null` = nicht begrenzen. Ohne
  /// [nachJpeg] ohne Bedeutung.
  final int? maxKante;

  final double qualitaet;

  /// Siehe `export_naming.dart`. Der Vorgabewert übernimmt den bisherigen
  /// Dateinamen unverändert.
  final String namensmuster;

  /// Die `.xmp`-Beistelldatei mitschreiben.
  final bool xmpDaneben;

  const Exportvorgabe({
    this.nachJpeg = false,
    this.maxKante,
    this.qualitaet = 0.9,
    this.namensmuster = '{name}',
    this.xmpDaneben = true,
  });

  /// Die Entsprechung einer der vier festen Grössen – damit der schnelle
  /// Weg und der Voreinstellungs-Weg denselben Code durchlaufen.
  factory Exportvorgabe.ausGroesse(Exportgroesse g) => Exportvorgabe(
        nachJpeg: g.maxKante != null,
        maxKante: g.maxKante,
      );

  factory Exportvorgabe.ausPreset(ExportPresetData p) => Exportvorgabe(
        nachJpeg: p.nachJpeg,
        maxKante: p.maxKante,
        qualitaet: p.qualitaet,
        namensmuster: p.namensmuster,
        xmpDaneben: p.xmpDaneben,
      );
}

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
  ///
  /// Mit [groesse] ungleich [Exportgroesse.original] wird das Foto nach JPEG
  /// gerendert. Videos und alles, was sich nicht konvertieren lässt, werden
  /// dabei unverändert kopiert statt übersprungen – ein Export soll nichts
  /// auslassen, nur weil eine Grössenvorgabe darauf nicht anwendbar ist.
  /// [nummer] ist die laufende Nummer innerhalb des Export-Laufs (ab 1) und
  /// wird nur gebraucht, wenn das Namensmuster `{nr}` enthält.
  Future<String> exportAsset(
    AssetData asset,
    String destinationDir, {
    Exportgroesse groesse = Exportgroesse.original,
    Exportvorgabe? vorgabe,
    int nummer = 1,
  }) async {
    final v = vorgabe ?? Exportvorgabe.ausGroesse(groesse);
    final sourceFile = await resolveSourceFile(asset);

    // `maxDimension: null` heisst für den nativen Wandler „nicht
    // begrenzen" – so lässt sich auch in voller Auflösung nach JPEG
    // rendern, was mit der alten Aufzählung nicht ging.
    Uint8List? gerendert;
    if (v.nachJpeg && asset.type == 'IMAGE') {
      gerendert = await NativeImageConverter.convertToJpegBytes(
        sourceFile,
        maxDimension: v.maxKante,
        quality: v.qualitaet,
      );
    }

    // Die Endung richtet sich danach, was WIRKLICH geschrieben wird: Ist
    // das Rendern fehlgeschlagen (oder war es ein Video), wird kopiert –
    // dann darf dort auch kein `.jpg` stehen.
    final endung =
        gerendert != null ? '.jpg' : p.extension(asset.originalFileName);
    final zielName = dateiname(
      v.namensmuster,
      asset,
      nummer: nummer,
      endung: endung,
    );
    final targetPath = _uniqueDestinationPath(destinationDir, zielName);
    if (gerendert != null) {
      await File(targetPath).writeAsBytes(gerendert);
    } else {
      await sourceFile.copy(targetPath);
    }

    if (v.xmpDaneben) {
      final tagNames = _library != null
          ? (await _library.db.tagsForAsset(asset.id)).map((t) => t.name).toList()
          : const <String>[];
      // Die benannten Gesichter gehen mit: Genau dafür exportiert man mit
      // Beipackzettel – damit das Zielprogramm die Namen übernimmt, statt
      // sie ein zweites Mal von Hand zu vergeben.
      final gesichter = _library != null
          ? await _library.db.gesichtsregionenVon(asset.id)
          : const <Gesichtsregion>[];
      final xmp = buildXmpPacket(asset, tagNames, gesichter: gesichter);
      await File(_paths.xmpSidecarPath(targetPath)).writeAsString(xmp);
    }

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
