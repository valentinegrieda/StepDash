//
//  ProfileView.swift
//  StepDash
//
//  The Profile toolbar page. Rendered inside the shared `DashboardPanel`
//  ("PROFILE" header) from `ToolbarDestinationView`, so this view only supplies
//  the panel *contents*: courier header, customize rows, and account actions.
//  Dialogs use the app's pixel popup look (scrim + cream card + title chip),
//  matching `MissionsPopup` rather than stock iOS alerts.
//

import SwiftUI
import SwiftData

struct ProfileContent: View {
    /// Fallback name, used only until the Player query resolves.
    let playerName: String

    @Environment(\.modelContext) private var context
    @Query private var players: [Player]

    @State private var activeModal: ProfileModal?
    @State private var draftName = ""

    private var player: Player? { players.first }
    private var displayName: String { player?.name ?? playerName }
    private var coins: Int { player?.coins ?? 0 }

    var body: some View {
        VStack(spacing: 24) {
            header

            section(title: "Customize") {
                customizeRow(title: "Avatar", icon: "Head1")
                Divider()
                customizeRow(title: "Backpack", icon: "Package")
            }

            section(title: "Account") {
                resetRow
            }
        }
        .fullScreenCover(item: $activeModal) { modal in
            Group {
                switch modal {
                case .rename:     renameDialog
                case .comingSoon: comingSoonDialog
                case .reset:      resetDialog
                }
            }
            .presentationBackground(.clear)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center, spacing: 14) {
            Image("player_idle")
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(width: 92, height: 112)

            VStack(alignment: .leading, spacing: 8) {
                Button {
                    draftName = displayName
                    activeModal = .rename
                } label: {
                    HStack(spacing: 8) {
                        Text(displayName.uppercased())
                            .font(Pixel.font(24, weight: .heavy))
                            .foregroundStyle(Pixel.ink)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                        Image(systemName: "pencil")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Pixel.textMuted)
                    }
                }
                .buttonStyle(.plain)

                HStack(spacing: 8) {
                    PixelIcon(name: "Coin").frame(width: 24, height: 24)
                    Text(stepFormatted(coins))
                        .font(Pixel.font(20, weight: .heavy))
                        .foregroundStyle(Pixel.ink)
                }
            }

            Spacer(minLength: 0)
        }
    }

    // MARK: - Sections

    /// A captioned group: uppercase HUD label above a white pixel box.
    @ViewBuilder
    private func section<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            // Section header: plain label, no background/border, outside the card.
            Text(title.uppercased())
                .font(Pixel.font(11, weight: .bold))
                .foregroundStyle(Pixel.dMuted)
                .tracking(1.5)
                .padding(.leading, 2)
                .frame(maxWidth: .infinity, alignment: .leading)

            // The card: rows live inside this rounded white box only.
            VStack(spacing: 0) { content() }
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color(hex: 0xD9D9D9), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 1)
        }
    }

    private func customizeRow(title: String, icon: String) -> some View {
        Button {
            activeModal = .comingSoon
        } label: {
            HStack(spacing: 12) {
                Text(title)
                    .font(Pixel.font(16, weight: .heavy))
                    .foregroundStyle(Pixel.ink)

                Spacer()

                Image(icon)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 34, height: 34)

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Pixel.dMuted)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var resetRow: some View {
        Button {
            activeModal = .reset
        } label: {
            HStack {
                Text("Reset Account")
                    .font(Pixel.font(16, weight: .heavy))
                    .foregroundStyle(Pixel.red)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Dialogs (pixel popups)

    private var renameDialog: some View {
        modalCard(title: "RENAME COURIER", chip: Pixel.purple) {
            VStack(spacing: 14) {
                TextField("", text: $draftName)
                    .font(Pixel.font(18, weight: .heavy))
                    .foregroundStyle(Pixel.ink)
                    .multilineTextAlignment(.center)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 8).fill(.white))
                    .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Pixel.dWhiteEdge, lineWidth: 2))
                    .onChange(of: draftName) { _, newValue in
                        if newValue.count > PlayerNameRules.maxLength {
                            draftName = PlayerNameRules.limited(newValue)
                        }
                    }

                Text("MAX \(PlayerNameRules.maxLength) CHARACTERS")
                    .font(Pixel.font(10, weight: .bold))
                    .foregroundStyle(Pixel.dMuted)

                HStack(spacing: 12) {
                    dialogButton("CANCEL", fill: .white, edge: Pixel.dWhiteEdge, textColor: Pixel.ink) {
                        activeModal = nil
                    }
                    dialogButton("SAVE", fill: Pixel.dGreen, edge: Pixel.dGreenEdge, textColor: .white) {
                        saveName()
                        activeModal = nil
                    }
                }
            }
        }
    }

    private var comingSoonDialog: some View {
        modalCard(title: "COMING SOON", chip: Pixel.purple) {
            VStack(spacing: 16) {
                Text("Customization is on the way!")
                    .font(Pixel.font(13, weight: .bold))
                    .foregroundStyle(Pixel.ink)
                    .multilineTextAlignment(.center)

                dialogButton("OK", fill: Pixel.dYellow, edge: Pixel.dYellowEdge, textColor: Pixel.ink) {
                    activeModal = nil
                }
            }
        }
    }

    private var resetDialog: some View {
        modalCard(title: "RESET ACCOUNT?", chip: Pixel.red) {
            VStack(spacing: 16) {
                Text("This deletes your courier and all progress. You'll start over from the beginning.")
                    .font(Pixel.font(12, weight: .bold))
                    .foregroundStyle(Pixel.ink)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 12) {
                    dialogButton("CANCEL", fill: .white, edge: Pixel.dWhiteEdge, textColor: Pixel.ink) {
                        activeModal = nil
                    }
                    dialogButton("RESET", fill: Pixel.red, edge: Color(hex: 0x7A1F1F), textColor: .white) {
                        activeModal = nil
                        resetAccount()
                    }
                }
            }
        }
    }

    /// Scrim + centered cream frame with a colored title chip (the app's popup
    /// shell, mirroring `MissionsPopup`).
    private func modalCard<C: View>(
        title: String,
        chip: Color,
        @ViewBuilder content: () -> C
    ) -> some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture { activeModal = nil }

            VStack(spacing: 16) {
                Text(title)
                    .font(Pixel.font(16, weight: .heavy))
                    .foregroundStyle(.white)
                    .tracking(1)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: 8).fill(chip))

                content()
            }
            .padding(20)
            .frame(width: 320)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: 0xF9F8F6)))
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Pixel.dWhiteEdge, lineWidth: 2))
        }
    }

    private func dialogButton(
        _ title: String,
        fill: Color,
        edge: Color,
        textColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(Pixel.font(14, weight: .heavy))
                .foregroundStyle(textColor)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(RoundedRectangle(cornerRadius: 8).fill(fill))
                .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(edge, lineWidth: 2))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private func saveName() {
        let trimmed = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let player else { return }
        player.name = PlayerNameRules.limited(trimmed)
        try? context.save()
    }

    /// Wipes the courier and all game progress. Removing the `Player` makes
    /// `ContentView` fall back to onboarding; missions re-seed on next launch.
    private func resetAccount() {
        try? context.delete(model: Player.self)
        try? context.delete(model: CurrentDelivery.self)
        try? context.delete(model: DailyStepRecord.self)
        try? context.delete(model: Mission.self)
        try? context.save()
    }
}

/// Which pixel dialog is currently presented over the Profile page.
private enum ProfileModal: Identifiable {
    case rename, comingSoon, reset
    var id: Int {
        switch self {
        case .rename:     return 0
        case .comingSoon: return 1
        case .reset:      return 2
        }
    }
}

#Preview("Profile") {
    let container = try! ModelContainer(
        for: Player.self, Mission.self, DailyStepRecord.self, CurrentDelivery.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    container.mainContext.insert(
        Player(name: "PLAYER", gender: "male", height: 175, stepLength: 0.72, coins: 250)
    )
    return ScrollView {
        DashboardPanel(title: "PROFILE") {
            ProfileContent(playerName: "PLAYER")
        }
        .padding()
    }
    .background(Pixel.screenBackground)
    .modelContainer(container)
}
