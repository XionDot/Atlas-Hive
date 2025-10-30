import SwiftUI

struct MonitorView: View {
    @ObservedObject var systemMonitor: SystemMonitor
    @ObservedObject var configManager: ConfigManager
    @StateObject private var privacyManager = PrivacyManager()
    @State private var isReorderMode: Bool = false
    @State private var draggedItem: MetricSection?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Desktopie")
                    .font(.system(size: 18, weight: .bold))
                Spacer()
                Button(action: {
                    withAnimation {
                        isReorderMode.toggle()
                    }
                }) {
                    Image(systemName: isReorderMode ? "checkmark" : "arrow.up.arrow.down")
                        .font(.system(size: 16))
                        .foregroundColor(isReorderMode ? .green : .primary)
                }
                .buttonStyle(.plain)
                .help(isReorderMode ? "Done Reordering" : "Reorder Sections")

                Button(action: {
                    configManager.showTaskManager.toggle()
                }) {
                    Image(systemName: "list.bullet.rectangle")
                        .font(.system(size: 16))
                }
                .buttonStyle(.plain)
                .help("Task Manager")

                Button(action: {
                    configManager.showSettings.toggle()
                }) {
                    Image(systemName: "gear")
                        .font(.system(size: 16))
                }
                .buttonStyle(.plain)
                .help("Settings")

                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    Image(systemName: "power")
                        .font(.system(size: 16))
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                .help("Quit Desktopie")
            }
            .padding()
            .background(Color.accentColor.opacity(0.1))

            ScrollView {
                VStack(spacing: 20) {
                    ForEach(configManager.config.sectionOrder, id: \.self) { section in
                        metricSectionView(for: section)
                            .opacity(draggedItem == section && isReorderMode ? 0.5 : 1.0)
                            .onDrag({
                                if isReorderMode {
                                    self.draggedItem = section
                                    return NSItemProvider(object: section.rawValue as NSString)
                                }
                                return NSItemProvider()
                            })
                            .onDrop(of: [.text], delegate: DropViewDelegate(
                                destinationItem: section,
                                items: $configManager.config.sectionOrder,
                                draggedItem: $draggedItem,
                                isReorderMode: isReorderMode
                            ))
                    }

                    Spacer(minLength: 20)
                }
                .padding()
            }
        }
        .frame(width: 360, height: 480)
        .sheet(isPresented: $configManager.showSettings) {
            SettingsView(configManager: configManager)
        }
        .sheet(isPresented: $configManager.showTaskManager) {
            TaskManagerView(taskManager: TaskManager())
        }
    }

    @ViewBuilder
    func metricSectionView(for section: MetricSection) -> some View {
        switch section {
        case .cpu:
            MetricCard(
                title: "CPU",
                icon: "cpu",
                value: systemMonitor.cpuUsage,
                color: .blue,
                showGraph: configManager.config.showGraphs
            )
        case .memory:
            MetricCard(
                title: "Memory",
                icon: "memorychip",
                value: systemMonitor.memoryUsage,
                subtitle: formatBytes(systemMonitor.memoryUsed) + " / " + formatBytes(systemMonitor.memoryTotal),
                color: .green,
                showGraph: configManager.config.showGraphs
            )
        case .network:
            NetworkCard(
                downloadSpeed: systemMonitor.networkDownload,
                uploadSpeed: systemMonitor.networkUpload,
                showGraph: configManager.config.showGraphs
            )
        case .disk:
            MetricCard(
                title: "Disk",
                icon: "internaldrive",
                value: systemMonitor.diskUsage,
                color: .orange,
                showGraph: configManager.config.showGraphs
            )
        case .battery:
            if systemMonitor.batteryLevel > 0 {
                BatteryCard(
                    level: systemMonitor.batteryLevel,
                    isCharging: systemMonitor.isCharging
                )
            }
        case .privacy:
            PrivacyCard(privacyManager: privacyManager)
        }
    }

    func formatBytes(_ bytes: Double) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useMB]
        formatter.countStyle = .memory
        return formatter.string(fromByteCount: Int64(bytes))
    }

    func formatSpeed(_ bytesPerSecond: Double) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .binary
        return formatter.string(fromByteCount: Int64(bytesPerSecond)) + "/s"
    }
}

