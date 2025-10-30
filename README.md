# Desktopie

<div align="center">
  <h3>Advanced System Monitor & Privacy Manager for macOS</h3>
  <p>A powerful menu bar application for monitoring system resources, managing processes, and controlling privacy settings</p>
</div>

## Features

### Real-Time System Monitoring
- **CPU Usage**: Track overall CPU utilization and per-core activity
- **Memory Statistics**: Monitor RAM usage with detailed metrics
- **Network Activity**: Real-time upload and download speeds
- **Disk Usage**: Track available and used storage space
- **Battery Status**: Monitor battery level and charging state (for laptops)
- **Menu Bar Display**: Choose between text metrics or mini graph visualization
- **Beautiful Graphs**: Visual representation of system performance trends
- **Customizable Updates**: Adjust refresh intervals to your preference

### Built-in Task Manager
- View all running processes with detailed information
- Monitor CPU and memory consumption per process
- Sort by name, CPU usage, or memory usage
- Search and filter processes
- Kill or restart any process with one click
- Updates every 3 seconds for optimal performance

### Privacy Controls
- **Camera Management**: Instantly revoke camera permissions for all apps
- **Microphone Management**: Control microphone access system-wide
- **USB Controls**: Information about USB device management
- One-click privacy protection using macOS TCC (Transparency, Consent, and Control) database

### Customization
- **Theme Support**: Light, Dark, or System-based themes
- **Reorderable Dashboard**: Drag and drop sections to customize your layout
- **Menu Bar Configuration**: Toggle what appears in your menu bar
- **Lightweight**: Minimal resource usage, runs quietly in the background

## Installation

### Download Pre-built App

