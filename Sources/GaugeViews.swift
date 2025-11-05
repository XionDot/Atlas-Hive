import SwiftUI

// MARK: - Temperature Gauge
struct TemperatureGauge: View {
    let temperature: Double // in Celsius
    let maxTemp: Double = 100.0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background arc
                Circle()
                    .trim(from: 0.125, to: 0.875)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8)
                    .rotationEffect(.degrees(135))

                // Temperature arc
                Circle()
                    .trim(from: 0, to: min(temperature / maxTemp, 1.0) * 0.75)
                    .stroke(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8)
                    .rotationEffect(.degrees(135))
                    .animation(.easeInOut(duration: 0.5), value: temperature)

                // Center content
                VStack(spacing: 4) {
                    Image(systemName: "thermometer.medium")
                        .font(.system(size: geometry.size.width * 0.15))
                        .foregroundColor(tempColor)

                    Text("\(Int(temperature))°C")
                        .font(.system(size: geometry.size.width * 0.18, weight: .bold))
                        .foregroundColor(.primary)

                    Text(tempStatus)
                        .font(.system(size: geometry.size.width * 0.1, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var tempColor: Color {
        switch temperature {
        case 0..<50: return .green
        case 50..<70: return .yellow
        case 70..<85: return .orange
        default: return .red
        }
    }

    private var tempStatus: String {
        switch temperature {
        case 0..<50: return "Cool"
        case 50..<70: return "Warm"
        case 70..<85: return "Hot"
        default: return "Critical"
        }
    }

    private var gradientColors: [Color] {
        switch temperature {
        case 0..<50: return [.green, .mint]
        case 50..<70: return [.yellow, .orange]
        case 70..<85: return [.orange, .red]
        default: return [.red, .pink]
        }
    }
}

// MARK: - Fan Speed Gauge
struct FanSpeedGauge: View {
    let rpm: Double
    let maxRPM: Double = 6000.0
    @State private var rotation: Double = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background arc
                Circle()
                    .trim(from: 0.125, to: 0.875)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8)
                    .rotationEffect(.degrees(135))

                // Fan speed arc
                Circle()
                    .trim(from: 0, to: min(rpm / maxRPM, 1.0) * 0.75)
                    .stroke(
                        LinearGradient(
                            colors: [.cyan, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8)
                    .rotationEffect(.degrees(135))
                    .animation(.easeInOut(duration: 0.5), value: rpm)

                // Center content
                VStack(spacing: 4) {
                    Image(systemName: "fan")
                        .font(.system(size: geometry.size.width * 0.15))
                        .foregroundColor(.cyan)
                        .rotationEffect(.degrees(rotation))
                        .onAppear {
                            if rpm > 0 {
                                withAnimation(.linear(duration: max(0.5, 3.0 / max(rpm / 1000.0, 1.0))).repeatForever(autoreverses: false)) {
                                    rotation = 360
                                }
                            }
                        }
                        .onChange(of: rpm) { newRPM in
                            if newRPM > 0 && rotation == 0 {
                                withAnimation(.linear(duration: max(0.5, 3.0 / max(newRPM / 1000.0, 1.0))).repeatForever(autoreverses: false)) {
                                    rotation = 360
                                }
                            } else if newRPM == 0 {
                                rotation = 0
                            }
                        }

                    Text("\(Int(rpm))")
                        .font(.system(size: geometry.size.width * 0.18, weight: .bold))
                        .foregroundColor(.primary)

                    Text("RPM")
                        .font(.system(size: geometry.size.width * 0.1, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - CPU Usage Gauge
struct CPUGauge: View {
    let usage: Double // 0-100

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background arc
                Circle()
                    .trim(from: 0.125, to: 0.875)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8)
                    .rotationEffect(.degrees(135))

                // Usage arc
                Circle()
                    .trim(from: 0, to: min(usage / 100.0, 1.0) * 0.75)
                    .stroke(
                        LinearGradient(
                            colors: gaugeGradient,
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8)
                    .rotationEffect(.degrees(135))
                    .animation(.easeInOut(duration: 0.5), value: usage)

                // Center content
                VStack(spacing: 4) {
                    Image(systemName: "cpu")
                        .font(.system(size: geometry.size.width * 0.15))
                        .foregroundColor(usageColor)

                    Text("\(Int(usage))%")
                        .font(.system(size: geometry.size.width * 0.18, weight: .bold))
                        .foregroundColor(.primary)

                    Text(statusText)
                        .font(.system(size: geometry.size.width * 0.1, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var usageColor: Color {
        switch usage {
        case 0..<40: return .green
        case 40..<70: return .yellow
        case 70..<90: return .orange
        default: return .red
        }
    }

    private var statusText: String {
        switch usage {
        case 0..<40: return "Good"
        case 40..<70: return "Moderate"
        case 70..<90: return "High"
        default: return "Critical"
        }
    }

    private var gaugeGradient: [Color] {
        switch usage {
        case 0..<40: return [.green, .mint]
        case 40..<70: return [.yellow, .orange]
        case 70..<90: return [.orange, .red]
        default: return [.red, .pink]
        }
    }
}

// MARK: - Memory Usage Gauge
struct MemoryGauge: View {
    let usage: Double // 0-100

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background arc
                Circle()
                    .trim(from: 0.125, to: 0.875)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8)
                    .rotationEffect(.degrees(135))

                // Usage arc
                Circle()
                    .trim(from: 0, to: min(usage / 100.0, 1.0) * 0.75)
                    .stroke(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8)
                    .rotationEffect(.degrees(135))
                    .animation(.easeInOut(duration: 0.5), value: usage)

                // Center content
                VStack(spacing: 4) {
                    Image(systemName: "memorychip")
                        .font(.system(size: geometry.size.width * 0.15))
                        .foregroundColor(.green)

                    Text("\(Int(usage))%")
                        .font(.system(size: geometry.size.width * 0.18, weight: .bold))
                        .foregroundColor(.primary)

                    Text("Memory")
                        .font(.system(size: geometry.size.width * 0.1, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Network Speed Gauge
struct NetworkGauge: View {
    let speed: Double // in bytes/second
    let maxSpeed: Double = 10_485_760.0 // 10 MB/s

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background arc
                Circle()
                    .trim(from: 0.125, to: 0.875)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8)
                    .rotationEffect(.degrees(135))

                // Speed arc
                Circle()
                    .trim(from: 0, to: min(speed / maxSpeed, 1.0) * 0.75)
                    .stroke(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8)
                    .rotationEffect(.degrees(135))
                    .animation(.easeInOut(duration: 0.5), value: speed)

                // Center content
                VStack(spacing: 4) {
                    Image(systemName: "network")
                        .font(.system(size: geometry.size.width * 0.15))
                        .foregroundColor(.purple)

                    Text(formattedSpeed)
                        .font(.system(size: geometry.size.width * 0.15, weight: .bold))
                        .foregroundColor(.primary)

                    Text("Network")
                        .font(.system(size: geometry.size.width * 0.1, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var formattedSpeed: String {
        if speed < 1024 {
            return String(format: "%.0f B/s", speed)
        } else if speed < 1024 * 1024 {
            return String(format: "%.0f KB/s", speed / 1024)
        } else {
            return String(format: "%.1f MB/s", speed / 1024 / 1024)
        }
    }
}

// MARK: - Disk Usage Gauge
struct DiskGauge: View {
    let usage: Double // 0-100

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background arc
                Circle()
                    .trim(from: 0.125, to: 0.875)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8)
                    .rotationEffect(.degrees(135))

                // Usage arc
                Circle()
                    .trim(from: 0, to: min(usage / 100.0, 1.0) * 0.75)
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8)
                    .rotationEffect(.degrees(135))
                    .animation(.easeInOut(duration: 0.5), value: usage)

                // Center content
                VStack(spacing: 4) {
                    Image(systemName: "internaldrive")
                        .font(.system(size: geometry.size.width * 0.15))
                        .foregroundColor(.blue)

                    Text("\(Int(usage))%")
                        .font(.system(size: geometry.size.width * 0.18, weight: .bold))
                        .foregroundColor(.primary)

                    Text("Storage")
                        .font(.system(size: geometry.size.width * 0.1, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Upload/Download Gauges (smaller for side-by-side)
struct UploadGauge: View {
    let speed: Double // in bytes/second
    let maxSpeed: Double = 10_485_760.0 // 10 MB/s

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background arc
                Circle()
                    .trim(from: 0.125, to: 0.875)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                    .frame(width: geometry.size.width * 0.85, height: geometry.size.width * 0.85)
                    .rotationEffect(.degrees(135))

                // Speed arc
                Circle()
                    .trim(from: 0, to: min(speed / maxSpeed, 1.0) * 0.75)
                    .stroke(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: geometry.size.width * 0.85, height: geometry.size.width * 0.85)
                    .rotationEffect(.degrees(135))
                    .animation(.easeInOut(duration: 0.5), value: speed)

                // Center content
                VStack(spacing: 2) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: geometry.size.width * 0.2))
                        .foregroundColor(.orange)

                    Text(formattedSpeed)
                        .font(.system(size: geometry.size.width * 0.13, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var formattedSpeed: String {
        if speed < 1024 {
            return String(format: "%.0f B/s", speed)
        } else if speed < 1024 * 1024 {
            return String(format: "%.0f KB/s", speed / 1024)
        } else {
            return String(format: "%.1f MB/s", speed / 1024 / 1024)
        }
    }
}

struct DownloadGauge: View {
    let speed: Double // in bytes/second
    let maxSpeed: Double = 10_485_760.0 // 10 MB/s

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background arc
                Circle()
                    .trim(from: 0.125, to: 0.875)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                    .frame(width: geometry.size.width * 0.85, height: geometry.size.width * 0.85)
                    .rotationEffect(.degrees(135))

                // Speed arc
                Circle()
                    .trim(from: 0, to: min(speed / maxSpeed, 1.0) * 0.75)
                    .stroke(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: geometry.size.width * 0.85, height: geometry.size.width * 0.85)
                    .rotationEffect(.degrees(135))
                    .animation(.easeInOut(duration: 0.5), value: speed)

                // Center content
                VStack(spacing: 2) {
                    Image(systemName: "arrow.down")
                        .font(.system(size: geometry.size.width * 0.2))
                        .foregroundColor(.green)

                    Text(formattedSpeed)
                        .font(.system(size: geometry.size.width * 0.13, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var formattedSpeed: String {
        if speed < 1024 {
            return String(format: "%.0f B/s", speed)
        } else if speed < 1024 * 1024 {
            return String(format: "%.0f KB/s", speed / 1024)
        } else {
            return String(format: "%.1f MB/s", speed / 1024 / 1024)
        }
    }
}

// MARK: - Helper to extract numeric value from temperature string
extension String {
    func extractTemperature() -> Double {
        let numericString = self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return Double(numericString) ?? 0.0
    }

    func extractRPM() -> Double {
        let numericString = self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return Double(numericString) ?? 0.0
    }
}
