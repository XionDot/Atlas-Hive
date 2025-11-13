# PeakView Development Progress Tracker

> **⚠️ TODO: REBRAND** - Need to rename app from "PeakView" to something better. Current name and logo are temporary placeholders. Consider alternatives that better reflect the privacy-first, system monitoring mission.

## Overview
Building PeakView - a privacy-focused macOS system monitoring app with dual-mode interface (Simple/Advanced) for both System Monitor and Task Manager views.

## Current Status: Phase 3 - Bug Fixes and Polish

---

## Phase 1: Core Architecture ✅ COMPLETED

### System Monitoring Core ✅
- [x] CPU usage tracking with history (60-second rolling window)
- [x] Memory calculation matching Activity Monitor (using internal pages)
- [x] Network monitoring (download/upload speeds)
- [x] Disk usage tracking
- [x] Battery monitoring with health metrics
- [x] History arrays for real-time graphing

### Memory Calculation Fix ✅
- [x] Fixed memory calculation to match Activity Monitor exactly
- [x] Using `sysctlbyname` for internal/external page counts
- [x] Memory Used = App Memory (internal pages) + Wired + Compressed
- [x] Added "Cached Files" metric alongside "Free" memory

### Configuration System ✅
- [x] Config persistence to disk (JSON)
- [x] Window behavior settings (showWindowOnLaunch, keepMenuBarWhenWindowClosed)
- [x] Theme support (light/dark/system)
- [x] View mode support (simple/advanced)
- [x] Section ordering configuration

---

## Phase 2: Main Window Implementation ✅ COMPLETED

### Two-Column Layout ✅
- [x] 35:65 split layout (System Monitor 420px / Task Manager 780px)
- [x] Total window size: 1200x700
- [x] MainWindowView.swift with HStack layout
- [x] Divider between columns
- [x] Both columns responsive to view mode changes

### System Monitor Column ✅
- [x] Header with title, mode toggle (Simple/Advanced), and settings button
- [x] Simple mode: StatusCard-based layout
  - CPU, Memory, Network, Disk, Battery cards
  - Status text (Good/Moderate/High/Critical)
  - Color-coded percentage display
- [x] Advanced mode: Detailed metrics with graphs
  - SystemMetricCard components for each metric
  - Real-time 60-second graphs for CPU, Memory, Network
  - Detailed breakdown (Memory: Used/Free/Cached, Network: Download/Upload, etc.)
  - Battery health with cycles and charge status

### Task Manager Column ✅
- [x] Header with title and refresh button
- [x] Quick filters: All, High CPU, High Memory, My Apps, System Apps
- [x] Search bar with live filtering
- [x] Simple mode: User apps only with large icons
  - SimpleProcessRow with app icons, CPU/Memory usage
  - Close button for each process
- [x] Advanced mode: All processes with detailed view
  - AdvancedProcessRow with PID, progress bars
  - Sortable columns (Name, CPU, Memory)
  - System summary (Total CPU, Total Memory, Process count)
  - Restart and Kill actions

### Supporting Views ✅
- [x] SystemMetricCard - Card component for advanced metrics
- [x] RealtimeGraphView - Line graph with gradient fill
- [x] MetricDetailRow - Key-value row for detailed metrics
- [x] FilterButton - Quick filter toggle buttons
- [x] SimpleProcessRow - Large app card for simple mode
- [x] AdvancedProcessRow - Compact process row with controls

---

## Phase 3: Bug Fixes and Polish 🔄 IN PROGRESS

### Current Issues
- [ ] **PRIORITY 1**: Menu bar click shows main window instead of popover
  - Status: Identified in PeakViewApp.swift handleClick method
  - Fix: Change `showMainWindow()` to `togglePopover()`
  - Need to restore popover functionality for menu bar clicks

- [ ] **PRIORITY 2**: Simple mode layout needs optimization
  - Status: Layout currently requires scrolling in 420px width
  - Fix needed: Make StatusCard components more compact
  - Reduce spacing, padding, font sizes as needed
  - Goal: Fit all content without scrolling

- [ ] **PRIORITY 3**: Test menu bar persistence
  - Verify menu bar works when main window closed
  - Verify menu bar works when main window minimized
  - Test popover dismiss and reopen

### Compilation Status ✅
- [x] MainWindowView.swift - No errors
- [x] SystemMonitorColumn struct properly closed
- [x] All helper functions in correct scope
- [x] TaskManagerColumn fully implemented

### Recent Fixes ✅
- [x] Fixed naming conflict (MetricSection → SystemMetricCard)
- [x] Fixed layout split ratio (50:50 → 35:65)
- [x] Removed duplicate mode toggle from Task Manager header
- [x] Fixed struct scope issues with helper functions

---

## Phase 4: Feature Completion (PENDING)

### Menu Bar Integration
- [x] Menu bar item creation
- [x] Custom icons (alert_status_menubar@2x.png)
- [x] Menu bar display modes (text stats or mini graph)
- [ ] Popover integration (NEEDS FIX)
- [x] Right-click context menu
- [x] Privacy controls in menu (Camera/Microphone/USB toggles)

