import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            WorldView()
                .tabItem {
                    Label("World", systemImage: "globe")
                }

            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            InventoryView()
                .tabItem {
                    Label("Inventory", systemImage: "tray.full")
                }

            ShopView()
                .tabItem {
                    Label("Shop", systemImage: "cart")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .onAppear {
            MusicManager.shared.startBackgroundMusic() // ✅ Start music once when app appears
        }
    }
}
