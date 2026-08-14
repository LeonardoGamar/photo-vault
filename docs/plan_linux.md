# Umsetzungsplan Linux (voller Funktionsumfang)

Stand: August 2026, Branch `portierung/linux-windows`.
Voraussetzung: die Vorbereitung aus [portierung_linux_windows.md](portierung_linux_windows.md)
ist erledigt (Projektgerüst, Ordnerauswahl, Dateimanager).

Ziel dieses Plans: **Funktionsgleichheit mit der macOS-Fassung**, nicht nur
Lauffähigkeit.

## Die Lücke in Zahlen

Sieben Fähigkeiten fehlen unter Linux. Sechs stammen aus
`macos/Runner/ImageConverter.swift`, eine aus einem Paket:

| # | Fähigkeit | Heute (macOS) | Ohne Umsetzung fehlt |
|---|---|---|---|
| 1 | ~~Videowiedergabe~~ | ~~`video_player`~~ | **erledigt** – jetzt `media_kit` |
| 2 | HEIC/RAW → JPEG | ImageIO | alle iPhone-Fotos und RAW-Dateien unsichtbar |
| 3 | RAW-Entwicklung | CIRAWFilter / Core Image | „Entwickeln" wirkungslos |
| 4 | Video-Vorschaubild | AVFoundation | Videos ohne Thumbnail |
| 5 | Video-Zuschnitt | AVFoundation | Funktion nicht verfügbar |
| 6 | Texterkennung (OCR) | Vision | keine Textsuche in Fotos |
| 7 | Objektivkorrektur | CIRAWFilter | Teil von (3) |

## Grundsatzentscheidung: Systembibliotheken statt Eigenbau

Unter Linux gibt es für jede dieser Aufgaben eine etablierte Bibliothek.
Zwei Wege stehen offen:

**A – Kommandozeilenwerkzeuge aufrufen** (`heif-convert`, `dcraw_emu`,
`ffmpeg`, `tesseract`). Schnell umgesetzt, robust, aber die App hängt an
installierten Fremdprogrammen.

**B – Bibliotheken per Dart FFI einbinden** (`libheif`, `libraw`,
`libavcodec`, `libtesseract`). Kein Prozessstart je Bild, feinere Kontrolle,
aber deutlich mehr Aufwand: Für keine dieser Bibliotheken existiert ein
brauchbares fertiges Dart-Paket (geprüft – `heic_to_png_jpg` fällt auf
Desktop auf das Dart-`image`-Paket zurück und kann HEIC dort gerade nicht).
Ein eigener FFI-Wrapper je Bibliothek wäre nötig.

**Empfehlung: A, ausgeliefert als Flatpak.** Der Einwand gegen A – die
Fremdabhängigkeiten – verschwindet, sobald die App als Flatpak
ausgeliefert wird: dort werden `ffmpeg`, `libheif`, `tesseract` und
`libmpv` mit ins Bundle gepackt und sind garantiert vorhanden. Man bekommt
den geringen Aufwand von A ohne dessen Nachteil. FFI bleibt später als
Optimierung möglich, ohne dass sich die Schnittstelle ändert.

## Phasen

Reihenfolge nach Nutzen: Was die meisten Fotos betrifft, kommt zuerst.

### Phase 0 – Bauen und starten (Grundlage)

**Auf der Linux-Maschine als Erstes ausführen:**

```bash
tool/linux_setup_check.sh
```

Das Skript prüft Bau-Voraussetzungen (Flutter, clang, cmake, ninja,
pkg-config, GTK 3) und Laufzeit-Werkzeuge (libmpv, ffmpeg, heif-convert,
dcraw_emu) und nennt zu jedem fehlenden Stück den Installationsbefehl.
Fehlende Laufzeit-Werkzeuge verhindern den Build nicht – sie kosten nur
einzelne Funktionen.

Auf Debian/Ubuntu meist in einem Rutsch:

```bash
sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev \
                 libmpv-dev mpv ffmpeg libheif-examples libraw-bin
```

