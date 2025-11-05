import SwiftUI
import AppKit

extension Color {
    /// Adaptive background based on current theme
    static var darkBackground: Color {
        // Check app's theme setting
        if let window = NSApp.windows.first(where: { $0.title == "PeakView" }) {
            // Check if appearance is explicitly set (custom theme) or nil (system default)
            if window.appearance == nil {
                // System default - use standard macOS colors
                return Color(NSColor.windowBackgroundColor)
            } else {
                // Custom theme set
                let appearance = window.effectiveAppearance
                if appearance.bestMatch(from: [.darkAqua, .aqua]) == .aqua {
                    // white af theme
                    return Color(NSColor.windowBackgroundColor)
                } else {
                    // black af theme - PURE BLACK #000000
                    return Color(red: 0, green: 0, blue: 0)
                }
            }
        }
        // Fallback
        return Color(NSColor.windowBackgroundColor)
    }

    /// Adaptive card background
    static var darkCard: Color {
        if let window = NSApp.windows.first(where: { $0.title == "PeakView" }) {
            // Check if appearance is explicitly set (custom theme) or nil (system default)
            if window.appearance == nil {
                // System default - use standard macOS colors
                return Color(NSColor.controlBackgroundColor)
            } else {
                // Custom theme set
                let appearance = window.effectiveAppearance
                if appearance.bestMatch(from: [.darkAqua, .aqua]) == .aqua {
                    // white af theme
                    return Color(NSColor.controlBackgroundColor)
                } else {
                    // black af theme - PURE BLACK #000000 (same as background for full black)
                    return Color(red: 0, green: 0, blue: 0)
                }
            }
        }
        // Fallback
        return Color(NSColor.controlBackgroundColor)
    }
}
