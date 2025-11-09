import SwiftUI

// MARK: - Samaritan Command Bar
struct SamaritanCommandBar: View {
    @Binding var isShowing: Bool
    @State private var searchText: String = ""
    @State private var selectedIndex: Int = 0
    @FocusState private var isTextFieldFocused: Bool
    @State private var keyMonitor: Any?

    let onCommandSelected: (SamaritanCommand) -> Void

    var filteredCommands: [SamaritanCommand] {
        if searchText.isEmpty {
            return SamaritanCommand.allCommands
        }
        return SamaritanCommand.allCommands.filter { command in
            command.name.lowercased().contains(searchText.lowercased()) ||
            command.keywords.contains(where: { $0.lowercased().contains(searchText.lowercased()) })
        }
    }

    var body: some View {
        ZStack {
            // Backdrop
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.2)) {
                        isShowing = false
                    }
                }

            // Command Bar
            VStack(spacing: 0) {
                // Header
                HStack {
                    Image(systemName: "terminal")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.samaritanRed)

                    Text("WHAT ARE YOUR COMMANDS?")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.samaritanText)
                        .tracking(1.5)

                    Spacer()

                    Button(action: {
                        withAnimation(.easeOut(duration: 0.2)) {
                            isShowing = false
                        }
                    }) {
                        Text("ESC")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.samaritanTextSecondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.samaritanBorder.opacity(0.3))
                            .cornerRadius(2)
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                .background(Color.black)
                .overlay(
                    Rectangle()
                        .fill(Color.samaritanRed)
                        .frame(height: 2),
                    alignment: .bottom
                )

                // Search Input
                HStack(spacing: 12) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.samaritanRed)

                    TextField("", text: $searchText)
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(.samaritanText)
                        .textFieldStyle(.plain)
                        .focused($isTextFieldFocused)
                        .onSubmit {
                            executeSelectedCommand()
                        }
                        .onChange(of: searchText) { _ in
                            selectedIndex = 0
                        }
                }
                .padding()
                .background(Color.darkCard)
                .overlay(
                    Rectangle()
                        .fill(Color.samaritanBorder.opacity(0.3))
                        .frame(height: 1),
                    alignment: .bottom
                )

                // Command List
                ScrollView {
                    VStack(spacing: 1) {
                        if filteredCommands.isEmpty {
                            HStack {
                                Text("NO COMMANDS FOUND")
                                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                                    .foregroundColor(.samaritanTextSecondary)
                                    .tracking(1.2)
                                Spacer()
                            }
                            .padding()
                            .background(Color.darkCard)
                        } else {
                            ForEach(Array(filteredCommands.enumerated()), id: \.element.id) { index, command in
                                CommandRow(
                                    command: command,
                                    isSelected: index == selectedIndex,
                                    searchText: searchText
                                )
                                .onTapGesture {
                                    selectedIndex = index
                                    executeSelectedCommand()
                                }
                            }
                        }
                    }
                }
                .frame(maxHeight: 400)

                // Footer with hints
                HStack(spacing: 16) {
                    KeyHint(key: "↑↓", description: "Navigate")
                    KeyHint(key: "↵", description: "Execute")
                    KeyHint(key: "ESC", description: "Close")
                    Spacer()
                    Text("SAMARITAN v978.0.06.51")
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundColor(.samaritanTextSecondary.opacity(0.6))
                        .tracking(0.5)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.black)
                .overlay(
                    Rectangle()
                        .fill(Color.samaritanBorder.opacity(0.3))
                        .frame(height: 1),
                    alignment: .top
                )
            }
            .frame(width: 600)
            .background(Color.darkBackground)
            .overlay(
                Rectangle()
                    .stroke(Color.samaritanBorder, lineWidth: 2)
            )
            .shadow(color: Color.samaritanRed.opacity(0.3), radius: 20)
            .onAppear {
                isTextFieldFocused = true
                setupKeyMonitor()
            }
            .onDisappear {
                // Remove keyboard monitor when command bar closes
                if let monitor = keyMonitor {
                    NSEvent.removeMonitor(monitor)
                    keyMonitor = nil
                }
            }
        }
    }

    private func setupKeyMonitor() {
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [self] event in
            // Up arrow
            if event.keyCode == 126 {
                DispatchQueue.main.async {
                    selectedIndex = max(0, selectedIndex - 1)
                }
                return nil
            }
            // Down arrow
            if event.keyCode == 125 {
                DispatchQueue.main.async {
                    selectedIndex = min(filteredCommands.count - 1, selectedIndex + 1)
                }
                return nil
            }
            return event
        }
    }

    private func executeSelectedCommand() {
        guard !filteredCommands.isEmpty else { return }
        let command = filteredCommands[selectedIndex]
        onCommandSelected(command)
        withAnimation(.easeOut(duration: 0.2)) {
            isShowing = false
        }
        searchText = ""
        selectedIndex = 0
    }
}

