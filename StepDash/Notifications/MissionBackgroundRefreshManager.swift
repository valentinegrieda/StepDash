import BackgroundTasks
import CoreMotion
import Foundation
import SwiftData
import SwiftUI
import UIKit

@MainActor
final class MissionBackgroundRefreshManager {
    static let shared = MissionBackgroundRefreshManager()

    private let taskIdentifier = "com.valentinegrieda.StepDash.mission-refresh"
    private let pedometer = CMPedometer()
    private var modelContainer: ModelContainer?
    private var didRegisterTask = false
    private var backgroundDeliveryCheckTask: Task<Void, Never>?
    private var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = .invalid

    private init() {}

    func configure(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        registerTaskIfNeeded()
        scheduleRefresh()
    }

    func scheduleRefreshSoon() {
        scheduleRefresh()
    }

    func handleScenePhase(_ phase: ScenePhase) {
        switch phase {
        case .background:
            startBackgroundDeliveryChecks()
        case .active:
            stopBackgroundDeliveryChecks()
            Task {
                await evaluateAcceptedMissions()
            }
        default:
            break
        }
    }

    private func registerTaskIfNeeded() {
        guard !didRegisterTask else { return }
        didRegisterTask = true

        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            guard let refreshTask = task as? BGAppRefreshTask else {
                task.setTaskCompleted(success: false)
                return
            }

            Task { @MainActor in
                self.handle(refreshTask)
            }
        }
    }

    private func scheduleRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60)

        do {
            BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: taskIdentifier)
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Failed to schedule mission background refresh:", error)
        }
    }

    private func handle(_ task: BGAppRefreshTask) {
        scheduleRefresh()

        let evaluationTask = Task {
            await evaluateAcceptedMissions()
            task.setTaskCompleted(success: !Task.isCancelled)
        }

        task.expirationHandler = {
            evaluationTask.cancel()
        }
    }

    private func startBackgroundDeliveryChecks() {
        stopBackgroundDeliveryChecks()
        scheduleRefresh()

        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(withName: "StepDashDeliveryCheck") { [weak self] in
            Task { @MainActor in
                self?.stopBackgroundDeliveryChecks()
            }
        }

        backgroundDeliveryCheckTask = Task { [weak self] in
            guard let self else { return }

            while !Task.isCancelled {
                await self.evaluateAcceptedMissions()

                do {
                    try await Task.sleep(for: .seconds(30))
                } catch {
                    break
                }
            }

            await MainActor.run {
                self.endBackgroundTaskIfNeeded()
            }
        }
    }

    private func stopBackgroundDeliveryChecks() {
        backgroundDeliveryCheckTask?.cancel()
        backgroundDeliveryCheckTask = nil
        endBackgroundTaskIfNeeded()
    }

    private func endBackgroundTaskIfNeeded() {
        guard backgroundTaskIdentifier != .invalid else { return }
        UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
        backgroundTaskIdentifier = .invalid
    }

    private func evaluateAcceptedMissions() async {
        guard let modelContainer else { return }
        guard CMPedometer.isStepCountingAvailable() else { return }
        guard let todaySteps = await queryTodaySteps() else { return }

        let context = modelContainer.mainContext
        let players = (try? context.fetch(FetchDescriptor<Player>())) ?? []
        let player = players.first
        let stepLength = player?.stepLength ?? 0.7
        let now = Date()

        let record = DailyStepRecord.record(for: now, context: context)
        let distance = Double(todaySteps) * stepLength
        if record.steps != todaySteps { record.steps = todaySteps }
        if record.distance != distance { record.distance = distance }

        evaluateCurrentDelivery(todaySteps: todaySteps, record: record, context: context)

        let missions = (try? context.fetch(FetchDescriptor<Mission>())) ?? []
        let accumulatedSteps = backgroundAccumulatedSteps(todaySteps: todaySteps)
        var completedNow = 0

        for mission in missions {
            mission.refreshPeriod(now: now)

            guard mission.isAccepted else {
                NotificationManager.shared.cancelMissionCompletionNotification(missionID: mission.id)
                continue
            }

            guard !mission.isCompleted else { continue }

            if mission.isReached(
                todaySteps: todaySteps,
                accumulatedSteps: accumulatedSteps,
                stepLength: stepLength
            ) {
                mission.isCompleted = true
                completedNow += 1
                NotificationManager.shared.notifyMissionCompleted(missionID: mission.id, title: mission.title)

                player?.coins += mission.rewardCoins
                player?.xp += mission.rewardXP
            }
        }

        if completedNow > 0 {
            record.deliveriesDone += completedNow
        }

        if context.hasChanges {
            try? context.save()
        }
    }

    private func queryTodaySteps() async -> Int? {
        let startOfToday = Calendar.current.startOfDay(for: Date())

        return await withCheckedContinuation { continuation in
            pedometer.queryPedometerData(from: startOfToday, to: Date()) { data, error in
                if let error {
                    print("Background pedometer query failed:", error)
                    continuation.resume(returning: nil)
                    return
                }

                continuation.resume(returning: data?.numberOfSteps.intValue)
            }
        }
    }

    private func backgroundAccumulatedSteps(todaySteps: Int) -> Int {
        let defaults = UserDefaults.standard
        let baseKey = "StepAccumulatedBase"
        let lastRawKey = "StepLastRaw"

        var base = defaults.integer(forKey: baseKey)
        let lastRaw = defaults.integer(forKey: lastRawKey)

        if todaySteps < lastRaw {
            base += lastRaw
        }

        defaults.set(base, forKey: baseKey)
        defaults.set(todaySteps, forKey: lastRawKey)

        return base + todaySteps
    }

    private func evaluateCurrentDelivery(todaySteps: Int, record: DailyStepRecord, context: ModelContext) {
        let deliveries = (try? context.fetch(FetchDescriptor<CurrentDelivery>())) ?? []
        guard let delivery = deliveries.first, delivery.isAccepted else { return }
        guard delivery.isComplete(todaySteps: todaySteps, consumed: record.consumedSteps) else { return }

        NotificationManager.shared.notifyDeliveryCompletedIfNeeded(
            recipient: delivery.recipient,
            dayKey: delivery.dayKey,
            goalSteps: delivery.goalSteps
        )
    }
}
