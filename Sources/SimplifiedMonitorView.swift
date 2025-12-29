import SwiftUI

struct SimplifiedMonitorView: View {
    @ObservedObject var monitor: SystemMonitor
    @ObservedObject var configManager: ConfigManager
    @State private var showSystemInfo = false

    var body: some View {
        VStack(spacing: 0) {
            // Scrollable content
            ScrollView {
                VStack(spacing: 16) {
                    // Header with mode toggle - Modern design
                    HStack {
                HStack(spacing: 8) {
                    Image(systemName: "chart.xyaxis.line")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("System Monitor")
                        .font(.system(size: 16, weight: .bold))
                }

                Spacer()

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showSystemInfo.toggle()
                    }
                }) {
                    Image(systemName: showSystemInfo ? "info.circle.fill" : "info.circle")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 24, height: 24)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help("System Information")

                Button(action: {
                    configManager.config.viewMode = .advanced
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "slider.horizontal.3")
                        Text("Advanced")
                    }
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(6)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help("Switch to Advanced Mode")

                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    Image(systemName: "power")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.red)
                        .frame(width: 24, height: 24)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help("Quit Atlas")
            }
            .padding(.bottom, 12)

            // System Information Panel
            if showSystemInfo {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "desktopcomputer")
                            .foregroundColor(.blue)
                        Text("System Information")
                            .font(.system(size: 13, weight: .semibold))
                    }

                    Divider()

                    InfoRow(label: "Model", value: monitor.deviceModel)
                    InfoRow(label: "macOS", value: monitor.macOSVersion)
                    InfoRow(label: "Processor", value: monitor.cpuModel)
                    InfoRow(label: "Cores", value: "\(monitor.cpuCores) cores")
                    InfoRow(label: "Memory", value: String(format: "%.0f GB", monitor.totalMemoryGB))
                    InfoRow(label: "Storage", value: String(format: "%.0f GB", monitor.totalStorageGB))
                    InfoRow(label: "Display", value: monitor.displayResolution)
                    InfoRow(label: "Uptime", value: monitor.uptimeString)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            // Simple status cards
            VStack(spacing: 12) {
                // CPU Status
                StatusCard(
                    icon: "cpu",
                    title: "Processor",
                    status: statusText(for: monitor.cpuUsage),
                    value: String(format: "%.0f%%", monitor.cpuUsage),
                    color: colorForPercentage(monitor.cpuUsage)
                )

                // Memory Status
                StatusCard(
                    icon: "memorychip",
                    title: "Memory",
                    status: statusText(for: monitor.memoryUsage),
                    value: String(format: "%.0f%%", monitor.memoryUsage),
                    color: colorForPercentage(monitor.memoryUsage)
                )

                // Network Status
                StatusCard(
                    icon: "network",
                    title: "Network",
                    status: networkStatus(),
                    value: formatNetworkSpeed(),
                    color: .blue
                )

                // Disk Status
                StatusCard(
                    icon: "internaldrive",
                    title: "Storage",
                    status: statusText(for: monitor.diskUsage),
                    value: String(format: "%.0f%%", monitor.diskUsage),
                    color: colorForPercentage(monitor.diskUsage)
                )

                // Temperature Status
                StatusCard(
                    icon: "thermometer.medium",
                    title: "Temperature",
                    status: tempStatus(monitor.cpuTemperature),
                    value: monitor.cpuTemperature,
                    color: temperatureColor(monitor.cpuTemperature)
                )

                // Fan Status
                StatusCard(
                    icon: "fan",
                    title: "Fans",
                    status: monitor.fanSpeed != "N/A" ? "Active" : "Inactive",
                    value: monitor.fanSpeed,
                    color: .cyan
                )

                // Battery Status (if available on laptops)
                if monitor.batteryLevel >= 0 {
                    StatusCard(
                        icon: batteryIcon(),
                        title: "Battery",
                        status: monitor.isCharging ? "Charging" : batteryStatusText(),
                        value: String(format: "%.0f%%", Double(monitor.batteryLevel)),
                        color: batteryColor()
                    )
                }
            }
                }
                .padding(16)
            }

            // Quick action buttons - fixed at bottom with modern gradients
            HStack(spacing: 12) {
                Button(action: {
                    configManager.showTaskManager = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "app.badge.fill")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Open Apps")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .shadow(color: .green.opacity(0.3), radius: 4, x: 0, y: 2)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help("Open Task Manager")

                Button(action: {
                    configManager.onShowSettings?()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Settings")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help("Open Settings")
            }
            .padding(16)
            .background(Color.darkCard)
        }
        .frame(width: 340)
    }

    private func statusText(for percentage: Double) -> String {
        switch percentage {
        case 0..<40: return "Good"
        case 40..<70: return "Moderate"
        case 70..<90: return "High"
        default: return "Critical"
        }
    }

    private func colorForPercentage(_ percentage: Double) -> Color {
        switch percentage {
        case 0..<40: return .green
        case 40..<70: return .yellow
        case 70..<90: return .orange
        default: return .red
        }
    }

    private func networkStatus() -> String {
        let total = monitor.networkDownload + monitor.networkUpload
        if total < 1024 * 10 { // Less than 10 KB/s
            return "Idle"
        } else if total < 1024 * 1024 { // Less than 1 MB/s
            return "Active"
        } else {
            return "Heavy Use"
        }
    }

    private func formatNetworkSpeed() -> String {
        let down = monitor.networkDownload
        let up = monitor.networkUpload

        if down < 1024 && up < 1024 {
            return "Idle"
        } else if down > up {
            return formatBytes(down) + "/s ↓"
        } else {
            return formatBytes(up) + "/s ↑"
        }
    }

    private func formatBytes(_ bytes: Double) -> String {
        if bytes < 1024 {
            return String(format: "%.0f B", bytes)
        } else if bytes < 1024 * 1024 {
            return String(format: "%.1f KB", bytes / 1024)
        } else {
            return String(format: "%.1f MB", bytes / 1024 / 1024)
        }
    }

    private func batteryIcon() -> String {
        if monitor.isCharging {
            return "battery.100.bolt"
        } else if monitor.batteryLevel > 80 {
            return "battery.100"
        } else if monitor.batteryLevel > 50 {
            return "battery.75"
        } else if monitor.batteryLevel > 25 {
            return "battery.50"
        } else {
            return "battery.25"
        }
    }

    private func batteryStatusText() -> String {
        if monitor.batteryLevel > 80 {
            return "Excellent"
        } else if monitor.batteryLevel > 50 {
            return "Good"
        } else if monitor.batteryLevel > 20 {
            return "Low"
        } else {
            return "Critical"
        }
    }

    private func batteryColor() -> Color {
        if monitor.isCharging {
            return .green
        } else if monitor.batteryLevel > 50 {
            return .green
        } else if monitor.batteryLevel > 20 {
            return .yellow
        } else {
            return .red
        }
    }

    private func temperatureColor(_ temp: String) -> Color {
        // Extract numeric value from temperature string (e.g., "45°C" -> 45)
        let numericString = temp.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        guard let tempValue = Double(numericString) else { return .blue }

        // Color based on temperature (assuming Celsius)
        switch tempValue {
        case 0..<50: return .green
        case 50..<70: return .yellow
        case 70..<85: return .orange
        default: return .red
        }
    }

    private func tempStatus(_ temp: String) -> String {
        let numericString = temp.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        guard let tempValue = Double(numericString) else { return "Unknown" }

        switch tempValue {
        case 0..<50: return "Cool"
        case 50..<70: return "Warm"
        case 70..<85: return "Hot"
        default: return "Critical"
        }
    }
}

