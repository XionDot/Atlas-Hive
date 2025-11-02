// BACKUP: Original Menu Bar Icon Implementation
// Date: 2025-11-02
// Location: DesktopieApp.swift (line 278-325)
//
// This is the circular gauge/activity monitor style icon
// Restore this function to DesktopieApp.swift if needed

func createDefaultMenuBarIcon() -> NSImage {
    let size: CGFloat = 18
    let image = NSImage(size: NSSize(width: size, height: size))

    image.lockFocus()

    // Clear background
    NSColor.clear.setFill()
    NSBezierPath(rect: NSRect(x: 0, y: 0, width: size, height: size)).fill()

    // Draw a circular gauge/activity monitor style icon
    let centerX = size / 2
    let centerY = size / 2
    let radius: CGFloat = 7

    // Draw outer circle
    let outerCircle = NSBezierPath()
    outerCircle.appendArc(
        withCenter: NSPoint(x: centerX, y: centerY),
        radius: radius,
        startAngle: 0,
        endAngle: 360
    )
    NSColor.labelColor.withAlphaComponent(0.6).setStroke()
    outerCircle.lineWidth = 1.5
    outerCircle.stroke()

    // Draw inner activity bars (like a simplified activity monitor)
    let barCount = 4
    let barSpacing: CGFloat = 1.5
    let barWidth: CGFloat = 1.2
    let barHeights: [CGFloat] = [4, 6, 5, 3] // Varying heights for visual interest

    for i in 0..<barCount {
        let x = centerX - (CGFloat(barCount) * (barWidth + barSpacing)) / 2 + CGFloat(i) * (barWidth + barSpacing) + barSpacing
        let height = barHeights[i]
        let y = centerY - height / 2

        let barRect = NSRect(x: x, y: y, width: barWidth, height: height)
        NSColor.labelColor.withAlphaComponent(0.7).setFill()
        NSBezierPath(rect: barRect).fill()
    }

    image.unlockFocus()

    image.isTemplate = true  // Use template mode for proper light/dark mode support
    return image
}

/* DESIGN NOTES:
 * - 18x18 pixel size optimal for menu bar
 * - Circular gauge with outer ring (radius 7px)
 * - Four vertical bars inside (heights: 4, 6, 5, 3 pixels)
 * - Uses NSColor.labelColor for automatic light/dark mode
 * - Template rendering mode (isTemplate = true)
 * - 60% opacity circle, 70% opacity bars for subtlety
 */