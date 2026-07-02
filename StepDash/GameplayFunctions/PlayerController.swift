//
//  PlayerMovement.swift
//  StepDash
//
//  Created by Valentine Grieda Sahuburua on 30/06/26.
//
import SpriteKit

extension GameScene {
    var idleTexture: SKTexture {
        SKTexture(imageNamed: "player_idle")
    }
    
    var walkFrameOne: SKTexture {
        SKTexture(imageNamed: "player_walk1")
    }
    
    var walkFrameTwo: SKTexture {
        SKTexture(imageNamed: "player_walk2")
    }
    
    func texturesForNextDetectedStep() -> [SKTexture] {
        if nextStepStartsWithLeadingLeftFoot {
            return [walkFrameOne, walkFrameTwo]
        }
        
        return [walkFrameTwo, walkFrameOne]
    }
    
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
        playerSprite.removeAllActions()
        playerSprite.texture = idleTexture
    }

    func animateDetectedStep(completion: @escaping () -> Void) {
        let stepTextures = texturesForNextDetectedStep()
        
        let textureAnimation = SKAction.animate(
            with: stepTextures,
            timePerFrame: 0.05,
            resize: false,
            restore: false
        )
        
        let bodySway = SKAction.sequence([
            .moveBy(x: 5, y: 0, duration: 0.12),
            .moveBy(x: -5, y: 0, duration: 0.12)
        ])
        
        let stepAnimation = SKAction.group([
            textureAnimation,
            bodySway
        ])
        
        let finishStep = SKAction.run { [weak self] in
            self?.nextStepStartsWithLeadingLeftFoot.toggle()
            completion()
        }
        
        playerSprite.run(.sequence([stepAnimation, finishStep]))
    }
    
}
