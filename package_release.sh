#!/bin/bash

# Package Desktopie for release
# Creates a distributable .zip file with the app bundle

set -e

VERSION="1.0.0"
APP_NAME="Desktopie"
BUILD_DIR="./build"
RELEASE_DIR="./releases"
APP_PATH="$BUILD_DIR/$APP_NAME.app"
ZIP_NAME="$APP_NAME-$VERSION.zip"

echo "📦 Packaging $APP_NAME v$VERSION for release..."

# Ensure the app is built
if [ ! -d "$APP_PATH" ]; then
    echo "❌ App not found at $APP_PATH"
    echo "Run ./build_app.sh first"
    exit 1
fi

# Create releases directory
mkdir -p "$RELEASE_DIR"

# Create a temporary staging directory
STAGING_DIR=$(mktemp -d)
echo "📁 Staging directory: $STAGING_DIR"

# Copy the app to staging
cp -R "$APP_PATH" "$STAGING_DIR/"

# Create the zip file
cd "$STAGING_DIR"
zip -r -q "$ZIP_NAME" "$APP_NAME.app"
mv "$ZIP_NAME" "$OLDPWD/$RELEASE_DIR/"
cd "$OLDPWD"

# Clean up
rm -rf "$STAGING_DIR"

# Calculate size
SIZE=$(du -h "$RELEASE_DIR/$ZIP_NAME" | cut -f1)

echo ""
echo "✅ Release package created successfully!"
echo ""
echo "   File: $RELEASE_DIR/$ZIP_NAME"
echo "   Size: $SIZE"
echo ""
echo "📤 Next steps:"
echo "   1. Test the release: unzip $RELEASE_DIR/$ZIP_NAME"
echo "   2. Create a GitHub release"
echo "   3. Upload $ZIP_NAME to the release"
echo ""
echo "GitHub Release Template:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "## $APP_NAME v$VERSION"
echo ""
echo "### Features"
echo "- Real-time system monitoring (CPU, Memory, Network, Disk, Battery)"
echo "- Built-in task manager with process control"
echo "- Privacy controls for Camera and Microphone"
echo "- Customizable menu bar display"
echo "- Light/Dark/System theme support"
echo ""
echo "### Installation"
echo "1. Download $ZIP_NAME"
echo "2. Unzip the file"
echo "3. Move $APP_NAME.app to Applications"
echo "4. Launch from Applications or Spotlight"
echo ""
echo "### System Requirements"
echo "- macOS 13.0 (Ventura) or later"
echo "- Apple Silicon or Intel processor"
echo ""
echo "### What's New"
echo "- Initial release"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"