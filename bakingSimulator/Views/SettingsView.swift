import SwiftUI

struct SettingsView: View {
    @AppStorage("isMusicMuted") var isMusicMuted: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text("⚙️ Settings")
                .font(.largeTitle)
                .bold()

            Toggle("Mute Music", isOn: $isMusicMuted)
                .padding()
                .font(.title2)

            Spacer()
        }
        .padding()
    }
}
