# App Store Preparation Checklist for Desktopie

## Current Status

- [x] App optimized for performance
- [x] App icon created and integrated
- [x] Info.plist configured with metadata
- [x] Landing page created
- [x] README documentation complete
- [x] MIT License added
- [x] Release package created (1.8MB)

## App Store Submission Requirements

### 1. Apple Developer Program
- [ ] Enroll in Apple Developer Program ($99/year)
- [ ] Create App Store Connect account
- [ ] Set up App Store Connect app listing

### 2. Code Signing & Notarization

#### Current Status
- App is signed with Developer ID (ad-hoc)
- **Needs**: Proper Apple Developer certificate

#### Steps Required
```bash
# 1. Get Developer ID Application certificate from Apple
# 2. Update build_app.sh with proper signing identity
codesign --sign "Developer ID Application: Your Name (TEAM_ID)" \
  --timestamp --options runtime \
  --entitlements Desktopie.entitlements \
  --deep --force ./build/Desktopie.app

# 3. Create a signed and notarized build
xcrun notarytool submit Desktopie-1.0.0.zip \
  --apple-id "your@email.com" \
  --team-id "TEAM_ID" \
  --password "app-specific-password"

# 4. Staple the notarization ticket
xcrun stapler staple ./build/Desktopie.app
```

### 3. App Store Assets

#### App Icon
- [x] 1024x1024 icon for App Store (generated)
- [x] All required sizes in .appiconset

#### Screenshots (Required)
Create screenshots showing:
1. **Dashboard view** - Main monitoring interface
2. **Task Manager** - Process management in action
3. **Privacy Controls** - Toggle switches
4. **Settings** - Customization options
5. **Menu Bar** - Mini graph and text display modes

Screenshot sizes needed:
- 1280x800 (13" MacBook)
- 1440x900 (15" MacBook)
- 2880x1800 (Retina displays)

#### App Preview Video (Optional)
- 15-30 second demo video
- Show key features in action

### 4. App Store Connect Metadata

#### App Information
```
Name: Desktopie
Subtitle: System Monitor & Privacy Manager
Category: Utilities
Price: Free (or set price)

Description:
Desktopie is a powerful macOS menu bar application that puts system monitoring
and privacy control at your fingertips.

REAL-TIME MONITORING
• Monitor CPU, memory, network, disk, and battery in real-time
• Beautiful graphs and visualizations
• Customizable menu bar display

TASK MANAGER
• View all running processes
• Sort by CPU or memory usage
• Kill or restart any process with one click

PRIVACY CONTROLS
• Instantly revoke camera permissions
• Control microphone access system-wide
• One-click privacy protection

CUSTOMIZATION
• Light, Dark, or System theme
• Drag-and-drop section reordering
• Configurable update intervals

Desktopie is lightweight, fast, and respects your privacy with no tracking
or data collection. Everything runs locally on your Mac.

Keywords:
system monitor, activity monitor, task manager, cpu monitor, memory monitor,
privacy, camera control, menu bar, utilities

Support URL: https://github.com/ahmedzitoun/desktopie
Marketing URL: https://desktopie.app (if deploying website)
```

#### Privacy Policy
Since the app accesses system information and TCC database, you'll need a privacy policy. Here's a template:

**Desktopie Privacy Policy**
```
Desktopie respects your privacy and operates with full transparency:

DATA COLLECTION: None
Desktopie does not collect, store, or transmit any personal data or usage
information. All system monitoring occurs locally on your device.

SYSTEM ACCESS:
- System metrics (CPU, memory, etc.) are read using standard macOS APIs
- Process information is accessed to display in the task manager
- TCC database is accessed only when you explicitly use privacy controls

THIRD-PARTY SERVICES: None
Desktopie does not use any analytics, tracking, or third-party services.

PERMISSIONS:
- Full Disk Access: Required for privacy control features only
- Accessibility: Optional, for enhanced system monitoring

All data remains on your device and is never shared or transmitted.

Contact: support@desktopie.app
Last Updated: January 2025
```

### 5. Testing Requirements

#### Functionality Testing
- [x] Test on Apple Silicon
- [ ] Test on Intel Mac
- [ ] Test on macOS 13 (Ventura)
- [ ] Test on macOS 14 (Sonoma)
- [ ] Test on macOS 15 (Sequoia)

#### Features to Test
- [ ] System monitoring accuracy
- [ ] Task manager (kill/restart processes)
- [ ] Privacy controls (camera/microphone revocation)
- [ ] Theme switching (Light/Dark/System)
- [ ] Menu bar customization
- [ ] Settings persistence
- [ ] Performance with long runtime

### 6. Entitlements & Sandboxing

#### Current Configuration
```xml
<!-- Desktopie.entitlements -->
<key>com.apple.security.app-sandbox</key>
<false/>  <!-- Not sandboxed for system access -->
```

**Note**: App Store apps typically require sandboxing, but system monitoring
apps often need exceptions. You may need to request special entitlements from
Apple or consider:

1. **Option A**: Submit as-is and request sandbox exception
2. **Option B**: Create a sandboxed version with limited features
3. **Option C**: Distribute outside App Store (current approach works)

### 7. Distribution Alternatives

If App Store approval is challenging due to sandboxing requirements:

#### Direct Distribution (Current)
- [x] GitHub Releases
- [ ] Host website (desktopie.app) with download link
- [ ] Sign with Developer ID and notarize
- [ ] Update landing page with download button

#### Third-Party Stores
- [ ] Setapp (subscription-based distribution)
- [ ] MacUpdate
- [ ] Alternative app stores

## Next Steps (Priority Order)

1. **Deploy Website** (Immediate)
   - Host website/index.html on GitHub Pages or custom domain
   - Update download links to point to GitHub Releases

2. **Take Screenshots** (1 hour)
   - Capture all required screenshots
   - Optimize for different display sizes

3. **Developer Account** (If pursuing App Store)
   - Enroll in Apple Developer Program
   - Request sandbox exceptions if needed

4. **Notarize App** (2-3 hours)
   - Get proper certificates
   - Notarize the release build
   - Test notarized version

5. **Create Privacy Policy Page** (30 minutes)
   - Add privacy.html to website
   - Link from landing page footer

## Current Release Strategy Recommendation

**Direct Distribution** (Recommended for v1.0.0)
1. Host website on GitHub Pages
2. Distribute via GitHub Releases
3. Notarize the app for smooth user experience
4. Build user base and gather feedback
5. Consider App Store for v2.0.0 after validation

This approach:
- Gets the app to users immediately
- No $99 annual fee initially
- No App Store review delays
- Full feature set without sandbox restrictions
- Easier to iterate based on feedback

## Files Created

- ✅ [README.md](README.md) - Comprehensive documentation
- ✅ [LICENSE](LICENSE) - MIT License
- ✅ [website/index.html](website/index.html) - Landing page
- ✅ [releases/Desktopie-1.0.0.zip](releases/Desktopie-1.0.0.zip) - Release package
- ✅ [generate_icon.sh](generate_icon.sh) - Icon generator
- ✅ [package_release.sh](package_release.sh) - Release packager
- ✅ This file - App Store prep guide

## Resources

- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Notarizing macOS Software](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)
- [App Sandbox Design Guide](https://developer.apple.com/library/archive/documentation/Security/Conceptual/AppSandboxDesignGuide/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/macos)