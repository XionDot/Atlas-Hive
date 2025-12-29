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

    // Theme-adaptive colors
    private var atlasAccentColor: Color {
        if Color.isSamaritanMode {
            return .samaritanRed
        }
        return Color.isSystemDark ? .vibrantBlue : .blue
    }

    private var atlasTextColor: Color {
        Color.isSamaritanMode ? .samaritanText : .primary
    }

    private var atlasSecondaryTextColor: Color {
        Color.isSamaritanMode ? .samaritanTextSecondary : .secondary
    }

    private var atlasBorderColor: Color {
        if Color.isSamaritanMode {
            return .samaritanBorder
        }
        return Color.isSystemDark ? Color.vibrantBlue.opacity(0.3) : Color.blue.opacity(0.3)
    }

    // Metric-specific colors
    private var cpuColor: Color {
        if Color.isSamaritanMode {
            return .samaritanRed
        }
        return Color.isSystemDark ? .vibrantBlue : .blue
    }

    private var memoryColor: Color {
        if Color.isSamaritanMode {
            return .samaritanOrange
        }
        return Color.isSystemDark ? .vibrantOrange : .orange
    }

    private var diskColor: Color {
        if Color.isSamaritanMode {
            return .samaritanAmber
        }
        return Color.isSystemDark ? .vibrantYellow : .yellow
    }

    private var networkColor: Color {
        if Color.isSamaritanMode {
            return .samaritanGreen
        }
        return Color.isSystemDark ? .vibrantGreen : .green
    }

    private var warningColor: Color {
        if Color.isSamaritanMode {
            return .samaritanOrange
        }
        return Color.isSystemDark ? .vibrantOrange : .orange
    }

    private var criticalColor: Color {
        if Color.isSamaritanMode {
            return .samaritanRed
        }
        return Color.isSystemDark ? .vibrantRed : .red
    }

    private var successColor: Color {
        if Color.isSamaritanMode {
            return .samaritanGreen
        }
        return Color.isSystemDark ? .vibrantGreen : .green
    }

    var body: some View {
        ZStack {
            // Background with grid
            Color.darkBackground
                .ignoresSafeArea()

            // Grid overlay
            Canvas { context, size in
                let gridSpacing: CGFloat = 60

                // Draw vertical lines
                var x: CGFloat = 0
                while x <= size.width {
                    let path = Path { path in
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                    }
                    context.stroke(path, with: .color(atlasAccentColor.opacity(0.1)), lineWidth: 1)
                    x += gridSpacing
                }

                // Draw horizontal lines
                var y: CGFloat = 0
                while y <= size.height {
                    let path = Path { path in
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                    }
                    context.stroke(path, with: .color(atlasAccentColor.opacity(0.1)), lineWidth: 1)
                    y += gridSpacing
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

                    // Command prompt
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
                // Widget view (no top bar)
                ZStack {
                    // Widget area (no scrolling - everything fits on screen)
                    if let widget = selectedWidget {
                        AtlasWidgetView(widget: widget, monitor: monitor, taskManager: taskManager, networkMonitor: networkMonitor)
                            .padding(30)
                    }

                    // Minimal icon for mouse access (bottom-right corner)
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    showCommandBar = true
                                }
                            }) {
                                Image(systemName: "command.circle.fill")
                                    .font(.system(size: 44, weight: .medium))
                                    .foregroundColor(atlasAccentColor.opacity(0.7))
                                    .background(
                                        Circle()
                                            .fill(Color.darkBackground.opacity(0.8))
                                            .frame(width: 50, height: 50)
                                    )
                                    .shadow(color: atlasAccentColor.opacity(0.3), radius: 10)
                            }
                            .buttonStyle(.plain)
                            .padding(30)
                        }
                    }

                    // Blurred overlay command palette
                    if showCommandBar {
                        ZStack {
                            // Blur backdrop
                            Color.black.opacity(0.7)
                                .blur(radius: 20)
                                .ignoresSafeArea()
                                .onTapGesture {
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        showCommandBar = false
                                    }
                                }

                            // Command prompt
                            AtlasCommandPrompt(isShowing: $showCommandBar) { command in
                                handleCommand(command)
                            }
                            .frame(width: 700)
                        }
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
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
        if Color.isSamaritanMode {
            return .samaritanRed
        }
        // Use vibrant colors for black af mode, standard for others
        return Color.isSystemDark ? .vibrantBlue : .blue
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
        if Color.isSamaritanMode {
            return .samaritanRed
        }
        return Color.isSystemDark ? .vibrantBlue : .blue
    }

    private var highlightColor: Color {
        if Color.isSamaritanMode {
            return .samaritanOrange
        }
        return Color.isSystemDark ? .vibrantCyan : .cyan
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

    private var accentColor: Color {
        if Color.isSamaritanMode {
            return .samaritanRed
        }
        return Color.isSystemDark ? .vibrantBlue : .blue
    }

    private var borderColor: Color {
        if Color.isSamaritanMode {
            return .samaritanBorder
        }
        return Color.isSystemDark ? Color.vibrantBlue.opacity(0.3) : Color.blue.opacity(0.3)
    }

    private var textColor: Color {
        Color.isSamaritanMode ? .samaritanTextSecondary : .secondary
    }

    var body: some View {
        HStack(spacing: 6) {
            Text(key)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(accentColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(borderColor.opacity(0.2))
                .cornerRadius(4)

            Text(description)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(textColor)
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
            description: "Red Terminal Theme",
            icon: "terminal",
            keywords: ["theme", "samaritan", "red", "terminal"],
            action: .switchTheme("samaritan")
        ),
        AtlasCommand(
            name: "Theme: Black AF",
            description: "Pure Black Theme",
            icon: "moon.stars.fill",
            keywords: ["theme", "black", "dark", "pure", "af"],
            action: .switchTheme("dark")
        ),
        AtlasCommand(
            name: "Theme: White AF",
            description: "Pure Light Theme",
            icon: "sun.max.fill",
            keywords: ["theme", "white", "light", "bright", "af"],
            action: .switchTheme("light")
        ),
        AtlasCommand(
            name: "Theme: System",
            description: "Follow System Theme",
            icon: "circle.lefthalf.filled",
            keywords: ["theme", "system", "auto", "default"],
            action: .switchTheme("system")
        ),
        AtlasCommand(
            name: "Quit Atlas",
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

    // Theme-adaptive colors
    private var accentColor: Color {
        if Color.isSamaritanMode {
            return .samaritanRed
        }
        return Color.isSystemDark ? .vibrantBlue : .blue
    }

    private var textColor: Color {
        Color.isSamaritanMode ? .samaritanText : .primary
    }

    private var secondaryTextColor: Color {
        Color.isSamaritanMode ? .samaritanTextSecondary : .secondary
    }

    private var borderColor: Color {
        if Color.isSamaritanMode {
            return .samaritanBorder
        }
        return Color.isSystemDark ? Color.vibrantBlue.opacity(0.3) : Color.blue.opacity(0.3)
    }

    private var widgetName: String {
        Color.isSamaritanMode ? widget.name.uppercased() : widget.name
    }

    private var widgetDescription: String {
        Color.isSamaritanMode ? widget.description.uppercased() : widget.description
    }

    // Metric-specific colors
    private var cpuColor: Color {
        if Color.isSamaritanMode {
            return .samaritanRed
        }
        return Color.isSystemDark ? .vibrantBlue : .blue
    }

    private var memoryColor: Color {
        if Color.isSamaritanMode {
            return .samaritanOrange
        }
        return Color.isSystemDark ? .vibrantOrange : .orange
    }

    private var diskColor: Color {
        if Color.isSamaritanMode {
            return .samaritanAmber
        }
        return Color.isSystemDark ? .vibrantYellow : .yellow
    }

    private var networkColor: Color {
        if Color.isSamaritanMode {
            return .samaritanGreen
        }
        return Color.isSystemDark ? .vibrantGreen : .green
    }

    private var warningColor: Color {
        if Color.isSamaritanMode {
            return .samaritanOrange
        }
        return Color.isSystemDark ? .vibrantOrange : .orange
    }

    private var criticalColor: Color {
        if Color.isSamaritanMode {
            return .samaritanRed
        }
        return Color.isSystemDark ? .vibrantRed : .red
    }

    private var successColor: Color {
        if Color.isSamaritanMode {
            return .samaritanGreen
        }
        return Color.isSystemDark ? .vibrantGreen : .green
    }

    var body: some View {
        VStack(spacing: 0) {
            // Widget header
            HStack {
                Image(systemName: widget.icon)
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(accentColor)

                VStack(alignment: .leading, spacing: 4) {
                    Text(widgetName)
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(textColor)
                        .tracking(Color.isSamaritanMode ? 2 : 1)

                    Text(widgetDescription)
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(secondaryTextColor)
                        .tracking(Color.isSamaritanMode ? 1 : 0.5)
                }

                Spacer()
            }
            .padding(30)
            .background(Color.darkBackground)
            .overlay(
                Rectangle()
                    .fill(accentColor)
                    .frame(height: 3),
                alignment: .bottom
            )

            // Widget content
            widgetContent
        }
        .background(Color.darkCard)
        .overlay(
            Rectangle()
                .stroke(borderColor, lineWidth: 2)
        )
    }

    @ViewBuilder
    private var widgetContent: some View {
        // All content fits on screen - no scrolling needed
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
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 24) {
            AtlasMetricCard(
                title: "Download Speed",
                value: formatBytes(monitor.networkDownload) + "/s",
                icon: "arrow.down.circle.fill",
                color: networkColor
            )

            AtlasMetricCard(
                title: "Upload Speed",
                value: formatBytes(monitor.networkUpload) + "/s",
                icon: "arrow.up.circle.fill",
                color: warningColor
            )

            AtlasMetricCard(
                title: "Total Traffic",
                value: formatBytes(monitor.networkDownload + monitor.networkUpload) + "/s",
                icon: "arrow.left.arrow.right.circle.fill",
                color: criticalColor
            )

            AtlasMetricCard(
                title: "Network Status",
                value: (monitor.networkDownload + monitor.networkUpload) > 1024 ? "ACTIVE" : "IDLE",
                icon: "wifi.circle.fill",
                color: diskColor
            )
        }
        .padding(30)
    }

    private var cpuContent: some View {
        VStack(spacing: 24) {
            Spacer()
            // Large CPU percentage
            VStack(spacing: 12) {
                Text(String(format: "%.1f%%", monitor.cpuUsage))
                    .font(.system(size: 120, weight: .bold, design: .monospaced))
                    .foregroundColor(cpuColor)

                Text(Color.isSamaritanMode ? "CPU UTILIZATION" : "CPU Utilization")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(secondaryTextColor)
                    .tracking(Color.isSamaritanMode ? 2 : 1)
            }

            Spacer()

            // CPU details grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 24) {
                AtlasMetricCard(title: "Cores", value: "\(monitor.cpuCores)", icon: "cpu", color: warningColor)
                AtlasMetricCard(title: "Temperature", value: monitor.cpuTemperature, icon: "thermometer.medium", color: criticalColor)
                AtlasMetricCard(title: "Load Average", value: monitor.cpuLoadAverage, icon: "chart.line.uptrend.xyaxis", color: diskColor)
            }

            Spacer()
        }
        .padding(30)
    }

    private var memoryContent: some View {
        VStack(spacing: 24) {
            Spacer()
            // Large memory percentage
            VStack(spacing: 12) {
                Text(String(format: "%.1f%%", monitor.memoryUsage))
                    .font(.system(size: 120, weight: .bold, design: .monospaced))
                    .foregroundColor(memoryColor)

                Text(Color.isSamaritanMode ? "MEMORY USAGE" : "Memory Usage")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(secondaryTextColor)
                    .tracking(Color.isSamaritanMode ? 2 : 1)
            }

            Spacer()

            // Memory details grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 24) {
                AtlasMetricCard(title: "Used", value: formatBytes(monitor.memoryUsed), icon: "memorychip.fill", color: criticalColor)
                AtlasMetricCard(title: "Free", value: formatBytes(monitor.memoryFree), icon: "memorychip", color: successColor)
                AtlasMetricCard(title: "Cached", value: formatBytes(monitor.memoryCached), icon: "internaldrive", color: diskColor)
            }

            Spacer()
        }
        .padding(30)
    }

    private var diskContent: some View {
        VStack(spacing: 24) {
            Spacer()
            // Large disk percentage
            VStack(spacing: 12) {
                Text(String(format: "%.1f%%", monitor.diskUsage))
                    .font(.system(size: 120, weight: .bold, design: .monospaced))
                    .foregroundColor(diskColor)

                Text(Color.isSamaritanMode ? "DISK USAGE" : "Disk Usage")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(secondaryTextColor)
                    .tracking(Color.isSamaritanMode ? 2 : 1)
            }

            Spacer()

            // Disk details grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 32) {
                AtlasMetricCard(title: "Used Space", value: formatBytes(monitor.diskTotal - monitor.diskFree), icon: "internaldrive.fill", color: criticalColor)
                AtlasMetricCard(title: "Free Space", value: formatBytes(monitor.diskFree), icon: "internaldrive", color: successColor)
            }

            Spacer()
        }
        .padding(30)
    }

    private var processesContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(Color.isSamaritanMode ? "TOP PROCESSES" : "Top Processes")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(textColor)
                .tracking(Color.isSamaritanMode ? 2 : 1)

            VStack(spacing: 2) {
                ForEach(taskManager.processes.prefix(10)) { process in
                    HStack {
                        Text(Color.isSamaritanMode ? process.name.uppercased() : process.name)
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(textColor)
                            .lineLimit(1)

                        Spacer()

                        Text(String(format: "%.1f%%", process.cpuUsage))
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(warningColor)
                            .frame(width: 80, alignment: .trailing)

                        Text(String(format: "%.0f MB", process.memoryMB))
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(criticalColor)
                            .frame(width: 100, alignment: .trailing)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.darkCard)
                    .overlay(
                        Rectangle()
                            .fill(borderColor.opacity(0.3))
                            .frame(height: 1),
                        alignment: .bottom
                    )
                }
            }
        }
    }

    private var systemOverviewContent: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 24) {
            AtlasMetricCard(title: "CPU", value: String(format: "%.1f%%", monitor.cpuUsage), icon: "cpu", color: cpuColor)
            AtlasMetricCard(title: "Memory", value: String(format: "%.1f%%", monitor.memoryUsage), icon: "memorychip", color: memoryColor)
            AtlasMetricCard(title: "Disk", value: String(format: "%.1f%%", monitor.diskUsage), icon: "internaldrive", color: diskColor)
            AtlasMetricCard(title: "Download", value: formatBytes(monitor.networkDownload) + "/s", icon: "arrow.down.circle", color: networkColor)
            AtlasMetricCard(title: "Upload", value: formatBytes(monitor.networkUpload) + "/s", icon: "arrow.up.circle", color: warningColor)
            AtlasMetricCard(title: "Temperature", value: monitor.cpuTemperature, icon: "thermometer.medium", color: criticalColor)
        }
        .padding(30)
    }

    private var allMetricsContent: some View {
        VStack(spacing: 12) {
            // Top row - Gauge metrics (smaller)
            HStack(spacing: 12) {
                // CPU Gauge
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .stroke(borderColor.opacity(0.3), lineWidth: 8)
                            .frame(width: 120, height: 120)

                        Circle()
                            .trim(from: 0, to: CGFloat(monitor.cpuUsage / 100))
                            .stroke(cpuColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))

                        VStack(spacing: 2) {
                            Text(String(format: "%.0f%%", monitor.cpuUsage))
                                .font(.system(size: 28, weight: .bold, design: .monospaced))
                                .foregroundColor(cpuColor)
                            Text("CPU")
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(secondaryTextColor)
                                .tracking(1)
                        }
                    }
                }
                .frame(maxWidth: .infinity)

                // Memory Gauge
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .stroke(borderColor.opacity(0.3), lineWidth: 8)
                            .frame(width: 120, height: 120)

                        Circle()
                            .trim(from: 0, to: CGFloat(monitor.memoryUsage / 100))
                            .stroke(memoryColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))

                        VStack(spacing: 2) {
                            Text(String(format: "%.0f%%", monitor.memoryUsage))
                                .font(.system(size: 28, weight: .bold, design: .monospaced))
                                .foregroundColor(memoryColor)
                            Text(Color.isSamaritanMode ? "MEMORY" : "Memory")
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(secondaryTextColor)
                                .tracking(Color.isSamaritanMode ? 1 : 0.5)
                        }
                    }
                }
                .frame(maxWidth: .infinity)

                // Disk Gauge
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .stroke(borderColor.opacity(0.3), lineWidth: 8)
                            .frame(width: 120, height: 120)

                        Circle()
                            .trim(from: 0, to: CGFloat(monitor.diskUsage / 100))
                            .stroke(diskColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))

                        VStack(spacing: 2) {
                            Text(String(format: "%.0f%%", monitor.diskUsage))
                                .font(.system(size: 28, weight: .bold, design: .monospaced))
                                .foregroundColor(diskColor)
                            Text(Color.isSamaritanMode ? "DISK" : "Disk")
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(secondaryTextColor)
                                .tracking(Color.isSamaritanMode ? 1 : 0.5)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 10)

            // CPU Details Row
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "cpu")
                        .foregroundColor(cpuColor)
                    Text(Color.isSamaritanMode ? "CPU METRICS" : "CPU Metrics")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(textColor)
                        .tracking(Color.isSamaritanMode ? 2 : 1)
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    DetailMetric(label: "Cores", value: "\(monitor.cpuCores)", color: cpuColor)
                    DetailMetric(label: "Temperature", value: monitor.cpuTemperature, color: criticalColor)
                    DetailMetric(label: "Load Average", value: monitor.cpuLoadAverage, color: warningColor)
                    DetailMetric(label: "Processes", value: "\(taskManager.processes.count)", color: diskColor)
                }
            }
            .padding(16)
            .background(Color.darkCard.opacity(0.5))
            .overlay(Rectangle().stroke(borderColor, lineWidth: 1))

            // Memory Details Row
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "memorychip")
                        .foregroundColor(memoryColor)
                    Text(Color.isSamaritanMode ? "MEMORY METRICS" : "Memory Metrics")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(textColor)
                        .tracking(Color.isSamaritanMode ? 2 : 1)
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    DetailMetric(label: "Used", value: formatBytes(monitor.memoryUsed), color: criticalColor)
                    DetailMetric(label: "Free", value: formatBytes(monitor.memoryFree), color: successColor)
                    DetailMetric(label: "Cached", value: formatBytes(monitor.memoryCached), color: diskColor)
                    DetailMetric(label: "Wired", value: formatBytes(monitor.memoryWired), color: warningColor)
                }
            }
            .padding(16)
            .background(Color.darkCard.opacity(0.5))
            .overlay(Rectangle().stroke(borderColor, lineWidth: 1))

            // Network + Disk Row
            HStack(spacing: 16) {
                // Network Details
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "network")
                            .foregroundColor(networkColor)
                        Text(Color.isSamaritanMode ? "NETWORK" : "Network")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(textColor)
                            .tracking(Color.isSamaritanMode ? 2 : 1)
                    }

                    VStack(spacing: 8) {
                        DetailMetric(label: "Download", value: formatBytes(monitor.networkDownload) + "/s", color: networkColor)
                        DetailMetric(label: "Upload", value: formatBytes(monitor.networkUpload) + "/s", color: warningColor)
                        DetailMetric(label: "Connections", value: "\(self.networkMonitor.connections.filter { $0.state == .established }.count)", color: diskColor)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(Color.darkCard.opacity(0.5))
                .overlay(Rectangle().stroke(borderColor, lineWidth: 1))

                // Disk Details
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "internaldrive")
                            .foregroundColor(diskColor)
                        Text(Color.isSamaritanMode ? "STORAGE" : "Storage")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(textColor)
                            .tracking(Color.isSamaritanMode ? 2 : 1)
                    }

                    VStack(spacing: 8) {
                        DetailMetric(label: "Used", value: formatBytes(monitor.diskTotal - monitor.diskFree), color: criticalColor)
                        DetailMetric(label: "Free", value: formatBytes(monitor.diskFree), color: successColor)
                        DetailMetric(label: "Total", value: formatBytes(monitor.diskTotal), color: textColor)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(Color.darkCard.opacity(0.5))
                .overlay(Rectangle().stroke(borderColor, lineWidth: 1))
            }

            // Bottom Row - Processes and Network Connections
            HStack(spacing: 16) {
                // Top Processes
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "app.badge")
                            .foregroundColor(cpuColor)
                        Text(Color.isSamaritanMode ? "TOP PROCESSES" : "Top Processes")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(textColor)
                            .tracking(Color.isSamaritanMode ? 2 : 1)
                        Spacer()
                    }

                    VStack(spacing: 2) {
                        ForEach(taskManager.processes.prefix(6)) { process in
                            HStack(spacing: 8) {
                                Text(Color.isSamaritanMode ? process.name.uppercased() : process.name)
                                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                                    .foregroundColor(textColor)
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Text(String(format: "%.1f%%", process.cpuUsage))
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(warningColor)
                                    .frame(width: 60, alignment: .trailing)

                                Text(String(format: "%.0f MB", process.memoryMB))
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(criticalColor)
                                    .frame(width: 80, alignment: .trailing)
                            }
                            .padding(.vertical, 5)
                            .padding(.horizontal, 12)
                            .background(Color.darkCard.opacity(0.3))
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(Color.darkCard.opacity(0.5))
                .overlay(Rectangle().stroke(borderColor, lineWidth: 1))

                // Active Connections
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "network")
                            .foregroundColor(networkColor)
                        Text(Color.isSamaritanMode ? "ACTIVE CONNECTIONS" : "Active Connections")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(textColor)
                            .tracking(Color.isSamaritanMode ? 2 : 1)
                        Spacer()
                    }

                    VStack(spacing: 2) {
                        ForEach(self.networkMonitor.connections.filter { $0.state == .established }.prefix(6)) { connection in
                            HStack(spacing: 8) {
                                Text(Color.isSamaritanMode ? connection.processName.uppercased() : connection.processName)
                                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                                    .foregroundColor(textColor)
                                    .lineLimit(1)
                                    .frame(width: 120, alignment: .leading)

                                Text(connection.networkProtocol.rawValue)
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .foregroundColor(diskColor)
                                    .frame(width: 50, alignment: .leading)

                                Text("\(connection.remotePort)")
                                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                                    .foregroundColor(secondaryTextColor)
                                    .frame(width: 50, alignment: .trailing)

                                Text(connection.totalTraffic)
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .foregroundColor(networkColor)
                                    .frame(width: 70, alignment: .trailing)
                            }
                            .padding(.vertical, 5)
                            .padding(.horizontal, 12)
                            .background(Color.darkCard.opacity(0.3))
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(Color.darkCard.opacity(0.5))
                .overlay(Rectangle().stroke(borderColor, lineWidth: 1))
            }
        }
        .padding(20)
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

