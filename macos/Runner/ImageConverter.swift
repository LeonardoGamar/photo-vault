// ImageConverter.swift
//
// Behebt zwei grundlegende Probleme:
//
//   1. Flutter selbst (Skia) kann HEIC/HEIF und die meisten RAW-Formate
//      (z.B. DNG) nicht rendern, und das Dart-Paket `image` kann sie nicht
//      dekodieren. macOS bringt mit ImageIO aber genau dafür eine native,
//      systemeigene Lösung mit (dieselbe, die z.B. auch die Vorschau im
//      Finder nutzt) – hierüber wird auf jedes von ImageIO unterstützte
//      Format zurückgegriffen, um es zu einem JPEG zu konvertieren, das dann
//      sowohl für Thumbnails als auch für die Vollbildvorschau verwendet
//      werden kann.
//   2. Für Videos gibt es in Flutter/Dart keine Möglichkeit, ein
//      Vorschaubild (einen Frame) zu extrahieren – AVFoundation liefert das
//      systemeigen mit ("videoThumbnail"-Methode unten), inkl. Videolänge.
//
// Einbindung:
//   1. Diese Datei nach macos/Runner/ImageConverter.swift kopieren.
//   2. In Xcode (macos/Runner.xcworkspace öffnen): Rechtsklick auf den
//      "Runner"-Ordner → "Add Files to Runner…" → ImageConverter.swift
//      auswählen, Target "Runner" ankreuzen.
//   3. In macos/Runner/MainFlutterWindow.swift direkt nach der Zeile
//      `RegisterGeneratedPlugins(registry: flutterViewController)` diese
//      eine Zeile ergänzen (offizieller Standardweg für Method Channels auf
//      macOS, kein Import nötig):
//
//      ImageConverterChannel.register(with: flutterViewController.registrar(forPlugin: "ImageConverter"))
//
// Ohne diesen Schritt läuft die App normal weiter – für HEIC/DNG-Dateien
// fehlen dann aber weiterhin Thumbnails/Vorschau (erkennbar über
// `NativeImageConverter.isSupported()` in den Werkzeugen).

import AVFoundation
import Cocoa
import CoreImage
import FlutterMacOS
import ImageIO
import UniformTypeIdentifiers
import Vision

