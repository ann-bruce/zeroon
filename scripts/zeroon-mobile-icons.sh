#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE="$ROOT_DIR/mobile/assets/zeroon-app-icon.png"
IOS_DIR="$ROOT_DIR/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset"
ANDROID_RES="$ROOT_DIR/mobile/android/app/src/main/res"

if [[ ! -f "$SOURCE" ]]; then
  echo "Missing icon master: $SOURCE"
  exit 2
fi

resize() {
  local size="$1"
  local output="$2"
  sips -z "$size" "$size" "$SOURCE" --out "$output" >/dev/null
}

resize 40 "$IOS_DIR/Icon-App-20x20@2x.png"
resize 60 "$IOS_DIR/Icon-App-20x20@3x.png"
resize 29 "$IOS_DIR/Icon-App-29x29@1x.png"
resize 58 "$IOS_DIR/Icon-App-29x29@2x.png"
resize 87 "$IOS_DIR/Icon-App-29x29@3x.png"
resize 80 "$IOS_DIR/Icon-App-40x40@2x.png"
resize 120 "$IOS_DIR/Icon-App-40x40@3x.png"
resize 120 "$IOS_DIR/Icon-App-60x60@2x.png"
resize 180 "$IOS_DIR/Icon-App-60x60@3x.png"
resize 20 "$IOS_DIR/Icon-App-20x20@1x.png"
resize 40 "$IOS_DIR/Icon-App-20x20@2x.png"
resize 40 "$IOS_DIR/Icon-App-40x40@1x.png"
resize 76 "$IOS_DIR/Icon-App-76x76@1x.png"
resize 152 "$IOS_DIR/Icon-App-76x76@2x.png"
resize 167 "$IOS_DIR/Icon-App-83.5x83.5@2x.png"
resize 1024 "$IOS_DIR/Icon-App-1024x1024@1x.png"

resize 48 "$ANDROID_RES/mipmap-mdpi/ic_launcher.png"
resize 72 "$ANDROID_RES/mipmap-hdpi/ic_launcher.png"
resize 96 "$ANDROID_RES/mipmap-xhdpi/ic_launcher.png"
resize 144 "$ANDROID_RES/mipmap-xxhdpi/ic_launcher.png"
resize 192 "$ANDROID_RES/mipmap-xxxhdpi/ic_launcher.png"

echo "ZEROON mobile icons generated from $SOURCE"
