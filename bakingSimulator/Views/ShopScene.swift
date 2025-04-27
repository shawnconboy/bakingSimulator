import SpriteKit

class ShopScene: SKScene {
    var tileMap: SKTileMapNode?
    let player = SKSpriteNode(imageNamed: "playerIdle")
    let cameraNode = SKCameraNode()
    
    var walkFrames: [SKTexture] = []
    
    var dpadNode: SKSpriteNode!
    var aButtonNode: SKSpriteNode!
    var bButtonNode: SKSpriteNode!
    
    var moveDirection: CGVector = .zero
    let tileSize: CGFloat = 64
    
    var collisionRects: [CGRect] = []

    override func didMove(to view: SKView) {
        backgroundColor = .black
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        setupTileMapFromImage(named: "shopMap")
        
        let idleTexture = SKTexture(imageNamed: "playerIdle")
        idleTexture.filteringMode = .nearest
        player.texture = idleTexture
        player.size = CGSize(width: 64, height: 64)
        player.position = CGPoint(x: 0, y: 0)
        addChild(player)
        
        for i in 1...4 {
            let textureName = "playerWalk\(i)"
            let texture = SKTexture(imageNamed: textureName)
            texture.filteringMode = .nearest
            walkFrames.append(texture)
        }
        
        camera = cameraNode
        cameraNode.position = player.position
        addChild(cameraNode)
        
        dpadNode = SKSpriteNode(imageNamed: "XboxSeriesX_Dpad")
        dpadNode.alpha = 0.8
        dpadNode.setScale(1.5)
        dpadNode.zPosition = 10
        dpadNode.position = CGPoint(x: -size.width / 2 + 100, y: -size.height / 2 + 200)
        cameraNode.addChild(dpadNode)
        
        aButtonNode = SKSpriteNode(imageNamed: "XboxSeriesX_A")
        aButtonNode.alpha = 0.8
        aButtonNode.setScale(1.0)
        aButtonNode.zPosition = 10
        aButtonNode.position = CGPoint(x: size.width / 2 - 80, y: -size.height / 2 + 200)
        cameraNode.addChild(aButtonNode)
        
        bButtonNode = SKSpriteNode(imageNamed: "XboxSeriesX_B")
        bButtonNode.alpha = 0.8
        bButtonNode.setScale(1.0)
        bButtonNode.zPosition = 10
        bButtonNode.position = CGPoint(x: size.width / 2 - 160, y: -size.height / 2 + 140)
        cameraNode.addChild(bButtonNode)
    }
    
