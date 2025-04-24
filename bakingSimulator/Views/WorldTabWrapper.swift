import SwiftUI
import SpriteKit

struct WorldTabWrapper: View {
    @Binding var isPaused: Bool

    var body: some View {
        SpriteView(scene: makeScene())
            .ignoresSafeArea()
    }

    private func makeScene() -> SKScene {
        let scene = WorldScene()
        scene.size = UIScreen.main.bounds.size
        scene.scaleMode = .resizeFill
        scene.onPauseToggle = { paused in
            isPaused = paused
        }
        return scene
    }
}
