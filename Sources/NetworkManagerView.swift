import SwiftUI

struct NetworkManagerView: View {
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var searchText: String = ""
    @State private var selectedConnection: NetworkConnection?
    @State private var selectedFilter: ConnectionFilter = .all
    @State private var showExportSheet: Bool = false
    @State private var sortColumn: SortColumn = .timestamp
    @State private var sortAscending: Bool = false

    // Column visibility states
    @State private var showProcessColumn: Bool = true
    @State private var showPIDColumn: Bool = true
    @State private var showProtoColumn: Bool = true
    @State private var showLocalAddressColumn: Bool = true
    @State private var showRemoteAddressColumn: Bool = true
    @State private var showStateColumn: Bool = true
    @State private var showTrafficColumn: Bool = true

    enum ConnectionFilter: String, CaseIterable {
        case all = "All"
        case tcp = "TCP"
        case udp = "UDP"
        case established = "Established"
        case listening = "Listening"
    }

    enum SortColumn {
        case process, pid, networkProtocol, localAddress, remoteAddress, state, bytes, timestamp
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            VStack(spacing: 0) {
                // Stats Bar with Control Buttons
                statsBarWithControls

                // Filters and Search
                filterBar

                // Main Content - Connection List (full width)
                connectionListView
            }
            .background(Color.darkCard)

