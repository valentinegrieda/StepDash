import Foundation
import SwiftData

@Model
final class DeliveryHistory {
    var id: UUID
    var recipient: String
    var goalSteps: Int
    var rewardCoins: Int
    var claimedAt: Date

    init(
        id: UUID = UUID(),
        recipient: String,
        goalSteps: Int,
        rewardCoins: Int,
        claimedAt: Date = Date()
    ) {
        self.id = id
        self.recipient = recipient
        self.goalSteps = goalSteps
        self.rewardCoins = rewardCoins
        self.claimedAt = claimedAt
    }

    convenience init(delivery: CurrentDelivery, claimedAt: Date = Date()) {
        self.init(
            recipient: delivery.recipient,
            goalSteps: delivery.goalSteps,
            rewardCoins: delivery.rewardCoins,
            claimedAt: claimedAt
        )
    }
}
