//
//  ToolbarDestinationViews.swift
//  StepDash
//
//  Created by Codex on 01/07/26.
//

import SwiftUI
import SwiftData
import UIKit

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
                    if destination == .stats {
                        StatsView()
                    } else {
                        destinationPanel
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
    private var destinationPanel: some View {
        if destination == .shop {
            shopPanel
        } else if destination == .profile {
            profilePanel
        } else {
            DashboardPanel(title: destination.title) {
                VStack(spacing: 10) {
                    destinationContent
                }
            }
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

    // Missions now live in the Home popup (MissionsPopup). This page is unused;
    // kept as a harmless placeholder so the .missions destination still compiles.
    private var missionContent: some View {
        VStack(spacing: 10) {
            toolbarRow(icon: "List", title: "Missions", detail: "Open missions from the Home screen")
        }
    }

    // MARK: - Stats

    private var statsContent: some View {
        StatsView()
    }

    // MARK: - Shop

    private var shopPanel: some View {
        VStack(spacing: 0) {
            Text("SHOP")
                .font(Pixel.font(28, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Pixel.purple)

            VStack(spacing: 14) {
                HStack(spacing: 12) {
                    PixelIcon(name: "Package")
                        .frame(width: 38, height: 38)

                    Text("Coming Soon!")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.black)
                }

                Text("This feature is still being delivered.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.vertical, 22)
            .background(.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.black.opacity(0.08), lineWidth: 1))
        .shadow(color: .black.opacity(0.35), radius: 4, x: 0, y: 3)
    }

    private var shopContent: some View {
        shopPanel
    }

    // MARK: - Profile

    private var profileContent: some View {
        ProfileContent(playerName: playerName)
    }

    // Self-contained card (matches Stats/Shop) instead of the shared DashboardPanel.
    private var profilePanel: some View {
        VStack(spacing: 0) {
            Text("PROFILE")
                .font(Pixel.font(28, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Pixel.purple)

            ProfileContent(playerName: playerName)
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(Color(hex: 0xF9F8F6))
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.black.opacity(0.08), lineWidth: 1))
        .shadow(color: .black.opacity(0.35), radius: 4, x: 0, y: 3)
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
    .modelContainer(for: [Mission.self, MissionHistory.self, DeliveryHistory.self, Player.self, DailyStepRecord.self],
        inMemory: true)}
