#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MOBILE_DIR="$ROOT_DIR/mobile"
MODE="${1:-verify}"

API_BASE_URL="${ZEROON_API_BASE_URL:-}"
SUPPORT_EMAIL="${ZEROON_SUPPORT_EMAIL:-zeroon_ai@outlook.com}"
BUILD_NAME="${ZEROON_BUILD_NAME:-1.0.0}"
BUILD_NUMBER="${ZEROON_BUILD_NUMBER:-1}"

usage() {
  echo "Usage: scripts/zeroon-mobile-build.sh verify|android|android-apk|ios|ios-unsigned|all"
}

require_release_environment() {
  if [[ -z "$API_BASE_URL" ]]; then
    echo "ZEROON_API_BASE_URL is required."
    exit 2
  fi
  if [[ "$API_BASE_URL" != https://* ]]; then
    echo "ZEROON_API_BASE_URL must use HTTPS."
    exit 2
  fi
  if [[ "$API_BASE_URL" != */api/v1 ]]; then
    echo "ZEROON_API_BASE_URL must end with /api/v1."
    exit 2
  fi
  if [[ "$SUPPORT_EMAIL" != *@*.* ]]; then
    echo "ZEROON_SUPPORT_EMAIL must be a valid email address."
    exit 2
  fi
  if [[ ! "$BUILD_NUMBER" =~ ^[1-9][0-9]*$ ]]; then
    echo "ZEROON_BUILD_NUMBER must be a positive integer."
    exit 2
  fi
}

flutter_defines=(
  "--dart-define=ZEROON_API_BASE_URL=$API_BASE_URL"
  "--dart-define=ZEROON_SUPPORT_EMAIL=$SUPPORT_EMAIL"
  "--build-name=$BUILD_NAME"
  "--build-number=$BUILD_NUMBER"
)

verify() {
  (
    cd "$MOBILE_DIR"
    flutter pub get
    flutter analyze
    flutter test
  )
}

build_android() {
  require_release_environment
  if [[ ! -f "$MOBILE_DIR/android/key.properties" ]]; then
    echo "mobile/android/key.properties is required for a signed Android release."
    echo "Copy mobile/android/key.properties.example and provide the upload keystore locally."
    exit 2
  fi
  (
    cd "$MOBILE_DIR"
    flutter build appbundle --release "${flutter_defines[@]}"
    shasum -a 256 build/app/outputs/bundle/release/app-release.aab
  )
}

build_android_apk() {
  require_release_environment
  if [[ ! -f "$MOBILE_DIR/android/key.properties" ]]; then
    echo "mobile/android/key.properties is required for a signed Android release."
    exit 2
  fi
  (
    cd "$MOBILE_DIR"
    flutter build apk --release "${flutter_defines[@]}"
    shasum -a 256 build/app/outputs/flutter-apk/app-release.apk
  )
}

build_ios() {
  require_release_environment
  if [[ -z "${ZEROON_IOS_DEVELOPMENT_TEAM:-}" ]]; then
    echo "ZEROON_IOS_DEVELOPMENT_TEAM is required for a signed iOS archive."
    exit 2
  fi
  (
    cd "$MOBILE_DIR"
    DEVELOPMENT_TEAM="$ZEROON_IOS_DEVELOPMENT_TEAM" \
      flutter build ipa --release --export-method app-store \
      "${flutter_defines[@]}"
    shasum -a 256 build/ios/ipa/*.ipa
  )
}

build_ios_unsigned() {
  require_release_environment
  (
    cd "$MOBILE_DIR"
    flutter build ios --release --no-codesign "${flutter_defines[@]}"
  )
}

case "$MODE" in
  verify)
    verify
    ;;
  android)
    verify
    build_android
    ;;
  android-apk)
    verify
    build_android_apk
    ;;
  ios)
    verify
    build_ios
    ;;
  ios-unsigned)
    verify
    build_ios_unsigned
    ;;
  all)
    verify
    build_android
    build_ios
    ;;
  *)
    usage
    exit 2
    ;;
esac
