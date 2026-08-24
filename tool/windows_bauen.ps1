# Baut Photo Vault als Windows-Paket.
#
#   tool\windows_bauen.ps1 [-Pruefen] [-Zip]
#
#     -Pruefen  Nach dem Bau nachsehen, ob die mitgelieferten Werkzeuge
#               wirklich da sind und koennen, was sie sollen - und zwar
#               OHNE den PATH dieses Rechners.
#     -Zip      Das fertige Verzeichnis einpacken.
#
# Kein MSIX: Ein MSIX-Paket muss signiert sein, und ohne Zertifikat muss
# der Nutzer erst ein selbst erzeugtes in seinen Stammspeicher aufnehmen -
# eine hoehere Huerde als die SmartScreen-Warnung, die er ohnehin bekommt.
# Ein Verzeichnis zum Auspacken ist ehrlicher und entspricht dem, was das
# Flatpak unter Linux leistet: alles dabei, nichts nachzuinstallieren.
[CmdletBinding()]
param([switch]$Pruefen, [switch]$Zip)

$ErrorActionPreference = 'Stop'

# PowerShell 5.1 wertet unter ErrorActionPreference=Stop jede Ausgabe eines
# fremden Programms auf stderr als abbrechenden Fehler - auch eine blosse
# Warnung. `flutter build` schreibt dorthin. Bisher ging es gut, aber nur
# zufaellig; in windows_werkzeuge.ps1 hat genau das einen Lauf still
# beendet, mit Rueckgabewert 0 und halbem Ergebnis.
function Fremd {
  param([string]$Programm, [string[]]$Argumente)
  $alt = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  try {
    & $Programm @Argumente 2>&1 | ForEach-Object { Write-Host "  $_" }
    return $LASTEXITCODE
  } finally { $ErrorActionPreference = $alt }
}

$Wurzel = [System.IO.Path]::GetFullPath("$PSScriptRoot\..")
$Bundle = "$Wurzel\build\windows\x64\runner\Release"
$Werkzeuge = "$Wurzel\build\windows\werkzeuge"
$Paket = "$Wurzel\build\windows\paket\PhotoVault"

function Titel($t) { Write-Host ""; Write-Host $t; Write-Host ('-' * $t.Length) }
function Gut($t)   { Write-Host "  [ok] $t" -ForegroundColor Green }
function Schlecht($t) { Write-Host "  [!!] $t" -ForegroundColor Red; $script:Fehler++ }
$script:Fehler = 0

Titel "Voraussetzungen"
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) { Schlecht "flutter fehlt"; exit 1 }
Gut "flutter"
if (-not (Test-Path "$Werkzeuge\heif-dec.exe")) {
  Schlecht "Werkzeuge fehlen - erst tool\windows_werkzeuge.ps1 laufen lassen"
  exit 1
}
Gut "Werkzeuge liegen bereit"

Titel "Flutter-Bundle bauen"
Push-Location $Wurzel
$rc = Fremd 'flutter' @('build', 'windows', '--release')
Pop-Location
if ($rc -ne 0) { Schlecht "flutter build fehlgeschlagen"; exit 1 }
if (-not (Test-Path "$Bundle\photo_vault.exe")) { Schlecht "keine photo_vault.exe"; exit 1 }
Gut "photo_vault.exe"

Titel "Paket zusammenstellen"
Remove-Item -Recurse -Force $Paket -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force $Paket | Out-Null
Copy-Item "$Bundle\*" $Paket -Recurse -Force
# Die Werkzeuge in einen Unterordner "tools". Genau dort sucht
# DesktopImageTools zuerst, noch vor dem PATH - siehe suchpfade() dort.
Copy-Item $Werkzeuge "$Paket\tools" -Recurse -Force
$mb = ((Get-ChildItem $Paket -Recurse -File | Measure-Object Length -Sum).Sum / 1MB)
Gut ("{0:N0} MB unter {1}" -f $mb, $Paket)

Titel "Was die App selbst mitbringen muss"
# Das Flatpak lud ONNX Runtime einmal klaglos aus dem Bauverzeichnis; im
# Buendel fehlte sie. Auf jedem anderen Rechner waeren damit saemtliche
# KI-Funktionen ausgefallen, ohne dass es hier aufgefallen waere.
foreach ($dll in 'onnxruntime.dll', 'libmpv-2.dll', 'flutter_windows.dll') {
  if (Test-Path "$Paket\$dll") {
    Gut ("{0} ({1:N0} MB)" -f $dll, ((Get-Item "$Paket\$dll").Length / 1MB))
  } else {
    Schlecht "$dll fehlt im Paket"
  }
}

