import Foundation
import Network
import SystemConfiguration

// MARK: - Network Connection Model
struct NetworkConnection: Identifiable, Hashable {
    let id = UUID()
    let processName: String
    let processID: Int
    let localAddress: String
    let localPort: Int
    let remoteAddress: String
    let remotePort: Int
    let networkProtocol: NetworkProtocol
    let state: ConnectionState
    var bytesReceived: Int64
    var bytesSent: Int64
    let timestamp: Date

    enum NetworkProtocol: String, CaseIterable {
        case tcp = "TCP"
        case udp = "UDP"
        case icmp = "ICMP"
        case other = "Other"
    }

    enum ConnectionState: String {
        case established = "ESTABLISHED"
        case listen = "LISTEN"
        case synSent = "SYN_SENT"
        case synReceived = "SYN_RECEIVED"
        case finWait1 = "FIN_WAIT1"
        case finWait2 = "FIN_WAIT2"
        case closeWait = "CLOSE_WAIT"
        case closing = "CLOSING"
        case lastAck = "LAST_ACK"
        case timeWait = "TIME_WAIT"
        case closed = "CLOSED"
        case unknown = "UNKNOWN"
    }

    var uploadSpeed: String {
        formatBytes(Double(bytesSent))
    }

    var downloadSpeed: String {
        formatBytes(Double(bytesReceived))
    }

    var totalTraffic: String {
        formatBytes(Double(bytesReceived + bytesSent))
    }

    private func formatBytes(_ bytes: Double) -> String {
        if bytes < 1024 {
            return String(format: "%.0f B", bytes)
        } else if bytes < 1024 * 1024 {
            return String(format: "%.2f KB", bytes / 1024)
        } else if bytes < 1024 * 1024 * 1024 {
            return String(format: "%.2f MB", bytes / (1024 * 1024))
        } else {
            return String(format: "%.2f GB", bytes / (1024 * 1024 * 1024))
        }
    }
}

// MARK: - Packet Information
struct PacketInfo: Identifiable {
    let id = UUID()
    let timestamp: Date
    let source: String
    let destination: String
    let networkProtocol: NetworkConnection.NetworkProtocol
    let length: Int
    let info: String
}

// MARK: - Network Statistics
struct NetworkStats {
    var totalPackets: Int = 0
    var totalBytes: Int64 = 0
    var packetsPerSecond: Double = 0
    var bytesPerSecond: Double = 0
    var activeConnections: Int = 0
    var topProcesses: [(name: String, bytes: Int64)] = []
}

// MARK: - Network Monitor
class NetworkMonitor: ObservableObject {
    @Published var connections: [NetworkConnection] = []
    @Published var packets: [PacketInfo] = []
    @Published var stats: NetworkStats = NetworkStats()
    @Published var isMonitoring: Bool = false

    private var monitorTimer: Timer?
    private var connectionCache: [String: NetworkConnection] = [:]
    private var processCache: [Int: String] = [:]
    private var lastTotalBytes: Int64 = 0
    private var lastUpdateTime: Date = Date()

    // Filters
    @Published var filterProtocol: NetworkConnection.NetworkProtocol?
    @Published var filterProcess: String = ""
    @Published var filterAddress: String = ""

    init() {
        NSLog("[NetworkMonitor] Initializing NetworkMonitor")
        startMonitoring()
        NSLog("[NetworkMonitor] Started monitoring")
    }

    deinit {
        stopMonitoring()
    }

    // MARK: - Monitoring Control
    func startMonitoring(interval: TimeInterval = 2.0) {
        NSLog("[NetworkMonitor] startMonitoring called, isMonitoring=%@", isMonitoring ? "true" : "false")
        guard !isMonitoring else {
            NSLog("[NetworkMonitor] Already monitoring, returning")
            return
        }
        isMonitoring = true
        NSLog("[NetworkMonitor] Setting up timer...")

        // Update connections with power-efficient timer
        monitorTimer = Timer.powerEfficientTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            NSLog("[NetworkMonitor] Timer fired")
            self?.updateConnections()
            self?.updateStatistics()
        }

