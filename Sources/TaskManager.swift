import Foundation
import AppKit

struct ProcessData: Identifiable, Hashable {
    let id: Int32
    let pid: Int32
    let name: String
    let cpuUsage: Double
    let memoryMB: Double
    let path: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(pid)
    }

    static func == (lhs: ProcessData, rhs: ProcessData) -> Bool {
        lhs.pid == rhs.pid
    }
}

class TaskManager: ObservableObject {
    @Published var processes: [ProcessData] = []
    @Published var sortBy: SortOption = .cpu
    @Published var searchText: String = ""
    @Published var totalCPU: Double = 0.0
    @Published var totalMemory: Double = 0.0

    private var updateTimer: Timer?

    enum SortOption {
        case name, cpu, memory
    }

    init() {
        updateProcessList()

        // Update every 3 seconds (reduce frequency for better performance)
        updateTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.updateProcessList()
        }
    }

    deinit {
        updateTimer?.invalidate()
        updateTimer = nil
    }

    func updateProcessList() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            let processes = self.getAllProcesses()

            // Calculate totals
            let cpuTotal = processes.reduce(0.0) { $0 + $1.cpuUsage }
            let memoryTotal = processes.reduce(0.0) { $0 + $1.memoryMB }

            DispatchQueue.main.async {
                self.processes = processes
                self.totalCPU = cpuTotal
                self.totalMemory = memoryTotal
            }
        }
    }

    private func getAllProcesses() -> [ProcessData] {
        var processes: [ProcessData] = []

        // Get list of all running processes
        let task = Process()
        let pipe = Pipe()

        task.standardOutput = pipe
        task.standardError = Pipe()
        task.arguments = ["-c", "ps -Aceo pid,pcpu,rss,comm -r"]
        task.launchPath = "/bin/bash"

        do {
            try task.run()
            task.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                let lines = output.components(separatedBy: "\n")

                for line in lines.dropFirst() { // Skip header
                    let components = line.split(separator: " ", omittingEmptySubsequences: true)

                    if components.count >= 4 {
                        if let pid = Int32(components[0]),
                           let cpu = Double(components[1]),
                           let rssKB = Double(components[2]) {

                            let name = String(components[3...].joined(separator: " "))
                            let memoryMB = rssKB / 1024.0

                            // Get full path for the process
                            let path = getProcessPath(pid: pid)

                            let process = ProcessData(
                                id: pid,
                                pid: pid,
                                name: name,
                                cpuUsage: cpu,
                                memoryMB: memoryMB,
                                path: path
                            )

                            processes.append(process)
                        }
                    }
                }
            }
        } catch {
            print("Error getting processes: \(error)")
        }

        // Sort by CPU usage (descending) by default
        return processes.sorted { $0.cpuUsage > $1.cpuUsage }
    }

    private func getProcessPath(pid: Int32) -> String {
        let task = Process()
        let pipe = Pipe()

        task.standardOutput = pipe
        task.standardError = Pipe()
        task.arguments = ["-c", "ps -p \(pid) -o comm="]
        task.launchPath = "/bin/bash"

        do {
            try task.run()
            task.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let path = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                return path
            }
        } catch {
            // Ignore
        }

        return ""
    }

    func killProcess(pid: Int32) -> Bool {
        let task = Process()
        task.launchPath = "/bin/kill"
        task.arguments = ["-9", "\(pid)"]

        do {
            try task.run()
            task.waitUntilExit()

            // Update list after killing
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.updateProcessList()
            }

            return task.terminationStatus == 0
        } catch {
            return false
        }
    }

    func restartProcess(process: ProcessData) -> Bool {
        guard !process.path.isEmpty else { return false }

        // Kill the process first
        if killProcess(pid: process.pid) {
            // Wait a moment then restart
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1.0) {
                let task = Process()
                task.launchPath = "/usr/bin/open"
                task.arguments = ["-a", process.path]

                do {
                    try task.run()
                } catch {
                    print("Failed to restart process: \(error)")
                }
            }
            return true
        }

        return false
    }

    func sortProcesses(by option: SortOption) {
        self.sortBy = option

        switch option {
        case .name:
            processes.sort { $0.name.lowercased() < $1.name.lowercased() }
        case .cpu:
            processes.sort { $0.cpuUsage > $1.cpuUsage }
        case .memory:
            processes.sort { $0.memoryMB > $1.memoryMB }
        }
    }

    func refreshProcesses() {
        updateProcessList()
    }

    var filteredProcesses: [ProcessData] {
        if searchText.isEmpty {
            return processes
        }
        return processes.filter { $0.name.lowercased().contains(searchText.lowercased()) }
    }
}
