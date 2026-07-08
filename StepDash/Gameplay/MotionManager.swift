import Foundation
import CoreMotion

final class MotionManager {

    static let shared = MotionManager()

    private let pedometer = CMPedometer()

    /// Step handlers keyed by a token. Multiple subscribers are supported so the
    /// same feed can drive several consumers at once — e.g. the always-on data
    /// pipeline on the shell AND the game scene's visuals — each with its own
    /// independent lifecycle. Handlers receive `(todaySteps, accumulatedSteps)`
    /// on the main thread.
    /// - `todaySteps`: raw pedometer count for the current day, resets at midnight.
    /// - `accumulatedSteps`: monotonic count that survives midnight (used as the
    ///   baseline reference for accepted weekly deliveries).
    private var handlers: [UUID: (Int, Int) -> Void] = [:]

    private var isRunning = false
    private var timer: Timer?

    /// Steps banked from previous days (added when a midnight rollover is detected).
    private var accumulatedBase: Int
    /// Last raw same-day count we saw, used to detect the midnight reset.
    private var lastRawSteps: Int

    private enum Keys {
        static let accumulatedBase = "StepAccumulatedBase"
        static let lastRaw = "StepLastRaw"
    }

    private init() {
        accumulatedBase = UserDefaults.standard.integer(forKey: Keys.accumulatedBase)
        lastRawSteps = UserDefaults.standard.integer(forKey: Keys.lastRaw)
    }

    /// Raw steps for today (resets at midnight).
    var todaySteps: Int { lastRawSteps }

    /// Monotonic steps that survive midnight.
    var accumulatedSteps: Int { accumulatedBase + lastRawSteps }

    /// Registers a step handler and returns a token used to remove it later. The
    /// handler is invoked immediately with the current values so a late
    /// subscriber is in sync right away.
    @discardableResult
    func addHandler(_ handler: @escaping (Int, Int) -> Void) -> UUID {
        let token = UUID()
        handlers[token] = handler
        handler(todaySteps, accumulatedSteps)
        return token
    }

    func removeHandler(_ token: UUID) {
        handlers.removeValue(forKey: token)
    }

    private func notify(today: Int, accumulated: Int) {
        for handler in handlers.values {
            handler(today, accumulated)
        }
    }

    func start() {

        guard CMPedometer.isStepCountingAvailable() else {
            print("❌ Pedometer not available")
            return
        }

        guard !isRunning else { return }
        isRunning = true

        fetchSteps()

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
            self?.fetchSteps()
        }
    }

    private func fetchSteps() {

        // Recomputed each poll so the day window rolls over at midnight.
        let startOfToday = Calendar.current.startOfDay(for: Date())

        pedometer.queryPedometerData(from: startOfToday, to: Date()) { [weak self] data, error in

            guard let self else { return }

            if let error {
                print("❌ query error:", error)
                return
            }

            guard let raw = data?.numberOfSteps.intValue else { return }

            DispatchQueue.main.async {

                // Midnight rollover: today's count dropped below the last seen
                // value, so bank the previous day's steps into the accumulator.
                if raw < self.lastRawSteps {
                    self.accumulatedBase += self.lastRawSteps
                }

                self.lastRawSteps = raw
                UserDefaults.standard.set(self.accumulatedBase, forKey: Keys.accumulatedBase)
                UserDefaults.standard.set(self.lastRawSteps, forKey: Keys.lastRaw)

                self.notify(today: raw, accumulated: self.accumulatedBase + raw)
            }
        }
    }

    func stop() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        pedometer.stopUpdates()
    }

    func reset() {
        accumulatedBase = 0
        lastRawSteps = 0
        UserDefaults.standard.removeObject(forKey: Keys.accumulatedBase)
        UserDefaults.standard.removeObject(forKey: Keys.lastRaw)
        notify(today: 0, accumulated: 0)
    }

    #if DEBUG
    /// Debug: simulate steps for testing without walking. Works best on the
    /// Simulator (the pedometer is unavailable there, so no poll overwrites it;
    /// on a device the next 1.5s poll resets it to the real count).
    func debugAddSteps(_ count: Int) {
        lastRawSteps += count
        UserDefaults.standard.set(lastRawSteps, forKey: Keys.lastRaw)
        notify(today: lastRawSteps, accumulated: accumulatedBase + lastRawSteps)
    }
    #endif

    // MARK: - Historical queries (for Stats)

    /// Steps in an arbitrary interval (used for backfill + hourly Day charts).
    /// Completion is delivered on the main thread.
    func querySteps(from start: Date, to end: Date, completion: @escaping (Int?) -> Void) {
        guard CMPedometer.isStepCountingAvailable(), end > start else {
            completion(nil)
            return
        }
        pedometer.queryPedometerData(from: start, to: end) { data, _ in
            DispatchQueue.main.async { completion(data?.numberOfSteps.intValue) }
        }
    }

    /// 24 hourly step counts for the given day (elapsed hours only; future hours = 0).
    func queryHourlySteps(for day: Date, completion: @escaping ([Int]) -> Void) {
        guard CMPedometer.isStepCountingAvailable() else { completion([]); return }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: day)
        let now = Date()
        var results = [Int](repeating: 0, count: 24)
        let group = DispatchGroup()

        for hour in 0..<24 {
            guard let from = calendar.date(byAdding: .hour, value: hour, to: startOfDay), from < now else { continue }
            let to = min(calendar.date(byAdding: .hour, value: 1, to: from) ?? from, now)
            group.enter()
            pedometer.queryPedometerData(from: from, to: to) { data, _ in
                results[hour] = data?.numberOfSteps.intValue ?? 0
                group.leave()
            }
        }

        group.notify(queue: .main) { completion(results) }
    }
}
