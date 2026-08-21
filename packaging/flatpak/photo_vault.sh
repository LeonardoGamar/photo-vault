#!/bin/sh
# Der Flutter-Bau erwartet seinen data-Ordner neben der ausführbaren Datei,
# deshalb liegt das ganze Bündel unter /app/photo_vault und nicht in
# /app/bin.
exec /app/photo_vault/photo_vault "$@"
