#!/usr/bin/env bash
#
# Baut Photo Vault als Flatpak.
#
# Aufruf:  tool/flatpak_bauen.sh [--installieren] [--pruefen]
#
#   --installieren  Das fertige Paket für den angemeldeten Benutzer
#                   einspielen (flatpak install --user).
#   --pruefen       Nach dem Bau im Sandkasten nachsehen, ob die
#                   mitgelieferten Werkzeuge wirklich da sind und können,
#                   was sie sollen.
#
# Der Flutter-Bau läuft bewusst VOR flatpak-builder: flatpak-builder
# arbeitet ohne Netzzugang, `flutter build` braucht aber die Pakete aus
# pub.dev. Deshalb entsteht das Bündel zuerst hier draussen, und der
# Bauplan nimmt es nur noch auf.
#
set -uo pipefail

ROT=$'\033[31m'; GRUEN=$'\033[32m'; GELB=$'\033[33m'; AUS=$'\033[0m'

WURZEL="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BAUPLAN="$WURZEL/packaging/flatpak/com.example.PhotoVault.yml"
KENNUNG="com.example.PhotoVault"
LAUFZEIT="org.gnome.Platform"
LAUFZEIT_FASSUNG="49"
BAUORT="$WURZEL/build/flatpak"
LAGER="$WURZEL/build/flatpak-repo"

installieren=0
pruefen=0
for arg in "$@"; do
  case "$arg" in
    --installieren) installieren=1 ;;
    --pruefen) pruefen=1 ;;
    *) printf '%sUnbekannte Angabe: %s%s\n' "$ROT" "$arg" "$AUS"; exit 2 ;;
  esac
done

titel() { printf '\n%s\n' "$1"; printf '%.0s─' $(seq 1 ${#1}); printf '\n'; }
fehler() { printf '  %s✗%s %s\n' "$ROT" "$AUS" "$1"; }
gut()    { printf '  %s✓%s %s\n' "$GRUEN" "$AUS" "$1"; }
hinweis(){ printf '  %s•%s %s\n' "$GELB" "$AUS" "$1"; }

titel "Voraussetzungen"

mangel=0
for befehl in flatpak flatpak-builder flutter; do
  if command -v "$befehl" >/dev/null 2>&1; then
    gut "$befehl"
  else
    fehler "$befehl fehlt"
    mangel=1
  fi
done
if [ "$mangel" -ne 0 ]; then
  printf '\n  Nachzuholen:\n'
  printf '    sudo apt install flatpak flatpak-builder\n'
  printf '    flatpak remote-add --if-not-exists --user flathub \\\n'
  printf '        https://dl.flathub.org/repo/flathub.flatpakrepo\n'
  exit 1
fi

# Laufzeit und SDK. Ohne beide bricht flatpak-builder erst spät ab, mit
# einer Meldung, die nicht sagt, was zu tun ist.
for teil in "$LAUFZEIT" "${LAUFZEIT/Platform/Sdk}"; do
  if flatpak info "$teil//$LAUFZEIT_FASSUNG" >/dev/null 2>&1; then
    gut "$teil//$LAUFZEIT_FASSUNG"
  else
    fehler "$teil//$LAUFZEIT_FASSUNG fehlt"
    printf '    flatpak install --user flathub %s//%s\n' "$teil" "$LAUFZEIT_FASSUNG"
    mangel=1
  fi
done
[ "$mangel" -eq 0 ] || exit 1

titel "Flutter-Bündel bauen"
( cd "$WURZEL" && flutter build linux --release ) || exit 1
BUENDEL="$WURZEL/build/linux/x64/release/bundle"
[ -x "$BUENDEL/photo_vault" ] || { fehler "kein Bündel unter $BUENDEL"; exit 1; }
gut "$(du -sh "$BUENDEL" | cut -f1) unter build/linux/x64/release/bundle"

titel "Flatpak bauen"
# --force-clean, weil ein halber Bauort aus einem abgebrochenen Lauf sonst
# stillschweigend weiterverwendet wird.
flatpak-builder --force-clean --user --repo="$LAGER" \
  --install-deps-from=flathub \
  "$BAUORT" "$BAUPLAN" || exit 1
gut "Paket gebaut"

if [ "$installieren" -eq 1 ]; then
  titel "Einspielen"
  flatpak --user remote-add --if-not-exists --no-gpg-verify photo-vault-lokal "$LAGER" || exit 1
  flatpak --user install -y --reinstall photo-vault-lokal "$KENNUNG" || exit 1
  gut "eingespielt – Start mit: flatpak run $KENNUNG"
fi

if [ "$pruefen" -eq 1 ]; then
  titel "Werkzeuge im Sandkasten"
  im_sandkasten() { flatpak-builder --run "$BAUORT" "$BAUPLAN" "$@" 2>&1; }

  # Nicht auf Vorhandensein prüfen, sondern aufrufen. Im ersten Bau lag
  # unter /app/bin/dcraw_emu das libtool-Hüllskript statt des Programms –
  # `which` war zufrieden, der Aufruf scheiterte.
  laeuft() { # name  befehl...
    local name="$1"; shift
    local aus rc
    aus="$(im_sandkasten "$@")"; rc=$?
    # Der Rückgabewert allein genügt nicht: Manche Werkzeuge melden bei
    # einem Aufruf ohne Argumente ihre Hilfe mit einem Wert ungleich null.
    # Umgekehrt genügt die Ausgabe allein auch nicht. Deshalb beides – und
    # ausdrücklich auch die Meldung von bwrap, wenn die Datei gar nicht da
    # ist. Genau die ging einmal durch, weil sie „No such file" sagt und
    # nicht „not found".
    if printf '%s' "$aus" | grep -qiE "execvp|no such file|nicht gefunden|not found|kommando nicht|command not found|nur lesbar|read-only"; then
      fehler "$name: $(printf '%s' "$aus" | head -1)"
    elif [ -z "$aus" ] && [ "$rc" -ne 0 ]; then
      fehler "$name: keine Ausgabe, Rückgabewert $rc"
    else
      gut "$name läuft"
    fi
  }
  laeuft heif-convert heif-convert --version
  laeuft dcraw_emu dcraw_emu
  laeuft ffmpeg ffmpeg -hide_banner -version
  laeuft ffprobe ffprobe -hide_banner -version
  laeuft zenity zenity --version

  # Das eigentliche Versprechen dieses Pakets: Vorhandensein genügt nicht,
  # libheif muss den Bildinhalt auch auspacken können. Genau daran ist der
  # erste Versuch auf echter Hardware gescheitert.
  if im_sandkasten heif-convert --list-decoders 2>&1 |
      awk '/HEIC decoders:/{gefunden=1; next} /decoders:/{gefunden=0} gefunden && NF' |
      grep -q .; then
    gut "libheif hat einen HEVC-Dekoder"
  else
    fehler "libheif ohne HEVC-Dekoder – HEIC-Fotos blieben unsichtbar"
  fi

  if im_sandkasten ffmpeg -hide_banner -decoders 2>/dev/null | grep -qE '^ V[.A-Z]* +hevc'; then
    gut "ffmpeg kann HEVC lesen"
  else
    fehler "ffmpeg ohne HEVC – Videovorschauen blieben leer"
  fi

  if im_sandkasten sh -c 'ls /app/lib/libmpv.so* >/dev/null 2>&1'; then
    gut "libmpv vorhanden (Videowiedergabe)"
  else
    hinweis "libmpv fehlt – alles ausser der Videowiedergabe funktioniert"
  fi
fi

printf '\n'
