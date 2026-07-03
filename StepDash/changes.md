# Changes Log

Significant changes to StepDash, newest first. Each entry notes **what**, **where**, and **why / how it works**.

---

## 2026-07-03 — Decouple step/mission/stats pipeline from the SpriteKit scene

### The problem
The data pipeline (recording `DailyStepRecord`, evaluating accepted missions for
completion, granting coin/XP rewards) was driven by the game **scene**: it ran
only through `GameScene`'s step callback, forwarded to the shell via
`onStepUpdate`.

Because navigation swaps the whole screen (`selectedDestination`), leaving Home
**tears down the scene**. Its `[weak self]` callback then went nil, so while on
Stats / Shop / Profile / Missions:
- daily steps stopped being recorded,
- accepted missions were never checked for completion (no rewards),
- the steps/progress shown on every page were a **stale snapshot** from the last
  time you were on Home.

This would have made the upcoming main-page UI show frozen, misleading data.

### The fix — own the feed on the persistent shell
Step updates now fan out from `MotionManager` to multiple subscribers, and the
always-on data pipeline is owned by the shell (`GameContainerView`), which stays
mounted across all pages. The scene only subscribes for its own visuals.

### Files changed

- **`Gameplay/MotionManager.swift`** — Replaced the single `var onStep` closure
  with a multi-subscriber registry: `addHandler(_:) -> UUID` /
  `removeHandler(_:)` and a private `notify(...)`. `addHandler` fires once
  immediately with current values so late subscribers sync instantly. `reset()`
  now notifies all handlers. *Why:* two independent consumers (shell pipeline +
  scene visuals) need the feed, each with its own lifecycle.

- **`Gameplay/GameSession.swift`** *(new)* — A small `@Observable` that owns the
  session's step feed: `start()` subscribes to `MotionManager`, republishes
  `todaySteps` / `accumulatedSteps`, and starts motion; `deinit` unsubscribes.
  *Why/how:* a stable reference type (held by the view via `@State`) is the
  robust place to own the subscription and expose live values to SwiftUI.

- **`GameScreen/GameContainerView.swift`** — Now owns `@State private var
  session = GameSession()`. `.onAppear` calls `session.start()`;
  `.onChange(of: session.todaySteps)` runs `evaluateStep()` (the renamed
  pipeline) on **every** step change regardless of the visible page. Pages and
  the scene are fed `session.todaySteps` / `session.accumulatedSteps` (live).
  Removed the old per-scene `onStepUpdate` wiring and the local step `@State`.
  *How it works:* the shell outlives page switches, so the pipeline never pauses.

- **`GameScreen/GameScene.swift`** — No longer owns the motion lifecycle. In
  `didMove` it registers a **visual-only** handler (`motion.addHandler`) that
  updates the labels + walk animation, stores the token, and `deinit` removes it.
  Dropped `motion.start()` (the shell starts it) and the `onStepUpdate` property.
  *Why:* the scene should render, not own the data.

- **`GameScreen/GameSKView.swift`** — Removed the now-unused `onStepUpdate`
  parameter and `updateStepHandler(...)`. Toolbar plumbing
  (`activeToolbarItemID`, `updateActiveToolbarItem`) is unchanged.

### Result
Steps, daily stats, and mission completion/rewards update continuously on any
page. The main-page UI can now read live data from `session` and via `@Query`
without depending on the scene being on screen. Behavior on Home (labels, walk
pulse, background scroll) is unchanged.

### Not touched (deliberately, pending your OK)
Left for a separate decision so this stays scoped to the critical bug:
- The debug **"Reset Player Data"** button + duplicate `Mission.seedIfNeeded`
  in `ContentView` (also seeded in `GameContainerView`).
- The **two parallel toolbars** (SpriteKit vs SwiftUI) and the Home scene being
  rebuilt on every return (teardown/persistence).
- **Missions has no toolbar entry** (reachable only if the main page links it).

### Verify
Build in Xcode (CLI unavailable here). Ensure the new
`Gameplay/GameSession.swift` is in the `StepDash` target (automatic if the
project uses file-system-synchronized groups).
