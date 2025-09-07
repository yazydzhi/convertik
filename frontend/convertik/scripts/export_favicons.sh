#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
APPICON_DIR="$ROOT_DIR/frontend/ios/Convertik/Resources/Assets.xcassets/AppIcon.appiconset"
OUT_DIR="$ROOT_DIR/landing/assets/img"

mkdir -p "$OUT_DIR"

# Apple touch icon (180x180) — copy directly
if [[ -f "$APPICON_DIR/icon_180x180.png" ]]; then
  cp "$APPICON_DIR/icon_180x180.png" "$OUT_DIR/apple-touch-icon.png"
  echo "apple-touch-icon.png exported"
else
  echo "WARN: icon_180x180.png not found in $APPICON_DIR"
fi

# Favicon 32x32 — generate via sips if available, else fallback to 60x60
SRC_FAV="$APPICON_DIR/icon_60x60.png"
if [[ -x "/usr/bin/sips" && -f "$SRC_FAV" ]]; then
  /usr/bin/sips -z 32 32 "$SRC_FAV" --out "$OUT_DIR/favicon.png" >/dev/null
  echo "favicon.png (32x32) generated from icon_60x60.png"
elif [[ -f "$SRC_FAV" ]]; then
  cp "$SRC_FAV" "$OUT_DIR/favicon.png"
  echo "favicon.png copied from icon_60x60.png (no resize)"
else
  echo "WARN: icon_60x60.png not found in $APPICON_DIR"
fi

echo "Done. Output: $OUT_DIR"


