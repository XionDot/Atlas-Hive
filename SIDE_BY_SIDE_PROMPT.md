# Side-by-Side Screenshot Design Prompt

## For Figma:

### Frame Setup
1. Create a frame: **2880 x 1800px** (Mac App Store screenshot size)
2. Name it: "Screenshot 3 - View Modes Comparison"

### Layout Structure

**Background:**
- Gradient from #E8F4FF (top) to #FFFFFF (bottom)
- OR: Subtle radial gradient with #F0F8FF center fading to #E0EEF8 edges

**Main Content Area:**
- Center both images with equal spacing
- Add 120px padding on all sides
- 80px gap between the two images

### Step-by-Step Design:

#### 1. Background Layer
```
- Fill: Linear gradient 90° (top to bottom)
  Start: #E8F4FF
  End: #FFFFFF
- Alternative: Radial gradient from center
  Inner: #F0F8FF
  Outer: #D8E8F8
```

#### 2. Title Section (Top Center)
```
Text: "Choose Your Perfect View"
Font: SF Pro Display, Bold
Size: 64pt
Color: #1C1C1E
Position: Top center, 80px from top
Add subtle text shadow: 0px 2px 4px rgba(0,0,0,0.05)
```

#### 3. Left Image Container
```
Position: Left side, vertically centered
Image 1: Simple Mode screenshot
Add floating card effect:
  - Background: White (#FFFFFF)
  - Border radius: 16px
  - Shadow: 0px 20px 60px rgba(0,0,0,0.15)
  - Padding inside card: 16px
Label below: "Simple Mode"
  - Font: SF Pro Text, Semibold, 28pt
  - Color: #0066FF
  - Position: 24px below image
```

#### 4. Right Image Container
```
Position: Right side, vertically centered
Image 2: Advanced Mode screenshot
Add floating card effect:
  - Background: White (#FFFFFF)
  - Border radius: 16px
  - Shadow: 0px 20px 60px rgba(0,0,0,0.15)
  - Padding inside card: 16px
Label below: "Advanced Mode"
  - Font: SF Pro Text, Semibold, 28pt
  - Color: #0066FF
  - Position: 24px below image
```

#### 5. Decorative Elements (Optional but looks great!)

**Add subtle connecting line:**
- Draw line between images
- Style: Dashed, 2px thick
- Color: #0066FF at 30% opacity
- Position: Center, connecting the two cards

**Add icon in center:**
- Use SF Symbol: arrow.left.arrow.right or switch.2
- Size: 48x48px
- Color: #0066FF
- Background circle: White with shadow
- Position: Absolute center between images

#### 6. Description Text (Bottom)
```
Left description: "Clean overview for quick glances"
Right description: "Detailed metrics for power users"

Font: SF Pro Text, Regular, 20pt
Color: #8E8E93
Position: Below each label, 16px spacing
Max width: Match image width
Text align: Center
```

### Alternative Layout: Overlapping Style

**For a more dynamic look:**
```
1. Position images slightly overlapping (left image 5% over right)
2. Add depth by making left image slightly larger (105% scale)
3. Left image: z-index higher, more prominent shadow
4. Right image: Slightly dimmed (95% opacity)
5. Creates a "featured comparison" look
```

## AI Generation Prompt (for background decorations)

If you want an AI-generated background instead:

```
"Modern UI design background, subtle gradient from light blue to white,
minimal geometric shapes, floating transparent circles, soft bokeh effect,
professional software interface aesthetic, 2880x1800 resolution,
very light and subtle, should not distract from foreground content,
clean and airy composition"
```

## Quick Figma Workflow:

1. **Import both images** (drag and drop into Figma)
2. **Create auto-layout frame** (Shift + A)
   - Horizontal direction
   - Gap: 80px
   - Padding: 120px all sides
3. **Add images to frame** - they'll auto-arrange
4. **Apply effects:**
   - Select each image
   - Add drop shadow: 0, 20, 60, rgba(0,0,0,0.15)
   - Add background fill (white) to create card effect
   - Add corner radius: 16px
5. **Add text layers** above and below
6. **Export** as PNG at 2x

## Color Variations:

**Professional Blue:**
- Background: #E8F4FF → #FFFFFF
- Accent: #0066FF
- Text: #1C1C1E

**Vibrant Gradient:**
- Background: #E0F2FF → #F0E7FF (blue to purple)
- Accent: #0066FF
- Text: #1C1C1E

**Dark Mode Alternative:**
- Background: #1C1C1E → #2C2C2E
- Card background: #3C3C3E
- Accent: #00D4FF
- Text: #FFFFFF

## Pro Tips:

1. **Make images same height** - looks more balanced
2. **Use subtle animations** in Figma prototype mode (slide in effect)
3. **Add labels with icons** - Simple mode icon: eye.fill, Advanced: chart.bar.fill
4. **Keep text minimal** - let images speak for themselves
5. **Export at 2x** for retina display crispness

## Figma Community Resources:

Search for these free templates:
- "App comparison layout"
- "Side by side mockup"
- "Before after showcase"
- "Feature comparison template"

These often have pre-made layouts you can customize!

---

**Final Export Settings:**
- Format: PNG
- Scale: 2x
- Include: "Side by Side" in selection
- Name: peakview-screenshot-3-modes-comparison.png
