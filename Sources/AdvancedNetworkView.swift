import SwiftUI
import Charts

// MARK: - Advanced Network Monitoring View

struct AdvancedNetworkView: View {
    @ObservedObject var monitor: AdvancedNetworkMonitor
    @State private var selectedTab: NetworkTab = .overview
    @State private var selectedDevice: SNMPDevice?
    @State private var discoveryNetwork: String = "192.168.1"
    @State private var communitString: String = "public"

    enum NetworkTab: String, CaseIterable {
        case overview = "Overview"
        case topology = "Topology"
        case snmp = "SNMP Devices"
        case flows = "Network Flows"
        case protocols = "Protocols"
        case analytics = "AI Analytics"
        case alerts = "Alerts"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Tab Selector
            HStack(spacing: 0) {
                ForEach(NetworkTab.allCases, id: \.self) { tab in
                    Button(action: {
                        selectedTab = tab
                    }) {
                        Text(tab.rawValue)
                            .font(.system(size: 11, weight: selectedTab == tab ? .semibold : .regular))
                            .foregroundColor(selectedTab == tab ? .vibrantCyan : .gray)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                selectedTab == tab ?
                                    Color.vibrantCyan.opacity(0.1) : Color.clear
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(Color.black.opacity(0.3))

            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    switch selectedTab {
                    case .overview:
                        OverviewTab(monitor: monitor)
                    case .topology:
                        TopologyTab(monitor: monitor)
                    case .snmp:
                        SNMPTab(
                            monitor: monitor,
                            selectedDevice: $selectedDevice,
                            discoveryNetwork: $discoveryNetwork,
                            communityString: $communitString
                        )
                    case .flows:
                        FlowsTab(monitor: monitor)
                    case .protocols:
                        ProtocolsTab(monitor: monitor)
                    case .analytics:
                        AnalyticsTab(monitor: monitor)
                    case .alerts:
                        AlertsTab(monitor: monitor)
                    }
                }
                .padding(20)
            }
        }
        .background(Color.black)
    }
}

// MARK: - Overview Tab

struct OverviewTab: View {
    @ObservedObject var monitor: AdvancedNetworkMonitor

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Network Overview")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(.vibrantCyan)

            // Key Metrics
            HStack(spacing: 16) {
                NetworkMetricCard(
                    title: "SNMP Devices",
                    value: "\(monitor.snmpDevices.count)",
                    subtitle: "\(monitor.snmpDevices.filter { $0.isReachable }.count) online",
                    color: .vibrantGreen
                )

                NetworkMetricCard(
                    title: "Active Flows",
                    value: "\(monitor.flows.count)",
                    subtitle: "Network connections",
                    color: .vibrantBlue
                )

                NetworkMetricCard(
                    title: "Protocols",
                    value: "\(monitor.detectedProtocols.count)",
                    subtitle: "Detected",
                    color: .vibrantOrange
                )

                NetworkMetricCard(
                    title: "Alerts",
                    value: "\(monitor.alerts.filter { !$0.isAcknowledged }.count)",
                    subtitle: "Unacknowledged",
                    color: .samaritanRed
                )
            }

            // Real-time Bandwidth Graph
            if !monitor.historicalData.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Bandwidth Over Time")
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundColor(.vibrantCyan)

                    BandwidthChart(data: monitor.historicalData)
                        .frame(height: 200)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }

            // Recent Anomalies
            let anomalies = monitor.historicalData.filter { $0.isAnomaly }.suffix(5)
            if !anomalies.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent Anomalies")
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundColor(.samaritanRed)

                    ForEach(Array(anomalies), id: \.id) { anomaly in
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.samaritanOrange)
                            VStack(alignment: .leading) {
                                Text(anomaly.anomalyReason ?? "Unknown anomaly")
                                    .font(.system(size: 12, design: .monospaced))
                                Text(anomaly.timestamp.formatted())
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Text("Score: \(String(format: "%.2f", anomaly.anomalyScore))")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.vibrantOrange)
                        }
                        .padding(8)
                        .background(Color.samaritanRed.opacity(0.1))
                        .cornerRadius(4)
                    }
                }
            }
        }
    }
}

// MARK: - SNMP Tab

