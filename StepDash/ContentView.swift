import SwiftUI
import SwiftData


struct ContentView: View {
    
    @Query private var players: [Player]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack {
            //Text("Players: \(players.count)")
            Button("Reset Player Data") {
                do {
                    try modelContext.delete(model: Player.self)
                    try modelContext.save()
                } catch {
                    print(error)
                }
            }
            
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
    }
}

