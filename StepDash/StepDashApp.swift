import SwiftUI
import SwiftData

@main
struct StepDashApp: App {

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
            .preferredColorScheme(.light)
        }
        .modelContainer(for: [Player.self, Mission.self])
    }
}