struct SNMPTab: View {
    @ObservedObject var monitor: AdvancedNetworkMonitor
    @Binding var selectedDevice: SNMPDevice?
    @Binding var discoveryNetwork: String
    @Binding var communityString: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("SNMP Device Discovery")
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(.vibrantCyan)

                Spacer()

                // Discovery Controls
                HStack(spacing: 8) {
                    TextField("Network (e.g., 192.168.1)", text: $discoveryNetwork)
                        .textFieldStyle(.plain)
                        .font(.system(size: 12, design: .monospaced))
                        .frame(width: 150)
                        .padding(6)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)

                    SecureField("Community", text: $communityString)
                        .textFieldStyle(.plain)
                        .font(.system(size: 12, design: .monospaced))
                        .frame(width: 100)
                        .padding(6)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)

                    Button(action: {
                        monitor.discoverSNMPDevices(network: discoveryNetwork, community: communityString)
                    }) {
                        HStack(spacing: 4) {
                            if monitor.isDiscovering {
                                ProgressView()
                                    .scaleEffect(0.7)
                            } else {
                                Image(systemName: "arrow.clockwise")
                            }
                            Text(monitor.isDiscovering ? "Scanning..." : "Discover")
                        }
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.vibrantCyan)
                        .cornerRadius(4)
                    }
                    .disabled(monitor.isDiscovering)
                }
            }

            // Device List
            if monitor.snmpDevices.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "network")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    Text("No SNMP devices discovered")
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(.gray)
                    Text("Click 'Discover' to scan your network")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.gray.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(40)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(monitor.snmpDevices, id: \.id) { device in
                        DeviceCard(device: device)
                            .onTapGesture {
                                selectedDevice = device
                            }
                    }
                }
            }

            // Device Details Sheet
            if let device = selectedDevice {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Device Details")
                            .font(.system(size: 16, weight: .semibold, design: .monospaced))
                            .foregroundColor(.vibrantCyan)
                        Spacer()
                        Button("Close") {
                            selectedDevice = nil
                        }
                        .font(.system(size: 12, design: .monospaced))
                    }

                    Divider()

                    AdvancedNetworkDetailRow(label: "Hostname", value: device.hostname)
                    AdvancedNetworkDetailRow(label: "IP Address", value: device.ipAddress)
                    AdvancedNetworkDetailRow(label: "Type", value: device.deviceType.rawValue)
                    AdvancedNetworkDetailRow(label: "Description", value: device.sysDescr)
                    AdvancedNetworkDetailRow(label: "Contact", value: device.sysContact)
                    AdvancedNetworkDetailRow(label: "Location", value: device.sysLocation)
                    AdvancedNetworkDetailRow(label: "Uptime", value: formatUptime(device.sysUpTime))
                    AdvancedNetworkDetailRow(label: "SNMP Version", value: device.version.rawValue)
                    AdvancedNetworkDetailRow(label: "Status", value: device.isReachable ? "Online" : "Offline")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }

    private func formatUptime(_ seconds: TimeInterval) -> String {
        let days = Int(seconds) / 86400
        let hours = (Int(seconds) % 86400) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        return "\(days)d \(hours)h \(minutes)m"
    }
}

// MARK: - Network Topology Tab

struct TopologyTab: View {
    @ObservedObject var monitor: AdvancedNetworkMonitor

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Network Topology")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(.vibrantCyan)

            // Network topology visualization would go here
            // This would be a canvas-based graph showing nodes and connections

            ZStack {
                // Background grid
                Canvas { context, size in
                    let spacing = 40.0
                    context.stroke(
                        Path { path in
                            for x in stride(from: 0, through: size.width, by: spacing) {
                                path.move(to: CGPoint(x: x, y: 0))
                                path.addLine(to: CGPoint(x: x, y: size.height))
                            }
                            for y in stride(from: 0, through: size.height, by: spacing) {
                                path.move(to: CGPoint(x: 0, y: y))
                                path.addLine(to: CGPoint(x: size.width, y: y))
                            }
                        },
                        with: .color(.gray.opacity(0.1)),
                        lineWidth: 0.5
                    )
                }

                VStack(spacing: 20) {
                    Text("Interactive Network Map")
                        .font(.system(size: 16, design: .monospaced))
                        .foregroundColor(.vibrantCyan)

                    // Placeholder for actual topology visualization
                    HStack(spacing: 40) {
                        ForEach(monitor.snmpDevices.prefix(5), id: \.id) { device in
                            VStack(spacing: 8) {
                                Image(systemName: device.deviceType.icon)
                                    .font(.system(size: 32))
                                    .foregroundColor(device.isReachable ? .vibrantGreen : .samaritanRed)
                                Text(device.hostname)
                                    .font(.system(size: 10, design: .monospaced))
                                    .lineLimit(1)
                            }
                        }
                    }
                }
            }
            .frame(height: 400)
            .background(Color.black.opacity(0.3))
            .cornerRadius(8)

