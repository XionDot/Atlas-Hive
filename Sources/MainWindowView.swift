import SwiftUI

struct MainWindowView: View {
    @ObservedObject var monitor: SystemMonitor
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var configManager: ConfigManager
    @ObservedObject var alertManager: AlertManager
    @State private var showSettings: Bool = false
    @State private var showNetworkMonitor: Bool = false
    @State private var showCommandBar: Bool = false
    @State private var keyMonitor: Any?

    var body: some View {
        Group {
            if configManager.config.atlasMode {
                // Full-screen Atlas Mode
                AtlasView(
                    monitor: monitor,
                    taskManager: taskManager,
                    configManager: configManager
                )
                .onAppear {
                    enterFullscreen()
                }
            } else {
                // Normal two-column layout
                normalModeView
                    .onAppear {
                        exitFullscreen()
                    }
            }
        }
    }

    private func enterFullscreen() {
        DispatchQueue.main.async {
            if let window = NSApplication.shared.windows.first(where: { $0.title == "PeakView" }) {
                if !window.styleMask.contains(.fullScreen) {
                    window.toggleFullScreen(nil)
                }
            }
        }
    }

    private func exitFullscreen() {
        DispatchQueue.main.async {
            if let window = NSApplication.shared.windows.first(where: { $0.title == "PeakView" }) {
                if window.styleMask.contains(.fullScreen) {
                    window.toggleFullScreen(nil)
                }
            }
        }
    }

    private var normalModeView: some View {
        ZStack(alignment: .trailing) {
            // Main content - Two column layout
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    // Left Column - System Monitor (35%)
                    SystemMonitorColumn(
                        monitor: monitor,
                        configManager: configManager,
                        alertManager: alertManager,
                        showSettings: $showSettings,
                        showNetworkMonitor: $showNetworkMonitor
                    )
                    .frame(width: geometry.size.width * 0.35)

                    Divider()

                    // Right Column - Task Manager (65%)
                    TaskManagerColumn(taskManager: taskManager, configManager: configManager)
                        .frame(width: geometry.size.width * 0.65)
                }
            }
            .blur(radius: (showSettings || showNetworkMonitor) ? 3 : 0)
            .animation(.easeInOut(duration: 0.3), value: showSettings)
            .animation(.easeInOut(duration: 0.3), value: showNetworkMonitor)

            // Settings slide-in panel
            if showSettings {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showSettings = false
                        }
                    }
                    .transition(.opacity)

                SettingsPanel(configManager: configManager, alertManager: alertManager, isShowing: $showSettings)
                    .frame(width: 450)
                    .transition(.move(edge: .trailing))
            }

            // Network Monitor slide-in panel
            if showNetworkMonitor {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showNetworkMonitor = false
                        }
                    }
                    .transition(.opacity)

                GeometryReader { geo in
                    NetworkMonitorPanel(isShowing: $showNetworkMonitor)
                        .frame(width: min(1250, geo.size.width * 0.8))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .transition(.move(edge: .trailing))
            }

            // Samaritan Command Bar
            if showCommandBar {
                SamaritanCommandBar(isShowing: $showCommandBar) { command in
                    handleCommand(command)
                }
                .transition(.opacity)
                .zIndex(1000)
            }
            }
            .frame(minWidth: 1200, idealWidth: 1200, maxWidth: .infinity, minHeight: 700, idealHeight: 700, maxHeight: .infinity)
            .samaritanGridOverlay()
            .samaritanScanlines()
            .onAppear {
                // Register keyboard shortcuts
                keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                    return self.handleKeyPress(event: event)
                }
            }
            .onDisappear {
                // Remove keyboard monitor when view disappears
                if let monitor = keyMonitor {
                    NSEvent.removeMonitor(monitor)
                    keyMonitor = nil
                }
            }
            .onChange(of: configManager.showSettings) { newValue in
                // When settings is requested from outside (like popover), open the panel
                if newValue {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showSettings = true
                    }
                    // Reset the flag
                    DispatchQueue.main.async {
                        configManager.showSettings = false
                    }
                }
            }
        }

    // MARK: - Keyboard Shortcuts
    private func handleKeyPress(event: NSEvent) -> NSEvent? {
        let modifiers = event.modifierFlags
        let isCmd = modifiers.contains(.command)

        // Cmd+K : Command Bar
        if isCmd && event.charactersIgnoringModifiers == "k" {
            withAnimation(.easeOut(duration: 0.2)) {
                showCommandBar.toggle()
            }
            return nil
        }

        // Cmd+, : Settings
        if isCmd && event.charactersIgnoringModifiers == "," {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showSettings.toggle()
            }
            return nil
        }

        // Cmd+N : Network Monitor
        if isCmd && event.charactersIgnoringModifiers == "n" {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showNetworkMonitor.toggle()
            }
            return nil
        }

        // Esc : Close panels
        if event.keyCode == 53 { // Escape key
            if showCommandBar {
                withAnimation(.easeOut(duration: 0.2)) {
                    showCommandBar = false
                }
                return nil
            }
            if showSettings || showNetworkMonitor {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showSettings = false
                    showNetworkMonitor = false
                }
                return nil
            }
        }

        return event
    }

    // MARK: - Command Handler
    private func handleCommand(_ command: SamaritanCommand) {
        switch command.action {
        case .openSettings:
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showSettings = true
            }

        case .openNetworkMonitor:
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showNetworkMonitor = true
            }

        case .switchTheme(let themeName):
            configManager.config.theme = themeName
            configManager.applyTheme()

        case .toggleViewMode:
            configManager.config.viewMode = configManager.config.viewMode == .simple ? .advanced : .simple

        case .toggleAtlasMode:
            configManager.config.atlasMode.toggle()

        case .quitApp:
            NSApplication.shared.terminate(nil)

        case .viewCPU, .viewMemory, .viewDisk, .viewNetwork, .viewBattery, .viewProcesses, .viewTemperature:
            // These would scroll to specific sections or focus them
            // For now, just ensure we're in advanced mode to see all metrics
            if configManager.config.viewMode == .simple {
                configManager.config.viewMode = .advanced
            }
        }
    }
}

