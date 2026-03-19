#!/bin/zsh
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
APP_NAME="Standup"
APP_BUNDLE="$ROOT_DIR/build/$APP_NAME.app"
STAGING_DIR="$ROOT_DIR/build/dmg-staging"
INFO_PLIST="$ROOT_DIR/Resources/Info.plist"
SIGNING_IDENTITY=${SIGNING_IDENTITY:-}

VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$INFO_PLIST")
DMG_NAME="$APP_NAME-$VERSION.dmg"
DMG_PATH="$ROOT_DIR/build/$DMG_NAME"
VOLUME_NAME="$APP_NAME"

"$ROOT_DIR/Scripts/build-app.sh"

rm -rf "$STAGING_DIR" "$DMG_PATH"
mkdir -p "$STAGING_DIR"

cp -R "$APP_BUNDLE" "$STAGING_DIR/"
ln -s /Applications "$STAGING_DIR/Applications"

hdiutil create \
  -volname "$VOLUME_NAME" \
  -srcfolder "$STAGING_DIR" \
  -ov \
  -format UDZO \
  "$DMG_PATH" >/dev/null

if [[ -z "$SIGNING_IDENTITY" ]]; then
    echo "Warning: DMG contains an ad-hoc signed app. Use Scripts/release-dmg.sh for a distributable build." >&2
fi

echo "Built DMG: $DMG_PATH"
