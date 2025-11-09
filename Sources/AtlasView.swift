import SwiftUI

// MARK: - Atlas Mode Main View
struct AtlasView: View {
    @ObservedObject var monitor: SystemMonitor
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var configManager: ConfigManager
    @StateObject private var networkMonitor = NetworkMonitor()

    @State private var showCommandBar: Bool = true
    @State private var selectedWidget: AtlasWidget? = nil
    @State private var keyMonitor: Any?

    // Accent color based on theme
    private var atlasAccentColor: Color {
        Color.isSamaritanMode ? .samaritanRed : .blue
    }

    private var atlasTextColor: Color {
        Color.isSamaritanMode ? .samaritanText : .primary
    }

    private var atlasSecondaryTextColor: Color {
        Color.isSamaritanMode ? .samaritanTextSecondary : .secondary
    }

    var body: some View {
        ZStack {
            // Background with grid
            Color.darkBackground
                .ignoresSafeArea()

            // Grid overlay
            GeometryReader { geometry in
                ZStack {
                    // Vertical lines
                    ForEach(0..<Int(geometry.size.width / 60), id: \.self) { i in
                        Rectangle()
                            .fill(atlasAccentColor.opacity(0.1))
                            .frame(width: 1)
                            .offset(x: CGFloat(i) * 60)
                    }

                    // Horizontal lines
                    ForEach(0..<Int(geometry.size.height / 60), id: \.self) { i in
                        Rectangle()
                            .fill(atlasAccentColor.opacity(0.1))
                            .frame(height: 1)
                            .offset(y: CGFloat(i) * 60)
                    }
                }
            }
            .allowsHitTesting(false)

            // Scanlines (only in Samaritan mode)
            if Color.isSamaritanMode {
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

            if selectedWidget == nil {
                // Centered command prompt (initial state)
                VStack(spacing: 40) {
                    // Atlas branding
                    VStack(spacing: 12) {
                        Text("ATLAS")
                            .font(.system(size: 72, weight: .bold, design: .monospaced))
                            .foregroundColor(atlasAccentColor)
                            .tracking(8)
                            .shadow(color: atlasAccentColor.opacity(0.5), radius: 20)

                        Text(Color.isSamaritanMode ? "SAMARITAN SYSTEM INTERFACE" : "System Interface")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(atlasSecondaryTextColor)
                            .tracking(Color.isSamaritanMode ? 4 : 2)
                    }

                    // Command prompt centered
                    if showCommandBar {
                        AtlasCommandPrompt(isShowing: $showCommandBar) { command in
                            handleCommand(command)
                        }
                        .frame(width: 700)
                    }

                    // Hint text
                    HStack(spacing: 12) {
                        KeyHintCompact(key: "⌘K", description: "Command Palette")
                        KeyHintCompact(key: "ESC", description: "Reset")
                    }
                    .opacity(0.6)
                }
            } else {
                // Widget view with top command bar
                VStack(spacing: 0) {
                    // Top command bar
                    HStack {
                        Spacer()

                        if showCommandBar {
                            AtlasCommandPrompt(isShowing: $showCommandBar) { command in
                                handleCommand(command)
                            }
                            .frame(width: 500)
                        } else {
                            // Collapsed command button
                            Button(action: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    showCommandBar = true
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "terminal")
                                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    Text("COMMAND PALETTE")
                                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                                        .tracking(1)
                                }
                                .foregroundColor(.samaritanRed)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color.black)
                                .overlay(
                                    Rectangle()
                                        .stroke(Color.samaritanBorder, lineWidth: 2)
                                )
                                .shadow(color: Color.samaritanRed.opacity(0.3), radius: 10)
                            }
                            .buttonStyle(.plain)
                        }

                        Spacer()
                    }
                    .padding(.vertical, 20)
                    .background(Color.black.opacity(0.8))
                    .overlay(
                        Rectangle()
                            .fill(Color.samaritanRed.opacity(0.3))
                            .frame(height: 1),
                        alignment: .bottom
                    )

                    // Widget area
                    ScrollView {
                        if let widget = selectedWidget {
                            AtlasWidgetView(widget: widget, monitor: monitor, taskManager: taskManager, networkMonitor: networkMonitor)
                                .padding(40)
                        }
                    }
                }
            }
        }
        .onAppear {
            setupKeyMonitor()
            networkMonitor.startMonitoring()
        }
        .onDisappear {
            if let monitor = keyMonitor {
                NSEvent.removeMonitor(monitor)
                keyMonitor = nil
            }
            networkMonitor.stopMonitoring()
        }
    }

    private func setupKeyMonitor() {
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let modifiers = event.modifierFlags
            let isCmd = modifiers.contains(.command)

            // Cmd+K: Toggle command bar
            if isCmd && event.charactersIgnoringModifiers == "k" {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    showCommandBar.toggle()
                }
                return nil
            }

            // Esc: Reset to initial state
            if event.keyCode == 53 {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    selectedWidget = nil
                    showCommandBar = true
                }
                return nil
            }

            return event
        }
    }

    // MARK: - Command Handler
    private func handleCommand(_ command: AtlasCommand) {
        switch command.action {
        case .widget(let widgetType):
            // Handle widget selection
            let widget = AtlasWidget(
                name: command.name,
                description: command.description,
                icon: command.icon,
                type: widgetType
            )
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                selectedWidget = widget
                showCommandBar = false
            }

        case .exitAtlas:
            // Exit Atlas Mode
            configManager.config.atlasMode = false

        case .settings:
            // Open settings (will be handled via configManager)
            configManager.showSettings = true

        case .switchTheme(let themeName):
            // Switch theme
            configManager.config.theme = themeName
            configManager.applyTheme()

        case .quit:
            // Quit application
            NSApplication.shared.terminate(nil)
        }
    }
}

