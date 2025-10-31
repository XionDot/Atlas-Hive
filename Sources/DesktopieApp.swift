import SwiftUI
import AppKit

@main
struct DesktopieApp: App {
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
    var systemMonitor: SystemMonitor?
    var configManager: ConfigManager?
    var privacyManager: PrivacyManager?
    var eventMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize managers
        configManager = ConfigManager()
        systemMonitor = SystemMonitor()
        privacyManager = PrivacyManager()

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
        }

        // Create popover
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 360, height: 480)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: ContentView(
                systemMonitor: systemMonitor!,
                configManager: configManager!
            )
        )
        self.popover = popover
    }

    @objc func handleClick(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!

        if event.type == .rightMouseUp {
            showMenu()
        } else {
            togglePopover()
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

        // Task Manager
        let taskManagerItem = NSMenuItem(title: "Task Manager", action: #selector(openTaskManager), keyEquivalent: "")
        taskManagerItem.target = self
        menu.addItem(taskManagerItem)

        menu.addItem(NSMenuItem.separator())

        // Quit
        let quitItem = NSMenuItem(title: "Quit Desktopie", action: #selector(quit), keyEquivalent: "q")
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

    @objc func openTaskManager() {
        // Open task manager in a new window
        let taskManager = TaskManager()
        let taskManagerView = TaskManagerView(taskManager: taskManager)
        let hostingController = NSHostingController(rootView: taskManagerView)

        let window = NSWindow(contentViewController: hostingController)
        window.title = "Task Manager"
        window.styleMask = [.titled, .closable, .resizable]
        window.setContentSize(NSSize(width: 600, height: 500))
        window.center()
        window.makeKeyAndOrderFront(nil)
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
        let downloadSpeed = monitor.networkDownload
        let uploadSpeed = monitor.networkUpload

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
            if config.showNetworkInMenuBar {
                displayText += formatNetworkSpeed(downloadSpeed, uploadSpeed)
            }

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

        // Draw CPU bar (blue)
        let cpuHeight = max(1, (cpuValue / 100.0) * height)
        NSColor.systemBlue.setFill()
        let cpuRect = NSRect(x: spacing, y: 0, width: barWidth, height: cpuHeight)
        NSBezierPath(rect: cpuRect).fill()

        // Draw CPU outline
        NSColor.systemBlue.withAlphaComponent(0.3).setStroke()
        let cpuOutline = NSBezierPath(rect: NSRect(x: spacing, y: 0, width: barWidth, height: height))
        cpuOutline.lineWidth = 0.5
        cpuOutline.stroke()

        // Draw Memory bar (green)
        let memHeight = max(1, (memoryValue / 100.0) * height)
        NSColor.systemGreen.setFill()
        let memRect = NSRect(x: spacing + barWidth + spacing, y: 0, width: barWidth, height: memHeight)
        NSBezierPath(rect: memRect).fill()

        // Draw Memory outline
        NSColor.systemGreen.withAlphaComponent(0.3).setStroke()
        let memOutline = NSBezierPath(rect: NSRect(x: spacing + barWidth + spacing, y: 0, width: barWidth, height: height))
        memOutline.lineWidth = 0.5
        memOutline.stroke()

        image.unlockFocus()

        image.isTemplate = false
        return image
    }

    func createDefaultMenuBarIcon() -> NSImage {
        let size: CGFloat = 18
        let image = NSImage(size: NSSize(width: size, height: size))

        image.lockFocus()

        // Clear background
        NSColor.clear.setFill()
        NSBezierPath(rect: NSRect(x: 0, y: 0, width: size, height: size)).fill()

        // Draw a circular gauge/activity monitor style icon
        let centerX = size / 2
        let centerY = size / 2
        let radius: CGFloat = 7

        // Draw outer circle
        let outerCircle = NSBezierPath()
        outerCircle.appendArc(
            withCenter: NSPoint(x: centerX, y: centerY),
            radius: radius,
            startAngle: 0,
            endAngle: 360
        )
        NSColor.labelColor.withAlphaComponent(0.6).setStroke()
        outerCircle.lineWidth = 1.5
        outerCircle.stroke()

        // Draw inner activity bars (like a simplified activity monitor)
        let barCount = 4
        let barSpacing: CGFloat = 1.5
        let barWidth: CGFloat = 1.2
        let barHeights: [CGFloat] = [4, 6, 5, 3] // Varying heights for visual interest

        for i in 0..<barCount {
            let x = centerX - (CGFloat(barCount) * (barWidth + barSpacing)) / 2 + CGFloat(i) * (barWidth + barSpacing) + barSpacing
            let height = barHeights[i]
            let y = centerY - height / 2

            let barRect = NSRect(x: x, y: y, width: barWidth, height: height)
            NSColor.labelColor.withAlphaComponent(0.7).setFill()
            NSBezierPath(rect: barRect).fill()
        }

        image.unlockFocus()

        image.isTemplate = true  // Use template mode for proper light/dark mode support
        return image
    }
}
