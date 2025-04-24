import SwiftUI
import AVFoundation

struct SplashView: View {
    @State private var showContent = false
    @State private var fadeOut = false
    @State private var dingPlayer: AVAudioPlayer?

    var onFinish: () -> Void

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("🍪🥛")
                    .font(.system(size: 100))
                    .scaleEffect(showContent ? 1.0 : 0.8)
                    .opacity(showContent ? 1.0 : 0.0)

                Text("Baking Simulator")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .opacity(showContent ? 1.0 : 0.0)
            }
            .animation(.easeIn(duration: 1.0), value: showContent)
        }
        .opacity(fadeOut ? 0.0 : 1.0)
        .animation(.easeOut(duration: 0.5), value: fadeOut)
        .onAppear {
            playDingSound()       // 🔔 Play immediately
            showContent = true    // 🧁 Start animating in

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                fadeOut = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onFinish()
                }
            }
        }
    }

    func playDingSound() {
        guard let url = Bundle.main.url(forResource: "ding", withExtension: "wav") else {
            print("Ding sound not found.")
            return
        }
        do {
            dingPlayer = try AVAudioPlayer(contentsOf: url)
            dingPlayer?.play()
        } catch {
            print("⚠️ Error loading ding sound: \(error.localizedDescription)")
        }
    }
}
