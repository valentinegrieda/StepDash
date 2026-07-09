import SpriteKit
import UIKit

final class GameSKView: SKView {

    private var presented = false

    let playerName: String
    let stepLength: Double

    init(
        playerName: String,
        stepLength: Double
    ) {
        self.playerName = playerName
        self.stepLength = stepLength
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard !presented, bounds.size != .zero else { return }

        let scene = GameScene(
            size: bounds.size,
            playerName: playerName,
            stepLength: stepLength
        )
        scene.scaleMode = .resizeFill

        presentScene(scene)
        presented = true

        becomeFirstResponder()
    }

    override var keyCommands: [UIKeyCommand]? {
        [
            UIKeyCommand(
                input: "k",
                modifierFlags: [],
                action: #selector(moveBackground)
            )
        ]
    }

    @objc private func moveBackground() {
        (scene as? GameScene)?.moveBackground()
    }
}
