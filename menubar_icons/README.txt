MENU BAR ICONS FOR MACOS
=========================

This package contains 18 menu bar icons designed specifically for macOS status bar apps.

MENU BAR ICON SPECIFICATIONS:
------------------------------
✓ Transparent background (not black)
✓ Black monochrome design (#000000)
✓ Optimized for small sizes (16x16 for standard, 32x32 for Retina)
✓ Simple, minimal design for clarity at tiny sizes
✓ Ready to use as template images in macOS

FILE NAMING:
------------
- icon_name_menubar.png (16x16 - standard display)
- icon_name_menubar@2x.png (32x32 - Retina display)

INCLUDED ICONS:
---------------
1. soft_focus_menubar
2. complete_ring_menubar
3. share_pie_menubar
4. signal_wave_menubar
5. pulse_rings_menubar
6. loading_ring_menubar
7. status_bars_menubar
8. center_point_menubar
9. full_load_menubar
10. radar_ring_menubar
11. cloud_sync_menubar
12. window_frame_menubar
13. heat_monitor_menubar
14. cosmic_radar_menubar
15. hex_core_menubar
16. night_monitor_menubar
17. alert_status_menubar
18. cpu_core_menubar

HOW TO USE IN XCODE (SWIFT):
-----------------------------

1. Add both .png and @2x.png files to your Xcode project

2. Load as template image in code:

```swift
let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

if let button = statusItem.button {
    let icon = NSImage(named: "cpu_core_menubar")
    icon?.isTemplate = true  // This makes it adapt to light/dark mode!
    button.image = icon
}
```

3. The icon will automatically:
   - Switch colors in dark mode
   - Highlight when clicked
   - Match the system appearance

IMPORTANT NOTES:
----------------
• Always set isTemplate = true for menu bar icons
• macOS will automatically handle light/dark mode switching
• Keep designs simple - menu bar icons are very small
• Test in both light and dark mode
• Consider how the icon looks when highlighted (inverted)

BEST PRACTICES:
---------------
• Use simple, recognizable shapes
• Avoid fine details that won't show at 16x16
• Ensure good contrast
• Test at actual size (16x16) before deploying
• Icons should be clear and readable at a glance

DIFFERENCES FROM APP ICONS:
----------------------------
App Icons (in .iconset):
- Colored/gradient backgrounds
- Rounded corners
- Multiple large sizes
- Used in Dock, Finder, etc.

Menu Bar Icons (these):
- Transparent background
- Black only (system colorizes)
- Small sizes only (16x16, 32x32)
- Used in top menu bar

For more info: https://developer.apple.com/design/human-interface-guidelines/macos/icons-and-images/system-icons/