// MARK: - Atlas Command Prompt
struct AtlasCommandPrompt: View {
    @Binding var isShowing: Bool
    @State private var searchText: String = ""
    @State private var selectedIndex: Int = 0
    @FocusState private var isTextFieldFocused: Bool
    @State private var keyMonitor: Any?

    let onCommandSelected: (AtlasCommand) -> Void

    // Theme-adaptive colors
    private var accentColor: Color {
        Color.isSamaritanMode ? .samaritanRed : .blue
    }

    private var textColor: Color {
        Color.isSamaritanMode ? .samaritanText : .primary
    }

    private var secondaryTextColor: Color {
        Color.isSamaritanMode ? .samaritanTextSecondary : .secondary
    }

    private var promptText: String {
        Color.isSamaritanMode ? "WHAT ARE YOUR COMMANDS?" : "Search commands..."
    }

    var filteredCommands: [AtlasCommand] {
        if searchText.isEmpty {
            return AtlasCommand.allCommands
        }
        return AtlasCommand.allCommands.filter { command in
            command.name.lowercased().contains(searchText.lowercased()) ||
            command.keywords.contains(where: { $0.lowercased().contains(searchText.lowercased()) })
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Command input
            HStack(spacing: 12) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(accentColor)

                TextField("", text: $searchText, prompt: Text(promptText).foregroundColor(secondaryTextColor.opacity(0.5)))
                    .font(.system(size: 18, weight: .medium, design: .monospaced))
                    .foregroundColor(textColor)
                    .textFieldStyle(.plain)
                    .focused($isTextFieldFocused)
                    .onSubmit {
                        executeSelectedCommand()
                    }
                    .onChange(of: searchText) { _ in
                        selectedIndex = 0
                    }
            }
            .padding(20)
            .background(Color.darkCard)
            .overlay(
                Rectangle()
                    .stroke(accentColor, lineWidth: 2)
            )

            // Command suggestions
            if !searchText.isEmpty && !filteredCommands.isEmpty {
                VStack(spacing: 1) {
                    ForEach(Array(filteredCommands.prefix(8).enumerated()), id: \.element.id) { index, command in
                        AtlasCommandRow(
                            command: command,
                            isSelected: index == selectedIndex
                        )
                        .onTapGesture {
                            selectedIndex = index
                            executeSelectedCommand()
                        }
                    }
                }
                .background(Color.darkCard)
                .overlay(
                    Rectangle()
                        .stroke(accentColor.opacity(0.5), lineWidth: 2)
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .shadow(color: accentColor.opacity(0.4), radius: 20)
        .onAppear {
            isTextFieldFocused = true
            setupKeyMonitor()
        }
        .onDisappear {
            if let monitor = keyMonitor {
                NSEvent.removeMonitor(monitor)
                keyMonitor = nil
            }
        }
    }

    private func setupKeyMonitor() {
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            // Up arrow
            if event.keyCode == 126 {
                selectedIndex = max(0, selectedIndex - 1)
                return nil
            }
            // Down arrow
            if event.keyCode == 125 {
                selectedIndex = min(filteredCommands.count - 1, selectedIndex + 1)
                return nil
            }
            return event
        }
    }

    private func executeSelectedCommand() {
        guard !filteredCommands.isEmpty else { return }
        let command = filteredCommands[selectedIndex]
        onCommandSelected(command)
        searchText = ""
        selectedIndex = 0
    }
}

// MARK: - Atlas Command Row
struct AtlasCommandRow: View {
    let command: AtlasCommand
    let isSelected: Bool