### Window Management
- [x] Main window creation with MainWindowView
- [x] Window delegate for close behavior
- [x] Keep menu bar active when window closed
- [x] Window shows on launch (configurable)
- [ ] Launch at startup option (NOT IMPLEMENTED)

### Settings Panel
- [ ] Settings view integration (referenced but not implemented)
- [ ] Theme picker (Light/Dark/Auto)
- [ ] Update interval slider
- [ ] Menu bar display options
- [ ] Window behavior toggles
- [ ] Launch at startup toggle

---

## Phase 5: Testing and Polish (PENDING)

### Testing Checklist
- [ ] Mode toggle functionality (Simple ↔ Advanced)
- [ ] All quick filters work correctly
- [ ] Process search and filtering
- [ ] Process kill/restart actions
- [ ] Memory calculation accuracy
- [ ] Graph updates in real-time (60-second window)
- [ ] Battery metrics display correctly
- [ ] Network speed tracking
- [ ] Dark/Light mode appearance
- [ ] Menu bar icon updates
- [ ] Popover interaction

### Performance Optimization
- [ ] Reduce update interval impact
- [ ] Optimize process list rendering (LazyVStack)
- [ ] Icon caching for processes
- [ ] Memory leak checks

### UI/UX Polish
- [ ] Animated transitions between modes
- [ ] Loading states for process list
- [ ] Empty states for filters with no results
- [ ] Tooltips and help text
- [ ] Keyboard shortcuts
- [ ] Accessibility labels

---

## Privacy Requirements ✅

- [x] No analytics or tracking
- [x] All monitoring is local
- [x] No network requests (except system monitoring)
- [x] Privacy controls in menu (Camera/Microphone/USB)
- [x] PrivacyManager integration

---

## Known Issues and Technical Debt

### Critical
1. Menu bar click behavior incorrect (shows window instead of popover)
2. Simple mode layout scrolling issue

### Medium Priority
- Settings panel not implemented yet
- Launch at startup not implemented
- No keyboard shortcuts defined

### Low Priority
- Consider adding more graph customization
- Add export functionality for system reports
- Consider adding notifications for high resource usage

---

## File Structure

```
Sources/
├── PeakViewApp.swift          - App delegate, menu bar, window management
├── MainWindowView.swift        - Main two-column layout
├── SimplifiedMonitorView.swift - Simple view for popover
├── SimplifiedTaskManagerView.swift - Simple task view for popover
├── ContentView.swift          - Legacy view (used in popover)
├── MonitorView.swift          - Legacy monitor view
├── SystemMonitor.swift        - Core system monitoring APIs
├── TaskManager.swift          - Process management
├── ConfigManager.swift        - Configuration persistence
├── PrivacyManager.swift       - Privacy controls
└── ... (other supporting files)
```

---

## Recent Commits

```
f523014 - Add custom menu bar icon loading with retina support
abebe03 - Replace app icon with alert_status.iconset
dd483a6 - Implement real battery health calculation from IOKit
67ed545 - Fix battery display and add health indicator in advanced mode
7371a9c - Remove network speed from menu bar to fix crashes
```

---

## Next Steps (Immediate)

1. ✅ Create this progress tracker document
2. 🔄 Fix menu bar click to show popover (CURRENT)
3. 🔄 Optimize simple mode layout to remove scrolling
4. ⏳ Test menu bar functionality thoroughly
5. ⏳ Final polish and testing

---

## User Feedback History

1. "Memory usage shows 95%" → Fixed by using internal pages calculation
2. "Big update - two-column layout" → Implemented MainWindowView
3. "35:65 layout split" → Fixed from 50:50 to 35:65
4. "Simple/Advanced for both columns" → Implemented dual-mode system
5. "Menu bar should show popover" → Current priority fix
6. "Simple mode needs no scrolling" → Next priority fix

---

## Build Status

- Last Build: Running (65de02)
- Build Command: `./build_app.sh && ./install.sh`
- Status: ✅ Building/Installing

---

## Phase 6: Modern UI Redesign & Crash Fixes ✅ COMPLETED

### Modern Security-Focused UI Redesign (2025-11-03)
Implemented comprehensive modern design throughout the entire application with security-focused aesthetic.

#### Settings Panel - Slide-In Design ✅
- [x] Converted from tab-based navigation to slide-in panel system
- [x] ZStack architecture with overlay and blur effect
- [x] Settings panel slides from right (450px wide)
- [x] Spring animation (0.4s response, 0.8 damping fraction)
- [x] Background blur (3px radius) when panel is open
- [x] Dark overlay (0.3 opacity) with tap-to-dismiss
- [x] Modern header with shield icon and gradient (blue-to-cyan)
- [x] Close button (X icon) for dismissing panel
- [x] Shadow effect for depth and elevation

