import SwiftUI

struct MonitorView: View {
    @ObservedObject var systemMonitor: SystemMonitor
    @ObservedObject var configManager: ConfigManager
    @StateObject private var privacyManager = PrivacyManager()
    @State private var isReorderMode: Bool = false
    @State private var draggedItem: MetricSection?
    @State private var showSystemInfo = false

    var body: some View {
        VStack(spacing: 0) {
            // Header - Modern design matching SimplifiedMonitorView
            HStack(spacing: 8) {
                Image(systemName: "chart.xyaxis.line")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("PeakView")
                    .font(.system(size: 13, weight: .bold))
                    .fixedSize()

                Spacer()

                Button(action: {
                    showSystemInfo.toggle()
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
                    configManager.config.viewMode = .simple
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "square.grid.2x2")
                        Text("Simple")
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
                .fixedSize()
                .help("Switch to Simple Mode")

                Button(action: {
                    withAnimation {
                        isReorderMode.toggle()
                    }
                }) {
                    Image(systemName: isReorderMode ? "checkmark" : "arrow.up.arrow.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(
                            isReorderMode ?
                                LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                LinearGradient(colors: [.secondary], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 24, height: 24)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help(isReorderMode ? "Done Reordering" : "Reorder Sections")

                Button(action: {
                    configManager.showTaskManager.toggle()
                }) {
                    Image(systemName: "list.bullet.rectangle")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 24, height: 24)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help("Task Manager")

                Button(action: {
                    configManager.onShowSettings?()
                }) {
                    Image(systemName: "gearshape.fill")
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
                .help("Settings")

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
                .help("Quit PeakView")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.darkCard)

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

                    InfoRow(label: "Model", value: systemMonitor.deviceModel)
                    InfoRow(label: "macOS", value: systemMonitor.macOSVersion)
                    InfoRow(label: "Processor", value: systemMonitor.cpuModel)
                    InfoRow(label: "Cores", value: "\(systemMonitor.cpuCores) cores")
                    InfoRow(label: "Memory", value: String(format: "%.0f GB", systemMonitor.totalMemoryGB))
                    InfoRow(label: "Storage", value: String(format: "%.0f GB", systemMonitor.totalStorageGB))
                    InfoRow(label: "Display", value: systemMonitor.displayResolution)
                    InfoRow(label: "Uptime", value: systemMonitor.uptimeString)
                }
                .padding(12)
                .background(Color.blue.opacity(0.05))
                .overlay(
                    Rectangle()
                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal)
                .padding(.top, 8)
            }

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
        .frame(width: 360)
        .frame(minHeight: 480, maxHeight: 800)
    }

    @ViewBuilder
    func metricSectionView(for section: MetricSection) -> some View {
        switch section {
        case .cpu:
            DetailedCPUCard(systemMonitor: systemMonitor, showGraph: configManager.config.showGraphs)
        case .memory:
            DetailedMemoryCard(systemMonitor: systemMonitor, showGraph: configManager.config.showGraphs)
        case .network:
            DetailedNetworkCard(systemMonitor: systemMonitor, showGraph: configManager.config.showGraphs)
        case .disk:
            DetailedDiskCard(systemMonitor: systemMonitor, showGraph: configManager.config.showGraphs)
        case .temperature:
            // Temperature card - will be added to menu bar advanced view
            EmptyView()
        case .fan:
            // Fan card - will be added to menu bar advanced view
            EmptyView()
        case .battery:
            if systemMonitor.batteryLevel >= 0 {
                DetailedBatteryCard(systemMonitor: systemMonitor)
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

    func colorForPercentage(_ percentage: Double) -> Color {
        switch percentage {
        case 0..<40: return .green
        case 40..<70: return .yellow
        case 70..<90: return .orange
        default: return .red
        }
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
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
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
                .fill(Color.darkCard)
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
                .fill(Color.darkCard)
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
    let health: Int

    var batteryColor: Color {
        if isCharging { return .green }
        if level > 50 { return .green }
        if level > 20 { return .orange }
        return .red
    }

    var healthColor: Color {
        if health >= 80 { return .green }
        if health >= 60 { return .yellow }
        return .orange
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

            HStack {
                if isCharging {
                    Text("Charging")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 10))
                        .foregroundColor(healthColor)
                    Text("Health: \(health)%")
                        .font(.system(size: 12))
                        .foregroundColor(healthColor)
                }
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
                .fill(Color.darkCard)
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
                .fill(Color.darkCard)
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

// MARK: - Detailed Cards

struct DetailedCPUCard: View {
    @ObservedObject var systemMonitor: SystemMonitor
    let showGraph: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "cpu")
                    .foregroundColor(colorForPercentage(systemMonitor.cpuUsage))
                    .font(.system(size: 20))
                Text("CPU")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Text(String(format: "%.1f%%", systemMonitor.cpuUsage))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(colorForPercentage(systemMonitor.cpuUsage))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                if !systemMonitor.cpuModel.isEmpty {
                    DetailRow(label: "Model", value: systemMonitor.cpuModel)
                }
                DetailRow(label: "Cores", value: "\(systemMonitor.cpuCores) cores")
                if !systemMonitor.cpuLoadAverage.isEmpty {
                    DetailRow(label: "Load Average", value: systemMonitor.cpuLoadAverage)
                }
                if systemMonitor.gpuInfo != "N/A" {
                    DetailRow(label: "GPU", value: systemMonitor.gpuInfo)
                }
                if !systemMonitor.uptimeString.isEmpty {
                    DetailRow(label: "Uptime", value: systemMonitor.uptimeString)
                }
            }
            .font(.system(size: 11))
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(colorForPercentage(systemMonitor.cpuUsage))
                        .frame(width: geometry.size.width * (systemMonitor.cpuUsage / 100.0), height: 8)
                }
            }
            .frame(height: 8)
            
            if showGraph {
                MiniGraph(value: systemMonitor.cpuUsage, color: colorForPercentage(systemMonitor.cpuUsage))
                    .frame(height: 60)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.darkCard)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    func colorForPercentage(_ percentage: Double) -> Color {
        switch percentage {
        case 0..<40: return .green
        case 40..<70: return .yellow
        case 70..<90: return .orange
        default: return .red
        }
    }
}

struct DetailedMemoryCard: View {
    @ObservedObject var systemMonitor: SystemMonitor
    let showGraph: Bool

    private func formatNumber(_ number: UInt64) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "memorychip")
                    .foregroundColor(colorForPercentage(systemMonitor.memoryUsage))
                    .font(.system(size: 20))
                Text("Memory")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Text(String(format: "%.1f%%", systemMonitor.memoryUsage))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(colorForPercentage(systemMonitor.memoryUsage))
            }

            VStack(alignment: .leading, spacing: 6) {
                DetailRow(label: "Used", value: formatBytes(systemMonitor.memoryUsed))
                DetailRow(label: "Free", value: formatBytes(systemMonitor.memoryFree))
                DetailRow(label: "Cached Files", value: formatBytes(systemMonitor.memoryCached))
                DetailRow(label: "Wired", value: formatBytes(systemMonitor.memoryWired))
                DetailRow(label: "Compressed", value: formatBytes(systemMonitor.memoryCompressed))
                DetailRow(label: "Pressure", value: systemMonitor.memoryPressure)
                if systemMonitor.swapTotal > 0 {
                    DetailRow(label: "Swap", value: "\(formatBytes(systemMonitor.swapUsed)) / \(formatBytes(systemMonitor.swapTotal))")
                } else {
                    DetailRow(label: "Swap", value: "Not in use")
                }
                DetailRow(label: "Pages In", value: formatNumber(systemMonitor.pagesIn))
                DetailRow(label: "Pages Out", value: formatNumber(systemMonitor.pagesOut))
            }
            .font(.system(size: 11))
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(colorForPercentage(systemMonitor.memoryUsage))
                        .frame(width: geometry.size.width * (systemMonitor.memoryUsage / 100.0), height: 8)
                }
            }
            .frame(height: 8)
            