    // Theme-adaptive colors
    private var accentColor: Color {
        Color.isSamaritanMode ? .samaritanRed : .blue
    }

    private var highlightColor: Color {
        Color.isSamaritanMode ? .samaritanOrange : .cyan
    }

    private var textColor: Color {
        Color.isSamaritanMode ? .samaritanText : .primary
    }

    private var secondaryTextColor: Color {
        Color.isSamaritanMode ? .samaritanTextSecondary : .secondary
    }

    private var commandName: String {
        Color.isSamaritanMode ? command.name.uppercased() : command.name
    }

    private var commandDescription: String {
        Color.isSamaritanMode ? command.description.uppercased() : command.description
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: command.icon)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundColor(isSelected ? accentColor : highlightColor)
                .frame(width: 24)

            Text(commandName)
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundColor(isSelected ? textColor : secondaryTextColor)
                .tracking(Color.isSamaritanMode ? 1.0 : 0)

            Spacer()

            Text(commandDescription)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(secondaryTextColor.opacity(0.7))
                .tracking(Color.isSamaritanMode ? 0.5 : 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(isSelected ? accentColor.opacity(0.15) : Color.darkCard)
        .overlay(
            Rectangle()
                .fill(isSelected ? accentColor : .clear)
                .frame(width: 3),
            alignment: .leading
        )
    }
}

// MARK: - Key Hint Compact
struct KeyHintCompact: View {
    let key: String
    let description: String

    var body: some View {
        HStack(spacing: 6) {
            Text(key)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.samaritanRed)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.samaritanBorder.opacity(0.2))
                .cornerRadius(4)

            Text(description)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(.samaritanTextSecondary)
        }
    }
}

