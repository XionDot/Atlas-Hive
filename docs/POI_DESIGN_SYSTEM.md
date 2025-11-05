# PeakView: POI-Inspired Intelligence Interface
**Carbon copy of Person of Interest aesthetic with unique PeakView features**

---

## Core Aesthetic (From POI)

### The Machine Interface (Our Primary Style)
- **Background**: Pure black (#000000) ✓
- **Primary Color**: Yellow/Gold (#FFD700) for boxes and highlights
- **Text**: White (#FFFFFF) primary, gray for secondary
- **Font**: Monospace (Roboto Mono or SF Mono)
- **Box Style**: Dashed corner brackets (not full rectangles)
- **Grid Overlay**: Subtle grid lines across entire interface
- **Timestamp**: HH:MM:SS.mmm format, constantly updating

### Box Classification System (POI Style)

```
┌─────┐ WHITE BOX       = Normal monitoring
│     │                   Regular processes

┌─────┐ YELLOW BOX      = Known/Important
│     │                   System critical processes

┌─────┐ RED BOX         = Threat/High usage
│     │                   Dangerous resource levels

┌─────┐ BLUE BOX        = User Applications
│     │                   Your apps and tools
```

### Visual Language
1. **Corner Brackets**: Not full boxes, just corners (POI signature)
2. **Dashed Lines**: Dashed rectangles, not solid
3. **Crosshairs**: Target reticle on focused items
4. **Scan Lines**: Horizontal lines sweeping down periodically
5. **Data Overlay**: Semi-transparent technical data overlays
6. **Glitch Effect**: Occasional subtle glitch/static effect

---

## POI UI Elements to Implement

### 1. Surveillance View (Main Interface)
**Exactly like POI but for system monitoring**

```
┌────────────────────────────────────────────────────┐
│  PEAKVIEW SURVEILLANCE SYSTEM    [██] 23:45:12.456 │
│  ╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌ │
│                                                     │
│  ┌╌╌╌╌╌╌╌┐                     ┌╌╌╌╌╌╌╌┐          │
│  ┆SAFARI ┆   CPU: 5.2%         ┆ ✓     ┆  ADMIN   │
│  ┆PID:234┆   MEM: 234MB        ┆       ┆          │
│  └╌╌╌╌╌╌╌┘   STATUS: MONITORED └╌╌╌╌╌╌╌┘          │
│  > CLASSIFICATION: RELEVANT                        │
│  > THREAT LEVEL: NONE                              │
│  > BEHAVIOR: NORMAL                                │
│                                                     │
│  ┌╌╌╌╌╌╌╌┐                     ┌╌╌╌╌╌╌╌┐          │
│  ┆CHROME ┆   CPU: 67.3%        ┆  ⚠    ┆  ALERT   │
│  ┆PID:567┆   MEM: 2.1GB        ┆       ┆          │
│  └╌╌╌╌╌╌╌┘   STATUS: ELEVATED  └╌╌╌╌╌╌╌┘          │
│  > CLASSIFICATION: RELEVANT                        │
│  > THREAT LEVEL: ELEVATED                          │
│  > BEHAVIOR: ANOMALOUS                             │
│                                                     │
│  [RELEVANT] [IRRELEVANT] [ADMIN] [UNKNOWN]        │
└────────────────────────────────────────────────────┘
```

### 2. Process Classification (POI Categories)

**RELEVANT** (Yellow Box)
- Processes using significant resources
- User applications in focus
- Anything currently important

**IRRELEVANT** (White Box)
- Background system processes
- Low resource usage
- Stable, quiet processes

**ADMIN** (Blue Box)
- System-critical processes
- Root/admin level processes
- macOS core services

**UNKNOWN** (Gray Box)
- Newly launched processes
- Unknown origin
- Pending classification

**THREAT** (Red Box)
- Excessive resource usage
- Crashed/hung processes
- Potential malware behavior

### 3. Targeting System
**POI's crosshair effect**

When you hover over a process:
```
      ┃
   ───┃───
      ┃
  ┏━━━╋━━━┓
  ┃ SAFARI┃
  ┃ LOCKED ┃
  ┗━━━╋━━━┛
      ┃
   ───┃───
      ┃
```

- Crosshairs appear
- Process info locks on
- "TRACKING" label appears
- Can right-click for actions

### 4. Data Streams (POI Style)
**Background technical readouts**

```
SYSTEM UPTIME........... 12:34:45
PROCESSES MONITORED..... 247
THREADS ACTIVE.......... 3,456
MEMORY AVAILABLE........ 8.2 GB
CPU CORES............... 12
TEMPERATURE............. 45°C
NETWORK RX/TX........... ↓234KB/s ↑45KB/s
DISK I/O................ 12 MB/s

> ANALYZING PROCESS TREE
> CALCULATING THREAT VECTORS
> MONITORING NETWORK ACTIVITY
> TRACKING RESOURCE ALLOCATION
```

### 5. Timeline Scrubber (POI Signature)
**Bottom of screen**

```
├────|────|────|────|────|────|────|────|────┤
00:00   05:00   10:00   15:00   20:00   NOW
  │       │       ◆       │       ▲
  └─ Boot └─ Peak └─ Crash─┘    Current

◆ = Critical Event
▲ = Current Position
│ = Process Launch
```

### 6. Alert System (POI Style)
**Red box expands with alert**

```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃  ⚠ CRITICAL ALERT                 ┃
┃  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  ┃
┃                                   ┃
┃  PROCESS: Chrome                  ┃
┃  PID: 567                         ┃
┃  THREAT: Memory exhaustion        ┃
┃  TIME: 23:45:12.789              ┃
┃                                   ┃
┃  > SYSTEM RECOMMENDS: TERMINATE   ┃
┃                                   ┃
┃  [KILL] [MONITOR] [IGNORE]       ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

### 7. Number Stations (POI Easter Egg)
**Background audio (optional)**

Like POI's number broadcasts:
- Subtle background numbers being read
- When system detects threats
- "Process 2-3-4... relevant"
- Can toggle on/off

---

## Our Unique Additions

### 1. Process Relationship Map
**Network graph like POI but showing process relationships**

```
        ┌─────┐
        │Finder│
        └──┬──┘
     ┌─────┼─────┐
  ┌──┴──┐ │ ┌───┴───┐
  │Quick│ │ │Spotlight│
  │Look │ │ └───────┘
  └─────┘ │
      ┌───┴────┐
      │Terminal│
      └───┬────┘
       ┌──┴──┐
       │ vim │
       └─────┘
```

- Yellow lines = active communication
- Dashed lines = spawned relationship
- Thickness = data flow

### 2. Predictive Overlay
**POI had predictions, we have resource predictions**

```
┌───────────────────────────────┐
│ PREDICTIVE ANALYSIS           │
│ ─────────────────────────     │
│                               │
│ CHROME.EXE                    │
│ > MEMORY TREND: INCREASING    │
│ > PREDICTED CRASH: 00:02:34   │
│ > CONFIDENCE: 87%             │
│ > RECOMMENDATION: RESTART NOW │
│                               │
│ [TAKE ACTION] [MONITOR]      │
└───────────────────────────────┘
```

### 3. Geolocation for Network
**Show where network connections go**

```
ACTIVE CONNECTIONS
━━━━━━━━━━━━━━━━━━
► 172.217.14.206 → Google LLC (US)
► 52.85.151.33   → Amazon AWS (VA)
► 104.16.249.249 → Cloudflare (CA)

[MAP VIEW] would show world map with arcing lines
```

### 4. Voice Synthesis (Optional)
**Like POI's machine voice**

Spoken alerts:
- "Process relevant: Chrome"
- "Threat detected: Memory critical"
- "System optimal"
- "New admin process: sudo"

Can use macOS text-to-speech

### 5. Code Name System
**Give processes code names like POI**

Instead of just "Safari.app":
- "NAVIGATOR-01" (Safari)
- "TERMINAL-07" (Terminal)
- "COMPILER-02" (Xcode)
- "EDITOR-04" (VSCode)

User can customize codenames

---

## Implementation Details

### Fonts
```swift
// POI-style monospace
let primaryFont = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
let headerFont = NSFont.monospacedSystemFont(ofSize: 14, weight: .semibold)

// Or custom
// Roboto Mono (free Google font)
// Inconsolata (free font)
// SF Mono (already on macOS)
```

### Colors
```swift
extension Color {
    // POI Machine colors
    static let machineYellow = Color(hex: "#FFD700")  // Primary
    static let machineWhite = Color(hex: "#FFFFFF")   // Normal
    static let machineRed = Color(hex: "#FF0000")     // Threat
    static let machineBlue = Color(hex: "#00A8FF")    // Admin
    static let machineGray = Color(hex: "#808080")    // Unknown
    static let machineBlack = Color(hex: "#000000")   // Background
}
```

### Box Drawing
```swift
struct POIBox: View {
    let color: Color
    let dashed: Bool

    var body: some View {
        Rectangle()
            .strokeBorder(
                style: StrokeStyle(
                    lineWidth: 2,
                    dash: dashed ? [5, 5] : []
                )
            )
            .foregroundColor(color)
    }
}

struct CornerBrackets: View {
    let color: Color
    let size: CGFloat = 20

    var body: some View {
        ZStack {
            // Top-left
            Path { path in
                path.move(to: CGPoint(x: size, y: 0))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 0, y: size))
            }
            .stroke(color, lineWidth: 2)

            // Top-right
            Path { path in
                path.move(to: CGPoint(x: size, y: 0))
                path.addLine(to: CGPoint(x: 2*size, y: 0))
                path.addLine(to: CGPoint(x: 2*size, y: size))
            }
            .stroke(color, lineWidth: 2)

            // Bottom corners (similar)
        }
    }
}
```

### Scan Line Effect
```swift
struct ScanLineView: View {
    @State private var offset: CGFloat = 0

    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.clear, .white.opacity(0.1), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(height: 100)
            .offset(y: offset)
            .onAppear {
                withAnimation(
                    .linear(duration: 3)
                    .repeatForever(autoreverses: false)
                ) {
                    offset = UIScreen.main.bounds.height
                }
            }
    }
}
```

### Glitch Effect
```swift
struct GlitchEffect: ViewModifier {
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1

