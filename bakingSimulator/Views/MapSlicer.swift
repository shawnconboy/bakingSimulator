import SpriteKit

class MapSlicer {
    static func slice(imageNamed: String, tileSize: CGSize) -> [[SKTexture?]] {
        let texture = SKTexture(imageNamed: imageNamed)
        
        let imageSize = texture.size()
        let columns = Int(imageSize.width / tileSize.width)
        let rows = Int(imageSize.height / tileSize.height)
        
        var slicedTextures: [[SKTexture?]] = Array(repeating: Array(repeating: nil, count: columns), count: rows)
        
        for row in 0..<rows {
            for col in 0..<columns {
                let rect = CGRect(
                    x: CGFloat(col) * tileSize.width / imageSize.width,
                    y: CGFloat(row) * tileSize.height / imageSize.height, // ✅ FIXED Y-DIRECTION
                    width: tileSize.width / imageSize.width,
                    height: tileSize.height / imageSize.height
                )
                let tileTexture = SKTexture(rect: rect, in: texture)
                slicedTextures[row][col] = tileTexture
            }
        }
        
        return slicedTextures
    }
}
