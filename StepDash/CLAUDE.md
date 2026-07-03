# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

StepDash is an iOS game (SwiftUI + SwiftData + SpriteKit) where the player's real-world steps, read from the device pedometer, drive a side-scrolling courier character. It was built at the Apple Developer Academy (`ADA26`).

## Build & Run

- Open `StepDash.xcodeproj` in Xcode and run the `StepDash` scheme (there is no `.xcworkspace`, SPM, or CocoaPods setup).
- **Must run on a physical device.** Core Motion's `CMPedometer` returns no data in the Simulator; `MotionManager.start()` will log `❌ Pedometer not available` and no steps will register.
- There is no test target, linter config, or CI in this repo — do not assume `xcodebuild test` or a lint step exists.
- **Debug shortcuts for advancing without walking:** `GameScene.touchesBegan` moves the background one step; `GameSKView` binds the hardware **`k`** key to `moveBackground()`. `ContentView` shows a **"Reset Player Data"** button that deletes all `Player` rows (returning the app to onboarding).

## Architecture

### App flow

`StepDashApp` (`@main`) installs a SwiftData `.modelContainer(for: Player.self)` and forces `.light` color scheme. `ContentView` branches on the `Player` query: empty → `OnboardingView`; otherwise → `GameContainerView(name:stepLength:)` using `players[0]`. There is no multi-player or player-selection concept — the app assumes a single persisted `Player`.

### Onboarding → stepLength

`OnboardingView` collects name / gender / height, then `PlayerSetup.swift` (an `extension OnboardingView`) computes the core game constant in `submitLog()`:

```
stepLength = (gender == "male" ? 0.415 : 0.413) * (heightCm / 100)   // meters per step
```

It inserts+saves the `Player`, then calls `finish()` which flips `didFinish` to present the game via `.fullScreenCover`. `stepLength` is passed by value into the game and is the sole link between the SwiftData model and gameplay distance math.

### SwiftUI → SpriteKit bridge

The game is reached through three layers, each just forwarding `name` + `stepLength`:

`GameContainerView` (`UIViewRepresentable`) → `GameSKView` (custom `SKView`) → `GameScene` (`SKScene`).

`GameScene` is **created lazily in `GameSKView.layoutSubviews`**, gated by a `presented` flag and `bounds.size != .zero`, because the scene needs real bounds. `GameScene` uses a non-default `anchorPoint = (0,0)` and `scaleMode = .resizeFill`.

### GameScene is split across extension files

The class body (`GameScene.swift`) holds only properties, `init`, `didMove`, and label setup. Behavior lives in extensions in `GameplayFunctions/`:
- `BackgroundController.swift` — `setupBackground`, `moveBackground` (two-tile seamless scroll), and `onStepTriggered`.
- `PlayerSetup.swift` — `setupPlayer`, `setIdle`, `runWalkPulse` (plays `player_walk1`/`player_walk2` once, then returns to `player_idle`).

When adding scene behavior, follow this pattern (extension file per concern) rather than growing `GameScene.swift`.

### Steps → gameplay (the core loop)

`MotionManager` (singleton, `Gameplay/MotionManager.swift`) wraps `CMPedometer`, polling every 1.5s via `Timer` from `startOfDay`. It reports the **cumulative** step count for the day through `onStep`. `GameScene.didMove` sets `onStep` to: update the step/distance labels (`distance = stepLength * totalSteps`), and — via **edge detection against `lastStepCount`** — call `onStepTriggered()` only when the count increases. Each new step moves the background by 40pt and triggers one walk-animation pulse. Because the baseline is midnight, the game reflects the day's total steps, not steps since launch.

### Design system

`Attributes/PixelTheme.swift` is the shared pixel-art design system: the `Pixel` enum (color palette + `Pixel.font(_:weight:)` monospaced helper), reusable views (`DashboardPanel`, `PopupContainer`, `InsetCard`, `DashboardBar`, `CurrencyPill`), the `.pixelPanel()` modifier, and `PixelButtonStyle`. Use these instead of ad-hoc styling; images use `.interpolation(.none)` to keep pixel art crisp.

## Notable state of the codebase

- **`Mission`** (`Database/Mission.swift`) defines a model plus `seedMissions`/`seedIfNeeded`, but it is **not registered** in the `modelContainer` and `seedIfNeeded` is never called — the missions feature is scaffolding, not yet wired up.
- **`PlayerForm.swift`** is entirely commented out (superseded by `OnboardingView` + `PlayerSetup`).
- `Sprites/` (`CleanAssets/`, `AchievementsBadge/`) holds loose PNGs that are **not** in `Assets.xcassets`; only the imageset assets (`player_idle`, `player_walk1/2`, `bg`, `StepDashLogo`, etc.) are loadable via `SKTexture(imageNamed:)` / `Image(_:)`.
- `Info.plist` is minimal (empty `UIBackgroundModes`). Motion works via foreground pedometer queries; there is currently no motion-usage description string here.
