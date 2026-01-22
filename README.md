<div align="center">

# ATLAS

**Advanced System Monitor & Privacy Manager for macOS**

[![macOS](https://img.shields.io/badge/macOS-13.0+-black?style=flat-square&logo=apple)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange?style=flat-square&logo=swift)](https://swift.org/)
[![License](https://img.shields.io/badge/License-MIT-red?style=flat-square)](LICENSE)
[![Notarized](https://img.shields.io/badge/Apple-Notarized-green?style=flat-square&logo=apple)](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)

[Download](https://github.com/XionDot/Atlas-Hive/releases/latest) · [Website](https://atlashive.dev) · [Report Bug](https://github.com/XionDot/Atlas-Hive/issues)

---

<img src="https://img.shields.io/badge/100%25-Local-00d4ff?style=for-the-badge" alt="100% Local"/>
<img src="https://img.shields.io/badge/Zero-Data%20Sent-ff4545?style=for-the-badge" alt="Zero Data Sent"/>
<img src="https://img.shields.io/badge/Open-Source-white?style=for-the-badge" alt="Open Source"/>

</div>

---

## Features

### Real-Time System Monitoring
- **CPU Usage** - Track overall utilization and per-core activity
- **Memory Stats** - Monitor RAM with detailed metrics
- **Network Activity** - Real-time upload/download speeds
- **Disk Usage** - Track storage space
- **Battery Status** - Monitor level and charging state
- **Menu Bar Display** - Text metrics or mini graph visualization

### Privacy Killswitch
- **Camera Control** - Instantly revoke camera permissions system-wide
- **Microphone Control** - Block mic access for all apps
- **USB Management** - Monitor and control USB devices
- One-click privacy protection using macOS TCC database

### Built-in Task Manager
- View all running processes with detailed info
- Sort by name, CPU, or memory usage
- Search and filter processes
- Kill or restart any process instantly

### Customization
- **Themes** - Light, Dark, or System-based
- **Reorderable Dashboard** - Drag and drop to customize layout
- **Atlas Mode** - Fullscreen dashboard with command palette (⌘K)
- **Lightweight** - Minimal resource usage

---

## Installation

### Download (Recommended)

1. Download the latest DMG from [Releases](https://github.com/XionDot/Atlas-Hive/releases/latest)
2. Open the DMG file
3. Drag **Atlas** to your **Applications** folder
4. Launch Atlas from Applications
5. The app appears in your menu bar

> **Note:** Atlas is notarized by Apple - no Gatekeeper warnings.

### Build from Source

```bash
# Clone the repository
git clone https://github.com/XionDot/Atlas-Hive.git
cd Atlas-Hive

# Build the app
./scripts/build_app.sh

# Install to Applications
cp -r ./build/Atlas.app /Applications/
```

### System Requirements

| Requirement | Minimum |
|-------------|---------|
| macOS | 13.0 (Ventura) or later |
| Processor | Apple Silicon (M1/M2/M3/M4) or Intel |
| Disk Space | ~10 MB |
| Permissions | Administrator (for privacy features) |

---

## Usage

### Quick Start
1. Click the Atlas icon in your menu bar
2. View real-time system metrics in the popover
3. Right-click for privacy controls and settings
4. Click to open the full dashboard window

### Privacy Controls
1. Right-click the menu bar icon
2. Toggle Camera, Microphone, or USB
3. Enter administrator password when prompted
4. Permissions are revoked instantly

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `⌘K` | Open command palette (Atlas Mode) |
| `⌘,` | Open settings |
| `⌘Q` | Quit Atlas |

---

## Privacy & Security

Atlas is built with privacy as a core principle:

- **100% Local** - All processing happens on your device
- **No Analytics** - Zero tracking or telemetry
- **No Network** - No data ever leaves your Mac
- **No Accounts** - No sign-up or login required
- **Open Source** - Full code transparency
- **Notarized** - Verified safe by Apple

### Required Permissions

| Permission | Purpose | Required |
|------------|---------|----------|
| Full Disk Access | TCC database for privacy controls | For privacy features |
| Accessibility | System-wide monitoring | Optional |

---

## Technical Details

### Architecture

- **Language:** Swift 5.9
- **Frameworks:** SwiftUI + AppKit
- **Pattern:** MVVM
- **Target:** macOS 13.0+

### Project Structure

```
Atlas-Hive/
├── Sources/           # Swift source files
├── Resources/         # App icons and assets
├── scripts/           # Build and install scripts
├── website/           # Landing page
├── Info.plist         # App metadata
└── Atlas.entitlements # Required permissions
```

---

## Contributing

Contributions are welcome!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/NewFeature`)
3. Commit your changes (`git commit -m 'Add NewFeature'`)
4. Push to the branch (`git push origin feature/NewFeature`)
5. Open a Pull Request

---

## License

MIT License - See [LICENSE](LICENSE) for details.

---

<div align="center">

**Made by [radix](https://r0ot.co)**

</div>
