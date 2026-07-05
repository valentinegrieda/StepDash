//
//  GameUIConfig.swift
//  StepDash
//
//  Created by Codex on 02/07/26.
//

import CoreGraphics

enum ToolbarDestination: String, Identifiable {
    case home
    case missions
    case stats
    case shop
    case profile

    var id: String { rawValue }

    static var toolbarItems: [ToolbarDestination] {
        GameUIConfig.toolbarItems.map(\.destination)
    }

    var title: String {
        GameUIConfig.item(for: self)?.title ?? rawValue.uppercased()
    }

    var iconName: String {
        GameUIConfig.item(for: self)?.iconName ?? "Home"
    }
}

struct GameToolbarItem: Identifiable {
    let destination: ToolbarDestination
    let iconName: String
    let title: String

    var id: String { destination.rawValue }
}

enum GameUIConfig {
    static let playerIconName = "Head1"
    static let stepsIconName = "Shoe"
    static let stepsTitle = "TODAY'S STEPS"

    static let toolbarItems: [GameToolbarItem] = [
        GameToolbarItem(destination: .home, iconName: "Home", title: "HOME"),
        GameToolbarItem(destination: .stats, iconName: "Stat", title: "STATS"),
        GameToolbarItem(destination: .shop, iconName: "Cart", title: "SHOP"),
        GameToolbarItem(destination: .profile, iconName: "Head1", title: "PROFILE")
    ]

    static func item(for destination: ToolbarDestination) -> GameToolbarItem? {
        toolbarItems.first { $0.destination == destination }
    }
}

enum TopSummaryMetrics {
    static let horizontalPadding: CGFloat = 20
    static let topPadding: CGFloat = 18
    static let gap: CGFloat = 12
    static let cardHeight: CGFloat = 70
    static let cornerRadius: CGFloat = 10
    static let iconSide: CGFloat = 34
    static let playerTextSize: CGFloat = 14
    static let stepsTitleSize: CGFloat = 9
    static let stepsValueSize: CGFloat = 20
    static let contentPadding: CGFloat = 12
    static let playerCardRatio: CGFloat = 0.42
    static let minPlayerCardWidth: CGFloat = 128
    static let maxPlayerCardWidth: CGFloat = 190
    static let maxContentWidth: CGFloat = 520

    static func playerCardWidth(for availableWidth: CGFloat) -> CGFloat {
        min(
            max((availableWidth - gap) * playerCardRatio, minPlayerCardWidth),
            maxPlayerCardWidth
        )
    }

    static func stepCardWidth(for availableWidth: CGFloat) -> CGFloat {
        availableWidth - playerCardWidth(for: availableWidth) - gap
    }
}

enum ToolbarMetrics {
    static let horizontalPadding: CGFloat = 16
    static let bottomPadding: CGFloat = 14
    static let toolbarHeight: CGFloat = 82
    static let maxToolbarWidth: CGFloat = 560
    static let itemHorizontalInset: CGFloat = 4
    static let verticalPadding: CGFloat = 9
    static let buttonHeight: CGFloat = 64
    static let selectedIconSide: CGFloat = 36
    static let iconSide: CGFloat = 32
    static let iconFrameHeight: CGFloat = 36
    static let titleHeight: CGFloat = 18
    static let titleFontSize: CGFloat = 12
    static let cornerRadius: CGFloat = 8
    static let activeCornerRadius: CGFloat = 8
}
