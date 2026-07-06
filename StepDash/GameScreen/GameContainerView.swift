import SwiftUI
import SwiftData

struct GameContainerView: View {
    let name: String
    let stepLength: Double

    @Environment(\.modelContext) private var context
    @Query private var missions: [Mission]
    @Query private var players: [Player]
    @Query private var deliveries: [CurrentDelivery]

    /// Always-on step feed for this session. Owned here (the persistent shell)
    /// so the data pipeline keeps running across every page, not just Home.
    @State private var session = GameSession()
    @State private var selectedDestination: ToolbarDestination = .home

    // The persisted Player is the source of truth for name + step length,
    // falling back to the values passed in if the query hasn't resolved yet.
    private var databasePlayer: Player? { players.first }
    private var playerName: String { databasePlayer?.name ?? name }
    private var playerStepLength: Double { databasePlayer?.stepLength ?? stepLength }
    private var todayDistance: Double { Double(session.todaySteps) * playerStepLength }

    var body: some View {
        Group {
            if selectedDestination == .home {
                HomeView(
                    playerName: playerName,
                    stepLength: playerStepLength,
                    session: session,
                    selectedDestination: selectedDestination,
                    onSelect: selectDestination
                )
            } else {
                ToolbarDestinationView(
                    destination: selectedDestination,
                    selectedDestination: selectedDestination,
                    playerName: playerName,
                    steps: session.todaySteps,
                    distance: todayDistance,
                    accumulatedSteps: session.accumulatedSteps,
                    stepLength: playerStepLength,
                    onSelect: selectDestination,
                    onMissionAccepted: evaluateStep
                )
            }
        }
        .animation(.easeOut(duration: 0.18), value: selectedDestination)
        .onAppear {
            Mission.seedIfNeeded(context: context)
            session.start()
            evaluateStep()
        }
        .onChange(of: session.todaySteps) { _, _ in
            evaluateStep()
        }
        .onChange(of: session.accumulatedSteps) { _, _ in
            evaluateStep()
        }
    }

    /// Runs on every step change, regardless of which page is visible: records
    /// today's steps/distance and evaluates accepted missions for completion
    /// (granting rewards + crediting a delivery to today's record).
    private func evaluateStep() {
        let today = session.todaySteps
        let accumulated = session.accumulatedSteps

        let record = DailyStepRecord.record(for: Date(), context: context)
        let distance = Double(today) * playerStepLength
        if record.steps != today { record.steps = today }
        if record.distance != distance { record.distance = distance }
        evaluateCurrentDelivery(todaySteps: today, record: record)

        let now = Date()
        var completedNow = 0

        for mission in missions {
            mission.refreshPeriod(now: now)
            guard mission.isAccepted else {
                NotificationManager.shared.cancelMissionCompletionNotification(missionID: mission.id)
                continue
            }

            guard !mission.isCompleted else { continue }

            if mission.isReached(todaySteps: today, accumulatedSteps: accumulated, stepLength: playerStepLength) {
                mission.isCompleted = true
                completedNow += 1
                NotificationManager.shared.notifyMissionCompleted(missionID: mission.id, title: mission.title)

                if let player = players.first {
                    player.coins += mission.rewardCoins
                    player.xp += mission.rewardXP
                }
            }
        }

        if completedNow > 0 {
            record.deliveriesDone += completedNow
        }

        if context.hasChanges {
            try? context.save()
        }
    }

    private func selectDestination(_ destination: ToolbarDestination) {
        selectedDestination = destination
    }

    private func evaluateCurrentDelivery(todaySteps: Int, record: DailyStepRecord) {
        guard let delivery = deliveries.first, delivery.isAccepted else { return }
        guard delivery.isComplete(todaySteps: todaySteps, consumed: record.consumedSteps) else { return }

        NotificationManager.shared.notifyDeliveryCompletedIfNeeded(
            recipient: delivery.recipient,
            dayKey: delivery.dayKey,
            goalSteps: delivery.goalSteps
        )
    }
}