            // Connection Details Panel (overlay when selected)
            if let connection = selectedConnection {
                connectionDetailsView(connection: connection)
                    .frame(width: 400)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: -5, y: 0)
                    .transition(.move(edge: .trailing))
            }
        }
    }

    // MARK: - Control Buttons
    private var controlButtons: some View {
        HStack(spacing: 8) {
            Button(action: {
                if networkMonitor.isMonitoring {
                    networkMonitor.stopMonitoring()
                } else {
                    networkMonitor.startMonitoring()
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: networkMonitor.isMonitoring ? "pause.fill" : "play.fill")
                    Text(networkMonitor.isMonitoring ? "Pause" : "Start")
                }
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    LinearGradient(
                        colors: networkMonitor.isMonitoring ? [.orange, .red] : [.green, .mint],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(6)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(networkMonitor.isMonitoring ? "Pause Monitoring" : "Start Monitoring")

            Button(action: {
                networkMonitor.clearConnections()
            }) {
                Image(systemName: "trash")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.red, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 24, height: 24)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help("Clear All Connections")

            Button(action: {
                exportConnections()
            }) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 24, height: 24)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help("Export Connections to CSV")

            Button(action: {
                networkMonitor.updateConnections()
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 24, height: 24)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help("Refresh Connection List")

            // Column visibility menu
            Menu {
                Toggle("Process", isOn: $showProcessColumn)
                Toggle("PID", isOn: $showPIDColumn)
                Toggle("Protocol", isOn: $showProtoColumn)
                Toggle("Local Address", isOn: $showLocalAddressColumn)
                Toggle("Remote Address", isOn: $showRemoteAddressColumn)
                Toggle("State", isOn: $showStateColumn)
                Toggle("Traffic", isOn: $showTrafficColumn)
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(width: 24, height: 24)
                    .contentShape(Rectangle())
            }
            .menuIndicator(.hidden)
            .fixedSize()
            .help("Show/Hide Columns")
        }
    }

    // MARK: - Stats Bar with Controls
    private var statsBarWithControls: some View {
        HStack(spacing: 0) {
            // Left side: Stats badges
            HStack(spacing: 20) {
                StatBadge(
                    icon: "network",
                    label: "Connections",
                    value: "\(networkMonitor.stats.activeConnections)",
                    color: .purple
                )

                StatBadge(
                    icon: "arrow.up.arrow.down",
                    label: "Total Traffic",
                    value: formatBytes(networkMonitor.stats.totalBytes),
                    color: .blue
                )

                StatBadge(
                    icon: "speedometer",
                    label: "Bytes/s",
                    value: formatBytes(Int64(networkMonitor.stats.bytesPerSecond)),
                    color: .green
                )
            }

            Spacer()

            // Right side: Monitoring status + control buttons
            HStack(spacing: 12) {
                if networkMonitor.isMonitoring {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("Monitoring")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }

                controlButtons
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.darkCard.opacity(0.5))
    }

    // MARK: - Filter Bar
    private var filterBar: some View {
        HStack(spacing: 12) {
            // Search
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 12))

                TextField("Search process, address, or port...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12))

                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(NSColor.textBackgroundColor))
            .cornerRadius(6)
            .frame(width: 300)

            // Protocol Filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(ConnectionFilter.allCases, id: \.self) { filter in
                        FilterChip(
                            title: filter.rawValue,
                            isSelected: selectedFilter == filter,
                            action: { selectedFilter = filter }
                        )
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.darkCard.opacity(0.3))
    }

    // MARK: - Connection List
    private var connectionListView: some View {
        VStack(spacing: 0) {
            // Table Header
            connectionTableHeader

            Divider()

            // Table Content
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(sortedConnections) { connection in
                        ConnectionRow(
                            connection: connection,
                            isSelected: selectedConnection?.id == connection.id,
                            showProcess: showProcessColumn,
                            showPID: showPIDColumn,
                            showProto: showProtoColumn,
                            showLocal: showLocalAddressColumn,
                            showRemote: showRemoteAddressColumn,
                            showState: showStateColumn,
                            showTraffic: showTrafficColumn
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedConnection = connection
                        }

                        Divider()
                    }
                }
            }

            if sortedConnections.isEmpty {
                emptyStateView
            }
        }
        .background(Color(NSColor.textBackgroundColor))
    }

    private var connectionTableHeader: some View {
        HStack(spacing: 8) {
            if showProcessColumn {
                HeaderCell(title: "Process", width: nil, sortColumn: .process, currentSort: $sortColumn, ascending: $sortAscending)
                    .frame(minWidth: 120, idealWidth: 140, maxWidth: 180)
                    .layoutPriority(2)
            }
            if showPIDColumn {
                HeaderCell(title: "PID", width: 60, sortColumn: .pid, currentSort: $sortColumn, ascending: $sortAscending)
                    .layoutPriority(1)
            }
            if showProtoColumn {
                HeaderCell(title: "Proto", width: 70, sortColumn: .networkProtocol, currentSort: $sortColumn, ascending: $sortAscending)
                    .layoutPriority(1)
            }
            if showLocalAddressColumn {
                HeaderCell(title: "Local Address", width: nil, sortColumn: .localAddress, currentSort: $sortColumn, ascending: $sortAscending)
                    .frame(minWidth: 120, idealWidth: 150, maxWidth: .infinity)
                    .layoutPriority(1)
            }
            if showRemoteAddressColumn {
                HeaderCell(title: "Remote Address", width: nil, sortColumn: .remoteAddress, currentSort: $sortColumn, ascending: $sortAscending)
                    .frame(minWidth: 120, idealWidth: 150, maxWidth: .infinity)
                    .layoutPriority(1)
            }
            if showStateColumn {
                HeaderCell(title: "State", width: 110, sortColumn: .state, currentSort: $sortColumn, ascending: $sortAscending)
                    .layoutPriority(1)
            }
            if showTrafficColumn {
                HeaderCell(title: "Traffic", width: 100, sortColumn: .bytes, currentSort: $sortColumn, ascending: $sortAscending)
                    .layoutPriority(1)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.darkCard)
    }

    // MARK: - Connection Details
    private func connectionDetailsView(connection: NetworkConnection) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("Connection Details")
                    .font(.system(size: 15, weight: .bold))

                Spacer()

                Button(action: {
                    selectedConnection = nil
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color.darkCard)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Process Info
                    DetailSection(title: "Process Information") {
                        NetworkDetailRow(label: "Name", value: connection.processName)
                        NetworkDetailRow(label: "PID", value: "\(connection.processID)")
                    }

                    // Connection Info
                    DetailSection(title: "Connection") {
                        NetworkDetailRow(label: "Protocol", value: connection.networkProtocol.rawValue)
                        NetworkDetailRow(label: "State", value: connection.state.rawValue)
                        NetworkDetailRow(label: "Local", value: "\(connection.localAddress):\(connection.localPort)")
                        NetworkDetailRow(label: "Remote", value: "\(connection.remoteAddress):\(connection.remotePort)")
                    }

                    // Traffic Stats
                    DetailSection(title: "Traffic Statistics") {
                        NetworkDetailRow(label: "Received", value: connection.downloadSpeed, color: .green)
                        NetworkDetailRow(label: "Sent", value: connection.uploadSpeed, color: .blue)
                        NetworkDetailRow(label: "Total", value: connection.totalTraffic, color: .purple)
                    }

                    // Timestamp
                    DetailSection(title: "Timing") {
                        NetworkDetailRow(label: "Started", value: formatDate(connection.timestamp))
                    }
                }
                .padding()
            }
        }
        .background(Color(NSColor.textBackgroundColor))
    }

    private var emptyDetailsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "info.circle")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.5))

            Text("No Connection Selected")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)

            Text("Select a connection to view details")
                .font(.system(size: 12))
                .foregroundColor(.secondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.textBackgroundColor))
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "network.slash")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.5))

            Text("No Connections")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)

            Text(networkMonitor.isMonitoring ? "Waiting for network activity..." : "Click Start to begin monitoring")
                .font(.system(size: 12))
                .foregroundColor(.secondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Computed Properties
    private var filteredConnections: [NetworkConnection] {
        var connections = networkMonitor.connections

        // Apply filter
        switch selectedFilter {
        case .all:
            break
        case .tcp:
            connections = connections.filter { $0.networkProtocol == .tcp }
        case .udp:
            connections = connections.filter { $0.networkProtocol == .udp }
        case .established:
            connections = connections.filter { $0.state == .established }
        case .listening:
            connections = connections.filter { $0.state == .listen }
        }

        // Apply search
        if !searchText.isEmpty {
            connections = connections.filter {
                $0.processName.localizedCaseInsensitiveContains(searchText) ||
                $0.localAddress.contains(searchText) ||
                $0.remoteAddress.contains(searchText) ||
                "\($0.localPort)".contains(searchText) ||
                "\($0.remotePort)".contains(searchText)
            }
        }

        return connections
    }

    private var sortedConnections: [NetworkConnection] {
        filteredConnections.sorted { conn1, conn2 in
            let result: Bool
            switch sortColumn {
            case .process:
                result = conn1.processName < conn2.processName
            case .pid:
                result = conn1.processID < conn2.processID
            case .networkProtocol:
                result = conn1.networkProtocol.rawValue < conn2.networkProtocol.rawValue
            case .localAddress:
                result = conn1.localAddress < conn2.localAddress
            case .remoteAddress:
                result = conn2.remoteAddress < conn2.remoteAddress
            case .state:
                result = conn1.state.rawValue < conn2.state.rawValue
            case .bytes:
                result = (conn1.bytesReceived + conn1.bytesSent) < (conn2.bytesReceived + conn2.bytesSent)
            case .timestamp:
                result = conn1.timestamp < conn2.timestamp
            }
            return sortAscending ? result : !result
        }
    }

    // MARK: - Helper Methods
    private func formatBytes(_ bytes: Int64) -> String {
        let double = Double(bytes)
        if double < 1024 {
            return String(format: "%.0f B", double)
        } else if double < 1024 * 1024 {
            return String(format: "%.2f KB", double / 1024)
        } else if double < 1024 * 1024 * 1024 {
            return String(format: "%.2f MB", double / (1024 * 1024))
        } else {
            return String(format: "%.2f GB", double / (1024 * 1024 * 1024))
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }

    private func exportConnections() {
        let csv = networkMonitor.exportConnections()

        let savePanel = NSSavePanel()
        savePanel.title = "Export Network Connections"
        savePanel.nameFieldStringValue = "network_connections.csv"
        savePanel.allowedContentTypes = [.commaSeparatedText]

        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                do {
                    try csv.write(to: url, atomically: true, encoding: .utf8)
                } catch {
                    print("Export error: \(error)")
                }
            }
        }
    }
}

