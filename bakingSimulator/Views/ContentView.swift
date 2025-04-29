import SwiftUI

struct ContentView: View {
    @State private var isInsideShop = false
    @State private var isShowingShopMenu = false
    @State private var selectedTab = 0

    @State private var worldSceneID = UUID()
    @State private var shopSceneID = UUID()

    @State private var lastEntryTile: (column: Int, row: Int)? = nil
    var body: some View {
        TabView(selection: $selectedTab) {
            if !isInsideShop {
                WorldView(
                    lastEntryTile: $lastEntryTile,
                    isInsideShop: $isInsideShop,
                    isShowingShopMenu: $isShowingShopMenu,
                    selectedTab: $selectedTab,
                    worldSceneID: $worldSceneID,
                    shopSceneID: $shopSceneID
                )
                .tabItem {
                    Label("World", systemImage: "globe")
                }
                .tag(0)
            } else {
                // Locked World Tab when inside shop
                Text("You must leave the shop to return to the world.")
                    .tabItem {
                        Label("World", systemImage: "globe")
                    }
                    .tag(0)
            }

            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(1)

            InventoryView()
                .tabItem {
                    Label("Inventory", systemImage: "tray.full")
                }
                .tag(2)

            if isInsideShop {
                ShopSceneWrapper(
                    lastEntryTile: $lastEntryTile,
                    isShowingShopMenu: $isShowingShopMenu,
                    selectedTab: $selectedTab,
                    isInsideShop: $isInsideShop,
                    shopSceneID: $shopSceneID,
                    worldSceneID: $worldSceneID
                )
                .tabItem {
                    Label("Shop", systemImage: "cart")
                }
                .tag(3)
            } else {
                // Locked Shop Tab when not inside shop
                Text("Locked")
                    .tabItem {
                        Label("Shop", systemImage: "cart")
                    }
                    .tag(3)
            }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(4)
        }
        .onAppear {
            MusicManager.shared.startBackgroundMusic()
        }

    }
}