Danach:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d linux
```

**Worauf beim ersten Start zu achten ist:**

1. Startet die App und erscheint die Timeline?
2. Lässt sich unter Einstellungen → Speicherort ein Ordner wählen? (Das
   war der ursprüngliche Blocker, jetzt über `folder_access_desktop.dart`.)
3. Importieren JPG/PNG samt Thumbnail?
4. Spielt ein Video ab? (media_kit, braucht libmpv)
5. Erscheint bei HEIC/RAW ein Vorschaubild? (braucht heif-convert bzw.
   dcraw_emu, siehe Phase 2)

Erwartete Stolpersteine: Pfadtrennzeichen, die sqlite3-Bibliothek und
Groß-/Kleinschreibung bei Dateinamen (Linux unterscheidet sie, macOS
üblicherweise nicht).

### Phase 1 – Videowiedergabe (`media_kit`) — **ERLEDIGT**

`video_player` ist vollständig durch `media_kit` ersetzt. Da dieses alle
sechs Plattformen abdeckt, war keine plattformabhängige Variante nötig –
es gibt weiterhin genau eine Wiedergabe-Implementierung.

Umgesetzt in `lib/widgets/video_playback.dart`:
`VideoPlaybackController` (öffnen, abspielen, pausieren, spulen,
Dauerschleife, Dauer, Seitenverhältnis), `VideoSurface` (Bildausgabe) und
`VideoProgressBar` – letztere ersetzt `VideoProgressIndicator`, für das es
bei `media_kit` keine Entsprechung gibt.

Angepasst: `asset_viewer_screen.dart`, `video_trim_screen.dart`,
`live_photo_view.dart`; `MediaKit.ensureInitialized()` in `main.dart`.

Auf macOS real gegen ein Video aus der Bibliothek geprüft: Öffnen in
457 ms, korrekte Dauer (31,96 s) und Seitenverhältnis, Position läuft in
Echtzeit weiter, 29,9 % nicht-schwarze Pixel (es wird also wirklich Bild
gerendert, nicht nur Ton), Pausieren und Zurückspulen funktionieren.

Die Plugin-Registrierung für Linux (`media_kit_libs_linux`) und Windows
(`media_kit_libs_windows_video`) ist erzeugt, dort aber **noch ungetestet**
– unter Linux wird zusätzlich `libmpv` gebraucht (im Flatpak zu bündeln).

Nebeneffekt: Das Projekt nutzt für macOS/iOS jetzt CocoaPods statt Swift
Package Manager, da `media_kit` nur damit ausgeliefert wird.

### Phase 2 – HEIC und RAW lesbar machen — **GESCHRIEBEN, UNGETESTET**

Umgesetzt in `lib/services/platform/linux_image_tools.dart`:

- **HEIC/HEIF:** `heif-convert` (Paket `libheif-examples`)
- **RAW:** `dcraw_emu` aus LibRaw (Paket `libraw-bin`), Ausgabe als TIFF

Beide schreiben in einen temporären Ordner, der anschließend immer
aufgeräumt wird; das Verkleinern übernimmt das `image`-Paket in einem
Isolate (`compute`), damit die UI nicht blockiert. Die RAW-Datei wird
vorher in den Temp-Ordner kopiert, weil `dcraw_emu` sonst neben das
Original schreiben würde – die Bibliothek bleibt unangetastet.

`NativeImageConverter` bleibt die einzige Anlaufstelle und verzweigt
intern nach Plattform; die 11 Aufrufstellen in der App sind unverändert.

**Noch offen:** `developImage` (die Entwickeln-Regler) hat unter Linux
weiterhin keine Entsprechung – dafür braucht es Phase 3 als maßgeblichen
Renderpfad. Ebenso die HDR-Gain-Map-Behandlung aus `convertHdrAwareJpeg`:
Das Bild wird korrekt angezeigt, nur ohne HDR-Feinheiten.

### Phase 3 – Entwickeln: Regler als Shader — **TEILWEISE ERLEDIGT**

`shaders/develop_adjustments.frag` bildet Belichtung, Weißabgleich,
Kontrast und Schatten in GLSL nach – die portable Entsprechung zu
`applyNonRawAdjustments`. Angebunden über
`lib/widgets/develop_preview.dart`.

**Rolle heute:** Live-Vorschau während des Regler-Ziehens. Maßgeblich für
das gespeicherte Ergebnis bleibt der native Renderpfad – bei RAW wirken
die Regler dort auf den Rohdaten (CIRAWFilter beim Demosaicing), was
deutlich mehr Spielraum hat als eine nachträgliche Korrektur.

**Real gemessene Abweichung** vom nativen Render (mittlere Helligkeit
desselben Fotos):

| Einstellung | Abweichung |
|---|---|
| neutral | 0,1 % |
| Belichtung +1 EV | 0,1 % |
| Kontrast +0,5 | 1,3 % |
| Temperatur 3200 K | 6,1 % |
| Temperatur 9000 K | 0,4 % |

Wegen der Abweichung beim warmen Weißabgleich sind **Temperatur und Tint
von der Live-Vorschau ausgenommen** (`liveVorschau: false` am jeweiligen
Regler): Gerade dort beurteilt man die Farbe, eine genäherte Vorschau
würde zu falschen Einstellungen verleiten.

Ebenfalls nicht im Shader: Schärfe und Rauschunterdrückung (brauchen
Nachbarpixel bzw. echte Entrauschung) sowie Masken – bei vorhandenen
Masken bleibt es beim nativen Render, da die neutrale Basis keine
Maskenwirkung enthält.

**Für Linux bleibt zu tun:** den Shader vom Vorschau- zum maßgeblichen
Renderpfad machen (dort gibt es kein Core Image), inklusive Schärfe,
Rauschunterdrückung und Maskenkomposition, gespeist aus einem per LibRaw
dekodierten Bild (Phase 2).

### Phase 4 – Video-Vorschaubild und -Zuschnitt — **GESCHRIEBEN, UNGETESTET**

Ebenfalls in `linux_image_tools.dart`:
- Vorschaubild: `ffmpeg` extrahiert einen Frame bei Sekunde 1 (nicht bei 0
  – der allererste Frame ist bei vielen Videos schwarz) und skaliert dabei
  gleich mit
- Länge: `ffprobe`
- Zuschnitt: `ffmpeg -c copy`, also verlustfrei ohne Neukodierung –
  entspricht dem nicht-destruktiven Verhalten unter macOS

### Phase 5 – Texterkennung (OCR)

Zwei Wege:
- **`tesseract`** – ausgereift, viele Sprachen, ein weiteres Systempaket
- **ONNX-OCR-Modell** – die ONNX-Runtime ist bereits eingebunden und
  unterstützt Linux; das Modell ließe sich über den bestehenden
  Modellkatalog nachladen, ganz ohne Systemabhängigkeit, und würde auf
  **allen** Plattformen gleich funktionieren

Empfehlung: das ONNX-Modell, passend zur bestehenden Architektur
(„nichts wird mitgeliefert, alles nachladbar"). Tesseract nur, falls die
Erkennungsqualität nicht reicht.

### Phase 6 – Paketierung

**Flatpak** als primäres Format: bündelt `ffmpeg`, `libheif`, LibRaw,
`libmpv` und ggf. `tesseract`, funktioniert distributionsunabhängig und
löst damit sämtliche Abhängigkeitsfragen der Phasen 1–5 auf einen Schlag.

Zu beachten: Flatpak sandboxt Dateizugriffe. Der frei wählbare
Bibliotheksordner braucht deshalb entweder die passende Berechtigung
(`--filesystem=home`) oder den Weg über XDG-Portale. Das betrifft
`folder_access_desktop.dart` – dort ist bereits ein `try/catch` für genau
diesen Fall vorgesehen.

Ergänzend ein `.deb`/AppImage, falls Flatpak nicht gewünscht ist; dann
müssen die Abhängigkeiten als Paketabhängigkeiten deklariert werden.

## Reihenfolge auf einen Blick

```
Phase 1  Videowiedergabe          ERLEDIGT (auf macOS verifiziert)
Phase 3  Entwickeln-Shader        TEILWEISE (Live-Vorschau steht)
Phase 2  HEIC/RAW lesbar          geschrieben, wartet auf Linux-Test
Phase 4  Video-Thumbnail/Schnitt  geschrieben, wartet auf Linux-Test
Phase 0  bauen/starten            Grundlage, blockiert alles Weitere
Phase 5  OCR                      am wenigsten kritisch
Phase 6  Flatpak                  parallel ab Phase 2 sinnvoll
```

Phase 2 vor Phase 1: Ein unsichtbares Foto wiegt schwerer als ein nicht
abspielbares Video, und HEIC betrifft praktisch jede iPhone-Bibliothek.

## Was dieser Plan bewusst offen lässt

- **Windows** – dieselbe Struktur, andere Werkzeuge (Media Foundation bzw.
  dieselben CLI-Werkzeuge als mitgelieferte Binärdateien). Erst nach Linux
  sinnvoll, da die Abstraktionen dann bereits stehen.
- **Zeitschätzungen** – ohne einen realen Linux-Build (Phase 0) wären sie
  geraten.