struct MetricCard: View {
    let title: String
    let icon: String
    let value: Double
    var subtitle: String? = nil
    let color: Color
    let showGraph: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 20))
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Text(String(format: "%.1f%%", value))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(color)
            }

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * (value / 100.0), height: 8)
                }
            }
            .frame(height: 8)

            if showGraph {
                MiniGraph(value: value, color: color)
                    .frame(height: 60)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

struct MiniGraph: View {
    let value: Double
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let step = width / 20

                path.move(to: CGPoint(x: 0, y: height))

                for i in 0...20 {
                    let x = step * Double(i)
                    let randomValue = Double.random(in: 0...1) * value / 100.0
                    let y = height - (randomValue * height)
                    path.addLine(to: CGPoint(x: x, y: y))
                }

                path.addLine(to: CGPoint(x: width, y: height))
                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [color.opacity(0.5), color.opacity(0.1)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
}

struct NetworkCard: View {
    let downloadSpeed: Double
    let uploadSpeed: Double
    let showGraph: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "network")
                    .foregroundColor(.purple)
                    .font(.system(size: 20))
                Text("Network")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
            }

            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 12))
                        Text("Download")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    Text(formatSpeed(downloadSpeed))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.blue)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 12))
                        Text("Upload")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    Text(formatSpeed(uploadSpeed))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.green)
                }

                Spacer()
            }

            if showGraph {
                NetworkGraph(downloadSpeed: downloadSpeed, uploadSpeed: uploadSpeed)
                    .frame(height: 60)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }

    func formatSpeed(_ bytesPerSecond: Double) -> String {
        if bytesPerSecond < 1024 {
            return String(format: "%.0f B/s", bytesPerSecond)
        } else if bytesPerSecond < 1024 * 1024 {
            return String(format: "%.1f KB/s", bytesPerSecond / 1024)
        } else if bytesPerSecond < 1024 * 1024 * 1024 {
            return String(format: "%.1f MB/s", bytesPerSecond / (1024 * 1024))
        } else {
            return String(format: "%.2f GB/s", bytesPerSecond / (1024 * 1024 * 1024))
        }
    }
}

struct NetworkGraph: View {
    let downloadSpeed: Double
    let uploadSpeed: Double

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 8) {
                // Download bar
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * 0.4, height: max(2, geometry.size.height * min(1.0, downloadSpeed / 10_000_000)))
                }

                // Upload bar
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.green)
                        .frame(width: geometry.size.width * 0.4, height: max(2, geometry.size.height * min(1.0, uploadSpeed / 10_000_000)))
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct BatteryCard: View {
    let level: Int
    let isCharging: Bool

    var batteryColor: Color {
        if isCharging { return .green }
        if level > 50 { return .green }
        if level > 20 { return .orange }
        return .red
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: isCharging ? "bolt.battery.fill" : "battery.100")
                    .foregroundColor(batteryColor)
                    .font(.system(size: 20))
                Text("Battery")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Text("\(level)%")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(batteryColor)
            }

            if isCharging {
                Text("Charging")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(batteryColor)
                        .frame(width: geometry.size.width * (Double(level) / 100.0), height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}


struct PrivacyCard: View {
    @ObservedObject var privacyManager: PrivacyManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lock.shield.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 20))
                Text("Privacy Controls")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
            }

            Text("Quickly disable hardware for privacy")
                .font(.system(size: 12))
                .foregroundColor(.secondary)

            VStack(spacing: 12) {
                // Camera Toggle
                PrivacyToggleRow(
                    icon: "video.fill",
                    title: "Camera",
                    isEnabled: privacyManager.cameraEnabled,
                    color: .blue
                ) {
                    privacyManager.toggleCamera()
                }

                Divider()

                // Microphone Toggle
                PrivacyToggleRow(
                    icon: "mic.fill",
                    title: "Microphone",
                    isEnabled: privacyManager.microphoneEnabled,
                    color: .orange
                ) {
                    privacyManager.toggleMicrophone()
                }

                Divider()

                // USB Toggle
                PrivacyToggleRow(
                    icon: "cable.connector",
                    title: "USB Ports",
                    isEnabled: privacyManager.usbEnabled,
                    color: .purple
                ) {
                    privacyManager.toggleUSB()
                }
            }
            .padding(.top, 4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

struct PrivacyToggleRow: View {
    let icon: String
    let title: String
    let isEnabled: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(isEnabled ? color : .gray)
                .font(.system(size: 16))
                .frame(width: 24)

            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.primary)

            Spacer()

            Button(action: action) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(isEnabled ? Color.green : Color.red)
                        .frame(width: 8, height: 8)

                    Text(isEnabled ? "Enabled" : "Disabled")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(isEnabled ? .green : .red)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isEnabled ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                )
            }
            .buttonStyle(.plain)
        }
    }
}

struct DropViewDelegate: DropDelegate {
    let destinationItem: MetricSection
    @Binding var items: [MetricSection]
    @Binding var draggedItem: MetricSection?
    let isReorderMode: Bool

    func dropEntered(info: DropInfo) {
        guard isReorderMode, let draggedItem = draggedItem else { return }

        if draggedItem != destinationItem {
            let from = items.firstIndex(of: draggedItem)!
            let to = items.firstIndex(of: destinationItem)!
            if items[to] != draggedItem {
                items.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
            }
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: isReorderMode ? .move : .cancel)
    }

    func performDrop(info: DropInfo) -> Bool {
        self.draggedItem = nil
        return true
    }
}
