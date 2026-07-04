import SpriteKit
import SwiftUI
import Foundation

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

    // MARK: - UI
    let playerNameLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    let stepLabel  = SKLabelNode(fontNamed: "AvenirNext-Bold")
    let distanceLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    let bottomToolbar = SKNode()

    // MARK: - CONFIG
    var playerName: String
    var stepLength: Double
    var distance: Double = 0
    var onToolbarItemSelected: ((String, Int, Double) -> Void)?

    // MARK: - STATE
    var lastStepCount: Int = 0
    var hasReceivedInitialStepCount = false
    var pendingStepAnimations = 0
    var isAnimatingDetectedStep = false
    var nextStepStartsWithLeadingLeftFoot = true
    var activeToolbarItemID: String = "home"

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
        setupPlayer()
        setupPlayerNameLabel()
        setIdle()
        setupStepLabel()
        setupDistanceLabel()
        setupBottomToolbar()

        // Visual-only subscription: the labels + walk animation react to steps
        // while the scene is on screen. The data pipeline (stats + missions) is
        // owned by the shell's GameSession, so it keeps running when this scene
        // is gone. Motion is started by the shell, not here.
        motionToken = motion.addHandler { [weak self] todaySteps, _ in
            guard let self else { return }

            DispatchQueue.main.async {
                self.stepLabel.text = "\(todaySteps)"
                self.distance = self.stepLength * Double(todaySteps)

                self.distanceLabel.text =
                "Distance: \(String(format: "%.2f", self.distance))m"

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


    // MARK: - DEBUG
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if handleToolbarTouch(touches) {
            return
        }

        moveBackground(distance: 40)
    }
}

#Preview {
    let scene = GameScene(
        size: CGSize(width: 393, height: 852),
        playerName: "Valentine",
        stepLength: 0.7
    )
    scene.scaleMode = .resizeFill

    return SpriteView(scene: scene)
        .frame(width: 393, height: 852)
        .ignoresSafeArea()
}
