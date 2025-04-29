import SpriteKit

class SpriteSceneManager {
    // Shared reference to the world tile map for grid-based positioning
    static var sharedWorldTileMap: SKTileMapNode? = nil
    static func createWorldScene(
        onEnterShop: @escaping (_ entryTile: (column: Int, row: Int)) -> Void,
        onOpenShopMenu: @escaping () -> Void,
        playerStartTile: (column: Int, row: Int)? = nil
    ) -> WorldScene {
        let scene = WorldScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .resizeFill

        if let startTile = playerStartTile, let tileMap = sharedWorldTileMap {
            scene.player.position = tileMap.centerOfTile(atColumn: startTile.column, row: startTile.row)
        }

        scene.enterShopAction = { [weak scene] in
            if let scene = scene, let tileMap = scene.tileMap {
                let tile = tileMap.tileColumnIndex(fromPosition: scene.player.position)
                let row = tileMap.tileRowIndex(fromPosition: scene.player.position)
                onEnterShop((tile, row))
            }
        }
        scene.openShopMenuAction = onOpenShopMenu

        return scene
    }

    static func createShopScene(
        onExitShop: @escaping (_ exitTile: (column: Int, row: Int)) -> Void,
        onOpenShopMenu: @escaping () -> Void,
        playerReturnTile: (column: Int, row: Int)? = nil
    ) -> ShopScene {
        let scene = ShopScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .resizeFill

        if let returnTile = playerReturnTile, let tileMap = sharedWorldTileMap {
            scene.player.position = tileMap.centerOfTile(atColumn: returnTile.column, row: returnTile.row)
        }

        scene.exitShopAction = { [weak scene] in
            if let scene = scene, let tileMap = scene.tileMap {
                let tile = tileMap.tileColumnIndex(fromPosition: scene.player.position)
                let row = tileMap.tileRowIndex(fromPosition: scene.player.position)
                onExitShop((tile, row))
            }
        }
        scene.openShopMenuAction = onOpenShopMenu

        return scene
    }
}