            Text("Note: Full topology mapping requires network scanning and device interrogation")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Network Flows Tab

struct FlowsTab: View {
    @ObservedObject var monitor: AdvancedNetworkMonitor

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Network Flows")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(.vibrantCyan)

            if monitor.flows.isEmpty {
                Text("No active network flows")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(40)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(monitor.flows.prefix(50), id: \.id) { flow in
                        FlowRow(flow: flow)
                    }
                }
            }
        }
    }
}

// MARK: - Protocols Tab

struct ProtocolsTab: View {
    @ObservedObject var monitor: AdvancedNetworkMonitor

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Detected Protocols")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(.vibrantCyan)

            if monitor.detectedProtocols.isEmpty {
                Text("No protocols detected yet")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(40)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(monitor.detectedProtocols, id: \.id) { detectedProtocol in
                        ProtocolCard(detectedProtocol: detectedProtocol)
                    }
                }
            }
        }
    }
}

// MARK: - AI Analytics Tab

struct AnalyticsTab: View {
    @ObservedObject var monitor: AdvancedNetworkMonitor

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AI-Powered Analytics")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(.vibrantCyan)

            // Data Collection Status
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Time-Series Data Points")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.gray)
                    Text("\(monitor.historicalData.count)")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(.vibrantGreen)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Coverage")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.gray)
                    Text("\(monitor.historicalData.count * 10 / 3600)h \(monitor.historicalData.count * 10 % 3600 / 60)m")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(.vibrantBlue)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Anomalies Detected")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.gray)
                    Text("\(monitor.historicalData.filter { $0.isAnomaly }.count)")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(.samaritanOrange)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)

            // Export Options
            VStack(alignment: .leading, spacing: 12) {
                Text("Export for ML Training")
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundColor(.vibrantCyan)

                HStack(spacing: 12) {
                    Button(action: {
                        let data = monitor.exportHistoricalData()
                        saveToFile(data, filename: "network_timeseries.json")
                    }) {
                        Label("Export Time-Series Data", systemImage: "doc.text")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.vibrantCyan)
                            .cornerRadius(4)
                    }

                    Button(action: {
                        let data = monitor.exportAlerts()
                        saveToFile(data, filename: "network_alerts.json")
                    }) {
                        Label("Export Alerts", systemImage: "bell")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.vibrantOrange)
                            .cornerRadius(4)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)

            // ML Model Integration Notes
            VStack(alignment: .leading, spacing: 8) {
                Text("Ready for AI Integration")
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundColor(.vibrantGreen)

                Text("• Time-series data collected every 10 seconds")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.gray)
                Text("• Basic statistical anomaly detection active (3-sigma rule)")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.gray)
                Text("• Data format: JSON compatible with TensorFlow, PyTorch, scikit-learn")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.gray)
                Text("• Ready for: LSTM networks, Isolation Forest, Autoencoders")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.vibrantGreen.opacity(0.1))
            .cornerRadius(8)
        }
    }

    private func saveToFile(_ content: String, filename: String) {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = filename
        panel.begin { response in
            if response == .OK, let url = panel.url {
                try? content.write(to: url, atomically: true, encoding: .utf8)
            }
        }
    }
}

// MARK: - Alerts Tab

struct AlertsTab: View {
    @ObservedObject var monitor: AdvancedNetworkMonitor

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Network Alerts")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(.vibrantCyan)

