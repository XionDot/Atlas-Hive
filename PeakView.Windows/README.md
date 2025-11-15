# PeakView for Windows

> Privacy-first system monitor for Windows with Atlas Mode and Samaritan theme support

## 🎯 Features

- **System Monitoring**: Real-time CPU, Memory, Network, and Disk metrics
- **Task Manager**: Process list with CPU/Memory usage, kill process functionality
- **Network Monitor**: Active network connections (privacy-first, no packet capture)
- **Atlas Mode**: Full-screen command-driven interface
- **Samaritan Theme**: Iconic red terminal theme from Person of Interest
- **Pure Black Theme**: OLED-friendly with vibrant accent colors
- **Privacy-First**: No cloud, no tracking, no external communication

## 🛠️ Technology Stack

- **Language**: C# (.NET 8.0)
- **UI Framework**: WPF (Windows Presentation Foundation) + ModernWPF
- **APIs Used**:
  - `System.Diagnostics.PerformanceCounter` - CPU, Memory, Network metrics
  - `System.Management` - WMI for hardware sensors
  - `System.Net.NetworkInformation` - Network connections
  - `System.Text.Json` - Configuration management

## 📋 Prerequisites

- Windows 10 or Windows 11
- .NET 8.0 SDK or Runtime
- Visual Studio 2022 (for development) or `dotnet` CLI

## 🔧 Building from Source

### Using Visual Studio 2022

1. Open `PeakView.sln` (or the `.csproj` file)
2. Select **Release** configuration
3. Build → Build Solution (Ctrl+Shift+B)
4. Output will be in `bin/Release/net8.0-windows/`

### Using dotnet CLI

```bash
# Navigate to the Windows project directory
cd PeakView.Windows

# Restore dependencies
dotnet restore

# Build in Release mode
dotnet build -c Release

# Run the application
dotnet run -c Release
```

## 📦 Creating a Portable Build

To create a portable executable that can be transferred to another Windows device:

```bash
# Self-contained build (includes .NET runtime - larger file)
dotnet publish -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true

# Framework-dependent build (requires .NET 8.0 runtime - smaller file)
dotnet publish -c Release -r win-x64 --self-contained false -p:PublishSingleFile=true
```

Output will be in:
- `bin/Release/net8.0-windows/win-x64/publish/`

The `PeakView.exe` file can be copied to any Windows device.

## 🚀 Running the Application

### From Visual Studio
- Press F5 (Debug) or Ctrl+F5 (Run without debugging)

### From Command Line
```bash
dotnet run -c Release
```

### From Published Executable
Simply double-click `PeakView.exe` from the publish folder.

## 🎨 Themes

PeakView supports multiple themes:

### Pure Black Theme (Default)
- Pure black background (#000000)
- Vibrant accent colors optimized for OLED displays
- Cyan, Blue, Green, Orange, Red, Purple, Pink, Yellow

### Samaritan Theme
- Red terminal aesthetic (#FF3333)
- Scanline effect
- Uppercase text
- Retro terminal feel

## ⌨️ Keyboard Shortcuts

### Atlas Mode
- **Ctrl+K**: Toggle command palette
- **ESC**: Return to initial screen / exit widget
- **Enter**: Execute command

### Main Window
- **Ctrl+W**: Close window
- **Ctrl+Q**: Quit application (when implemented)

## 📁 Configuration

Configuration is stored in JSON format at:
```
%APPDATA%\PeakView\config.json
```

### Example config.json
```json
{
  "version": "1.0",
  "theme": "dark",
  "viewMode": "simple",
  "atlasMode": false,
  "updateInterval": 2.0,
  "showWindowOnLaunch": true,
  "thresholds": {
    "cpu": 80.0,
    "memory": 85.0,
    "disk": 90.0,
    "enableAlerts": false
  }
}
```

## 🔐 Privacy & Permissions

PeakView is privacy-first:
- ✅ No cloud connections
- ✅ No telemetry or tracking
- ✅ No external API calls
- ✅ All data stays on your device
- ✅ Open source

### Required Permissions
- **Performance Counters**: Read CPU, Memory, Disk, Network metrics
- **Process Information**: List running processes and their resource usage
- **Network Information**: Read active network connections (no packet capture)

## 🐛 Known Issues & Limitations

### Windows-Specific Limitations
1. **Hardware Sensors**: CPU temperature and fan speeds require admin privileges and OpenHardwareMonitor (not yet implemented)
2. **Process-to-Connection Mapping**: Windows doesn't expose this easily, so network connections show "Unknown" process (requires P/Invoke)
3. **Modern UI Controls**: Using ModernWPF for enhanced Windows 11 look and feel

### Planned Features
- [ ] System tray integration
- [ ] Hardware sensor support (CPU temp, fan speed)
- [ ] Process-to-connection mapping for network monitor
- [ ] CSV export for network connections
- [ ] GPU usage monitoring
- [ ] Battery status (for laptops)
- [ ] Startup on Windows login
- [ ] Settings panel
- [ ] Network Monitor panel

## 🎯 Roadmap

### Phase 1: Core Features (Current)
- [x] Basic WPF project structure
- [x] System monitoring (CPU, Memory, Network, Disk)
- [x] Task Manager with process list
- [x] Atlas Mode UI framework
- [x] Samaritan theme support
- [x] Configuration management
- [ ] Complete Atlas Mode widgets
- [ ] Settings panel
- [ ] System tray integration

### Phase 2: Advanced Features
- [ ] Network Monitor panel
- [ ] Hardware sensor integration (OpenHardwareMonitor)
- [ ] Camera/Microphone permission status
- [ ] Privacy controls

### Phase 3: Polish & Distribution
- [ ] MSI installer
- [ ] Portable .exe build
- [ ] Code signing
- [ ] Windows Defender SmartScreen approval
- [ ] Chocolatey package
- [ ] Microsoft Store submission (optional)

## 🤝 Contributing

Contributions are welcome! Please see the main repository for contribution guidelines.

## 📄 License

Same as PeakView macOS - see main repository LICENSE file.

## 🔗 Cross-Platform Compatibility

PeakView Windows shares the same configuration format as macOS and Linux versions, allowing you to sync settings across devices.

---

**Note**: This is the Windows port of PeakView. For macOS version, see the main `Sources/` directory.

Built with ❤️ for Windows users who value privacy and performance.
