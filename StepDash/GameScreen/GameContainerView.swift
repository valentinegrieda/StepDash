import SwiftUI
import SpriteKit

struct GameContainerView: UIViewRepresentable {
    
    let name: String
    let stepLength: Double
    
    
    func makeUIView(context: Context) -> SKView {
        GameSKView(playerName: name, stepLength: stepLength)
    }
    
    
    func updateUIView(_ uiView: SKView, context: Context) {
    }
}
