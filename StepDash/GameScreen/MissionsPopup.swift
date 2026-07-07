import SwiftUI
import SwiftData

/// The daily missions modal, opened from the Home "MISSIONS" box.
/// Missions auto-track and are claimed here; they reset at midnight.
struct MissionsPopup: View {
    let todaySteps: Int
    let deliveriesToday: Int
    var onClose: () -> Void

    @Environment(\.modelContext) private var context
    @Query(sort: \Mission.id) private var missions: [Mission]
    @Query private var players: [Player]

    private let purple  = Color(hex: 0x655DD1)
    private let frameBG = Color(hex: 0xF9F8F6)
    private let listBG  = Color(hex: 0xF1F0ED)
    private let green   = Color(hex: 0x57B84F)
    private let track   = Color(hex: 0xDAD8D2)

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture { onClose() }

            VStack(spacing: 16) {
                header
                missionList
                footer
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 14)
            .frame(width: 354)
            .frame(maxHeight: 462)
            .background(frameBG)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Header

    private var header: some View {
        ZStack {
            // Centered title chip
            Text("MISSIONS")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 4)
                .background(
                    UnevenRoundedRectangle(
                        cornerRadii: .init(
                            topLeading: 0,
                            bottomLeading: 8,
                            bottomTrailing: 8,
                            topTrailing: 0,
                        )
                    )
                    .fill(purple)
                )
            
            // Close button pinned to the right
            HStack {
                Spacer()
                Button { onClose() } label: {
                    PixelIcon(name: "X").frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - List

    private var missionList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(missions, id: \.id) { mission in
                    row(mission)
                    if mission.id != missions.last?.id {
                        Divider()
                    }
                }
            }
        }
        .background(listBG)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Pixel.dBlue, lineWidth: 1))
    }

    private func row(_ mission: Mission) -> some View {
        let current  = mission.currentCount(todaySteps: todaySteps, deliveriesToday: deliveriesToday)
        let complete = mission.isComplete(todaySteps: todaySteps, deliveriesToday: deliveriesToday)
        let fraction = mission.fraction(todaySteps: todaySteps, deliveriesToday: deliveriesToday)

        return HStack(spacing: 10) {
            PixelIcon(name: mission.iconName).frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 10) {
                    Text(mission.title)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Pixel.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                }
                progressBar(fraction: fraction)
                    .frame(height: 6)

                Text(mission.showsCount ? "\(stepFormatted(current)) / \(stepFormatted(mission.goal))" : " ")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Pixel.dMuted)
            }
            
            HStack(spacing: 3) {
                PixelIcon(name: "Coin").frame(width: 16, height: 16)
                Text("\(mission.rewardCoins)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Pixel.ink)
            }
            .fixedSize()

            stateView(mission, complete: complete)
        }
        .frame(height: 68)
        .padding(.horizontal, 8)
    }

    private func progressBar(fraction: Double) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(track)
                Capsule().fill(green)
                    .frame(width: geo.size.width * min(max(fraction, 0), 1))
            }
        }
    }

    @ViewBuilder
    private func stateView(_ mission: Mission, complete: Bool) -> some View {
        if mission.isClaimed {
            PixelIcon(name: "Check").frame(width: 26, height: 26)
        } else if complete {
            Button {
                MissionStore.claim(mission,
                                   todaySteps: todaySteps,
                                   deliveriesToday: deliveriesToday,
                                   player: players.first,
                                   context: context)
            } label: {
                Text("CLAIM")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Pixel.ink)
                    .frame(width: 65, height: 32)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Pixel.dYellow))
            }
            .buttonStyle(.plain)
        } else {
            Color.clear.frame(width: 1, height: 32)
        }
    }

    // MARK: - Footer

    private var footer: some View {
        TimelineView(.periodic(from: .now, by: 60)) { _ in
            HStack(spacing: 6) {
                Image(systemName: "clock")
                    .font(.system(size: 12))
                    .foregroundStyle(Pixel.dMuted)
                Text("Refresh in:")
                    .foregroundStyle(Pixel.dMuted)
                Text(refreshCountdown)
                    .foregroundStyle(Pixel.ink)
                    .bold()
            }
            .font(.system(size: 12, weight: .semibold))
        }
    }

    private var refreshCountdown: String {
        let calendar = Calendar.current
        let now = Date()
        let nextMidnight = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) ?? now
        let minutes = max(0, Int(nextMidnight.timeIntervalSince(now) / 60))
        return "\(minutes / 60)h \(minutes % 60)m"
    }
}
