import SwiftUI
import SpriteKit

struct WorldTabWrapper: View {
    @Binding var isPaused: Bool

    @State private var scene = WorldScene()

    var body: some View {
        GeometryReader { _ in
            SpriteView(scene: scene)
                .ignoresSafeArea()
                .onAppear {
                    scene.size = UIScreen.main.bounds.size
                    scene.scaleMode = .resizeFill
                }
                .onChange(of: isPaused) {
                    scene.isPaused = isPaused
                    print("🟡 onChange: isPaused = \(isPaused)")
                }
        }
    }
}
