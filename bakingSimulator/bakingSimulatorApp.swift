import SwiftUI

@main
struct BakingSimulatorApp: App {
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashView {
                    showSplash = false
                }
            } else {
                ContentView()
            }
        }
    }
}