        NSLog("[NetworkMonitor] Timer created, calling initial updateConnections")
        // Initial update
        updateConnections()
    }

    func stopMonitoring() {
        isMonitoring = false
        monitorTimer?.invalidate()
        monitorTimer = nil
    }

    // MARK: - Update Methods
    func updateConnections() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            let newConnections = self.fetchActiveConnections()

            DispatchQueue.main.async {
                self.connections = newConnections
                self.stats.activeConnections = newConnections.count
            }
        }
    }

    private func fetchActiveConnections() -> [NetworkConnection] {
        var connections: [NetworkConnection] = []

        // Use netstat command to get connection information
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/sbin/netstat")
        task.arguments = ["-anvp", "tcp"]

        let pipe = Pipe()
        task.standardOutput = pipe

        do {
            try task.run()
            task.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                let tcpConns = parseTCPConnections(output)
                NSLog("[NetworkMonitor Parsed \(tcpConns.count) TCP connections")
                connections.append(contentsOf: tcpConns)
            }
        } catch {
            NSLog("[NetworkMonitor Error fetching TCP connections: \(error)")
        }

        // Fetch UDP connections
        let udpTask = Process()
        udpTask.executableURL = URL(fileURLWithPath: "/usr/sbin/netstat")
        udpTask.arguments = ["-anvp", "udp"]

        let udpPipe = Pipe()
        udpTask.standardOutput = udpPipe

        do {
            try udpTask.run()
            udpTask.waitUntilExit()

            let data = udpPipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                let udpConns = parseUDPConnections(output)
                NSLog("[NetworkMonitor Parsed \(udpConns.count) UDP connections")
                connections.append(contentsOf: udpConns)
            }
        } catch {
            NSLog("[NetworkMonitor Error fetching UDP connections: \(error)")
        }

        NSLog("[NetworkMonitor Total connections: \(connections.count)")
        return connections
    }

    private func parseTCPConnections(_ output: String) -> [NetworkConnection] {
        var connections: [NetworkConnection] = []
        let lines = output.components(separatedBy: .newlines)
        var skippedCount = 0

        for line in lines {
            // Skip header lines and empty lines
            guard !line.contains("Proto") && !line.contains("Active") && !line.isEmpty else {
                skippedCount += 1
                continue
            }

            let components = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            guard components.count >= 11 else {
                // Skip lines with insufficient data
                continue
            }

            // Parse addresses and ports (indices 3 and 4)
            let localAddress = parseAddress(components[3])
            let remoteAddress = parseAddress(components[4])

            // Parse state (index 5)
            let stateString = components[5]
            let state = parseConnectionState(stateString)

            // Get process info from PID (index 10)
            var processName = "Unknown"
            var processID = 0

            if let pid = Int(components[10]) {
                processID = pid
                processName = getProcessName(pid: pid)
            }

            // Get actual bytes from rxbytes (6) and txbytes (7)
            let bytesReceived = Int64(components[6]) ?? 0
            let bytesSent = Int64(components[7]) ?? 0

            let connection = NetworkConnection(
                processName: processName,
                processID: processID,
                localAddress: localAddress.address,
                localPort: localAddress.port,
                remoteAddress: remoteAddress.address,
                remotePort: remoteAddress.port,
                networkProtocol: .tcp,
                state: state,
                bytesReceived: bytesReceived,
                bytesSent: bytesSent,
                timestamp: Date()
            )

            connections.append(connection)
            NSLog("[NetworkMonitor Added TCP connection: \(processName) (\(processID)) \(localAddress.address):\(localAddress.port) -> \(remoteAddress.address):\(remoteAddress.port)")
        }

        return connections
    }

    private func parseUDPConnections(_ output: String) -> [NetworkConnection] {
        var connections: [NetworkConnection] = []
        let lines = output.components(separatedBy: .newlines)

        for line in lines {
            // Skip header lines and empty lines
            guard !line.contains("Proto") && !line.contains("Active") && !line.isEmpty else { continue }

            let components = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            guard components.count >= 11 else { continue }

            // Parse addresses (UDP can have both local and remote)
            let localAddress = parseAddress(components[3])
            let remoteAddress = parseAddress(components[4])

            var processName = "Unknown"
            var processID = 0

            if let pid = Int(components[10]) {
                processID = pid
                processName = getProcessName(pid: pid)
            }

            // Get actual bytes from rxbytes (6) and txbytes (7)
            let bytesReceived = Int64(components[6]) ?? 0
            let bytesSent = Int64(components[7]) ?? 0

            // Determine state based on remote address
            let state: NetworkConnection.ConnectionState = (remoteAddress.address == "*" || remoteAddress.address.isEmpty) ? .listen : .established

            let connection = NetworkConnection(
                processName: processName,
                processID: processID,
                localAddress: localAddress.address,
                localPort: localAddress.port,
                remoteAddress: remoteAddress.address,
                remotePort: remoteAddress.port,
                networkProtocol: .udp,
                state: state,
                bytesReceived: bytesReceived,
                bytesSent: bytesSent,
                timestamp: Date()
            )

            connections.append(connection)
        }

        return connections
    }

    private func parseAddress(_ addressString: String) -> (address: String, port: Int) {
        let components = addressString.components(separatedBy: ".")

        if components.count >= 5 {
            // IPv4 format: x.x.x.x.port
            let address = components[0..<4].joined(separator: ".")
            let port = Int(components[4]) ?? 0
            return (address, port)
        } else if addressString.contains(":") {
            // IPv6 format
            let parts = addressString.components(separatedBy: ":")
            if let portString = parts.last, let port = Int(portString) {
                let address = parts.dropLast().joined(separator: ":")
                return (address, port)
            }
        }

        return (addressString, 0)
    }

    private func parseConnectionState(_ state: String) -> NetworkConnection.ConnectionState {
        switch state.uppercased() {
        case "ESTABLISHED": return .established
        case "LISTEN": return .listen
        case "SYN_SENT": return .synSent
        case "SYN_RCVD": return .synReceived
        case "FIN_WAIT_1": return .finWait1
        case "FIN_WAIT_2": return .finWait2
        case "CLOSE_WAIT": return .closeWait
        case "CLOSING": return .closing
        case "LAST_ACK": return .lastAck
        case "TIME_WAIT": return .timeWait
        case "CLOSED": return .closed
        default: return .unknown
        }
    }

    private func getProcessName(pid: Int) -> String {
        // Handle PID 0 (kernel/system)
        if pid == 0 {
            return "System"
        }

        // Check cache first
        if let cached = processCache[pid] {
            return cached
        }

        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/ps")
        task.arguments = ["-p", "\(pid)", "-o", "comm="]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        do {
            try task.run()
            task.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines), !output.isEmpty {
                let name = output.components(separatedBy: "/").last ?? output
                if !name.isEmpty {
                    processCache[pid] = name
                    return name
                }
            }
        } catch {
            NSLog("[NetworkMonitor] Error getting process name for PID \(pid): \(error)")
        }

        // If we can't get the process name, use the PID
        let fallback = "PID:\(pid)"
        processCache[pid] = fallback
        return fallback
    }

    private func updateStatistics() {
        let totalBytes = connections.reduce(0) { $0 + $1.bytesReceived + $1.bytesSent }

        // Calculate bytes per second
        let now = Date()
        let timeDelta = now.timeIntervalSince(lastUpdateTime)
        if timeDelta > 0 {
            let bytesDelta = totalBytes - lastTotalBytes
            // Ensure bytes per second is never negative (can happen when connections are cleared)
            stats.bytesPerSecond = max(0, Double(bytesDelta) / timeDelta)
        }

        lastTotalBytes = totalBytes
        lastUpdateTime = now

        stats.totalBytes = totalBytes
        stats.activeConnections = connections.count

        // Calculate top processes by bandwidth
        var processBandwidth: [String: Int64] = [:]
        for conn in connections {
            let total = conn.bytesReceived + conn.bytesSent
            processBandwidth[conn.processName, default: 0] += total
        }

        stats.topProcesses = processBandwidth.sorted { $0.value > $1.value }
            .prefix(5)
            .map { ($0.key, $0.value) }
    }

    // MARK: - Filtering
    var filteredConnections: [NetworkConnection] {
        var filtered = connections

        if let proto = filterProtocol {
            filtered = filtered.filter { $0.networkProtocol == proto }
        }

        if !filterProcess.isEmpty {
            filtered = filtered.filter { $0.processName.localizedCaseInsensitiveContains(filterProcess) }
        }

        if !filterAddress.isEmpty {
            filtered = filtered.filter {
                $0.localAddress.contains(filterAddress) ||
                $0.remoteAddress.contains(filterAddress)
            }
        }

        return filtered
    }

    // MARK: - Actions
    func clearConnections() {
        connections.removeAll()
        packets.removeAll()
        connectionCache.removeAll()
    }

    func exportConnections() -> String {
        var csv = "Timestamp,Process,PID,Protocol,Local Address,Remote Address,State,Bytes Received,Bytes Sent\n"

        for conn in connections {
            let line = """
            \(conn.timestamp),\(conn.processName),\(conn.processID),\(conn.networkProtocol.rawValue),\
            \(conn.localAddress):\(conn.localPort),\(conn.remoteAddress):\(conn.remotePort),\
            \(conn.state.rawValue),\(conn.bytesReceived),\(conn.bytesSent)\n
            """
            csv += line
        }

        return csv
    }
}
