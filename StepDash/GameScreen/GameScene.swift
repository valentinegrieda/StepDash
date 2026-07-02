import SpriteKit
import SwiftUI
import Foundation

class GameScene: SKScene {

    // MARK: - PLAYER
    let playerSprite = SKSpriteNode(imageNamed: "player_idle")

    // MARK: - MOTION
    let motion = MotionManager.shared

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
    /// Forwards each pedometer update to SwiftUI: `(todaySteps, accumulatedSteps, todayDistance)`.
    var onStepUpdate: ((Int, Int, Double) -> Void)?

    // MARK: - STATE
    var lastStepCount: Int = 0
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

        motion.onStep = { [weak self] todaySteps, accumulatedSteps in
            guard let self else { return }

            DispatchQueue.main.async {
                self.stepLabel.text = "\(todaySteps)"
                self.distance = self.stepLength * Double(todaySteps)

                self.distanceLabel.text =
                "Distance: \(String(format: "%.2f", self.distance))m"

                // 🔥 STEP EDGE DETECTION (ONLY NEW STEP TRIGGERS GAME)
                if todaySteps > self.lastStepCount {

                    self.onStepTriggered()
                }

                self.lastStepCount = todaySteps

                // Forward to SwiftUI for mission progress + daily stats.
                self.onStepUpdate?(todaySteps, accumulatedSteps, self.distance)
            }
        }

        motion.start()
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