    func setupTileMapFromImage(named imageName: String) {
        let textures = MapSlicer.slice(imageNamed: imageName, tileSize: CGSize(width: 64, height: 64))
        
        if let tileMap = TileMapBuilder.buildTileMap(from: textures, tileSize: CGSize(width: 64, height: 64)) {
            tileMap.zPosition = -10
            addChild(tileMap)
            self.tileMap = tileMap
            
            // 🧱 Setup collision boundaries
            let tileOrigin = CGPoint(x: -tileMap.mapSize.width / 2, y: -tileMap.mapSize.height / 2)
            
            // (1,1) to (1,5)
            for row in 1...5 {
                let rect = CGRect(
                    x: tileOrigin.x + CGFloat(1) * tileSize,
                    y: tileOrigin.y + CGFloat(row) * tileSize,
                    width: tileSize,
                    height: tileSize
                )
                collisionRects.append(rect)
            }
            
            // (3,6) to (3,7)
            for row in 6...7 {
                let rect = CGRect(
                    x: tileOrigin.x + CGFloat(3) * tileSize,
                    y: tileOrigin.y + CGFloat(row) * tileSize,
                    width: tileSize,
                    height: tileSize
                )
                collisionRects.append(rect)
            }
            
            // (5,6) to (5,7)
            for row in 6...7 {
                let rect = CGRect(
                    x: tileOrigin.x + CGFloat(5) * tileSize,
                    y: tileOrigin.y + CGFloat(row) * tileSize,
                    width: tileSize,
                    height: tileSize
                )
                collisionRects.append(rect)
            }
            
            // 🔴 Optional debug: visualize collision areas
            /*
            for rect in collisionRects {
                let debugNode = SKShapeNode(rect: rect)
                debugNode.strokeColor = .red
                debugNode.lineWidth = 2
                debugNode.zPosition = 100
                addChild(debugNode)
            }
            */
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: cameraNode)
            
            if dpadNode.contains(location) {
                let center = dpadNode.position
                let dx = location.x - center.x
                let dy = location.y - center.y
                
                if abs(dx) > abs(dy) {
                    moveDirection = dx > 0 ? CGVector(dx: 1, dy: 0) : CGVector(dx: -1, dy: 0)
                } else {
                    moveDirection = dy > 0 ? CGVector(dx: 0, dy: 1) : CGVector(dx: 0, dy: -1)
                }
            }
            
            if aButtonNode.contains(location) {
                print("🛒 Open Shop Menu (not built yet)")
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        moveDirection = .zero
    }
    
    override func update(_ currentTime: TimeInterval) {
        let speed: CGFloat = 2.0
        player.position.x += moveDirection.dx * speed
        player.position.y += moveDirection.dy * speed
        
        // 🛡️ Clamp player inside map
        if let tileMap = tileMap {
            let playerHalfWidth = player.size.width / 2
            let playerHalfHeight = player.size.height / 2
            let mapWidth = tileMap.mapSize.width
            let mapHeight = tileMap.mapSize.height
            
            player.position.x = min(max(player.position.x, -mapWidth/2 + playerHalfWidth), mapWidth/2 - playerHalfWidth)
            player.position.y = min(max(player.position.y, -mapHeight/2 + playerHalfHeight), mapHeight/2 - playerHalfHeight)
            
            cameraNode.position = player.position
        }
        
        if moveDirection.dx != 0 || moveDirection.dy != 0 {
            startWalkingAnimation()
            
            if moveDirection.dx < 0 {
                player.xScale = -1.0
            } else if moveDirection.dx > 0 {
                player.xScale = 1.0
            }
        } else {
            stopWalkingAnimation()
        }
        
        // 🚪 Door detection (lowered)
        let doorTile = CGPoint(x: tileSize * 3 - tileSize * 2, y: -tileSize * 3)
        if player.position.distance(to: doorTile) < tileSize / 2 {
            if moveDirection.dy < 0 {
                leaveShop()
            }
        }
        
        // 🔥 Collision against walls
        for rect in collisionRects {
            if player.frame.intersects(rect) {
                if moveDirection.dx > 0 {
                    player.position.x = rect.minX - player.size.width / 2
                }
                if moveDirection.dx < 0 {
                    player.position.x = rect.maxX + player.size.width / 2
                }
                if moveDirection.dy > 0 {
                    player.position.y = rect.minY - player.size.height / 2
                }
                if moveDirection.dy < 0 {
                    player.position.y = rect.maxY + player.size.height / 2
                }
            }
        }
    }
    
    func startWalkingAnimation() {
        if player.action(forKey: "walking") == nil {
            let walkAction = SKAction.repeatForever(SKAction.animate(with: walkFrames, timePerFrame: 0.1))
            player.run(walkAction, withKey: "walking")
        }
    }
    
    func stopWalkingAnimation() {
        player.removeAction(forKey: "walking")
        
        let idleTexture = SKTexture(imageNamed: "playerIdle")
        idleTexture.filteringMode = .nearest
        player.texture = idleTexture
    }
    
    func leaveShop() {
        let worldScene = WorldScene(size: self.size)
        worldScene.scaleMode = .resizeFill

        // ✅ Set new spawn when exiting the shop
        worldScene.initialPlayerTile = (column: 20, row: 18)

        // ✅ Lock the door when re-entering world
        worldScene.canEnterShop = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            worldScene.canEnterShop = true
        }

        let transition = SKTransition.fade(withDuration: 1.0)
        self.view?.presentScene(worldScene, transition: transition)
    }


}