// MARK: - Detail Metric Component
struct DetailMetric: View {
    let label: String
    let value: String
    let color: Color

    private var secondaryTextColor: Color {
        Color.isSamaritanMode ? .samaritanTextSecondary : .secondary
    }

    private var labelText: String {
        Color.isSamaritanMode ? label.uppercased() : label
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(labelText)
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(secondaryTextColor)
                .tracking(Color.isSamaritanMode ? 1 : 0.5)

            Text(value)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.darkCard.opacity(0.5))
        .overlay(Rectangle().stroke(color.opacity(0.3), lineWidth: 1))
    }
}

// MARK: - Atlas Metric Card
struct AtlasMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    private var textColor: Color {
        Color.isSamaritanMode ? .samaritanText : .primary
    }

    private var secondaryTextColor: Color {
        Color.isSamaritanMode ? .samaritanTextSecondary : .secondary
    }

    private var borderColor: Color {
        if Color.isSamaritanMode {
            return .samaritanBorder
        }
        return Color.isSystemDark ? Color.vibrantBlue.opacity(0.3) : Color.blue.opacity(0.3)
    }

    private var titleText: String {
        Color.isSamaritanMode ? title.uppercased() : title
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(color)

            VStack(spacing: 8) {
                Text(value)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(textColor)

                Text(titleText)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(secondaryTextColor)
                    .tracking(Color.isSamaritanMode ? 1.5 : 1)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color.darkCard)
        .overlay(
            Rectangle()
                .stroke(borderColor, lineWidth: 2)
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

// MARK: - Blinking Cursor Prompt
struct BlinkingCursorPrompt: View {
    @State private var showCursor = true
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Type a command...")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .opacity(0.5)
            
            Text("^")
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .opacity(showCursor ? 1.0 : 0.0)
                .onAppear {
                    // Start blinking animation
                    Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { _ in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showCursor.toggle()
                        }
                    }
                }
        }
    }
}
