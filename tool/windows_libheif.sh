#!/bin/bash
#
# Baut libheif für Windows – nur mit Dekodern.
#
# Aufruf aus einer MSYS2-Shell:  bash tool/windows_libheif.sh <Zielordner>
#
# Warum selbst bauen statt das fertige MSYS2-Paket zu nehmen: Dessen
# heif-dec.exe zieht 63 MB DLLs nach sich, davon 22 MB libx265 und weitere
# 17 MB an AV1-Encodern (aom, rav1e, SVT-AV1). Zum *Lesen* von
# iPhone-Fotos braucht es davon nichts. Mit abgeschalteten Encodern sind
# es 16 MB – dieselbe Überlegung, die im Flatpak-Bauplan steht, wo aus
# demselben Grund dav1d statt aom genommen wurde.
#
# Nebenbei liefert der eigene Bau `heif-convert.exe` als Kopie mit; das
# MSYS2-Paket tut das nicht, weshalb dort nur `heif-dec.exe` liegt.
#
# Weder set -e noch set -u vor dem Profil: MSYS2s /etc/profile greift auf
# nicht gesetzte Variablen zu, und unter set -u beendet sich die Shell
# dabei sofort – ohne Meldung und ohne Protokoll.
export MSYSTEM=MINGW64
source /etc/profile
set -e

FASSUNG="v1.23.1"
ZIEL="${1:?Zielordner angeben}"
ARBEIT="$(mktemp -d)"
trap 'rm -rf "$ARBEIT"' EXIT

echo "== Bauwerkzeuge und Dekoder-Bibliotheken =="
pacman -S --noconfirm --needed \
  mingw-w64-x86_64-gcc mingw-w64-x86_64-cmake mingw-w64-x86_64-ninja \
  mingw-w64-x86_64-libde265 mingw-w64-x86_64-dav1d \
  mingw-w64-x86_64-libjpeg-turbo mingw-w64-x86_64-libpng git

echo "== libheif $FASSUNG holen =="
git clone --depth 1 --branch "$FASSUNG" \
  https://github.com/strukturag/libheif.git "$ARBEIT/quelle"

echo "== Übersetzen (Encoder aus) =="
cmake -G Ninja -S "$ARBEIT/quelle" -B "$ARBEIT/bau" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$ARBEIT/fertig" \
  -DBUILD_SHARED_LIBS=ON \
  -DWITH_EXAMPLES=ON \
  -DWITH_LIBDE265=ON -DWITH_DAV1D=ON \
  -DWITH_X265=OFF -DWITH_AOM_ENCODER=OFF -DWITH_AOM_DECODER=OFF \
  -DWITH_RAV1E=OFF -DWITH_SvtEnc=OFF -DWITH_KVAZAAR=OFF \
  -DWITH_OpenH264_DECODER=OFF -DWITH_OpenH264_ENCODER=OFF \
  -DWITH_FFMPEG_DECODER=OFF -DWITH_UNCOMPRESSED_CODEC=OFF \
  -DWITH_JPEG_DECODER=ON -DWITH_JPEG_ENCODER=ON \
  -DWITH_OpenJPEG_DECODER=OFF -DWITH_OpenJPEG_ENCODER=OFF \
  -DWITH_OPENJPH_ENCODER=OFF -DWITH_OPENJPH_DECODER=OFF \
  -DENABLE_PLUGIN_LOADING=OFF -DBUILD_TESTING=OFF
cmake --build "$ARBEIT/bau" --parallel
cmake --install "$ARBEIT/bau"

echo "== Einsammeln nach $ZIEL =="
mkdir -p "$ZIEL"
cp "$ARBEIT/fertig/bin/heif-dec.exe" "$ZIEL/"

# Die DLL-Hülle ausrechnen statt aufzuzählen. Eine Liste von Hand veraltet
# beim ersten Fassungswechsel, und was fehlt, merkt man erst auf einem
# fremden Rechner – dort startet das Programm dann gar nicht.
cd "$ARBEIT/fertig/bin"
ldd heif-dec.exe | grep -iE '/mingw64/|/fertig/' | sed 's/.*=> //; s/ (0x.*//' |
  sort -u | while read -r dll; do cp "$dll" "$ZIEL/"; done

echo "== Ergebnis =="
du -sh "$ZIEL"
ls "$ZIEL" | wc -l | xargs printf '%s Dateien\n'
