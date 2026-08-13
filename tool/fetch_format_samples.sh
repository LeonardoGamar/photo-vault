#!/usr/bin/env bash
#
# Lädt echte Kameradateien (RAW/HEIC) aus öffentlichen Quellen herunter, um
# die Formatunterstützung manuell zu prüfen.
#
# Warum ein Skript statt Dateien im Repository:
#   * RAW-/HEIC-Dateien sind groß (10–50 MB pro Stück) und würden die
#     Repository-Historie dauerhaft aufblähen.
#   * Ihre Lizenzen unterscheiden sich je Datei; Herunterladen zum eigenen
#     Testen ist unkritisch, Weiterverbreiten wäre es nicht.
#   * Automatisierte Tests brauchen sie nicht – die decken die Formate ab,
#     die sich synthetisch erzeugen lassen (siehe test/image_format_test.dart).
#
# Das Zielverzeichnis ist bewusst über .gitignore ausgeschlossen.
#
# Verwendung:
#   tool/fetch_format_samples.sh                    # Standardsatz laden
#   tool/fetch_format_samples.sh --list Canon       # Modelle eines Herstellers
#   tool/fetch_format_samples.sh --make Canon --model "EOS R6"
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$REPO_ROOT/test/fixtures/samples"
RAW_BASE="https://raw.pixls.us/data"

# Real geprüfte Direktlinks (Stand: August 2026). Format: URL|Zielname|Lizenz
DEFAULT_SAMPLES=(
  "https://raw.pixls.us/data/Apple/iPhone%206s%20Plus/IMG_0853.DNG|iphone_6s_plus.dng|CC0 (raw.pixls.us)"
  "https://raw.githubusercontent.com/nokiatech/heif_conformance/master/conformance_files/C001.heic|nokia_conformance_C001.heic|unklar – Nokia HEIF-Conformance, keine Lizenzdatei im Repo"
)

usage() {
  sed -n '3,20p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
  exit 0
}

download() {
  local url="$1" name="$2" license="$3"
  local target="$DEST/$name"
  if [[ -f "$target" ]]; then
    echo "  vorhanden: $name"
    return 0
  fi
  echo "  lade: $name"
  if ! curl -fsSL --max-time 300 -o "$target.part" "$url"; then
    echo "  FEHLER: Download fehlgeschlagen ($url)" >&2
    rm -f "$target.part"
    return 1
  fi
  mv "$target.part" "$target"
  printf '%s\t%s\t%s\n' "$name" "$license" "$url" >> "$DEST/HERKUNFT.tsv"
}

list_models() {
  local make="$1"
  echo "Modelle für $make:"
  curl -fsSL --max-time 30 "$RAW_BASE/$make/" \
    | grep -oE 'href="[^"?/][^"]*/"' \
    | sed 's/href="//;s/\/"$//' \
    | sed 's/%20/ /g' \
    | sed 's/^/  /'
}

fetch_by_model() {
  local make="$1" model="$2"
  local encoded_model="${model// /%20}"
  echo "Suche RAW-Datei für $make / $model …"
  local file
  file="$(curl -fsSL --max-time 30 "$RAW_BASE/$make/$encoded_model/" \
    | grep -oiE 'href="[^"?/][^"]*\.(dng|cr2|cr3|nef|arw|raf|orf|rw2|pef|srw)"' \
    | head -1 | sed 's/href="//I;s/"$//')" || true
  if [[ -z "$file" ]]; then
    echo "Keine RAW-Datei gefunden. Verzeichnis prüfen: $RAW_BASE/$make/$encoded_model/" >&2
    exit 1
  fi
  local plain="${file//%20/_}"
  download "$RAW_BASE/$make/$encoded_model/$file" "$plain" "siehe raw.pixls.us (meist CC0)"
}

mkdir -p "$DEST"

case "${1:-}" in
  -h|--help) usage ;;
  --list)
    [[ $# -ge 2 ]] || { echo "Hersteller fehlt: --list Canon" >&2; exit 1; }
    list_models "$2"
    exit 0
    ;;
  --make)
    [[ $# -ge 4 && "$3" == "--model" ]] || { echo "Aufruf: --make Canon --model \"EOS R6\"" >&2; exit 1; }
    fetch_by_model "$2" "$4"
    ;;
  "")
    echo "Lade Standardsatz nach test/fixtures/samples/ …"
    for entry in "${DEFAULT_SAMPLES[@]}"; do
      IFS='|' read -r url name license <<< "$entry"
      download "$url" "$name" "$license"
    done
    ;;
  *)
    echo "Unbekannte Option: $1 (--help für Hilfe)" >&2
    exit 1
    ;;
esac

cat <<'EOF'

Fertig. Die Dateien liegen unter test/fixtures/samples/ und sind über
.gitignore von der Versionierung ausgeschlossen – bitte NICHT committen und
nicht weiterverbreiten; die Lizenzen unterscheiden sich je Datei (siehe
test/fixtures/samples/HERKUNFT.tsv).

Manuelle Prüfung (die native Bildkonvertierung gibt es nur zur Laufzeit,
nicht in `flutter test`):
  1. flutter run -d macos
  2. Import öffnen und die Dateien aus test/fixtures/samples/ importieren
  3. Erwartung: Vorschaubild in der Timeline, Vollbild öffnet, bei RAW ist
     "Entwickeln" verfügbar (siehe README, Abschnitt Bildformat-Unterstützung)
EOF
