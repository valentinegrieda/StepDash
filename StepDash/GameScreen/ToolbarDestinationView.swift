//
//  ToolbarDestinationViews.swift
//  StepDash
//
//  Created by Codex on 01/07/26.
//

import SwiftUI
import SwiftData
import UIKit

struct ToolbarDestinationPresentation: Identifiable {
    let id = UUID()
    let destination: ToolbarDestination
    let steps: Int
    let distance: Double
}

struct ToolbarDestinationView: View {
    let destination: ToolbarDestination
    let selectedDestination: ToolbarDestination
    let playerName: String
    /// Today's raw steps (resets at midnight).
    let steps: Int
    /// Today's distance in meters.
    let distance: Double
    /// Monotonic step count used for weekly-delivery progress.
    var accumulatedSteps: Int = 0
    var stepLength: Double = 0.7
    var onSelect: (ToolbarDestination) -> Void = { _ in }
    var onMissionAccepted: () -> Void = {}

    @Environment(\.modelContext) private var context
    @Query(sort: \Mission.id) private var missions: [Mission]
    @Query private var players: [Player]

    var body: some View {
        ZStack {
            ScrollingBackground(imageName: "bg", speed: 22)
                .ignoresSafeArea()
            Pixel.ink.opacity(0.18).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    DashboardPanel(title: destination.title) {
                        VStack(spacing: 10) {
                            destinationContent
                        }
                    }
                }
                .frame(maxWidth: TopSummaryMetrics.maxContentWidth)
                .padding(.horizontal, TopSummaryMetrics.horizontalPadding)
                .padding(.top, TopSummaryMetrics.topPadding)
                .padding(.bottom, 110)
            }

            VStack {
                Spacer()
                GameBottomToolbar(selected: selectedDestination, onSelect: onSelect)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }

    @ViewBuilder
    private var destinationContent: some View {
        switch destination {
        case .home:
            EmptyView()
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

    // MARK: - Missions

    private var missionContent: some View {
        VStack(spacing: 10) {
            if missions.isEmpty {
                toolbarRow(icon: "Map", title: "No Missions", detail: "Mission database is empty")
            } else {
                ForEach(missions, id: \.id) { mission in
                    missionRow(mission)
                }
            }
        }
    }

    @ViewBuilder
    private func missionRow(_ mission: Mission) -> some View {
        let progress = mission.progress(todaySteps: steps, accumulatedSteps: accumulatedSteps, stepLength: stepLength)

        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Image(missionIcon(for: mission.id))
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 38, height: 38)

                VStack(alignment: .leading, spacing: 3) {
                    Text(mission.title)
                        .font(Pixel.font(15, weight: .heavy))
                        .foregroundStyle(Pixel.ink)
                    Text("\(mission.destination) • \(mission.goalDescription)")
                        .font(Pixel.font(11, weight: .bold))
                        .foregroundStyle(Pixel.textMuted)
                }

                Spacer()
                categoryBadge(mission.category)
            }

            if mission.isCompleted {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(Pixel.grass)
                    Text("DELIVERED")
                        .font(Pixel.font(12, weight: .heavy))
                        .foregroundStyle(Pixel.grass)
                    Spacer()
                    rewardText(mission)
                }
            } else if mission.isAccepted {
                DashboardBar(progress: progress, fill: Pixel.gem, height: 10)
                HStack {
                    Text(mission.progressDescription(todaySteps: steps, accumulatedSteps: accumulatedSteps, stepLength: stepLength))
                        .font(Pixel.font(11, weight: .bold))
                        .foregroundStyle(Pixel.textMuted)
                    Spacer()
                    rewardText(mission)
                }
            } else {
                HStack {
                    rewardText(mission)
                    Spacer()
                }
                Button("ACCEPT DELIVERY") {
                    mission.accept(now: Date(), accumulatedSteps: accumulatedSteps)
                    try? context.save()
                }
                .buttonStyle(PixelButtonStyle(fill: Pixel.grass))
            }
        }
        .padding(12)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Pixel.panelEdge, lineWidth: 1.5))
    }

    private func categoryBadge(_ category: MissionCategory) -> some View {
        Text(category == .daily ? "DAILY" : "WEEKLY")
            .font(Pixel.font(10, weight: .heavy))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Capsule().fill(category == .daily ? Pixel.purple : Pixel.gem))
    }

    private func rewardText(_ mission: Mission) -> some View {
        HStack(spacing: 8) {
            Label("\(mission.rewardCoins)", systemImage: "dollarsign.circle.fill")
                .foregroundStyle(Pixel.coin)
            Label("\(mission.rewardXP)", systemImage: "star.fill")
                .foregroundStyle(Pixel.purple)
        }
        .font(Pixel.font(12, weight: .heavy))
        .labelStyle(.titleAndIcon)
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

    // MARK: - Stats

    private var statsContent: some View {
        let totals = DailyStepRecord.lifetimeTotals(context: context)

        return VStack(spacing: 14) {
            statBlock(title: "TODAY", value: "\(steps) steps", progress: stepProgress)
            statBlock(title: "DISTANCE", value: "\(formattedDistance)m", progress: distanceProgress)

            InsetCard {
                totalRow(title: "TOTAL STEPS", value: "\(totals.steps)")
                Divider()
                totalRow(title: "TOTAL DISTANCE", value: String(format: "%.0f m", totals.distance))
                Divider()
                totalRow(title: "DELIVERIES DONE", value: "\(totals.deliveries)")
            }
        }
    }

    private func totalRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(Pixel.font(12, weight: .heavy))
                .foregroundStyle(Pixel.textMuted)
            Spacer()
            Text(value)
                .font(Pixel.font(14, weight: .heavy))
                .foregroundStyle(Pixel.ink)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
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

    // MARK: - Shop

    private var shopContent: some View {
        VStack(spacing: 10) {
            toolbarRow(icon: "Shoe", title: "Speed Shoes", detail: "120 coins")
            toolbarRow(icon: "Gift", title: "Reward Box", detail: "80 coins")
            toolbarRow(icon: "Gear", title: "Courier Gear", detail: "150 coins")
        }
    }

    // MARK: - Profile

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
            toolbarRow(icon: "Coin", title: "Coins", detail: "\(players.first?.coins ?? 0)")
            toolbarRow(icon: "Stat", title: "XP", detail: "\(players.first?.xp ?? 0)")
        }
    }

    // MARK: - Shared

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
                    .lineLimit(2)
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
        selectedDestination: .stats,
        playerName: "Valentine",
        steps: 7245,
        distance: 5120.45,
        accumulatedSteps: 7245,
        stepLength: 0.7
    )
    .modelContainer(for: [Mission.self, Player.self, DailyStepRecord.self], inMemory: true)
}
