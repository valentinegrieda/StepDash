import Foundation
import SwiftData

/// One persisted row per calendar day, so there is history to show on a stats
/// screen. Updated live as the player walks and rolled to a fresh row at
/// midnight. `distance` is meters; `deliveriesDone` counts missions completed
/// that day.
@Model
final class DailyStepRecord {
    /// Normalized to `startOfDay`.
    var date: Date
    var steps: Int
    var distance: Double
    var deliveriesDone: Int

    init(date: Date, steps: Int = 0, distance: Double = 0, deliveriesDone: Int = 0) {
        self.date = date
        self.steps = steps
        self.distance = distance
        self.deliveriesDone = deliveriesDone
    }
}

extension DailyStepRecord {

    /// Fetches the record for the given day, creating (and inserting) one if it
    /// doesn't exist yet.
    static func record(for day: Date, context: ModelContext, calendar: Calendar = .current) -> DailyStepRecord {
        let start = calendar.startOfDay(for: day)
        let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start

        var descriptor = FetchDescriptor<DailyStepRecord>(
            predicate: #Predicate { $0.date >= start && $0.date < end }
        )
        descriptor.fetchLimit = 1

        if let existing = try? context.fetch(descriptor).first {
            return existing
        }

        let created = DailyStepRecord(date: start)
        context.insert(created)
        return created
    }

    /// Totals across every recorded day ("since playing").
    static func lifetimeTotals(context: ModelContext) -> (steps: Int, distance: Double, deliveries: Int) {
        let all = (try? context.fetch(FetchDescriptor<DailyStepRecord>())) ?? []
        return (
            all.reduce(0) { $0 + $1.steps },
            all.reduce(0) { $0 + $1.distance },
            all.reduce(0) { $0 + $1.deliveriesDone }
        )
    }
}
