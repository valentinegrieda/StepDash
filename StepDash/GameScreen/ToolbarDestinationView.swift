//
//  ToolbarDestinationViews.swift
//  StepDash
//
//  Created by Codex on 01/07/26.
//

import SwiftUI
import SwiftData

enum ToolbarDestination: String, Identifiable {
    case missions
    case stats
    case shop
    case profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .missions:
            return "MISSIONS"
        case .stats:
            return "STATS"
        case .shop:
            return "SHOP"
        case .profile:
            return "PROFILE"
        }
    }

    var iconName: String {
        switch self {
        case .missions:
            return "List"
        case .stats:
            return "Stat"
        case .shop:
            return "Cart"
        case .profile:
            return "Head1"
        }
    }
}

struct ToolbarDestinationPresentation: Identifiable {
    let id = UUID()
    let destination: ToolbarDestination
    let steps: Int
    let distance: Double
}

struct ToolbarDestinationView: View {
    let destination: ToolbarDestination
    let playerName: String
    let steps: Int
    let distance: Double
    var onClose: () -> Void = {}

    @Query(sort: \Mission.id) private var missions: [Mission]

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()

            DashboardPanel(title: destination.title, headerTrailing: AnyView(closeButton)) {
                VStack(spacing: 10) {
                    destinationContent
                }
            }
            .frame(maxWidth: 420)
            .padding(20)
        }
    }

    private var closeButton: some View {
        Button {
            onClose()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(Pixel.red, in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var destinationContent: some View {
        switch destination {
        case .missions:
            missionContent
        case .stats:
            statsContent
        case .shop:
            shopContent
        case .profile:
            profileContent
        }
    }

    private var missionContent: some View {
        VStack(spacing: 10) {
            if missions.isEmpty {
                toolbarRow(icon: "Map", title: "No Missions", detail: "Mission database is empty")
            } else {
                ForEach(missions, id: \.id) { mission in
                    toolbarRow(
                        icon: missionIcon(for: mission.id),
                        title: mission.title,
                        detail: "\(mission.destination) • \(String(format: "%.1f", mission.distanceKm)) km • \(mission.rewardCoins) coins"
                    )
                }
            }
        }
    }

    private func missionIcon(for id: Int) -> String {
        switch id % 3 {
        case 1:
            return "Map"
        case 2:
            return "Package"
        default:
            return "DoublePackage"
        }
    }

    private var statsContent: some View {
        VStack(spacing: 14) {
            statBlock(title: "TODAY", value: "\(steps) steps", progress: stepProgress)
            statBlock(title: "DISTANCE", value: "\(formattedDistance)m", progress: distanceProgress)
        }
    }

    private var formattedDistance: String {
        String(format: "%.2f", distance)
    }

    private var stepProgress: Double {
        min(Double(steps) / 12_000, 1)
    }

    private var distanceProgress: Double {
        min(distance / 8_000, 1)
    }

    private var shopContent: some View {
        VStack(spacing: 10) {
            toolbarRow(icon: "Shoe", title: "Speed Shoes", detail: "120 coins")
            toolbarRow(icon: "Gift", title: "Reward Box", detail: "80 coins")
            toolbarRow(icon: "Gear", title: "Courier Gear", detail: "150 coins")
        }
    }

    private var profileContent: some View {
        VStack(spacing: 12) {
            Image("Head1")
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(width: 84, height: 84)

            Text(playerName)
                .font(Pixel.font(22, weight: .heavy))
                .foregroundStyle(Pixel.ink)

            toolbarRow(icon: "Badge", title: "Courier Rank", detail: "Starter")
            toolbarRow(icon: "Coin", title: "Coins", detail: "0")
        }
    }

    private func toolbarRow(icon: String, title: String, detail: String) -> some View {
        HStack(spacing: 12) {
            Image(icon)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(width: 38, height: 38)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(Pixel.font(15, weight: .heavy))
                    .foregroundStyle(Pixel.ink)
                Text(detail)
                    .font(Pixel.font(12, weight: .bold))
                    .foregroundStyle(Pixel.textMuted)
            }

            Spacer()
        }
        .padding(12)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Pixel.panelEdge, lineWidth: 1.5))
    }

    private func statBlock(title: String, value: String, progress: Double) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(Pixel.font(12, weight: .heavy))
                    .foregroundStyle(Pixel.textMuted)
                Spacer()
                Text(value)
                    .font(Pixel.font(14, weight: .heavy))
                    .foregroundStyle(Pixel.ink)
            }

            DashboardBar(progress: progress, fill: Pixel.grass, height: 12)
        }
        .padding(12)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Pixel.panelEdge, lineWidth: 1.5))
    }
}

#Preview("Toolbar Destination") {
    ToolbarDestinationView(
        destination: .stats,
        playerName: "Valentine",
        steps: 7245,
        distance: 5120.45
    )
    .modelContainer(for: [Mission.self], inMemory: true)
}
