#!/bin/bash

# Build the Swift package in release mode
echo "Building PeakView in release mode..."
swift build -c release

# Create app bundle structure
echo "Creating app bundle structure..."
APP_NAME="PeakView.app"
APP_DIR="./build/$APP_NAME"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

# Clean previous build
rm -rf "./build"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Copy executable
echo "Copying executable..."
cp .build/release/PeakView "$MACOS_DIR/"

# Copy Info.plist
echo "Copying Info.plist..."
cp Info.plist "$CONTENTS_DIR/"

# Copy app icon
echo "Copying app icon..."
if [ -f "Resources/AppIcon.icns" ]; then
    cp "Resources/AppIcon.icns" "$RESOURCES_DIR/"
    echo "✓ AppIcon.icns copied"
elif [ -d "Resources/AppIcon.appiconset" ]; then
    cp -r Resources/AppIcon.appiconset "$RESOURCES_DIR/"
    # Try to create icns file from appiconset
    if command -v iconutil &> /dev/null; then
        iconutil -c icns "$RESOURCES_DIR/AppIcon.appiconset" -o "$RESOURCES_DIR/AppIcon.icns"
        echo "✓ AppIcon.icns created with iconutil"
    else
        # Fallback: use sips to convert largest PNG
        sips -s format icns "$RESOURCES_DIR/AppIcon.appiconset/icon_512x512.png" --out "$RESOURCES_DIR/AppIcon.icns" 2>/dev/null
        echo "✓ AppIcon.icns created with sips"
    fi
fi

# Sign the app with Developer ID
echo "Signing app with Developer ID..."
codesign --force --sign "Developer ID Application: Ahmed Zitoun (3FPQAZ9VK8)" \
    --timestamp \
    --options runtime \
    --entitlements PeakView.entitlements \
    "$APP_DIR"

# Verify signature
echo "Verifying signature..."
codesign --verify --verbose "$APP_DIR"
spctl --assess --verbose "$APP_DIR"

echo ""
echo "✅ App created successfully at: $APP_DIR"
echo ""
echo "To install, run: cp -r $APP_DIR /Applications/"
