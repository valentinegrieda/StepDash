import Foundation
import SwiftData

@Model
final class Player {
    var name: String
    var gender: String
    var height: Int
    var stepLength: Double

    init(name: String, gender: String, height: Int, stepLength: Double) {
        self.name = name
        self.gender = gender
        self.height = height
        self.stepLength = stepLength
        
    }
}
