#!/bin/bash

echo "Installing PeakView to /Applications..."

# Kill any running PeakView processes first
echo "Killing any running PeakView processes..."
killall -9 PeakView 2>/dev/null || true

# Remove old version if exists
if [ -d "/Applications/PeakView.app" ]; then
    echo "Removing old version..."
    rm -rf "/Applications/PeakView.app"
fi

# Also remove old Desktopie version if it exists
if [ -d "/Applications/Desktopie.app" ]; then
    echo "Removing old Desktopie version..."
    rm -rf "/Applications/Desktopie.app"
fi

# Copy new version
cp -r ./build/PeakView.app /Applications/

# Remove quarantine attribute to avoid Gatekeeper issues
echo "Removing quarantine attribute..."
xattr -cr /Applications/PeakView.app

echo ""
echo "✅ PeakView installed successfully!"
echo ""
echo "To launch: open /Applications/PeakView.app"
echo "The app will appear in your menu bar."
