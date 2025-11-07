import SwiftUI

// MARK: - Sparkline Graph View
struct SparklineView: View {
    let dataPoints: [Double]
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            if dataPoints.count > 1 {
                let maxValue = dataPoints.max() ?? 1.0
                let path = createPath(in: geometry.size, maxValue: maxValue)

                ZStack {
                    // Background
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color.opacity(0.1))

                    // Line graph
                    path
                        .stroke(color, lineWidth: 1.5)
                        .animation(.easeInOut(duration: 0.3), value: dataPoints)
                }
            }
        }
    }

    private func createPath(in size: CGSize, maxValue: Double) -> Path {
        var path = Path()

        let stepX = size.width / CGFloat(max(dataPoints.count - 1, 1))
        let safeMaxValue = maxValue > 0 ? maxValue : 1.0

        for (index, value) in dataPoints.enumerated() {
            let x = CGFloat(index) * stepX
            let normalizedValue = min(value / safeMaxValue, 1.0)
            let y = size.height * (1.0 - normalizedValue)

            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        return path
    }
}

// MARK: - Modular Metric Block
struct ModularMetricBlock: View {
    let section: MetricSection
    @ObservedObject var monitor: SystemMonitor
    @ObservedObject var configManager: ConfigManager
    @Binding var draggedItem: MetricSection?
    let isReorderMode: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header with toggle button
            HStack {
                Image(systemName: iconFor(section))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(colorFor(section))

                Text(section == .temperature ? "Temperature & Fan" : section.rawValue)
                    .font(.system(size: 15, weight: .bold))

                Spacer()

                // Toggle between graph and gauge
                if section == .temperature {
                    // Temperature & Fan combined toggles
                    HStack(spacing: 4) {
                        Button(action: {
                            toggleDisplayMode(for: .temperature)
                        }) {
                            Image(systemName: displayMode(for: .temperature) == .gauge ? "thermometer.medium" : "chart.xyaxis.line")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(displayMode(for: .temperature) == .gauge ? .white : .orange)
                                .frame(width: 26, height: 26)
                                .background(displayMode(for: .temperature) == .gauge ? Color.orange.opacity(0.8) : Color.orange.opacity(0.1))
                                .cornerRadius(6)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .help("Toggle Temperature Gauge")

                        Button(action: {
                            toggleDisplayMode(for: .fan)
                        }) {
                            Image(systemName: displayMode(for: .fan) == .gauge ? "fan" : "chart.xyaxis.line")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(displayMode(for: .fan) == .gauge ? .white : .cyan)
                                .frame(width: 26, height: 26)
                                .background(displayMode(for: .fan) == .gauge ? Color.cyan.opacity(0.8) : Color.cyan.opacity(0.1))
                                .cornerRadius(6)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .help("Toggle Fan Gauge")
                    }
                } else if section == .network {
                    // Network toggle
                    Button(action: {
                        toggleDisplayMode(for: .network)
                    }) {
                        Image(systemName: displayMode(for: .network) == .gauge ? "gauge.medium" : "chart.xyaxis.line")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.blue)
                            .frame(width: 28, height: 28)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(6)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .help(displayMode(for: .network) == .gauge ? "Switch to Graph View" : "Switch to Gauge View")
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.darkCard.opacity(0.5))

            // Content based on display mode
            contentView(for: section)
                .padding(12)
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.darkCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(colorFor(section).opacity(0.3), lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .opacity(draggedItem == section ? 0.5 : 1.0)
        .onDrag {
            if isReorderMode {
                self.draggedItem = section
                return NSItemProvider(object: section.rawValue as NSString)
            }
            return NSItemProvider()
        }
        .onDrop(of: [.text], delegate: MetricDropDelegate(
            destinationItem: section,
            draggedItem: $draggedItem,
            configManager: configManager
        ))
    }

    @ViewBuilder
    private func contentView(for section: MetricSection) -> some View {
        switch section {
        case .cpu:
            cpuContent
        case .memory:
            memoryContent
        case .network:
            networkContent
        case .disk:
            diskContent
        case .temperature:
            temperatureContent
        case .fan:
            fanContent
        case .battery:
            if monitor.batteryLevel >= 0 {
                batteryContent
            }
        case .privacy:
            EmptyView() // Privacy handled separately
        }
    }

    // MARK: - CPU Content
    private var cpuContent: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(String(format: "%.1f", monitor.cpuUsage))%")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(colorForPercentage(monitor.cpuUsage))
                Spacer()

                // Mini sparkline graph
                SparklineView(
                    dataPoints: monitor.cpuHistory,
                    color: colorForPercentage(monitor.cpuUsage)
                )
                .frame(width: 60, height: 24)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(colorForPercentage(monitor.cpuUsage))
                        .frame(width: geometry.size.width * (monitor.cpuUsage / 100.0), height: 8)
                }
            }
            .frame(height: 8)

            VStack(alignment: .leading, spacing: 4) {
                if !monitor.cpuModel.isEmpty {
                    MetricDetailRow(label: "Model", value: monitor.cpuModel)
                }
                MetricDetailRow(label: "Cores", value: "\(monitor.cpuCores) cores")
                if !monitor.cpuLoadAverage.isEmpty {
                    MetricDetailRow(label: "Load Avg", value: monitor.cpuLoadAverage)
                }
                if monitor.gpuInfo != "N/A" {
                    MetricDetailRow(label: "GPU", value: monitor.gpuInfo)
                }
            }
            .font(.system(size: 10))
        }
    }

    // MARK: - Memory Content
    private var memoryContent: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(String(format: "%.1f", monitor.memoryUsage))%")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(colorForPercentage(monitor.memoryUsage))
                Spacer()

                // Mini sparkline graph
                SparklineView(
                    dataPoints: monitor.memoryHistory,
                    color: colorForPercentage(monitor.memoryUsage)
                )
                .frame(width: 60, height: 24)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(colorForPercentage(monitor.memoryUsage))
                        .frame(width: geometry.size.width * (monitor.memoryUsage / 100.0), height: 8)
                }
            }
            .frame(height: 8)

            VStack(alignment: .leading, spacing: 4) {
                MetricDetailRow(label: "Used", value: formatBytes(monitor.memoryUsed))
                MetricDetailRow(label: "Free", value: formatBytes(monitor.memoryFree))
                MetricDetailRow(label: "Cached", value: formatBytes(monitor.memoryCached))
                MetricDetailRow(label: "Wired", value: formatBytes(monitor.memoryWired))
                MetricDetailRow(label: "Compressed", value: formatBytes(monitor.memoryCompressed))
                MetricDetailRow(label: "Pressure", value: monitor.memoryPressure)
                if monitor.swapTotal > 0 {
                    MetricDetailRow(label: "Swap", value: "\(formatBytes(monitor.swapUsed)) / \(formatBytes(monitor.swapTotal))")
                } else {
                    MetricDetailRow(label: "Swap", value: "Not in use")
                }
            }
            .font(.system(size: 10))
        }
    }

    // MARK: - Network Content
    private var networkContent: some View {
        Group {
            if displayMode(for: .network) == .gauge {
                // Side-by-side gauges for upload and download
                HStack(spacing: 16) {
                    VStack(spacing: 4) {
                        DownloadGauge(speed: monitor.networkDownload)
                            .frame(width: 90, height: 90)
                        Text("Download")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)

                    Divider()
                        .frame(height: 90)

                    VStack(spacing: 4) {
                        UploadGauge(speed: monitor.networkUpload)
                            .frame(width: 90, height: 90)
                        Text("Upload")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 8)
            } else {
                VStack(spacing: 8) {
                    RealtimeGraphView(
                        dataPoints: monitor.networkHistory,
                        color: .purple,
                        maxValue: monitor.networkHistory.max() ?? 1024
                    )
                    .frame(height: 80)

                    VStack(spacing: 4) {
                        MetricDetailRow(label: "Download", value: formatBytes(monitor.networkDownload) + "/s")
                        MetricDetailRow(label: "Upload", value: formatBytes(monitor.networkUpload) + "/s")
                    }
                    .padding(.top, 8)
                }
            }
        }
    }

    // MARK: - Disk Content
    private var diskContent: some View {
        VStack(spacing: 8) {
            // Progress bar style for disk
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 20)
                        .cornerRadius(10)

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * (monitor.diskUsage / 100.0), height: 20)
                        .cornerRadius(10)
                }
            }
            .frame(height: 20)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Used")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Text(formatBytes(monitor.diskTotal - monitor.diskFree))
                        .font(.system(size: 12, weight: .semibold))
                }

                Spacer()

                Text("\(String(format: "%.1f", monitor.diskUsage))%")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.blue)

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Free")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Text(formatBytes(monitor.diskFree))
                        .font(.system(size: 12, weight: .semibold))
                }
            }
        }
    }

    // MARK: - Temperature Content (combined with Fan)
    private var temperatureContent: some View {
        HStack(spacing: 12) {
            // Temperature section
            HStack(spacing: 6) {
                if displayMode(for: .temperature) == .gauge {
                    TemperatureGauge(temperature: monitor.cpuTemperature.extractTemperature())
                        .frame(width: 85, height: 85)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Temp")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.orange)
                        .fixedSize()
                    MetricDetailRow(label: "CPU", value: monitor.cpuTemperature)
                    MetricDetailRow(label: "Disk", value: monitor.diskTemperature)
                    if monitor.batteryLevel >= 0 {
                        MetricDetailRow(label: "Batt", value: monitor.batteryTemperature)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                .frame(minWidth: 80)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()
                .frame(height: 85)

            // Fan section
            HStack(spacing: 6) {
                if displayMode(for: .fan) == .gauge {
                    FanSpeedGauge(rpm: monitor.fanSpeed.extractRPM())
                        .frame(width: 85, height: 85)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Fan")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.cyan)
                        .fixedSize()
                    MetricDetailRow(label: "Speed", value: monitor.fanSpeed)
                    MetricDetailRow(label: "State", value: monitor.fanSpeed != "N/A" ? "Active" : "Idle")
                }
                .fixedSize(horizontal: false, vertical: true)
                .frame(minWidth: 80)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Fan Content
    private var fanContent: some View {
        EmptyView() // Fan is now combined with temperature
    }

    // MARK: - Battery Content
    private var batteryContent: some View {
        VStack(spacing: 8) {
            // Battery percentage display
            HStack {
                Text("\(monitor.batteryLevel)%")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(batteryColor)
                Spacer()

                // Charging status or time remaining
                if monitor.isCharging {
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 12))
                        Text("Charging")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(.green)
                } else if monitor.batteryTimeRemaining != "N/A" && monitor.batteryTimeRemaining != "Unknown" {
                    Text(monitor.batteryTimeRemaining)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }

            // Battery progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: batteryGradient,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * (Double(monitor.batteryLevel) / 100.0), height: 8)
                }
            }
            .frame(height: 8)

            VStack(alignment: .leading, spacing: 4) {
                MetricDetailRow(label: "Health", value: "\(monitor.batteryHealth)%")
                MetricDetailRow(label: "Cycles", value: "\(monitor.batteryCycles)")
                if monitor.batteryCapacity != "N/A" && !monitor.batteryCapacity.isEmpty {
                    MetricDetailRow(label: "Capacity", value: monitor.batteryCapacity)
                }
                if monitor.batteryWattage != "N/A" && !monitor.batteryWattage.isEmpty {
                    MetricDetailRow(label: "Power", value: monitor.batteryWattage)
                }
            }
            .font(.system(size: 10))
        }
    }

    // MARK: - Helper Functions
    private func iconFor(_ section: MetricSection) -> String {
        switch section {
        case .cpu: return "cpu"
        case .memory: return "memorychip"
        case .network: return "network"
        case .disk: return "internaldrive"
        case .temperature: return "thermometer.medium"
        case .fan: return "fan"
        case .battery: return batteryIcon()
        case .privacy: return "shield.lefthalf.filled"
        }
    }

    private func batteryIcon() -> String {
        if monitor.isCharging {
            // Show charging icon with appropriate battery level
            if monitor.batteryLevel > 80 {
                return "battery.100.bolt"
            } else if monitor.batteryLevel > 50 {
                return "battery.75.bolt"
            } else if monitor.batteryLevel > 25 {
                return "battery.50.bolt"
            } else {
                return "battery.25.bolt"
            }
        } else {
            // Show regular battery icon based on level
            if monitor.batteryLevel > 80 {
                return "battery.100"
            } else if monitor.batteryLevel > 50 {
                return "battery.75"
            } else if monitor.batteryLevel > 25 {
                return "battery.50"
            } else {
                return "battery.25"
            }
        }
    }

    private func colorFor(_ section: MetricSection) -> Color {
        switch section {
        case .cpu: return .blue
        case .memory: return .green
        case .network: return .purple
        case .disk: return .cyan
        case .temperature: return .orange
        case .fan: return .mint
        case .battery: return .yellow
        case .privacy: return .indigo
        }
    }

    private func canToggleView(_ section: MetricSection) -> Bool {
        switch section {
        case .temperature, .fan, .network:
            return true
        case .cpu, .memory, .disk, .battery, .privacy:
            return false
        }
    }

    private func displayMode(for section: MetricSection) -> MetricDisplayMode {
        return configManager.config.metricDisplayModes[section.rawValue] ?? .graph
    }

    private func toggleDisplayMode(for section: MetricSection) {
        let currentMode = displayMode(for: section)
        let newMode: MetricDisplayMode = currentMode == .graph ? .gauge : .graph
        configManager.config.metricDisplayModes[section.rawValue] = newMode
    }

    private func colorForPercentage(_ percentage: Double) -> Color {
        switch percentage {
        case 0..<40: return .green
        case 40..<70: return .yellow
        case 70..<90: return .orange
        default: return .red
        }
    }

    private var batteryColor: Color {
        if monitor.isCharging { return .green }
        if monitor.batteryLevel > 50 { return .green }
        if monitor.batteryLevel > 20 { return .yellow }
        return .red
    }

    private var batteryGradient: [Color] {
        if monitor.isCharging { return [.green, .mint] }
        if monitor.batteryLevel > 50 { return [.green, .mint] }
        if monitor.batteryLevel > 20 { return [.yellow, .orange] }
        return [.red, .pink]
    }

    private func formatBytes(_ bytes: Double) -> String {
        if bytes < 1024 {
            return String(format: "%.0f B", bytes)
        } else if bytes < 1024 * 1024 {
            return String(format: "%.1f KB", bytes / 1024)
        } else if bytes < 1024 * 1024 * 1024 {
            return String(format: "%.1f MB", bytes / 1024 / 1024)
        } else {
            return String(format: "%.2f GB", bytes / 1024 / 1024 / 1024)
        }
    }
}

// MARK: - Drop Delegate for Reordering
struct MetricDropDelegate: DropDelegate {
    let destinationItem: MetricSection
    @Binding var draggedItem: MetricSection?
    let configManager: ConfigManager

    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
        return true
    }

    func dropEntered(info: DropInfo) {
        guard let draggedItem = draggedItem else { return }

        if draggedItem != destinationItem {
            let from = configManager.config.sectionOrder.firstIndex(of: draggedItem)!
            let to = configManager.config.sectionOrder.firstIndex(of: destinationItem)!

            withAnimation(.default) {
                configManager.config.sectionOrder.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
            }
        }
    }
}
