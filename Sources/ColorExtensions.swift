import SwiftUI
import AppKit

extension Color {
    /// Pure black background for dark mode, system color for light mode
    static var darkBackground: Color {
        if NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua {
            return Color.black  // Pure black for dark mode
        } else {
            return Color(NSColor.windowBackgroundColor)
        }
    }

    /// Slightly lighter black for card backgrounds in dark mode
    static var darkCard: Color {
        if NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua {
            return Color.black  // Pure black for cards too
        } else {
            return Color(NSColor.controlBackgroundColor)
        }
    }
}
