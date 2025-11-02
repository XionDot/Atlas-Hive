#!/bin/bash

# Create a simple app icon using SF Symbols and sips
# The icon will be a monitoring/chart symbol

ICON_DIR="Resources/AppIcon.appiconset"
SIZES=(16 32 128 256 512 1024)

# Create a base icon using SF Symbols via swift
cat > /tmp/create_icon.swift << 'EOF'
import AppKit
import Foundation

let size: CGFloat = 1024
let image = NSImage(size: NSSize(width: size, height: size))

image.lockFocus()

// Black background with subtle gradient for depth
let gradient = NSGradient(colors: [
    NSColor(white: 0.15, alpha: 1.0),
    NSColor(white: 0.08, alpha: 1.0)
])
gradient?.draw(in: NSRect(x: 0, y: 0, width: size, height: size), angle: 135)

// Add smooth rounded corners (macOS Big Sur style)
let cornerRadius = size * 0.225
let path = NSBezierPath(roundedRect: NSRect(x: 0, y: 0, width: size, height: size),
                        xRadius: cornerRadius, yRadius: cornerRadius)
path.addClip()

// Draw chart/monitoring icon
let iconSize = size * 0.55
let iconX = (size - iconSize) / 2
let iconY = (size - iconSize) / 2 + size * 0.02

// Draw bars representing activity monitoring with subtle glow
NSColor.white.setFill()

// Add subtle shadow for depth
let shadow = NSShadow()
shadow.shadowColor = NSColor(white: 1.0, alpha: 0.3)
shadow.shadowBlurRadius = size * 0.015
shadow.shadowOffset = NSSize(width: 0, height: size * 0.005)
shadow.set()

let barWidth = iconSize / 6
let spacing = iconSize / 12

// CPU bar
let bar1Height = iconSize * 0.7
let bar1 = NSBezierPath(roundedRect: NSRect(x: iconX, y: iconY, width: barWidth, height: bar1Height),
                        xRadius: barWidth / 4, yRadius: barWidth / 4)
bar1.fill()

// Memory bar
let bar2Height = iconSize * 0.9
let bar2 = NSBezierPath(roundedRect: NSRect(x: iconX + barWidth + spacing, y: iconY, width: barWidth, height: bar2Height),
                        xRadius: barWidth / 4, yRadius: barWidth / 4)
bar2.fill()

// Network bar
let bar3Height = iconSize * 0.5
let bar3 = NSBezierPath(roundedRect: NSRect(x: iconX + (barWidth + spacing) * 2, y: iconY, width: barWidth, height: bar3Height),
                        xRadius: barWidth / 4, yRadius: barWidth / 4)
bar3.fill()

// Disk bar
let bar4Height = iconSize * 0.8
let bar4 = NSBezierPath(roundedRect: NSRect(x: iconX + (barWidth + spacing) * 3, y: iconY, width: barWidth, height: bar4Height),
                        xRadius: barWidth / 4, yRadius: barWidth / 4)
bar4.fill()

image.unlockFocus()

// Save
if let tiffData = image.tiffRepresentation,
   let bitmap = NSBitmapImageRep(data: tiffData),
   let pngData = bitmap.representation(using: .png, properties: [:]) {
    try? pngData.write(to: URL(fileURLWithPath: "/tmp/desktopie_icon.png"))
}
EOF

# Compile and run
swiftc -o /tmp/create_icon /tmp/create_icon.swift -framework AppKit
/tmp/create_icon

# Generate all sizes
for size in "${SIZES[@]}"; do
    sips -z $size $size /tmp/desktopie_icon.png --out "$ICON_DIR/icon_${size}x${size}.png" > /dev/null 2>&1

    # Create @2x versions
    if [ $size -le 512 ]; then
        size2x=$((size * 2))
        sips -z $size2x $size2x /tmp/desktopie_icon.png --out "$ICON_DIR/icon_${size}x${size}@2x.png" > /dev/null 2>&1
    fi
done

echo "✅ App icon generated successfully!"
echo "Icon files created in: $ICON_DIR"

# Cleanup
rm -f /tmp/create_icon.swift /tmp/create_icon /tmp/desktopie_icon.png