import SpriteKit
import AVFoundation

class WorldScene: SKScene {
    var tileMap: SKTileMapNode?
    let player = SKSpriteNode(imageNamed: "playerIdle")
    let cameraNode = SKCameraNode()
    var backgroundMusicPlayer: AVAudioPlayer?
    var walkFrames: [SKTexture] = []

    var dpadNode: SKSpriteNode!
    var aButtonNode: SKSpriteNode!
    var bButtonNode: SKSpriteNode!
    var wasPaused: Bool = false

    var npc: SKSpriteNode!
    var isGamePaused = false
    var onPauseToggle: ((Bool) -> Void)?

    let tileSize: CGFloat = 64
    let columns: Int = 50
    let rows: Int = 50
    var moveDirection: CGVector = .zero

    // Add a property to track if player is at the door
    var isAtDoor: Bool = false

    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        // Set up the scene's anchor point to center
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        setupTileMap()
        setupPlayer()
        setupNPC()
        loadWalkTextures()
        addDpadAndButtons()

        // Set up camera
        camera = cameraNode
        addChild(cameraNode)
        
        // Position camera at player's position after setup
        cameraNode.position = player.position

        let musicOptions = ["lofi1.mp3", "lofi2.mp3", "lofi3.mp3", "lofi4.mp3"]
        if let randomTrack = musicOptions.randomElement() {
            playBackgroundMusic(filename: randomTrack)
        }
    }

    func setupTileMap() {
        // Create a tile set with our custom tiles
        let tileSet = SKTileSet()
        let grassTileGroup = SKTileGroup(tileDefinition: SKTileDefinition(texture: SKTexture(imageNamed: "tileGrass")))
        let roadTileGroup = SKTileGroup(tileDefinition: SKTileDefinition(texture: SKTexture(imageNamed: "tileRoad")))
        let sidewalkTileGroup = SKTileGroup(tileDefinition: SKTileDefinition(texture: SKTexture(imageNamed: "tileSidewalk")))
        let houseLeftGroup = SKTileGroup(tileDefinition: SKTileDefinition(texture: SKTexture(imageNamed: "blueHouseLeft")))
        let houseRightGroup = SKTileGroup(tileDefinition: SKTileDefinition(texture: SKTexture(imageNamed: "blueHouseRight")))
        let houseSidingGroup = SKTileGroup(tileDefinition: SKTileDefinition(texture: SKTexture(imageNamed: "blueHouseSiding")))
        let houseWindowGroup = SKTileGroup(tileDefinition: SKTileDefinition(texture: SKTexture(imageNamed: "blueHouseWindow")))
        let houseDoorGroup = SKTileGroup(tileDefinition: SKTileDefinition(texture: SKTexture(imageNamed: "blueHouseDoor")))
        
        tileSet.tileGroups = [grassTileGroup, roadTileGroup, sidewalkTileGroup, 
                            houseLeftGroup, houseRightGroup, houseSidingGroup, 
                            houseWindowGroup, houseDoorGroup]

        // Create the tile map
        let tileMap = SKTileMapNode(tileSet: tileSet, columns: columns, rows: rows, tileSize: CGSize(width: tileSize, height: tileSize))
        tileMap.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        tileMap.position = CGPoint(x: 0, y: 0)
        addChild(tileMap)
        self.tileMap = tileMap

        // Fill the map with grass as base
        for column in 0..<columns {
            for row in 0..<rows {
                tileMap.setTileGroup(grassTileGroup, forColumn: column, row: row)
            }
        }

        // Create a horizontal road through the middle
        let roadWidth = 2  // Two tiles wide
        let roadRow = rows / 2  // Middle row
        for column in 0..<columns {
            for offset in -roadWidth/2...roadWidth/2 {
                let row = roadRow + offset
                if row >= 0 && row < rows {
                    tileMap.setTileGroup(roadTileGroup, forColumn: column, row: row)
                }
            }
        }

        // Add sidewalk above the road
        let sidewalkRow = roadRow + roadWidth/2 + 1  // One row above the road
        for column in 0..<columns {
            if sidewalkRow >= 0 && sidewalkRow < rows {
                tileMap.setTileGroup(sidewalkTileGroup, forColumn: column, row: sidewalkRow)
            }
        }

        // Add the blue house above the sidewalk
        let houseStartColumn = columns / 2 - 2  // Center the house
        let houseStartRow = sidewalkRow + 1     // One row above the sidewalk
        
        // Bottom row of the house
        tileMap.setTileGroup(houseLeftGroup, forColumn: houseStartColumn, row: houseStartRow)
        tileMap.setTileGroup(houseWindowGroup, forColumn: houseStartColumn + 1 , row: houseStartRow)
        tileMap.setTileGroup(houseWindowGroup, forColumn: houseStartColumn + 2 , row: houseStartRow)
        tileMap.setTileGroup(houseDoorGroup, forColumn: houseStartColumn + 3, row: houseStartRow)
        tileMap.setTileGroup(houseRightGroup, forColumn: houseStartColumn + 4, row: houseStartRow)
        
        // Top row of the house
        tileMap.setTileGroup(houseLeftGroup, forColumn: houseStartColumn, row: houseStartRow + 1)
        tileMap.setTileGroup(houseWindowGroup, forColumn: houseStartColumn + 1, row: houseStartRow + 1)
        tileMap.setTileGroup(houseWindowGroup, forColumn: houseStartColumn + 2, row: houseStartRow + 1)
        tileMap.setTileGroup(houseSidingGroup, forColumn: houseStartColumn + 3, row: houseStartRow + 1)
        tileMap.setTileGroup(houseRightGroup, forColumn: houseStartColumn + 4, row: houseStartRow + 1)
    }

    override func didEvaluateActions() {
        if !isPaused && wasPaused {
            moveDirection = .zero
            player.removeAction(forKey: "walk")
            player.texture = SKTexture(imageNamed: "playerIdle")
            player.texture?.filteringMode = .nearest
            wasPaused = false
        }
    }

    override var isPaused: Bool {
        didSet {
            if isPaused {
                wasPaused = true
            }
        }
    }

    func setupPlayer() {
        player.size = CGSize(width: tileSize, height: tileSize)
        player.texture?.filteringMode = .nearest
        // Spawn player in the middle of the map, just above the road
        player.position = CGPoint(x: 0, y: tileSize * 2)  // Center of map, slightly above road
        addChild(player)
    }

    func setupNPC() {
        npc = SKSpriteNode(imageNamed: "npcFacing1")
        npc.texture?.filteringMode = .nearest
        npc.size = CGSize(width: tileSize, height: tileSize)
        npc.setScale(0.85)
        npc.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        // Spawn NPC above the player
        npc.position = CGPoint(x: tileSize * 2, y: tileSize * 4)  // Slightly to the right and above the player
        addChild(npc)
    }

    func loadWalkTextures() {
        walkFrames = [
            SKTexture(imageNamed: "playerWalk1"),
            SKTexture(imageNamed: "playerWalk2"),
            SKTexture(imageNamed: "playerWalk3"),
            SKTexture(imageNamed: "playerWalk4")
        ]
        for frame in walkFrames {
            frame.filteringMode = .nearest
        }
    }

    func addDpadAndButtons() {
        dpadNode = SKSpriteNode(imageNamed: "XboxSeriesX_Dpad")
        dpadNode.name = "dpad"
        dpadNode.alpha = 0.8
        dpadNode.zPosition = 10
        dpadNode.setScale(1.5)
        dpadNode.position = CGPoint(x: -size.width / 2 + dpadNode.size.width * 0.6 + 10,
                                    y: -size.height / 2 + dpadNode.size.height * 0.75 + 40)
        cameraNode.addChild(dpadNode)

        aButtonNode = SKSpriteNode(imageNamed: "XboxSeriesX_A")
        aButtonNode.name = "aButton"
        aButtonNode.alpha = 0.8
        aButtonNode.zPosition = 10
        aButtonNode.setScale(1.0)
        aButtonNode.position = CGPoint(x: size.width / 2 - 80, y: -size.height / 2 + 200)
        cameraNode.addChild(aButtonNode)

        bButtonNode = SKSpriteNode(imageNamed: "XboxSeriesX_B")
        bButtonNode.name = "bButton"
        bButtonNode.alpha = 0.8
        bButtonNode.zPosition = 10
        bButtonNode.setScale(1.0)
        bButtonNode.position = CGPoint(x: size.width / 2 - 130, y: -size.height / 2 + 120)
        cameraNode.addChild(bButtonNode)
    }

    func playBackgroundMusic(filename: String) {
        if let url = Bundle.main.url(forResource: filename, withExtension: nil) {
            do {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
                backgroundMusicPlayer?.numberOfLoops = -1
                backgroundMusicPlayer?.volume = 0.35
                backgroundMusicPlayer?.prepareToPlay()
                backgroundMusicPlayer?.play()
            } catch {
                print("❌ Could not load file: \(filename)")
            }
        }
    }

    func togglePauseMenu() {
        isGamePaused.toggle()
        isPaused = isGamePaused
        onPauseToggle?(isGamePaused)
    }

    override func update(_ currentTime: TimeInterval) {
        guard !isPaused else { return }

        let speed: CGFloat = 2.0
        let dx = moveDirection.dx * speed
        let dy = moveDirection.dy * speed

        if dx < 0 { player.xScale = -1 }
        if dx > 0 { player.xScale = 1 }

        // Simple movement without collision for now
        player.position.x += dx
        player.position.y += dy

        // Update camera position
        cameraNode.position = player.position

        // Basic map boundaries
        let mapWidth = CGFloat(tileMap?.numberOfColumns ?? 0) * tileSize
        let mapHeight = CGFloat(tileMap?.numberOfRows ?? 0) * tileSize
        let halfMapWidth = mapWidth / 2
        let halfMapHeight = mapHeight / 2

        // Keep player within map bounds
        player.position.x = min(max(player.position.x, -halfMapWidth), halfMapWidth)
        player.position.y = min(max(player.position.y, -halfMapHeight), halfMapHeight)

        // Keep camera within map bounds
        let viewSize = view?.bounds.size ?? .zero
        let halfViewWidth = viewSize.width / 2
        let halfViewHeight = viewSize.height / 2

        cameraNode.position.x = min(max(cameraNode.position.x, -halfMapWidth + halfViewWidth), halfMapWidth - halfViewWidth)
        cameraNode.position.y = min(max(cameraNode.position.y, -halfMapHeight + halfViewHeight), halfMapHeight - halfViewHeight)

        if dx != 0 || dy != 0 {
            if player.action(forKey: "walk") == nil {
                let walkAction = SKAction.repeatForever(
                    SKAction.animate(with: walkFrames, timePerFrame: 0.15)
                )
                player.run(walkAction, withKey: "walk")
            }
        } else {
            player.removeAction(forKey: "walk")
            player.texture = SKTexture(imageNamed: "playerIdle")
            player.texture?.filteringMode = .nearest
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
                if isAtDoor {
                    print("🚪 At the door - ready for room transition")
                    // Here we'll add the room transition logic later
                } else {
                    print("🅰️ A Button Pressed — Toggling pause menu")
                    togglePauseMenu()
                }
            }

            if bButtonNode.contains(location) {
                print("🅱️ B Button Pressed — maybe cancel or interact?")
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        moveDirection = .zero
    }
}
