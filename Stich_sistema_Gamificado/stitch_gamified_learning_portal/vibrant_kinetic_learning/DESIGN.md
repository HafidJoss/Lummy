---
name: Vibrant Kinetic Learning
colors:
  surface: '#f9f9fc'
  surface-dim: '#dadadc'
  surface-bright: '#f9f9fc'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f3f6'
  surface-container: '#eeeef0'
  surface-container-high: '#e8e8ea'
  surface-container-highest: '#e2e2e5'
  on-surface: '#1a1c1e'
  on-surface-variant: '#444656'
  inverse-surface: '#2f3133'
  inverse-on-surface: '#f0f0f3'
  outline: '#757687'
  outline-variant: '#c5c5d8'
  surface-tint: '#2c49ea'
  primary: '#001e9b'
  on-primary: '#ffffff'
  primary-container: '#002dd6'
  on-primary-container: '#aab4ff'
  inverse-primary: '#bbc3ff'
  secondary: '#346b00'
  on-secondary: '#ffffff'
  secondary-container: '#90fd3b'
  on-secondary-container: '#377200'
  tertiary: '#671200'
  on-tertiary: '#ffffff'
  tertiary-container: '#8f1d00'
  on-tertiary-container: '#ffa089'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dee0ff'
  primary-fixed-dim: '#bbc3ff'
  on-primary-fixed: '#000e5e'
  on-primary-fixed-variant: '#002bcf'
  secondary-fixed: '#90fd3b'
  secondary-fixed-dim: '#75df16'
  on-secondary-fixed: '#0b2000'
  on-secondary-fixed-variant: '#255100'
  tertiary-fixed: '#ffdad2'
  tertiary-fixed-dim: '#ffb4a2'
  on-tertiary-fixed: '#3d0700'
  on-tertiary-fixed-variant: '#8a1c00'
  background: '#f9f9fc'
  on-background: '#1a1c1e'
  surface-variant: '#e2e2e5'
typography:
  headline-xl:
    fontFamily: Quicksand
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Quicksand
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Quicksand
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
  headline-md:
    fontFamily: Quicksand
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Quicksand
    fontSize: 18px
    fontWeight: '500'
    lineHeight: 28px
  body-md:
    fontFamily: Quicksand
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
  label-lg:
    fontFamily: Quicksand
    fontSize: 14px
    fontWeight: '700'
    lineHeight: 20px
  label-sm:
    fontFamily: Quicksand
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  container-margin: 24px
  gutter: 16px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 32px
---

## Brand & Style
The brand personality is high-energy, encouraging, and inherently playful. It targets learners who thrive in an environment that feels less like a classroom and more like an interactive playground. The visual language is designed to evoke feelings of progress, excitement, and accessibility.

This design system utilizes a **refined-playful** style. It blends the clarity of modern SaaS with the tactile friendliness of casual gaming. Key characteristics include exaggerated corner radii, high-contrast interactive elements, and a "squishy" tactile feel. The goal is to lower the cognitive barrier to learning through a UI that feels responsive and rewarding to touch.

## Colors
The palette is built on high-saturation "Power Primaries" to drive engagement and clear functional signaling.

- **Primary (Vibrant Blue):** Used for core navigation, progress tracking, and primary actions. It represents the "logic" and foundation of the app.
- **Secondary (Energetic Green):** Reserved for "success" states, leveling up, and completion. It provides a dopamine hit upon task finishing.
- **Tertiary (Bold Orange/Red):** Used for "streaks," urgent notifications, and high-energy challenges.
- **Surface & Background:** The default state is a clean, bright white (`#FFFFFF`) to ensure the vibrant colors pop. Subtle off-white (`#F8F9FF`) is used for grouping related content blocks to maintain a soft contrast.

## Typography
The typography utilizes **Quicksand** exclusively to maintain a consistent, friendly character. Its rounded terminals mirror the UI's physical shapes.

- **Headlines:** Set in Bold (700) or SemiBold (600) with tight letter-spacing to create a "sticker-like" impactful feel for headers.
- **Body:** Set in Medium (500) to ensure legibility while maintaining a softer look than standard book weights.
- **Labels:** Use uppercase and bold weights for small navigational elements to ensure they remain functional despite their friendly aesthetic.

## Layout & Spacing
The system follows a **fluid grid** logic with generous safe areas.

- **Mobile:** A single-column layout with 24px side margins. Elements are typically full-width or card-based.
- **Desktop/Tablet:** A 12-column grid with a maximum content width of 1200px.
- **Rhythm:** An 8px base unit drives all padding and margins. Vertical rhythm should feel "breathable"—don't be afraid of whitespace; it prevents the vibrant colors from becoming overwhelming.
- **Patterns:** Use subtle geometric watermarks (circles and soft triangles) in the background to add texture to large empty areas without distracting from the content.

## Elevation & Depth
Depth is conveyed through **Soft Tactile Shadows** rather than traditional elevation tiers. 

- **Level 0 (Background):** Flat, bright white or extremely light blue.
- **Level 1 (Cards):** Substantial 16px to 24px blur radius shadows with low opacity (approx. 8-12%), tinted slightly with the primary blue (`#002DD6`) to keep the "light" feeling active.
- **Interactive Depth:** Buttons and clickable cards should use a 3D "press" effect. This is achieved by using a thick bottom border (4px) in a darker shade of the element's color, which disappears on the `:active` state to simulate a physical push.

## Shapes
Shapes are unapologetically rounded to communicate safety and friendliness.

- **Primary Radius:** 16px (1rem) for standard cards and buttons.
- **Large Radius:** 24px (1.5rem) for major layout containers and "Level Up" modals.
- **Icons:** Use a consistent stroke weight (2px or 3px) with rounded caps and joins to match the typography.

## Components
- **Buttons:** Large, high-contrast, and "chunky." Primary buttons use the 4px bottom-border technique mentioned in Elevation. All buttons should have a minimum height of 56px for easy tapping.
- **Progress Bars:** Thick (12px+) with fully rounded caps. Use a high-contrast track color (e.g., light grey) and the secondary green for the fill to indicate progress.
- **Input Fields:** Thick outlines (2px) that change from grey to Primary Blue on focus. Use Quicksand Medium for placeholder text.
- **Chips/Badges:** Pill-shaped with a light background tint of the status color (e.g., light green background with dark green text for "Correct").
- **Cards:** White background with a 1px soft border and the standard Level 1 shadow. Cards should never have sharp corners.
- **Streak Indicators:** Special component using the Tertiary Orange/Red with a flame icon and a "bouncing" animation to draw the user's eye.