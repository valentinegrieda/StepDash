import SwiftUI
import SpriteKit
import SwiftData

struct HomeView: View {
    let playerName: String
    let stepLength: Double
    var session: GameSession
    let selectedDestination: ToolbarDestination
    var onSelect: (ToolbarDestination) -> Void

    @Environment(\.modelContext) private var context
    @Query private var players: [Player]
    @Query private var deliveries: [CurrentDelivery]
    @Query private var dayRecords: [DailyStepRecord]

    private var coins: Int { players.first?.coins ?? 0 }
    private var todaySteps: Int { session.todaySteps }
    private var delivery: CurrentDelivery? { deliveries.first }
    private var consumed: Int {
        dayRecords.first { Calendar.current.isDate($0.date, inSameDayAs: Date()) }?.consumedSteps ?? 0
    }

    var body: some View {
        ZStack {
            // Full-screen scrolling background (undermost layer).
            SceneBand(name: playerName, stepLength: stepLength)
                .ignoresSafeArea()

            // All UI floats on top of the background.
            VStack(spacing: 12) {
                topBar
                    .padding(.horizontal, 12)
                    .padding(.top, 8)

                Spacer(minLength: 0)

                deliveryPanel
                    .padding(.horizontal, 12)

                categoryBoxes
                    .padding(.horizontal, 12)

                GameBottomToolbar(selected: selectedDestination, onSelect: onSelect)
            }
        }
        .onAppear {
            DeliveryStore.current(for: Date(), context: context)
        }
        #if DEBUG
        .overlay(alignment: .topTrailing) {
            Button("+500 steps") {
                MotionManager.shared.debugAddSteps(500)
            }
            .font(Pixel.font(11, weight: .heavy))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color.black.opacity(0.55)))
            .padding(.top, 72)
            .padding(.trailing, 16)
        }
        #endif
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack(spacing: 8) {
            // Player (fixed width — room for ~7 characters)
            HStack(spacing: 8) {
                PixelIcon(name: "Head1").frame(width: 30, height: 30)
                Text(playerName.uppercased())
                    .font(Pixel.font(13, weight: .heavy))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .padding(.horizontal, 12)
            .frame(width: 120, height: 52)
            .pixelBox(fill: Pixel.dNavy, stroke: Pixel.dNavyEdge)

            // Today's steps
            HStack(spacing: 8) {
                PixelIcon(name: "Shoe").frame(width: 30, height: 30)
                VStack(alignment: .leading, spacing: 1) {
                    Text("TODAY'S STEPS")
                        .font(Pixel.font(9, weight: .bold))
                        .foregroundStyle(Pixel.dMuted)
                    Text(stepFormatted(todaySteps))
                        .font(Pixel.font(18, weight: .heavy))
                        .foregroundStyle(Pixel.ink)
                }
            }
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .pixelBox(fill: .white, stroke: Pixel.dWhiteEdge)

            // Coins (fixed width — room for 4 digits)
            HStack(spacing: 6) {
                PixelIcon(name: "Coin").frame(width: 24, height: 24)
                Text(stepFormatted(coins))
                    .font(Pixel.font(15, weight: .heavy))
                    .foregroundStyle(Pixel.ink)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .frame(width: 100, height: 52)
            .pixelBox(fill: .white, stroke: Pixel.dWhiteEdge)
        }
    }

    // MARK: - Delivery panel

    private var deliveryPanel: some View {
        VStack(spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                PixelIcon(name: "Home").frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text("CURRENT DELIVERY")
                        .font(Pixel.font(12, weight: .semibold))
                        .foregroundStyle(Pixel.dOrange)
                    Text("Deliver to:")
                        .font(Pixel.font(11, weight: .regular))
                        .foregroundStyle(Pixel.dMuted)
                    Text(delivery?.recipient ?? "—")
                        .font(Pixel.font(17, weight: .bold))
                        .foregroundStyle(Pixel.ink)
                }

                Spacer()

                VStack(spacing: 3) {
                    Text("REWARD")
                        .font(Pixel.font(9, weight: .bold))
                        .foregroundStyle(Pixel.dMuted)
                    HStack(spacing: 4) {
                        PixelIcon(name: "Coin").frame(width: 18, height: 18)
                        Text("\(delivery?.rewardCoins ?? 0)")
                            .font(Pixel.font(15, weight: .heavy))
                            .foregroundStyle(Pixel.ink)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .pixelBox(fill: .white, stroke: Pixel.dWhiteEdge)
            }

            HStack(spacing: 12) {
                // Progress bar + count share one flexible frame, so it stays put
                // when the button changes from ACCEPT to CLAIM.
                VStack(alignment: .leading, spacing: 8) {
                    ProgressTrack(fraction: fraction)
                        .frame(height: 10)
                    Text("\(stepFormatted(progressSteps)) / \(stepFormatted(delivery?.goalSteps ?? 0)) steps")
                        .font(Pixel.font(12, weight: .heavy))
                        .foregroundStyle(Pixel.dOrange)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                deliveryButton
                    .frame(width: 104, height: 48)
            }
        }
        .padding(14)
        .pixelBox(fill: .white, stroke: Pixel.dWhiteEdge)
    }

    private var progressSteps: Int {
        delivery?.progress(todaySteps: todaySteps, consumed: consumed) ?? 0
    }
    private var fraction: Double {
        delivery?.fraction(todaySteps: todaySteps, consumed: consumed) ?? 0
    }
    private var isComplete: Bool {
        delivery?.isComplete(todaySteps: todaySteps, consumed: consumed) ?? false
    }

    @ViewBuilder
    private var deliveryButton: some View {
        if let delivery {
            if !delivery.isAccepted {
                Button("ACCEPT") {
                    DeliveryStore.accept(delivery, context: context)
                    if delivery.isComplete(todaySteps: todaySteps, consumed: consumed) {
                        NotificationManager.shared.notifyDeliveryCompletedIfNeeded(
                            recipient: delivery.recipient,
                            dayKey: delivery.dayKey,
                            goalSteps: delivery.goalSteps
                        )
                    } else {
                        MissionBackgroundRefreshManager.shared.scheduleRefreshSoon()
                    }
                }
                    .buttonStyle(DeliveryButtonStyle(fill: Pixel.dGreen, edge: Pixel.dGreenEdge, textColor: .white))
            } else {
                Button("CLAIM") {
                    DeliveryStore.claim(delivery, todaySteps: todaySteps, player: players.first, context: context)
                }
                .buttonStyle(DeliveryButtonStyle(
                    fill: isComplete ? Pixel.dYellow : Pixel.dTrack,
                    edge: isComplete ? Pixel.dYellowEdge : Pixel.dWhiteEdge,
                    textColor: isComplete ? Pixel.ink : Pixel.dMuted
                ))
                .disabled(!isComplete)
            }
        }
    }

    // MARK: - Category boxes

    private var categoryBoxes: some View {
        HStack(spacing: 10) {
            categoryBox(icon: "Trophy", title: "ACHIEVEMENTS") { }
            categoryBox(icon: "List",  title: "MISSIONS") { onSelect(.missions) }
            categoryBox(icon: "Package", title: "HISTORY") { }
        }
    }

    private func categoryBox(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                PixelIcon(name: icon).frame(width: 64, height: 64)
                Text(title)
                    .font(Pixel.font(12, weight: .semibold))
                    .foregroundStyle(Pixel.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 8)
            .pixelBox(fill: Pixel.dBlue, stroke: Pixel.dBlueEdge)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Supporting views

/// Orange progress fill on a light track (rounded).
private struct ProgressTrack: View {
    let fraction: Double
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Pixel.dTrack)
                Capsule().fill(Pixel.dOrange)
                    .frame(width: geo.size.width * min(max(fraction, 0), 1))
            }
        }
    }
}

private struct DeliveryButtonStyle: ButtonStyle {
    var fill: Color
    var edge: Color
    var textColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Pixel.font(14, weight: .heavy))
            .foregroundStyle(textColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(RoundedRectangle(cornerRadius: 8).fill(fill))
            .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(edge, lineWidth: 2))
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

/// The SpriteKit walking scene, embedded as a fixed band (no in-scene toolbar).
private struct SceneBand: UIViewRepresentable {
    let name: String
    let stepLength: Double

    func makeUIView(context: Context) -> SKView {
        GameSKView(playerName: name, stepLength: stepLength)
    }

    func updateUIView(_ uiView: SKView, context: Context) {}
}
