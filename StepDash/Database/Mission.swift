import Foundation
import SwiftData

@Model
final class Mission {
    var id: Int
    var title: String
    var destination: String
    var distanceKm: Double
    var rewardCoins: Int
    var rewardXP: Int

    init(
        id: Int,
        title: String,
        destination: String,
        distanceKm: Double,
        rewardCoins: Int,
        rewardXP: Int
    ) {
        self.id = id
        self.title = title
        self.destination = destination
        self.distanceKm = distanceKm
        self.rewardCoins = rewardCoins
        self.rewardXP = rewardXP
    }
}


extension Mission {
    
    static var seedMissions: [Mission] {
        [
            Mission(id: 1, title: "Bakery Run",    destination: "Sunny Street 12", distanceKm: 2.5, rewardCoins: 25, rewardXP: 50),
            Mission(id: 2, title: "Park Express",  destination: "Green Park 4",    distanceKm: 4.0, rewardCoins: 45, rewardXP: 90),
            Mission(id: 3, title: "Downtown Dash", destination: "Main Plaza 7",    distanceKm: 6.5, rewardCoins: 80, rewardXP: 150),
        ]
    }

    
    static func seedIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Mission>()
        let existingCount = (try? context.fetchCount(descriptor)) ?? 0
        guard existingCount == 0 else { return }

        for mission in seedMissions {
            context.insert(mission)
        }

        try? context.save()
    }
}