// MARK: - Supporting Views
struct ConnectionRow: View {
    let connection: NetworkConnection
    let isSelected: Bool
    let showProcess: Bool
    let showPID: Bool
    let showProto: Bool
    let showLocal: Bool
    let showRemote: Bool
    let showState: Bool
    let showTraffic: Bool

    var body: some View {
        HStack(spacing: 8) {
            if showProcess {
                Text(connection.processName)
                    .font(.system(size: 11, weight: .medium))
                    .frame(minWidth: 120, idealWidth: 140, maxWidth: 180, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .layoutPriority(2)
            }

            if showPID {
                Text("\(connection.processID)")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.secondary)
                    .frame(width: 60, alignment: .leading)
                    .layoutPriority(1)
            }

            if showProto {
                Text(connection.networkProtocol.rawValue)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(protocolColor)
                    .frame(width: 70, alignment: .leading)
                    .layoutPriority(1)
            }

            if showLocal {
                Text("\(connection.localAddress):\(connection.localPort)")
                    .font(.system(size: 11, design: .monospaced))
                    .frame(minWidth: 120, idealWidth: 150, maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .layoutPriority(1)
            }

            if showRemote {
                Text("\(connection.remoteAddress):\(connection.remotePort)")
                    .font(.system(size: 11, design: .monospaced))
                    .frame(minWidth: 120, idealWidth: 150, maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .layoutPriority(1)
            }

            if showState {
                Text(connection.state.rawValue)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(stateColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(stateColor.opacity(0.15))
                    .cornerRadius(4)
                    .frame(width: 110, alignment: .leading)
                    .layoutPriority(1)
            }

            if showTraffic {
                Text(connection.totalTraffic)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(width: 100, alignment: .trailing)
                    .layoutPriority(1)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
    }

    private var protocolColor: Color {
        switch connection.networkProtocol {
        case .tcp: return .blue
        case .udp: return .green
        case .icmp: return .orange
        case .other: return .secondary
        }
    }

    private var stateColor: Color {
        switch connection.state {
        case .established: return .green
        case .listen: return .blue
        case .closeWait, .closing, .lastAck, .timeWait, .closed: return .orange
        default: return .secondary
        }
    }
}

struct HeaderCell: View {
    let title: String
    let width: CGFloat?
    let sortColumn: NetworkManagerView.SortColumn
    @Binding var currentSort: NetworkManagerView.SortColumn
    @Binding var ascending: Bool

    var body: some View {
        Button(action: {
            if currentSort == sortColumn {
                ascending.toggle()
            } else {
                currentSort = sortColumn
                ascending = true
            }
        }) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)

                if currentSort == sortColumn {
                    Image(systemName: ascending ? "chevron.up" : "chevron.down")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: width, alignment: .leading)
        }
        .buttonStyle(.plain)
    }
}

struct StatBadge: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)

                Text(value)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct DetailSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.primary)
                .textCase(.uppercase)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 6) {
                content
            }
            .padding(12)
            .background(Color.darkCard.opacity(0.5))
            .cornerRadius(8)
        }
    }
}

struct NetworkDetailRow: View {
    let label: String
    let value: String
    var color: Color = .primary

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundColor(color)
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(
                    isSelected ?
                        LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing) :
                        LinearGradient(colors: [Color.darkCard], startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: isSelected ? 0 : 1)
                )
        }
        .buttonStyle(.plain)
    }
}
