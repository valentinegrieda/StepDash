import Foundation
import CoreMotion

final class MotionManager {

    static let shared = MotionManager()

    private let pedometer = CMPedometer()

    /// Called on the main thread with `(todaySteps, accumulatedSteps)`.
    /// - `todaySteps`: raw pedometer count for the current day, resets at midnight.
    /// - `accumulatedSteps`: monotonic count that survives midnight (used as the
    ///   baseline reference for accepted weekly deliveries).
    var onStep: ((Int, Int) -> Void)?

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

                self.onStep?(raw, self.accumulatedBase + raw)
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
        onStep?(0, 0)
    }
}
