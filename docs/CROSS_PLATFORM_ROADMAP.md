# Cross-Platform Development Roadmap

> **Mission**: Bring Atlas's privacy-first system monitoring to Windows and Linux while maintaining a unified design language and feature set across all platforms.

---

## 🎯 Project Goals

### Core Objectives
- **Consistent UI/UX** - Identical design language across macOS, Windows, and Linux
- **Feature Parity** - All platforms support the same monitoring capabilities
- **Privacy-First** - No cloud, no tracking, no external communication
- **Native Performance** - Platform-optimized implementations, not web wrappers
- **Mesh Network Ready** - Cross-platform communication for multi-device monitoring

### Success Criteria
- [ ] 90%+ feature parity across platforms
- [ ] Unified color scheme (vibrant colors, pure black theme)
- [ ] Native performance (< 2% CPU usage when idle)
- [ ] Cross-platform config file compatibility
- [ ] Shared codebase for business logic where possible

---

## 📋 Platform Analysis

### macOS (Current Implementation) ✅
**Status**: Complete - Production ready

**Tech Stack**:
- Language: Swift
- UI Framework: SwiftUI + AppKit
- APIs: IOKit, SystemConfiguration, SMC, TCC Database

**Key Features**:
- ✅ System monitoring (CPU, Memory, Network, Disk, Battery)
- ✅ Task Manager with process control
- ✅ Network Monitor (privacy-first)
- ✅ Privacy controls (Camera/Microphone/USB)
- ✅ Menu bar integration with popover
- ✅ Themes: System, Light, Dark, Pure Black, Samaritan
- ✅ Atlas Mode (full-screen command interface)
- ✅ Hardware sensors (CPU temp, fan speed)
- ✅ Sparkline graphs and real-time charts

---

### Windows Implementation 🔲

**Status**: Not started - Planning phase

#### Technology Options

##### Option 1: Native C# + WPF (Recommended)
**Pros**:
- Native Windows performance
- Rich UI framework (WPF/XAML)
- Access to Performance Counters API
- WMI for hardware info
- Good .NET ecosystem

