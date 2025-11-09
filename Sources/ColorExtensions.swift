import SwiftUI
import AppKit

extension Color {
    // MARK: - Theme Detection

    /// Check if Samaritan theme is active
    static var isSamaritanMode: Bool {
        // Access ConfigManager to check theme setting
        // We'll use UserDefaults as a bridge since we can't directly access ConfigManager here
        return UserDefaults.standard.string(forKey: "PeakView.theme") == "samaritan"
    }

    /// Check if currently in dark appearance (for Samaritan light/dark variants)
    static var isSystemDark: Bool {
        if let window = NSApp.windows.first(where: { $0.title == "PeakView" }) {
            let appearance = window.effectiveAppearance
            return appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        }
        return NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
    }

    /// Adaptive background based on current theme
    static var darkBackground: Color {
        // Samaritan mode
        if isSamaritanMode {
            return isSystemDark ?
                Color(red: 0, green: 0, blue: 0) :  // Samaritan Dark: Pure black
                Color(red: 0.96, green: 0.95, blue: 0.91)  // Samaritan Light: Cream
        }

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
        // Samaritan mode
        if isSamaritanMode {
            return isSystemDark ?
                Color(red: 0.05, green: 0.05, blue: 0.05) :  // Samaritan Dark: Very dark gray
                Color(red: 0.93, green: 0.91, blue: 0.87)  // Samaritan Light: Darker cream
        }

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

    // MARK: - Samaritan Color Palette

    /// Samaritan primary red - intense, commanding
    static var samaritanRed: Color {
        isSystemDark ?
            Color(red: 1.0, green: 0.27, blue: 0.27) :  // Dark mode: Bright red #FF4545
            Color(red: 0.86, green: 0.21, blue: 0.27)   // Light mode: Deep red #DC3545
    }

    /// Samaritan secondary orange - warning, alert
    static var samaritanOrange: Color {
        isSystemDark ?
            Color(red: 1.0, green: 0.53, blue: 0.27) :  // Dark mode: Bright orange #FF8844
            Color(red: 1.0, green: 0.42, blue: 0.21)    // Light mode: Deep orange #FF6B35
    }

    /// Samaritan amber - caution, moderate status
    static var samaritanAmber: Color {
        isSystemDark ?
            Color(red: 1.0, green: 0.74, blue: 0.27) :  // Dark mode: Bright amber #FFBD45
            Color(red: 0.96, green: 0.63, blue: 0.15)   // Light mode: Deep amber #F5A025
    }

    /// Samaritan text primary - main text color (WHITE in dark, like the screenshot)
    static var samaritanText: Color {
        isSystemDark ?
            Color(red: 0.95, green: 0.95, blue: 0.95) :  // Dark mode: Almost white #F2F2F2
            Color(red: 0.2, green: 0.2, blue: 0.2)       // Light mode: Dark gray
    }

    /// Samaritan text secondary - dimmer text
    static var samaritanTextSecondary: Color {
        isSystemDark ?
            Color(red: 0.6, green: 0.6, blue: 0.6) :    // Dark mode: Gray
            Color(red: 0.4, green: 0.4, blue: 0.4)      // Light mode: Medium gray
    }

    /// Samaritan border - sharp geometric borders
    static var samaritanBorder: Color {
        isSystemDark ?
            Color(red: 1.0, green: 0.27, blue: 0.27).opacity(0.5) :
            Color(red: 0.86, green: 0.21, blue: 0.27).opacity(0.3)
    }

    /// Samaritan green - ok/good status (still red-tinted for Samaritan aesthetic)
    static var samaritanGreen: Color {
        isSystemDark ?
            Color(red: 1.0, green: 0.6, blue: 0.4) :    // Dark mode: Orange-red
            Color(red: 0.8, green: 0.4, blue: 0.2)      // Light mode: Brown-red
    }
}

// MARK: - Font Extensions for Samaritan Mode

extension Font {
    /// Samaritan header font - monospaced, letter-spaced, uppercase style
    static func samaritanHeader(size: CGFloat) -> Font {
        Color.isSamaritanMode ?
            .system(size: size, weight: .bold, design: .monospaced) :
            .system(size: size, weight: .bold)
    }

