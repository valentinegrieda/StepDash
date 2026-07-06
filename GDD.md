# StepDash Game Design Document

## 1. Overview

**Game Title:** StepDash  
**Platform:** iOS  
**Genre:** Fitness, casual, idle progression, pixel-art delivery game  
**Target Device:** iPhone and iPad  
**Core Input:** Real-world walking steps through the iOS pedometer  
**Primary Technology:** SwiftUI, SpriteKit, SwiftData, CoreMotion

StepDash is a mobile fitness game where the player's real-world steps power an in-game courier journey. Players create a courier profile, walk in real life, complete deliveries, earn coins and XP, and progress through daily and weekly missions. The game uses a bright pixel-art visual style to make walking feel playful, measurable, and rewarding.

## 2. Design Pillars

### Movement Becomes Progress

Every real step should feel useful. Walking advances delivery progress, contributes to missions, increases stats, and supports long-term player growth.

### Lightweight Daily Habit

The game should be easy to open, check, and understand within a few seconds. Players should immediately see today's steps, current delivery progress, and available rewards.

### Cozy Courier Fantasy

The player is not just counting steps; they are becoming a courier moving through a pixel-art city. Deliveries, packages, destinations, coins, and city backgrounds reinforce this fantasy.

### Simple Rewards, Clear Goals

Goals should be understandable at a glance: walk a number of steps, reach a distance, claim a delivery, earn coins, and complete missions.

## 3. Target Audience

StepDash is designed for players who:

- Want extra motivation to walk more each day.
- Enjoy casual mobile games with simple progression.
- Like pixel-art visuals and cozy game themes.
- Prefer light fitness tracking over complex workout analytics.
- Benefit from small daily goals and visible rewards.

## 4. Core Gameplay Loop

1. The player opens StepDash.
2. The app reads today's step count from the pedometer.
3. The player accepts a delivery or mission.
4. The player walks in real life.
5. Step progress updates delivery and mission progress.
6. The player claims completed delivery or mission rewards.
7. Rewards increase coins and XP.
8. The player checks stats, profile progress, or future goals.
9. The player returns later to continue walking and completing deliveries.

## 5. Player Onboarding

On first launch, the player creates a courier profile.

### Required Inputs

- Name
- Gender
- Height in centimeters

### Step Length Calculation

The game estimates step length from height and gender:

- Male factor: `0.415`
- Female factor: `0.413`
- Step length is stored in meters per step.

This value is used to convert steps into distance-based mission progress.

## 6. Game World and Theme

StepDash takes place in a stylized pixel-art city. The player is represented as a courier who moves through the city while completing package deliveries.

### Theme Elements

- Courier identity
- Packages and delivery destinations
- Pixel-art streets and city backgrounds
- Coins and XP as rewards
- Daily and weekly delivery objectives

### Tone

The tone should be friendly, energetic, and encouraging. The game should feel like a small companion that celebrates everyday movement without feeling demanding.

## 7. Main Screens

### Home

The Home screen is the main play screen.

Key elements:

- Player name
- Today's step count
- Current coin balance
- Active delivery panel
- Delivery recipient
- Delivery reward
- Delivery progress bar
- Accept/Claim delivery button
- Shortcut boxes for Achievements, Missions, and History
- Bottom toolbar navigation
- Pixel-art moving background

### Missions

The Missions screen shows daily and weekly delivery-themed objectives.

Mission row information:

- Mission title
- Destination
- Goal requirement
- Daily or weekly category badge
- Reward coins
- Reward XP
- Progress bar if accepted
- Completion status when delivered
- Accept Delivery button if not yet accepted

### Stats

The Stats screen summarizes current and lifetime activity.

Tracked values:

- Today's steps
- Today's distance
- Total lifetime steps
- Total lifetime distance
- Total deliveries completed

### Shop

The Shop screen currently presents item concepts such as:

- Speed Shoes
- Reward Box
- Courier Gear

These items establish the future economy direction, even if purchasing behavior is not fully implemented yet.

### Profile

The Profile screen shows courier identity and progression.

Displayed values:

- Player avatar
- Player name
- Courier rank
- Coins
- XP

## 8. Navigation

The player navigates using a persistent bottom toolbar.

Primary destinations:

- Home
- Missions
- Stats
- Shop
- Profile

The toolbar should make the app feel like a compact game dashboard rather than a traditional fitness tracker.

## 9. Step Tracking System

StepDash uses `CMPedometer` through `MotionManager` to fetch today's step count.

### Step Values

- **Today Steps:** raw daily step count that resets at midnight.
- **Accumulated Steps:** monotonic step total that survives midnight rollover and supports weekly mission progress.

### Update Behavior

- The app polls pedometer data periodically.
- Step handlers receive live values on the main thread.
- `GameSession` owns the persistent step feed, so stats and mission progress continue updating even when the player navigates away from the Home screen.
- The SpriteKit scene subscribes only for visual reactions, such as walk animations.

### Debug Support

In Debug builds, the Home screen includes a `+500 steps` button to simulate progress, especially useful in the Simulator.

## 10. Delivery System

The delivery system gives the player a single active delivery at a time.

### Delivery Data

Each delivery contains:

- Recipient name
- Goal steps
- Reward coins
- Accepted state
- Day key

### Delivery Flow

1. A delivery is generated from the delivery catalog.
2. The player taps Accept.
3. Walking progress fills the delivery progress bar.
4. When the required steps are reached, the player taps Claim.
5. The player receives coins.
6. The delivery's required steps are marked as consumed for the day.
7. A new random delivery is generated.