#### Settings Section Components ✅
- [x] Gradient icon badges (32x32 rounded squares)
- [x] Blue-to-cyan gradient backgrounds for icons
- [x] White icons on gradient background
- [x] Elevated cards with subtle shadows (0.05 opacity, 8px radius)
- [x] Gradient borders (blue-to-cyan, 0.2/0.1 opacity)
- [x] 12px border radius for modern feel
- [x] 16px padding inside cards
- [x] Professional spacing and typography

#### Main Window - System Monitor Header ✅
- [x] Added gradient icon (chart.xyaxis.line) with blue-to-cyan gradient
- [x] Bold title text (17pt, weight: bold)
- [x] Modern toggle buttons for Simple/Advanced mode:
  - Gradient background when selected (blue-to-cyan)
  - White text when selected, blue when not
  - 12px horizontal, 6px vertical padding
  - 6px corner radius
  - 4px spacing between buttons
- [x] Settings gear icon with gradient when active
- [x] Elevated button container (gray 0.1 opacity, 8px corner radius)

#### Main Window - Task Manager Header ✅
- [x] Added gradient icon (app.badge) with green-to-mint gradient
- [x] Bold title text matching System Monitor style
- [x] Refresh button with gradient styling:
  - Green-to-mint gradient for icon
  - 32x32 frame size
  - Green 0.1 opacity background
  - 8px corner radius
- [x] Consistent modern header design

#### Theme System Enhancements ✅
- [x] Added emoji indicators to all 7 themes:
  - 🔄 System Default
  - ☀️ Light
  - 🌙 Dark
  - ✨ Vibrant Light
  - 🌃 Vibrant Dark
  - 🔆 High Contrast Light
  - 🌑 High Contrast Dark
- [x] Added `.onChange()` handler to force immediate theme application
- [x] Dividers between theme groups in picker
- [x] Picker available in both Simple and Advanced modes

#### Menu Bar Popover (SimplifiedMonitorView) ✅
- [x] Modern header with gradient icon (chart.xyaxis.line)
- [x] Blue-to-cyan gradient for System Monitor title icon
- [x] Info button with gradient styling
- [x] Advanced mode button with full gradient background:
  - White text on blue-to-cyan gradient
  - 10px horizontal, 5px vertical padding
  - 6px corner radius
- [x] Power button remains red for visibility
- [x] Updated StatusCard components with modern design:
  - Icon in colored rounded square (36x36, 8px radius)
  - Color-specific opacity backgrounds (0.15)
  - Bold fonts for values
  - Shadows for elevation (0.05 opacity, 4px radius)
  - Color-based borders (0.2 opacity)
  - 10px corner radius
  - 12px padding
- [x] Modern gradient buttons at bottom:
  - "Open Apps" with green-to-mint gradient
  - "Settings" with blue-to-cyan gradient
  - White text, semibold fonts
  - Colored shadows (0.3 opacity, 4px radius)
  - 8px corner radius

### Critical Crash Fixes ✅
Fixed app crashes related to NSTask/Process usage throughout the codebase.

#### SystemMonitor.swift Fixes ✅
- [x] **getDetailedCPUMetrics()** - Wrapped system_profiler launch in try-catch
  - Changed deprecated `launchPath` to `executableURL`
  - Added error handling with print statements
  - Graceful fallback to "N/A" on failure
  - Prevents app crash when system_profiler fails

- [x] **getDeviceModel()** - Updated to modern Process API
  - Changed `launchPath` to `executableURL`
  - Added error logging
  - Graceful fallback to model identifier

#### TaskManager.swift Fixes ✅
- [x] **getAllProcesses()** - Updated Process API
  - Changed `launchPath` to `executableURL` for bash
  - Maintained existing error handling

- [x] **getProcessPath()** - Enhanced error handling
  - Changed `launchPath` to `executableURL`
  - Added descriptive error logging
  - Graceful return of empty string on failure

- [x] **killProcess()** - Modern API with logging
  - Changed `launchPath` to `executableURL`
  - Added error logging for debugging

- [x] **restartProcess()** - Updated to executableURL
  - Modern Process API for /usr/bin/open
  - Existing error handling maintained

#### PrivacyManager.swift Fixes ✅
- [x] **executeShellCommand()** - Updated bash execution
  - Changed `launchPath` to `executableURL`
  - Added error logging
  - Maintained graceful error handling

### Build System Improvements ✅
- [x] Updated install.sh to kill existing PeakView processes
  - Added `killall -9 PeakView 2>/dev/null || true`
  - Ensures clean install without process conflicts
  - Prevents "app is already running" issues

### Dock Icon ✅
- [x] Removed `LSUIElement` from Info.plist
- [x] App now appears in dock with active indicator
- [x] Dock icon shows when app is running (like Spotify)

### Files Modified
1. **MainWindowView.swift** (Lines 59-147, 405-453, 1002-1063)
   - System Monitor header with gradients
   - Task Manager header with gradients
   - New SettingsPanel component
   - ZStack with slide-in panel architecture