// MARK: - Atlas Command Model
struct AtlasCommand: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let icon: String
    let keywords: [String]
    let action: CommandAction

    enum CommandAction {
        case widget(WidgetType)
        case exitAtlas
        case settings
        case switchTheme(String)
        case quit
    }

    enum WidgetType {
        case network
        case cpu
        case memory
        case disk
        case processes
        case system
        case all
    }

    static let allCommands: [AtlasCommand] = [
        // Widget Commands
        AtlasCommand(
            name: "Network Monitor",
            description: "Traffic & Speed Analysis",
            icon: "network",
            keywords: ["network", "traffic", "bandwidth", "speed", "internet"],
            action: .widget(.network)
        ),
        AtlasCommand(
            name: "CPU Analytics",
            description: "Processor Metrics",
            icon: "cpu",
            keywords: ["cpu", "processor", "performance"],
            action: .widget(.cpu)
        ),
        AtlasCommand(
            name: "Memory Status",
            description: "RAM Usage & Pressure",
            icon: "memorychip",
            keywords: ["memory", "ram", "swap"],
            action: .widget(.memory)
        ),
        AtlasCommand(
            name: "Disk Analysis",
            description: "Storage Metrics",
            icon: "internaldrive",
            keywords: ["disk", "storage", "drive"],
            action: .widget(.disk)
        ),
        AtlasCommand(
            name: "Process Manager",
            description: "Running Applications",
            icon: "app.badge",
            keywords: ["processes", "apps", "tasks"],
            action: .widget(.processes)
        ),
        AtlasCommand(
            name: "System Overview",
            description: "Complete Metrics",
            icon: "gauge.medium",
            keywords: ["system", "overview", "complete"],
            action: .widget(.system)
        ),
        AtlasCommand(
            name: "All Metrics",
            description: "Everything At Once",
            icon: "square.grid.3x3",
            keywords: ["all", "everything", "full", "complete", "atlas"],
            action: .widget(.all)
        ),

        // System Commands
        AtlasCommand(
            name: "Exit Atlas Mode",
            description: "Return to Normal View",
            icon: "arrow.left.circle",
            keywords: ["exit", "leave", "return", "normal", "back"],
            action: .exitAtlas
        ),
        AtlasCommand(
            name: "Settings",
            description: "Open Settings Panel",
            icon: "gearshape",
            keywords: ["settings", "preferences", "config"],
            action: .settings
        ),
        AtlasCommand(
            name: "Theme: Samaritan",
            description: "Switch to Samaritan Theme",
            icon: "terminal",
            keywords: ["theme", "samaritan", "red"],
            action: .switchTheme("samaritan")
        ),
        AtlasCommand(
            name: "Theme: Dark",
            description: "Switch to Dark Theme",
            icon: "moon.fill",
            keywords: ["theme", "dark", "black"],
            action: .switchTheme("dark")
        ),
        AtlasCommand(
            name: "Theme: Light",
            description: "Switch to Light Theme",
            icon: "sun.max.fill",
            keywords: ["theme", "light", "white"],
            action: .switchTheme("light")
        ),
        AtlasCommand(
            name: "Theme: System",
            description: "Use System Theme",
            icon: "circle.lefthalf.filled",
            keywords: ["theme", "system", "auto"],
            action: .switchTheme("system")
        ),
        AtlasCommand(
            name: "Quit PeakView",
            description: "Exit Application",
            icon: "power",
            keywords: ["quit", "exit", "close", "terminate"],
            action: .quit
        ),
    ]
}

// MARK: - Atlas Widget (for backwards compatibility)
struct AtlasWidget: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let icon: String
    let type: AtlasCommand.WidgetType
}

// MARK: - Atlas Widget View
struct AtlasWidgetView: View {
    let widget: AtlasWidget
    @ObservedObject var monitor: SystemMonitor
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var networkMonitor: NetworkMonitor

    var body: some View {
        VStack(spacing: 0) {
            // Widget header
            HStack {
                Image(systemName: widget.icon)
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(.samaritanRed)

                VStack(alignment: .leading, spacing: 4) {
                    Text(widget.name.uppercased())
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(.samaritanText)
                        .tracking(2)

                    Text(widget.description.uppercased())
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(.samaritanTextSecondary)
                        .tracking(1)
                }

                Spacer()
            }
            .padding(30)
            .background(Color.black)
            .overlay(
                Rectangle()
                    .fill(Color.samaritanRed)
                    .frame(height: 3),
                alignment: .bottom
            )

            // Widget content
            widgetContent
                .padding(30)
        }
        .background(Color.black.opacity(0.6))
        .overlay(
            Rectangle()
                .stroke(Color.samaritanBorder, lineWidth: 2)
        )
    }

    @ViewBuilder
    private var widgetContent: some View {
        switch widget.type {
        case .network:
            networkContent
        case .cpu:
            cpuContent
        case .memory:
            memoryContent
        case .disk:
            diskContent
        case .processes:
            processesContent
        case .system:
            systemOverviewContent
        case .all:
            allMetricsContent
        }
    }

    // MARK: - Widget Content Views

