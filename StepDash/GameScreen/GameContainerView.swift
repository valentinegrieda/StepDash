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
    @StateObject private var voiceControl = VoiceControlManager()
    @State private var showMissions = false
    @State private var showHistory = false

    // The persisted Player is the source of truth for name + step length,
    // falling back to the values passed in if the query hasn't resolved yet.
    private var databasePlayer: Player? { players.first }
    private var playerName: String { databasePlayer?.name ?? name }
    private var playerStepLength: Double { databasePlayer?.stepLength ?? stepLength }
    private var todayDistance: Double { Double(session.todaySteps) * playerStepLength }
    private var todayRecord: DailyStepRecord {
        DailyStepRecord.record(for: Date(), context: context)
    }

    var body: some View {
        ZStack {
            Group {
                if selectedDestination == .home {
                    HomeView(
                        playerName: playerName,
                        stepLength: playerStepLength,
                        session: session,
                        selectedDestination: selectedDestination,
                        showMissions: $showMissions,
                        showHistory: $showHistory,
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

            voiceControlOverlay
        }
        .animation(.easeOut(duration: 0.18), value: selectedDestination)
        .onAppear {
            Mission.seedIfNeeded(context: context)
            session.start()
            evaluateStep()
            voiceControl.onCommand = handleVoiceCommand
        }
        .onDisappear {
            voiceControl.stopListening()
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

        let record = DailyStepRecord.record(for: Date(), context: context)
        let distance = Double(today) * playerStepLength
        if record.steps != today { record.steps = today }
        if record.distance != distance { record.distance = distance }
        evaluateCurrentDelivery(todaySteps: today, record: record)

        // Missions now use the design's auto-track + claim flow (see MissionsPopup),
        // so the old accept-based auto-grant loop is retired — we only reset the
        // daily claim state here.
        MissionStore.refresh(for: Date(), context: context)

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

    private var voiceControlOverlay: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    voiceControl.toggleListening()
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: voiceControl.isListening ? "mic.fill" : "mic")
                            .font(.system(size: 18, weight: .heavy))
                        Text(voiceControl.isListening ? "VOICE ON" : "VOICE")
                            .font(Pixel.font(9, weight: .heavy))
                    }
                    .foregroundStyle(.white)
                    .frame(width: 74, height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(voiceControl.isListening ? Pixel.dGreen : Pixel.dNavy)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(.white.opacity(0.65), lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.28), radius: 4, x: 0, y: 2)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(voiceControl.isListening ? "Turn voice control off" : "Turn voice control on")
                .padding(.trailing, 16)
                .padding(.bottom, 104)
            }
        }
        .allowsHitTesting(true)
    }

    private func handleVoiceCommand(_ command: VoiceCommand) {
        switch command {
        case .destination(let destination):
            selectDestination(destination)
            closePopups()
        case .openMissions:
            selectedDestination = .home
            showHistory = false
            showMissions = true
        case .openHistory:
            selectedDestination = .home
            showMissions = false
            showHistory = true
        case .closePopup:
            closePopups()
        case .acceptDelivery:
            acceptCurrentDelivery()
        case .claimDelivery:
            claimCurrentDelivery()
        case .claimMission:
            claimFirstCompletedMission()
        }
    }

    private func closePopups() {
        showMissions = false
        showHistory = false
    }

    private func acceptCurrentDelivery() {
        let delivery = DeliveryStore.current(for: Date(), context: context)
        guard !delivery.isAccepted else { return }

        DeliveryStore.accept(delivery, context: context)
        evaluateStep()
    }

    private func claimCurrentDelivery() {
        guard let delivery = deliveries.first else { return }

        DeliveryStore.claim(
            delivery,
            todaySteps: session.todaySteps,
            player: players.first,
            context: context
        )
        evaluateStep()
    }

    private func claimFirstCompletedMission() {
        let deliveriesToday = todayRecord.deliveriesDone
        guard let mission = missions.first(where: {
            !$0.isClaimed && $0.isComplete(todaySteps: session.todaySteps, deliveriesToday: deliveriesToday)
        }) else { return }

        MissionStore.claim(
            mission,
            todaySteps: session.todaySteps,
            deliveriesToday: deliveriesToday,
            player: players.first,
            context: context
        )
    }
}
