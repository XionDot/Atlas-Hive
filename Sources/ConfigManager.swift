import Foundation
import SwiftUI
import AppKit

enum MetricSection: String, Codable, CaseIterable {
    case cpu = "CPU"
    case memory = "Memory"
    case network = "Network"
    case disk = "Disk"
    case battery = "Battery"
    case privacy = "Privacy"
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
    var sectionOrder: [MetricSection] = [.cpu, .memory, .network, .disk, .battery, .privacy]
    var viewMode: ViewMode = .simple

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

    private let configURL: URL

    init() {
        // Get config file path
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appFolder = appSupport.appendingPathComponent("Desktopie", isDirectory: true)

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

            NSApp.appearance = newAppearance

            // Force refresh all windows
            for window in NSApp.windows {
                window.appearance = newAppearance
            }
        }
    }
}
