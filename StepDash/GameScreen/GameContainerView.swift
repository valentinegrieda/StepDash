import SwiftUI
import SpriteKit
import SwiftData

struct GameContainerView: View {
    let name: String
    let stepLength: Double

    @Environment(\.modelContext) private var context
    @Query private var missions: [Mission]
    @Query private var players: [Player]

    @State private var presentation: ToolbarDestinationPresentation?
    @State private var todaySteps = 0
    @State private var accumulatedSteps = 0

    private var todayDistance: Double { Double(todaySteps) * stepLength }

    var body: some View {
        ZStack {
            GameSceneRepresentable(
                name: name,
                stepLength: stepLength,
                onToolbarItemSelected: { itemId, _, _ in
                    guard let selected = ToolbarDestination(rawValue: itemId) else { return }
                    presentation = ToolbarDestinationPresentation(
                        destination: selected,
                        steps: todaySteps,
                        distance: todayDistance
                    )
                },
                onStepUpdate: { today, accumulated, _ in
                    handleStep(today: today, accumulated: accumulated)
                }
            )
            .ignoresSafeArea()

            if let presentation {
                ToolbarDestinationView(
                    destination: presentation.destination,
                    playerName: name,
                    steps: todaySteps,
                    distance: todayDistance,
                    accumulatedSteps: accumulatedSteps,
                    stepLength: stepLength,
                    onClose: {
                        self.presentation = nil
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }
        }
        .animation(.easeOut(duration: 0.18), value: presentation?.id)
        .onAppear { Mission.seedIfNeeded(context: context) }
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
}

private struct GameSceneRepresentable: UIViewRepresentable {
    let name: String
    let stepLength: Double
    let onToolbarItemSelected: (String, Int, Double) -> Void
    let onStepUpdate: (Int, Int, Double) -> Void

    func makeUIView(context: Context) -> SKView {
        GameSKView(
            playerName: name,
            stepLength: stepLength,
            onToolbarItemSelected: onToolbarItemSelected,
            onStepUpdate: onStepUpdate
        )
    }

    func updateUIView(_ uiView: SKView, context: Context) {
        guard let view = uiView as? GameSKView else { return }
        view.updateToolbarHandler(onToolbarItemSelected)
        view.updateStepHandler(onStepUpdate)
    }
}