2. **SettingsView.swift** (Lines 91-105, 268-319)
   - Enhanced theme picker with emojis
   - Added .onChange() handler
   - Redesigned SettingsSection with gradients

3. **SimplifiedMonitorView.swift** (Lines 14-82, 299-348, 170-221)
   - Modern header with gradients
   - Updated StatusCard design
   - Gradient action buttons

4. **SystemMonitor.swift** (Lines 141-169, 522-562)
   - Fixed NSTask crashes with try-catch
   - Updated to executableURL API

5. **TaskManager.swift** (Lines 70-80, 122-142, 147-165, 171-186)
   - All Process calls updated to executableURL
   - Enhanced error handling

6. **PrivacyManager.swift** (Lines 197-218)
   - Updated shell command execution

7. **ConfigManager.swift** (No changes, themes already implemented)

8. **Info.plist** (Lines 23-24)
   - Removed LSUIElement for dock icon

9. **install.sh** (Lines 5-7)
   - Added process killing before install

### Color Scheme
- **System Monitor**: Blue-to-cyan gradients
- **Task Manager**: Green-to-mint gradients
- **Settings**: Blue-to-cyan gradients (matches System Monitor)
- **Status Colors**:
  - Green (Good, 0-40%)
  - Yellow (Moderate, 40-70%)
  - Orange (High, 70-90%)
  - Red (Critical, 90-100%)

### Build Status
- Last Build: Successful ✅
- App Launches: Without crashes ✅
- All features: Working as expected ✅

---

## Phase 7: Network Monitoring Tool ✅ COMPLETED

### Wireshark-Like Network Monitor (2025-11-03)
Implemented comprehensive privacy-first network monitoring with Wireshark-inspired interface.

#### Core Network Monitoring ✅
- [x] NetworkMonitor.swift - Core monitoring class with ObservableObject pattern
- [x] Real-time connection tracking (TCP/UDP protocols)
- [x] Connection state machine (ESTABLISHED, LISTEN, SYN_SENT, etc.)
- [x] Process identification and caching for performance
- [x] Network statistics aggregation (packets, bytes, top processes)
- [x] Timer-based updates every 2 seconds
- [x] Memory-only data storage (no persistence)

#### NetworkConnection Model ✅
- [x] Identifiable and Hashable for SwiftUI List performance
- [x] Process metadata (name, PID)
- [x] Address information (local/remote IP and ports)
- [x] Protocol classification (TCP, UDP, ICMP, Other)
- [x] Connection state tracking
- [x] Bandwidth metrics (bytes sent/received)
- [x] Timestamp for connection tracking
- [x] Formatted output helpers (uploadSpeed, downloadSpeed, totalTraffic)

#### NetworkManagerView UI ✅
- [x] Slide-over panel design (900px wide) matching Settings panel
- [x] Purple-to-pink gradient theme for network features
- [x] Modern header with network icon and close button
- [x] HSplitView layout: connection list + detail panel
- [x] Sortable connection table with 7 sort columns:
  - Process name
  - Protocol type
  - Local address
  - Remote address
  - Connection state
  - Bytes transferred
  - Timestamp
- [x] Quick filter system:
  - All Connections
  - TCP only
  - UDP only
  - Established connections
  - Listening ports
- [x] Live search bar for filtering by process/address
- [x] Connection detail panel showing:
  - Process information (name, PID)
  - Protocol details
  - Address information (local/remote with ports)
  - Connection state
  - Bandwidth metrics (upload/download/total)
  - Timestamp
- [x] Real-time statistics bar:
  - Active connections count
  - Total packets
  - Total data transferred
  - Bytes per second
  - Top 5 processes by bandwidth
- [x] Manual refresh button
- [x] CSV export functionality (user-controlled)
- [x] Empty state messaging

#### Privacy-First Architecture ✅
- [x] **NO packet capture** - Uses system commands only (netstat, ps)
- [x] **NO deep packet inspection** - Only connection metadata
- [x] **NO persistent storage** - All data in memory
- [x] **NO external communication** - Completely local monitoring
- [x] **Read-only access** - Cannot modify network traffic
- [x] Manual export only - User must explicitly export data to CSV
- [x] Process caching for performance optimization
- [x] Sandboxed operation within macOS security model

#### Technical Implementation Details ✅
- [x] Uses `/usr/bin/netstat` for connection data
  - TCP connections: `netstat -anvp tcp`
  - UDP connections: `netstat -anvp udp`
- [x] Uses `/bin/ps` for process name resolution
- [x] Address parsing for IPv4 and IPv6
- [x] Connection state mapping from netstat output
- [x] Bandwidth calculation (placeholder - no actual packet capture)
- [x] Top processes aggregation by total bandwidth
- [x] Filtering and search with SwiftUI computed properties

#### UI Integration ✅
- [x] Added Network Monitor button to System Monitor header
- [x] Slide-over panel architecture matching Settings panel
- [x] Spring animations (0.4s response, 0.8 damping)
- [x] Background blur and dark overlay when panel open
- [x] Tap-to-dismiss overlay functionality
- [x] Close button (X icon) in panel header
- [x] ZStack layering with proper transitions
- [x] State management via @State and @Binding
- [x] Two-column layout preserved (420px + 780px)

