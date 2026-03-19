#!/bin/zsh
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
APP_NAME="Standup"
BUILD_DIR="$ROOT_DIR/build"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
SIGNING_IDENTITY=${SIGNING_IDENTITY:-}

cd "$ROOT_DIR"

swift build -c release

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR"

cp ".build/release/$APP_NAME" "$MACOS_DIR/$APP_NAME"
cp "Resources/Info.plist" "$CONTENTS_DIR/Info.plist"

if command -v codesign >/dev/null 2>&1; then
    if [[ -n "$SIGNING_IDENTITY" ]]; then
        codesign \
          --force \
          --deep \
          --options runtime \
          --timestamp \
          --sign "$SIGNING_IDENTITY" \
          "$APP_DIR" >/dev/null
    else
        codesign --force --deep --sign - "$APP_DIR" >/dev/null
        echo "Warning: built with ad-hoc signing only. Gatekeeper will reject this app on other Macs." >&2
    fi
fi

echo "Built app bundle: $APP_DIR"
