import Foundation
import SwiftData

/// A possible delivery in the pool. The active `CurrentDelivery` is filled from
/// one of these, picked at random on a new day and after each claim.
struct DeliveryTemplate {
    let recipient: String
    let goalSteps: Int
    let rewardCoins: Int
}

enum DeliveryCatalog {
    /// The pool of deliveries that can appear. (Replace/extend freely.)
    static let all: [DeliveryTemplate] = [
        DeliveryTemplate(recipient: "John",  goalSteps: 2_500, rewardCoins: 25),
        DeliveryTemplate(recipient: "Maria", goalSteps: 1-500, rewardCoins: 15),
        DeliveryTemplate(recipient: "Kenji", goalSteps: 3_000, rewardCoins: 30),
        DeliveryTemplate(recipient: "Amara", goalSteps: 4_500, rewardCoins: 45),
        DeliveryTemplate(recipient: "Liam",  goalSteps: 2_000, rewardCoins: 20),
        DeliveryTemplate(recipient: "Sofia", goalSteps: 6_000, rewardCoins: 60),
    ]

    static func random() -> DeliveryTemplate {
        all.randomElement() ?? all[0]
    }
}

/// The single active delivery (only one at a time). Progress is a *consumption*
/// model: it draws from the day's step pool minus steps already consumed by
/// deliveries claimed earlier today.
@Model
final class CurrentDelivery {
    var recipient: String
    var goalSteps: Int
    var rewardCoins: Int
    var isAccepted: Bool
    /// Start-of-day this delivery belongs to; a mismatch triggers a daily reset.
    var dayKey: Date

    init(recipient: String, goalSteps: Int, rewardCoins: Int, isAccepted: Bool = false, dayKey: Date) {
        self.recipient = recipient
        self.goalSteps = goalSteps
        self.rewardCoins = rewardCoins
        self.isAccepted = isAccepted
        self.dayKey = dayKey
    }
}

extension CurrentDelivery {

    /// Replace this delivery's contents with a template (fresh, not accepted).
    func fill(with t: DeliveryTemplate, dayKey: Date) {
        recipient = t.recipient
        goalSteps = t.goalSteps
        rewardCoins = t.rewardCoins
        isAccepted = false
        self.dayKey = dayKey
    }

    /// Steps applied to this delivery = leftover pool (today − consumed), capped
    /// at the goal. Zero until accepted.
    func progress(todaySteps: Int, consumed: Int) -> Int {
        guard isAccepted else { return 0 }
        return max(0, min(todaySteps - consumed, goalSteps))
    }

    func stepsRemaining(todaySteps: Int, consumed: Int) -> Int {
        max(0, goalSteps - progress(todaySteps: todaySteps, consumed: consumed))
    }

    func isComplete(todaySteps: Int, consumed: Int) -> Bool {
        isAccepted && progress(todaySteps: todaySteps, consumed: consumed) >= goalSteps
    }

    func fraction(todaySteps: Int, consumed: Int) -> Double {
        guard goalSteps > 0 else { return 0 }
        return Double(progress(todaySteps: todaySteps, consumed: consumed)) / Double(goalSteps)
    }
}

// MARK: - Store (fetch/reset/accept/claim)

enum DeliveryStore {

    /// Fetch-or-create the single active delivery, re-randomizing it if it
    /// belongs to a previous day (daily reset).
    @discardableResult
    static func current(for day: Date, context: ModelContext, calendar: Calendar = .current) -> CurrentDelivery {
        let dayStart = calendar.startOfDay(for: day)
        let descriptor = FetchDescriptor<CurrentDelivery>()

        if let existing = try? context.fetch(descriptor).first {
            if calendar.startOfDay(for: existing.dayKey) != dayStart {
                existing.fill(with: DeliveryCatalog.random(), dayKey: dayStart)
                try? context.save()
            }
            return existing
        }

        let t = DeliveryCatalog.random()
        let created = CurrentDelivery(recipient: t.recipient, goalSteps: t.goalSteps, rewardCoins: t.rewardCoins, dayKey: dayStart)
        context.insert(created)
        try? context.save()
        return created
    }

    static func accept(_ delivery: CurrentDelivery, context: ModelContext) {
        delivery.isAccepted = true
        try? context.save()
    }

    /// Grant the reward, consume the goal from today's pool, then roll a new
    /// random delivery. No-op unless complete.
    static func claim(_ delivery: CurrentDelivery,
                      todaySteps: Int,
                      player: Player?,
                      context: ModelContext,
                      calendar: Calendar = .current) {
        let today = Date()
        let record = DailyStepRecord.record(for: today, context: context)
        guard delivery.isComplete(todaySteps: todaySteps, consumed: record.consumedSteps) else { return }

        player?.coins += delivery.rewardCoins
        record.consumedSteps += delivery.goalSteps
        record.deliveriesDone += 1

        delivery.fill(with: DeliveryCatalog.random(), dayKey: calendar.startOfDay(for: today))
        try? context.save()
    }
}
