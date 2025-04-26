import SwiftUI
import SpriteKit

struct WorldView: View {
    var body: some View {
        SpriteView(scene: WorldScene(size: UIScreen.main.bounds.size))
            .ignoresSafeArea()
    }
}
