import SwiftUI
import SpriteKit

struct WorldTabWrapper: View {
    @Binding var isPaused: Bool

    var scene: SKScene {
        let scene = WorldScene()
        scene.size = UIScreen.main.bounds.size
        scene.scaleMode = .resizeFill
        scene.onPauseToggle = { paused in
            isPaused = paused
        }
        return scene
    }

    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
    }
}
