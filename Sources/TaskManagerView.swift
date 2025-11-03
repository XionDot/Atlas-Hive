import SwiftUI

struct TaskManagerView: View {
    @ObservedObject var taskManager: TaskManager
    @State private var selectedProcess: ProcessData?
    @State private var showingKillConfirmation = false
    @State private var processToKill: ProcessData?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16))
                }
                .buttonStyle(.plain)
                .help("Back")

                Text("Task Manager")
                    .font(.system(size: 18, weight: .bold))
                Spacer()
                Button(action: {
                    taskManager.updateProcessList()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16))
                }
                .buttonStyle(.plain)
                .help("Refresh")
            }
            .padding()
            .background(Color.accentColor.opacity(0.1))

            // System summary
            HStack(spacing: 16) {
                // Total CPU
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total CPU")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f%%", taskManager.totalCPU))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.blue)
                }

                Divider()
                    .frame(height: 30)

                // Total Memory
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Memory")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text(String(format: "%.0f MB", taskManager.totalMemory))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.green)
                }

                Spacer()

                // Process count
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Processes")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text("\(taskManager.processes.count)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.purple)
                }
            }
            .padding()
            .background(Color.blue.opacity(0.05))
            .cornerRadius(8)
            .padding(.horizontal)
            .padding(.top, 8)

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
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal)
            .padding(.top, 8)

            // Column headers - aligned with rows
            HStack(spacing: 12) {
                // Name column
                Button(action: {
                    taskManager.sortProcesses(by: .name)
                }) {
                    HStack {
                        Text("Name")
                        if taskManager.sortBy == .name {
                            Image(systemName: "chevron.down")
                        }
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(taskManager.sortBy == .name ? .blue : .primary)
                }
                .buttonStyle(.plain)
                .frame(width: 180, alignment: .leading)

                Spacer()

                // CPU column
                Button(action: {
                    taskManager.sortProcesses(by: .cpu)
                }) {
                    HStack {
                        Text("CPU")
                        if taskManager.sortBy == .cpu {
                            Image(systemName: "chevron.down")
                        }
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(taskManager.sortBy == .cpu ? .blue : .primary)
                }
                .buttonStyle(.plain)
                .frame(width: 80, alignment: .trailing)

                // Memory column
                Button(action: {
                    taskManager.sortProcesses(by: .memory)
                }) {
                    HStack {
                        Text("Memory")
                        if taskManager.sortBy == .memory {
                            Image(systemName: "chevron.down")
                        }
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(taskManager.sortBy == .memory ? .blue : .primary)
                }
                .buttonStyle(.plain)
                .frame(width: 80, alignment: .trailing)

                // Actions column
                Text("Actions")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.gray)
                    .frame(width: 70, alignment: .center)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.05))

            Divider()

            // Process list
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(taskManager.filteredProcesses) { process in
                        ProcessRow(
                            process: process,
                            isSelected: selectedProcess?.pid == process.pid,
                            onKill: {
                                processToKill = process
                                showingKillConfirmation = true
                            },
                            onRestart: {
                                let _ = taskManager.restartProcess(process: process)
                            }
                        )
                        .onTapGesture {
                            selectedProcess = process
                        }

                        Divider()
                    }
                }
            }

            // Footer with process count
            HStack {
                Text("\(taskManager.filteredProcesses.count) processes")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                Spacer()
            }
            .padding(8)
            .background(Color.gray.opacity(0.05))
        }
        .frame(width: 600, height: 500)
        .alert("Kill Process?", isPresented: $showingKillConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Kill", role: .destructive) {
                if let process = processToKill {
                    let _ = taskManager.killProcess(pid: process.pid)
                }
            }
        } message: {
            if let process = processToKill {
                Text("Are you sure you want to kill '\(process.name)' (PID: \(process.pid))?\n\nThis will immediately terminate the process.")
            }
        }
    }
}

struct ProcessRow: View {
    let process: ProcessData
    let isSelected: Bool
    let onKill: () -> Void
    let onRestart: () -> Void

    @State private var appIcon: NSImage?

    var body: some View {
        HStack(spacing: 12) {
            // App icon
            if let icon = appIcon {
                Image(nsImage: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
            } else {
                Image(systemName: "app")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .frame(width: 24, height: 24)
            }

            // Process name
            VStack(alignment: .leading, spacing: 2) {
                Text(process.name)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)

                Text("PID: \(process.pid)")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            .frame(width: 150, alignment: .leading)

            Spacer()

            // CPU usage
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.1f%%", process.cpuUsage))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(cpuColor(for: process.cpuUsage))

                ProgressView(value: min(process.cpuUsage, 100), total: 100)
                    .progressViewStyle(.linear)
                    .frame(width: 60)
            }
            .frame(width: 80)

            // Memory usage
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatMemory(process.memoryMB))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(memoryColor(for: process.memoryMB))

                ProgressView(value: min(process.memoryMB, 1000), total: 1000)
                    .progressViewStyle(.linear)
                    .frame(width: 60)
            }
            .frame(width: 80)

            // Action buttons
            HStack(spacing: 8) {
                Button(action: onRestart) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 11))
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                .help("Restart")

                Button(action: onKill) {
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 11))
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                .help("Kill Process")
            }
            .frame(width: 70)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
        .onAppear {
            loadAppIcon()
        }
    }

    private func loadAppIcon() {
        // Get the app bundle path from the process path
        if let range = process.path.range(of: ".app/") {
            let bundlePath = String(process.path[..<range.upperBound].dropLast(1))
            appIcon = NSWorkspace.shared.icon(forFile: bundlePath)
        } else if process.path.hasSuffix(".app") {
            appIcon = NSWorkspace.shared.icon(forFile: process.path)
        }
    }

    private func cpuColor(for usage: Double) -> Color {
        if usage > 50 { return .red }
        if usage > 25 { return .orange }
        return .green
    }

    private func memoryColor(for mb: Double) -> Color {
        if mb > 500 { return .red }
        if mb > 200 { return .orange }
        return .green
    }

    private func formatMemory(_ mb: Double) -> String {
        if mb > 1024 {
            return String(format: "%.1f GB", mb / 1024.0)
        }
        return String(format: "%.0f MB", mb)
    }
}
