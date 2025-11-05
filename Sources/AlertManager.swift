import Foundation
import UserNotifications
import Combine

class AlertManager: ObservableObject {
    @Published var alertsEnabled: Bool = true
    @Published var cpuThreshold: Double = 80.0
    @Published var memoryThreshold: Double = 80.0
    @Published var diskThreshold: Double = 90.0

    private var lastCPUAlert: Date?
    private var lastMemoryAlert: Date?
    private var lastDiskAlert: Date?

    private let alertCooldown: TimeInterval = 300 // 5 minutes between same type of alerts

    init() {
        // Request notification permission
        requestNotificationPermission()
    }

    private func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }

    func checkResourceUsage(cpu: Double, memory: Double, disk: Double) {
        guard alertsEnabled else { return }

        // Check CPU
        if cpu > cpuThreshold {
            if shouldSendAlert(lastAlert: lastCPUAlert) {
                sendNotification(
                    title: "High CPU Usage",
                    body: String(format: "CPU usage is at %.0f%%", cpu),
                    identifier: "cpu_alert"
                )
                lastCPUAlert = Date()
            }
        }

        // Check Memory
        if memory > memoryThreshold {
            if shouldSendAlert(lastAlert: lastMemoryAlert) {
                sendNotification(
                    title: "High Memory Usage",
                    body: String(format: "Memory usage is at %.0f%%", memory),
                    identifier: "memory_alert"
                )
                lastMemoryAlert = Date()
            }
        }

        // Check Disk
        if disk > diskThreshold {
            if shouldSendAlert(lastAlert: lastDiskAlert) {
                sendNotification(
                    title: "Low Disk Space",
                    body: String(format: "Disk usage is at %.0f%%", disk),
                    identifier: "disk_alert"
                )
                lastDiskAlert = Date()
            }
        }
    }

    private func shouldSendAlert(lastAlert: Date?) -> Bool {
        guard let lastAlert = lastAlert else { return true }
        return Date().timeIntervalSince(lastAlert) > alertCooldown
    }

    private func sendNotification(title: String, body: String, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: nil // Immediate delivery
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification error: \(error.localizedDescription)")
            }
        }
    }
}
