import SwiftUI

struct ContentView: View {
    @ObservedObject var systemMonitor: SystemMonitor
    @ObservedObject var configManager: ConfigManager

    var body: some View {
        Group {
            if configManager.config.viewMode == .simple {
                SimplifiedMonitorView(monitor: systemMonitor, configManager: configManager)
            } else {
                MonitorView(systemMonitor: systemMonitor, configManager: configManager)
            }
        }
        .sheet(isPresented: $configManager.showSettings) {
            SettingsView(configManager: configManager)
        }
        .sheet(isPresented: $configManager.showTaskManager) {
            if configManager.config.viewMode == .simple {
                SimplifiedTaskManagerView(taskManager: TaskManager(), configManager: configManager)
            } else {
                TaskManagerView(taskManager: TaskManager())
            }
        }
    }
}