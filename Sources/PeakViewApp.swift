import SwiftUI
import AppKit

@main
struct PeakViewApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var mainWindow: NSWindow?
    var loadingWindow: NSWindow?
    var systemMonitor: SystemMonitor?
    var taskManager: TaskManager?
    var configManager: ConfigManager?
    var privacyManager: PrivacyManager?
    var alertManager: AlertManager?
    var eventMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize config manager first to get theme
        configManager = ConfigManager()

        // Show loading screen with app theme
        showLoadingScreen()

        // Initialize other managers
        systemMonitor = SystemMonitor()
        taskManager = TaskManager()
        privacyManager = PrivacyManager()
        alertManager = AlertManager()

        // Setup callback for settings button to show main window with settings open
        configManager?.onShowSettings = { [weak self] in
            guard let self = self else { return }
            // Show the main window first
            self.showMainWindow()
            // Then trigger settings panel to open
            DispatchQueue.main.async {
                self.configManager?.showSettings = true
            }
        }

        // Create menu bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            updateMenuBarDisplay()
            button.action = #selector(handleClick(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.target = self
        }

        // Setup monitoring timer
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.updateMenuBarDisplay()
            self?.checkResourceAlerts()
        }

        // Create popover (for compact menu bar view)
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 360, height: 600)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: ContentView(
                systemMonitor: systemMonitor!,
                configManager: configManager!,
                alertManager: alertManager!
            )
        )
        self.popover = popover

        // Give config manager reference to popover for theme updates
        configManager?.popover = popover

        // Create main window with two-column layout
        createMainWindow()

        // Apply theme after windows are created
        configManager?.applyTheme()

        // Note: Main window will be shown after loading screen completes in hideLoadingScreen()
    }

    func createMainWindow() {
        guard let systemMonitor = systemMonitor,
              let taskManager = taskManager,
              let configManager = configManager,
              let alertManager = alertManager else { return }

        let mainView = MainWindowView(
            monitor: systemMonitor,
            taskManager: taskManager,
            configManager: configManager,
            alertManager: alertManager
        )

        let hostingController = NSHostingController(rootView: mainView)
        let window = NSWindow(contentViewController: hostingController)
        window.title = "PeakView"
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView]
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.setContentSize(NSSize(width: 1200, height: 700))
        window.minSize = NSSize(width: 1200, height: 700)
        window.center()
        window.isReleasedWhenClosed = false
        window.delegate = self

        // Configure fullscreen to show menu bar
        window.collectionBehavior = [.fullScreenPrimary, .fullScreenAllowsTiling]

        // Set pure black background for title bar
        window.backgroundColor = .black

        self.mainWindow = window
    }

    func showMainWindow() {
        guard let window = mainWindow else { return }

        // Ensure window is visible and brought to front
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()

        // Activate the app
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func handleClick(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!

        if event.type == .rightMouseUp {
            showMenu()
        } else {
            // Smart click behavior based on window state
            if let window = mainWindow {
                if window.isMiniaturized {
                    // Window is minimized - restore it
                    window.deminiaturize(nil)
                    showMainWindow()
                } else if window.isVisible {
                    // Window is open and visible - show main window
                    showMainWindow()
                } else {
                    // Window is closed (hidden) - show popover
                    togglePopover()
                }
            } else {
                // Fallback - show popover
                togglePopover()
            }
        }
    }

    func showMenu() {
        guard let privacyManager = privacyManager else { return }

        let menu = NSMenu()

        // Privacy section
        menu.addItem(NSMenuItem(title: "Privacy Controls", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())

        // Camera toggle
        let cameraItem = NSMenuItem(
            title: privacyManager.cameraEnabled ? "🟢 Camera Enabled" : "🔴 Camera Disabled",
            action: #selector(toggleCamera),
            keyEquivalent: ""
        )
        cameraItem.target = self
        menu.addItem(cameraItem)

        // Microphone toggle
        let micItem = NSMenuItem(
            title: privacyManager.microphoneEnabled ? "🟢 Microphone Enabled" : "🔴 Microphone Disabled",
            action: #selector(toggleMicrophone),
            keyEquivalent: ""
        )
        micItem.target = self
        menu.addItem(micItem)

        // USB toggle
        let usbItem = NSMenuItem(
            title: privacyManager.usbEnabled ? "🟢 USB Enabled" : "🔴 USB Disabled",
            action: #selector(toggleUSB),
            keyEquivalent: ""
        )
        usbItem.target = self
        menu.addItem(usbItem)

        menu.addItem(NSMenuItem.separator())

        // Show Window
        let showWindowItem = NSMenuItem(title: "Show PeakView Window", action: #selector(showMainWindowMenu), keyEquivalent: "")
        showWindowItem.target = self
        menu.addItem(showWindowItem)

        // Fullscreen toggle
        let fullscreenTitle = mainWindow?.styleMask.contains(.fullScreen) == true ? "Exit Fullscreen" : "Enter Fullscreen"
        let fullscreenItem = NSMenuItem(title: fullscreenTitle, action: #selector(toggleFullscreen), keyEquivalent: "f")
        fullscreenItem.target = self
        menu.addItem(fullscreenItem)

        menu.addItem(NSMenuItem.separator())

        // Quit
        let quitItem = NSMenuItem(title: "Quit PeakView", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }

    @objc func toggleCamera() {
        privacyManager?.toggleCamera()
    }

    @objc func toggleMicrophone() {
        privacyManager?.toggleMicrophone()
    }

    @objc func toggleUSB() {
        privacyManager?.toggleUSB()
    }

    @objc func showMainWindowMenu() {
        showMainWindow()
    }

    @objc func toggleFullscreen() {
        mainWindow?.toggleFullScreen(nil)
    }

    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }

    @objc func togglePopover() {
        if let popover = popover {
            if popover.isShown {
                closePopover()
            } else {
                showPopover()
            }
        }
    }

    func showPopover() {
        if let button = statusItem?.button {
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)

            // Setup event monitor to close popover when clicking outside
            eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
                self?.closePopover()
            }
        }
    }

    func closePopover() {
        popover?.performClose(nil)

        // Remove event monitor
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }

    func updateMenuBarDisplay() {
        guard let monitor = systemMonitor, let button = statusItem?.button else { return }

        let cpuUsage = monitor.getCPUUsage()
        let (memoryUsage, _, _) = monitor.getMemoryInfo()

        let config = configManager?.config ?? Config.default

        if config.showMiniGraphInMenuBar {
            // Show graph icon with custom drawing
            let image = createMiniGraphImage(cpuValue: cpuUsage, memoryValue: memoryUsage)
            button.image = image
            button.title = ""
        } else {
            // Show text
            var displayText = ""
            if config.showCPUInMenuBar {
                displayText += String(format: "CPU: %.0f%% ", cpuUsage)
            }
            if config.showMemoryInMenuBar {
                displayText += String(format: "MEM: %.0f%% ", memoryUsage)
            }
            // Network speed display removed - causes crashes

            if displayText.isEmpty {
                // Show custom icon when no stats selected
                button.image = createDefaultMenuBarIcon()
                button.title = ""
            } else {
                button.image = nil
                button.title = displayText
            }
        }
    }

    func formatNetworkSpeed(_ download: Double, _ upload: Double) -> String {
        let down = formatSpeed(download)
        let up = formatSpeed(upload)
        return "↓\(down) ↑\(up)"
    }

    func formatSpeed(_ bytesPerSecond: Double) -> String {
        if bytesPerSecond < 1024 {
            return String(format: "%.0fB/s", bytesPerSecond)
        } else if bytesPerSecond < 1024 * 1024 {
            return String(format: "%.0fK/s", bytesPerSecond / 1024)
        } else {
            return String(format: "%.1fM/s", bytesPerSecond / (1024 * 1024))
        }
    }

    func createMiniGraphImage(cpuValue: Double, memoryValue: Double) -> NSImage {
        let width: CGFloat = 30
        let height: CGFloat = 16
        let barWidth: CGFloat = 4
        let spacing: CGFloat = 2

        let image = NSImage(size: NSSize(width: width, height: height))

        image.lockFocus()

        // Clear background
        NSColor.clear.setFill()
        NSBezierPath(rect: NSRect(x: 0, y: 0, width: width, height: height)).fill()

        // Draw CPU bar (white for dark menu bar)
        let cpuHeight = max(1, (cpuValue / 100.0) * height)
        NSColor.white.setFill()
        let cpuRect = NSRect(x: spacing, y: 0, width: barWidth, height: cpuHeight)
        NSBezierPath(rect: cpuRect).fill()

        // Draw CPU outline
        NSColor.white.withAlphaComponent(0.3).setStroke()
        let cpuOutline = NSBezierPath(rect: NSRect(x: spacing, y: 0, width: barWidth, height: height))
        cpuOutline.lineWidth = 0.5
        cpuOutline.stroke()

        // Draw Memory bar (white for dark menu bar)
        let memHeight = max(1, (memoryValue / 100.0) * height)
        NSColor.white.setFill()
        let memRect = NSRect(x: spacing + barWidth + spacing, y: 0, width: barWidth, height: memHeight)
        NSBezierPath(rect: memRect).fill()

        // Draw Memory outline
        NSColor.white.withAlphaComponent(0.3).setStroke()
        let memOutline = NSBezierPath(rect: NSRect(x: spacing + barWidth + spacing, y: 0, width: barWidth, height: height))
        memOutline.lineWidth = 0.5
        memOutline.stroke()

        image.unlockFocus()

        // No isTemplate - always white for dark menu bar
        return image
    }

    func createDefaultMenuBarIcon() -> NSImage {
        // Try to load the PNG icon and tint it white
        let iconName = "alert_status_menubar"

        if let resourcePath = Bundle.main.resourcePath {
            let iconPath = "\(resourcePath)/menubar_icons/\(iconName)@2x.png"
            if let sourceImage = NSImage(contentsOfFile: iconPath) {
                // Create a white-tinted version
                let size = NSSize(width: 18, height: 18)
                let tintedImage = NSImage(size: size)

                tintedImage.lockFocus()

                // Draw the original image
                sourceImage.draw(in: NSRect(origin: .zero, size: size))

                // Apply white tint
                NSColor.white.set()
                NSRect(origin: .zero, size: size).fill(using: .sourceAtop)

                tintedImage.unlockFocus()
                return tintedImage
            }
        }

        // Fallback: draw white icon
        let size: CGFloat = 18
        let image = NSImage(size: NSSize(width: size, height: size))
        image.lockFocus()

        NSColor.clear.setFill()
        NSBezierPath(rect: NSRect(x: 0, y: 0, width: size, height: size)).fill()

        let centerX = size / 2
        let centerY = size / 2
        let radius: CGFloat = 7

        let outerCircle = NSBezierPath()
        outerCircle.appendArc(withCenter: NSPoint(x: centerX, y: centerY), radius: radius, startAngle: 0, endAngle: 360)
        NSColor.white.withAlphaComponent(0.8).setStroke()
        outerCircle.lineWidth = 1.5
        outerCircle.stroke()

        let barCount = 4
        let barSpacing: CGFloat = 1.5
        let barWidth: CGFloat = 1.2
        let barHeights: [CGFloat] = [4, 6, 5, 3]

        for i in 0..<barCount {
            let x = centerX - (CGFloat(barCount) * (barWidth + barSpacing)) / 2 + CGFloat(i) * (barWidth + barSpacing) + barSpacing
            let height = barHeights[i]
            let y = centerY - height / 2
            let barRect = NSRect(x: x, y: y, width: barWidth, height: height)
            NSColor.white.withAlphaComponent(0.9).setFill()
            NSBezierPath(rect: barRect).fill()
        }

        image.unlockFocus()
        return image
    }

    func checkResourceAlerts() {
        guard let monitor = systemMonitor, let alertManager = alertManager else { return }

        alertManager.checkResourceUsage(
            cpu: monitor.cpuUsage,
            memory: monitor.memoryUsage,
            disk: monitor.diskUsage
        )
    }

    func showLoadingScreen() {
        guard let configManager = configManager else { return }

        // Create loading view with app theme
        let loadingView = PeakViewLoadingView(
            isShowing: .constant(true),
            appTheme: configManager.config.theme
        )

        // Create window for loading screen
        let hostingController = NSHostingController(rootView: loadingView)
        let window = NSWindow(contentViewController: hostingController)
        window.styleMask = [.borderless, .fullSizeContentView]

        // Set background based on app theme
        let isDarkMode: Bool
        switch configManager.config.theme {
        case "light":
            isDarkMode = false
        case "dark":
            isDarkMode = true
        default: // "system"
            isDarkMode = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        }
        window.backgroundColor = isDarkMode ? .black : .white

        // Apply theme appearance to window
        let appearance: NSAppearance?
        switch configManager.config.theme {
        case "light":
            appearance = NSAppearance(named: .aqua)
        case "dark":
            appearance = NSAppearance(named: .darkAqua)
        default:
            appearance = nil
        }
        window.appearance = appearance

        window.isOpaque = true
        window.hasShadow = false
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]

        // Set window size to match main window (1200x700)
        window.setContentSize(NSSize(width: 1200, height: 700))
        window.center()

        self.loadingWindow = window
        window.makeKeyAndOrderFront(nil)

        // Schedule loading completion after 3.5 seconds (loading animation is 3 seconds + 0.5s buffer)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in
            self?.hideLoadingScreen()
        }
    }

    func hideLoadingScreen() {
        loadingWindow?.close()
        loadingWindow = nil

        // Show main window after loading completes (if configured)
        if configManager?.config.showWindowOnLaunch ?? true {
            showMainWindow()
        }
    }
}

// MARK: - NSWindowDelegate
extension AppDelegate: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        // Hide window instead of closing it (keeping menu bar active)
        if sender == mainWindow {
            if configManager?.config.keepMenuBarWhenWindowClosed ?? true {
                mainWindow?.orderOut(nil)
                return false
            }
        }
        return true
    }
}
