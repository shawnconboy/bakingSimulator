import SpriteKit

class TileMapBuilder {
    static func buildTileMap(from textures: [[SKTexture?]], tileSize: CGSize) -> SKTileMapNode? {
        guard !textures.isEmpty else { return nil }
        
        let rows = textures.count
        let columns = textures[0].count
        
        // Create the SKTileSet
        var tileGroups: [SKTileGroup] = []
        for row in textures {
            for tileTexture in row {
                if let texture = tileTexture {
                    let tileDefinition = SKTileDefinition(texture: texture, size: tileSize)
                    let tileGroup = SKTileGroup(tileDefinition: tileDefinition)
                    tileGroups.append(tileGroup)
                }
            }
        }
        
        let tileSet = SKTileSet(tileGroups: tileGroups)
        
        // Create the TileMap
        let tileMap = SKTileMapNode(tileSet: tileSet, columns: columns, rows: rows, tileSize: tileSize)
        tileMap.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        for row in 0..<rows {
            for col in 0..<columns {
                let index = row * columns + col
                if index < tileGroups.count {
                    tileMap.setTileGroup(tileGroups[index], forColumn: col, row: row)
                }
            }
        }
        
        return tileMap
    }
}
