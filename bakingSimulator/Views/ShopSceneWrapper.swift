import SwiftUI
import SpriteKit

struct ShopSceneWrapper: View {
    @Binding var lastEntryTile: (column: Int, row: Int)?
    @Binding var isShowingShopMenu: Bool
    @Binding var selectedTab: Int
    @Binding var isInsideShop: Bool
    @Binding var shopSceneID: UUID
    @Binding var worldSceneID: UUID
    @State private var playerReturnTile: (column: Int, row: Int)? = nil
    @State private var isExitingShop = false

    var body: some View {
        SpriteView(scene: SpriteSceneManager.createShopScene(
            onExitShop: { _ in
                guard isInsideShop, !isExitingShop else { return }
                isExitingShop = true

                // Use lastEntryTile and offset row by +2 for exit
                if let entry = lastEntryTile {
                    playerReturnTile = (entry.column, entry.row + 2)
                }

                let wasOnWorldTab = (selectedTab == 0)
                withAnimation {
                    isInsideShop = false
                    if !wasOnWorldTab {
                        selectedTab = 0
                    }
                }
                if !wasOnWorldTab {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        if !isInsideShop && selectedTab == 0 {
                            worldSceneID = UUID()
                        }
                        isExitingShop = false // allow future exits
                    }
                } else {
                    isExitingShop = false
                }
            },
            onOpenShopMenu: {
                isShowingShopMenu = true
            },
            playerReturnTile: playerReturnTile
        ))
        .ignoresSafeArea()
        .id(shopSceneID)
        .sheet(isPresented: $isShowingShopMenu) {
            ShopMenuView()
        }
    }
}
