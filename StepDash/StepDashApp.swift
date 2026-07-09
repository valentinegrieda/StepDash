import SwiftUI
import SwiftData
import Foundation

@main
struct StepDashApp: App {
    @Environment(\.scenePhase) private var scenePhase
    private let modelContainer: ModelContainer

    init() {
        let schema = Schema([Player.self, Mission.self, DailyStepRecord.self, CurrentDelivery.self, MissionHistory.self, DeliveryHistory.self])
        let configuration = ModelConfiguration(schema: schema)

        do {
            modelContainer = try ModelContainer(for: schema, configurations: configuration)
        } catch {
            // The on-disk store is incompatible with the current schema — this
            // happens in development when a @Model changes shape. Wipe the stale
            // store and rebuild it fresh instead of crashing.
            StepDashApp.deleteStore(at: configuration.url)
            do {
                modelContainer = try ModelContainer(for: schema, configurations: configuration)
            } catch {
                fatalError("Failed to create model container: \(error)")
            }
        }

        MissionBackgroundRefreshManager.shared.configure(modelContainer: modelContainer)
    }

    private static func deleteStore(at url: URL) {
        let fileManager = FileManager.default
        for suffix in ["", "-wal", "-shm"] {
            try? fileManager.removeItem(at: URL(fileURLWithPath: url.path + suffix))
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
                if newPhase == .active {
                    BackgroundMusicPlayer.shared.resumeIfPaused()
                }
            }

        }
        .modelContainer(modelContainer)
    }
}