// MARK: - Network Monitor Panel
struct NetworkMonitorPanel: View {
    @Binding var isShowing: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: Color.isSamaritanMode ? "bolt.horizontal" : "network")
                    .font(Font.samaritanHeader(size: 20))
                    .foregroundStyle(
                        Color.isSamaritanMode ?
                            LinearGradient(
                                colors: [.samaritanOrange, .samaritanAmber],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [.vibrantPurple, .vibrantPink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
                    .samaritanGlow(color: .samaritanOrange)

                Text(Color.isSamaritanMode ? ">>> NETWORK ANALYSIS <<<" : "Network Monitor")
                    .font(Font.samaritanHeader(size: 22))
                    .foregroundColor(Color.isSamaritanMode ? .samaritanText : .primary)
                    .samaritanSpacing()

                Spacer()

                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isShowing = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary.opacity(0.6))
                }
                .buttonStyle(.plain)
                .help("Close")
            }
            .padding()
            .background(Color.darkCard)

            Divider()

            // Network Manager Content
            NetworkManagerView()
                .environmentObject(configManager)
        }
        .background(
            Color.darkBackground
                .shadow(color: .black.opacity(0.3), radius: 20, x: -5, y: 0)
        )
    }
}

// MARK: - System Monitor Column
struct SystemMonitorColumn: View {
    @ObservedObject var monitor: SystemMonitor
    @ObservedObject var configManager: ConfigManager
    @ObservedObject var alertManager: AlertManager
    @Binding var showSettings: Bool
    @Binding var showNetworkMonitor: Bool

