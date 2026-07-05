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

    // MARK: - CITY BACKGROUND
    // `bgZoom` > 1 zooms in (buildings larger). Tune to taste.
    func setupBackground() {
        // Show the full background image at a fixed height from the top (no zoom);
        // width follows the image's natural aspect. Brick fills everything below.
        let bgHeight: CGFloat = 500
        let aspect = background1.size.width / max(background1.size.height, 1)
        let bgWidth = bgHeight * aspect
//        let bgZoom: CGFloat = 1.2

        for bg in [background1, background2] {
            bg.size = CGSize(width: bgWidth, height: bgHeight)
            bg.anchorPoint = CGPoint(x: 0, y: 1)
            bg.zPosition = -1
        }

        background1.position = CGPoint(x: 0, y: size.height)
        background2.position = CGPoint(x: bgWidth, y: size.height)

        addChild(background1)
        addChild(background2)
    }

    // MARK: - BRICK ROAD (bottom strip, scrolls with the city)
    func setupBrick() {
        // Brick sits directly under the city background (no gap), filling from
        // the background's bottom edge down to the bottom of the screen. Uses the
        // same tile width as the background so they scroll together as one.
        let bgBottom = size.height - background1.size.height
        guard bgBottom > 0 else { return }

        let brickWidth = background1.size.width

        for brick in [brick1, brick2] {
            brick.size = CGSize(width: brickWidth, height: bgBottom)
            brick.anchorPoint = CGPoint(x: 0, y: 0)
            brick.zPosition = -1
        }

        brick1.position = CGPoint(x: 0, y: 0)
        brick2.position = CGPoint(x: brickWidth, y: 0)

        addChild(brick1)
        addChild(brick2)
    }

    // MARK: - SCROLL (city + brick move together)
    func moveBackground(distance: CGFloat = 40) {
        wrapPair(background1, background2, distance: distance)
        wrapPair(brick1, brick2, distance: distance)
    }

    private func wrapPair(_ a: SKSpriteNode, _ b: SKSpriteNode, distance: CGFloat) {
        a.position.x -= distance
        b.position.x -= distance

        let width = a.size.width

        if a.position.x <= -width {
            a.position.x = b.position.x + width
        }
        if b.position.x <= -width {
            b.position.x = a.position.x + width
        }
    }
}
