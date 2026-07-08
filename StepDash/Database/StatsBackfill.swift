import Foundation
import SwiftData

/// Fills in `DailyStepRecord` rows for the last few days from CMPedometer's
/// stored history (~7 days), so the Stats week view isn't full of gaps on days
/// the app wasn't opened. Runs on launch.
enum StatsBackfill {

    static func run(context: ModelContext, stepLength: Double, days: Int = 7, calendar: Calendar = .current) {
        let today = calendar.startOfDay(for: Date())

        for offset in 0..<days {
            guard let dayStart = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            let dayEnd = min(calendar.date(byAdding: .day, value: 1, to: dayStart) ?? Date(), Date())

            MotionManager.shared.querySteps(from: dayStart, to: dayEnd) { steps in
                guard let steps, steps > 0 else { return }

                let record = DailyStepRecord.record(for: dayStart, context: context)
                // Never clobber a live/higher count (today keeps updating).
                if steps > record.steps {
                    record.steps = steps
                    record.distance = Double(steps) * stepLength
                    try? context.save()
                }
            }
        }
    }
}