            if showGraph {
                MiniGraph(value: systemMonitor.memoryUsage, color: colorForPercentage(systemMonitor.memoryUsage))
                    .frame(height: 60)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.darkCard)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    func colorForPercentage(_ percentage: Double) -> Color {
        switch percentage {
        case 0..<40: return .green
        case 40..<70: return .yellow
        case 70..<90: return .orange
        default: return .red
        }
    }
    
    func formatBytes(_ bytes: Double) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useMB]
        formatter.countStyle = .memory
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

struct DetailedDiskCard: View {
    @ObservedObject var systemMonitor: SystemMonitor
    let showGraph: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "internaldrive")
                    .foregroundColor(colorForPercentage(systemMonitor.diskUsage))
                    .font(.system(size: 20))
                Text("Disk")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Text(String(format: "%.1f%%", systemMonitor.diskUsage))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(colorForPercentage(systemMonitor.diskUsage))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                if systemMonitor.totalStorageGB > 0 {
                    DetailRow(label: "Total", value: String(format: "%.0f GB", systemMonitor.totalStorageGB))
                }
                if systemMonitor.diskFree > 0 {
                    DetailRow(label: "Free", value: formatBytes(systemMonitor.diskFree))
                }
                if !systemMonitor.mountedDisks.isEmpty {
                    DetailRow(label: "Mounted", value: "\(systemMonitor.mountedDisks.count) disks")
                }
                if systemMonitor.smartStatus != "N/A" {
                    DetailRow(label: "S.M.A.R.T", value: systemMonitor.smartStatus)
                }
            }
            .font(.system(size: 11))
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(colorForPercentage(systemMonitor.diskUsage))
                        .frame(width: geometry.size.width * (systemMonitor.diskUsage / 100.0), height: 8)
                }
            }
            .frame(height: 8)
            
            if showGraph {
                MiniGraph(value: systemMonitor.diskUsage, color: colorForPercentage(systemMonitor.diskUsage))
                    .frame(height: 60)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.darkCard)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    func colorForPercentage(_ percentage: Double) -> Color {
        switch percentage {
        case 0..<40: return .green
        case 40..<70: return .yellow
        case 70..<90: return .orange
        default: return .red
        }
    }
    
    func formatBytes(_ bytes: Double) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useMB]
        formatter.countStyle = .memory
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

