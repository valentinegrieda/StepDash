import SwiftUI
import SwiftData

/// One coin-earning event (a claimed delivery or a claimed mission).
private struct HistoryEntry: Identifiable {
    let id: UUID
    let icon: String
    let title: String
    let subtitle: String
    let subtitleColor: Color
    let rewardCoins: Int
    let date: Date
}

/// Shows the player's history of everything that earned coins (deliveries + missions).
struct HistoryPopup: View {
    var onClose: () -> Void

    @Query(sort: \DeliveryHistory.claimedAt, order: .reverse) private var deliveries: [DeliveryHistory]
    @Query(sort: \MissionHistory.completedAt, order: .reverse) private var missions: [MissionHistory]

    private let purple = Color(hex: 0x655DD1)
    private let frameBG = Color(hex: 0xF9F8F6)
    private let listBG = Color(hex: 0xF1F0ED)

    private var entries: [HistoryEntry] {
        let deliveryEntries = deliveries.map {
            HistoryEntry(id: $0.id, icon: "Package", title: $0.recipient,
                         subtitle: "Delivered", subtitleColor: Pixel.dGreen,
                         rewardCoins: $0.rewardCoins, date: $0.claimedAt)
        }
        let missionEntries = missions.map {
            HistoryEntry(id: $0.id, icon: $0.missionIconName, title: $0.missionTitle,
                         subtitle: "Mission complete", subtitleColor: purple,
                         rewardCoins: $0.rewardCoins, date: $0.completedAt)
        }
        return (deliveryEntries + missionEntries).sorted { $0.date > $1.date }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture { onClose() }

            VStack(spacing: 16) {
                header
                historyList
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 14)
            .frame(width: 354)
            .frame(maxHeight: 462)
            .background(frameBG)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var header: some View {
        ZStack {
            Text("HISTORY")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 4)
                .background(
                    UnevenRoundedRectangle(
                        cornerRadii: .init(topLeading: 0, bottomLeading: 8, bottomTrailing: 8, topTrailing: 0)
                    )
                    .fill(purple)
                )

            HStack {
                Spacer()
                Button { onClose() } label: {
                    PixelIcon(name: "X").frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var historyList: some View {
        ScrollView(showsIndicators: false) {
            if entries.isEmpty {
                emptyState
            } else {
                VStack(spacing: 0) {
                    ForEach(entries) { entry in
                        row(entry)
                        if entry.id != entries.last?.id {
                            Divider()
                        }
                    }
                }
            }
        }
        .background(listBG)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Pixel.dBlue, lineWidth: 1))
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            PixelIcon(name: "Package")
                .frame(width: 56, height: 56)
            Text("No history yet")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Pixel.ink)
            Text("Claim a delivery or mission to start earning!")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Pixel.dMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 220)
        .padding(.horizontal, 20)
    }

    private func row(_ entry: HistoryEntry) -> some View {
        HStack(spacing: 10) {
            PixelIcon(name: entry.icon).frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 6) {
                Text(entry.title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Pixel.ink)
                    .lineLimit(2)

                Text(entry.subtitle)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(entry.subtitleColor)
            }

            Spacer()

            HStack(spacing: 3) {
                PixelIcon(name: "Coin").frame(width: 16, height: 16)
                Text("+\(entry.rewardCoins)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Pixel.ink)
            }
            .fixedSize()
        }
        .frame(height: 68)
        .padding(.horizontal, 8)
    }
}
