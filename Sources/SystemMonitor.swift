import Foundation
import IOKit.ps
import SystemConfiguration
import AppKit

class SystemMonitor: ObservableObject {
    @Published var cpuUsage: Double = 0.0
    @Published var memoryUsage: Double = 0.0
    @Published var memoryUsed: Double = 0.0
    @Published var memoryTotal: Double = 0.0
    @Published var networkDownload: Double = 0.0
    @Published var networkUpload: Double = 0.0
    @Published var batteryLevel: Int = 0
    @Published var isCharging: Bool = false
    @Published var batteryHealth: Int = 100  // Battery health percentage
    @Published var diskUsage: Double = 0.0

    // System information
    @Published var deviceModel: String = ""
    @Published var macOSVersion: String = ""
    @Published var cpuModel: String = ""
    @Published var cpuCores: Int = 0
    @Published var uptimeString: String = ""
    @Published var totalMemoryGB: Double = 0.0
    @Published var totalStorageGB: Double = 0.0
    @Published var displayResolution: String = ""

    private var previousCPUInfo: host_cpu_load_info?
    private var previousNetworkBytes: (rx: UInt64, tx: UInt64) = (0, 0)
    private var lastUpdateTime: Date = Date()

    private var timer: Timer?

    init() {
        loadSystemInfo()
        startMonitoring()
    }