// MARK: - Command Row
struct CommandRow: View {
    let command: SamaritanCommand
    let isSelected: Bool
    let searchText: String

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: command.icon)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundColor(isSelected ? .samaritanRed : .samaritanOrange)
                .frame(width: 24)

            // Command name
            Text(command.name.uppercased())
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundColor(isSelected ? .samaritanText : .samaritanTextSecondary)
                .tracking(1.0)

            Spacer()

            // Description
            Text(command.description.uppercased())
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(.samaritanTextSecondary.opacity(0.7))
                .tracking(0.5)

            // Keyboard shortcut if any
            if let shortcut = command.shortcut {
                Text(shortcut)
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(isSelected ? .samaritanRed : .samaritanTextSecondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.samaritanBorder.opacity(0.2))
                    .cornerRadius(2)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Rectangle()
                .fill(isSelected ? Color.samaritanRed.opacity(0.15) : Color.darkCard)
        )
        .overlay(
            Rectangle()
                .fill(isSelected ? Color.samaritanRed : .clear)
                .frame(width: 3),
            alignment: .leading
        )
    }
}

// MARK: - Key Hint
struct KeyHint: View {
    let key: String
    let description: String

    var body: some View {
        HStack(spacing: 4) {
            Text(key)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.samaritanRed)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.samaritanBorder.opacity(0.2))
                .cornerRadius(2)

            Text(description)
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(.samaritanTextSecondary)
        }
    }
}

// MARK: - Command Model
struct SamaritanCommand: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let icon: String
    let keywords: [String]
    let shortcut: String?
    let action: CommandAction

    enum CommandAction {
        case viewCPU
        case viewMemory
        case viewDisk
        case viewNetwork
        case viewBattery
        case viewProcesses
        case viewTemperature
        case openSettings
        case openNetworkMonitor
        case switchTheme(String)
        case toggleViewMode
        case toggleAtlasMode
        case quitApp
    }

    static let allCommands: [SamaritanCommand] = [
        // View Commands
        SamaritanCommand(
            name: "CPU Monitor",
            description: "View CPU metrics",
            icon: "cpu",
            keywords: ["cpu", "processor", "performance"],
            shortcut: nil,
            action: .viewCPU
        ),
        SamaritanCommand(
            name: "Memory Status",
            description: "View memory usage",
            icon: "memorychip",
            keywords: ["memory", "ram", "mem"],
            shortcut: nil,
            action: .viewMemory
        ),
        SamaritanCommand(
            name: "Disk Usage",
            description: "View storage metrics",
            icon: "internaldrive",
            keywords: ["disk", "storage", "drive"],
            shortcut: nil,
            action: .viewDisk
        ),
        SamaritanCommand(
            name: "Network Analysis",
            description: "View network activity",
            icon: "network",
            keywords: ["network", "net", "internet", "bandwidth"],
            shortcut: "⌘N",
            action: .viewNetwork
        ),
        SamaritanCommand(
            name: "Battery Info",
            description: "View battery status",
            icon: "battery.100",
            keywords: ["battery", "power", "charge"],
            shortcut: nil,
            action: .viewBattery
        ),
        SamaritanCommand(
            name: "Process Manager",
            description: "View running processes",
            icon: "app.badge",
            keywords: ["processes", "apps", "tasks", "activity"],
            shortcut: nil,
            action: .viewProcesses
        ),
        SamaritanCommand(
            name: "Temperature",
            description: "View thermal metrics",
            icon: "thermometer.medium",
            keywords: ["temperature", "temp", "thermal", "heat"],
            shortcut: nil,
            action: .viewTemperature
        ),

        // Navigation Commands
        SamaritanCommand(
            name: "Settings",
            description: "Open settings panel",
            icon: "gearshape",
            keywords: ["settings", "preferences", "config"],
            shortcut: "⌘,",
            action: .openSettings
        ),
        SamaritanCommand(
            name: "Network Monitor",
            description: "Open network monitor",
            icon: "bolt.horizontal",
            keywords: ["network monitor", "detailed network"],
            shortcut: "⌘N",
            action: .openNetworkMonitor
        ),

        // Theme Commands
        SamaritanCommand(
            name: "Theme: Samaritan",
            description: "Switch to Samaritan theme",
            icon: "terminal",
            keywords: ["theme", "samaritan", "red"],
            shortcut: nil,
            action: .switchTheme("samaritan")
        ),
        SamaritanCommand(
            name: "Theme: Dark",
            description: "Switch to dark theme",
            icon: "moon.fill",
            keywords: ["theme", "dark", "black"],
            shortcut: nil,
            action: .switchTheme("dark")
        ),
        SamaritanCommand(
            name: "Theme: Light",
            description: "Switch to light theme",
            icon: "sun.max.fill",
            keywords: ["theme", "light", "white"],
            shortcut: nil,
            action: .switchTheme("light")
        ),
        SamaritanCommand(
            name: "Theme: System",
            description: "Use system theme",
            icon: "circle.lefthalf.filled",
            keywords: ["theme", "system", "auto"],
            shortcut: nil,
            action: .switchTheme("system")
        ),

        // View Mode Commands
        SamaritanCommand(
            name: "Toggle View Mode",
            description: "Switch simple/advanced",
            icon: "slider.horizontal.3",
            keywords: ["view", "mode", "simple", "advanced"],
            shortcut: nil,
            action: .toggleViewMode
        ),
        SamaritanCommand(
            name: "Toggle Atlas Mode",
            description: "Full-screen Samaritan UI",
            icon: "globe",
            keywords: ["atlas", "mode", "fullscreen", "samaritan", "full"],
            shortcut: nil,
            action: .toggleAtlasMode
        ),

        // System Commands
        SamaritanCommand(
            name: "Quit PeakView",
            description: "Exit application",
            icon: "power",
            keywords: ["quit", "exit", "close"],
            shortcut: "⌘Q",
            action: .quitApp
        ),
    ]
}