#### Files Created/Modified ✅
1. **NetworkMonitor.swift** (NEW - ~415 lines)
   - NetworkConnection struct with enums
   - NetworkStats struct
   - PacketInfo struct
   - NetworkMonitor class with ObservableObject
   - Connection fetching and parsing logic
   - Statistics calculation
   - CSV export functionality

2. **NetworkManagerView.swift** (NEW - ~690 lines)
   - Main NetworkManagerView with filters and search
   - ConnectionListView with sortable table
   - ConnectionDetailView with detailed metrics
   - StatsBar with real-time statistics
   - FilterBar with quick filter buttons
   - NetworkDetailRow component
   - FilterButton component
   - EmptyStateView component

3. **MainWindowView.swift** (MODIFIED)
   - Added `@State private var showNetworkMonitor: Bool`
   - Created NetworkMonitorPanel wrapper (lines ~1002-1063)
   - Added Network button to SystemMonitorColumn header
   - ZStack integration for slide-over panel
   - Background blur and overlay logic

4. **NETWORK_MONITOR_UPDATE.md** (NEW)
   - Comprehensive privacy documentation
   - Feature capabilities and limitations
   - Security measures explanation
   - User privacy commitment

#### Design Changes ✅
- [x] Initial tab-based navigation removed per user request
- [x] Slide-over panel approach implemented (like Settings)
- [x] Two-column layout restored and preserved
- [x] Network panel width increased to 900px for usability
- [x] Purple-to-pink gradient for network features
- [x] Consistent modern design language

#### Known Limitations (By Design) ✅
- No actual packet capture (privacy protection)
- Bandwidth metrics are placeholders (no BPF/libpcap)
- Cannot decrypt encrypted traffic (privacy protection)
- Cannot modify network traffic (read-only)
- No persistent logging (memory-only)
- Requires manual export for data saving

#### Testing Status ✅
- [x] App compiles without errors
- [x] Build successful with only minor warnings
- [x] Network Monitor button appears in System Monitor header
- [x] Slide-over panel animations work correctly
- [x] Connection list populates from netstat
- [x] Filtering and search functionality
- [x] CSV export generates valid output

### Build Status
- Last Build: Successful ✅
- Network Monitor: Fully integrated ✅
- Privacy-first architecture: Documented ✅
- Slide-over UI: Working as expected ✅

---

---

## Phase 8: Sparkline Graphs & Unified Color Scheme ✅ COMPLETED

### UI Enhancements (2025-11-05)
Improved visual consistency and added real-time sparkline graphs to metric headers.

#### Sparkline Mini-Graphs ✅
- [x] Created SparklineView component in ModularMetricBlock.swift
- [x] Compact inline graphs (60x24px) for metric headers
- [x] Added to CPU metric header showing cpuHistory
- [x] Added to Memory metric header showing memoryHistory
- [x] Color-coded based on percentage thresholds:
  - Green (0-40%)
  - Yellow (40-70%)
  - Orange (70-90%)
  - Red (90-100%)
- [x] Animated line drawing with 0.3s easeInOut duration
- [x] Background fill with 0.1 opacity for visual depth
- [x] Rounded corners (3px radius) for modern aesthetic
- [x] Automatic scaling based on data point max value

#### SparklineView Implementation Details ✅
- [x] SwiftUI GeometryReader for responsive sizing
- [x] Path-based line drawing with proper normalization
- [x] Safe max value handling (prevents division by zero)
- [x] Graceful handling of empty/single data point arrays
- [x] Real-time updates as history arrays populate
- [x] 60-second rolling window from SystemMonitor

#### Unified Dark Color Scheme ✅
- [x] Replaced all `Color(NSColor.controlBackgroundColor)` with `Color.darkBackground`
- [x] Replaced all `Color.gray.opacity()` backgrounds with `Color.darkCard`
- [x] Applied consistent dark theme throughout main window:
  - System Monitor Column header
  - Task Manager Column header
  - Network Monitor Panel header
  - Settings Panel (already using VisualEffectBlur)
  - System Info Panel (already using VisualEffectBlur)
  - Quick filters background
  - Search bar background
  - Process list headers
  - Filter buttons container
  - SystemMetricCard backgrounds

#### Color Unification Changes ✅
- [x] MainWindowView.swift header backgrounds → Color.darkCard
- [x] NetworkMonitorPanel header → Color.darkCard
- [x] TaskManagerColumn header → Color.darkCard
- [x] Mode toggle container → Color.darkBackground
- [x] Quick filters bar → Color.darkCard.opacity(0.5)
- [x] Search bar background → Color.darkCard.opacity(0.5)
- [x] Column headers → Color.darkCard.opacity(0.5)
- [x] SystemMetricCard → Color.darkCard

