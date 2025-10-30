import SwiftUI

struct SettingsView: View {
    @ObservedObject var configManager: ConfigManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Settings")
                    .font(.system(size: 20, weight: .bold))
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
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
                            Toggle("Show Network Speed", isOn: $configManager.config.showNetworkInMenuBar)
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

                    // Display Section
                    SettingsSection(title: "Display", icon: "chart.xyaxis.line") {
                        Toggle("Show Graphs", isOn: $configManager.config.showGraphs)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Theme")
                                .font(.system(size: 12))
                            Picker("Theme", selection: $configManager.config.theme) {
                                Text("System").tag("system")
                                Text("Light").tag("light")
                                Text("Dark").tag("dark")
                            }
                            .pickerStyle(.segmented)
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
        .frame(width: 500, height: 600)
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }

            VStack(alignment: .leading, spacing: 12) {
                content
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(NSColor.controlBackgroundColor))
            )
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(configManager: ConfigManager())
    }
}
