import Foundation
import SwiftData

/// What a mission is measured against. All missions are daily and auto-track
/// (no accept step); the player claims the reward once the goal is reached.
enum MissionKind: String, Codable {
    case login       // completed just by opening the app today
    case steps       // walk N steps today
    case deliveries  // complete N deliveries today
}

@Model
final class Mission {
    var id: Int
    var title: String
    var iconName: String
    var kindRaw: String
    var goal: Int
    var rewardCoins: Int
    /// Whether the reward has been collected today (resets at midnight).
    var isClaimed: Bool
    /// Start-of-day this mission's claim state belongs to; a mismatch resets it.
    var dayKey: Date

    var kind: MissionKind {
        get { MissionKind(rawValue: kindRaw) ?? .steps }
        set { kindRaw = newValue.rawValue }
    }

    init(id: Int, title: String, iconName: String, kind: MissionKind, goal: Int, rewardCoins: Int, isClaimed: Bool = false, dayKey: Date) {
        self.id = id
        self.title = title
        self.iconName = iconName
        self.kindRaw = kind.rawValue
        self.goal = goal
        self.rewardCoins = rewardCoins
        self.isClaimed = isClaimed
        self.dayKey = dayKey
    }
}

// MARK: - Progress

extension Mission {

    /// Raw progress in the mission's own units (today's steps / today's
    /// deliveries / login = met).
    func currentCount(todaySteps: Int, deliveriesToday: Int) -> Int {
        switch kind {
        case .login:      return goal
        case .steps:      return todaySteps
        case .deliveries: return deliveriesToday
        }
    }

    func isComplete(todaySteps: Int, deliveriesToday: Int) -> Bool {
        currentCount(todaySteps: todaySteps, deliveriesToday: deliveriesToday) >= goal
    }

    func fraction(todaySteps: Int, deliveriesToday: Int) -> Double {
        guard goal > 0 else { return 0 }
        return min(Double(currentCount(todaySteps: todaySteps, deliveriesToday: deliveriesToday)) / Double(goal), 1)
    }

    /// Login missions don't show a "x / y" count in the design.
    var showsCount: Bool { kind != .login }
}

// MARK: - Store (daily reset + claim)

enum MissionStore {

    /// Resets each mission's claim state when a new day has started.
    static func refresh(for day: Date, context: ModelContext, calendar: Calendar = .current) {
        let dayStart = calendar.startOfDay(for: day)
        let missions = (try? context.fetch(FetchDescriptor<Mission>())) ?? []

        var changed = false
        for mission in missions where calendar.startOfDay(for: mission.dayKey) != dayStart {
            mission.isClaimed = false
            mission.dayKey = dayStart
            changed = true
        }

        if changed { try? context.save() }
    }

    /// Grants coins if the mission is complete and not already claimed.
    static func claim(_ mission: Mission, todaySteps: Int, deliveriesToday: Int, player: Player?, context: ModelContext) {
        guard !mission.isClaimed,
              mission.isComplete(todaySteps: todaySteps, deliveriesToday: deliveriesToday) else { return }

        mission.isClaimed = true
        player?.coins += mission.rewardCoins
        context.insert(MissionHistory(mission: mission))
        try? context.save()
    }
}

// MARK: - Seeding

extension Mission {

    static var seedMissions: [Mission] {
        let today = Calendar.current.startOfDay(for: Date())
        return [
            Mission(id: 1, title: "Daily login",       iconName: "Head1",   kind: .login,      goal: 1,      rewardCoins: 25,  dayKey: today),
            Mission(id: 2, title: "Deliver a package", iconName: "Package", kind: .deliveries, goal: 1,      rewardCoins: 50,  dayKey: today),
            Mission(id: 3, title: "Walk 7.000 steps",  iconName: "Shoe",    kind: .steps,      goal: 7_000,  rewardCoins: 75,  dayKey: today),
            Mission(id: 4, title: "Deliver 5 packages",iconName: "Package", kind: .deliveries, goal: 5,      rewardCoins: 100, dayKey: today),
            Mission(id: 5, title: "Walk 10.000 steps", iconName: "Shoe",    kind: .steps,      goal: 10_000, rewardCoins: 100, dayKey: today),
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