struct StatusCard: View {
    let icon: String
    let title: String
    let status: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            // Icon with gradient background
            ZStack {
                RoundedRectangle(cornerRadius: Color.isSamaritanMode ? 0 : 8)
                    .fill(Color.isSamaritanMode ? Color.samaritanRed.opacity(0.1) : color.opacity(0.15))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(Font.samaritanBody(size: 18))
                    .foregroundColor(Color.isSamaritanMode ? .samaritanRed : color)
            }

            // Title and status
            VStack(alignment: .leading, spacing: 2) {
                Text(Color.isSamaritanMode ? title.uppercased() : title)
                    .font(Font.samaritanBody(size: 12))
                    .foregroundColor(Color.isSamaritanMode ? .samaritanText : .primary)
                    .samaritanSpacing()

                Text(Color.isSamaritanMode ? status.uppercased() : status)
                    .font(Font.samaritanCaption(size: 10))
                    .foregroundColor(Color.isSamaritanMode ? .samaritanTextSecondary : .secondary)
                    .samaritanSpacing()
            }

            Spacer()

            // Value
            Text(value)
                .font(Font.samaritanData(size: 14))
                .foregroundColor(Color.isSamaritanMode ? .samaritanOrange : color)
                .samaritanSpacing()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: Color.isSamaritanMode ? 0 : 10)
                .fill(Color.darkCard)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Color.isSamaritanMode ? 0 : 10)
                .stroke(Color.isSamaritanMode ? Color.samaritanBorder : color.opacity(0.2), lineWidth: Color.isSamaritanMode ? 2 : 1)
        )
        .samaritanPulseGlow(color: .samaritanRed)
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }
}