    /// Samaritan body font - monospaced for terminal aesthetic
    static func samaritanBody(size: CGFloat) -> Font {
        Color.isSamaritanMode ?
            .system(size: size, weight: .medium, design: .monospaced) :
            .system(size: size, weight: .medium)
    }

    /// Samaritan data font - monospaced for numeric displays
    static func samaritanData(size: CGFloat) -> Font {
        Color.isSamaritanMode ?
            .system(size: size, weight: .semibold, design: .monospaced) :
            .system(size: size, weight: .semibold)
    }

    /// Samaritan caption font - smaller monospaced text
    static func samaritanCaption(size: CGFloat) -> Font {
        Color.isSamaritanMode ?
            .system(size: size, weight: .regular, design: .monospaced) :
            .system(size: size, weight: .regular)
    }
}

// MARK: - View Extensions for Samaritan Styling

extension View {
    /// Apply Samaritan letter spacing (terminal aesthetic)
    func samaritanSpacing() -> some View {
        self.tracking(Color.isSamaritanMode ? 1.2 : 0)
    }

    /// Apply Samaritan corner radius (sharp vs rounded)
    func samaritanCorners(_ radius: CGFloat) -> some View {
        self.cornerRadius(Color.isSamaritanMode ? 2 : radius)
    }

    /// Apply Samaritan glow effect (for dark mode only)
    func samaritanGlow(color: Color) -> some View {
        self.shadow(
            color: Color.isSamaritanMode && Color.isSystemDark ? color.opacity(0.6) : .clear,
            radius: Color.isSamaritanMode ? 8 : 0,
            x: 0,
            y: 0
        )
    }

    /// Apply Samaritan grid overlay background
    func samaritanGridOverlay() -> some View {
        self.background(
            Color.isSamaritanMode ? SamaritanGridView() : nil
        )
    }

    /// Apply Samaritan scanline effect
    func samaritanScanlines() -> some View {
        self.overlay(
            Color.isSamaritanMode ? SamaritanScanlinesView() : nil
        )
    }

    /// Apply animated pulsing glow for Samaritan mode
    func samaritanPulseGlow(color: Color) -> some View {
        self.modifier(SamaritanPulseGlowModifier(color: color))
    }
}

// MARK: - Samaritan Pulse Glow Animation
struct SamaritanPulseGlowModifier: ViewModifier {
    let color: Color
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        if Color.isSamaritanMode && Color.isSystemDark {
            content
                .shadow(
                    color: color.opacity(isPulsing ? 0.4 : 0.2),
                    radius: isPulsing ? 12 : 6,
                    x: 0,
                    y: 0
                )
                .onAppear {
                    withAnimation(
                        Animation.easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true)
                    ) {
                        isPulsing = true
                    }
                }
        } else {
            content
        }
    }
}

// MARK: - Samaritan Grid Overlay
struct SamaritanGridView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Vertical lines
                ForEach(0..<Int(geometry.size.width / 40), id: \.self) { i in
                    Rectangle()
                        .fill(Color.samaritanBorder.opacity(0.08))
                        .frame(width: 1)
                        .offset(x: CGFloat(i) * 40)
                }

                // Horizontal lines
                ForEach(0..<Int(geometry.size.height / 40), id: \.self) { i in
                    Rectangle()
                        .fill(Color.samaritanBorder.opacity(0.08))
                        .frame(height: 1)
                        .offset(y: CGFloat(i) * 40)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Samaritan Scanlines Effect
struct SamaritanScanlinesView: View {
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 4) {
                ForEach(0..<Int(geometry.size.height / 4), id: \.self) { _ in
                    Rectangle()
                        .fill(Color.black.opacity(0.05))
                        .frame(height: 2)
                }
            }
        }
        .allowsHitTesting(false)
    }
}
