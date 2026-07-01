//
//  BackgroundController.swift
//  StepDash
//
//  Created by Valentine Grieda Sahuburua on 30/06/26.
//

import SpriteKit

extension GameScene {
    
    func onStepTriggered() {

            // move background ONLY on step
            moveBackground(distance: 40)

            // play 1x animation pulse
            runWalkPulse()
        }
    // MARK: - BACKGROUND
    func setupBackground() {

        let bgWidth = background1.size.width

        background1.anchorPoint = CGPoint(x: 0, y: 1)
        background2.anchorPoint = CGPoint(x: 0, y: 1)

        background1.position = CGPoint(x: 0, y: size.height)
        background2.position = CGPoint(x: bgWidth, y: size.height)

        background1.zPosition = -1
        background2.zPosition = -1

        addChild(background1)
        addChild(background2)
    }

    func moveBackground(distance: CGFloat = 40) {

        background1.position.x -= distance
        background2.position.x -= distance

        let bgWidth = background1.size.width

        if background1.position.x <= -bgWidth {
            background1.position.x = background2.position.x + bgWidth
        }

        if background2.position.x <= -bgWidth {
            background2.position.x = background1.position.x + bgWidth
        }
    }
}
