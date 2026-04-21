#!/usr/bin/env bash
# Build the Release configuration and package MacMD.app into dist/ as a
# signed-app-friendly zip plus a sha256 checksum.
#
# Usage: Scripts/package.sh [version]
#   Default version: the MARKETING_VERSION in the Xcode project (currently 1.0).
set -euo pipefail

cd "$(dirname "$0")/.."

VERSION="${1:-1.0.0}"
DIST="dist"
APP_NAME="MacMD.app"
ZIP_NAME="MacMD-${VERSION}.zip"

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
rm -f "$DIST/$ZIP_NAME" "$DIST/$ZIP_NAME.sha256"

echo "Packaging $BUILT_APP -> $DIST/$ZIP_NAME"
ditto -c -k --sequesterRsrc --keepParent "$BUILT_APP" "$DIST/$ZIP_NAME"

echo "Computing sha256..."
shasum -a 256 "$DIST/$ZIP_NAME" | awk '{print $1}' > "$DIST/$ZIP_NAME.sha256"

echo
echo "Release artifacts in $DIST/:"
ls -lh "$DIST/"
echo
echo "sha256: $(cat "$DIST/$ZIP_NAME.sha256")"
