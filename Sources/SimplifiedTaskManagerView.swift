import SwiftUI
import AppKit

struct SimplifiedTaskManagerView: View {
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var configManager: ConfigManager
    @Environment(\.dismiss) var dismiss

    @State private var searchText = ""

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .medium))
                }
                .buttonStyle(.plain)

                Spacer()

                Text("Open Apps")
                    .font(.system(size: 16, weight: .semibold))

                Spacer()

                Button(action: {
                    configManager.config.viewMode = .advanced
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "slider.horizontal.3")
                        Text("Advanced")
                    }
                    .font(.system(size: 11))
                    .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color.gray.opacity(0.1))

            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)

                TextField("Search apps...", text: $searchText)
                    .textFieldStyle(.plain)

                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal)
            .padding(.vertical, 12)

            // App count
            HStack {
                Text("\(filteredApps.count) open apps")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)

                Spacer()

                Button(action: {
                    taskManager.refreshProcesses()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh")
                    }
                    .font(.system(size: 11))
                    .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)

            Divider()

            // App list
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(filteredApps) { app in
                        AppRowView(app: app, taskManager: taskManager)
                        Divider()
                    }
                }
            }

            // Info footer
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(.secondary)
                    .font(.system(size: 11))

                Text("Only user applications are shown in simple mode")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)

                Spacer()
            }
            .padding()
            .background(Color.gray.opacity(0.05))
        }
        .frame(width: 500, height: 600)
        .onAppear {
            taskManager.refreshProcesses()
        }
    }

    private var filteredApps: [ProcessData] {
        let apps = taskManager.processes.filter { process in
            // Filter to only show apps (end with .app or common user apps)
            let isApp = process.path.hasSuffix(".app") ||
                       process.path.contains("/Applications/") ||
                       process.path.contains("/Users/")

            // Exclude system processes
            let isSystemProcess = process.path.hasPrefix("/usr/libexec/") ||
                                 process.path.hasPrefix("/System/") ||
                                 process.path.hasPrefix("/usr/sbin/") ||
                                 process.path.contains("kernel_task")

            return isApp && !isSystemProcess
        }

        if searchText.isEmpty {
            return apps
        } else {
            return apps.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

struct AppRowView: View {
    let app: ProcessData
    @ObservedObject var taskManager: TaskManager

    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    var body: some View {
        HStack(spacing: 12) {
            // App icon (placeholder - could be enhanced with real icons)
            Image(systemName: appIcon())
                .font(.system(size: 28))
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)

            // App name and stats
            VStack(alignment: .leading, spacing: 4) {
                Text(app.name)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)

                HStack(spacing: 12) {
                    Label(String(format: "%.1f%%", app.cpuUsage), systemImage: "cpu")
                    Label(String(format: "%.0f MB", app.memoryMB), systemImage: "memorychip")
                }
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            }

            Spacer()

            // Close button
            Button(action: {
                handleCloseApp()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "xmark.circle.fill")
                    Text("Close")
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.red)
                .cornerRadius(6)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    private func appIcon() -> String {
        let name = app.name.lowercased()

        if name.contains("safari") { return "safari" }
        if name.contains("chrome") { return "globe" }
        if name.contains("firefox") { return "globe" }
        if name.contains("mail") { return "envelope" }
        if name.contains("messages") { return "message" }
        if name.contains("music") { return "music.note" }
        if name.contains("finder") { return "folder" }
        if name.contains("terminal") { return "terminal" }
        if name.contains("code") || name.contains("xcode") { return "chevron.left.forwardslash.chevron.right" }
        if name.contains("calendar") { return "calendar" }
        if name.contains("notes") { return "note.text" }
        if name.contains("photos") { return "photo" }

        return "app"
    }

    private func handleCloseApp() {
        let success = taskManager.killProcess(pid: app.pid)

        if success {
            alertTitle = "App Closed"
            alertMessage = "\(app.name) has been closed successfully."
        } else {
            alertTitle = "Failed to Close"
            alertMessage = "Could not close \(app.name). It may require administrator privileges or is a protected system process."
        }

        showingAlert = true

        // Refresh after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            taskManager.refreshProcesses()
        }
    }
}