    @State private var draggedMetric: MetricSection?
    @State private var isReorderMode: Bool = false
    @State private var showSystemInfo: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Header with title and buttons
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: Color.isSamaritanMode ? "terminal" : "chart.xyaxis.line")
                        .font(Font.samaritanHeader(size: 16))
                        .foregroundStyle(
                            Color.isSamaritanMode ?
                                LinearGradient(
                                    colors: [.samaritanRed, .samaritanOrange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [.vibrantBlue, .vibrantCyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                        )
                        .samaritanGlow(color: .samaritanRed)

                    Text(Color.isSamaritanMode ? ">>> SYSTEM MONITOR <<<" : "System Monitor")
                        .font(Font.samaritanHeader(size: 17))
                        .foregroundColor(Color.isSamaritanMode ? .samaritanText : .primary)
                        .samaritanSpacing()
                }

                Spacer()

                // Mode toggle with modern style
                HStack(spacing: 4) {
                    Button(action: {
                        configManager.config.viewMode = .simple
                    }) {
                        Text("Simple")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(configManager.config.viewMode == .simple ? .white : .blue)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .frame(minWidth: 58)
                            .background(
                                configManager.config.viewMode == .simple ?
                                    LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing) :
                                    LinearGradient(colors: [.clear], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(6)
                            .fixedSize()
                    }
                    .buttonStyle(.plain)

                    Button(action: {
                        configManager.config.viewMode = .advanced
                    }) {
                        Text("Advanced")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(configManager.config.viewMode == .advanced ? .white : .blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .frame(minWidth: 70)
                            .background(
                                configManager.config.viewMode == .advanced ?
                                    LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing) :
                                    LinearGradient(colors: [.clear], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(6)
                            .fixedSize()
                    }
                    .buttonStyle(.plain)
                }
                .padding(4)
                .background(Color.darkBackground)
                .cornerRadius(8)
                .fixedSize()

                // System Info Button
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showSystemInfo.toggle()
                    }
                }) {
                    Image(systemName: showSystemInfo ? "info.circle.fill" : "info.circle")
                        .font(Font.samaritanBody(size: 14))
                        .foregroundStyle(
                            Color.isSamaritanMode ?
                                (showSystemInfo ?
                                    LinearGradient(colors: [.samaritanRed, .samaritanOrange], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                    LinearGradient(colors: [.samaritanTextSecondary], startPoint: .topLeading, endPoint: .bottomTrailing)
                                ) :
                                (showSystemInfo ?
                                    LinearGradient(colors: [.vibrantGreen, .vibrantMint], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                    LinearGradient(colors: [.secondary], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                        )
                        .frame(width: 32, height: 32)
                        .background(showSystemInfo ? (Color.isSamaritanMode ? Color.samaritanBorder.opacity(0.2) : Color.green.opacity(0.1)) : Color.clear)
                        .samaritanCorners(8)
                        .samaritanGlow(color: .samaritanRed)
                }
                .buttonStyle(.plain)
                .help("System Information")

                // Network Monitor Button
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showNetworkMonitor.toggle()
                    }
                }) {
                    Image(systemName: "network")
                        .font(Font.samaritanBody(size: 14))
                        .foregroundStyle(
                            Color.isSamaritanMode ?
                                LinearGradient(
                                    colors: [.samaritanOrange, .samaritanAmber],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [.vibrantPurple, .vibrantPink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                        )
                        .frame(width: 32, height: 32)
                        .background(showNetworkMonitor ? (Color.isSamaritanMode ? Color.samaritanBorder.opacity(0.2) : Color.purple.opacity(0.1)) : Color.clear)
                        .samaritanCorners(8)
                        .samaritanGlow(color: .samaritanOrange)
                }
                .buttonStyle(.plain)
                .help("Network Monitor")

                // Settings Button
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showSettings.toggle()
                    }
                }) {
                    Image(systemName: showSettings ? "gearshape.fill" : "gearshape")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(
                            showSettings ?
                                LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                LinearGradient(colors: [.secondary], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 32, height: 32)
                        .background(showSettings ? Color.blue.opacity(0.1) : Color.clear)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .help("Settings")
            }
            .padding()
            .background(Color.darkCard)

            ZStack(alignment: .trailing) {
                ScrollView {
                    VStack(spacing: 12) {
                        if configManager.config.viewMode == .simple {
                            // Simple mode - just status cards
                            simpleMonitorView
                        } else {
                            // Advanced mode - detailed metrics with graphs
                            advancedMonitorView
                        }
                    }
                    .padding(10)
                }
                .background(Color.darkBackground)
                .blur(radius: showSystemInfo ? 3 : 0)
                .disabled(showSystemInfo)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // System Info Panel Overlay
                if showSystemInfo {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                showSystemInfo = false
                            }
                        }
                        .transition(.opacity)
                        .zIndex(0)

                    SystemInfoPanel(monitor: monitor, isShowing: $showSystemInfo)
                        .frame(width: 350)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                        .zIndex(1)
                }
            }
        }
        .background(Color.darkBackground)
    }

    // Simple mode view
    var simpleMonitorView: some View {
        VStack(spacing: 8) {
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

            // Battery Status (if available)
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

    // Advanced mode view
    var advancedMonitorView: some View {
        VStack(spacing: 12) {
            // Reorder mode toggle
            HStack {
                Text(isReorderMode ? "Drag to Reorder" : "Advanced View")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)

                Spacer()

                Button(action: {
                    withAnimation {
                        isReorderMode.toggle()
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: isReorderMode ? "checkmark" : "arrow.up.arrow.down")
                        Text(isReorderMode ? "Done" : "Reorder")
                    }
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        LinearGradient(
                            colors: isReorderMode ? [.green, .mint] : [.blue, .cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(6)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help(isReorderMode ? "Done Reordering" : "Reorder Metrics")
            }
            .padding(.horizontal, 8)

            // Modular metric blocks
            ForEach(configManager.config.sectionOrder.filter { $0 != .privacy && $0 != .fan }) { section in
                if section == .battery && monitor.batteryLevel < 0 {
                    EmptyView()
                } else {
                    ModularMetricBlock(
                        section: section,
                        monitor: monitor,
                        configManager: configManager,
                        draggedItem: $draggedMetric,
                        isReorderMode: isReorderMode
                    )
                }
            }
        }
    }

    // Legacy view kept for reference - can be removed
    var advancedMonitorViewOld: some View {
        VStack(spacing: 16) {
                    // CPU Section with Graph
                    SystemMetricCard(
                        title: "Processor",
                        icon: "cpu",
                        value: String(format: "%.1f%%", monitor.cpuUsage),
                        color: colorForPercentage(monitor.cpuUsage)
                    ) {
                        RealtimeGraphView(
                            dataPoints: monitor.cpuHistory,
                            color: .blue,
                            maxValue: 100
                        )
                        .frame(height: 80)
                    }

                    // Memory Section with Graph
                    SystemMetricCard(
                        title: "Memory",
                        icon: "memorychip",
                        value: String(format: "%.1f%%", monitor.memoryUsage),
                        color: colorForPercentage(monitor.memoryUsage)
                    ) {
                        RealtimeGraphView(
                            dataPoints: monitor.memoryHistory,
                            color: .green,
                            maxValue: 100
                        )
                        .frame(height: 80)

                        VStack(spacing: 4) {
                            MetricDetailRow(label: "Used", value: formatBytes(monitor.memoryUsed))
                            MetricDetailRow(label: "Free", value: formatBytes(monitor.memoryFree))
                            MetricDetailRow(label: "Cached", value: formatBytes(monitor.memoryCached))
                        }
                        .padding(.top, 8)
                    }

                    // Network Section with Graph
                    SystemMetricCard(
                        title: "Network",
                        icon: "network",
                        value: formatNetworkTotal(),
                        color: .blue
                    ) {
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

                    // Disk Section
                    SystemMetricCard(
                        title: "Storage",
                        icon: "internaldrive",
                        value: String(format: "%.1f%%", monitor.diskUsage),
                        color: colorForPercentage(monitor.diskUsage)
                    ) {
                        VStack(spacing: 4) {
                            let used = monitor.diskTotal - monitor.diskFree
                            MetricDetailRow(label: "Used", value: formatBytes(used))
                            MetricDetailRow(label: "Free", value: formatBytes(monitor.diskFree))
                            MetricDetailRow(label: "Total", value: formatBytes(monitor.diskTotal))
                        }
                    }

                    // Temperature Section
                    SystemMetricCard(
                        title: "Temperature",
                        icon: "thermometer.medium",
                        value: monitor.cpuTemperature,
                        color: temperatureColor(monitor.cpuTemperature)
                    ) {
                        HStack(spacing: 16) {
                            TemperatureGauge(temperature: monitor.cpuTemperature.extractTemperature())
                                .frame(width: 120, height: 120)

                            VStack(spacing: 4) {
                                MetricDetailRow(label: "CPU", value: monitor.cpuTemperature)
                                MetricDetailRow(label: "Disk", value: monitor.diskTemperature)
                                if monitor.batteryLevel >= 0 {
                                    MetricDetailRow(label: "Battery", value: monitor.batteryTemperature)
                                }
                            }
                        }
                    }

                    // Fan Section
                    SystemMetricCard(
                        title: "Fans",
                        icon: "fan",
                        value: monitor.fanSpeed,
                        color: .cyan
                    ) {
                        HStack(spacing: 16) {
                            FanSpeedGauge(rpm: monitor.fanSpeed.extractRPM())
                                .frame(width: 120, height: 120)

                            VStack(spacing: 4) {
                                MetricDetailRow(label: "Fan Speed", value: monitor.fanSpeed)
                                MetricDetailRow(label: "Status", value: monitor.fanSpeed != "N/A" ? "Active" : "Inactive")
                            }
                        }
                    }

                    // Battery Section (if available)
                    if monitor.batteryLevel >= 0 {
                        SystemMetricCard(
                            title: "Battery",
                            icon: batteryIcon(),
                            value: String(format: "%.0f%%", Double(monitor.batteryLevel)),
                            color: batteryColor()
                        ) {
                            VStack(spacing: 4) {
                                MetricDetailRow(label: "Status", value: monitor.isCharging ? "Charging" : "On Battery")
                                MetricDetailRow(label: "Health", value: String(format: "%.0f%%", monitor.batteryHealth))
                                MetricDetailRow(label: "Cycles", value: "\(monitor.batteryCycles)")
                            }
                        }
                    }
        }
    }

    private func colorForPercentage(_ percentage: Double) -> Color {
        if Color.isSamaritanMode {
            switch percentage {
            case 0..<40: return .samaritanGreen
            case 40..<70: return .samaritanAmber
            case 70..<90: return .samaritanOrange
            default: return .samaritanRed
            }
        } else {
            switch percentage {
            case 0..<40: return .vibrantGreen
            case 40..<70: return .vibrantYellow
            case 70..<90: return .vibrantOrange
            default: return .vibrantRed
            }
        }
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

    private func statusText(for percentage: Double) -> String {
        switch percentage {
        case 0..<40: return "Good"
        case 40..<70: return "Moderate"
        case 70..<90: return "High"
        default: return "Critical"
        }
    }

    private func networkStatus() -> String {
        let total = monitor.networkDownload + monitor.networkUpload
        if total < 1024 * 10 { return "Idle" }
        if total < 1024 * 1024 { return "Active" }
        return "Heavy Use"
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

    private func batteryStatusText() -> String {
        if monitor.batteryLevel > 80 { return "Excellent" }
        if monitor.batteryLevel > 50 { return "Good" }
        if monitor.batteryLevel > 20 { return "Low" }
        return "Critical"
    }

    private func formatNetworkTotal() -> String {
        let total = monitor.networkDownload + monitor.networkUpload
        return formatBytes(total) + "/s"
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

    private func batteryColor() -> Color {
        if Color.isSamaritanMode {
            if monitor.isCharging { return .samaritanGreen }
            if monitor.batteryLevel > 50 { return .samaritanGreen }
            if monitor.batteryLevel > 20 { return .samaritanAmber }
            return .samaritanRed
        } else {
            if monitor.isCharging { return .vibrantGreen }
            if monitor.batteryLevel > 50 { return .vibrantGreen }
            if monitor.batteryLevel > 20 { return .vibrantYellow }
            return .vibrantRed
        }
    }

    private func temperatureColor(_ temp: String) -> Color {
        // Extract numeric value from temperature string (e.g., "45°C" -> 45)
        let numericString = temp.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        guard let tempValue = Double(numericString) else {
            return Color.isSamaritanMode ? .samaritanTextSecondary : .vibrantBlue
        }

        // Color based on temperature (assuming Celsius)
        if Color.isSamaritanMode {
            switch tempValue {
            case 0..<50: return .samaritanGreen
            case 50..<70: return .samaritanAmber
            case 70..<85: return .samaritanOrange
            default: return .samaritanRed
            }
        } else {
            switch tempValue {
            case 0..<50: return .vibrantGreen
            case 50..<70: return .vibrantYellow
            case 70..<85: return .vibrantOrange
            default: return .vibrantRed
            }
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

// MARK: - Task Manager Column
struct TaskManagerColumn: View {
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var configManager: ConfigManager

    @State private var selectedFilter: TaskFilter = .all

    enum TaskFilter {
        case all, highCPU, highMemory, myApps, systemApps
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with title and filters
            HStack {
                // Title
                HStack(spacing: 8) {
                    Image(systemName: Color.isSamaritanMode ? "command" : "list.bullet.rectangle")
                        .font(Font.samaritanHeader(size: 16))
                        .foregroundStyle(
                            Color.isSamaritanMode ?
                                LinearGradient(
                                    colors: [.samaritanRed, .samaritanOrange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [.vibrantGreen, .vibrantMint],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                        )
                        .samaritanGlow(color: .samaritanRed)

                    Text(Color.isSamaritanMode ? ">>> PROCESS MANAGER <<<" : "Task Manager")
                        .font(Font.samaritanHeader(size: 17))
                        .foregroundColor(Color.isSamaritanMode ? .samaritanText : .primary)
                        .samaritanSpacing()
                }

                Spacer()

                // Refresh Button
                Button(action: {
                    taskManager.updateProcessList()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(Font.samaritanBody(size: 14))
                        .foregroundStyle(
                            Color.isSamaritanMode ?
                                LinearGradient(
                                    colors: [.samaritanRed, .samaritanOrange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [.vibrantGreen, .vibrantMint],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                        )
                        .frame(width: 32, height: 32)
                        .background(Color.isSamaritanMode ? Color.samaritanBorder.opacity(0.2) : Color.clear)
                        .samaritanCorners(8)
                        .samaritanGlow(color: .samaritanRed)
                }
                .buttonStyle(.plain)
                .help("Refresh Process List")
            }
            .padding()
            .background(Color.darkCard)

            // Filters (only in advanced mode)
            if configManager.config.viewMode == .advanced {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterButton(title: "All", icon: "square.grid.2x2", isSelected: selectedFilter == .all) {
                            selectedFilter = .all
                        }
                        FilterButton(title: "High CPU", icon: "cpu", isSelected: selectedFilter == .highCPU) {
                            selectedFilter = .highCPU
                        }
                        FilterButton(title: "High Memory", icon: "memorychip", isSelected: selectedFilter == .highMemory) {
                            selectedFilter = .highMemory
                        }
                        FilterButton(title: "My Apps", icon: "person.fill", isSelected: selectedFilter == .myApps) {
                            selectedFilter = .myApps
                        }
                        FilterButton(title: "System", icon: "gear", isSelected: selectedFilter == .systemApps) {
                            selectedFilter = .systemApps
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
            }

            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search processes...", text: $taskManager.searchText)
                    .textFieldStyle(.plain)

                if !taskManager.searchText.isEmpty {
                    Button(action: {
                        taskManager.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(Color.darkCard.opacity(0.5))
            .cornerRadius(8)
            .padding(.horizontal)
            .padding(.vertical, 8)

            // Process list based on mode
            if configManager.config.viewMode == .simple {
                SimpleProcessList(taskManager: taskManager, filter: selectedFilter)
            } else {
                AdvancedProcessList(taskManager: taskManager, filter: selectedFilter)
            }
        }
        .background(Color.darkBackground)
    }
}

// MARK: - Simple Process List
struct SimpleProcessList: View {
    @ObservedObject var taskManager: TaskManager
    let filter: TaskManagerColumn.TaskFilter

    var body: some View {
        VStack(spacing: 0) {
            // Process count
            HStack {
                Text("\(filteredProcesses.count) processes")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(filteredProcesses) { process in
                        SimpleProcessRow(process: process, taskManager: taskManager)
                        Divider()
                    }
                }
            }
        }
    }

    private var filteredProcesses: [ProcessData] {
        var processes = taskManager.filteredProcesses

        // Apply filter
        switch filter {
        case .all:
            break
        case .highCPU:
            processes = processes.filter { $0.cpuUsage > 50 }
        case .highMemory:
            processes = processes.filter { $0.memoryMB > 500 }
        case .myApps:
            processes = processes.filter { $0.path.hasPrefix("/Applications/") }
        case .systemApps:
            processes = processes.filter { $0.path.contains("/System/") }
        }

        // Only show user apps in simple mode
        return processes.filter { process in
            let isUserApp = process.path.hasPrefix("/Applications/") && process.path.contains(".app/")
            let isSystemApp = (process.path.contains("/System/Applications/") ||
                              process.path.contains("/System/Volumes/Preboot/Cryptexes/App/System/Applications/")) &&
                              process.path.contains(".app/")

            guard isUserApp || isSystemApp else { return false }

            let name = process.name.lowercased()
            let excludedPatterns = ["helper", "plugin", "renderer", "gpu", "agent", "daemon", "service", "broker", "webcontent", "networking"]

            for pattern in excludedPatterns {
                if name.contains(pattern) { return false }
            }

            if process.path.contains(".xpc/") || process.path.contains(".appex/") || process.path.contains(".widget/") {
                return false
            }

            return true
        }
    }
}

struct SimpleProcessRow: View {
    let process: ProcessData
    @ObservedObject var taskManager: TaskManager

    @State private var appIcon: NSImage?
    @State private var showingAlert = false

    var body: some View {
        HStack(spacing: 12) {
            if let icon = appIcon {
                Image(nsImage: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 36, height: 36)
                    .cornerRadius(6)
            } else {
                Image(systemName: "app")
                    .font(.system(size: 20))
                    .foregroundColor(.gray)
                    .frame(width: 36, height: 36)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(process.name)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)

                HStack(spacing: 12) {
                    Label(String(format: "%.1f%%", process.cpuUsage), systemImage: "cpu")
                        .foregroundColor(process.cpuUsage > 50 ? .red : .secondary)
                    Label(String(format: "%.0f MB", process.memoryMB), systemImage: "memorychip")
                        .foregroundColor(process.memoryMB > 500 ? .red : .secondary)
                }
                .font(.system(size: 11))
            }

            Spacer()

            Button(action: {
                let _ = taskManager.killProcess(pid: process.pid)
                showingAlert = true
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "xmark.circle.fill")
                    Text("Close")
                }
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.red)
                .cornerRadius(5)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .onAppear {
            loadAppIcon()
        }
    }

    private func loadAppIcon() {
        if let range = process.path.range(of: ".app/") {
            let bundlePath = String(process.path[..<range.upperBound].dropLast(1))
            appIcon = NSWorkspace.shared.icon(forFile: bundlePath)
        } else if process.path.hasSuffix(".app") {
            appIcon = NSWorkspace.shared.icon(forFile: process.path)
        }
    }
}

// MARK: - Advanced Process List
struct AdvancedProcessList: View {
    @ObservedObject var taskManager: TaskManager
    let filter: TaskManagerColumn.TaskFilter

    @State private var selectedProcess: ProcessData?

    var body: some View {
        VStack(spacing: 0) {
            // System summary - sleeker horizontal design
            HStack(spacing: 20) {
                HStack(spacing: 6) {
                    Text("Total CPU")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f%%", taskManager.totalCPU))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.blue)
                }

                Divider().frame(height: 16)

                HStack(spacing: 6) {
                    Text("Total Memory")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text(String(format: "%.0f MB", taskManager.totalMemory))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.green)
                }

                Spacer()

                HStack(spacing: 6) {
                    Text("Processes")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text("\(filteredProcesses.count)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.purple)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color.clear)

            // Column headers
            HStack(spacing: 12) {
                Button(action: { taskManager.sortProcesses(by: .name) }) {
                    HStack {
                        Text("Name")
                        if taskManager.sortBy == .name {
                            Image(systemName: "chevron.down")
                        }
                    }
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(taskManager.sortBy == .name ? .blue : .primary)
                }
                .buttonStyle(.plain)
                .frame(width: 150, alignment: .leading)

                Spacer()

                Button(action: { taskManager.sortProcesses(by: .cpu) }) {
                    HStack {
                        Text("CPU")
                        if taskManager.sortBy == .cpu {
                            Image(systemName: "chevron.down")
                        }
                    }
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(taskManager.sortBy == .cpu ? .blue : .primary)
                }
                .buttonStyle(.plain)
                .frame(width: 70, alignment: .trailing)

                Button(action: { taskManager.sortProcesses(by: .memory) }) {
                    HStack {
                        Text("Memory")
                        if taskManager.sortBy == .memory {
                            Image(systemName: "chevron.down")
                        }
                    }
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(taskManager.sortBy == .memory ? .blue : .primary)
                }
                .buttonStyle(.plain)
                .frame(width: 70, alignment: .trailing)

                Text("Actions")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.gray)
                    .frame(width: 60, alignment: .center)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.darkCard.opacity(0.5))

            Divider()

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(filteredProcesses) { process in
                        AdvancedProcessRow(
                            process: process,
                            isSelected: selectedProcess?.pid == process.pid,
                            taskManager: taskManager
                        )
                        .onTapGesture {
                            selectedProcess = process
                        }
                        Divider()
                    }
                }
            }
        }
    }

    private var filteredProcesses: [ProcessData] {
        var processes = taskManager.filteredProcesses

        switch filter {
        case .all:
            break
        case .highCPU:
            processes = processes.filter { $0.cpuUsage > 50 }
        case .highMemory:
            processes = processes.filter { $0.memoryMB > 500 }
        case .myApps:
            processes = processes.filter { $0.path.hasPrefix("/Applications/") }
        case .systemApps:
            processes = processes.filter { $0.path.contains("/System/") }
        }

        return processes
    }
}

struct AdvancedProcessRow: View {
    let process: ProcessData
    let isSelected: Bool
    @ObservedObject var taskManager: TaskManager

    @State private var appIcon: NSImage?
    @State private var showingKillConfirmation = false

    var body: some View {
        HStack(spacing: 12) {
            if let icon = appIcon {
                Image(nsImage: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
            } else {
                Image(systemName: "app")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .frame(width: 20, height: 20)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(process.name)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)
                Text("PID: \(process.pid)")
                    .font(.system(size: 9))
                    .foregroundColor(.gray)
            }
            .frame(width: 120, alignment: .leading)

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.1f%%", process.cpuUsage))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(cpuColor(for: process.cpuUsage))
                ProgressView(value: min(process.cpuUsage, 100), total: 100)
                    .progressViewStyle(.linear)
                    .tint(cpuColor(for: process.cpuUsage))
                    .frame(width: 50)
            }
            .frame(width: 70)

            VStack(alignment: .trailing, spacing: 2) {
                Text(formatMemory(process.memoryMB))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(memoryColor(for: process.memoryMB))
                ProgressView(value: min(process.memoryMB, 1000), total: 1000)
                    .progressViewStyle(.linear)
                    .tint(memoryColor(for: process.memoryMB))
                    .frame(width: 50)
            }
            .frame(width: 70)

            HStack(spacing: 6) {
                Button(action: {
                    let _ = taskManager.restartProcess(process: process)
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 10))
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                .help("Restart")

                Button(action: {
                    showingKillConfirmation = true
                }) {
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 10))
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                .help("Kill Process")
            }
            .frame(width: 60)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
        .alert("Kill Process?", isPresented: $showingKillConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Kill", role: .destructive) {
                let _ = taskManager.killProcess(pid: process.pid)
            }
        } message: {
            Text("Are you sure you want to kill '\(process.name)' (PID: \(process.pid))?")
        }
        .onAppear {
            loadAppIcon()
        }
    }

    private func loadAppIcon() {
        if let range = process.path.range(of: ".app/") {
            let bundlePath = String(process.path[..<range.upperBound].dropLast(1))
            appIcon = NSWorkspace.shared.icon(forFile: bundlePath)
        } else if process.path.hasSuffix(".app") {
            appIcon = NSWorkspace.shared.icon(forFile: process.path)
        }
    }

    private func cpuColor(for usage: Double) -> Color {
        if Color.isSamaritanMode {
            if usage > 50 { return .samaritanRed }
            if usage > 25 { return .samaritanOrange }
            return .samaritanGreen
        } else {
            if usage > 50 { return .vibrantRed }
            if usage > 25 { return .vibrantOrange }
            return .vibrantGreen
        }
    }

    private func memoryColor(for mb: Double) -> Color {
        if Color.isSamaritanMode {
            if mb > 500 { return .samaritanRed }
            if mb > 200 { return .samaritanOrange }
            return .samaritanGreen
        } else {
            if mb > 500 { return .vibrantRed }
            if mb > 200 { return .vibrantOrange }
            return .vibrantGreen
        }
    }

    private func formatMemory(_ mb: Double) -> String {
        if mb > 1024 {
            return String(format: "%.1f GB", mb / 1024.0)
        }
        return String(format: "%.0f MB", mb)
    }
}

// MARK: - Supporting Views
struct SystemMetricCard<Content: View>: View {
    let title: String
    let icon: String
    let value: String
    let color: Color
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)

                Text(title)
                    .font(.system(size: 16, weight: .semibold))

                Spacer()

                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(color)
            }

            content
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.darkCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct MetricDetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(Color.isSamaritanMode ? label.uppercased() : label)
                .font(Font.samaritanCaption(size: 11))
                .foregroundColor(Color.isSamaritanMode ? .samaritanTextSecondary : .secondary)
                .samaritanSpacing()
            Spacer()
            Text(value)
                .font(Font.samaritanBody(size: 11))
                .foregroundColor(Color.isSamaritanMode ? .samaritanText : .primary)
                .samaritanSpacing()
        }
    }
}

struct FilterButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                Text(title)
                    .font(.system(size: 11))
            }
            .foregroundColor(isSelected ? .white : .blue)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue : Color.blue.opacity(0.1))
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Realtime Graph View
struct RealtimeGraphView: View {
    let dataPoints: [Double]
    let color: Color
    let maxValue: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background grid
                Path { path in
                    for i in stride(from: 0, through: 4, by: 1) {
                        let y = geometry.size.height * CGFloat(i) / 4
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    }
                }
                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)

                // Data line
                Path { path in
                    guard !dataPoints.isEmpty else { return }

                    let stepX = geometry.size.width / CGFloat(max(dataPoints.count - 1, 1))

                    for (index, value) in dataPoints.enumerated() {
                        let x = CGFloat(index) * stepX
                        let normalizedValue = min(value, maxValue) / maxValue
                        let y = geometry.size.height * (1 - CGFloat(normalizedValue))

                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(color, lineWidth: 2)

                // Fill area under line
                Path { path in
                    guard !dataPoints.isEmpty else { return }

                    let stepX = geometry.size.width / CGFloat(max(dataPoints.count - 1, 1))

                    path.move(to: CGPoint(x: 0, y: geometry.size.height))

                    for (index, value) in dataPoints.enumerated() {
                        let x = CGFloat(index) * stepX
                        let normalizedValue = min(value, maxValue) / maxValue
                        let y = geometry.size.height * (1 - CGFloat(normalizedValue))
                        path.addLine(to: CGPoint(x: x, y: y))
                    }

                    let lastX = CGFloat(dataPoints.count - 1) * stepX
                    path.addLine(to: CGPoint(x: lastX, y: geometry.size.height))
                    path.closeSubpath()
                }
                .fill(LinearGradient(
                    gradient: Gradient(colors: [color.opacity(0.3), color.opacity(0.05)]),
                    startPoint: .top,
                    endPoint: .bottom
                ))
            }
        }
        .background(Color.black.opacity(0.02))
        .cornerRadius(8)
    }
}

// MARK: - Settings Panel
struct SettingsPanel: View {
    @ObservedObject var configManager: ConfigManager
    @ObservedObject var alertManager: AlertManager
    @Binding var isShowing: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("Settings")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)

                Spacer()

                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isShowing = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary.opacity(0.6))
                }
                .buttonStyle(.plain)
                .help("Close")
            }
            .padding()
            .background(
                VisualEffectBlur(material: .hudWindow, blendingMode: .behindWindow)
            )

            Divider()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    SettingsView(configManager: configManager, alertManager: alertManager)
                }
                .padding()
            }
        }
        .background(
            VisualEffectBlur(material: .hudWindow, blendingMode: .behindWindow)
        )
        .shadow(color: .black.opacity(0.3), radius: 20, x: -5, y: 0)
    }
}