Download the latest version from [GitHub Releases](https://github.com/ahmedzitoun/desktopie/releases/latest)

1. Download `Desktopie.app.zip`
2. Unzip the file
3. Move `Desktopie.app` to your Applications folder
4. Double-click to launch
5. The app will appear in your menu bar

### System Requirements

- macOS 13.0 (Ventura) or later
- Apple Silicon (M1/M2/M3) or Intel processor
- 10 MB of available disk space
- Administrator privileges for privacy features

### Building from Source

1. Clone the repository:

   ```bash
   git clone https://github.com/ahmedzitoun/desktopie.git
   cd desktopie
   ```

2. Generate the app icon (optional):

   ```bash
   ./generate_icon.sh
   ```

3. Build the application:

   ```bash
   ./build_app.sh
   ```

4. Install to Applications:

   ```bash
   ./install.sh
   ```

The app will appear in your menu bar and run quietly in the background.

## Usage

### First Launch
1. After launching, you'll see the Desktopie icon in your menu bar
2. Click the icon to open the monitoring dashboard
3. Access settings via the gear icon in the dashboard

### Customization

Desktopie is highly customizable through the Settings panel:

#### Menu Bar Options

- **Mini Graph Mode**: Display a compact visual graph showing CPU and Memory bars
- **Text Mode**: Toggle individual CPU/Memory text display
- **Update Interval**: Adjust refresh rate (1-10 seconds)

#### Display Options

- **Show/hide performance graphs** in the dashboard
- **Theme selection** (System, Light, Dark)
- **Reorderable sections**: Click the reorder button (↕️) to drag-and-drop sections and customize your layout

### Using the Task Manager

1. Click the menu bar icon
2. Select "Task Manager" from the menu
3. View all running processes with real-time statistics
4. Use the search bar to find specific processes
5. Click column headers to sort (Name, CPU, Memory)
6. Click "Kill" to terminate a process
7. Click "Restart" to kill and relaunch a process
8. Click the back button to return to the dashboard

**Note**: Some system processes may require administrator privileges to manage.

### Privacy Features

Privacy controls allow you to instantly revoke permissions for camera and microphone access:

1. Click the menu bar icon
2. Toggle Camera, Microphone, or USB controls
3. Enter your administrator password when prompted
4. The system will revoke all app permissions for that service
5. Apps will need to request permission again when they try to access the hardware

**Important**: Privacy features use macOS's TCC (Transparency, Consent, and Control) database. This is a safe, system-approved method that works within macOS security constraints.

### Configuration File

Settings are stored in:

```text
~/Library/Application Support/Desktopie/config.json
```

You can manually edit this file for advanced customization:

```json
{
  "showCPUInMenuBar": true,
  "showMemoryInMenuBar": true,
  "showMiniGraphInMenuBar": false,
  "showGraphs": true,
  "updateInterval": 2.0,
  "theme": "system",
  "sectionOrder": ["cpu", "memory", "disk", "battery"]
}
```

## Features Breakdown

### Monitoring Metrics

**CPU Usage**
- Real-time CPU percentage
- Multi-core aggregation
- Visual graph representation

**Memory Usage**
- Active, inactive, wired, and compressed memory
- Percentage and absolute values
- Total vs. used memory display

**Disk Usage**
- System disk space monitoring
- Percentage of disk used

**Battery**
- Battery level percentage
- Charging status indicator
- Color-coded based on battery level

## Customization Tips

1. **Mini Graph Mode**: Use the mini graph for a sleek, visual menu bar display
2. **Minimal Menu Bar**: Show only the metrics you care about
3. **Performance Mode**: Increase update interval to reduce overhead
4. **Visual Focus**: Enable graphs for detailed performance visualization
5. **Personal Layout**: Reorder dashboard sections to match your priorities

## Troubleshooting

### App Won't Open

- Right-click the app and select "Open" to bypass Gatekeeper
- Check System Settings > Privacy & Security for any blocks

### Privacy Features Not Working

- Ensure you entered the correct administrator password
- Grant Full Disk Access in System Settings > Privacy & Security
- Try rebooting after making changes

### High CPU Usage

1. Increase the update interval in Settings
2. Close the task manager when not in use
3. Disable graphs if not needed

### Task Manager Not Showing Processes

- Grant necessary permissions in System Settings
- Restart the app
- Check Console.app for any error messages

### Menu Bar Not Showing

1. Check if the app is running in Activity Monitor
2. Restart the application
3. Check System Settings > Control Center > Menu Bar Only

## Technical Details

### Architecture

- **Language**: Swift
- **Framework**: SwiftUI + AppKit
- **Pattern**: MVVM (Model-View-ViewModel)
- **Minimum Target**: macOS 13.0 (Ventura)

### APIs Used

- **IOKit**: System monitoring and power management
- **AppKit**: Menu bar integration (NSStatusItem, NSPopover)
- **Foundation**: Process execution and data management
- **TCC Database**: Privacy permission management

### Project Structure

```text
desktopie/
├── Sources/
│   ├── DesktopieApp.swift       # Main app entry and menu bar
│   ├── ContentView.swift        # Dashboard UI
│   ├── SystemMonitor.swift      # System metrics collection
│   ├── ConfigManager.swift      # Settings persistence
│   ├── PrivacyManager.swift     # Privacy controls
│   ├── TaskManager.swift        # Process monitoring
│   ├── TaskManagerView.swift    # Task manager UI
│   └── AuthorizationHelper.swift # Privilege escalation
├── Resources/
│   └── AppIcon.appiconset/      # App icon assets
├── website/
│   └── index.html               # Landing page
├── Info.plist                   # App metadata
├── Desktopie.entitlements       # Required permissions
├── build_app.sh                 # Build script
├── install.sh                   # Installation script
└── generate_icon.sh             # Icon generation
```

## Privacy & Security

Desktopie respects your privacy:

- No analytics or tracking
- No data collection
- No network requests (except system monitoring APIs)
- All data stays on your device
- Open source and auditable

### Required Permissions

- **Accessibility**: For system-wide monitoring (optional)
- **Full Disk Access**: For TCC database access (privacy features only)

## License

MIT License - See [LICENSE](LICENSE) file for details.

Copyright 2025 Ahmed Zitoun

## Contributing

Contributions are welcome! Feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Support

- **Website**: [desktopie.app](https://desktopie.app)
- **Issues**: [GitHub Issues](https://github.com/ahmedzitoun/desktopie/issues)
- **Email**: support@desktopie.app

## Roadmap

- [ ] App Store submission
- [ ] Notarization for easier distribution
- [ ] Per-app network usage monitoring
- [ ] CPU temperature monitoring
- [ ] Custom notification alerts for thresholds
- [ ] Export system reports (CSV/JSON)
- [ ] Plugins/extensions system
- [ ] Localization support (i18n)

---

Made with ❤️ by [Ahmed Zitoun](https://github.com/ahmedzitoun)