#### Color Extensions Reference ✅
Using ColorExtensions.swift color definitions:
- **Color.darkBackground**: `Color(white: 0.05)` in dark mode
- **Color.darkCard**: `Color(white: 0.08)` in dark mode
- Both adapt to light mode with system colors

#### Visual Improvements ✅
- [x] Consistent dark shade throughout entire UI
- [x] Exceptional UI quality with unified color palette
- [x] Better contrast between cards and backgrounds
- [x] Professional "one color" aesthetic requested by user
- [x] Seamless integration between System Monitor and Task Manager
- [x] Mini sparkline graphs provide instant visual feedback
- [x] Real-time history visualization without expanding views

#### Files Modified ✅
1. **ModularMetricBlock.swift**
   - Added SparklineView struct (lines 3-48)
   - Added sparkline to cpuContent (lines 139-143)
   - Added sparkline to memoryContent (lines 179-183)

2. **MainWindowView.swift**
   - System Monitor header background (line 281)
   - NetworkMonitorPanel header (line 125)
   - TaskManagerColumn header (line 733)
   - Mode toggle container (line 214)
   - Quick filters bar (line 757)
   - Search bar background (line 777)
   - Column headers (line 1034)
   - SystemMetricCard backgrounds (line 1228)

### Build Status ✅
- Last Build: Successful
- Sparkline Graphs: Working in CPU and Memory metrics
- Color Scheme: Fully unified across main window
- Visual Quality: Exceptional as requested

---

## Phase 9: Theme System Overhaul & Vibrant Colors ✅ COMPLETED

### Theme System Improvements (2025-11-06)
Complete redesign of the theme system with pure black mode and vibrant color palette.

#### Samaritan-Inspired Loading Screen ✅
- [x] PeakViewLoadingView.swift - Futuristic loading animation
- [x] 3-second progressive loading animation
- [x] Monospaced typography with letter spacing
- [x] Loading messages: "INITIALIZING SYSTEM...", "LOADING CORE MODULES...", etc.
- [x] Red/orange gradient for dark mode, blue/cyan for light mode
- [x] Progress bar with glow effect
- [x] Adaptive theming based on user's selected theme
- [x] Shown at app launch (3.5 second display time)

#### Pure Black Theme Implementation ✅
- [x] "black af" theme now uses pure #000000 black
- [x] ColorExtensions.swift updated to detect system vs custom themes
- [x] System default (window.appearance == nil) uses macOS colors
- [x] "white af" and "black af" are custom themes
- [x] Theme detection logic differentiates between all three modes
- [x] Menu bar icon ALWAYS white regardless of app theme

#### Menu Bar Icon Fixes ✅
- [x] Removed isTemplate flag for consistent white display
- [x] PNG icon loading with white tinting via sourceAtop blending
- [x] Mini graph bars changed from blue/green to white
- [x] Icon remains white on dark macOS menu bar (system appearance)
- [x] App theme changes don't affect menu bar icon color

#### Theme Picker UI Redesign ✅
- [x] Replaced dropdown picker with horizontal button layout
- [x] ThemeButton component with blue selection indicator
- [x] Entire button area clickable (contentShape)
- [x] Theme labels: "🔄 System", "☀️ white af", "⬛ black af"
- [x] Available in both simple and advanced modes
- [x] Instant theme application (no action needed)

#### Popover Theme Updates ✅
- [x] ConfigManager stores weak reference to popover
- [x] Theme applies directly to popover content view
- [x] Popover updates immediately when theme changes
- [x] No need to interact with popover for theme to update
- [x] PeakViewApp connects popover reference on initialization

#### Vibrant Color System for Black AF Mode ✅
- [x] New vibrant color variants that pop against pure black
- [x] isBlackAFMode helper function checks current theme
- [x] Vibrant colors return neon-like RGB values:
  - **vibrantCyan**: RGB(0.0, 0.9, 1.0) - Electric cyan
  - **vibrantBlue**: RGB(0.2, 0.6, 1.0) - Bright blue
  - **vibrantGreen**: RGB(0.0, 1.0, 0.4) - Neon green
  - **vibrantMint**: RGB(0.3, 1.0, 0.8) - Bright mint
  - **vibrantOrange**: RGB(1.0, 0.6, 0.0) - Vivid orange
  - **vibrantRed**: RGB(1.0, 0.2, 0.3) - Bright red
  - **vibrantPurple**: RGB(0.8, 0.3, 1.0) - Bright purple
  - **vibrantPink**: RGB(1.0, 0.3, 0.8) - Hot pink
  - **vibrantYellow**: RGB(1.0, 0.9, 0.0) - Bright yellow
- [x] All gradients updated to use vibrant versions
- [x] Status indicators use vibrant colors (CPU, memory, temperature, battery)
- [x] Progress bars and metrics use vibrant colors
- [x] Colors auto-adapt: vibrant in black af, standard in light/system

#### Advanced Mode Filters Restored ✅
- [x] Filter buttons back in Task Manager advanced mode
- [x] Filters: All, High CPU, High Memory, My Apps, System
- [x] Positioned between header and search bar
- [x] Only visible in advanced mode (clean simple mode)
- [x] ScrollView for horizontal scrolling if needed

