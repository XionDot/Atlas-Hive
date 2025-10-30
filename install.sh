#!/bin/bash

echo "Installing Desktopie to /Applications..."

# Remove old version if exists
if [ -d "/Applications/Desktopie.app" ]; then
    echo "Removing old version..."
    rm -rf "/Applications/Desktopie.app"
fi

# Copy new version
cp -r ./build/Desktopie.app /Applications/

# Remove quarantine attribute to avoid Gatekeeper issues
echo "Removing quarantine attribute..."
xattr -cr /Applications/Desktopie.app

echo ""
echo "✅ Desktopie installed successfully!"
echo ""
echo "To launch: open /Applications/Desktopie.app"
echo "The app will appear in your menu bar."
