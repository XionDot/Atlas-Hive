import Foundation
import IOKit

// MARK: - SMC Key Structures
struct SMCKeyData {
    struct Version {
        var major: UInt8 = 0
        var minor: UInt8 = 0
        var build: UInt8 = 0
        var reserved: UInt8 = 0
        var release: UInt16 = 0
    }

    struct LimitData {
        var version: UInt16 = 0
        var length: UInt16 = 0
        var cpuPLimit: UInt32 = 0
        var gpuPLimit: UInt32 = 0
        var memPLimit: UInt32 = 0
    }

    struct KeyInfo {
        var dataSize: IOByteCount = 0
        var dataType: UInt32 = 0
        var dataAttributes: UInt8 = 0
    }

    var key: UInt32 = 0
    var version = Version()
    var pLimitData = LimitData()
    var keyInfo = KeyInfo()
    var result: UInt8 = 0
    var status: UInt8 = 0
    var data8: UInt8 = 0
    var data32: UInt32 = 0
    var bytes: [UInt8] = Array(repeating: 0, count: 32)
}

// MARK: - SMC Helper Class
class SMCHelper {
    private var connection: io_connect_t = 0

    // SMC selector constants
    private let KERNEL_INDEX_SMC: Int32 = 2
    private let SMC_CMD_READ_KEYINFO: UInt8 = 9
    private let SMC_CMD_READ_BYTES: UInt8 = 5

    // Temperature keys for different Mac models
    private let CPU_TEMP_KEYS = ["TC0P", "TC0D", "TC0E", "TC0F", "TCXC"]
    private let GPU_TEMP_KEYS = ["TG0P", "TG0D", "TGDD"]
    private let BATTERY_TEMP_KEYS = ["TB0T", "TB1T", "TB2T"]

    init() {
        openSMC()
    }

    deinit {
        closeSMC()
    }

    // MARK: - SMC Connection
    private func openSMC() {
        var iterator: io_iterator_t = 0
        let matchingDictionary = IOServiceMatching("AppleSMC")
        let result = IOServiceGetMatchingServices(kIOMainPortDefault, matchingDictionary, &iterator)

        if result == kIOReturnSuccess {
            let device = IOIteratorNext(iterator)
            if device != 0 {
                IOServiceOpen(device, mach_task_self_, 0, &connection)
                IOObjectRelease(device)
            }
            IOObjectRelease(iterator)
        }
    }

    private func closeSMC() {
        if connection != 0 {
            IOServiceClose(connection)
            connection = 0
        }
    }

    // MARK: - Key Conversion
    private func fourCharCodeToUInt32(_ key: String) -> UInt32 {
        let chars = Array(key.utf8)
        guard chars.count == 4 else { return 0 }
        return UInt32(chars[0]) << 24 | UInt32(chars[1]) << 16 | UInt32(chars[2]) << 8 | UInt32(chars[3])
    }

    // MARK: - SMC Read Functions
    private func readSMC(key: String) -> SMCKeyData? {
        guard connection != 0 else { return nil }

        var inputStructure = SMCKeyData()
        var outputStructure = SMCKeyData()

        inputStructure.key = fourCharCodeToUInt32(key)
        inputStructure.data8 = SMC_CMD_READ_KEYINFO

        var structureSize = MemoryLayout<SMCKeyData>.size

        let result = IOConnectCallStructMethod(
            connection,
            UInt32(KERNEL_INDEX_SMC),
            &inputStructure,
            structureSize,
            &outputStructure,
            &structureSize
        )

        if result != kIOReturnSuccess {
            return nil
        }

        inputStructure.keyInfo = outputStructure.keyInfo
        inputStructure.data8 = SMC_CMD_READ_BYTES

        let readResult = IOConnectCallStructMethod(
            connection,
            UInt32(KERNEL_INDEX_SMC),
            &inputStructure,
            structureSize,
            &outputStructure,
            &structureSize
        )

        if readResult != kIOReturnSuccess {
            return nil
        }

        return outputStructure
    }

    // MARK: - Temperature Reading
    private func readTemperature(key: String) -> Double? {
        guard let data = readSMC(key: key) else { return nil }

        // SMC temperature is stored as sp78 (signed fixed point, 1 sign bit, 7 int bits, 8 frac bits)
        let bytes = data.bytes
        let temp = Int(bytes[0]) << 8 | Int(bytes[1])
        return Double(temp) / 256.0
    }

    func getCPUTemperature() -> Double? {
        // Try different CPU temperature keys
        for key in CPU_TEMP_KEYS {
            if let temp = readTemperature(key: key) {
                // Sanity check - temperature should be reasonable
                if temp > 0 && temp < 120 {
                    return temp
                }
            }
        }
        return nil
    }

    func getGPUTemperature() -> Double? {
        for key in GPU_TEMP_KEYS {
            if let temp = readTemperature(key: key) {
                if temp > 0 && temp < 120 {
                    return temp
                }
            }
        }
        return nil
    }

    func getBatteryTemperature() -> Double? {
        for key in BATTERY_TEMP_KEYS {
            if let temp = readTemperature(key: key) {
                if temp > 0 && temp < 80 {
                    return temp
                }
            }
        }
        return nil
    }

    func getDiskTemperature() -> Double? {
        // Try common SSD/HDD temperature keys
        let diskKeys = ["TH0P", "TH1P", "TH2P", "Th0H", "Th1H"]
        for key in diskKeys {
            if let temp = readTemperature(key: key) {
                if temp > 0 && temp < 100 {
                    return temp
                }
            }
        }
        return nil
    }

    // MARK: - Fan Reading
    private func readFanRPM(fanNumber: Int) -> Double? {
        // Fan actual speed is stored as fpe2 (floating point, 2 decimal places)
        let key = String(format: "F%dAc", fanNumber)
        guard let data = readSMC(key: key) else { return nil }

        let bytes = data.bytes
        let rpm = (UInt16(bytes[0]) << 8) | UInt16(bytes[1])

        // fpe2 format: divide by 4
        return Double(rpm) / 4.0
    }

    func getNumberOfFans() -> Int {
        // Read FNum key to get number of fans
        guard let data = readSMC(key: "FNum") else { return 0 }
        return Int(data.bytes[0])
    }

    func getFanSpeeds() -> [Double] {
        let fanCount = getNumberOfFans()
        var speeds: [Double] = []

        for i in 0..<fanCount {
            if let rpm = readFanRPM(fanNumber: i) {
                speeds.append(rpm)
            }
        }

        return speeds
    }

    func getAverageFanSpeed() -> Double? {
        let speeds = getFanSpeeds()
        guard !speeds.isEmpty else { return nil }
        return speeds.reduce(0, +) / Double(speeds.count)
    }
}
