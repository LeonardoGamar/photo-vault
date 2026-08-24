# Beschafft die Kommandozeilenwerkzeuge fuer das Windows-Paket.
#
#   tool\windows_werkzeuge.ps1 [-Ziel <Ordner>]
#
# Unter Windows gibt es keine Paketquelle, aus der sich heif-dec oder
# dcraw_emu nachinstallieren liessen. Sie muessen mitgeliefert werden -
# und damit stellt sich dieselbe Frage wie bei den KI-Modellen: Woher, und
# woher weiss man, dass es dasselbe ist? Deshalb feste Adressen und
# Pruefsummen. Ein Werkzeug ohne Pruefsumme im Installationspaket waere
# ein Einfallstor.
#
# libheif kommt nicht als Download, sondern wird gebaut - siehe
# tool\windows_libheif.sh und die Begruendung dort.
[CmdletBinding()]
param([string]$Ziel = "$PSScriptRoot\..\build\windows\werkzeuge")

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'   # sonst kostet die Fortschrittsanzeige mehr Zeit als der Download

# PowerShell 5.1 wertet JEDE Ausgabe eines fremden Programms auf stderr als
# abbrechenden Fehler, sobald ErrorActionPreference auf Stop steht - auch
# eine blosse Warnung wie "Paket ist aktuell, ueberspringe". Der Bau von
# libheif brach daran ab, ohne dass eine Fehlermeldung erschien: Das
# Skript endete mit Rueckgabewert 0 und einem halben Werkzeugordner.
# Fremde Programme laufen deshalb durch diese Huelle.
function Fremd {
  param([string]$Programm, [string[]]$Argumente)
  $alt = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  try {
    & $Programm @Argumente 2>&1 | ForEach-Object { Write-Host "    $_" }
    return $LASTEXITCODE
  } finally { $ErrorActionPreference = $alt }
}

function Titel($t) { Write-Host ""; Write-Host $t; Write-Host ('-' * $t.Length) }
function Gut($t)   { Write-Host "  [ok] $t" -ForegroundColor Green }
function Schlecht($t) { Write-Host "  [!!] $t" -ForegroundColor Red }

$Ziel = [System.IO.Path]::GetFullPath($Ziel)
# Leeren, nicht ergaenzen. Ein Werkzeug aus einem frueheren, halb
# gescheiterten Lauf bliebe sonst liegen und wanderte ins Paket - und
# genau das ist hier einmal passiert.
Remove-Item -Recurse -Force $Ziel -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force $Ziel | Out-Null
$Zwischen = Join-Path $env:TEMP 'pv_werkzeuge'
New-Item -ItemType Directory -Force $Zwischen | Out-Null

# Name, Adresse, SHA-256. Beide Fassungen sind festgenagelt: Bei BtbN sind
# die datierten Marken unveraenderlich, "latest" waere es nicht.
$Quellen = @(
  @{ Name  = 'LibRaw-0.22.2-Win64.zip'
     Adresse = 'https://www.libraw.org/data/LibRaw-0.22.2-Win64.zip'
     Summe = 'AC64FA12BB00A7581332D4C6AB918C0533FB3F119D6B668D47A6875410DCA948' }
  @{ Name  = 'ffmpeg-lgpl-shared.zip'
     Adresse = 'https://github.com/BtbN/FFmpeg-Builds/releases/download/autobuild-2026-08-22-12-58/ffmpeg-n9.0.1-6-g9d4ca21220-win64-lgpl-shared-9.0.zip'
     Summe = 'BEE92BA1D9BE90E7DD9BE6A40FD853297AFD993231D9F3DDF9FDFDBC3012268D' }
)