    private var networkContent: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 30) {
            AtlasMetricCard(
                title: "Download Speed",
                value: formatBytes(monitor.networkDownload) + "/s",
                icon: "arrow.down.circle.fill",
                color: .samaritanGreen
            )

            AtlasMetricCard(
                title: "Upload Speed",
                value: formatBytes(monitor.networkUpload) + "/s",
                icon: "arrow.up.circle.fill",
                color: .samaritanOrange
            )

            AtlasMetricCard(
                title: "Total Traffic",
                value: formatBytes(monitor.networkDownload + monitor.networkUpload) + "/s",
                icon: "arrow.left.arrow.right.circle.fill",
                color: .samaritanRed
            )

            AtlasMetricCard(
                title: "Network Status",
                value: (monitor.networkDownload + monitor.networkUpload) > 1024 ? "ACTIVE" : "IDLE",
                icon: "wifi.circle.fill",
                color: .samaritanAmber
            )
        }
    }

    private var cpuContent: some View {
        VStack(spacing: 30) {
            // Large CPU percentage
            VStack(spacing: 12) {
                Text(String(format: "%.1f%%", monitor.cpuUsage))
                    .font(.system(size: 96, weight: .bold, design: .monospaced))
                    .foregroundColor(.samaritanRed)

                Text("CPU UTILIZATION")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.samaritanTextSecondary)
                    .tracking(2)
            }

            // CPU details grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                AtlasMetricCard(title: "Cores", value: "\(monitor.cpuCores)", icon: "cpu", color: .samaritanOrange)
                AtlasMetricCard(title: "Temperature", value: monitor.cpuTemperature, icon: "thermometer.medium", color: .samaritanRed)
                AtlasMetricCard(title: "Load Average", value: monitor.cpuLoadAverage, icon: "chart.line.uptrend.xyaxis", color: .samaritanAmber)
            }
        }
    }

    private var memoryContent: some View {
        VStack(spacing: 30) {
            // Large memory percentage
            VStack(spacing: 12) {
                Text(String(format: "%.1f%%", monitor.memoryUsage))
                    .font(.system(size: 96, weight: .bold, design: .monospaced))
                    .foregroundColor(.samaritanOrange)

                Text("MEMORY USAGE")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.samaritanTextSecondary)
                    .tracking(2)
            }

            // Memory details grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                AtlasMetricCard(title: "Used", value: formatBytes(monitor.memoryUsed), icon: "memorychip.fill", color: .samaritanRed)
                AtlasMetricCard(title: "Free", value: formatBytes(monitor.memoryFree), icon: "memorychip", color: .samaritanGreen)
                AtlasMetricCard(title: "Cached", value: formatBytes(monitor.memoryCached), icon: "internaldrive", color: .samaritanAmber)
            }
        }
    }

    private var diskContent: some View {
        VStack(spacing: 30) {
            // Large disk percentage
            VStack(spacing: 12) {
                Text(String(format: "%.1f%%", monitor.diskUsage))
                    .font(.system(size: 96, weight: .bold, design: .monospaced))
                    .foregroundColor(.samaritanAmber)

                Text("DISK USAGE")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.samaritanTextSecondary)
                    .tracking(2)
            }

            // Disk details grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                AtlasMetricCard(title: "Used Space", value: formatBytes(monitor.diskTotal - monitor.diskFree), icon: "internaldrive.fill", color: .samaritanRed)
                AtlasMetricCard(title: "Free Space", value: formatBytes(monitor.diskFree), icon: "internaldrive", color: .samaritanGreen)
            }
        }
    }

    private var processesContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("TOP PROCESSES")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.samaritanText)
                .tracking(2)

            VStack(spacing: 2) {
                ForEach(taskManager.processes.prefix(10)) { process in
                    HStack {
                        Text(process.name.uppercased())
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(.samaritanText)
                            .lineLimit(1)

                        Spacer()

                        Text(String(format: "%.1f%%", process.cpuUsage))
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.samaritanOrange)
                            .frame(width: 80, alignment: .trailing)

                        Text(String(format: "%.0f MB", process.memoryMB))
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.samaritanRed)
                            .frame(width: 100, alignment: .trailing)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.black.opacity(0.4))
                    .overlay(
                        Rectangle()
                            .fill(Color.samaritanBorder.opacity(0.3))
                            .frame(height: 1),
                        alignment: .bottom
                    )
                }
            }
        }
    }

    private var systemOverviewContent: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 30) {
            AtlasMetricCard(title: "CPU", value: String(format: "%.1f%%", monitor.cpuUsage), icon: "cpu", color: .samaritanRed)
            AtlasMetricCard(title: "Memory", value: String(format: "%.1f%%", monitor.memoryUsage), icon: "memorychip", color: .samaritanOrange)
            AtlasMetricCard(title: "Disk", value: String(format: "%.1f%%", monitor.diskUsage), icon: "internaldrive", color: .samaritanAmber)
            AtlasMetricCard(title: "Download", value: formatBytes(monitor.networkDownload) + "/s", icon: "arrow.down.circle", color: .samaritanGreen)
            AtlasMetricCard(title: "Upload", value: formatBytes(monitor.networkUpload) + "/s", icon: "arrow.up.circle", color: .samaritanOrange)
            AtlasMetricCard(title: "Temperature", value: monitor.cpuTemperature, icon: "thermometer.medium", color: .samaritanRed)
        }
    }

    private var allMetricsContent: some View {
        VStack(spacing: 16) {
            systemMonitorRow
            networkAndTaskRow
        }
        .padding(24)
    }

    private var systemMonitorRow: some View {
        HStack(spacing: 16) {
            CompactSystemCard(title: "CPU", value: String(format: "%.1f%%", monitor.cpuUsage), icon: "cpu", color: .samaritanRed)
            CompactSystemCard(title: "MEMORY", value: String(format: "%.1f%%", monitor.memoryUsage), icon: "memorychip", color: .samaritanOrange)
            CompactSystemCard(title: "DISK", value: String(format: "%.1f%%", monitor.diskUsage), icon: "internaldrive", color: .samaritanAmber)
            CompactSystemCard(title: "NETWORK", value: formatBytes(monitor.networkDownload + monitor.networkUpload) + "/s", icon: "network", color: .samaritanGreen)
        }
    }

    private var networkAndTaskRow: some View {
        HStack(spacing: 16) {
            networkAnalysisPanel
            taskManagerPanel
        }
    }

    private var networkAnalysisPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            networkAnalysisPanelHeader
            networkAnalysisTableHeader
            networkAnalysisConnectionsList
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.black.opacity(0.4))
        .overlay(
            Rectangle()
                .stroke(Color.samaritanBorder, lineWidth: 1)
        )
    }

    private var networkAnalysisPanelHeader: some View {
        HStack(spacing: 8) {
            Image(systemName: "network")
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundColor(.samaritanRed)
            Text("NETWORK ANALYSIS")
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundColor(.samaritanText)
                .tracking(1.5)
            Spacer()
            Text("\(self.networkMonitor.connections.filter { $0.state == .established }.count) ACTIVE")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.samaritanOrange)
        }
    }

    private var networkAnalysisTableHeader: some View {
        HStack(spacing: 8) {
            Text("PROCESS")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.samaritanTextSecondary)
                .frame(width: 120, alignment: .leading)

            Text("PROTOCOL")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.samaritanTextSecondary)
                .frame(width: 60, alignment: .leading)

            Text("REMOTE")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.samaritanTextSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("STATE")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.samaritanTextSecondary)
                .frame(width: 80, alignment: .trailing)

            Text("TRAFFIC")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.samaritanTextSecondary)
                .frame(width: 70, alignment: .trailing)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.black.opacity(0.5))
    }

    private var networkAnalysisConnectionsList: some View {
        ScrollView {
            VStack(spacing: 1) {
                ForEach(self.networkMonitor.connections.filter { $0.state == .established }.prefix(8)) { connection in
                    NetworkConnectionRow(connection: connection)
                }
            }
        }
        .frame(height: 200)
    }

    private var taskManagerPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "app.badge")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.samaritanRed)
                Text("TASK MANAGER")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.samaritanText)
                    .tracking(1.5)
                Spacer()
            }

            // Process table header
            HStack(spacing: 8) {
                Text("PROCESS")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.samaritanTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("CPU")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.samaritanTextSecondary)
                    .frame(width: 50, alignment: .trailing)

                Text("MEM")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.samaritanTextSecondary)
                    .frame(width: 60, alignment: .trailing)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.black.opacity(0.5))

            // Process list
            ScrollView {
                VStack(spacing: 1) {
                    ForEach(taskManager.processes.prefix(8)) { process in
                        AtlasProcessRow(process: process)
                    }
                }
            }
            .frame(height: 200)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.black.opacity(0.4))
        .overlay(
            Rectangle()
                .stroke(Color.samaritanBorder, lineWidth: 1)
        )
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

