import Foundation
import IOKit.ps

/// Manages power state and provides optimized intervals for battery efficiency
class PowerManager: ObservableObject {
    static let shared = PowerManager()

    @Published private(set) var isOnBattery: Bool = false
    @Published private(set) var batteryLevel: Int = 100

    private var pollTimer: Timer?

    // Timer intervals - normal vs low power
    struct Intervals {
        // Normal mode (plugged in)
        static let systemMonitorNormal: TimeInterval = 2.0
        static let networkMonitorNormal: TimeInterval = 2.0
        static let taskManagerNormal: TimeInterval = 3.0
        static let menuBarNormal: TimeInterval = 2.0
        static let advancedNetworkDataNormal: TimeInterval = 10.0
        static let advancedNetworkFlowNormal: TimeInterval = 5.0

        // Low power mode (on battery or manual)
        static let systemMonitorLowPower: TimeInterval = 5.0
        static let networkMonitorLowPower: TimeInterval = 5.0
        static let taskManagerLowPower: TimeInterval = 10.0
        static let menuBarLowPower: TimeInterval = 5.0
        static let advancedNetworkDataLowPower: TimeInterval = 30.0
        static let advancedNetworkFlowLowPower: TimeInterval = 15.0
    }

    // Timer tolerance for battery coalescing (allows system to batch timer fires)
    static let timerTolerance: TimeInterval = 1.0

    private init() {
        updatePowerState()
        // Poll power state every 30 seconds
        pollTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.updatePowerState()
        }
        pollTimer?.tolerance = 5.0
    }

    deinit {
        pollTimer?.invalidate()
    }

    /// Get the appropriate interval based on power state and config
    func interval(normal: TimeInterval, lowPower: TimeInterval, config: Config) -> TimeInterval {
        if config.lowPowerMode {
            return lowPower
        }
        if config.autoLowPowerOnBattery && isOnBattery {
            return lowPower
        }
        return normal
    }

    /// Check if low power mode should be active
    func isLowPowerActive(config: Config) -> Bool {
        return config.lowPowerMode || (config.autoLowPowerOnBattery && isOnBattery)
    }

    private func updatePowerState() {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef],
              !sources.isEmpty else {
            // No battery (desktop Mac)
            isOnBattery = false
            batteryLevel = 100
            return
        }

        for source in sources {
            if let info = IOPSGetPowerSourceDescription(snapshot, source)?.takeUnretainedValue() as? [String: Any] {
                if let powerSource = info[kIOPSPowerSourceStateKey] as? String {
                    isOnBattery = (powerSource == kIOPSBatteryPowerValue)
                }
                if let capacity = info[kIOPSCurrentCapacityKey] as? Int {
                    batteryLevel = capacity
                }
            }
        }
    }
}

// MARK: - Timer Extension for Power Efficiency

extension Timer {
    /// Create a power-efficient timer with tolerance for battery coalescing
    static func powerEfficientTimer(
        withTimeInterval interval: TimeInterval,
        repeats: Bool,
        tolerance: TimeInterval = PowerManager.timerTolerance,
        block: @escaping (Timer) -> Void
    ) -> Timer {
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: repeats, block: block)
        timer.tolerance = tolerance
        return timer
    }
}