Titel "Herunterladen"
foreach ($q in $Quellen) {
  $datei = Join-Path $Zwischen $q.Name
  if (-not (Test-Path $datei)) {
    # Erst neben das Ziel laden, dann umbenennen: Ein abgebrochener
    # Download hinterliesse sonst eine halbe Datei, die beim naechsten Lauf
    # als vorhanden gilt.
    Invoke-WebRequest -Uri $q.Adresse -OutFile "$datei.teil"
    Move-Item "$datei.teil" $datei
  }
  $ist = (Get-FileHash $datei -Algorithm SHA256).Hash
  if ([string]::IsNullOrEmpty($q.Summe)) {
    Schlecht "$($q.Name): keine Pruefsumme hinterlegt. Gemessen: $ist"
    Write-Host "       Diesen Wert in tool\windows_werkzeuge.ps1 eintragen."
  } elseif ($ist -ne $q.Summe) {
    Schlecht "$($q.Name): Pruefsumme weicht ab"
    Write-Host "       erwartet $($q.Summe)"
    Write-Host "       bekommen $ist"
    Remove-Item $datei -Force
    exit 1
  } else {
    Gut "$($q.Name)"
  }
}

Titel "Auspacken"
$libraw = Join-Path $Zwischen 'libraw'
$ffmpeg = Join-Path $Zwischen 'ffmpeg'
Remove-Item -Recurse -Force $libraw, $ffmpeg -ErrorAction SilentlyContinue
Expand-Archive (Join-Path $Zwischen 'LibRaw-0.22.2-Win64.zip') $libraw
Expand-Archive (Join-Path $Zwischen 'ffmpeg-lgpl-shared.zip') $ffmpeg

# dcraw_emu braucht genau eine DLL, ffmpeg bringt seine eigenen mit.
Copy-Item (Get-ChildItem $libraw -Recurse -Filter 'dcraw_emu.exe').FullName $Ziel -Force
Copy-Item (Get-ChildItem $libraw -Recurse -Filter 'libraw.dll').FullName $Ziel -Force
Gut "dcraw_emu.exe + libraw.dll"

foreach ($n in 'ffmpeg.exe', 'ffprobe.exe') {
  Copy-Item (Get-ChildItem $ffmpeg -Recurse -Filter $n | Select-Object -First 1).FullName $Ziel -Force
}
Get-ChildItem $ffmpeg -Recurse -Filter '*.dll' | ForEach-Object { Copy-Item $_.FullName $Ziel -Force }
Gut "ffmpeg.exe, ffprobe.exe samt DLLs"

Titel "libheif bauen"
$bash = 'C:\msys64\usr\bin\bash.exe'
if (-not (Test-Path $bash)) {
  Schlecht "MSYS2 fehlt - ohne es laesst sich libheif nicht bauen."
  Write-Host "       winget install --id MSYS2.MSYS2 -e"
  exit 1
}
# MSYS2 haengt die Laufwerke unter /c, /d ... ein - klein geschrieben.
#
# Von Hand und nicht per -replace mit Skriptblock: Das kann erst
# PowerShell 6. Unter 5.1 fiel der Laufwerksbuchstabe still weg, und der
# Bau suchte sein Skript unter /src/... statt /c/src/...
function AlsUnix($p) {
  $p = $p -replace '\\', '/'
  if ($p -match '^([A-Za-z]):(.*)$') { return '/' + $Matches[1].ToLower() + $Matches[2] }
  return $p
}
$sh = AlsUnix (Resolve-Path "$PSScriptRoot\windows_libheif.sh").Path
$zielUnix = AlsUnix $Ziel
$rc = Fremd $bash @('-lc', "bash '$sh' '$zielUnix'")
if ($rc -ne 0) { Schlecht "libheif-Bau fehlgeschlagen (Rueckgabewert $rc)"; exit 1 }
if (-not (Test-Path "$Ziel\heif-dec.exe")) { Schlecht "heif-dec.exe fehlt trotzdem"; exit 1 }
Gut "heif-dec.exe samt Huelle"

Titel "Was jetzt da ist"
$gesamt = (Get-ChildItem $Ziel -File | Measure-Object -Property Length -Sum).Sum
Write-Host ("  {0} Dateien, {1:N0} MB in {2}" -f `
  (Get-ChildItem $Ziel -File).Count, ($gesamt / 1MB), $Ziel)
