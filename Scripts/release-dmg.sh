#!/bin/zsh
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
INFO_PLIST="$ROOT_DIR/Resources/Info.plist"
APP_NAME="Standup"
VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$INFO_PLIST")
DMG_PATH="$ROOT_DIR/build/$APP_NAME-$VERSION.dmg"

: "${SIGNING_IDENTITY:?Set SIGNING_IDENTITY to your Developer ID Application certificate name.}"
: "${NOTARYTOOL_KEYCHAIN_PROFILE:?Set NOTARYTOOL_KEYCHAIN_PROFILE to a configured notarytool profile.}"

"$ROOT_DIR/Scripts/build-dmg.sh"

xcrun notarytool submit "$DMG_PATH" --keychain-profile "$NOTARYTOOL_KEYCHAIN_PROFILE" --wait
xcrun stapler staple "$DMG_PATH"
xcrun stapler validate "$DMG_PATH"

echo "Release DMG notarized and stapled: $DMG_PATH"
