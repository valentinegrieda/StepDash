import Foundation
import SwiftData

@Model
final class MissionHistory {
    var id: UUID
    var missionID: Int
    var missionTitle: String
    var missionIconName: String
    var rewardCoins: Int
    var completedAt: Date

    init(
        id: UUID = UUID(),
        missionID: Int,
        missionTitle: String,
        missionIconName: String,
        rewardCoins: Int,
        completedAt: Date = Date()
    ) {
        self.id = id
        self.missionID = missionID
        self.missionTitle = missionTitle
        self.missionIconName = missionIconName
        self.rewardCoins = rewardCoins
        self.completedAt = completedAt
    }

    convenience init(mission: Mission, completedAt: Date = Date()) {
        self.init(
            missionID: mission.id,
            missionTitle: mission.title,
            missionIconName: mission.iconName,
            rewardCoins: mission.rewardCoins,
            completedAt: completedAt
        )
    }
}