    func body(content: Content) -> some View {
        content
            .offset(x: offset)
            .opacity(opacity)
            .onAppear {
                // Random glitch every 10-30 seconds
                Timer.scheduledTimer(withTimeInterval: .random(in: 10...30), repeats: true) { _ in
                    withAnimation(.linear(duration: 0.1)) {
                        offset = .random(in: -5...5)
                        opacity = 0.8
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        offset = 0
                        opacity = 1
                    }
                }
            }
    }
}
```

---

## Phase 1 Implementation (Start Here)

### Week 1: Core POI Aesthetic
- [ ] Switch to monospace fonts
- [ ] Implement yellow corner brackets
- [ ] Add classification colors (yellow/white/red/blue/gray)
- [ ] Create dashed box components
- [ ] Add timestamp display (HH:MM:SS.mmm)
- [ ] Grid overlay on background

### Week 2: Process Classification
- [ ] Auto-classify processes
- [ ] Box coloring based on classification
- [ ] Add labels: RELEVANT, IRRELEVANT, ADMIN, etc.
- [ ] Hover targeting system with crosshairs
- [ ] Process info cards with POI style

### Week 3: Advanced Features
- [ ] Timeline scrubber at bottom
- [ ] Scan line animation
- [ ] Alert system with POI style boxes
- [ ] Data stream sidebar
- [ ] Glitch effects

### Week 4: Our Unique Features
- [ ] Process relationship map
- [ ] Predictive analysis overlay
- [ ] Network geolocation
- [ ] Code name system
- [ ] Voice synthesis (optional)

---

## Reference Screenshots

**POI Machine Interface Key Elements**:
1. Dashed corner brackets (not full boxes)
2. Yellow = important/relevant
3. White = normal monitoring
4. Red = threat/critical
5. Black background
6. Monospace font
7. Constant timestamp
8. Grid overlay
9. Technical data streams
10. Classification labels

**Our Twist**:
- Apply this to system monitoring instead of people
- Processes are "subjects"
- Resource usage = "threat level"
- Network connections = "associations"
- Process tree = "social network"

---

## Settings Options

**POI Mode Toggle**:
- [ ] Enable/Disable POI aesthetic
- [ ] Classic mode (current look)
- [ ] POI mode (new intelligence interface)

**Customization**:
- [ ] Color scheme (Machine yellow/white or Samaritan white/blue)
- [ ] Scan line speed
- [ ] Glitch frequency
- [ ] Voice alerts on/off
- [ ] Code names on/off
- [ ] Grid overlay opacity

---

*Design Document Version: 2.0*
*POI-Inspired with PeakView Uniqueness*
*Created: 2025-11-05*
