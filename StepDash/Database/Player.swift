import Foundation
import SwiftData

enum PlayerNameRules {
    static let maxLength = 10

    static func limited(_ name: String) -> String {
        String(name.prefix(maxLength))
    }
}

@Model
final class Player {
    var name: String
    var gender: String
    var height: Int
    var stepLength: Double
    var coins: Int = 0
    var xp: Int = 0

    init(name: String, gender: String, height: Int, stepLength: Double, coins: Int = 0, xp: Int = 0) {
        self.name = name
        self.gender = gender
        self.height = height
        self.stepLength = stepLength
        self.coins = coins
        self.xp = xp
    }
}
