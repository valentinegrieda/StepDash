import SwiftUI
import SwiftData

@main
struct StepDashApp: App {
    @Environment(\.scenePhase) private var scenePhase
    private let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(
                for: Player.self,
                Mission.self,
                DailyStepRecord.self,
                CurrentDelivery.self
            )
            MissionBackgroundRefreshManager.shared.configure(modelContainer: modelContainer)
        } catch {
            fatalError("Failed to create model container: \(error)")
        }
    }

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
                MissionBackgroundRefreshManager.shared.handleScenePhase(newPhase)
            }
        }
        .modelContainer(modelContainer)
    }
}
