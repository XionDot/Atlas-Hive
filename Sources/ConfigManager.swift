import Foundation
import SwiftUI
import AppKit

enum MetricSection: String, Codable, CaseIterable, Identifiable {
    case cpu = "CPU"
    case memory = "Memory"
    case network = "Network"
    case disk = "Disk"
    case battery = "Battery"
    case temperature = "Temperature"
    case fan = "Fan"
    case privacy = "Privacy"

    var id: String { rawValue }
}

enum MetricDisplayMode: String, Codable {
    case graph = "graph"
    case gauge = "gauge"
}

enum ViewMode: String, Codable {
    case simple = "simple"
    case advanced = "advanced"
}

struct Config: Codable {
    var showCPUInMenuBar: Bool = false
    var showMemoryInMenuBar: Bool = false
    var showNetworkInMenuBar: Bool = false  // Disabled - causes crashes
    var showMiniGraphInMenuBar: Bool = false
    var showGraphs: Bool = true
    var updateInterval: Double = 2.0
    var theme: String = "system"
    var sectionOrder: [MetricSection] = [.cpu, .memory, .network, .disk, .temperature, .fan, .battery, .privacy]
    var viewMode: ViewMode = .simple

    // Metric display modes (graph vs gauge)
    var metricDisplayModes: [String: MetricDisplayMode] = [
        "CPU": .graph,
        "Memory": .graph,
        "Network": .graph,
        "Disk": .graph,
        "Temperature": .gauge,
        "Fan": .gauge,
        "Battery": .graph
    ]

    // Window settings
    var showWindowOnLaunch: Bool = true
    var keepMenuBarWhenWindowClosed: Bool = true
    var launchAtStartup: Bool = false

    static let `default` = Config()
}

class ConfigManager: ObservableObject {
    @Published var config: Config {
        didSet {
            saveConfig()
            applyTheme()
        }
    }

    @Published var showSettings: Bool = false
    @Published var showTaskManager: Bool = false

    // Callback to show settings (can be window or tab depending on context)
    var onShowSettings: (() -> Void)?

    // Reference to popover for theme updates
    weak var popover: NSPopover?

    private let configURL: URL

    init() {
        // Get config file path
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appFolder = appSupport.appendingPathComponent("PeakView", isDirectory: true)

        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: appFolder, withIntermediateDirectories: true)

        configURL = appFolder.appendingPathComponent("config.json")

        // Load config or use default
        if let data = try? Data(contentsOf: configURL),
           let loaded = try? JSONDecoder().decode(Config.self, from: data) {
            config = loaded

            // Migrate old configs - add network if missing
            if !config.sectionOrder.contains(.network) {
                var newOrder = config.sectionOrder
                // Insert network after memory
                if let memIndex = newOrder.firstIndex(of: .memory) {
                    newOrder.insert(.network, at: memIndex + 1)
                } else {
                    newOrder.insert(.network, at: 0)
                }
                config.sectionOrder = newOrder
                saveConfig()
            }

            // Migrate old configs - add privacy if missing
            if !config.sectionOrder.contains(.privacy) {
                config.sectionOrder.append(.privacy)
                saveConfig()
            }

            // Migrate old configs - add temperature if missing
            if !config.sectionOrder.contains(.temperature) {
                // Insert temperature before battery or at end
                if let batteryIndex = config.sectionOrder.firstIndex(of: .battery) {
                    config.sectionOrder.insert(.temperature, at: batteryIndex)
                } else {
                    config.sectionOrder.append(.temperature)
                }
                saveConfig()
            }

            // Migrate old configs - add fan if missing
            if !config.sectionOrder.contains(.fan) {
                // Insert fan after temperature or at end
                if let tempIndex = config.sectionOrder.firstIndex(of: .temperature) {
                    config.sectionOrder.insert(.fan, at: tempIndex + 1)
                } else {
                    config.sectionOrder.append(.fan)
                }
                saveConfig()
            }
        } else {
            config = Config.default
            saveConfig()
        }

        // Apply theme on startup
        applyTheme()
    }

    func saveConfig() {
        if let data = try? JSONEncoder().encode(config) {
            try? data.write(to: configURL)
        }
    }

    func resetToDefaults() {
        config = Config.default
    }

    func applyTheme() {
        DispatchQueue.main.async {
            let newAppearance: NSAppearance?
            switch self.config.theme {
            case "light":
                newAppearance = NSAppearance(named: .aqua)
            case "dark":
                newAppearance = NSAppearance(named: .darkAqua)
            default:
                newAppearance = nil // System default
            }

            // DON'T apply to NSApp.appearance globally - this affects menu bar
            // Only apply to specific content windows (not status bar or system windows)

            // Apply to main window and popovers only
            for window in NSApp.windows {
                // Only apply theme to windows with titles or content view controllers
                // Skip system windows (status bar, etc)
                // Include popover windows (.class == NSPopover)
                if window.title == "PeakView" ||
                   (window.contentViewController != nil && window.styleMask.contains(.titled)) ||
                   window.styleMask.contains(.borderless) ||
                   String(describing: type(of: window)).contains("Popover") {
                    window.appearance = newAppearance
                    // Force view hierarchy to update
                    window.contentView?.needsDisplay = true
                    window.contentView?.needsLayout = true
                }
            }

            // Apply theme directly to popover content view
            if let popover = self.popover,
               let contentViewController = popover.contentViewController {
                contentViewController.view.appearance = newAppearance
                contentViewController.view.needsDisplay = true
                contentViewController.view.needsLayout = true
            }

            // Trigger a view refresh by toggling a published property
            self.objectWillChange.send()
        }
    }
}
