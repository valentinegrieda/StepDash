# StepDash — MVP TODO

MVP goal: **accept a delivery → walk → fill its progress bar → deliver → earn coins → stats build up.**

## Mission design (decided)
- **Two step counters** (`MotionManager`): `todaySteps` (resets at midnight) and `accumulatedSteps` (monotonic, survives midnight, persisted in UserDefaults).
- **Missions must be accepted** (delivery theme). Two categories:
  - **Daily** — credits the **whole day's steps** once accepted (pre-accept steps count too); **resets at midnight** (re-accept each day).
  - **Weekly** — counts from the accept baseline (`accumulatedSteps − baselineSteps`); **carries over midnight**, resets at the **week** boundary.
- Both come in **steps** or **distance** goal types.
- Completing a mission grants `rewardCoins` / `rewardXP` to the `Player` and +1 to today's `deliveriesDone`.

## Done (this pass)
- [x] `MotionManager`: dual counters (`todaySteps` + persistent `accumulatedSteps`) with midnight-rollover banking; `onStep(today, accumulated)`.
- [x] `Mission` schema: `category` (daily/weekly), `goalType` (steps/distance), `goalValue`, accept/baseline/period state + progress helpers.
- [x] `Mission.seedIfNeeded` now actually called (`GameContainerView.onAppear`); seeds 2 daily + 2 weekly.
- [x] `DailyStepRecord` model (steps, distance, deliveriesDone) + `lifetimeTotals` ("since playing"); registered in the container.
- [x] `Player` gained `coins` / `xp`.
- [x] Scene→SwiftUI `onStepUpdate` bridge; `GameContainerView` records daily steps + evaluates mission completion + grants rewards.
- [x] Missions panel: category badge, **ACCEPT DELIVERY** button, progress bar, DELIVERED state, reward pills.
- [x] Stats panel: today + lifetime totals (steps/distance/deliveries). Profile shows real coins/XP.

## Next
- [ ] **Build in Xcode** — couldn't compile here (only Command Line Tools installed). Verify the new `Database/DailyStepRecord.swift` is in the `StepDash` target (auto if the project uses Xcode file-system-synchronized groups; otherwise add it).
- [ ] **Delete-app / reset once** — the `Mission`/`Player` schema changed; existing on-device SwiftData stores may need a clean install (or a migration plan) since properties were added/changed.
- [ ] Weekly-boundary reset is handled via `refreshPeriod`, but only fires while stepping — verify a mission accepted last week clears correctly on first step of the new week.
- [ ] Wire the **Shop** to actually spend `Player.coins`.
- [ ] Consider a "claim reward" tap on completion instead of auto-grant, if you want a reward moment.

## Post-MVP
- [ ] Achievement badges (`Sprites/AchievementsBadge/`).
- [ ] Stats history/graph view over `DailyStepRecord` rows.
- [ ] Move loose `Sprites/` PNGs into `Assets.xcassets` if they need `SKTexture(imageNamed:)`.
