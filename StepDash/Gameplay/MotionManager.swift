import Foundation
import CoreMotion

final class MotionManager {

    static let shared = MotionManager()

    private let pedometer = CMPedometer()
    var onStep: ((Int) -> Void)?

    private var isRunning = false

    // FIX: consistent start time (midnight)
    private let startDate: Date = Calendar.current.startOfDay(for: Date())

    private init() {}

    private var timer: Timer?

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

        pedometer.queryPedometerData(from: startDate, to: Date()) { [weak self] data, error in

            if let error {
                print("❌ query error:", error)
                return
            }

            guard let steps = data?.numberOfSteps.intValue else { return }

            DispatchQueue.main.async {
                self?.onStep?(steps)
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
        UserDefaults.standard.removeObject(forKey: "StepStartDate")
        onStep?(0)
    }
}