struct DetailedNetworkCard: View {
    @ObservedObject var systemMonitor: SystemMonitor
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
                Image(systemName: systemMonitor.networkConnected ? "wifi" : "wifi.slash")
                    .foregroundColor(systemMonitor.networkConnected ? .green : .gray)
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
                    Text(formatSpeed(systemMonitor.networkDownload))
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
                    Text(formatSpeed(systemMonitor.networkUpload))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.green)
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 6) {
                if systemMonitor.publicIP != "Loading..." && systemMonitor.publicIP != "Unavailable" {
                    DetailRow(label: "Public IP", value: systemMonitor.publicIP)
                }
                if !systemMonitor.localIP.isEmpty {
                    DetailRow(label: "Local IP", value: systemMonitor.localIP)
                }
                if systemMonitor.peakDownload > 0 {
                    DetailRow(label: "Peak Down", value: formatSpeed(systemMonitor.peakDownload))
                }
                if systemMonitor.peakUpload > 0 {
                    DetailRow(label: "Peak Up", value: formatSpeed(systemMonitor.peakUpload))
                }
            }
            .font(.system(size: 11))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.darkCard)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    func formatSpeed(_ bytesPerSecond: Double) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .binary
        return formatter.string(fromByteCount: Int64(bytesPerSecond)) + "/s"
    }
}

struct DetailedBatteryCard: View {
    @ObservedObject var systemMonitor: SystemMonitor
    
    var batteryColor: Color {
        if systemMonitor.isCharging { return .green }
        if systemMonitor.batteryLevel > 50 { return .green }
        if systemMonitor.batteryLevel > 20 { return .orange }
        return .red
    }
    
    var healthColor: Color {
        if systemMonitor.batteryHealth >= 80 { return .green }
        if systemMonitor.batteryHealth >= 60 { return .yellow }
        return .orange
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: systemMonitor.isCharging ? "bolt.battery.fill" : "battery.100")
                    .foregroundColor(batteryColor)
                    .font(.system(size: 20))
                Text("Battery")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Text("\(systemMonitor.batteryLevel)%")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(batteryColor)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                DetailRow(label: "Status", value: systemMonitor.isCharging ? "Charging" : "Discharging")
                if systemMonitor.batteryTimeRemaining != "N/A" && systemMonitor.batteryTimeRemaining != "Unknown" {
                    DetailRow(label: "Time Remaining", value: systemMonitor.batteryTimeRemaining)
                }
                DetailRow(label: "Health", value: "\(systemMonitor.batteryHealth)%")
                if systemMonitor.batteryCycles > 0 {
                    DetailRow(label: "Cycles", value: "\(systemMonitor.batteryCycles)")
                }
                if systemMonitor.batteryCapacity != "N/A" {
                    DetailRow(label: "Capacity", value: systemMonitor.batteryCapacity)
                }
                if systemMonitor.batteryWattage != "N/A" {
                    DetailRow(label: "Wattage", value: systemMonitor.batteryWattage)
                }
            }
            .font(.system(size: 11))
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(batteryColor)
                        .frame(width: geometry.size.width * (Double(systemMonitor.batteryLevel) / 100.0), height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.darkCard)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(.primary)
        }
    }
}