### Step Consumption Model

Deliveries use a daily step pool. When a delivery is claimed, its required steps are added to `consumedSteps`. The next delivery can only use the remaining unconsumed steps for that day.

Example:

- Today steps: `5,000`
- Claimed delivery cost: `2,500`
- Consumed steps: `2,500`
- Remaining usable steps for next delivery: `2,500`

This prevents the same steps from being repeatedly reused for unlimited delivery claims.

### Delivery Catalog

Current delivery templates include recipients such as:

- John
- Maria
- Kenji
- Amara
- Liam
- Sofia

Goal steps range from `1,500` to `5,000`, with coin rewards scaling by difficulty.

## 11. Mission System

Missions are broader goals that can be accepted and completed for coins and XP.

### Mission Categories

- **Daily:** resets at the start of a new day.
- **Weekly:** resets at the start of a new week.

### Mission Goal Types

- **Steps:** completed by walking a required number of steps.
- **Distance:** completed by covering a required distance in meters.

### Mission Flow

1. The player opens Missions.
2. The player accepts a mission.
3. Step or distance progress begins tracking.
4. When the goal is reached, the mission is marked as completed.
5. Coins and XP are awarded.
6. Completion contributes to daily delivery statistics.

## 12. Economy and Progression

### Currencies

- **Coins:** earned from deliveries and missions.
- **XP:** earned from missions.

### Current Uses

- Coins and XP are displayed in the Profile screen.
- Coins are displayed in the Home top bar.
- Shop items communicate future spending options.

### Future Economy Direction

Coins can later be used for:

- Cosmetic courier outfits
- Shoe upgrades
- Delivery boosts
- Reward boxes
- Background themes

XP can later support:

- Courier rank progression
- Level-based unlocks
- Achievement milestones

## 13. Stats and History

StepDash stores one daily record per calendar day.

### Daily Record Fields

- Date
- Steps
- Distance
- Deliveries completed
- Consumed delivery steps

### Lifetime Totals

The Stats screen can calculate:

- Total steps
- Total distance
- Total deliveries completed

These stats support a long-term sense of growth and achievement.

## 14. Visual Design

### Art Direction

StepDash uses a bright pixel-art style with chunky panels, crisp icons, and a scrolling city background.

### UI Style

- Pixel-style typography
- Bold readable labels
- High-contrast top bar
- Card-like mission rows
- Progress bars for goals
- Icon-driven toolbar
- Light, playful colors

### Animation

- Background scrolling creates the feeling of movement through a city.
- The player sprite can react to detected steps with walking animations.
- UI transitions should stay quick and lightweight.

## 15. Audio Design

The game includes looping background music through `BackgroundMusicPlayer`.

Audio goals:

- Create a playful and motivating atmosphere.
- Avoid distracting from quick daily check-ins.
- Support the courier adventure theme.

Future audio additions could include:

- Delivery accepted sound
- Delivery claimed sound
- Mission completed sound
- Coin reward sound
- Button tap feedback

## 16. Notifications

StepDash uses local notifications to remind registered players to return.

### Current Behavior

- Notification scheduling begins after a player profile exists.
- The current implementation uses a short 5-second test trigger.

### Intended Production Behavior

- Remind the player after a period of inactivity.
- Use a scheduled daily reminder, such as the prepared next-day evening trigger.
- Keep notification text encouraging and non-intrusive.

## 17. Data Persistence

StepDash uses SwiftData for local persistence.

Stored model types:

- `Player`
- `Mission`
- `DailyStepRecord`
- `CurrentDelivery`

This keeps player identity, progress, missions, delivery state, and history available across app launches.

## 18. Technical Requirements

### iOS Capabilities

The app needs access to Motion & Fitness data for step tracking.

Recommended `Info.plist` permission:

```xml
<key>NSMotionUsageDescription</key>
<string>StepDash uses step data to calculate delivery and mission progress.</string>
```

### Device Notes

- Real pedometer testing requires a physical iPhone.
- The iOS Simulator can be used for UI development and debug step simulation.

## 19. Success Metrics

Potential product and gameplay success metrics:

- Daily active users
- Average daily steps while using StepDash
- Delivery completion rate
- Mission acceptance rate
- Mission completion rate
- Day-1 and day-7 retention
- Average sessions per day
- Notification return rate

## 20. Risks and Design Considerations

### Pedometer Availability

Some devices or environments may not provide pedometer data. The game should clearly handle unavailable step tracking and support debug simulation during development.

### Permission Friction

If Motion & Fitness permission is denied, the core loop is weakened. The app should explain why step access matters.

### Reusing Steps Too Much

The delivery consumption model helps prevent the same steps from being claimed repeatedly. Future systems should preserve that fairness.

### Overwhelming the Player

The game should avoid too many currencies, missions, or screens early on. The strongest experience is a clear delivery goal and visible walking progress.

## 21. Future Feature Ideas

- Achievements screen with milestone rewards.
- Delivery history screen.
- Fully functional shop.
- Cosmetic courier customization.
- Courier rank levels.
- Streaks for consecutive walking days.
- More delivery destinations and characters.
- Daily login rewards.
- Weekly event missions.
- Apple Health integration, if needed.
- Better production notification schedule.
- Sound effects for rewards and actions.

## 22. MVP Scope

The current MVP focuses on:

- Player onboarding
- Step tracking
- Daily delivery flow
- Mission flow
- Coin and XP rewards
- Stats tracking
- Profile display
- Pixel-art game presentation

The MVP proves the main idea: real-world walking can drive a simple, rewarding courier game loop.
