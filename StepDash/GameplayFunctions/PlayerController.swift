//
//  PlayerMovement.swift
//  StepDash
//
//  Created by Valentine Grieda Sahuburua on 30/06/26.
//
import SpriteKit

extension GameScene {
    
    
    // MARK: - PLAYER
    func setupPlayer() {

        playerSprite.position = CGPoint(
            x: size.width / 2,
            y: size.height / 2 - 50
        )

        playerSprite.zPosition = 10

        addChild(playerSprite)
    }

    // MARK: - IDLE
    func setIdle() {
        playerSprite.texture = SKTexture(imageNamed: "player_idle")
        playerSprite.removeAllActions()
    }

    // MARK: - WALK PULSE (KEY LOGIC)
    func runWalkPulse() {

        playerSprite.removeAllActions()

        let frames = [
            SKTexture(imageNamed: "player_walk1"),
            SKTexture(imageNamed: "player_walk2")
        ]

        let animate = SKAction.animate(with: frames, timePerFrame: 0.15)

        let once = SKAction.sequence([
            animate,
            SKAction.run { [weak self] in
                self?.setIdle()
            }
        ])

        playerSprite.run(once)
    }
    
}