// MARK: - System Info Panel
struct SystemInfoPanel: View {
    @ObservedObject var monitor: SystemMonitor
    @Binding var isShowing: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: Color.isSamaritanMode ? "cpu" : "desktopcomputer")
                    .font(Font.samaritanHeader(size: 20))
                    .foregroundStyle(
                        Color.isSamaritanMode ?
                            LinearGradient(
                                colors: [.samaritanRed, .samaritanOrange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [.vibrantGreen, .vibrantMint],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
                    .samaritanGlow(color: .samaritanRed)

                Text(Color.isSamaritanMode ? ">>> HARDWARE DATA <<<" : "System Information")
                    .font(Font.samaritanHeader(size: 22))
                    .foregroundColor(Color.isSamaritanMode ? .samaritanText : .primary)
                    .samaritanSpacing()

                Spacer()

                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isShowing = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary.opacity(0.6))
                }
                .buttonStyle(.plain)
                .help("Close")
            }
            .padding()
            .background(
                VisualEffectBlur(material: .hudWindow, blendingMode: .behindWindow)
            )

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    SystemInfoSection(title: "Hardware") {
                        SystemInfoRow(label: "Model", value: monitor.deviceModel)
                        SystemInfoRow(label: "Processor", value: monitor.cpuModel)
                        SystemInfoRow(label: "Cores", value: "\(monitor.cpuCores) cores")
                        SystemInfoRow(label: "Memory", value: String(format: "%.0f GB", monitor.totalMemoryGB))
                        SystemInfoRow(label: "Storage", value: String(format: "%.0f GB", monitor.totalStorageGB))
                        SystemInfoRow(label: "Display", value: monitor.displayResolution)
                    }

                    SystemInfoSection(title: "Software") {
                        SystemInfoRow(label: "macOS", value: monitor.macOSVersion)
                        SystemInfoRow(label: "Uptime", value: monitor.uptimeString)
                    }

                    SystemInfoSection(title: "Network") {
                        let networkMetrics = monitor.getDetailedNetworkMetrics()
                        SystemInfoRow(label: "Status", value: networkMetrics.connected ? "Connected" : "Disconnected")
                        if networkMetrics.connected {
                            SystemInfoRow(label: "Local IP", value: networkMetrics.localIP)
                        }
                    }

                    if monitor.batteryLevel >= 0 {
                        SystemInfoSection(title: "Battery") {
                            SystemInfoRow(label: "Level", value: "\(monitor.batteryLevel)%")
                            SystemInfoRow(label: "Health", value: "\(monitor.batteryHealth)%")
                            SystemInfoRow(label: "Cycles", value: "\(monitor.batteryCycles)")
                            if monitor.batteryCapacity != "N/A" && !monitor.batteryCapacity.isEmpty {
                                SystemInfoRow(label: "Capacity", value: monitor.batteryCapacity)
                            }
                            SystemInfoRow(label: "Status", value: monitor.isCharging ? "Charging" : "On Battery")
                        }
                    }
                }
                .padding()
            }
        }
        .background(
            VisualEffectBlur(material: .hudWindow, blendingMode: .behindWindow)
        )
        .cornerRadius(0)
        .shadow(color: .black.opacity(0.3), radius: 20, x: -5, y: 0)
    }
}

struct SystemInfoSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.primary)
                .textCase(.uppercase)

            VStack(alignment: .leading, spacing: 8) {
                content
            }
            .padding(12)
            .background(Color.darkCard.opacity(0.5))
            .cornerRadius(8)
        }
    }
}

struct SystemInfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }
}