class ImageConverterChannel: NSObject {
    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "photo_vault/image_convert",
            binaryMessenger: registrar.messenger
        )
        channel.setMethodCallHandler { call, result in
            switch call.method {
            case "ping":
                result(true)
            case "convertToJpeg":
                guard
                    let args = call.arguments as? [String: Any],
                    let path = args["path"] as? String
                else {
                    result(FlutterError(code: "bad_args", message: "path fehlt", details: nil))
                    return
                }
                let maxDimension = (args["maxDimension"] as? NSNumber)?.intValue ?? 2048
                let quality = (args["quality"] as? NSNumber)?.doubleValue ?? 0.9
                DispatchQueue.global(qos: .userInitiated).async {
                    let data = convertToJpeg(path: path, maxDimension: maxDimension, quality: quality)
                    DispatchQueue.main.async {
                        if let data = data {
                            result(FlutterStandardTypedData(bytes: data))
                        } else {
                            result(nil)
                        }
                    }
                }
            case "developImage":
                guard
                    let args = call.arguments as? [String: Any],
                    let path = args["path"] as? String
                else {
                    result(FlutterError(code: "bad_args", message: "path fehlt", details: nil))
                    return
                }
                let maxDimension = (args["maxDimension"] as? NSNumber)?.intValue ?? 2048
                let quality = (args["quality"] as? NSNumber)?.doubleValue ?? 0.9
                let adjustments = DevelopAdjustments(
                    exposure: (args["exposure"] as? NSNumber)?.floatValue ?? 0,
                    temperature: (args["temperature"] as? NSNumber)?.floatValue,
                    tint: (args["tint"] as? NSNumber)?.floatValue,
                    contrast: (args["contrast"] as? NSNumber)?.floatValue ?? 0,
                    shadows: (args["shadows"] as? NSNumber)?.floatValue ?? 0,
                    sharpness: (args["sharpness"] as? NSNumber)?.floatValue ?? 0,
                    noiseReduction: (args["noiseReduction"] as? NSNumber)?.floatValue ?? 0,
                    lensCorrectionEnabled: (args["lensCorrectionEnabled"] as? Bool) ?? true,
                    curveLut: floatArray(args["toneCurveLut"]),
                    colorCube: floatArray(args["colorCube"]),
                    colorCubeSize: (args["colorCubeSize"] as? NSNumber)?.intValue ?? 0
                )
                // KI-Objektmasken (siehe MaskEditor/DevelopMasks): jede trägt
                // eine Grauwert-PNG-Alphamaske + ihren eigenen Regler-Satz,
                // wirksam NUR innerhalb der Maske (siehe developImage unten).
                let maskLayers: [MaskLayer] = ((args["masks"] as? [[String: Any]]) ?? []).compactMap { m in
                    guard let path = m["path"] as? String else { return nil }
                    return MaskLayer(
                        path: path,
                        adjustments: DevelopAdjustments(
                            exposure: (m["exposure"] as? NSNumber)?.floatValue ?? 0,
                            temperature: (m["temperature"] as? NSNumber)?.floatValue,
                            tint: (m["tint"] as? NSNumber)?.floatValue,
                            contrast: (m["contrast"] as? NSNumber)?.floatValue ?? 0,
                            shadows: (m["shadows"] as? NSNumber)?.floatValue ?? 0,
                            sharpness: (m["sharpness"] as? NSNumber)?.floatValue ?? 0,
                            noiseReduction: (m["noiseReduction"] as? NSNumber)?.floatValue ?? 0,
                            lensCorrectionEnabled: true
                        )
                    )
                }
                DispatchQueue.global(qos: .userInitiated).async {
                    let data = developImage(
                        path: path, maxDimension: maxDimension, quality: quality, adjustments: adjustments,
                        maskLayers: maskLayers
                    )
                    DispatchQueue.main.async {
                        if let data = data {
                            result(FlutterStandardTypedData(bytes: data))
                        } else {
                            result(nil)
                        }
                    }
                }
            case "videoThumbnail":
                guard
                    let args = call.arguments as? [String: Any],
                    let path = args["path"] as? String
                else {
                    result(FlutterError(code: "bad_args", message: "path fehlt", details: nil))
                    return
                }
                let maxDimension = (args["maxDimension"] as? NSNumber)?.intValue ?? 800
                DispatchQueue.global(qos: .userInitiated).async {
                    let thumbnail = videoThumbnail(path: path, maxDimension: maxDimension)
                    DispatchQueue.main.async {
                        if let thumbnail = thumbnail {
                            result([
                                "jpeg": FlutterStandardTypedData(bytes: thumbnail.jpeg),
                                "durationSeconds": thumbnail.durationSeconds,
                            ])
                        } else {
                            result(nil)
                        }
                    }
                }
            case "recognizeText":
                guard
                    let args = call.arguments as? [String: Any],
                    let path = args["path"] as? String
                else {
                    result(FlutterError(code: "bad_args", message: "path fehlt", details: nil))
                    return
                }
                DispatchQueue.global(qos: .userInitiated).async {
                    let text = recognizeText(path: path)
                    DispatchQueue.main.async {
                        result(text)
                    }
                }
            case "trimVideo":
                guard
                    let args = call.arguments as? [String: Any],
                    let path = args["path"] as? String,
                    let outputPath = args["outputPath"] as? String,
                    let startSeconds = (args["startSeconds"] as? NSNumber)?.doubleValue,
                    let endSeconds = (args["endSeconds"] as? NSNumber)?.doubleValue
                else {
                    result(FlutterError(code: "bad_args", message: "path/outputPath/startSeconds/endSeconds fehlt", details: nil))
                    return
                }
                trimVideo(
                    path: path, outputPath: outputPath, startSeconds: startSeconds, endSeconds: endSeconds
                ) { success in
                    DispatchQueue.main.async {
                        result(success)
                    }
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    /// Lädt eine Bilddatei über ImageIO (deckt HEIC/HEIF, DNG/RAW, TIFF-
    /// Sonderfälle usw. ab), skaliert sie ggf. auf maximal [maxDimension] px
    /// (längste Seite) und gibt sie als JPEG-Bytes zurück.
    ///
    /// Enthält das Bild eine eingebettete HDR-Gain-Map (Apples "Adaptive
    /// HDR", z.B. bei iPhone-Fotos im HDR-Modus), wird zuerst versucht, sie
    /// über Core Image einzubeziehen (siehe [convertHdrAwareJpeg]) – JPEG
    /// selbst kann kein HDR darstellen, aber ein damit ton-gemapptes Bild
    /// gibt die Kontrast-/Helligkeitsabsicht der Aufnahme deutlich besser
    /// wieder als das nackte SDR-Basisbild, das der normale Pfad unten liefern
    /// würde. Schlägt das aus irgendeinem Grund fehl (ältere macOS-Version,
    /// keine Gain-Map, o.ä.), fällt es lückenlos auf den bisherigen,
    /// unveränderten ImageIO-Pfad zurück.
    private static func convertToJpeg(path: String, maxDimension: Int, quality: Double) -> Data? {
        if #available(macOS 14.0, *),
            let hdrData = convertHdrAwareJpeg(path: path, maxDimension: maxDimension, quality: quality)
        {
            return hdrData
        }

        if #available(macOS 12.0, *),
            rawExtensions.contains((path as NSString).pathExtension.lowercased()),
            let rawData = convertRawWithLensCorrection(path: path, maxDimension: maxDimension, quality: quality)
        {
            return rawData
        }

        let url = URL(fileURLWithPath: path)
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }

        let downsampleOptions: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimension,
            kCGImageSourceCreateThumbnailWithTransform: true,
        ]

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, downsampleOptions as CFDictionary) else {
            // Fallback: Vollauflösung laden, falls die Thumbnail-Erzeugung scheitert.
            guard let full = CGImageSourceCreateImageAtIndex(source, 0, nil) else { return nil }
            return encodeJpeg(full, quality: quality)
        }
        return encodeJpeg(cgImage, quality: quality)
    }

    /// Ob [source] eine eingebettete HDR-Gain-Map besitzt (Apples "Adaptive
    /// HDR" in HEIC: neben dem normalen SDR-Basisbild eine zusätzliche
    /// Zusatzebene mit den Aufhellungs-/Kontrastinformationen für HDR-fähige
    /// Anzeigen). Ein günstiger Metadaten-Check statt eines vollen Decodes,
    /// damit ganz normale (Nicht-HDR-)Fotos weiterhin den bestehenden,
    /// schnelleren Pfad in [convertToJpeg] nehmen.
    @available(macOS 14.0, *)
    private static func hasHdrGainMap(source: CGImageSource) -> Bool {
        guard
            let auxInfo = CGImageSourceCopyAuxiliaryDataInfoAtIndex(
                source, 0, kCGImageAuxiliaryDataTypeHDRGainMap
            ) as? [CFString: Any]
        else { return false }
        return !auxInfo.isEmpty
    }

    /// Dekodiert [path] inkl. HDR-Gain-Map über Core Image
    /// (`.expandToHDR`) und rendert das Ergebnis über einen [CIContext] in
    /// den sRGB-Zielfarbraum zurück – dabei wendet Core Image automatisch
    /// die passende Ton-Kurve an, um den erweiterten HDR-Dynamikumfang auf
    /// den regulären SDR-Bereich abzubilden (dieselbe Technik, mit der z.B.
    /// Apple selbst HDR-Fotos für Apps/Websites ohne HDR-Unterstützung
    /// darstellt). Gibt `nil` zurück, wenn [path] keine Gain-Map enthält
    /// oder irgendein Schritt fehlschlägt – der Aufrufer fällt dann auf den
    /// normalen ImageIO-Pfad zurück.
    @available(macOS 14.0, *)
    private static func convertHdrAwareJpeg(path: String, maxDimension: Int, quality: Double) -> Data? {
        let url = URL(fileURLWithPath: path)
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
            hasHdrGainMap(source: source)
        else { return nil }

        // .applyOrientationProperty ist hier zwingend nötig: anders als der
        // ImageIO-Pfad oben (kCGImageSourceCreateThumbnailWithTransform)
        // dreht Core Image ein geladenes Bild NICHT automatisch nach seiner
        // EXIF-Orientierung – ohne diese Option kämen hochkant aufgenommene
        // Fotos seitlich verdreht heraus.
        guard
            let hdrImage = CIImage(
                contentsOf: url, options: [.expandToHDR: true, .applyOrientationProperty: true]
            )
        else { return nil }

        let scaledImage = downscale(hdrImage, maxDimension: maxDimension)
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else { return nil }
        guard
            let cgImage = sharedCIContext.createCGImage(
                scaledImage, from: scaledImage.extent, format: .RGBA8, colorSpace: colorSpace
            )
        else { return nil }

        return encodeJpeg(cgImage, quality: quality)
    }

    /// Dateiendungen, die macOS' ImageIO/CIRAWFilter als Hersteller-RAW-
    /// Format erkennt (bestätigt über `CGImageSourceCopyTypeIdentifiers()`
    /// auf diesem System: 30 registrierte RAW-UTIs). Muss von Hand mit
    /// `lib/services/raw_formats.dart` synchron gehalten werden, da Swift
    /// die Dart-Datei nicht importieren kann.
    private static let rawExtensions: Set<String> = [
        "dng", "cr2", "cr3", "crw", // Canon (+ Adobe DNG, iPhone DNG)
        "nef", "nrw", "nefx", // Nikon
        "arw", "sr2", "srf", "axr", // Sony
        "raf", // Fujifilm
        "orf", // Olympus/OM System
        "rw2", // Panasonic
        "pef", // Pentax
        "3fr", "fff", // Hasselblad
        "iiq", // Phase One
        "dcr", // Kodak
        "mrw", // Minolta
        "mos", // Leaf
        "srw", // Samsung
        "erf", // Epson
        "rwl", "raw", // Leica
        "dxo", // DxO
    ]

    /// Dekodiert eine RAW-Datei über Apples `CIRAWFilter` statt der
    /// einfachen ImageIO-Vorschau weiter unten – dieselbe API, mit der z.B.
    /// auch Fotos.app RAW-Dateien verarbeitet. `CIRAWFilter` erkennt Kamera
    /// und Objektiv dafür selbst aus den RAW-Metadaten und gleicht sie mit
    /// Apples eigener, über System-Updates gepflegter Kamera-/Objektiv-
    /// Datenbank ab – bei einem Treffer (`isLensCorrectionSupported`) wird
    /// automatisch eine Objektivkorrektur (Verzeichnung, Vignettierung)
    /// angewendet, ganz ohne eigene Profildatenbank. Nicht jede Kamera/jedes
    /// Objektiv wird unterstützt (bei eigenen Testfotos von einem iPhone 17
    /// Pro und einer Canon EOS R10 z.B. nicht) – dann bleibt es beim reinen,
    /// unkorrigierten RAW-Dekodieren. Gibt `nil` zurück, wenn die Datei kein
    /// gültiges RAW-Format ist oder irgendein Schritt fehlschlägt; der
    /// Aufrufer fällt dann auf den bisherigen ImageIO-Pfad zurück, der
    /// ebenfalls RAW lesen kann, nur ohne Objektivkorrektur.
    @available(macOS 12.0, *)
    private static func convertRawWithLensCorrection(path: String, maxDimension: Int, quality: Double) -> Data? {
        let url = URL(fileURLWithPath: path)
        guard let filter = CIRAWFilter(imageURL: url) else { return nil }

        // Direkt in der gewünschten Zielgröße dekodieren lassen, statt in
        // voller Auflösung zu rendern und danach herunterzuskalieren wie bei
        // [downscale] – CIRAWFilter unterstützt das nativ und spart bei
        // großen RAW-Dateien (oft 40+ Megapixel) unnötige Rechenzeit.
        let longSide = max(filter.nativeSize.width, filter.nativeSize.height)
        if longSide > 0 {
            filter.scaleFactor = min(1, Float(maxDimension) / Float(longSide))
        }
        if filter.isLensCorrectionSupported {
            filter.isLensCorrectionEnabled = true
        }

        guard let outputImage = filter.outputImage,
            let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
            let cgImage = sharedCIContext.createCGImage(
                outputImage, from: outputImage.extent, format: .RGBA8, colorSpace: colorSpace
            )
        else { return nil }

        return encodeJpeg(cgImage, quality: quality)
    }

    /// Ein einzelner, wiederverwendeter [CIContext] statt eines neuen pro
    /// Konvertierung: die Erstellung baut eine eigene Metal/GPU-Rendering-
    /// Pipeline auf (mehrere zehn Millisekunden) und ist damit deutlich
    /// teurer als das eigentliche Bild-Rendering selbst – bei vielen
    /// HDR-Fotos hintereinander (z.B. beim Import) summiert sich das sonst zu
    /// spürbar unnötigem Overhead. `CIContext` ist laut Apple-Dokumentation
    /// sicher von mehreren Threads gleichzeitig nutzbar, passt also zu den
    /// parallelen Aufrufen über `DispatchQueue.global` oben in
    /// `ImageConverterChannel`.
    private static let sharedCIContext = CIContext()

    /// Regler-Werte des DevelopScreen (siehe lib/screens/develop_screen.dart)
    /// – ein "neutraler" Wert (0 bzw. `nil` bei Weißabgleich) entspricht
    /// unverändert, damit ein frisch geöffnetes Foto ohne gespeicherte
    /// DevelopSettings optisch identisch zur normalen Vorschau bleibt.
    private struct DevelopAdjustments {
        let exposure: Float
        let temperature: Float?
        let tint: Float?
        let contrast: Float
        let shadows: Float
        let sharpness: Float
        let noiseReduction: Float
        let lensCorrectionEnabled: Bool

        /// Tonwertkurve und Farbmischer kommen NICHT als Regler-Zahlen an,
        /// sondern als fertig ausgerechnete Nachschlagetabellen (siehe
        /// lib/services/develop_color.dart). Der Grund ist Absicht: Sonst
        /// müssten die Kurveninterpolation und die Farbband-Mathematik hier
        /// ein zweites Mal stehen – neben der Fassung im GPU-Shader für die
        /// Live-Vorschau – und beide könnten unbemerkt auseinanderlaufen.
        ///
        /// Fehlt eine der beiden, ist das Werkzeug neutral und der Filter
        /// entfällt; Masken übertragen sie grundsätzlich nicht.
        var curveLut: [Float]? = nil
        var colorCube: [Float]? = nil
        var colorCubeSize: Int = 0
    }

    /// Eine KI-Objektmaske (siehe MaskEditor/DevelopMasks): [path] zeigt auf
    /// eine Grauwert-PNG-Alphamaske (weiß = Anpassung wirksam, schwarz =
    /// unverändert), [adjustments] gilt NUR innerhalb dieser Maske.
    private struct MaskLayer {
        let path: String
        let adjustments: DevelopAdjustments
    }

    /// Rendert eine Bilddatei (RAW oder normales Format) mit den
    /// angegebenen, nicht-destruktiven Anpassungen. Für RAW-Dateien über
    /// CIRAWFilter-Eigenschaften (arbeitet auf den Rohdaten vor dem
    /// Demosaicing – höhere Qualität als eine Filterkette auf dem bereits
    /// demosaicten Bild), für alle anderen Formate über eine äquivalente
    /// CIFilter-Kette auf dem dekodierten Bild (siehe
    /// [applyNonRawAdjustments]). [maskLayers] werden NACH den globalen
    /// Reglern der Reihe nach übereinandergelegt (siehe
    /// [compositeMaskLayers]) – dieselbe [applyNonRawAdjustments]-Filterkette
    /// wie für die globalen Regler, nur pro Maske auf das bereits global
    /// angepasste Bild angewendet und über `CIBlendWithMask` zurück-
    /// kompositiert. Gibt `nil` zurück, wenn die Datei nicht geladen werden
    /// kann.
    private static func developImage(
        path: String, maxDimension: Int, quality: Double, adjustments: DevelopAdjustments,
        maskLayers: [MaskLayer] = []
    ) -> Data? {
        let url = URL(fileURLWithPath: path)
        let ext = (path as NSString).pathExtension.lowercased()
        let output: CIImage?

        // #available (statt einer Funktionssignatur-weiten @available-
        // Annotation wie bei convertRawWithLensCorrection) wird hier
        // gebraucht, weil developImage ungated vom Method-Channel-Handler
        // aufgerufen wird – auf macOS < 12 fällt selbst eine RAW-Datei auf
        // die CIFilter-Kette unten zurück (ohne CIRAWFilter-spezifische
        // Anpassungen wie Objektivkorrektur, aber immer noch mit Belichtung/
        // Weißabgleich/Kontrast/etc.).
        if #available(macOS 12.0, *), rawExtensions.contains(ext), let filter = CIRAWFilter(imageURL: url) {
            filter.exposure = adjustments.exposure
            if let temperature = adjustments.temperature {
                filter.neutralTemperature = temperature
            }
            if let tint = adjustments.tint {
                filter.neutralTint = tint
            }
            if filter.isContrastSupported {
                filter.contrastAmount = 1.0 + adjustments.contrast
            }
            filter.shadowBias = adjustments.shadows
            if filter.isSharpnessSupported {
                filter.sharpnessAmount = adjustments.sharpness
            }
            if filter.isLuminanceNoiseReductionSupported {
                filter.luminanceNoiseReductionAmount = adjustments.noiseReduction
            }
            if filter.isColorNoiseReductionSupported {
                filter.colorNoiseReductionAmount = adjustments.noiseReduction
            }
            if filter.isLensCorrectionSupported {
                filter.isLensCorrectionEnabled = adjustments.lensCorrectionEnabled
            }
            let longSide = max(filter.nativeSize.width, filter.nativeSize.height)
            if longSide > 0 {
                filter.scaleFactor = min(1, Float(maxDimension) / Float(longSide))
            }
            // CIRAWFilter kennt weder Kurve noch Farbmischer – beide laufen
            // deshalb als Nachkette auf seiner Ausgabe. Dieselbe Funktion
            // wie im Nicht-RAW-Zweig, die beiden Pfade teilen sich hier
            // erstmals Code, statt ihn zu spiegeln.
            output = filter.outputImage.map { applyCurveAndMixer($0, adjustments) }
        } else {
            guard let source = CIImage(contentsOf: url, options: [.applyOrientationProperty: true])
            else { return nil }
            output = applyNonRawAdjustments(downscale(source, maxDimension: maxDimension), adjustments)
        }

        guard var renderedImage = output else { return nil }
        renderedImage = compositeMaskLayers(renderedImage, maskLayers)

        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
            let cgImage = sharedCIContext.createCGImage(
                renderedImage, from: renderedImage.extent, format: .RGBA8, colorSpace: colorSpace
            )
        else { return nil }

        return encodeJpeg(cgImage, quality: quality)
    }

    /// Legt [maskLayers] der Reihe nach über [base] (das bereits global
    /// angepasste Bild): pro Maske wird [applyNonRawAdjustments] auf den
    /// AKTUELLEN Zwischenstand angewendet (nicht auf [base] selbst – so
    /// wirken mehrere überlappende Masken tatsächlich nacheinander statt
    /// dass die letzte alle vorherigen überschreibt) und über
    /// `CIBlendWithMask` nur innerhalb der Maske zurückkompositiert. Die
    /// PNG-Maskendatei wird dafür auf die tatsächliche Arbeitsgröße von
    /// [base] skaliert (die kann je nach `maxDimension` von der Original-
    /// Auflösung abweichen, in der die Maske gespeichert wurde). Maske
    /// fehlt/unlesbar → diese eine Maske wird übersprungen, der Rest läuft
    /// normal weiter.
    private static func compositeMaskLayers(_ base: CIImage, _ maskLayers: [MaskLayer]) -> CIImage {
        var result = base
        for layer in maskLayers {
            guard let maskImage = CIImage(contentsOf: URL(fileURLWithPath: layer.path)) else { continue }
            let scaleX = result.extent.width / maskImage.extent.width
            let scaleY = result.extent.height / maskImage.extent.height
            let scaledMask = maskImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

            let adjusted = applyNonRawAdjustments(result, layer.adjustments)

            guard let blendFilter = CIFilter(name: "CIBlendWithMask") else { continue }
            blendFilter.setValue(adjusted, forKey: kCIInputImageKey)
            blendFilter.setValue(result, forKey: kCIInputBackgroundImageKey)
            blendFilter.setValue(scaledMask, forKey: kCIInputMaskImageKey)
            result = blendFilter.outputImage ?? result
        }
        return result
    }

    /// Liest eine Float32List vom Method-Channel als Swift-Array.
    ///
    /// Gibt `nil` zurück, wenn nichts da ist oder die Länge kein Vielfaches
    /// von 4 Byte ist – lieber den Filter weglassen als aus einem halben
    /// Wert eine Farbe zu erfinden.
    private static func floatArray(_ value: Any?) -> [Float]? {
        guard let typed = value as? FlutterStandardTypedData else { return nil }
        let data = typed.data
        guard !data.isEmpty, data.count % MemoryLayout<Float32>.size == 0 else { return nil }
        return data.withUnsafeBytes { roh in Array(roh.bindMemory(to: Float32.self)) }
    }

    /// Tonwertkurve und Farbmischer als Core-Image-Filter.
    ///
    /// Beide arbeiten in **sRGB**, nicht linear: Das ist die Konvention von
    /// Lightroom und darktable, und nur so entspricht die im Programm
    /// gezeichnete Kurve dem, was am Ende im Bild steht. `inputColorSpace`
    /// deshalb ausdrücklich setzen statt der Vorgabe zu vertrauen.
    ///
    /// Die Tabellen kommen fertig aus Dart – hier wird nichts gerechnet,
    /// nur übergeben (siehe [DevelopAdjustments.curveLut]).
    private static func applyCurveAndMixer(_ input: CIImage, _ a: DevelopAdjustments) -> CIImage {
        var image = input
        guard let raum = CGColorSpace(name: CGColorSpace.sRGB) else { return image }

        if let lut = a.curveLut, lut.count == 256 * 3, let f = CIFilter(name: "CIColorCurves") {
            f.setValue(image, forKey: kCIInputImageKey)
            f.setValue(Data(bytes: lut, count: lut.count * MemoryLayout<Float>.size),
                       forKey: "inputCurvesData")
            f.setValue(CIVector(x: 0, y: 1), forKey: "inputCurvesDomain")
            f.setValue(raum, forKey: "inputColorSpace")
            image = f.outputImage ?? image
        }

        if let cube = a.colorCube, a.colorCubeSize > 1,
            cube.count == a.colorCubeSize * a.colorCubeSize * a.colorCubeSize * 4,
            let f = CIFilter(name: "CIColorCubeWithColorSpace")
        {
            f.setValue(image, forKey: kCIInputImageKey)
            f.setValue(a.colorCubeSize, forKey: "inputCubeDimension")
            f.setValue(Data(bytes: cube, count: cube.count * MemoryLayout<Float>.size),
                       forKey: "inputCubeData")
            f.setValue(raum, forKey: "inputColorSpace")
            image = f.outputImage ?? image
        }

        return image
    }

    /// CIFilter-Kette für Nicht-RAW-Formate (JPEG/HEIC/PNG & Co.), als
    /// Ersatz für die CIRAWFilter-Eigenschaften oben – dieselben sechs
    /// Regler, nur auf dem bereits demosaicten Bild angewendet.
    /// Reihenfolge bewusst: Belichtung zuerst (wirkt sich sinnvoll auf
    /// nachfolgende Kontrast-/Schatten-Berechnungen aus), Weißabgleich vor
    /// Kontrast, Schärfen/Rauschunterdrückung zuletzt (arbeiten auf dem
    /// fertig tonkorrigierten Bild, wie bei RAW-Entwicklern üblich).
    /// Objektivkorrektur entfällt hier – die betrifft nur RAW-Rohdaten.
    private static func applyNonRawAdjustments(_ input: CIImage, _ a: DevelopAdjustments) -> CIImage {
        var image = input
        if a.exposure != 0, let f = CIFilter(name: "CIExposureAdjust") {
            f.setValue(image, forKey: kCIInputImageKey)
            f.setValue(a.exposure, forKey: kCIInputEVKey)
            image = f.outputImage ?? image
        }
        if let temperature = a.temperature, let f = CIFilter(name: "CITemperatureAndTint") {
            f.setValue(image, forKey: kCIInputImageKey)
            f.setValue(CIVector(x: 6500, y: 0), forKey: "inputNeutral")
            f.setValue(CIVector(x: CGFloat(temperature), y: CGFloat(a.tint ?? 0)), forKey: "inputTargetNeutral")
            image = f.outputImage ?? image
        }
        if a.contrast != 0, let f = CIFilter(name: "CIColorControls") {
            f.setValue(image, forKey: kCIInputImageKey)
            f.setValue(1.0 + a.contrast, forKey: kCIInputContrastKey)
            image = f.outputImage ?? image
        }
        if a.shadows != 0, let f = CIFilter(name: "CIHighlightShadowAdjust") {
            f.setValue(image, forKey: kCIInputImageKey)
            f.setValue(1.0 + a.shadows, forKey: "inputShadowAmount")
            image = f.outputImage ?? image
        }
        // Tonwertkurve und Farbmischer wirken auf dem tonkorrigierten Bild,
        // aber VOR Schärfe und Rauschunterdrückung: Eine steile Kurve nach
        // dem Schärfen würde dessen Säume mit verstärken. Im RAW-Zweig
        // ergibt sich dieselbe Reihenfolge von selbst, weil CIRAWFilter
        // Schärfe und Entrauschen schon vor seiner Ausgabe erledigt.
        image = applyCurveAndMixer(image, a)

        if a.sharpness > 0, let f = CIFilter(name: "CISharpenLuminance") {
            f.setValue(image, forKey: kCIInputImageKey)
            f.setValue(a.sharpness * 2.0, forKey: kCIInputSharpnessKey)
            image = f.outputImage ?? image
        }
        if a.noiseReduction > 0, let f = CIFilter(name: "CINoiseReduction") {
            f.setValue(image, forKey: kCIInputImageKey)
            f.setValue(a.noiseReduction, forKey: "inputNoiseLevel")
            f.setValue(0.4, forKey: kCIInputSharpnessKey)
            image = f.outputImage ?? image
        }
        return image
    }

    /// Skaliert [image] gleichmäßig herunter, falls die längste Seite über
    /// [maxDimension] px liegt – Core Image hat (anders als ImageIOs
    /// Thumbnail-Erzeugung) keine eingebaute "maximale Kantenlänge"-Option.
    private static func downscale(_ image: CIImage, maxDimension: Int) -> CIImage {
        let longSide = max(image.extent.width, image.extent.height)
        guard longSide > CGFloat(maxDimension), longSide > 0 else { return image }
        let scale = CGFloat(maxDimension) / longSide
        return image.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
    }

    private static func encodeJpeg(_ image: CGImage, quality: Double) -> Data? {
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            data, UTType.jpeg.identifier as CFString, 1, nil
        ) else { return nil }
        let options: [CFString: Any] = [kCGImageDestinationLossyCompressionQuality: quality]
        CGImageDestinationAddImage(destination, image, options as CFDictionary)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return data as Data
    }

    /// Erkennt Text in einer Bilddatei über Apples Vision-Framework (rein
    /// on-device, kein Modell-Download nötig, seit macOS 10.13 eingebaut).
    /// `.recognitionLevel = .accurate` statt `.fast`, da OCR beim Import im
    /// Hintergrund läuft und nicht interaktiv blockiert – Genauigkeit zählt
    /// hier mehr als Geschwindigkeit. Erkannte Zeilen werden mit `\n`
    /// verbunden zurückgegeben; bei keinem gefundenen Text ein leerer
    /// String (nicht `nil` – `nil` bedeutet "Erkennung fehlgeschlagen",
    /// siehe NativeImageConverter.recognizeText auf Dart-Seite).
    private static func recognizeText(path: String) -> String? {
        let url = URL(fileURLWithPath: path)
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
            let cgImage = CGImageSourceCreateThumbnailAtIndex(
                source, 0,
                [
                    kCGImageSourceCreateThumbnailFromImageAlways: true,
                    kCGImageSourceThumbnailMaxPixelSize: 2048,
                    kCGImageSourceCreateThumbnailWithTransform: true,
                ] as CFDictionary
            )
        else { return nil }

        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            return nil
        }
        let lines = (request.results ?? []).compactMap { $0.topCandidates(1).first?.string }
        return lines.joined(separator: "\n")
    }

    private struct VideoThumbnail {
        let jpeg: Data
        let durationSeconds: Double
    }

    /// Extrahiert einen einzelnen Frame aus einer Videodatei über
    /// AVFoundation (behebt das Platzhalter-Icon für Video-Thumbnails in der
    /// Kachelansicht) und liefert gleich die Videolänge mit, da beides über
    /// dasselbe AVAsset ohnehin benötigt wird.
    private static func videoThumbnail(path: String, maxDimension: Int) -> VideoThumbnail? {
        let url = URL(fileURLWithPath: path)
        let asset = AVURLAsset(url: url)
        let rawDuration = CMTimeGetSeconds(asset.duration)
        let durationSeconds = rawDuration.isFinite && rawDuration > 0 ? rawDuration : 0

        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: maxDimension, height: maxDimension)

        // Ein kleines Stück nach dem Start greifen statt exakt Frame 0 – bei
        // vielen Videos ist der allererste Frame schwarz oder unbrauchbar.
        let offsetSeconds = durationSeconds > 0 ? min(0.5, durationSeconds / 2) : 0
        let requestedTime = CMTime(seconds: offsetSeconds, preferredTimescale: 600)

        guard let cgImage = try? generator.copyCGImage(at: requestedTime, actualTime: nil) else {
            return nil
        }
        guard let jpeg = encodeJpeg(cgImage, quality: 0.8) else { return nil }
        return VideoThumbnail(jpeg: jpeg, durationSeconds: durationSeconds)
    }

    /// Schneidet ein Video nicht-destruktiv auf [startSeconds, endSeconds] zu
    /// – über AVFoundations `AVAssetExportSession` (dieselbe Art API, mit der
    /// z.B. auch Fotos.app/iMovie exportieren). Das Original bleibt
    /// unangetastet, das Ergebnis landet unter [outputPath]. Re-encodiert
    /// nach H.264/MP4 (`AVAssetExportPresetHighestQuality`) statt eines
    /// verlustfreien "Passthrough"-Exports, damit das Ergebnis unabhängig
    /// vom Quellcodec zuverlässig abspielbar bleibt. Ruft [completion] mit
    /// `true` bei Erfolg auf – auf einer beliebigen Queue (siehe
    /// `exportAsynchronously`), der Aufrufer (Channel-Handler oben) springt
    /// selbst auf den Hauptthread zurück, bevor er an Flutter antwortet.
    private static func trimVideo(
        path: String, outputPath: String, startSeconds: Double, endSeconds: Double,
        completion: @escaping (Bool) -> Void
    ) {
        let asset = AVURLAsset(url: URL(fileURLWithPath: path))
        guard
            let session = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
        else {
            completion(false)
            return
        }

        let outputURL = URL(fileURLWithPath: outputPath)
        try? FileManager.default.removeItem(at: outputURL)

        session.outputURL = outputURL
        session.outputFileType = .mp4
        session.timeRange = CMTimeRange(
            start: CMTime(seconds: startSeconds, preferredTimescale: 600),
            end: CMTime(seconds: endSeconds, preferredTimescale: 600)
        )
        session.exportAsynchronously {
            completion(session.status == .completed)
        }
    }
}
