# Portierung nach Windows

Der Plan zur Linux-Portierung (`docs/plan_linux.md`) hat sich als
tragfähig erwiesen: sechs Phasen, jede für sich lauffähig, jede auf echter
Hardware belegt. Dieser Plan folgt derselben Form – und profitiert davon,
dass die Linux-Arbeit die plattformabhängigen Stellen bereits
herausgezogen hat.

## Der Ausgangspunkt ist deutlich besser als bei Linux

**Erhoben, nicht geschätzt** (Stand v1.8.3):

| | |
|---|---|
| `Platform.isWindows` im Quelltext | **1** Stelle (`reveal_in_file_manager.dart`, `explorer`) |
| Dateien mit Plattformweichen insgesamt | 8 |
| `windows/`-Gerüst | vorhanden, 18 Dateien, in Git |
| Pakete mit Windows-Unterstützung | alle geprüften |

Nachgesehen in den Paket-Metadaten: `flutter_onnxruntime`,
`media_kit_video` (samt `media_kit_libs_windows_video`), `file_picker`
(über Dart und `win32`, **kein** externer Dialog nötig), `url_launcher`,
`path_provider` und `share_plus` führen Windows ausdrücklich. Das ist der
grösste Unterschied zu Linux: Dort fehlte mit `libmpv` und dem
HEVC-Dekoder handfeste Infrastruktur.

**Drei Dinge fallen Windows ohne eigene Arbeit zu**, weil die
Linux-Portierung sie plattformneutral gebaut hat:

1. **Entwickeln.** `lib/services/develop_render.dart` rendert über den
   Fragment-Shader und gilt für *alles ausser macOS*
   (`istMassgeblich => !Platform.isMacOS`). Windows bekommt damit sofort
   den vollen Regler-Satz bis auf die vier bekannten Ausnahmen (Schärfe,
   Rauschunterdrückung, Klarheit, Vignettierung).
2. **Texterkennung.** `OcrService` läuft über nachladbare ONNX-Modelle,
   nicht über eine Systemschnittstelle – einschliesslich des
   `HardSwish`-Umbaus, der die Modelldatei beim ersten Laden umschreibt.
   Ob der zugrundeliegende Fremdfehler auch unter Windows auftritt, ist
   offen; der Umbau schadet dort nicht.
3. **Die Oberflächenschrift.** Seit v1.8.3 wählt `app_theme.dart` je
   Plattform: macOS `.AppleSystemUIFont`, Windows `Segoe UI Variable`
   (Rückfall `Segoe UI`), sonst `Adwaita Sans`.

## Was fehlt

`NativeImageConverter.isSupported()` gibt ausserhalb von macOS `false`
zurück, und `LinuxImageTools` heisst nicht ohne Grund so. Unter Windows
fehlen damit heute:

| Fähigkeit | heute | Folge |
|---|---|---|
| HEIC/HEIF lesen | – | iPhone-Fotos ohne Vorschau, nicht zu öffnen |
| RAW lesen | – | dasselbe für alle Hersteller-RAWs |
| Video-Vorschaubild | – | Videos ohne Bild in der Zeitleiste |
| Videolänge | – | keine Dauer in den Angaben |
| Video-Zuschnitt | – | Funktion fehlt |

## Der entscheidende Entwurf: Werkzeuge oder Systemschnittstelle?

Windows böte für HEIC die **Windows Imaging Component** an. Das ist ein
Irrweg, und zwar aus einem Grund, den man kennen muss: HEIF-Dateien
öffnet WIC nur, wenn die **HEVC Video Extensions** installiert sind – ein
Paket, das Microsoft im Store **kostenpflichtig** anbietet. Eine
Fotoverwaltung, die iPhone-Fotos erst nach einem Kauf anzeigt, ist keine.

Dieselbe Falle wie unter Linux, wo Ubuntu libheif ohne Dekoder
ausliefert – nur teurer. Die Antwort ist deshalb dieselbe: **die Werkzeuge
mitliefern.** `heif-convert.exe`, `dcraw_emu.exe`, `ffmpeg.exe` und
`ffprobe.exe` neben die Anwendung legen, so wie das Flatpak sie ins Bündel
nimmt.

Damit wird aus `LinuxImageTools` eine gemeinsame Klasse. Der Umbau ist
klein, weil die Struktur schon steht:

* Die Werkzeugsuche über `PATH` liegt bereits in Dart und kennt keine
  Linux-Eigenheit – nur `Platform.pathSeparator` und das Ausführungsbit,
  das unter Windows entfällt (dort zählt die Endung `.exe`).
* Alle Aufrufe laufen über `Process.run` mit Argumentlisten, nicht über
  eine Shell. Anführungszeichen und Leerzeichen in Pfaden sind damit
  bereits richtig behandelt.
* `dcraw_emu` schreibt neben die Eingabedatei, weshalb schon heute in
  einen Temp-Ordner kopiert wird – unter Windows genauso nötig.

