# PeakView - Figma Design Guide for App Store Assets

## Quick Start in Figma

1. Go to figma.com and create a free account
2. Create a new design file (Desktop size)
3. Use the frame tool to create these standard Mac App Store sizes

## Required Asset Sizes

### App Icon (1024x1024px)
- Main app icon for the App Store listing
- Should be clean, recognizable, and look good at small sizes
- Export as PNG

### Mac App Store Screenshots
**Required sizes:**
- 2880 x 1800 pixels (16:10 ratio) - Retina display
- 1280 x 800 pixels (16:10 ratio) - Non-retina

**Recommended:** Create 3-5 screenshots showing key features

## Design Assets Needed

### 1. App Icon Design Brief
**Style:** Modern, clean, macOS Big Sur style
**Colors:**
- Primary: Deep blue gradient (#0066FF → #0047AB)
- Accent: Bright cyan (#00D4FF)
- Background: Subtle gradient with rounded corners (22.5% radius)

**Concept:**
- Mountain peak silhouette (represents "Peak" performance)
- Activity graph/metrics overlay
- Clean, minimalist design that works at 16x16px and 1024x1024px

**AI Prompt for Icon Generation:**
```
"macOS app icon, 1024x1024, modern minimalist design, mountain peak silhouette
in deep blue gradient, overlaid with ascending graph/chart lines in bright cyan,
rounded square with 22.5% corner radius, subtle depth and shadows, Big Sur style,
professional system utility aesthetic, flat design with gradient"
```

### 2. Screenshot Layout Template

**Figma Frame Setup:**
```
Frame 1: 2880 x 1800px "Hero Shot"
- Show the main popover interface
- Feature: System monitoring dashboard with live metrics
- Overlay text: "Monitor Your Mac at Peak Performance"
```

**Screenshot Ideas:**

#### Screenshot 1: Hero/Main Interface
**Content:** Full popover showing CPU, Memory, Battery, Disk stats
**Overlay Text:**
- Headline: "Complete System Monitoring"
- Subtext: "Real-time performance metrics in your menu bar"

#### Screenshot 2: Menu Bar Integration
**Content:** Menu bar with PeakView icon and right-click menu
**Overlay Text:**
- Headline: "Always Accessible"
- Subtext: "Quick access to privacy controls and task manager"

#### Screenshot 3: Simple/Advanced Modes
**Content:** Side-by-side comparison of simple and advanced views
**Overlay Text:**
- Headline: "Choose Your View"
- Subtext: "Simple overview or detailed metrics - you decide"

#### Screenshot 4: Task Manager
**Content:** Task Manager window showing running processes
**Overlay Text:**
- Headline: "Built-in Task Manager"
- Subtext: "Monitor and manage your apps and processes"

#### Screenshot 5: Privacy Controls
**Content:** Privacy toggles for camera, microphone, USB
**Overlay Text:**
- Headline: "Privacy First"
- Subtext: "Quick hardware access controls at your fingertips"

### 3. Figma Design System

**Color Palette:**
```
Primary Blue: #0066FF
Dark Blue: #0047AB
Cyan Accent: #00D4FF
Success Green: #34C759
Warning Yellow: #FFD60A
Alert Red: #FF453A
Background Light: #F5F5F7
Background Dark: #1C1C1E
Text Primary: #000000
Text Secondary: #8E8E93
```

**Typography:**
- Headlines: SF Pro Display, Bold, 48-64pt
- Subheadlines: SF Pro Text, Semibold, 24-32pt
- Body: SF Pro Text, Regular, 16-20pt
- Menu bar: SF Pro Text, Regular, 13pt

**Spacing:**
- Large: 40px
- Medium: 24px
- Small: 16px
- Tiny: 8px

## Figma Plugins to Install

1. **Remove BG** - Remove backgrounds from screenshots
2. **Iconify** - Access to SF Symbols and system icons
3. **Unsplash** - Free background images
4. **Blush** - Illustrations and graphics
5. **Stark** - Check contrast and accessibility

## Screenshot Best Practices

### Background Styles
- Use subtle gradients (light blue to white)
- Or blurred abstract shapes
- Keep it clean - don't distract from the UI

### Text Overlays
- Place in top-left or center
- Use contrasting colors for readability
- Add subtle shadow or background blur box
- Keep text concise and benefit-focused

### Device Mockups
- Show the app in context on a Mac screen
- Use high-quality MacBook Pro mockups from:
  - Figma Community (search "MacBook mockup")
  - Previewed.app exports

### Composition Tips
1. **Rule of thirds** - Place key elements at intersection points
2. **White space** - Don't crowd the design
3. **Hierarchy** - Make the headline obvious
4. **Consistency** - Use same style across all screenshots

## Export Settings in Figma

**For App Icon:**
- Format: PNG
- Scale: 1x (already at 1024x1024)
- No compression

**For Screenshots:**
- Format: PNG
- Scale: 1x, 2x (create both sizes)
- Optimize for web

## Quick Figma Workflow

1. **Set up frames** for all required sizes
2. **Import screenshots** of PeakView (use actual app screenshots)
3. **Add device mockups** from Figma Community
4. **Create background** (gradient or image)
5. **Add text overlays** with clear value propositions
6. **Export all assets**

## Where to Get PeakView Screenshots

Run PeakView and capture these views:
1. Main popover (left-click menu bar icon)
2. Right-click privacy menu
3. Advanced mode with all metrics
4. Simple mode view
5. Task Manager window
6. Battery health indicator

Take screenshots with:
```bash
# Full screen
Cmd + Shift + 3

# Selection
Cmd + Shift + 4

# Window
Cmd + Shift + 4, then press Space, click window
```

## Figma Community Resources

Search for these in Figma Community (all free):

1. "macOS Big Sur UI Kit" - System components
2. "Mac App Store Screenshots Template" - Pre-made layouts
3. "SF Pro Font" - macOS system font
4. "App Icon Template" - Rounded square grids
5. "MacBook Pro Mockup" - Device frames

## AI Image Generation Prompts

### For Marketing Backgrounds

**Mountain Peak Theme:**
```
"Abstract mountain peak silhouette, gradient blue to cyan,
minimal geometric style, soft lighting, wide aspect ratio,
clean professional tech aesthetic, 2880x1800 resolution"
```

**Performance/Speed Theme:**
```
"Abstract speed lines and data visualization particles,
dark blue gradient background, glowing cyan accent elements,
professional tech style, motion blur effect, high resolution"
```

**System Monitoring Theme:**
```
"Minimalist dashboard interface aesthetic, floating metrics cards,
gradient blue background, clean modern UI elements, data visualization,
professional software design, wide screen format"
```

## Final Checklist

- [ ] App Icon 1024x1024 exported
- [ ] 5 screenshots at 2880x1800 created
- [ ] All screenshots have clear headlines
- [ ] Text is readable and high contrast
- [ ] Color scheme is consistent
- [ ] No spelling/grammar errors
- [ ] Exported as PNG files
- [ ] Files named clearly (icon.png, screenshot-1.png, etc.)

## Example File Naming

```
peakview-app-icon.png
peakview-screenshot-1-hero.png
peakview-screenshot-2-menubar.png
peakview-screenshot-3-modes.png
peakview-screenshot-4-taskmanager.png
peakview-screenshot-5-privacy.png
```

---

**Need Help?**
- Figma Community: figma.com/community
- Figma Tutorials: youtube.com/figmadesign
- Mac App Store Guidelines: developer.apple.com/app-store/marketing/guidelines/
