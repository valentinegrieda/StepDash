# StepDash

StepDash is a SwiftUI iOS app that turns walking activity into a pixel-art courier game. The app reads the user's daily step count, estimates distance from the user's profile, and uses that progress to complete deliveries, missions, and earn coins/XP.

## Main Features

- Player onboarding with name, gender, height, and step-length calculation.
- `CoreMotion`/`CMPedometer` integration for daily step tracking.
- Pixel-art game interface built with SwiftUI and SpriteKit.
- Random daily deliveries with accept, progress, claim, and coin reward flow.
- Daily and weekly missions based on either step count or distance.
- Local persistence with SwiftData for player data, missions, deliveries, and daily step history.
- Local background music from `background_music.mp3`.
- Local reminders using `UserNotifications`.
- Debug-only `+500 steps` button to make Simulator testing easier.

## Tech Stack

- Swift
- SwiftUI
- SpriteKit
- SwiftData
- CoreMotion
- UserNotifications
- Xcode project (`StepDash.xcodeproj`)

## Project Structure

```text
StepDash/
├── App/                  # Onboarding and player setup views
├── Assets.xcassets/      # Pixel-art assets, logo, icons, background, items
├── Attributes/           # Design system, colors, fonts, and UI configuration
├── Audio/                # Background music player
├── Database/             # SwiftData models: Player, Mission, Delivery, DailyStepRecord
├── GameScreen/           # Main game screens, toolbar, SpriteKit bridge, home UI
├── Gameplay/             # Step session and MotionManager
├── GameplayFunctions/    # Player setup, background, and player controller helpers
├── Notifications/        # Local reminder manager
├── ContentView.swift     # Routes to onboarding or game based on stored player data
└── StepDashApp.swift     # App entry point and SwiftData container setup
```

## Requirements

- macOS with a recent Xcode version that supports SwiftData and the project's iOS target.
- A physical iPhone for real step-counter testing.
- The Simulator can be used for UI/debug testing, but pedometer data is usually unavailable there.

Current project settings:

- Bundle identifier: `com.valentinegrieda.StepDash`
- Marketing version: `1.0`
- App iOS deployment target: `26.0`
- Swift version setting: `5.0`
- Device family: iPhone and iPad

## Running the App

1. Open the project:

   ```bash
   open StepDash.xcodeproj
   ```

2. Select the `StepDash` scheme.
3. Choose a physical device or simulator.
4. Run the app from Xcode.
5. On first launch, complete the courier profile setup.
6. After the profile is saved, the app opens the main game screen.

## App Flow

1. `StepDashApp` sets up the `NavigationStack`, color scheme, background music, notification manager, and SwiftData `modelContainer`.
2. `ContentView` checks for a stored `Player` record.
3. If no player exists, the app shows `OnboardingView`.
4. If a player exists, the app opens `GameContainerView`.
5. `GameContainerView` starts `GameSession`, records daily step updates, and evaluates missions.
6. `HomeView` displays today's steps, coins, active delivery, delivery progress, and the bottom navigation toolbar.

## Local Data

The project uses SwiftData with these models:

- `Player`: player profile, step length, coins, and XP.
- `Mission`: daily/weekly mission definitions, progress state, and rewards.
- `DailyStepRecord`: daily steps, distance, completed deliveries, and consumed steps.
- `CurrentDelivery`: the currently active daily delivery.

Initial missions are seeded automatically through `Mission.seedIfNeeded(context:)`.

## Testing Notes

- In Debug builds, the home screen shows a `+500 steps` button for simulated step progress.
- Deliveries use a step consumption model: steps claimed for one delivery are stored as `consumedSteps`, so the next delivery uses the remaining steps for that day.
- Daily missions use today's raw steps, while weekly missions use accumulated steps since the mission was accepted.
- The reminder notification currently uses a 5-second test trigger in `NotificationManager.swift`. For production behavior, switch to the `UNCalendarNotificationTrigger` already prepared in that file.

## Permissions

Because the app reads step data through `CMPedometer`, device builds usually need a Motion & Fitness usage description in `Info.plist`, for example:

```xml
<key>NSMotionUsageDescription</key>
<string>StepDash uses step data to calculate delivery and mission progress.</string>
```

If the step counter does not update on a physical device, check Motion & Fitness permission, app capabilities, and iOS Privacy settings.

## Troubleshooting

- **Pedometer not available**: run the app on a physical iPhone. The Simulator usually does not provide pedometer data.
- **Steps do not update**: make sure Motion & Fitness permission is enabled and `NSMotionUsageDescription` has been added.
- **Notifications appear too quickly**: the reminder trigger is still using the 5-second test mode in `NotificationManager.swift`.
- **Need to reset player data**: delete the app from the simulator/device to clear local SwiftData storage, then run it again.

## Future Improvements

- Add the Motion & Fitness permission string to `Info.plist`.
- Replace the notification test trigger with the production daily schedule.
- Complete achievements, history, shop, and profile pages if they are not fully active yet.
- Add tests for mission, delivery, and daily step record logic.
