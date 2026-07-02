//
//  BackgroundController.swift
//  StepDash
//
//  Created by Valentine Grieda Sahuburua on 30/06/26.
//

import SpriteKit

extension GameScene {
    
    func onStepTriggered(stepCount: Int = 1) {
        guard stepCount > 0 else { return }
        
        pendingStepAnimations += stepCount
        animateNextDetectedStepIfNeeded()
    }
    
    func animateNextDetectedStepIfNeeded() {
        guard !isAnimatingDetectedStep else { return }
        
        guard pendingStepAnimations > 0 else {
            setIdle()
            return
        }
        
        isAnimatingDetectedStep = true
        pendingStepAnimations -= 1
        
        let backgroundShift = smoothBackgroundShift(totalDistance: 40, slices: 8)
        
        run(backgroundShift)
        animateDetectedStep { [weak self] in
            guard let self else { return }
            
            self.isAnimatingDetectedStep = false
            
            if self.pendingStepAnimations > 0 {
                self.animateNextDetectedStepIfNeeded()
            } else {
                self.setIdle()
            }
        }
    }
    
    func smoothBackgroundShift(totalDistance: CGFloat, slices: Int) -> SKAction {
        let safeSlices = max(slices, 1)
        let shiftPerSlice = totalDistance / CGFloat(safeSlices)
        
        let shiftActions = (0..<safeSlices).map { _ in
            SKAction.sequence([
                .wait(forDuration: 0.03),
                .run { [weak self] in
                    self?.moveBackground(distance: shiftPerSlice)
                }
            ])
        }
        
        return .sequence(shiftActions)
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