// MARK: - Atlas Metric Card
struct AtlasMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(color)

            VStack(spacing: 8) {
                Text(value)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(.samaritanText)

                Text(title.uppercased())
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.samaritanTextSecondary)
                    .tracking(1.5)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color.black.opacity(0.6))
        .overlay(
            Rectangle()
                .stroke(Color.samaritanBorder, lineWidth: 2)
        )
        .shadow(color: color.opacity(0.3), radius: 10)
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    let icon: String

    // Theme-adaptive colors
    private var accentColor: Color {
        Color.isSamaritanMode ? .samaritanRed : .blue
    }

    private var textColor: Color {
        Color.isSamaritanMode ? .samaritanText : .primary
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(accentColor)

            Text(title)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(textColor)
                .tracking(Color.isSamaritanMode ? 2 : 0)

            Spacer()
        }
    }
}

// MARK: - Large Metric Card
struct LargeMetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(color)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundColor(.samaritanText)

                Text(title)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.samaritanTextSecondary)
                    .tracking(1.5)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(subtitle.uppercased())
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(.samaritanTextSecondary.opacity(0.7))
                .tracking(0.5)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.black.opacity(0.5))
        .overlay(
            Rectangle()
                .stroke(color, lineWidth: 2)
        )
        .shadow(color: color.opacity(0.3), radius: 10)
    }
}

