import SwiftUI
import SpriteKit

struct WorldView: View {
    var scene: SKScene {
        let scene = WorldScene()
        scene.size = UIScreen.main.bounds.size
        scene.scaleMode = .resizeFill
        return scene
    }

    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
    }
}
