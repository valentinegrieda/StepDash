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
            .task {
                BackgroundMusicPlayer.shared.startIfNeeded()
            }
        }
        .modelContainer(for: [Player.self, Mission.self, DailyStepRecord.self])
    }
}
