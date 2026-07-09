import SwiftUI

/// Placeholder Achievements modal — a "Coming Soon" empty state, styled like the
/// history/missions empty state.
struct AchievementsPopup: View {
    var onClose: () -> Void

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
                comingSoon
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
            Text("ACHIEVEMENTS")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
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

    private var comingSoon: some View {
        VStack(spacing: 10) {
            PixelIcon(name: "Trophy")
                .frame(width: 56, height: 56)
            Text("Coming Soon!")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Pixel.ink)
            Text("Achievements are on the way!")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Pixel.dMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 391)
        .padding(.horizontal, 20)
        .background(listBG)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Pixel.dBlue, lineWidth: 1))
    }
}