if ($Pruefen) {
  Titel "Werkzeuge - ohne den PATH dieses Rechners"
  # Der wichtigste Handgriff dieser Pruefung. Mit dem eigenen PATH faende
  # sich heif-dec.exe auch dann, wenn es im Paket fehlte: Es liegt hier
  # unter C:\msys64. Auf einer fremden Maschine gaebe es das nicht.
  $sauber = "$env:SystemRoot\System32;$env:SystemRoot"
  function ImPaket($exe, $argumente) {
    $alt = $env:PATH
    try {
      $env:PATH = $sauber
      $aus = & "$Paket\tools\$exe" @argumente 2>&1 | Out-String
      return @{ rc = $LASTEXITCODE; aus = $aus }
    } catch {
      return @{ rc = -1; aus = "$_" }
    } finally { $env:PATH = $alt }
  }

  # Vorhandensein genuegt nicht - aufrufen. Unter Linux lag einmal ein
  # libtool-Huellskript statt des Programms an der Stelle, und `which` war
  # damit zufrieden.
  foreach ($w in @(
      @{ n = 'heif-dec.exe';   a = @('--version') }
      @{ n = 'dcraw_emu.exe';  a = @() }
      @{ n = 'ffmpeg.exe';     a = @('-hide_banner', '-version') }
      @{ n = 'ffprobe.exe';    a = @('-hide_banner', '-version') })) {
    $e = ImPaket $w.n $w.a
    if ($e.aus -match 'nicht gefunden|not found|0xc000007b|kann nicht gefunden') {
      Schlecht ("{0}: {1}" -f $w.n, ($e.aus -split "`n")[0])
    } elseif ([string]::IsNullOrWhiteSpace($e.aus)) {
      Schlecht ("{0}: keine Ausgabe, Rueckgabewert {1}" -f $w.n, $e.rc)
    } else {
      Gut "$($w.n) laeuft"
    }
  }

  # Das eigentliche Versprechen: Vorhandensein genuegt nicht, libheif muss
  # den Bildinhalt auch auspacken koennen. Genau daran ist unter Linux der
  # erste Versuch gescheitert - Ubuntu liefert libheif ohne HEVC-Dekoder.
  $dek = ImPaket 'heif-dec.exe' @('--list-decoders')
  if ($dek.aus -match '(?s)HEIC decoders:\s*\r?\n\s*-') {
    Gut "libheif hat einen HEVC-Dekoder"
  } else {
    Schlecht "libheif ohne HEVC-Dekoder - HEIC-Fotos blieben unsichtbar"
  }
  if ($dek.aus -match '(?s)AVIF decoders:\s*\r?\n\s*-') {
    Gut "libheif hat einen AVIF-Dekoder"
  } else {
    Schlecht "libheif ohne AVIF-Dekoder"
  }
  $ffd = ImPaket 'ffmpeg.exe' @('-hide_banner', '-decoders')
  if ($ffd.aus -match '(?m)^\s*V[.A-Z]*\s+hevc\s') {
    Gut "ffmpeg kann HEVC lesen"
  } else {
    Schlecht "ffmpeg ohne HEVC - Videovorschauen blieben leer"
  }
  # Vorschaubilder werden als JPEG geschrieben. Der Dekoder allein genuegt
  # dafuer nicht - es braucht auch den mjpeg-Kodierer. Ein H.264-Kodierer
  # dagegen fehlt der LGPL-Fassung, und das ist in Ordnung: Geschnitten
  # wird mit -c copy.
  $ffe = ImPaket 'ffmpeg.exe' @('-hide_banner', '-encoders')
  if ($ffe.aus -match '(?m)^\s*V[.A-Z]*\s+mjpeg\s') {
    Gut "ffmpeg kann JPEG schreiben (Vorschaubilder)"
  } else {
    Schlecht "ffmpeg ohne mjpeg-Kodierer - Videovorschauen blieben leer"
  }

  # Und einmal richtig: eine echte HEIC-Datei auspacken.
  $probe = "$Wurzel\test\fixtures\werkzeuge\probe.heic"
  if (Test-Path $probe) {
    $raus = Join-Path $env:TEMP 'pv_paketprobe.jpg'
    Remove-Item $raus -Force -ErrorAction SilentlyContinue
    $u = ImPaket 'heif-dec.exe' @($probe, $raus)
    if ((Test-Path $raus) -and (Get-Item $raus).Length -gt 1000) {
      Gut ("HEIC ausgepackt ({0:N0} Bytes JPEG)" -f (Get-Item $raus).Length)
    } else {
      Schlecht "HEIC liess sich nicht auspacken: $($u.aus)"
    }
  }
}

if ($Zip) {
  Titel "Einpacken"
  # Nicht $zip: PowerShell unterscheidet keine Gross- und Kleinschreibung,
  # die Zuweisung landete sonst im Schalter $Zip - und der Versuch, eine
  # Zeichenkette in einen Schalter zu schreiben, brach das Skript ab.
  $zipDatei = "$Wurzel\build\windows\PhotoVault-windows-x64.zip"
  Remove-Item $zipDatei -Force -ErrorAction SilentlyContinue
  # Nicht Compress-Archive: Das scheiterte hier still an den langen Pfaden
  # unter data\flutter_assets - das Skript endete mitten im Abschnitt, mit
  # Rueckgabewert 0 und ohne Datei. ZipFile kommt damit zurecht.
  try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory(
      $Paket, $zipDatei,
      [System.IO.Compression.CompressionLevel]::Optimal,
      $true)   # $true: den Ordner PhotoVault mit einpacken, nicht nur seinen Inhalt
    Gut ("{0:N0} MB  {1}" -f ((Get-Item $zipDatei).Length / 1MB), $zipDatei)
  } catch {
    Schlecht "Einpacken fehlgeschlagen: $($_.Exception.Message)"
  }
}

Write-Host ""
if ($script:Fehler -gt 0) { Write-Host "$($script:Fehler) Beanstandungen" -ForegroundColor Red; exit 1 }
