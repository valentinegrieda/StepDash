import SwiftUI
import SwiftData

/// Shows the player's claimed delivery history.
struct HistoryPopup: View {
    var onClose: () -> Void

    @Query(sort: \DeliveryHistory.claimedAt, order: .reverse) private var histories: [DeliveryHistory]

    private let purple = Color(hex: 0x655DD1)
    private let frameBG = Color(hex: 0xF9F8F6)
    private let listBG = Color(hex: 0xF1F0ED)

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
                        cornerRadii: .init(
                            topLeading: 0,
                            bottomLeading: 8,
                            bottomTrailing: 8,
                            topTrailing: 0,
                        )
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
            if histories.isEmpty {
                emptyState
            } else {
                VStack(spacing: 0) {
                    ForEach(histories) { history in
                        row(history)
                        if history.id != histories.last?.id {
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
            Text("No delivery history yet")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Pixel.ink)
            Text("Go deliver a package!")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Pixel.dMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 220)
        .padding(.horizontal, 20)
    }

    private func row(_ history: DeliveryHistory) -> some View {
        HStack(spacing: 10) {
            PixelIcon(name: "Package").frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 6) {
                Text("\(history.recipient)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Pixel.ink)
                    .lineLimit(2)

                Text("Delivered")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Pixel.dGreen)
            }

            Spacer(minLength: 8)

            VStack(spacing: 4) {
                HStack(spacing: 3) {
                    PixelIcon(name: "Coin").frame(width: 16, height: 16)
                    Text("+\(history.rewardCoins)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Pixel.ink)
                }
            }
            .fixedSize()
        }
        .frame(minHeight: 76)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
    }
}
