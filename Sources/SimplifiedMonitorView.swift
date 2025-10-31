import SwiftUI

struct SimplifiedMonitorView: View {
    @ObservedObject var monitor: SystemMonitor
    @ObservedObject var configManager: ConfigManager

    var body: some View {
        VStack(spacing: 16) {
            // Header with mode toggle
            HStack {
                Text("System Monitor")
                    .font(.system(size: 18, weight: .semibold))

                Spacer()

                Button(action: {
                    configManager.config.viewMode = .advanced
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "slider.horizontal.3")
                        Text("Advanced")
                    }
                    .font(.system(size: 11))
                    .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 8)

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

                // Battery Status (if available)
                if monitor.batteryLevel > 0 && monitor.batteryLevel < 100 {
                    StatusCard(
                        icon: batteryIcon(),
                        title: "Battery",
                        status: monitor.isCharging ? "Charging" : batteryStatusText(),
                        value: String(format: "%.0f%%", Double(monitor.batteryLevel)),
                        color: batteryColor()
                    )
                }
            }

            Spacer(minLength: 12)

            // Quick action buttons
            HStack(spacing: 12) {
                Button(action: {
                    configManager.showTaskManager = true
                }) {
                    HStack {
                        Image(systemName: "app.badge.fill")
                        Text("Open Apps")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)

                Button(action: {
                    configManager.showSettings = true
                }) {
                    HStack {
                        Image(systemName: "gearshape.fill")
                        Text("Settings")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.primary)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
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
}

struct StatusCard: View {
    let icon: String
    let title: String
    let status: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 36, height: 36)

            // Title and status
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)

                Text(status)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Value
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.1))
        )
    }
}