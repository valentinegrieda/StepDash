//
//  ToolbarController.swift
//  StepDash
//
//  Created by Codex on 01/07/26.
//

import SpriteKit

extension GameScene {
    private struct ToolbarItem {
        let id: String
        let iconAsset: String
        let title: String
    }

    private var toolbarItems: [ToolbarItem] {
        [
            ToolbarItem(id: "home", iconAsset: "Home", title: "HOME"),
            ToolbarItem(id: "missions", iconAsset: "List", title: "MISSIONS"),
            ToolbarItem(id: "stats", iconAsset: "Stat", title: "STATS"),
            ToolbarItem(id: "shop", iconAsset: "Cart", title: "SHOP"),
            ToolbarItem(id: "profile", iconAsset: "Head1", title: "PROFILE")
        ]
    }

    func setupBottomToolbar() {
        bottomToolbar.removeAllChildren()
        bottomToolbar.name = "bottomToolbar"
        bottomToolbar.zPosition = 250

        let safeBottom = view?.safeAreaInsets.bottom ?? 0
        let horizontalPadding: CGFloat = 16
        let toolbarHeight: CGFloat = 82
        let toolbarWidth = min(size.width - horizontalPadding * 2, 560)
        let toolbarY = safeBottom + toolbarHeight / 2 + 14

        bottomToolbar.position = CGPoint(x: size.width / 2, y: toolbarY)

        let background = SKShapeNode(
            rectOf: CGSize(width: toolbarWidth, height: toolbarHeight),
            cornerRadius: 18
        )
        background.fillColor = SKColor(red: 0.05, green: 0.16, blue: 0.25, alpha: 0.92)
        background.strokeColor = SKColor(red: 0.12, green: 0.28, blue: 0.40, alpha: 1)
        background.lineWidth = 2
        background.name = "bottomToolbarBackground"
        background.zPosition = 0
        bottomToolbar.addChild(background)

        let itemWidth = toolbarWidth / CGFloat(toolbarItems.count)
        let startX = -toolbarWidth / 2 + itemWidth / 2

        for (index, item) in toolbarItems.enumerated() {
            let isSelected = item.id == activeToolbarItemID
            let button = makeToolbarButton(
                item: item,
                isSelected: isSelected,
                size: CGSize(width: itemWidth - 8, height: toolbarHeight - 18)
            )

            button.position = CGPoint(
                x: startX + CGFloat(index) * itemWidth,
                y: 0
            )
            bottomToolbar.addChild(button)
        }

        if bottomToolbar.parent == nil {
            addChild(bottomToolbar)
        }
    }

    private func makeToolbarButton(item: ToolbarItem, isSelected: Bool, size: CGSize) -> SKNode {
        let button = SKNode()
        button.name = "toolbar_\(item.id)"
        button.zPosition = 1

        if isSelected {
            let activeBackground = SKShapeNode(rectOf: size, cornerRadius: 14)
            activeBackground.fillColor = SKColor(red: 0.11, green: 0.28, blue: 0.39, alpha: 1)
            activeBackground.strokeColor = SKColor(red: 0.18, green: 0.38, blue: 0.52, alpha: 1)
            activeBackground.lineWidth = 2
            activeBackground.name = button.name
            activeBackground.zPosition = -1
            button.addChild(activeBackground)
        }

        let iconNode = SKSpriteNode(imageNamed: item.iconAsset)
        iconNode.size = fittedIconSize(for: iconNode.texture, maxSide: isSelected ? 36 : 32)
        iconNode.position = CGPoint(x: 0, y: 10)
        iconNode.name = button.name
        iconNode.zPosition = 1
        button.addChild(iconNode)

        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        titleLabel.text = item.title
        titleLabel.fontSize = 12
        titleLabel.fontColor = isSelected ? .yellow : .white
        titleLabel.verticalAlignmentMode = .center
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.position = CGPoint(x: 0, y: -16)
        titleLabel.name = button.name
        button.addChild(titleLabel)

        return button
    }

    private func fittedIconSize(for texture: SKTexture?, maxSide: CGFloat) -> CGSize {
        guard let texture else {
            return CGSize(width: maxSide, height: maxSide)
        }

        let textureSize = texture.size()
        let largestSide = max(textureSize.width, textureSize.height)
        guard largestSide > 0 else {
            return CGSize(width: maxSide, height: maxSide)
        }

        let scale = maxSide / largestSide
        return CGSize(
            width: textureSize.width * scale,
            height: textureSize.height * scale
        )
    }

    func handleToolbarTouch(_ touches: Set<UITouch>) -> Bool {
        guard let touch = touches.first else { return false }

        let location = touch.location(in: self)
        let tappedNode = atPoint(location)

        guard let nodeName = tappedNode.name,
              nodeName.hasPrefix("toolbar_") else {
            return false
        }

        let itemId = String(nodeName.dropFirst("toolbar_".count))
        activeToolbarItemID = itemId
        setupBottomToolbar()

        print("Toolbar tapped:", itemId)
        onToolbarItemSelected?(itemId, lastStepCount, distance)
        return true
    }
}
