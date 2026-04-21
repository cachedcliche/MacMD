#!/usr/bin/env bash
# Build the Release configuration and package MacMD.app into dist/ as:
#   - a signature-preserving .zip (via ditto)
#   - a drag-to-Applications .dmg (via hdiutil)
# Each artifact gets a matching .sha256.
#
# Usage: Scripts/package.sh [version]
set -euo pipefail

cd "$(dirname "$0")/.."

VERSION="${1:-1.0.0}"
DIST="dist"
APP_NAME="MacMD.app"
ZIP_NAME="MacMD-${VERSION}.zip"
DMG_NAME="MacMD-${VERSION}.dmg"

echo "Building Release configuration..."
xcodebuild \
    -project MacMD.xcodeproj \
    -scheme MacMD \
    -configuration Release \
    -destination 'platform=macOS' \
    -quiet \
    clean build

BUILT_APP=$(find "$HOME/Library/Developer/Xcode/DerivedData" \
    -type d -name "$APP_NAME" -path "*MacMD*/Build/Products/Release/*" 2>/dev/null | head -n 1)

if [[ -z "$BUILT_APP" ]]; then
    echo "ERROR: could not locate built $APP_NAME" >&2
    exit 1
fi

mkdir -p "$DIST"
rm -f "$DIST/$ZIP_NAME" "$DIST/$ZIP_NAME.sha256" \
      "$DIST/$DMG_NAME" "$DIST/$DMG_NAME.sha256"

echo "Packaging -> $DIST/$ZIP_NAME"
ditto -c -k --sequesterRsrc --keepParent "$BUILT_APP" "$DIST/$ZIP_NAME"
shasum -a 256 "$DIST/$ZIP_NAME" | awk '{print $1}' > "$DIST/$ZIP_NAME.sha256"

echo "Packaging -> $DIST/$DMG_NAME"
STAGE=$(mktemp -d /tmp/macmd-dmg.XXXXXX)
cp -R "$BUILT_APP" "$STAGE/"
ln -s /Applications "$STAGE/Applications"
hdiutil create \
    -volname "MacMD ${VERSION}" \
    -srcfolder "$STAGE" \
    -ov \
    -format UDZO \
    -fs HFS+ \
    -quiet \
    "$DIST/$DMG_NAME"
rm -rf "$STAGE"
shasum -a 256 "$DIST/$DMG_NAME" | awk '{print $1}' > "$DIST/$DMG_NAME.sha256"

echo
echo "Release artifacts in $DIST/:"
ls -lh "$DIST/"
echo
echo "zip sha256: $(cat "$DIST/$ZIP_NAME.sha256")"
echo "dmg sha256: $(cat "$DIST/$DMG_NAME.sha256")"