**Zu prüfen bleibt:** ob `heif-convert.exe` bei mehrbildrigen Dateien
dieselbe `out-1.jpg`-Benennung verwendet (der Sonderfall ist in
`convertToJpeg` bereits behandelt) und ob `ffmpeg` mit Laufwerksbuchstaben
in `-i` klarkommt, wenn der Pfad ein Doppelpunkt enthält.

## Zuschnitt: sechs Phasen

| | Inhalt | Wichtigster Beleg |
|---|---|---|
| **0** | Bauen und starten. `flutter build windows`, App startet, legt Datenbank an, Suite grün | `PRAGMA user_version` = 45 in der angelegten Datei |
| **1** | Werkzeugschicht: `LinuxImageTools` → `DesktopImageTools`, Endung `.exe`, Suche ohne Ausführungsbit | Bestandstests laufen unverändert weiter |
| **2** | HEIC und RAW gegen echte Dateien | dieselbe Testtafel wie unter Linux |
| **3** | Video: Vorschaubild, Länge, verlustfreier Zuschnitt | `-ss`/`-to` **vor** `-i`, wie unter Linux |
| **4** | Wiedergabe über `media_kit` samt `media_kit_libs_windows_video` | ein Video spielt wirklich ab |
| **5** | Namen und Optik: Fenstertitel, `Runner.rc`, Symbol | `photo_vault` steht an **vier** Stellen |
| **6** | Paketierung: MSIX oder Verzeichnis samt Werkzeugen | Start auf einer Maschine, auf der nie gebaut wurde |

Phase 5 ist klein, aber nicht optional: In `windows/runner/main.cpp` und
dreimal in `windows/runner/Runner.rc` steht `photo_vault`. Dasselbe Versäumnis
wie unter Linux, wo das Fenster bis v1.8.3 `photo_vault` hiess.

## Was aus der Linux-Runde zu übernehmen ist

Diese Punkte haben dort Zeit gekostet und sind hier vorhersehbar:

* **Auf der Zielmaschine messen, nicht auf der Baumaschine.** Das Flatpak
  lud ONNX Runtime klaglos aus dem Bauverzeichnis; erst das Ausblenden des
  Heimatordners zeigte, dass die Bibliothek im Bündel fehlte. Unter
  Windows ist das Gegenstück: eine DLL, die nur deshalb gefunden wird,
  weil sie im Bauordner oder in `PATH` liegt. **Die Probe gehört auf eine
  Maschine ohne Entwicklungsumgebung.**
* **„Vorhanden" ist nicht „läuft".** `where heif-convert.exe` genügt
  nicht; das Werkzeug muss aufgerufen werden. Unter Linux lag einmal ein
  libtool-Hüllskript statt des Programms an der Stelle.
* **Die Kennung nicht anfassen.** Aus ihr leitet sich der Ablageort ab.
  Unter Windows ist das `%APPDATA%\<Kennung>` – ein Wechsel liesse die
  Bibliothek einer benutzten Installation verschwinden.
  `test/linux_kennung_test.dart` hält das für Linux fest; ein Gegenstück
  für Windows gehört dazu.
* **Debug-Bauten messen nicht.** Ein Download kam im Debug-Bau auf ein
  Sechstel der echten Geschwindigkeit.

## Offene Fragen, die nur eine Maschine beantwortet

1. **Gibt es überhaupt eine Windows-Maschine?** Die Linux-Portierung kam
   erst voran, als eine bereitstand. Ohne sie lässt sich Phase 0 nicht
   abschliessen, und alles Weitere wäre geraten.
2. **`sqlite3_flutter_libs`** liefert in der eingesetzten Fassung keine
   eigenen Plattformordner mehr, sondern zieht die Bibliothek über
   Build-Hooks. Ob das unter Windows greift, zeigt der erste Bau.
3. **Woher kommen die Werkzeug-Binärdateien?** Für Linux liefert das
   Flatpak sie aus dem Quellcode. Für Windows gibt es fertige Bauten
   (libheif, LibRaw, ffmpeg als `gyan.dev`- oder `BtbN`-Bauten). Sie
   müssen mit Prüfsumme festgelegt werden, wie die Modelle im Katalog –
   ein Werkzeug ohne Prüfsumme im Installationspaket wäre ein
   Einfallstor.
4. **Signatur.** Ohne Zertifikat meldet sich SmartScreen bei jedem
   Download, ähnlich wie Gatekeeper auf macOS. Ein
   EV-Code-Signing-Zertifikat kostet jährlich; ohne es bleibt es bei der
   Warnung.

## Was dieser Plan bewusst offen lässt

* **Windows on ARM.** Flutter baut dafür, die Werkzeug-Binärdateien gibt
  es aber überwiegend nur für x64. Erst nach x64 sinnvoll.
* **Die Objektivkorrektur.** Sie hängt auf macOS an `CIRAWFilter`; unter
  Linux fehlt sie ebenso. LibRaw kann sie nicht ersetzen, ohne eine
  eigene Objektivdatenbank mitzubringen.
* **Zeitschätzungen.** Ohne einen ersten echten Bau wären sie geraten –
  dieselbe Zurückhaltung wie im Linux-Plan.
