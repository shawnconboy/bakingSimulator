import SwiftUI
import SpriteKit

struct WorldView: View {
    @Binding var lastEntryTile: (column: Int, row: Int)?
    @Binding var isInsideShop: Bool
    @Binding var isShowingShopMenu: Bool
    @Binding var selectedTab: Int
    @Binding var worldSceneID: UUID
    @Binding var shopSceneID: UUID

    @State private var respawnTile: (column: Int, row: Int)? = nil
    @State private var justExitedShop = false

    var body: some View {
        SpriteView(scene: SpriteSceneManager.createWorldScene(
            onEnterShop: { entryTile in
                guard !isInsideShop, !justExitedShop else { return }
                lastEntryTile = entryTile
                withAnimation {
                    isInsideShop = true
                    if selectedTab != 3 {
                        selectedTab = 3
                    }
                }
            },
            onOpenShopMenu: {
                isShowingShopMenu = true
            },
            playerStartTile: respawnTile ?? lastEntryTile
        ))
        .ignoresSafeArea()
        .id(worldSceneID)
        .onChange(of: isInsideShop) {
            if !isInsideShop {
                // On exiting shop, respawn two tiles "down" from entry
                if let entry = lastEntryTile {
                    respawnTile = (entry.column, entry.row + 2)
                }
                justExitedShop = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    justExitedShop = false
                }
            }
        }
    }
}