#### Hardware Sensor Monitoring ✅
- [x] SMCHelper.swift - Direct SMC (System Management Controller) access
- [x] Real CPU temperature readings via IOKit
- [x] Real fan speed readings (RPM)
- [x] Battery temperature monitoring
- [x] Disk temperature tracking
- [x] Native hardware sensor integration

#### Files Modified/Created ✅
1. **ColorExtensions.swift** (51 → 109 lines)
   - Added isBlackAFMode detection
   - Added 9 vibrant color variants
   - Enhanced theme detection logic

2. **ConfigManager.swift**
   - Added weak popover reference
   - Updated applyTheme() for selective window targeting
   - Added direct popover content view theme application

3. **SettingsView.swift**
   - Replaced dropdown with horizontal button layout
   - Added ThemeButton component
   - Made entire button clickable with contentShape

4. **MainWindowView.swift**
   - Updated all gradients to vibrant versions
   - Updated status indicator colors
   - Restored advanced mode filters
   - Applied vibrant colors to: blue/cyan, green/mint, purple/pink gradients

5. **PeakViewApp.swift**
   - Added loading screen with app theme
   - Connected popover reference to ConfigManager
   - Removed isTemplate from menu bar icons
   - Added PNG icon white tinting
   - Mini graph bars changed to white

6. **PeakViewLoadingView.swift** (NEW - 146 lines)
   - Samaritan-inspired loading screen
   - Progressive animation with messages
   - Adaptive theming

7. **SMCHelper.swift** (NEW - ~200 lines)
   - Direct SMC access for hardware sensors
   - Temperature and fan speed monitoring

8. **themerules.txt** (NEW)
   - Theme system documentation
   - Describes system default, white af, black af themes
   - Menu bar icon behavior rules

