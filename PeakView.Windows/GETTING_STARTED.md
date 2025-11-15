# Getting Started with PeakView for Windows

Quick guide to building and running PeakView on Windows.

## Prerequisites

### Required
- **Windows 10 or Windows 11**
- **.NET 8.0 SDK** - [Download here](https://dotnet.microsoft.com/download/dotnet/8.0)
- **Visual Studio 2022** (recommended) or **Visual Studio Code** with C# extension

### Verify Installation

Open PowerShell or Command Prompt:

```powershell
# Check .NET SDK version
dotnet --version
# Should show 8.0.x or higher
```

## Quick Start (Visual Studio 2022)

### 1. Open the Project
- Launch Visual Studio 2022
- Open `PeakView.Windows/PeakView.csproj` or `desktopie.sln`

### 2. Restore Dependencies
Visual Studio will automatically restore NuGet packages. If not:
- Right-click solution → **Restore NuGet Packages**

### 3. Build
- Select **Release** configuration (or **Debug** for development)
- Press `Ctrl+Shift+B` or **Build → Build Solution**

### 4. Run
- Press `F5` (with debugging) or `Ctrl+F5` (without debugging)

## Quick Start (Command Line)

### 1. Navigate to Project
```powershell
cd path\to\desktopie\PeakView.Windows
```

### 2. Restore Dependencies
```powershell
dotnet restore
```

### 3. Build
```powershell
# Debug build
dotnet build

# Release build
dotnet build -c Release
```

### 4. Run
```powershell
# Run directly
dotnet run

# Run Release build
dotnet run -c Release
```

## Creating a Portable Executable

### Option 1: Using Build Script (Recommended)

```bash
# On Windows with Git Bash or WSL
cd PeakView.Windows
./build.sh
```

The executable will be at:
```
bin/Release/net8.0-windows/win-x64/publish/PeakView.exe
```

### Option 2: Manual Build

```powershell
# Self-contained (includes .NET runtime - ~150MB)
dotnet publish -c Release `
    -r win-x64 `
    --self-contained true `
    -p:PublishSingleFile=true `
    -p:IncludeNativeLibrariesForSelfExtract=true

# Framework-dependent (requires .NET 8.0 runtime - ~10MB)
dotnet publish -c Release `
    -r win-x64 `
    --self-contained false `
    -p:PublishSingleFile=true
```

## Testing the Application

### 1. Main Window
When you first run PeakView, you'll see:
- **Left Panel (35%)**: System monitoring cards
  - CPU usage with percentage
  - Memory usage with available/total
  - Network speed (upload/download)
  - Disk usage percentage

- **Right Panel (65%)**: Task Manager
  - List of running processes
  - CPU and Memory usage per process
  - Kill process functionality

### 2. Atlas Mode
To enter Atlas Mode:
1. Press `Ctrl+Shift+A` (if implemented) or use the menu
2. You'll see the full-screen command interface
3. Try typing: `network`, `cpu`, `memory`, `all metrics`
4. Press `Enter` to execute a command

**Atlas Mode Shortcuts:**
- `Ctrl+K` - Toggle command palette
- `ESC` - Return to initial screen
- Type to search commands

### 3. Themes
Test theme switching in Atlas Mode:
- Type: `theme: samaritan` - Red terminal theme with scanlines
- Type: `theme: pure black` - Pure black with vibrant accents

## Development Workflow

### 1. Project Structure
```
PeakView.Windows/
├── App.xaml                    # Application entry
├── MainWindow.xaml             # Main UI layout
├── Core/                       # Business logic
│   ├── SystemMonitor.cs        # System metrics
│   ├── TaskManager.cs          # Process management
│   ├── NetworkMonitor.cs       # Network connections
│   └── ConfigManager.cs        # Configuration
├── Views/                      # Additional windows
│   ├── AtlasView.xaml          # Atlas Mode UI
│   └── AtlasView.xaml.cs       # Atlas Mode logic
├── Models/                     # Data models
│   ├── Config.cs
│   ├── ProcessData.cs
│   └── NetworkConnection.cs
└── Resources/Themes/           # Color themes
    └── Colors.xaml
```

### 2. Hot Reload
Visual Studio 2022 supports XAML Hot Reload:
- Make changes to `.xaml` files while debugging
- UI updates immediately without restart

### 3. Debugging
Set breakpoints in `.cs` files:
- Click left margin in editor (red dot appears)
- Press `F5` to debug
- `F10` - Step over, `F11` - Step into

### 4. Configuration Location
Config file is stored at:
```
%APPDATA%\PeakView\config.json
```

View/edit it:
```powershell
notepad $env:APPDATA\PeakView\config.json
```

## Common Issues

### Issue: "Performance counter not found"
**Solution**: Run as Administrator (Performance Counters require elevated privileges)

### Issue: "ModernWPF not found"
**Solution**: Restore NuGet packages
```powershell
dotnet restore
```

### Issue: Build fails with SDK errors
**Solution**: Ensure .NET 8.0 SDK is installed
```powershell
dotnet --list-sdks
```

### Issue: Application crashes on startup
**Solution**: Check Event Viewer for .NET runtime errors:
- Windows Key + X → Event Viewer
- Windows Logs → Application
- Look for .NET Runtime errors

## Next Steps

### Implement Atlas Mode Widgets
Edit [Views/AtlasView.xaml.cs](Views/AtlasView.xaml.cs):
- Find `HandleCommand()` method (line 147)
- Implement widget content loading:
```csharp
else
{
    // Show widget screen
    InitialScreen.Visibility = Visibility.Collapsed;
    WidgetScreen.Visibility = Visibility.Visible;

    // Load widget content based on command
    LoadWidget(command.Name);
}
```

### Add System Tray
1. Add reference: `System.Windows.Forms`
2. Create `NotifyIcon` in `App.xaml.cs`
3. Add context menu with Show/Hide/Exit

### Add Settings Panel
1. Create `Views/SettingsWindow.xaml`
2. Add theme selector, update interval slider
3. Save to `ConfigManager`

### Add Network Monitor Panel
1. Create `Views/NetworkMonitorWindow.xaml`
2. Display connections from `NetworkMonitor`
3. Add process-to-connection mapping (requires P/Invoke)

## Resources

- [WPF Documentation](https://docs.microsoft.com/en-us/dotnet/desktop/wpf/)
- [ModernWPF UI Library](https://github.com/Kinnara/ModernWpf)
- [Performance Counters](https://docs.microsoft.com/en-us/dotnet/api/system.diagnostics.performancecounter)
- [System.Management (WMI)](https://docs.microsoft.com/en-us/dotnet/api/system.management)

## Contributing

See the main repository for contribution guidelines.

---

Need help? Check [README.md](README.md) for detailed documentation.
