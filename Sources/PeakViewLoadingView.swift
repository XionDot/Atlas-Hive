import SwiftUI
import AppKit

struct PeakViewLoadingView: View {
    @State private var progress: Double = 0.0
    @State private var currentMessageIndex: Int = 0
    @State private var isComplete: Bool = false
    @Binding var isShowing: Bool
    let appTheme: String  // Pass the app's theme: "system", "light", or "dark"
    @Environment(\.colorScheme) var colorScheme

    let loadingMessages = [
        "INITIALIZING SYSTEM...",
        "LOADING CORE MODULES...",
        "ESTABLISHING CONNECTIONS...",
        "ANALYZING SYSTEM STATE...",
        "CALIBRATING SENSORS...",
        "READY"
    ]

    // Check app theme (not system appearance)
    private var isDarkMode: Bool {
        switch appTheme {
        case "light":
            return false
        case "dark":
            return true
        default: // "system"
            return NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        }
    }

    private var backgroundColor: Color {
        isDarkMode ? .black : .white
    }

    private var primaryTextColor: Color {
        isDarkMode ? .white : .black
    }

    private var secondaryTextColor: Color {
        isDarkMode ? Color.red.opacity(0.8) : Color.blue.opacity(0.8)
    }

    private var progressBarBackground: Color {
        isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.1)
    }

    private var progressGradient: [Color] {
        isDarkMode ? [.red, .orange] : [.blue, .cyan]
    }

    var body: some View {
        ZStack {
            // Adaptive background
            backgroundColor.ignoresSafeArea()

            VStack(spacing: 60) {
                Spacer()

                // PeakView branding
                VStack(spacing: 12) {
                    Text("PEAKVIEW")
                        .font(.system(size: 64, weight: .black, design: .monospaced))
                        .foregroundColor(primaryTextColor)
                        .tracking(12)

                    Text("SYSTEM MONITOR")
                        .font(.system(size: 18, weight: .medium, design: .monospaced))
                        .foregroundColor(secondaryTextColor)
                        .tracking(6)
                }

                Spacer()

                // Loading message
                Text(loadingMessages[currentMessageIndex])
                    .font(.system(size: 16, weight: .semibold, design: .monospaced))
                    .foregroundColor(primaryTextColor.opacity(0.9))
                    .tracking(3)
                    .frame(height: 24)
                    .transition(.opacity)
                    .id(currentMessageIndex) // Force view update on message change

                // Progress bar
                VStack(spacing: 16) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background
                            Rectangle()
                                .fill(progressBarBackground)
                                .frame(height: 4)

                            // Progress fill with adaptive gradient
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: progressGradient,
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * progress, height: 4)
                                .animation(.linear(duration: 0.3), value: progress)

                            // Glow effect
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: progressGradient.map { $0.opacity(0.8) },
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * progress, height: 4)
                                .blur(radius: 6)
                                .animation(.linear(duration: 0.3), value: progress)
                        }
                    }
                    .frame(width: 700, height: 4)

                    // Progress percentage
                    Text(String(format: "%.0f%%", progress * 100))
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(secondaryTextColor)
                        .tracking(3)
                }

                Spacer()

                // Version info
                VStack(spacing: 6) {
                    Text("PEAKVIEW v2.0")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(primaryTextColor.opacity(0.4))
                        .tracking(2)

                    Text("ADVANCED SYSTEM MONITORING")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(secondaryTextColor.opacity(0.5))
                        .tracking(1)
                }
                .padding(.bottom, 50)
            }
            .padding()
        }
        .onAppear {
            startLoading()
        }
    }

    private func startLoading() {
        // Animate progress and messages
        let totalDuration: Double = 3.0 // Total loading time in seconds
        let messageInterval = totalDuration / Double(loadingMessages.count - 1)

        // Animate progress bar smoothly
        withAnimation(.linear(duration: totalDuration)) {
            progress = 1.0
        }

        // Update messages sequentially
        for (index, _) in loadingMessages.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + messageInterval * Double(index)) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentMessageIndex = index
                }

                // On last message, wait a bit then dismiss
                if index == loadingMessages.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        withAnimation(.easeOut(duration: 0.5)) {
                            isComplete = true
                            isShowing = false
                        }
                    }
                }
            }
        }
    }
}