**Cons**:
- Different language from macOS (Swift vs C#)
- More code to maintain

**APIs Needed**:
- `PerformanceCounter` - CPU, Memory, Disk, Network metrics
- `System.Diagnostics.Process` - Process management
- `System.Management` (WMI) - Hardware sensors (temperature, fan speed)
- `Windows.Devices` - Device enumeration
- `System.Net.NetworkInformation` - Network monitoring
- Task Tray icon + WPF Window

##### Option 2: Qt + C++ (Cross-Platform)
**Pros**:
- Write once, runs on Windows + Linux
- Native look and feel
- Mature cross-platform framework
- Good performance

**Cons**:
- Learning curve for Qt
- LGPL licensing considerations
- Larger binary size

##### Option 3: Electron + React
**Pros**:
- Web technologies (easier for some devs)
- Cross-platform by default
- Rich UI possibilities

**Cons**:
- High memory usage (Chromium overhead)
- Slower than native
- Against project philosophy (native performance)
- **NOT RECOMMENDED** ❌

#### Recommended Approach: Native C# + WPF
**Reasoning**: Best performance, native Windows integration, rich monitoring APIs

#### Windows-Specific Features to Implement
- [ ] **System Monitoring**
  - [ ] CPU usage via `PerformanceCounter`
  - [ ] Memory usage (Physical + Virtual)
  - [ ] Network speed (Upload/Download)
  - [ ] Disk usage and I/O speed
  - [ ] Battery status (laptops)
  - [ ] GPU usage (optional)

- [ ] **Task Manager**
  - [ ] Process list with CPU/Memory
  - [ ] Kill process functionality
  - [ ] Process path and icon extraction
  - [ ] Sort by Name, CPU, Memory

- [ ] **Network Monitor**
  - [ ] Active connections via `netstat` or `Get-NetTCPConnection`
  - [ ] Process-to-connection mapping
  - [ ] Privacy-first (no packet capture)
  - [ ] CSV export

- [ ] **UI Components**
  - [ ] System tray icon with context menu
  - [ ] WPF main window (1200x700)
  - [ ] Two-column layout (System Monitor + Task Manager)
  - [ ] Settings panel (slide-in)
  - [ ] Network Monitor panel (slide-in)
  - [ ] Themes: Light, Dark, Pure Black

- [ ] **Privacy Features**
  - [ ] Camera/Microphone permission status (Windows 10+)
  - [ ] Device Manager integration (USB control)

- [ ] **Windows-Specific Challenges**
  - [ ] Admin privileges for hardware sensors
  - [ ] OpenHardwareMonitor integration for temps/fan speeds
  - [ ] Registry access for startup settings
  - [ ] Windows Defender SmartScreen compatibility

#### Windows File Structure (Proposed)
```
Atlas.Windows/
├── Atlas.csproj
├── App.xaml
├── App.xaml.cs
├── MainWindow.xaml
├── MainWindow.xaml.cs
├── Core/
│   ├── SystemMonitor.cs
│   ├── TaskManager.cs
│   ├── NetworkMonitor.cs
│   ├── ConfigManager.cs
│   └── PrivacyManager.cs
├── Views/
│   ├── SystemMonitorView.xaml
│   ├── TaskManagerView.xaml
│   ├── SettingsView.xaml
│   └── NetworkMonitorView.xaml
├── Models/
│   ├── Config.cs
│   ├── ProcessData.cs
│   └── NetworkConnection.cs
└── Resources/
    ├── Icons/
    └── Themes/
```

---

### Linux Implementation 🔲

**Status**: Not started - Planning phase

#### Technology Options

##### Option 1: GTK4 + Python (Recommended for prototyping)
**Pros**:
- Native Linux look
- Python is fast to prototype
- Good system access via `psutil`, `/proc`
- GTK is standard on most distros

**Cons**:
- Python overhead (slower than compiled)
- Separate codebase from macOS/Windows

##### Option 2: Qt + C++ (Cross-Platform with Windows)
**Pros**:
- Share code with Windows version
- Native performance
- Cross-distro compatibility

**Cons**:
- More complex setup
- LGPL licensing

##### Option 3: Rust + GTK (Performance-First)
**Pros**:
- Native performance
- Memory safety
- Growing ecosystem
- Good `/proc` filesystem access

**Cons**:
- Learning curve
- Smaller community vs Python/C++

#### Recommended Approach: GTK4 + Python (then Rust rewrite if needed)
**Reasoning**: Fastest to prototype, good Linux integration, can optimize later

#### Linux-Specific Features to Implement
- [ ] **System Monitoring**
  - [ ] CPU usage via `/proc/stat`
  - [ ] Memory usage via `/proc/meminfo`
  - [ ] Network speed via `/sys/class/net/`
  - [ ] Disk usage via `df` and `/proc/diskstats`
  - [ ] Battery status via `/sys/class/power_supply/`
  - [ ] Temperature via `sensors` (lm-sensors)

- [ ] **Task Manager**
  - [ ] Process list via `/proc/[pid]/`
  - [ ] Kill process via `os.kill()`
  - [ ] Process icons via desktop files
  - [ ] Sort by Name, CPU, Memory

- [ ] **Network Monitor**
  - [ ] Active connections via `/proc/net/tcp`, `/proc/net/udp`
  - [ ] Process-to-connection mapping via `/proc/[pid]/fd/`
  - [ ] Privacy-first (no packet capture)
  - [ ] CSV export

- [ ] **UI Components**
  - [ ] GTK4 main window (1200x700)
  - [ ] System tray/AppIndicator
  - [ ] Two-column layout
  - [ ] Settings panel (slide-in)
  - [ ] Network Monitor panel (slide-in)
  - [ ] Themes: Light, Dark, Pure Black

- [ ] **Linux-Specific Challenges**
  - [ ] Different distros have different APIs
  - [ ] AppIndicator vs StatusNotifier vs GtkStatusIcon
  - [ ] Permission model (root for some sensors)
  - [ ] Wayland vs X11 compatibility
  - [ ] Packaging (deb, rpm, flatpak, snap, AppImage)

#### Linux File Structure (Proposed)
```
atlas-linux/
├── atlas/
│   ├── __init__.py
│   ├── main.py
│   ├── core/
│   │   ├── system_monitor.py
│   │   ├── task_manager.py
│   │   ├── network_monitor.py
│   │   └── config_manager.py
│   ├── ui/
│   │   ├── main_window.py
│   │   ├── system_monitor_view.py
│   │   ├── task_manager_view.py
│   │   ├── settings_view.py
│   │   └── network_monitor_view.py
│   └── utils/
│       ├── proc_parser.py
│       └── sensors.py
├── resources/
│   ├── icons/
│   └── themes/
├── requirements.txt
├── setup.py
└── README.md
```

---

## 🔗 Shared Components

### Cross-Platform Configuration Format
**Goal**: Single `config.json` format that works across all platforms

```json
{
  "version": "1.0",
  "theme": "dark",
  "viewMode": "simple",
  "atlasMode": false,
  "updateInterval": 2.0,
  "showWindowOnLaunch": true,
  "menuBar": {
    "showCPU": false,
    "showMemory": false,
    "showMiniGraph": false
  },
  "thresholds": {
    "cpu": 80.0,
    "memory": 85.0,
    "disk": 90.0,
    "enableAlerts": false
  },
  "sectionOrder": ["cpu", "memory", "network", "disk", "battery"],
  "platform": "macOS|Windows|Linux"
}
```

### Unified Color Scheme
**All platforms must support**:

- **Vibrant Colors** (for Pure Black theme):
  - Cyan: `rgb(0, 230, 255)`
  - Blue: `rgb(51, 153, 255)`
  - Green: `rgb(0, 255, 102)`
  - Mint: `rgb(77, 255, 204)`
  - Orange: `rgb(255, 153, 0)`
  - Red: `rgb(255, 51, 77)`
  - Purple: `rgb(204, 77, 255)`
  - Pink: `rgb(255, 77, 204)`
  - Yellow: `rgb(255, 230, 0)`

- **Samaritan Theme**:
  - Red: `rgb(255, 51, 51)`
  - Orange: `rgb(255, 153, 51)`
  - Amber: `rgb(255, 191, 0)`
  - Green: `rgb(102, 255, 102)`

### Design Language Consistency

All platforms should maintain:
- **Layout**: 35/65 split (System Monitor / Task Manager)
- **Typography**: Monospaced fonts for technical data
- **Cards**: Rounded corners (8-12px), shadows, borders
- **Gradients**: Blue-to-cyan (System), Green-to-mint (Tasks), Purple-to-pink (Network)
- **Animations**: Spring animations (0.4s response, 0.8 damping)
- **Icons**: SF Symbols style (macOS), Material Icons (Linux), Segoe Fluent (Windows)

---

## 🌐 Mesh Network Architecture (Future)

### Goal
Enable monitoring multiple devices (Mac, Windows, Linux) from a single interface

### Key Principles
- **Local-only**: No cloud, no external servers
- **Zero-knowledge**: Admin can't see user data
- **End-to-end encrypted**: All communication encrypted
- **Optional**: Must work standalone without mesh

### Technology Stack (Proposed)
- **Discovery**: Bonjour/mDNS (Avahi on Linux)
- **Protocol**: WebSockets over TLS or custom TCP protocol
- **Authentication**: Token-based with user consent
- **Encryption**: TLS 1.3 or libsodium

### Implementation Phases
1. **Phase 1**: Local network device discovery
2. **Phase 2**: Secure pairing with QR codes or tokens
3. **Phase 3**: Remote metrics streaming
4. **Phase 4**: Aggregated dashboard view
5. **Phase 5**: Remote process management (optional)

---

## 📅 Development Timeline (Estimated)

### Q1 2025: Windows Development
- [ ] Week 1-2: Windows project setup (C# + WPF)
- [ ] Week 3-4: Core system monitoring (CPU, Memory, Disk, Network)
- [ ] Week 5-6: Task Manager implementation
- [ ] Week 7-8: UI components (main window, tray icon)
- [ ] Week 9-10: Network Monitor
- [ ] Week 11-12: Settings panel, theme system
- [ ] Week 13-14: Testing, bug fixes, Polish

### Q2 2025: Linux Development
- [ ] Week 1-2: Linux project setup (Python + GTK4)
- [ ] Week 3-4: Core system monitoring (/proc parsing)
- [ ] Week 5-6: Task Manager implementation
- [ ] Week 7-8: UI components (main window, tray icon)
- [ ] Week 9-10: Network Monitor
- [ ] Week 11-12: Settings panel, theme system
- [ ] Week 13-14: Packaging (deb, rpm, flatpak, AppImage)

### Q3 2025: Mesh Network (All Platforms)
- [ ] Week 1-4: Discovery and pairing protocol
- [ ] Week 5-8: Secure communication layer
- [ ] Week 9-12: Mesh UI and aggregated views
- [ ] Week 13-16: Testing and hardening

### Q4 2025: Polish & Release
- [ ] Cross-platform testing
- [ ] Documentation
- [ ] Website updates
- [ ] Release builds for all platforms

---

## 📦 Distribution Strategy

### macOS
- ✅ Direct download (.app bundle)
- [ ] Notarization
- [ ] App Store submission

### Windows
- [ ] MSI installer (Windows Installer)
- [ ] Chocolatey package
- [ ] Microsoft Store (optional)
- [ ] Portable .exe

### Linux
- [ ] `.deb` package (Debian/Ubuntu)
- [ ] `.rpm` package (Fedora/RHEL)
- [ ] Flatpak (universal)
- [ ] Snap (Ubuntu)
- [ ] AppImage (portable)
- [ ] AUR package (Arch Linux)

---

## 🧪 Testing Requirements

### Per-Platform Testing
- [ ] Fresh install on clean OS
- [ ] Upgrade path from previous version
- [ ] Permission dialogs and admin access
- [ ] CPU/Memory usage benchmarks
- [ ] Battery impact on laptops
- [ ] Theme switching
- [ ] Config migration

### Cross-Platform Testing
- [ ] Config file compatibility
- [ ] Mesh network discovery (Mac ↔ Windows ↔ Linux)
- [ ] Encrypted communication
- [ ] Design language consistency

---

## 🚧 Known Challenges & Risks

### Technical Challenges
1. **Hardware Sensor Access**
   - macOS: SMC requires entitlements
   - Windows: OpenHardwareMonitor needs admin rights
   - Linux: lm-sensors varies by distro

2. **System Tray/Menu Bar**
   - macOS: NSStatusItem (well-supported)
   - Windows: NotifyIcon (straightforward)
   - Linux: AppIndicator vs StatusNotifier vs GtkStatusIcon (fragmented)

3. **Permission Models**
   - macOS: TCC prompts, code signing, notarization
   - Windows: UAC, SmartScreen, admin elevation
   - Linux: Polkit, sudo, capabilities

4. **Package Management**
   - macOS: 1 format (app bundle)
   - Windows: 2-3 formats (MSI, Store, Chocolatey)
   - Linux: 5+ formats (deb, rpm, flatpak, snap, AppImage, AUR)

### Business Risks
- **Maintenance Burden**: 3 codebases to maintain
- **Testing Surface**: Exponential increase in OS versions/configs
- **Support Complexity**: Platform-specific bugs and issues

### Mitigation Strategies
- Start with Windows (largest user base)
- Use platform-specific native tools (don't force cross-platform)
- Automate builds and testing (CI/CD)
- Community contributions for Linux distro packaging

---

## 🎯 Success Metrics

### Phase 1: Windows Release
- [ ] 1,000+ Windows downloads in first month
- [ ] < 5% crash rate
- [ ] 4+ stars average rating
- [ ] Feature parity with macOS version

### Phase 2: Linux Release
- [ ] 500+ Linux downloads in first month
- [ ] Support for top 5 distros (Ubuntu, Fedora, Arch, Debian, Mint)
- [ ] Community contributions for packaging

### Phase 3: Mesh Network
- [ ] Successfully pair 2+ devices on local network
- [ ] Encrypted communication verified
- [ ] No security vulnerabilities reported

---

## 📚 Resources & References

### Windows Development
- [WPF Documentation](https://docs.microsoft.com/en-us/dotnet/desktop/wpf/)
- [PerformanceCounter Class](https://docs.microsoft.com/en-us/dotnet/api/system.diagnostics.performancecounter)
- [OpenHardwareMonitor](https://github.com/openhardwaremonitor/openhardwaremonitor)

### Linux Development
- [GTK4 Documentation](https://docs.gtk.org/gtk4/)
- [psutil Library](https://github.com/giampaolo/psutil)
- [/proc Filesystem Documentation](https://www.kernel.org/doc/html/latest/filesystems/proc.html)

### Cross-Platform
- [Qt Framework](https://www.qt.io/)
- [Electron](https://www.electronjs.org/) (if considering web tech)
- [mDNS/Bonjour](https://developer.apple.com/bonjour/)

---

*Last Updated: 2025-01-11*
*Status: Planning Phase - Windows development to begin Q1 2025*
