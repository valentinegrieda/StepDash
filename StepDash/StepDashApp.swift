import SwiftUI
import SwiftData

@main
struct StepDashApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
            .preferredColorScheme(.light)
            .task {
                BackgroundMusicPlayer.shared.startIfNeeded()
            }
            .onChange(of: scenePhase, initial: true) { _, newPhase in
                NotificationManager.shared.handleScenePhase(newPhase)
            }
        }
        .modelContainer(for: [Player.self, Mission.self, DailyStepRecord.self, CurrentDelivery.self])
    }
}
