#!/usr/bin/env bash
#
# Prüft eine Linux-Maschine auf alles, was Photo Vault zum Bauen und Laufen
# braucht – und nennt für jedes fehlende Stück den Installationsbefehl.
#
# Aufruf:  tool/linux_setup_check.sh
# Ergebnis: Exit-Code 0, wenn alles zum BAUEN vorhanden ist. Fehlende
#           Laufzeit-Werkzeuge senken den Funktionsumfang, verhindern den
#           Build aber nicht.
#
set -uo pipefail

ROT=$'\033[31m'; GRUEN=$'\033[32m'; GELB=$'\033[33m'; AUS=$'\033[0m'
fehlt_build=0
fehlt_laufzeit=0

titel() { printf '\n%s\n' "$1"; printf '%.0s─' $(seq 1 ${#1}); printf '\n'; }

pruefe() { # name  befehl  paket  kategorie(build|laufzeit)  zweck
  local name="$1" befehl="$2" paket="$3" kategorie="$4" zweck="$5"
  if command -v "$befehl" >/dev/null 2>&1; then
    printf '  %s✓%s %-16s %s\n' "$GRUEN" "$AUS" "$name" "$zweck"
  else
    if [ "$kategorie" = build ]; then
      printf '  %s✗%s %-16s %s\n' "$ROT" "$AUS" "$name" "$zweck"
      printf '      → %s\n' "$paket"
      fehlt_build=$((fehlt_build+1))
    else
      printf '  %s!%s %-16s %s\n' "$GELB" "$AUS" "$name" "$zweck"
      printf '      → %s\n' "$paket"
      fehlt_laufzeit=$((fehlt_laufzeit+1))
    fi
  fi
}

pruefe_lib() { # name  pkg-config-name  paket  zweck
  local name="$1" pc="$2" paket="$3" zweck="$4"
  if pkg-config --exists "$pc" 2>/dev/null; then
    printf '  %s✓%s %-16s %s\n' "$GRUEN" "$AUS" "$name" "$zweck"
  else
    printf '  %s✗%s %-16s %s\n' "$ROT" "$AUS" "$name" "$zweck"
    printf '      → %s\n' "$paket"
    fehlt_build=$((fehlt_build+1))
  fi
}

printf 'Photo Vault – Linux-Bereitschaftsprüfung\n'
printf 'System: %s\n' "$(uname -sr)"
[ -f /etc/os-release ] && printf 'Distribution: %s\n' "$(. /etc/os-release; echo "$PRETTY_NAME")"

titel 'Zum Bauen nötig'
pruefe 'Flutter SDK'  flutter     'https://docs.flutter.dev/get-started/install/linux' build 'Compiler und Werkzeuge'
pruefe 'clang'        clang       'sudo apt install clang'                            build 'C++-Compiler für den Linux-Build'
pruefe 'cmake'        cmake       'sudo apt install cmake'                            build 'Build-System'
pruefe 'ninja'        ninja       'sudo apt install ninja-build'                      build 'Build-System'
pruefe 'pkg-config'   pkg-config  'sudo apt install pkg-config'                       build 'Bibliothekssuche'
pruefe_lib 'GTK 3'    gtk+-3.0    'sudo apt install libgtk-3-dev'                            'Fensterrahmen der App'

titel 'Zur Laufzeit – ohne diese fehlen einzelne Funktionen'
pruefe 'mpv-Bibliothek' mpv       'sudo apt install libmpv-dev mpv'                laufzeit 'Videowiedergabe (media_kit)'
pruefe 'ffmpeg'       ffmpeg      'sudo apt install ffmpeg'                        laufzeit 'Video-Vorschaubild und -Zuschnitt'
pruefe 'ffprobe'      ffprobe     'sudo apt install ffmpeg'                        laufzeit 'Videolänge ermitteln'
pruefe 'heif-convert' heif-convert 'sudo apt install libheif-examples'             laufzeit 'HEIC/HEIF-Fotos (iPhone)'
pruefe 'dcraw_emu'    dcraw_emu   'sudo apt install libraw-bin'                    laufzeit 'RAW-Fotos'

titel 'Noch nicht umgesetzt'
printf '  Entwickeln (Regler wirken noch nicht auf das gespeicherte Bild)\n'
printf '  Texterkennung (OCR)\n'
printf '  Siehe docs/plan_linux.md, Phasen 2, 3 und 5.\n'

titel 'Ergebnis'
if [ "$fehlt_build" -gt 0 ]; then
  printf '  %s%d Bau-Voraussetzung(en) fehlen%s – bitte oben genannte Pakete installieren.\n' "$ROT" "$fehlt_build" "$AUS"
else
  printf '  %sBauen möglich.%s Nächster Schritt:\n' "$GRUEN" "$AUS"
  printf '      flutter pub get && dart run build_runner build --delete-conflicting-outputs\n'
  printf '      flutter build linux    # oder: flutter run -d linux\n'
fi
if [ "$fehlt_laufzeit" -gt 0 ]; then
  printf '  %s%d Laufzeit-Werkzeug(e) fehlen%s – die App startet trotzdem, einzelne Funktionen bleiben aus.\n' "$GELB" "$fehlt_laufzeit" "$AUS"
fi

[ "$fehlt_build" -eq 0 ]