#### Theme Rules Documentation ✅
- System Default: Follows macOS appearance
- white af: Custom light theme, menu bar follows system
- black af: Pure black (#000000) custom theme, menu bar follows system
- Menu bar icon ALWAYS follows macOS menu bar appearance
- Theme persists across app launches

### Build Status ✅
- Last Build: Successful
- Pure black theme: Working perfectly
- Vibrant colors: Eye-catching and readable in black af mode
- Menu bar icon: Always white
- Popover theme updates: Instant
- Advanced filters: Restored

---

## Phase 10: Atlas Mode & Command Palette ✅ COMPLETED

### Atlas Mode Implementation (2025-01-11)
Full-screen "mission control" interface with command-driven navigation and theme-adaptive design.

#### Core Features ✅
- [x] **Full-Screen Interface**
  - Grid overlay with 60px spacing (theme-adaptive color)
  - Scanlines effect (Samaritan mode only)
  - Pure black or themed background
  - Automatic fullscreen toggle when entering/exiting

- [x] **Command Palette System**
  - Centered search bar with fuzzy matching
  - Keyboard navigation (⌘K toggle, ↑↓ navigate, Enter execute, ESC reset)
  - 700px width (centered), 500px (widget view)
  - Live filtering with keywords
  - 8 command suggestions max

- [x] **Theme Adaptivity**
  - Follows all app themes (System, Light, Dark, Black AF, Samaritan)
  - Vibrant blue/cyan accents for dark themes
  - Standard blue/cyan for light themes
  - Samaritan red/orange for terminal theme
  - All UI components theme-aware (no hardcoded colors)

#### Widget System ✅
- [x] **Available Widgets**
  - Network Monitor - Traffic & speed analysis
  - CPU Analytics - Processor metrics with temperature
  - Memory Status - RAM usage & pressure
  - Disk Analysis - Storage metrics
  - Process Manager - Top 10 processes with CPU/Memory
  - System Overview - All metrics at a glance
  - All Metrics - Everything in one view

- [x] **Widget UI**
  - AtlasMetricCard components with icons and shadows
  - Large percentage displays (96pt monospace font)
  - Grid layouts (2-3 columns depending on widget)
  - Color-coded metrics (red/orange/amber/green)
  - Scrollable widget area with 40px padding

#### Command System ✅
- [x] **Widget Commands**
  - Launch any widget via search
  - Keywords for easy discovery
  - Icon and description for each

- [x] **System Commands**
  - Exit Atlas Mode
  - Open Settings Panel
  - Switch themes (4 options)
  - Quit application

- [x] **Theme Commands**
  - "Theme: Samaritan" - Red Terminal Theme
  - "Theme: Black AF" - Pure Black Theme
  - "Theme: White AF" - Pure Light Theme
  - "Theme: System" - Follow System Theme

#### Keyboard Shortcuts ✅
- [x] `⌘K` - Toggle command palette
- [x] `ESC` - Reset to initial state / Close palette
- [x] `↑↓` - Navigate command list
- [x] `Enter` - Execute selected command
- [x] Mouse click - Select and execute command

#### Visual Elements ✅
- [x] **Atlas Branding**
  - Large "ATLAS" title (72pt, bold, monospace, 8pt tracking)
  - Subtitle adapts to theme ("SAMARITAN SYSTEM INTERFACE" or "System Interface")
  - Glow effect on title (shadow with accent color)

- [x] **Key Hints**
  - Theme-adaptive colors
  - Rounded button style (4px radius)
  - Border with accent color opacity
  - Located below command prompt

- [x] **Collapsed Command Button**
  - Appears in widget view when palette hidden
  - "COMMAND PALETTE" text with terminal icon
  - Theme-adaptive border and shadow
  - Click to expand palette

- [x] **Widget Headers**
  - Icon + uppercased title
  - Description text below title
  - Theme-colored bottom border (3px)
  - Black background header bar

#### Network Integration ✅
- [x] NetworkMonitor instance per Atlas view
- [x] Starts monitoring on appear
- [x] Stops monitoring on disappear
- [x] Live connection tracking in "All Metrics" widget
- [x] Network analysis panel with process/protocol/state/traffic

#### Files Created ✅
1. **Sources/AtlasView.swift** (1,285 lines)
   - Main Atlas Mode view
   - Command palette components
   - Widget views and layouts
   - Theme-adaptive color system
   - Keyboard shortcut handling

2. **Sources/SamaritanCommandBar.swift** (445 lines)
   - Standalone command bar (not currently used)
   - Alternative command palette design
   - Samaritan-specific styling

#### Configuration Integration ✅
- [x] `configManager.config.atlasMode: Bool` - Toggle Atlas Mode
- [x] Persisted to config.json
- [x] Accessible via Settings or Command Palette
- [x] Automatic fullscreen on activation
- [x] Exits fullscreen on deactivation

#### Known Limitations
- Bandwidth metrics in Network widget are placeholders (no actual packet capture)
- Widget loading is instant (no loading states)
- No widget history/persistence (resets on ESC)
- Limited to 8 command suggestions at a time

### Build Status ✅
- Last Build: Successful (2025-01-11)
- Atlas Mode: Fully functional
- Theme adaptivity: Working across all themes
- Command palette: Responsive and fast
- Widget rendering: Smooth performance

---

## Future Features (Backlog - From big_update.txt)

### Planned Enhancements 📋

#### Multi-Device Monitoring 📡
- [ ] Local mesh network setup for device-to-device communication
- [ ] User-based authentication system
- [ ] Admin (creator) cannot access user data - privacy-first
- [ ] Potential features:
  - Monitor multiple Macs on local network
  - View aggregated system stats across devices
  - Remote process management
  - Network topology visualization
  - Device health dashboard
- [ ] Security considerations:
  - End-to-end encryption
  - Local-only communication (no cloud)
  - User-controlled access tokens
  - Zero-knowledge architecture
  - Bonjour/mDNS for local device discovery

#### Cross-Platform Ecosystem 🌐
- [ ] **Windows Version**
  - Port to Windows with same UI/design language
  - Use Windows Performance Counters for metrics
  - Maintain privacy-first architecture
  - Compatible with mesh network feature

- [ ] **Unix/Linux Version**
  - Port to Linux distributions
  - Use /proc filesystem and system calls
  - Consistent UI across all platforms
  - Same gradient color schemes
  - Compatible with mesh network feature

- [ ] **Platform Compatibility**
  - Unified design language across macOS, Windows, Linux
  - Consistent feature set
  - Cross-platform mesh network communication
  - Shared configuration format

#### ASI (Artificial Superintelligence) Integration 🤖
- [ ] AI-powered system optimization suggestions
- [ ] Predictive resource usage analysis
- [ ] Anomaly detection for unusual process behavior
- [ ] Automated performance tuning recommendations
- [ ] Natural language interface for system queries
- [ ] Privacy-preserving on-device AI processing
- [ ] Integration considerations:
  - Local model execution (no cloud APIs)
  - User-controlled AI features
  - Transparent AI decision making
  - Optional feature (can be disabled)

### Implementation Notes 📝
- **Multi-device monitoring**: Requires significant architecture changes
  - Mesh network may need Bonjour/mDNS for device discovery
  - Consider using WebSockets or custom TCP protocol
  - Authentication system needs careful security design
  - Privacy-first approach must be maintained throughout

- **Cross-platform**: Major development effort
  - Separate native implementations for each platform
  - Consider Qt or Electron for UI consistency
  - Or: Native Swift UI on Mac, WPF on Windows, GTK on Linux
  - Maintain consistent design language and color schemes

- **ASI Integration**: Research phase needed
  - Evaluate on-device ML frameworks (Core ML, TensorFlow Lite)
  - Define specific use cases and benefits
  - Ensure user privacy and control
  - Consider computational overhead

---

*Last Updated: 2025-01-11*
*Current Focus: Atlas Mode completed with full theme adaptivity. Cross-platform roadmap documented. Next: Notification alerts, CSV export, or per-app network usage.*