// MARK: - Status Row
struct StatusRow: View {
    let label: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 20)

            Text(label)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(.samaritanTextSecondary)
                .tracking(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(value)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.samaritanText)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.3))
        .overlay(
            Rectangle()
                .fill(Color.samaritanBorder.opacity(0.2))
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

// MARK: - Compact Metric Card
struct CompactMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(color)

            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(.samaritanText)

                Text(title.uppercased())
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.samaritanTextSecondary)
                    .tracking(1)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.black.opacity(0.4))
        .overlay(
            Rectangle()
                .stroke(Color.samaritanBorder, lineWidth: 1)
        )
        .shadow(color: color.opacity(0.2), radius: 8)
    }
}

// MARK: - Atlas Network Detail Row
struct AtlasNetworkDetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(.samaritanTextSecondary)
                .tracking(1)
            Spacer()
            Text(value)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.samaritanText)
        }
    }
}

// MARK: - Compact System Card
struct CompactSystemCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(.samaritanText)

                Text(title)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(.samaritanTextSecondary)
                    .tracking(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.black.opacity(0.5))
        .overlay(
            Rectangle()
                .stroke(color, lineWidth: 2)
        )
    }
}

// MARK: - Network Connection Row
struct NetworkConnectionRow: View {
    let connection: NetworkConnection

    var body: some View {
        HStack(spacing: 8) {
            Text(connection.processName.uppercased())
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(.samaritanText)
                .lineLimit(1)
                .frame(width: 120, alignment: .leading)

            Text(connection.networkProtocol.rawValue)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.samaritanAmber)
                .frame(width: 60, alignment: .leading)

            Text("\(connection.remoteAddress):\(connection.remotePort)")
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(.samaritanTextSecondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(connection.state.rawValue)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.samaritanGreen)
                .frame(width: 80, alignment: .trailing)

            Text(connection.totalTraffic)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.samaritanOrange)
                .frame(width: 70, alignment: .trailing)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.2))
        .overlay(
            Rectangle()
                .fill(Color.samaritanBorder.opacity(0.1))
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

// MARK: - Atlas Process Row
struct AtlasProcessRow: View {
    let process: ProcessData

    var body: some View {
        HStack(spacing: 8) {
            Text(process.name.uppercased())
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(.samaritanText)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(String(format: "%.1f%%", process.cpuUsage))
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.samaritanOrange)
                .frame(width: 50, alignment: .trailing)

            Text(String(format: "%.0f MB", process.memoryMB))
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.samaritanRed)
                .frame(width: 60, alignment: .trailing)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.2))
        .overlay(
            Rectangle()
                .fill(Color.samaritanBorder.opacity(0.1))
                .frame(height: 1),
            alignment: .bottom
        )
    }
}
