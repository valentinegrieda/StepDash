import SwiftUI
import SpriteKit

struct GameContainerView: View {
    let name: String
    let stepLength: Double

    @State private var presentation: ToolbarDestinationPresentation?

    var body: some View {
        ZStack {
            GameSceneRepresentable(
                name: name,
                stepLength: stepLength,
                onToolbarItemSelected: { itemId, steps, distance in
                    guard let selected = ToolbarDestination(rawValue: itemId) else { return }
                    presentation = ToolbarDestinationPresentation(
                        destination: selected,
                        steps: steps,
                        distance: distance
                    )
                }
            )
            .ignoresSafeArea()

            if let presentation {
                ToolbarDestinationView(
                    destination: presentation.destination,
                    playerName: name,
                    steps: presentation.steps,
                    distance: presentation.distance,
                    onClose: {
                        self.presentation = nil
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }
        }
        .animation(.easeOut(duration: 0.18), value: presentation?.id)
    }
}

private struct GameSceneRepresentable: UIViewRepresentable {
    let name: String
    let stepLength: Double
    let onToolbarItemSelected: (String, Int, Double) -> Void

    func makeUIView(context: Context) -> SKView {
        GameSKView(
            playerName: name,
            stepLength: stepLength,
            onToolbarItemSelected: onToolbarItemSelected
        )
    }

    func updateUIView(_ uiView: SKView, context: Context) {
        (uiView as? GameSKView)?.updateToolbarHandler(onToolbarItemSelected)
    }
}
