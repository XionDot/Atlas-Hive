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

    // MARK: - Vibrant Colors for Black AF Mode

    /// Check if currently in black af theme
    private static var isBlackAFMode: Bool {
        if let window = NSApp.windows.first(where: { $0.title == "PeakView" }) {
            if window.appearance != nil {
                let appearance = window.effectiveAppearance
                return appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            }
        }
        return false
    }

    /// Vibrant cyan for black af mode, standard cyan otherwise
    static var vibrantCyan: Color {
        isBlackAFMode ? Color(red: 0.0, green: 0.9, blue: 1.0) : .cyan
    }

    /// Vibrant blue for black af mode, standard blue otherwise
    static var vibrantBlue: Color {
        isBlackAFMode ? Color(red: 0.2, green: 0.6, blue: 1.0) : .blue
    }

    /// Vibrant green for black af mode, standard green otherwise
    static var vibrantGreen: Color {
        isBlackAFMode ? Color(red: 0.0, green: 1.0, blue: 0.4) : .green
    }

    /// Vibrant mint for black af mode, standard mint otherwise
    static var vibrantMint: Color {
        isBlackAFMode ? Color(red: 0.3, green: 1.0, blue: 0.8) : .mint
    }

    /// Vibrant orange for black af mode, standard orange otherwise
    static var vibrantOrange: Color {
        isBlackAFMode ? Color(red: 1.0, green: 0.6, blue: 0.0) : .orange
    }

    /// Vibrant red for black af mode, standard red otherwise
    static var vibrantRed: Color {
        isBlackAFMode ? Color(red: 1.0, green: 0.2, blue: 0.3) : .red
    }

    /// Vibrant purple for black af mode, standard purple otherwise
    static var vibrantPurple: Color {
        isBlackAFMode ? Color(red: 0.8, green: 0.3, blue: 1.0) : .purple
    }

    /// Vibrant pink for black af mode, standard pink otherwise
    static var vibrantPink: Color {
        isBlackAFMode ? Color(red: 1.0, green: 0.3, blue: 0.8) : .pink
    }

    /// Vibrant yellow for black af mode, standard yellow otherwise
    static var vibrantYellow: Color {
        isBlackAFMode ? Color(red: 1.0, green: 0.9, blue: 0.0) : .yellow
    }
}
