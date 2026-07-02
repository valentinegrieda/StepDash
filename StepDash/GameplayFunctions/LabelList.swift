//
//  LabelList.swift
//  StepDash
//
//  Created by Valentine Grieda Sahuburua on 01/07/26.
//

import SpriteKit

extension GameScene {
    func setupPlayerNameLabel() {
        let safeTop = view?.safeAreaInsets.top ?? 0
        let availableWidth = max(size.width - TopSummaryMetrics.horizontalPadding * 2, 0)
        let playerCardWidth = TopSummaryMetrics.playerCardWidth(for: availableWidth)
        let cardY = size.height - safeTop - TopSummaryMetrics.topPadding - TopSummaryMetrics.cardHeight / 2

        let playerCard = SKShapeNode(
            rectOf: CGSize(width: playerCardWidth, height: TopSummaryMetrics.cardHeight),
            cornerRadius: TopSummaryMetrics.cornerRadius
        )
        playerCard.fillColor = SKColor(red: 0.05, green: 0.16, blue: 0.25, alpha: 0.96)
        playerCard.strokeColor = SKColor.white.withAlphaComponent(0.12)
        playerCard.lineWidth = 1
        playerCard.position = CGPoint(
            x: TopSummaryMetrics.horizontalPadding + playerCardWidth / 2,
            y: cardY
        )
        playerCard.zPosition = 100
        playerCard.name = "playerSummaryCard"

        let playerIcon = SKSpriteNode(imageNamed: GameUIConfig.playerIconName)
        playerIcon.size = CGSize(
            width: TopSummaryMetrics.iconSide,
            height: TopSummaryMetrics.iconSide
        )
        playerIcon.position = CGPoint(x: -playerCardWidth / 2 + 29, y: 0)
        playerIcon.zPosition = 1
        playerCard.addChild(playerIcon)

        playerNameLabel.text = playerName
        playerNameLabel.fontSize = TopSummaryMetrics.playerTextSize
        playerNameLabel.fontColor = .white
        playerNameLabel.horizontalAlignmentMode = .left
        playerNameLabel.verticalAlignmentMode = .center
        playerNameLabel.position = CGPoint(x: -playerCardWidth / 2 + 58, y: 0)
        playerNameLabel.zPosition = 1

        playerCard.addChild(playerNameLabel)
        addChild(playerCard)
    }

    func setupStepLabel() {
        let safeTop = view?.safeAreaInsets.top ?? 0
        let availableWidth = max(size.width - TopSummaryMetrics.horizontalPadding * 2, 0)
        let playerCardWidth = TopSummaryMetrics.playerCardWidth(for: availableWidth)
        let stepCardWidth = TopSummaryMetrics.stepCardWidth(for: availableWidth)
        let cardY = size.height - safeTop - TopSummaryMetrics.topPadding - TopSummaryMetrics.cardHeight / 2

        let stepCard = SKShapeNode(
            rectOf: CGSize(width: stepCardWidth, height: TopSummaryMetrics.cardHeight),
            cornerRadius: TopSummaryMetrics.cornerRadius
        )
        stepCard.fillColor = .white
        stepCard.strokeColor = SKColor(red: 0.82, green: 0.82, blue: 0.82, alpha: 1)
        stepCard.lineWidth = 1.5
        stepCard.position = CGPoint(
            x: TopSummaryMetrics.horizontalPadding + playerCardWidth + TopSummaryMetrics.gap + stepCardWidth / 2,
            y: cardY
        )
        stepCard.zPosition = 100
        stepCard.name = "stepSummaryCard"

        let shoeIcon = SKSpriteNode(imageNamed: GameUIConfig.stepsIconName)
        shoeIcon.size = CGSize(
            width: TopSummaryMetrics.iconSide,
            height: TopSummaryMetrics.iconSide
        )
        shoeIcon.position = CGPoint(x: -stepCardWidth / 2 + 30, y: 0)
        shoeIcon.zPosition = 1
        stepCard.addChild(shoeIcon)

        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = GameUIConfig.stepsTitle
        titleLabel.fontSize = TopSummaryMetrics.stepsTitleSize
        titleLabel.fontColor = SKColor(red: 0.32, green: 0.35, blue: 0.39, alpha: 1)
        titleLabel.horizontalAlignmentMode = .left
        titleLabel.verticalAlignmentMode = .center
        titleLabel.position = CGPoint(x: -stepCardWidth / 2 + 62, y: 11)
        titleLabel.zPosition = 1
        stepCard.addChild(titleLabel)

        stepLabel.text = "0"
        stepLabel.fontSize = TopSummaryMetrics.stepsValueSize
        stepLabel.fontColor = SKColor(red: 0.11, green: 0.13, blue: 0.16, alpha: 1)
        stepLabel.horizontalAlignmentMode = .left
        stepLabel.verticalAlignmentMode = .center

        stepLabel.position = CGPoint(x: -stepCardWidth / 2 + 62, y: -11)
        stepLabel.zPosition = 1

        stepCard.addChild(stepLabel)
        addChild(stepCard)
    }

    func setupDistanceLabel() {

        distanceLabel.text = "Distance: 0"
        distanceLabel.fontSize = 14
        distanceLabel.fontColor = .white
        distanceLabel.horizontalAlignmentMode = .left
        distanceLabel.verticalAlignmentMode = .top

        distanceLabel.position = CGPoint(x: 20, y: size.height - (view?.safeAreaInsets.top ?? 0) - 100)
        distanceLabel.zPosition = 100

        addChild(distanceLabel)
    }
}
