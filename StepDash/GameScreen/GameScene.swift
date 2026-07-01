import SpriteKit
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

    // MARK: - CONFIG
    var playerName: String
    var stepLength: Double
    var distance: Double = 0

    // MARK: - STATE
    var lastStepCount: Int = 0

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

        motion.onStep = { [weak self] totalSteps in
            guard let self else { return }
            
            DispatchQueue.main.async {
                
                self.stepLabel.text = "Steps: \(totalSteps)"
                
                self.distance = self.stepLength * Double(totalSteps)
                
                self.distanceLabel.text =
                "Distance: \(String(format: "%.2f", self.distance))m"
                
                // 🔥 STEP EDGE DETECTION (ONLY NEW STEP TRIGGERS GAME)
                if totalSteps > self.lastStepCount {
                    
                    self.onStepTriggered()
                }
                
                self.lastStepCount = totalSteps
            }
        }

        motion.start()
    }

    

    

    // MARK: - LABELS
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

    // MARK: - DEBUG
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        moveBackground(distance: 40)
    }
}
