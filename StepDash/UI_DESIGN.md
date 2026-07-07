# StepDash UI Design

StepDash uses a pixel-art delivery game interface: playful, readable, and dense enough for quick daily check-ins. The app should feel like a small game HUD rather than a standard fitness dashboard.

## Design Goals

- Make steps feel like game progress, not raw health data.
- Keep the primary screen instantly scannable: player, steps, coins, current delivery, missions, and navigation.
- Use chunky pixel-inspired UI surfaces, crisp bitmap assets, and short labels.
- Prioritize direct actions: accept delivery, claim reward, switch destination, close popup.
- Avoid marketing-style screens inside the app. The first experience should be usable.

## Visual Language

The app combines two related pixel styles:

- Onboarding uses hard-edged retro panels with square borders and offset shadows.
- Gameplay uses rounded pixel boxes over a full-screen SpriteKit scene.

Use monospaced system fonts through `Pixel.font(...)` until a bundled pixel font is added. Keep headings bold and compact. Labels should be uppercase when they behave like HUD labels.

## Color System

Shared palette lives in:

- `StepDash/Attributes/PixelTheme.swift`
- `StepDash/Attributes/DesignKit.swift`

Core semantic colors:

- `Pixel.ink`: primary text and dark borders.
- `Pixel.cream`: onboarding panel fill.
- `Pixel.red`: strong action or selected state.
- `Pixel.grass` / `Pixel.dGreen`: positive action, especially start or accept.
- `Pixel.dYellow`: claim-ready reward state.
- `Pixel.dOrange`: delivery title and progress emphasis.
- `Pixel.dNavy`: player chip and bottom toolbar.
- `Pixel.dBlue`: home category boxes.
- `Pixel.dTrack`: progress track background.
- `Pixel.dMuted`: secondary labels.

When adding colors, prefer semantic names on `Pixel` instead of inline values in screens.

## Layout Principles

- Keep the game scene full-screen and place UI as an overlay.
- Use stable dimensions for HUD elements so changing numbers do not shift the layout.
- Keep the top bar compact and aligned: player, steps, coins.
- Keep bottom navigation persistent across gameplay screens.
- Use popups for focused secondary tasks like missions.
- Keep controls large enough for touch, especially action buttons and toolbar icons.

## Main Screens

### Onboarding

File: `StepDash/App/OnboardingView.swift`

Purpose: create the player profile before entering the game.

Current structure:

- Scrolling pixel background.
- Logo at the top.
- `ProfileSetup` panel.
- Name field with max 6 characters.
- Gender segmented buttons.
- Height stepper.
- Start button.

Rules:

- Keep the form short.
- Name should remain compact because it appears in the home HUD.
- Use `PixelButtonStyle` for the primary start action.
- Use `pixelPanel()` for the main setup panel.

### Home

File: `StepDash/GameScreen/HomeView.swift`

Purpose: daily game dashboard.

Current structure:

- Full-screen SpriteKit `SceneBand`.
- Top HUD with player, today's steps, and coins.
- Current delivery panel.
- Category boxes for achievements, missions, and history.
- Bottom toolbar.
- Missions popup overlay.

Rules:

- The SpriteKit scene is the background, not a framed preview.
- UI floats above the scene with enough contrast.
- The current delivery is the primary action area.
- Keep category boxes visually equal and easy to tap.

### Missions Popup

File: `StepDash/GameScreen/MissionsPopup.swift`

Purpose: show auto-tracked daily missions and claimable rewards.

Current structure:

- Dimmed backdrop.
- Centered rounded frame.
- Purple title chip.
- Close icon button.
- Scrollable mission list.
- Footer countdown to refresh.

Rules:

- Claimable state should be obvious with `Pixel.dYellow`.
- Completed claimed missions use the check icon.
- Keep rows fixed-height and scannable.
- Do not navigate away from the game scene for this flow.

### Toolbar Destinations

File: `StepDash/GameScreen/ToolbarDestinationView.swift`

Purpose: secondary pages reached from the bottom toolbar.

Rules:

- Use dashboard panels and inset cards for structured information.
- Keep values close to their labels.
- Preserve bottom toolbar behavior for easy return to Home.

## Components

### `PixelBox`

Use for rounded HUD surfaces. Default radius is 8.

Good for:

- Home top-bar chips.
- Delivery panel sections.
- Category boxes.
- Compact reward boxes.

### `pixelPanel`

Use for onboarding-style square panels with thick borders and offset shadow.

Good for:

- Retro forms.
- Primary onboarding containers.
- Large start or setup surfaces.

### `PixelButtonStyle`

Use for large square primary actions.

Good for:

- Start button.
- Any future high-emphasis onboarding action.

### `PixelIcon`

Use for image assets that should render crisply.

Rules:

- Keep `.interpolation(.none)` for pixel art.
- Prefer asset catalog names first.
- Keep icons visually balanced inside fixed frames.

## Interaction States

Buttons should have a visible state change:

- Pixel onboarding buttons use offset press feedback.
- Delivery buttons use opacity feedback.
- Disabled buttons should lower emphasis and stay readable.
- Claim-ready rewards use yellow.
- Incomplete claim actions use muted text and disabled state.

## Copy Guidelines

- Use short labels: `START`, `ACCEPT`, `CLAIM`, `MISSIONS`.
- Use uppercase for HUD labels.
- Keep explanatory text out of the main gameplay screen.
- Use helper text only where the user needs input constraints, such as `Max 6 characters`.

## Assets

Primary visual assets live in:

- `StepDash/Assets.xcassets`
- `StepDash/Sprites`

Important assets currently used by UI:

- `StepDashLogo`
- `Head1`
- `Shoe`
- `Coin`
- `House1`
- `Package`
- `Check`
- `X`
- `bg`

Asset rules:

- Use bitmap assets for game visuals.
- Keep pixel art crisp with `.interpolation(.none)`.
- Avoid blurry, decorative, or unrelated imagery.

## Accessibility And Responsiveness

- Text should not overlap at small sizes.
- Use `lineLimit(1)` and `minimumScaleFactor(...)` for compact HUD labels.
- Keep touch targets around 44 points or larger where possible.
- Do not rely only on color for completion state; icons and labels should help.
- Test long names, large step counts, and zero-progress states.

## Adding New UI

Before adding a new screen or component:

1. Check whether `PixelBox`, `DashboardPanel`, `InsetCard`, `DashboardBar`, or `PixelButtonStyle` already fits.
2. Use existing `Pixel` semantic colors.
3. Keep layout stable with fixed heights or predictable frames for HUD elements.
4. Prefer direct actions over explanatory text.
5. Verify in portrait phone layout first.

## Current Design Direction

StepDash should continue moving toward a cohesive pixel delivery game:

- Home is the center of the experience.
- Missions and delivery rewards provide daily loops.
- Profile setup stays simple.
- Secondary pages should support the game loop without feeling like separate apps.
