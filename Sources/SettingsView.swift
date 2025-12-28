import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @ObservedObject var configManager: ConfigManager
    @ObservedObject var alertManager: AlertManager

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 24) {
                // View Mode Section
                    SettingsSection(title: "View Mode", icon: "eye") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Choose your preferred interface style")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)

                            Picker("Mode", selection: $configManager.config.viewMode) {
                                Label("Simple", systemImage: "square.grid.2x2")
                                    .tag(ViewMode.simple)
                                Label("Advanced", systemImage: "slider.horizontal.3")
                                    .tag(ViewMode.advanced)
                            }
                            .pickerStyle(.segmented)

                            Group {
                                if configManager.config.viewMode == .simple {
                                    Text("• Clean, easy-to-understand interface\n• Status-based indicators (Good/Moderate/High)\n• Simple app management")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("• Detailed metrics and graphs\n• Full process list with all details\n• Advanced customization options")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.top, 4)
                        }
                    }

                    // Atlas Mode Section
                    SettingsSection(title: "Atlas Mode", icon: "globe") {
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle("Enable Atlas Mode", isOn: $configManager.config.atlasMode)
                                .font(.system(size: 13, weight: .medium))

                            Text("Full-screen Samaritan interface with widget-based layout and command center")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)

                            if configManager.config.atlasMode {
                                HStack(spacing: 6) {
                                    Image(systemName: "info.circle.fill")
                                        .font(.system(size: 11))
                                        .foregroundColor(.samaritanRed)
                                    Text("Press Cmd+K to access the command palette in Atlas Mode")
                                        .font(.system(size: 10, design: .monospaced))
                                        .foregroundColor(.samaritanOrange)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.samaritanRed.opacity(0.1))
                                .cornerRadius(6)
                            }
                        }
                    }

                    // Menu Bar Section
                    SettingsSection(title: "Menu Bar", icon: "menubar.rectangle") {
                        Toggle("Show Mini Graph", isOn: $configManager.config.showMiniGraphInMenuBar)
                            .onChange(of: configManager.config.showMiniGraphInMenuBar) { newValue in
                                if newValue {
                                    configManager.config.showCPUInMenuBar = false
                                    configManager.config.showMemoryInMenuBar = false
                                    configManager.config.showNetworkInMenuBar = false
                                }
                            }

                        if !configManager.config.showMiniGraphInMenuBar {
                            Toggle("Show CPU Usage", isOn: $configManager.config.showCPUInMenuBar)
                            Toggle("Show Memory Usage", isOn: $configManager.config.showMemoryInMenuBar)
                            // Network speed option removed - causes crashes in menu bar
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Update Interval: \(String(format: "%.1f", configManager.config.updateInterval))s")
                                .font(.system(size: 12))
                            Slider(
                                value: $configManager.config.updateInterval,
                                in: 1.0...10.0,
                                step: 0.5
                            )
                        }
                    }

                    // Display Section (only show in advanced mode)
                    if configManager.config.viewMode == .advanced {
                        SettingsSection(title: "Display", icon: "chart.xyaxis.line") {
                            Toggle("Show Graphs", isOn: $configManager.config.showGraphs)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Theme")
                                    .font(.system(size: 12))

                                VStack(spacing: 8) {
                                    HStack(spacing: 8) {
                                        ThemeButton(title: "🔄 System", isSelected: configManager.config.theme == "system") {
                                            configManager.config.theme = "system"
                                            configManager.applyTheme()
                                        }

                                        ThemeButton(title: "☀️ white af", isSelected: configManager.config.theme == "light") {
                                            configManager.config.theme = "light"
                                            configManager.applyTheme()
                                        }
                                    }

                                    HStack(spacing: 8) {
                                        ThemeButton(title: "⬛ black af", isSelected: configManager.config.theme == "dark") {
                                            configManager.config.theme = "dark"
                                            configManager.applyTheme()
                                        }

                                        ThemeButton(title: "🔴 Samaritan", isSelected: configManager.config.theme == "samaritan") {
                                            configManager.config.theme = "samaritan"
                                            configManager.applyTheme()
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        SettingsSection(title: "Appearance", icon: "paintbrush") {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Theme")
                                    .font(.system(size: 12))

                                VStack(spacing: 8) {
                                    HStack(spacing: 8) {
                                        ThemeButton(title: "🔄 System", isSelected: configManager.config.theme == "system") {
                                            configManager.config.theme = "system"
                                            configManager.applyTheme()
                                        }

                                        ThemeButton(title: "☀️ white af", isSelected: configManager.config.theme == "light") {
                                            configManager.config.theme = "light"
                                            configManager.applyTheme()
                                        }
                                    }

                                    HStack(spacing: 8) {
                                        ThemeButton(title: "⬛ black af", isSelected: configManager.config.theme == "dark") {
                                            configManager.config.theme = "dark"
                                            configManager.applyTheme()
                                        }

                                        ThemeButton(title: "🔴 Samaritan", isSelected: configManager.config.theme == "samaritan") {
                                            configManager.config.theme = "samaritan"
                                            configManager.applyTheme()
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Window Behavior Section
                    SettingsSection(title: "Window Behavior", icon: "macwindow") {
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle("Show window on launch", isOn: $configManager.config.showWindowOnLaunch)
                            Toggle("Keep menu bar when window closed", isOn: $configManager.config.keepMenuBarWhenWindowClosed)

                            Text("When disabled, closing the window will quit the app")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    }

                    // Startup Section
                    SettingsSection(title: "Startup ⚡", icon: "power") {
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle("Launch at startup", isOn: Binding(
                                get: { configManager.config.launchAtStartup },
                                set: { newValue in
                                    configManager.config.launchAtStartup = newValue
                                    toggleLaunchAtStartup(enabled: newValue)
                                }
                            ))

                            Text("PeakView will automatically start when you log in")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    }

                    // Power Management Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 10) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.green)
                                    .frame(width: 32, height: 32)
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            Text("Power Management")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Toggle("Low power mode", isOn: $configManager.config.lowPowerMode)

                            Text("Reduces update frequency to save battery")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)

                            Divider()

                            Toggle("Auto low power on battery", isOn: $configManager.config.autoLowPowerOnBattery)

                            Text("Automatically enables low power mode when unplugged")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(NSColor.controlBackgroundColor))
                        )
                    }

                    // Resource Alerts Section
                    SettingsSection(title: "Resource Alerts", icon: "bell.badge") {
                        VStack(alignment: .leading, spacing: 16) {
                            Toggle("Enable resource alerts", isOn: $alertManager.alertsEnabled)

                            if alertManager.alertsEnabled {
                                VStack(alignment: .leading, spacing: 12) {
                                    // CPU Alert
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text("CPU Threshold")
                                                .font(.system(size: 12, weight: .medium))
                                            Spacer()
                                            Text("\(Int(alertManager.cpuThreshold))%")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(.orange)
                                        }
                                        Slider(value: $alertManager.cpuThreshold, in: 50...100, step: 5)
                                    }

                                    Divider()

                                    // Memory Alert
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text("Memory Threshold")
                                                .font(.system(size: 12, weight: .medium))
                                            Spacer()
                                            Text("\(Int(alertManager.memoryThreshold))%")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(.orange)
                                        }
                                        Slider(value: $alertManager.memoryThreshold, in: 50...100, step: 5)
                                    }

                                    Divider()

                                    // Disk Alert
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text("Disk Threshold")
                                                .font(.system(size: 12, weight: .medium))
                                            Spacer()
                                            Text("\(Int(alertManager.diskThreshold))%")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(.orange)
                                        }
                                        Slider(value: $alertManager.diskThreshold, in: 50...100, step: 5)
                                    }
                                }

                                Text("Notifications are sent when usage exceeds threshold (max once every 5 minutes)")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    // About Section
                    SettingsSection(title: "About", icon: "info.circle") {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.secondary)
                        }

                        Button(action: {
                            configManager.resetToDefaults()
                        }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Reset to Defaults")
                            }
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.red)
                    }
            }
            .padding()
        }
    }

    private func toggleLaunchAtStartup(enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to \(enabled ? "enable" : "disable") launch at startup: \(error.localizedDescription)")
            }
        } else {
            // Fallback for macOS 12 and earlier using Legacy Login Items
            if enabled {
                // Add to login items using AppleScript
                let script = """
                tell application "System Events"
                    make login item at end with properties {path:"\(Bundle.main.bundlePath)", hidden:false}
                end tell
                """
                var error: NSDictionary?
                if let scriptObject = NSAppleScript(source: script) {
                    scriptObject.executeAndReturnError(&error)
                    if let error = error {
                        print("AppleScript error: \(error)")
                    }
                }
            } else {
                // Remove from login items using AppleScript
                let script = """
                tell application "System Events"
                    delete login item "PeakView"
                end tell
                """
                var error: NSDictionary?
                if let scriptObject = NSAppleScript(source: script) {
                    scriptObject.executeAndReturnError(&error)
                    if let error = error {
                        print("AppleScript error: \(error)")
                    }
                }
            }
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.7), .cyan.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)

                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }

                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
            }

            VStack(alignment: .leading, spacing: 12) {
                content
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.darkCard)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            colors: [.blue.opacity(0.2), .cyan.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
        }
    }
}

// MARK: - Theme Button
struct ThemeButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.blue : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(configManager: ConfigManager(), alertManager: AlertManager())
    }
}
