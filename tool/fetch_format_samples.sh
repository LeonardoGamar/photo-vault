#!/usr/bin/env bash
#
# Lädt echte Kameradateien für test/werkzeuge_echt_test.dart nach
# test/fixtures/samples/.
#
# Warum nicht im Repository: RAW-Dateien sind 10–50 MB je Stück. Zwei
# davon in der Historie wären mehr als der gesamte übrige Quelltext, und
# gelöscht bekommt man sie danach nicht mehr. Fehlen sie, überspringt der
# Test die betroffene Gruppe, statt zu scheitern.
#
# Die Dateien stammen von raw.pixls.us und stehen unter CC0
# (Public Domain). Jede wird gegen eine Prüfsumme geprüft: Eine
# Testvorlage, die sich unbemerkt ändert, verwandelt einen echten Fund in
# einen scheinbaren Testfehler – oder umgekehrt.
#
# Aufruf:  tool/fetch_format_samples.sh
set -uo pipefail

ROT=$'\033[31m'; GRUEN=$'\033[32m'; AUS=$'\033[0m'
WURZEL="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZIEL="$WURZEL/test/fixtures/samples"

# Name | Quelle | SHA-256
PROBEN=(
  "iphone_6s_plus.dng|https://raw.pixls.us/data/Apple/iPhone%206s%20Plus/IMG_0853.DNG|845fee4f09c832af3728778737f5ae9b99124debb821b6e2066b94aed1daa91c"
)

pruefsumme() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | cut -d' ' -f1
  else
    # macOS bringt kein sha256sum mit.
    shasum -a 256 "$1" | cut -d' ' -f1
  fi
}

mkdir -p "$ZIEL"
fehler=0

for eintrag in "${PROBEN[@]}"; do
  IFS='|' read -r name quelle erwartet <<< "$eintrag"
  datei="$ZIEL/$name"

  if [ -f "$datei" ] && [ "$(pruefsumme "$datei")" = "$erwartet" ]; then
    printf '  %s✓%s %s (schon da)\n' "$GRUEN" "$AUS" "$name"
    continue
  fi

  printf '  … %s\n' "$name"
  # Erst neben das Ziel laden, dann umbenennen. Ein abgebrochener Download
  # hinterliesse sonst eine halbe Datei, die beim nächsten Lauf als
  # vorhanden gilt und den Test mit einem unverständlichen Fehler
  # scheitern lässt.
  if ! curl -sSfL --retry 2 -o "$datei.teil" "$quelle"; then
    printf '  %s✗%s %s: Download fehlgeschlagen\n' "$ROT" "$AUS" "$name"
    rm -f "$datei.teil"
    fehler=1
    continue
  fi

  ist="$(pruefsumme "$datei.teil")"
  if [ "$ist" != "$erwartet" ]; then
    printf '  %s✗%s %s: Prüfsumme weicht ab\n' "$ROT" "$AUS" "$name"
    printf '      erwartet %s\n      bekommen %s\n' "$erwartet" "$ist"
    rm -f "$datei.teil"
    fehler=1
    continue
  fi

  mv "$datei.teil" "$datei"
  printf '  %s✓%s %s\n' "$GRUEN" "$AUS" "$name"
done

exit "$fehler"
