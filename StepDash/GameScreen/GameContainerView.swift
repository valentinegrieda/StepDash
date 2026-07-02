import SwiftUI
import SpriteKit
import SwiftData

struct GameContainerView: View {
    let name: String
    let stepLength: Double

    @Environment(\.modelContext) private var context
    @Query private var missions: [Mission]
    @Query private var players: [Player]

    @State private var selectedDestination: ToolbarDestination = .home
    @State private var todaySteps = 0
    @State private var accumulatedSteps = 0

    private var todayDistance: Double { Double(todaySteps) * stepLength }

    var body: some View {
        Group {
            if selectedDestination == .home {
                homeScene
            } else {
                ToolbarDestinationView(
                    destination: selectedDestination,
                    selectedDestination: selectedDestination,
                    playerName: name,
                    steps: todaySteps,
                    distance: todayDistance,
                    accumulatedSteps: accumulatedSteps,
                    stepLength: stepLength,
                    onSelect: selectDestination
                )
            }
        }
        .animation(.easeOut(duration: 0.18), value: selectedDestination)
        .onAppear { Mission.seedIfNeeded(context: context) }
    }

    private var homeScene: some View {
        GameSceneRepresentable(
            name: name,
            stepLength: stepLength,
            activeToolbarItemID: selectedDestination.rawValue,
            onToolbarItemSelected: { itemId, steps, _ in
                todaySteps = steps
                guard let selected = ToolbarDestination(rawValue: itemId) else { return }
                selectDestination(selected)
            },
            onStepUpdate: { today, accumulated, _ in
                handleStep(today: today, accumulated: accumulated)
            }
        )
        .ignoresSafeArea()
    }

    /// Records today's steps/distance and evaluates every accepted mission for
    /// completion (granting rewards + crediting a delivery to today's record).
    private func handleStep(today: Int, accumulated: Int) {
        todaySteps = today
        accumulatedSteps = accumulated

        let record = DailyStepRecord.record(for: Date(), context: context)
        let distance = Double(today) * stepLength
        if record.steps != today { record.steps = today }
        if record.distance != distance { record.distance = distance }

        let now = Date()
        var completedNow = 0

        for mission in missions {
            mission.refreshPeriod(now: now)
            guard mission.isAccepted, !mission.isCompleted else { continue }

            if mission.isReached(todaySteps: today, accumulatedSteps: accumulated, stepLength: stepLength) {
                mission.isCompleted = true
                completedNow += 1

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
}

private struct GameSceneRepresentable: UIViewRepresentable {
    let name: String
    let stepLength: Double
    let activeToolbarItemID: String
    let onToolbarItemSelected: (String, Int, Double) -> Void
    let onStepUpdate: (Int, Int, Double) -> Void

    func makeUIView(context: Context) -> SKView {
        GameSKView(
            playerName: name,
            stepLength: stepLength,
            activeToolbarItemID: activeToolbarItemID,
            onToolbarItemSelected: onToolbarItemSelected,
            onStepUpdate: onStepUpdate
        )
    }

    func updateUIView(_ uiView: SKView, context: Context) {
        guard let gameView = uiView as? GameSKView else { return }
        gameView.updateToolbarHandler(onToolbarItemSelected)
        gameView.updateStepHandler(onStepUpdate)
        gameView.updateActiveToolbarItem(activeToolbarItemID)
    }
}
