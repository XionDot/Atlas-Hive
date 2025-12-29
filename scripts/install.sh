#!/bin/bash

echo "Installing Atlas to /Applications..."

# Kill any running Atlas processes first
echo "Killing any running Atlas processes..."
killall -9 Atlas 2>/dev/null || true

# Remove old version if exists
if [ -d "/Applications/Atlas.app" ]; then
    echo "Removing old version..."
    rm -rf "/Applications/Atlas.app"
fi

# Also remove old PeakView version if it exists
if [ -d "/Applications/PeakView.app" ]; then
    echo "Removing old PeakView version..."
    rm -rf "/Applications/PeakView.app"
fi

# Also remove old Desktopie version if it exists
if [ -d "/Applications/Desktopie.app" ]; then
    echo "Removing old Desktopie version..."
    rm -rf "/Applications/Desktopie.app"
fi

# Copy new version
cp -r ./build/Atlas.app /Applications/

# Remove quarantine attribute to avoid Gatekeeper issues
echo "Removing quarantine attribute..."
xattr -cr /Applications/Atlas.app

echo ""
echo "✅ Atlas installed successfully!"
echo ""
echo "To launch: open /Applications/Atlas.app"
echo "The app will appear in your menu bar."
