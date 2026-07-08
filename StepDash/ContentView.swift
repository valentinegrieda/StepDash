import SwiftUI
import SwiftData


struct ContentView: View {
    
    @Query private var players: [Player]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack {
            //Text("Players: \(players.count)")
            // Debug: disabled so it doesn't disrupt the home design.
            /*
            Button("Reset Player Data") {
                do {
                    try modelContext.delete(model: Player.self)
                    try modelContext.save()
                } catch {
                    print(error)
                }
            }
            */

            /*
            Button("Test Insert") {
                let player = Player(
                    name: "Test",
                    gender: "male",
                    height: 170,
                    factor: 0.415
                )

                print("Before:", modelContext.hasChanges)

                modelContext.insert(player)

                print("After insert:", modelContext.hasChanges)

                do {
                    try modelContext.save()
                    print("Saved")
                } catch {
                    print(error)
                }
            }
             */

            if players.isEmpty {
                OnboardingView()
            } else {
                //CheckingScreen()
                GameContainerView(name: players[0].name, stepLength: players[0].stepLength)
            }
        }
        .onAppear {
            Mission.seedIfNeeded(context: modelContext)
        }
        .onChange(of: players.count, initial: true) { _, newCount in
            let hasRegisteredUser = newCount > 0
            NotificationManager.shared.updateReminderEligibility(hasRegisteredUser: hasRegisteredUser)
        }
    }
}

#Preview("Home (seeded player)") {
    let container = try! ModelContainer(
        for: Player.self, Mission.self, MissionHistory.self, DeliveryHistory.self, DailyStepRecord.self, CurrentDelivery.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    container.mainContext.insert(
        Player(name: "Player", gender: "male", height: 175, stepLength: 0.72, coins: 340)
    )
    return NavigationStack { ContentView() }
        .modelContainer(container)
}

#Preview("Onboarding (no player)") {
    NavigationStack { ContentView() }
        .modelContainer(for: [Player.self, Mission.self, MissionHistory.self, DeliveryHistory.self, DailyStepRecord.self, CurrentDelivery.self], inMemory: true)
}
