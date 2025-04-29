import SpriteKit
import SwiftUI

class ShopScene: SKScene {
    var tileMap: SKTileMapNode?
    let player = SKSpriteNode(imageNamed: "playerIdle")
    let cameraNode = SKCameraNode()
    
    var openShopMenuAction: (() -> Void)?
    var exitShopAction: (() -> Void)?

    var dpadNode: SKSpriteNode!
    var aButtonNode: SKSpriteNode!
    var bButtonNode: SKSpriteNode!

    var walkFrames: [SKTexture] = []
    var moveDirection: CGVector = .zero

    var shopkeeper: SKSpriteNode!
    let tileSize: CGFloat = 64

    var playerReturnTile: (column: Int, row: Int)? = nil

    var canExitShop = true // ✅ Cooldown for door
    var collisionRects: [CGRect] = []

    override func didMove(to view: SKView) {
        backgroundColor = .black
        anchorPoint = CGPoint(x: 0.5, y: 0.5)

        setupTileMap()
        setupPlayer()
        setupShopkeeper()
        setupControls()
        setupWalkFrames()
        setupCollisionRects()

        camera = cameraNode
        cameraNode.position = player.position
        addChild(cameraNode)

        // 🛡️ Cooldown to prevent instant door teleport
        canExitShop = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.canExitShop = true
        }
    }

    func setupTileMap() {
        let textures = MapSlicer.slice(imageNamed: "shopMap", tileSize: CGSize(width: 64, height: 64))
        if let tileMap = TileMapBuilder.buildTileMap(from: textures, tileSize: CGSize(width: 64, height: 64)) {
            tileMap.zPosition = -10
            addChild(tileMap)
            self.tileMap = tileMap
        }
    }

    func setupPlayer() {
        player.texture?.filteringMode = .nearest
        player.size = CGSize(width: tileSize, height: tileSize)

        if let tileMap = tileMap {
            let bottomRow = 2 // ✅ Start a little higher to avoid door zone
            let rightColumn = tileMap.numberOfColumns - 2
            player.position = tileMap.centerOfTile(atColumn: rightColumn, row: bottomRow)
        } else {
            player.position = CGPoint(x: 0, y: 0)
        }

        addChild(player)
    }



    func setupWalkFrames() {
        for i in 1...4 {
            let textureName = "playerWalk\(i)"
            let texture = SKTexture(imageNamed: textureName)
            texture.filteringMode = .nearest
            walkFrames.append(texture)
        }
    }

    func setupControls() {
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

    func setupShopkeeper() {
        shopkeeper = SKSpriteNode(imageNamed: "npcFacing1")
        shopkeeper.texture?.filteringMode = .nearest
        shopkeeper.size = CGSize(width: tileSize, height: tileSize)

        if let tileMap = tileMap {
            let middleRow = tileMap.numberOfRows / 2
            shopkeeper.position = CGPoint(
                x: (-tileMap.mapSize.width / 2) + (tileSize * 1),
                y: (-tileMap.mapSize.height / 2) + (tileSize * CGFloat(middleRow))
            )
        } else {
            shopkeeper.position = CGPoint(x: 0, y: 0)
        }

        addChild(shopkeeper)
    }

    func setupCollisionRects() {
        // 🛡️ Block vending machines (top middle area)
        collisionRects.append(CGRect(x: -tileSize, y: tileSize * 2, width: tileSize * 2, height: tileSize))

        // 🛡️ Block counter on left
        collisionRects.append(CGRect(x: -tileSize * 2, y: -tileSize * 1, width: tileSize * 1, height: tileSize * 4))
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
                if player.position.distance(to: shopkeeper.position) < tileSize * 2.5 {
                    openShopMenuAction?()
                }
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

        if let tileMap = tileMap {
            let playerHalfWidth = player.size.width / 2
            let playerHalfHeight = player.size.height / 2
            let mapWidth = tileMap.mapSize.width
            let mapHeight = tileMap.mapSize.height

            player.position.x = min(max(player.position.x, -mapWidth/2 + playerHalfWidth), mapWidth/2 - playerHalfWidth)
            player.position.y = min(max(player.position.y, -mapHeight/2 + playerHalfHeight), mapHeight/2 - playerHalfHeight)

            cameraNode.position = player.position
        }

        // 🛡️ Collision walls
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

        // 🎯 Walking animation
        if moveDirection.dx != 0 || moveDirection.dy != 0 {
            if player.action(forKey: "walking") == nil {
                let walkAction = SKAction.repeatForever(SKAction.animate(with: walkFrames, timePerFrame: 0.1))
                player.run(walkAction, withKey: "walking")
            }

            if moveDirection.dx < 0 {
                player.xScale = -1.0
            } else if moveDirection.dx > 0 {
                player.xScale = 1.0
            }
        } else {
            player.removeAction(forKey: "walking")
            let idleTexture = SKTexture(imageNamed: "playerIdle")
            idleTexture.filteringMode = .nearest
            player.texture = idleTexture
        }

        let doorTile = CGPoint(x: tileSize * 3 - tileSize * 2, y: -tileSize * 3)

        if player.position.distance(to: doorTile) < tileSize * 0.8 {
            if canExitShop {
                leaveShop() // ✅ This now just calls exitShopAction
            }
        }
    }

    func leaveShop() {
        exitShopAction?()
    }
}


