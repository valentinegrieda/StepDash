import SpriteKit
import SwiftUI
import Foundation
import UIKit

class GameScene: SKScene {

    // MARK: - PLAYER
    let playerSprite = SKSpriteNode(imageNamed: "player_idle")

    // MARK: - MOTION
    let motion = MotionManager.shared
    /// Token for this scene's visual-only step subscription; removed on teardown.
    private var motionToken: UUID?

    // MARK: - BACKGROUND
    let background1 = SKSpriteNode(imageNamed: "bg")
    let background2 = SKSpriteNode(imageNamed: "bg")
    // Brick strip under the city background (scrolls with it).
    let brick1 = SKSpriteNode(imageNamed: "Brick")
    let brick2 = SKSpriteNode(imageNamed: "Brick")

    // MARK: - UI
    let playerNameLabel = SKLabelNode(fontNamed: UIFont.systemFont(ofSize: 17, weight: .bold).fontName)
    let stepLabel  = SKLabelNode(fontNamed: UIFont.systemFont(ofSize: 17, weight: .bold).fontName)
    let distanceLabel = SKLabelNode(fontNamed: UIFont.systemFont(ofSize: 17, weight: .bold).fontName)
    let bottomToolbar = SKNode()

    // MARK: - CONFIG
    var playerName: String
    var stepLength: Double
    var distance: Double = 0

    // MARK: - STATE
    var lastStepCount: Int = 0
    var hasReceivedInitialStepCount = false
    var pendingStepAnimations = 0
    var isAnimatingDetectedStep = false
    var nextStepStartsWithLeadingLeftFoot = true

    // MARK: - INIT
    init(size: CGSize, playerName: String, stepLength: Double) {
        self.playerName = playerName
        self.stepLength = stepLength
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        if let motionToken {
            motion.removeHandler(motionToken)
        }
    }

    // MARK: - DID MOVE
    override func didMove(to view: SKView) {

        anchorPoint = CGPoint(x: 0, y: 0)

        setupBackground()
        setupBrick()
        setupPlayer()
        setIdle()

        // Visual-only subscription: the labels + walk animation react to steps
        // while the scene is on screen. The data pipeline (stats + missions) is
        // owned by the shell's GameSession, so it keeps running when this scene
        // is gone. Motion is started by the shell, not here.
        motionToken = motion.addHandler { [weak self] todaySteps, _ in
            guard let self else { return }

            DispatchQueue.main.async {
                // First real reading just seeds the baseline — don't animate the
                // (possibly large) jump from 0 to today's already-walked total.
                if !self.hasReceivedInitialStepCount {
                    self.lastStepCount = todaySteps
                    self.hasReceivedInitialStepCount = true
                    return
                }

                // Animate one walk cycle per newly detected step.
                let detectedNewSteps = todaySteps - self.lastStepCount

                if detectedNewSteps > 0 {
                    self.onStepTriggered(stepCount: detectedNewSteps)
                }

                self.lastStepCount = todaySteps
            }
        }
    }

    // MARK: - DEBUG (tap scrolls the world one step)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        onStepTriggered()
    }
}

#Preview {
    let scene = GameScene(
        size: CGSize(width: 393, height: 480),
        playerName: "Valentine",
        stepLength: 0.7
    )
    scene.scaleMode = .resizeFill

    return SpriteView(scene: scene)
        .frame(width: 393, height: 480)
        .ignoresSafeArea()
}
