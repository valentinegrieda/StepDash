//
//  LabelList.swift
//  StepDash
//
//  Created by Valentine Grieda Sahuburua on 01/07/26.
//

import SpriteKit

extension GameScene {
    func setupPlayerNameLabel() {

        playerNameLabel.text = playerName
        playerNameLabel.fontSize = 16
        playerNameLabel.fontColor = .white
        playerNameLabel.horizontalAlignmentMode = .center
        playerNameLabel.verticalAlignmentMode = .bottom

        playerNameLabel.position = CGPoint(
            x: playerSprite.position.x,
            y: playerSprite.position.y + playerSprite.size.height / 2 + 12
        )
        playerNameLabel.zPosition = 100

        addChild(playerNameLabel)
    }

    func setupStepLabel() {

        stepLabel.text = "Steps: 0"
        stepLabel.fontSize = 14
        stepLabel.fontColor = .white
        stepLabel.horizontalAlignmentMode = .left
        stepLabel.verticalAlignmentMode = .top

        stepLabel.position = CGPoint(x: 20, y: size.height - 20)
        stepLabel.zPosition = 100

        addChild(stepLabel)
    }

    func setupDistanceLabel() {

        distanceLabel.text = "Distance: 0"
        distanceLabel.fontSize = 14
        distanceLabel.fontColor = .white
        distanceLabel.horizontalAlignmentMode = .left
        distanceLabel.verticalAlignmentMode = .top

        distanceLabel.position = CGPoint(x: 20, y: size.height - 40)
        distanceLabel.zPosition = 100

        addChild(distanceLabel)
    }
}
