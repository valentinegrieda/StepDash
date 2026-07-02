import SpriteKit
import UIKit

final class GameSKView: SKView {

    private var presented = false

    let playerName: String
    let stepLength: Double
    var onToolbarItemSelected: ((String, Int, Double) -> Void)?
    var onStepUpdate: ((Int, Int, Double) -> Void)?

        init(
            playerName: String,
            stepLength: Double,
            onToolbarItemSelected: ((String, Int, Double) -> Void)? = nil,
            onStepUpdate: ((Int, Int, Double) -> Void)? = nil
        ) {
            self.playerName = playerName
            self.stepLength = stepLength
            self.onToolbarItemSelected = onToolbarItemSelected
            self.onStepUpdate = onStepUpdate
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
        scene.onToolbarItemSelected = onToolbarItemSelected
        scene.onStepUpdate = onStepUpdate
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

    func updateToolbarHandler(_ handler: ((String, Int, Double) -> Void)?) {
        onToolbarItemSelected = handler
        (scene as? GameScene)?.onToolbarItemSelected = handler
    }

    func updateStepHandler(_ handler: ((Int, Int, Double) -> Void)?) {
        onStepUpdate = handler
        (scene as? GameScene)?.onStepUpdate = handler
    }
}
