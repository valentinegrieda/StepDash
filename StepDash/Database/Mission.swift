import Foundation
import SwiftData

/// Reset cadence for a mission. Both are delivery-themed and must be accepted
/// before they count. `daily` resets at midnight; `weekly` carries over midnight
/// and resets at the start of a new week.
enum MissionCategory: String, Codable {
    case daily
    case weekly
}

/// Whether a mission is completed by taking a number of steps or by covering a
/// distance. Distance goals are stored in **meters** (matches `stepLength`,
/// which is meters-per-step).
enum MissionGoalType: String, Codable {
    case steps
    case distance
}

@Model
final class Mission {
    var id: Int
    var title: String
    var destination: String

    var categoryRaw: String
    var goalTypeRaw: String
    /// Steps: a whole-number count. Distance: meters.
    var goalValue: Double

    var rewardCoins: Int
    var rewardXP: Int

    // MARK: - Tracking state

    /// Deliveries only count once accepted (delivery theme).
    var isAccepted: Bool
    var isCompleted: Bool

    /// Steps captured at accept time. Daily missions use today's raw step count;
    /// weekly missions use accumulated steps so they can survive midnight.
    var baselineSteps: Int

    /// Start of the period (day or week) this acceptance belongs to. Used to
    /// reset `daily` missions at midnight and `weekly` missions at the week
    /// boundary. `nil` when not accepted.
    var periodStart: Date?

    var category: MissionCategory {
        get { MissionCategory(rawValue: categoryRaw) ?? .daily }
        set { categoryRaw = newValue.rawValue }
    }

    var goalType: MissionGoalType {
        get { MissionGoalType(rawValue: goalTypeRaw) ?? .distance }
        set { goalTypeRaw = newValue.rawValue }
    }

    init(
        id: Int,
        title: String,
        destination: String,
        category: MissionCategory,
        goalType: MissionGoalType,
        goalValue: Double,
        rewardCoins: Int,
        rewardXP: Int
    ) {
        self.id = id
        self.title = title
        self.destination = destination
        self.categoryRaw = category.rawValue
        self.goalTypeRaw = goalType.rawValue
        self.goalValue = goalValue
        self.rewardCoins = rewardCoins
        self.rewardXP = rewardXP
        self.isAccepted = false
        self.isCompleted = false
        self.baselineSteps = -1
        self.periodStart = nil
    }
}

// MARK: - Accept / period reset

extension Mission {

    /// Start of the current period for this mission's category.
    func currentPeriodStart(now: Date, calendar: Calendar = .current) -> Date {
        switch category {
        case .daily:
            return calendar.startOfDay(for: now)
        case .weekly:
            return calendar.dateInterval(of: .weekOfYear, for: now)?.start
                ?? calendar.startOfDay(for: now)
        }
    }

    /// Accept the delivery and start counting progress from the current step count.
    func accept(now: Date, todaySteps: Int, accumulatedSteps: Int) {
        isAccepted = true
        isCompleted = false
        periodStart = currentPeriodStart(now: now)
        baselineSteps = (category == .weekly) ? accumulatedSteps : todaySteps
    }

    /// Clears an acceptance whose period has elapsed (daily at midnight, weekly
    /// at the week boundary). Call before evaluating progress.
    func refreshPeriod(now: Date) {
        guard isAccepted, let periodStart else { return }
        if periodStart != currentPeriodStart(now: now) {
            isAccepted = false
            isCompleted = false
            baselineSteps = -1
            self.periodStart = nil
        }
    }
}

// MARK: - Progress

extension Mission {

    /// Steps counted toward this mission. Daily and weekly both start from the
    /// step count captured at acceptance time. Zero until accepted.
    func stepsTaken(todaySteps: Int, accumulatedSteps: Int) -> Int {
        guard isAccepted else { return 0 }
        guard baselineSteps >= 0 else { return 0 }
        switch category {
        case .daily:
            return max(0, todaySteps - baselineSteps)
        case .weekly:
            return max(0, accumulatedSteps - baselineSteps)
        }
    }

    /// Current progress in the mission's own units (steps, or meters).
    func currentValue(todaySteps: Int, accumulatedSteps: Int, stepLength: Double) -> Double {
        let steps = Double(stepsTaken(todaySteps: todaySteps, accumulatedSteps: accumulatedSteps))
        switch goalType {
        case .steps:    return steps
        case .distance: return steps * stepLength
        }
    }

    /// Fractional progress `0...1` for the progress bar.
    func progress(todaySteps: Int, accumulatedSteps: Int, stepLength: Double) -> Double {
        guard goalValue > 0 else { return 0 }
        return min(currentValue(todaySteps: todaySteps, accumulatedSteps: accumulatedSteps, stepLength: stepLength) / goalValue, 1)
    }

    func isReached(todaySteps: Int, accumulatedSteps: Int, stepLength: Double) -> Bool {
        currentValue(todaySteps: todaySteps, accumulatedSteps: accumulatedSteps, stepLength: stepLength) >= goalValue
    }

    /// e.g. "3000 steps" or "2.5 km".
    var goalDescription: String {
        switch goalType {
        case .steps:    return "\(Int(goalValue)) steps"
        case .distance: return String(format: "%.1f km", goalValue / 1000)
        }
    }

    /// e.g. "1200 / 3000 steps" or "1.20 / 2.50 km".
    func progressDescription(todaySteps: Int, accumulatedSteps: Int, stepLength: Double) -> String {
        let current = currentValue(todaySteps: todaySteps, accumulatedSteps: accumulatedSteps, stepLength: stepLength)
        switch goalType {
        case .steps:
            return "\(Int(current)) / \(Int(goalValue)) steps"
        case .distance:
            return String(format: "%.2f / %.2f km", current / 1000, goalValue / 1000)
        }
    }
}

// MARK: - Seeding

extension Mission {

    static var seedMissions: [Mission] {
        [
            Mission(id: 1, title: "Bakery Run",    destination: "Sunny Street 12",   category: .daily,  goalType: .distance, goalValue: 2_500,  rewardCoins: 25,  rewardXP: 50),
            Mission(id: 2, title: "Morning Steps", destination: "Neighborhood Loop", category: .daily,  goalType: .steps,    goalValue: 3_000,  rewardCoins: 30,  rewardXP: 60),
            Mission(id: 3, title: "Downtown Dash", destination: "Main Plaza 7",      category: .weekly, goalType: .distance, goalValue: 20_000, rewardCoins: 120, rewardXP: 250),
            Mission(id: 4, title: "Step Champion", destination: "City Wide",         category: .weekly, goalType: .steps,    goalValue: 40_000, rewardCoins: 200, rewardXP: 400),
        ]
    }

    static func seedIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Mission>()
        let existingCount = (try? context.fetchCount(descriptor)) ?? 0
        guard existingCount == 0 else { return }

        for mission in seedMissions {
            context.insert(mission)
        }

        try? context.save()
    }
}