    func startMonitoring() {
        // Initial update
        updateMetrics()

        // Setup timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateMetrics()
        }
    }

    func loadSystemInfo() {
        // Get friendly device model name
        deviceModel = getDeviceModel()

        // Get macOS version
        let version = ProcessInfo.processInfo.operatingSystemVersion
        macOSVersion = "macOS \(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"

        // Get CPU model
        var size = 0
        sysctlbyname("machdep.cpu.brand_string", nil, &size, nil, 0)
        var cpuBrand = [CChar](repeating: 0, count: size)
        sysctlbyname("machdep.cpu.brand_string", &cpuBrand, &size, nil, 0)
        cpuModel = String(cString: cpuBrand).trimmingCharacters(in: .whitespaces)

        // Get CPU cores
        var cores: Int32 = 0
        size = MemoryLayout<Int32>.size
        sysctlbyname("hw.ncpu", &cores, &size, nil, 0)
        cpuCores = Int(cores)

        // Get total memory in GB
        var memSize: UInt64 = 0
        size = MemoryLayout<UInt64>.size
        sysctlbyname("hw.memsize", &memSize, &size, nil, 0)
        totalMemoryGB = Double(memSize) / 1_073_741_824.0  // Convert bytes to GB

        // Get total storage
        totalStorageGB = getTotalStorage()

        // Get display resolution
        displayResolution = getDisplayResolution()

        // Update uptime periodically
        updateUptime()
    }

    func getDeviceModel() -> String {
        var size = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        var model = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.model", &model, &size, nil, 0)
        let modelIdentifier = String(cString: model)

        // Try to get marketing name from system_profiler
        let task = Process()
        task.launchPath = "/usr/sbin/system_profiler"
        task.arguments = ["SPHardwareDataType"]

        let pipe = Pipe()
        task.standardOutput = pipe

        do {
            try task.run()
            task.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                // Parse for "Model Name:" or "Model Identifier:"
                let lines = output.components(separatedBy: .newlines)
                for line in lines {
                    if line.contains("Model Name:") {
                        let parts = line.components(separatedBy: ":")
                        if parts.count > 1 {
                            return parts[1].trimmingCharacters(in: .whitespaces)
                        }
                    }
                }
            }
        } catch {
            // Fall back to model identifier
        }

        return modelIdentifier
    }

    func getTotalStorage() -> Double {
        do {
            let fileURL = URL(fileURLWithPath: "/")
            let values = try fileURL.resourceValues(forKeys: [.volumeTotalCapacityKey])
            if let capacity = values.volumeTotalCapacity {
                return Double(capacity) / 1_073_741_824.0  // Convert bytes to GB
            }
        } catch {
            return 0.0
        }
        return 0.0
    }

    func getDisplayResolution() -> String {
        guard let screen = NSScreen.main else {
            return "Unknown"
        }

        let screenSize = screen.frame.size
        let scaleFactor = screen.backingScaleFactor
        let backingWidth = screenSize.width * scaleFactor
        let backingHeight = screenSize.height * scaleFactor

        return "\(Int(backingWidth)) × \(Int(backingHeight))"
    }

    func updateUptime() {
        let uptime = ProcessInfo.processInfo.systemUptime
        let days = Int(uptime) / 86400
        let hours = (Int(uptime) % 86400) / 3600
        let minutes = (Int(uptime) % 3600) / 60

        if days > 0 {
            uptimeString = "\(days)d \(hours)h \(minutes)m"
        } else if hours > 0 {
            uptimeString = "\(hours)h \(minutes)m"
        } else {
            uptimeString = "\(minutes)m"
        }
    }

    func updateMetrics() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else { return }

            let cpu = self.getCPUUsage()
            let memory = self.getMemoryInfo()
            let network = self.getNetworkUsage()
            let battery = self.getBatteryInfo()
            let disk = self.getDiskUsage()

            DispatchQueue.main.async {
                self.cpuUsage = cpu
                self.memoryUsage = memory.usage
                self.memoryUsed = memory.used
                self.memoryTotal = memory.total
                self.networkDownload = network.download
                self.networkUpload = network.upload
                self.batteryLevel = battery.level
                self.isCharging = battery.charging
                self.batteryHealth = battery.health
                self.diskUsage = disk
                self.updateUptime()
            }
        }
    }

    func getCPUUsage() -> Double {
        var numCPUs: natural_t = 0
        var cpuInfo: processor_info_array_t?
        var numCPUInfo: mach_msg_type_number_t = 0

        let result = host_processor_info(
            mach_host_self(),
            PROCESSOR_CPU_LOAD_INFO,
            &numCPUs,
            &cpuInfo,
            &numCPUInfo
        )

        guard result == KERN_SUCCESS, let cpuInfo = cpuInfo else {
            return 0.0
        }

        defer {
            vm_deallocate(
                mach_task_self_,
                vm_address_t(bitPattern: cpuInfo),
                vm_size_t(numCPUInfo) * vm_size_t(MemoryLayout<integer_t>.size)
            )
        }

        var totalUser: UInt32 = 0
        var totalSystem: UInt32 = 0
        var totalIdle: UInt32 = 0
        var totalNice: UInt32 = 0

        for i in 0..<Int(numCPUs) {
            let offset = Int(CPU_STATE_MAX) * i
            totalUser += UInt32(cpuInfo[offset + Int(CPU_STATE_USER)])
            totalSystem += UInt32(cpuInfo[offset + Int(CPU_STATE_SYSTEM)])
            totalIdle += UInt32(cpuInfo[offset + Int(CPU_STATE_IDLE)])
            totalNice += UInt32(cpuInfo[offset + Int(CPU_STATE_NICE)])
        }

        let total = totalUser + totalSystem + totalIdle + totalNice
        let active = totalUser + totalSystem + totalNice

        if total == 0 {
            return 0.0
        }

        return (Double(active) / Double(total)) * 100.0
    }

    func getMemoryInfo() -> (usage: Double, used: Double, total: Double) {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)

        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }

        guard result == KERN_SUCCESS else {
            return (0, 0, 0)
        }

        let pageSize = Double(vm_kernel_page_size)
        let totalMemory = Double(ProcessInfo.processInfo.physicalMemory)

        let active = Double(stats.active_count) * pageSize
        let inactive = Double(stats.inactive_count) * pageSize
        let wired = Double(stats.wire_count) * pageSize
        let compressed = Double(stats.compressor_page_count) * pageSize

        let usedMemory = active + inactive + wired + compressed
        let usagePercentage = (usedMemory / totalMemory) * 100.0

        return (usagePercentage, usedMemory, totalMemory)
    }

    func getNetworkUsage() -> (download: Double, upload: Double) {
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        var downloadBytes: UInt64 = 0
        var uploadBytes: UInt64 = 0

        // Get network interface information
        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else {
            return (0, 0)
        }

        defer {
            freeifaddrs(ifaddr)
        }

        // Iterate through all interfaces
        var currentInterface = firstAddr
        while true {
            let interface = currentInterface.pointee

            // Get interface name
            let name = String(cString: interface.ifa_name)

            // Only process active network interfaces
            if (interface.ifa_flags & UInt32(IFF_UP)) != 0,
               name != "lo0",
               (name.starts(with: "en") || name.starts(with: "pdp_ip")),
               let addr = interface.ifa_addr,
               addr.pointee.sa_family == UInt8(AF_LINK) {

                // Safely access sockaddr_dl data
                addr.withMemoryRebound(to: sockaddr_dl.self, capacity: 1) { sockaddrPtr in
                    let sockaddrDl = sockaddrPtr.pointee

                    // Check if this is an Ethernet or similar interface
                    if sockaddrDl.sdl_type == IFT_ETHER || sockaddrDl.sdl_type == IFT_IEEE1394 {
                        if let ifdata = interface.ifa_data {
                            let networkData = ifdata.assumingMemoryBound(to: if_data.self).pointee
                            downloadBytes += UInt64(networkData.ifi_ibytes)
                            uploadBytes += UInt64(networkData.ifi_obytes)
                        }
                    }
                }
            }

            // Move to next interface
            guard let next = interface.ifa_next else {
                break
            }
            currentInterface = next
        }

        // Calculate speed
        let currentTime = Date()
        let timeDiff = currentTime.timeIntervalSince(lastUpdateTime)

        var downloadSpeed: Double = 0
        var uploadSpeed: Double = 0

        // Only calculate if we have previous data and sufficient time has passed
        if previousNetworkBytes.rx > 0 && timeDiff > 0.5 {
            let rxDiff = Double(Int64(downloadBytes) - Int64(previousNetworkBytes.rx))
            let txDiff = Double(Int64(uploadBytes) - Int64(previousNetworkBytes.tx))

            // Only update if the difference is positive (no counter wrap)
            if rxDiff >= 0 && txDiff >= 0 {
                downloadSpeed = rxDiff / timeDiff
                uploadSpeed = txDiff / timeDiff
            }
        }

        // Always update for next calculation
        if timeDiff > 0.5 {
            previousNetworkBytes = (rx: downloadBytes, tx: uploadBytes)
            lastUpdateTime = currentTime
        }

        return (downloadSpeed, uploadSpeed)
    }

    func getBatteryInfo() -> (level: Int, charging: Bool, health: Int) {
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as Array

        guard let source = sources.first else {
            return (-1, false, 100)  // No battery (desktop)
        }

        let description = IOPSGetPowerSourceDescription(snapshot, source).takeUnretainedValue() as! [String: Any]

        let currentCapacity = description[kIOPSCurrentCapacityKey] as? Int ?? -1
        let isCharging = description[kIOPSIsChargingKey] as? Bool ?? false

        // Calculate battery health from IOKit power source data
        // Health = (Current Max Capacity / Original Design Capacity) * 100
        let maxCapacity = description[kIOPSMaxCapacityKey] as? Int ?? 100

        // Try different keys to get design capacity
        var designCapacity = maxCapacity // Default to max if design not available

        if let design = description["DesignCapacity"] as? Int, design > 0 {
            designCapacity = design
        } else if let design = description["AppleRawMaxCapacity"] as? Int, design > 0 {
            designCapacity = design
        }

        // Calculate health percentage (capped at 100%)
        let health = designCapacity > 0 ? min(100, (maxCapacity * 100) / designCapacity) : 100

        return (currentCapacity, isCharging, health)
    }

    func getDiskUsage() -> Double {
        guard let attributes = try? FileManager.default.attributesOfFileSystem(forPath: "/") else {
            return 0.0
        }

        if let total = attributes[.systemSize] as? NSNumber,
           let free = attributes[.systemFreeSize] as? NSNumber {
            let totalBytes = total.doubleValue
            let freeBytes = free.doubleValue
            let usedBytes = totalBytes - freeBytes
            return (usedBytes / totalBytes) * 100.0
        }

        return 0.0
    }

    deinit {
        timer?.invalidate()
    }
}
