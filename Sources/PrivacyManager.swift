import Foundation
import AVFoundation
import AppKit

class PrivacyManager: ObservableObject {
    @Published var cameraEnabled: Bool = true
    @Published var microphoneEnabled: Bool = true
    @Published var usbEnabled: Bool = true

    private var updateTimer: Timer?
    private let authHelper = AuthorizationHelper()

    init() {
        // Don't check status immediately to avoid AttributeGraph cycles
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.checkCurrentStatus()
        }

        // Setup periodic status check every 5 seconds
        updateTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.checkCurrentStatus()
        }
    }

    func checkCurrentStatus() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }

            // Check if any apps have camera/microphone permissions
            let cameraStatus = self.hasAnyTCCPermissions("kTCCServiceCamera")
            let micStatus = self.hasAnyTCCPermissions("kTCCServiceMicrophone")
            let usbStatus = true // USB cannot be controlled, always show as enabled

            DispatchQueue.main.async {
                self.cameraEnabled = cameraStatus
                self.microphoneEnabled = micStatus
                self.usbEnabled = usbStatus
            }
        }
    }

    private func hasAnyTCCPermissions(_ service: String) -> Bool {
        // Check if any apps have permissions for this service
        let dbPath = "\(NSHomeDirectory())/Library/Application Support/com.apple.TCC/TCC.db"
        let result = executeShellCommand("sqlite3 '\(dbPath)' 'SELECT COUNT(*) FROM access WHERE service=\"\(service)\" AND allowed=1;' 2>/dev/null || echo '0'")
        let trimmed = result.trimmingCharacters(in: .whitespacesAndNewlines)
        let count = Int(trimmed) ?? 0
        print("Checking TCC \(service): count=\(count), hasPermissions=\(count > 0)")
        return count > 0
    }

    deinit {
        updateTimer?.invalidate()
        updateTimer = nil
    }

    func toggleCamera() {
        if cameraEnabled {
            disableCamera()
        } else {
            enableCamera()
        }
    }

    func toggleMicrophone() {
        if microphoneEnabled {
            disableMicrophone()
        } else {
            enableMicrophone()
        }
    }

    func toggleUSB() {
        if usbEnabled {
            disableUSB()
        } else {
            enableUSB()
        }
    }

    private func disableCamera() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            // Reset TCC database for camera to revoke all permissions
            let result = self.authHelper.executeWithPrivileges(
                command: "tccutil reset Camera"
            )
            print("Disable camera result: success=\(result.success), output=\(result.output)")

            if result.success {
                DispatchQueue.main.async {
                    self.cameraEnabled = false
                }
            }

            // Update UI and recheck status after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.checkCurrentStatus()
            }
        }
    }

    private func enableCamera() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            let alert = NSAlert()
            alert.messageText = "Enable Camera"
            alert.informativeText = """
            Camera has been reset. Apps will request permission when they try to access the camera.

            You can also manually grant permissions in:
            System Settings → Privacy & Security → Camera
            """
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()

            self.cameraEnabled = true
        }
    }

    private func disableMicrophone() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            // Reset TCC database for microphone to revoke all permissions
            let result = self.authHelper.executeWithPrivileges(
                command: "tccutil reset Microphone"
            )
            print("Disable microphone result: success=\(result.success), output=\(result.output)")

            if result.success {
                DispatchQueue.main.async {
                    self.microphoneEnabled = false
                }
            }

            // Update UI and recheck status after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.checkCurrentStatus()
            }
        }
    }

    private func enableMicrophone() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            let alert = NSAlert()
            alert.messageText = "Enable Microphone"
            alert.informativeText = """
            Microphone has been reset. Apps will request permission when they try to access the microphone.

            You can also manually grant permissions in:
            System Settings → Privacy & Security → Microphone
            """
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()

            self.microphoneEnabled = true
        }
    }

    private func disableUSB() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            let alert = NSAlert()
            alert.messageText = "USB Control Not Available"
            alert.informativeText = """
            USB ports cannot be disabled on modern macOS due to System Integrity Protection.

            For USB security, physically disconnect devices or use hardware USB blockers.
            """
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }

    private func enableUSB() {
        // USB is always enabled, nothing to do
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            let alert = NSAlert()
            alert.messageText = "USB Already Enabled"
            alert.informativeText = "USB ports are managed by macOS and cannot be controlled programmatically."
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }

    @discardableResult
    private func executeShellCommand(_ command: String) -> String {
        let task = Process()
        let pipe = Pipe()
        let errorPipe = Pipe()

        task.standardOutput = pipe
        task.standardError = errorPipe  // Separate stderr to avoid noise
        task.arguments = ["-c", command]
        task.executableURL = URL(fileURLWithPath: "/bin/bash")
        task.standardInput = nil

        do {
            try task.run()
            task.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            return output
        } catch {
            print("Failed to execute command: \(error.localizedDescription)")
            return ""
        }
    }
}