            // Alert Statistics
            HStack(spacing: 16) {
                AlertStatCard(
                    title: "Critical",
                    count: monitor.alerts.filter { $0.severity == .critical }.count,
                    color: .samaritanRed
                )
                AlertStatCard(
                    title: "Warning",
                    count: monitor.alerts.filter { $0.severity == .warning }.count,
                    color: .vibrantOrange
                )
                AlertStatCard(
                    title: "Info",
                    count: monitor.alerts.filter { $0.severity == .info }.count,
                    color: .vibrantBlue
                )
            }

            // Alert List
            if monitor.alerts.isEmpty {
                Text("No alerts")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(40)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(monitor.alerts.reversed(), id: \.id) { alert in
                        AlertRow(alert: alert) {
                            // Acknowledge alert
                            if let index = monitor.alerts.firstIndex(where: { $0.id == alert.id }) {
                                monitor.alerts[index].isAcknowledged = true
                                monitor.alerts[index].acknowledgedAt = Date()
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct NetworkMetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(color)
            Text(subtitle)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.gray.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct DeviceCard: View {
    let device: SNMPDevice

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: device.deviceType.icon)
                    .foregroundColor(device.isReachable ? .vibrantGreen : .gray)
                Spacer()
                Circle()
                    .fill(device.isReachable ? Color.vibrantGreen : Color.samaritanRed)
                    .frame(width: 8, height: 8)
            }
            Text(device.hostname)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .lineLimit(1)
            Text(device.ipAddress)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.gray)
            Text(device.deviceType.rawValue)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.vibrantCyan)
        }
        .padding(12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct AdvancedNetworkDetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.white)
        }
    }
}

struct FlowRow: View {
    let flow: NetworkFlow

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(flow.srcIP):\(flow.srcPort)")
                    .font(.system(size: 11, design: .monospaced))
                Text("→ \(flow.dstIP):\(flow.dstPort)")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.gray)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(flow.protocolType)
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundColor(.vibrantCyan)
                Text("\(flow.packets) packets")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.gray)
            }
        }
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(4)
    }
}

struct ProtocolCard: View {
    let detectedProtocol: DetectedProtocol

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(detectedProtocol.name)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundColor(.vibrantCyan)
            Text(detectedProtocol.category.rawValue)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.gray)
            HStack {
                Text("\(detectedProtocol.packets) packets")
                    .font(.system(size: 10, design: .monospaced))
                Spacer()
                Text(formatBytes(detectedProtocol.bytes))
                    .font(.system(size: 10, design: .monospaced))
            }
            .foregroundColor(.gray)
        }
        .padding(12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }

    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .binary
        return formatter.string(fromByteCount: bytes)
    }
}

struct AlertStatCard: View {
    let title: String
    let count: Int
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct AlertRow: View {
    let alert: NetworkAlert
    let onAcknowledge: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(Color(hex: alert.severity.color))
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(alert.title)
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white)
                    Spacer()
                    Text(alert.timestamp.formatted(date: .omitted, time: .shortened))
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.gray)
                }
                Text(alert.description)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }

            if !alert.isAcknowledged {
                Button(action: onAcknowledge) {
                    Text("Ack")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.vibrantCyan)
                        .cornerRadius(4)
                }
            }
        }
        .padding(12)
        .background(alert.isAcknowledged ? Color.gray.opacity(0.05) : Color.gray.opacity(0.1))
        .cornerRadius(8)
        .opacity(alert.isAcknowledged ? 0.5 : 1.0)
    }
}

struct BandwidthChart: View {
    let data: [NetworkDataPoint]

    var body: some View {
        Chart {
            ForEach(data.suffix(100), id: \.id) { point in
                LineMark(
                    x: .value("Time", point.timestamp),
                    y: .value("In", Double(point.bytesIn) / 1024 / 1024) // MB
                )
                .foregroundStyle(Color.vibrantGreen)

                LineMark(
                    x: .value("Time", point.timestamp),
                    y: .value("Out", Double(point.bytesOut) / 1024 / 1024) // MB
                )
                .foregroundStyle(Color.vibrantOrange)

                if point.isAnomaly {
                    PointMark(
                        x: .value("Time", point.timestamp),
                        y: .value("In", Double(point.bytesIn) / 1024 / 1024)
                    )
                    .foregroundStyle(Color.samaritanRed)
                    .symbolSize(50)
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 6))
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
