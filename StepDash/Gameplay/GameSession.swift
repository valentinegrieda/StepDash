import Foundation
import Observation

/// Owns the always-on step feed for a play session.
///
/// This lives on the persistent shell (`GameContainerView`) rather than inside
/// the SpriteKit scene, so step data keeps flowing no matter which page is on
/// screen. Previously the pipeline was wired through the game scene, which is
/// torn down whenever you navigate to Stats/Shop/Profile/Missions — freezing
/// step recording and mission completion until you returned Home. Subscribing
/// here decouples the data from the scene's lifecycle.
@Observable
final class GameSession {

    private(set) var todaySteps: Int = 0
    private(set) var accumulatedSteps: Int = 0

    @ObservationIgnored private var token: UUID?

    /// Begins (or resumes) the step feed. Idempotent.
    func start() {
        guard token == nil else { return }

        token = MotionManager.shared.addHandler { [weak self] today, accumulated in
            self?.todaySteps = today
            self?.accumulatedSteps = accumulated
        }

        MotionManager.shared.start()
    }

    deinit {
        if let token {
            MotionManager.shared.removeHandler(token)
        }
    }
}
