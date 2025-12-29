#!/bin/bash

# Create DMG for Atlas distribution
# Creates a drag-and-drop installer DMG

set -e

VERSION="1.0.0"
APP_NAME="Atlas"
BUILD_DIR="./build"
RELEASE_DIR="./releases"
APP_PATH="$BUILD_DIR/$APP_NAME.app"
DMG_NAME="$APP_NAME-$VERSION.dmg"
VOLUME_NAME="$APP_NAME"

echo "📦 Creating DMG for $APP_NAME v$VERSION..."

# Build the app first if needed
if [ ! -d "$APP_PATH" ]; then
    echo "🔨 Building app first..."
    ./scripts/build_app.sh
fi

# Verify app exists
if [ ! -d "$APP_PATH" ]; then
    echo "❌ App not found at $APP_PATH"
    exit 1
fi

# Create releases directory
mkdir -p "$RELEASE_DIR"

# Remove old DMG if exists
rm -f "$RELEASE_DIR/$DMG_NAME"

# Create temporary directory for DMG contents
STAGING_DIR=$(mktemp -d)
echo "📁 Staging directory: $STAGING_DIR"

# Copy app to staging
cp -R "$APP_PATH" "$STAGING_DIR/"

# Create Applications symlink for drag-and-drop install
ln -s /Applications "$STAGING_DIR/Applications"

# Create the DMG
echo "💿 Creating DMG..."
hdiutil create -volname "$VOLUME_NAME" \
    -srcfolder "$STAGING_DIR" \
    -ov \
    -format UDZO \
    "$RELEASE_DIR/$DMG_NAME"

# Clean up
rm -rf "$STAGING_DIR"

# Calculate size
SIZE=$(du -h "$RELEASE_DIR/$DMG_NAME" | cut -f1)

echo ""
echo "✅ DMG created successfully!"
echo ""
echo "   File: $RELEASE_DIR/$DMG_NAME"
echo "   Size: $SIZE"
echo ""
echo "📤 To share with your friend:"
echo "   1. Send: $RELEASE_DIR/$DMG_NAME"
echo "   2. They double-click to mount"
echo "   3. Drag Atlas to Applications"
echo ""
echo "⚠️  Note: Your friend may need to right-click → Open"
echo "   on first launch (macOS Gatekeeper)"
