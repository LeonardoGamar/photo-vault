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
| 1 | Videowiedergabe | `video_player` (AVFoundation) | Videos, Live Photos, Video-Zuschnitt-Vorschau |
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

Auf einem echten Linux-System (oder in einer VM/Container) `flutter build
linux` durchführen und die App starten. Erwartete Stolpersteine: fehlende
Systempakete (`libgtk-3-dev`, `libsecret`), Pfadtrennzeichen, sqlite3-
Bibliothek. Ohne diesen Schritt ist alles Weitere Spekulation – **von macOS
aus nicht durchführbar.**

Ergebnis: App startet, Timeline zeigt JPG/PNG, Datenbank und
Verschlüsselung funktionieren.

### Phase 1 – Videowiedergabe (`media_kit`)

Betrifft `asset_viewer_screen.dart`, `video_trim_screen.dart`,
`live_photo_view.dart`.

`media_kit` unterstützt alle Zielplattformen inklusive macOS. Deshalb
**vollständig ersetzen statt parallel führen** – am Ende gibt es eine
Wiedergabe-Implementierung, nicht zwei. Unter Linux wird `libmpv`
gebraucht (im Flatpak gebündelt).

Vorgehen: hinter einer eigenen Abstraktion in `lib/services/platform/`
kapseln, zuerst unter macOS umstellen und dort gegen die bestehende
Funktion prüfen (Live-Photo-Wiedergabe per Gedrückthalten, framegenaues
Suchen im Zuschnitt-Bildschirm), erst danach Linux.

### Phase 2 – HEIC und RAW lesbar machen (größter Nutzen)

Ohne diesen Schritt sind iPhone-Fotos und RAW-Dateien schlicht unsichtbar.

Neue Datei `lib/services/platform/image_decoder_linux.dart`, die dieselbe
Rolle erfüllt wie `convertToJpeg` unter macOS:

- **HEIC/HEIF:** `heif-convert` (Paket `libheif-examples`)
- **RAW:** `dcraw_emu` aus LibRaw, alternativ `darktable-cli`

Beides schreibt in eine temporäre Datei, die dann wie bisher weiterverarbeitet
wird. Die Aufrufe gehören in ein Isolate (`compute`), damit die UI nicht
blockiert – dasselbe Muster wie beim bestehenden Thumbnail-Pfad.

**Wichtig:** Die HDR-Gain-Map-Behandlung aus `convertHdrAwareJpeg` hat unter
Linux keine direkte Entsprechung. Für v1 akzeptabel (Bild wird korrekt
angezeigt, nur ohne HDR-Feinheiten), sollte aber dokumentiert werden.

### Phase 3 – Entwickeln (der anspruchsvollste Teil)

Core Image hat unter Linux keine Entsprechung. Statt einen Ersatz zu suchen,
bietet sich ein **Fragment-Shader in Flutter selbst** an: Belichtung,
Kontrast, Schatten, Temperatur, Tint und die Maskenebenen sind reine
Pixeloperationen und lassen sich in GLSL abbilden (`FragmentProgram`,
seit Flutter 3.7).

Das ist mehr Arbeit als ein CLI-Aufruf, hat aber drei Vorteile: es
funktioniert auf **allen** Plattformen identisch, läuft auf der GPU (also
schneller als der heutige native Umweg über eine Datei), und macht die
Vorschau live statt nach jedem Reglerstopp neu gerendert.

Bleibt zweigeteilt:
- **Anpassungen** (Belichtung, Kontrast, …) → Shader, plattformübergreifend
- **RAW-Demosaicing + Objektivkorrektur** → weiter nativ; unter Linux über
  LibRaw (Objektivkorrektur via `lensfun`, das LibRaw anbinden kann)

Empfehlung: Shader zuerst und plattformübergreifend einführen, danach RAW.
Der Shader-Teil ist auch für macOS ein Gewinn.

### Phase 4 – Video-Vorschaubild und -Zuschnitt (`ffmpeg`)

Beides direkt über `ffmpeg`:
- Vorschaubild: einzelnes Bild an einer Zeitposition extrahieren
- Zuschnitt: verlustfrei schneiden (`-c copy`), also ohne Neukodierung –
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
Phase 0  bauen/starten            Grundlage, blockiert alles Weitere
Phase 2  HEIC/RAW lesbar          größter Nutzen für Nutzer
Phase 1  Videowiedergabe          betrifft alle Videos
Phase 4  Video-Thumbnail/Schnitt  ergänzt Phase 1
Phase 3  Entwickeln (Shader)      größter Aufwand, auch macOS-Gewinn
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
