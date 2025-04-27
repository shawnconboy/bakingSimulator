import SpriteKit
import AVFoundation

class WorldScene: SKScene {
    var tileMap: SKTileMapNode?
    let player = SKSpriteNode(imageNamed: "playerIdle")
    let cameraNode = SKCameraNode()

    var walkFrames: [SKTexture] = []

    var dpadNode: SKSpriteNode!
    var aButtonNode: SKSpriteNode!

    var moveDirection: CGVector = .zero

    var npc: SKSpriteNode!
    var dialogueBox: SKShapeNode!
    var dialogueLabels: [SKLabelNode] = []
    var dialogueLines: [String] = []
    var currentDialogueIndex = 0
    var isInteracting = false
    var hasSeenNPC = false

    var bButtonNode: SKSpriteNode!

    let tileSize: CGFloat = 64
    var columns: Int = 0
    var rows: Int = 0
    
    var canEnterShop = true



    
    // 🛡️ Tiles that are blocked and cannot be walked into
    let blockedTiles: [(Int, Int)] = [
        // Vertical wall (12,20) to (12,23)
        (12,20), (12,21), (12,22), (12,23),
        
        // Vertical wall (13,20) to (13,23)
        (13,20), (13,21), (13,22), (13,23),
        
        // Horizontal wall (9,23) to (8,23)
        (9,23), (8,23),
        
        // Horizontal wall (9,25) to (8,25)
        (9,25), (8,25),
        
        // Horizontal wall (19,21) to (20,21)
        (19,21), (20,21),
        
        // Horizontal wall (19,19) to (20,19)
        (19,19), (20,19),
        
        // Single blocked tile (19,18)
        (19,18),
        
        // Long vertical wall (0,18) to (0,28)
        (0,18), (0,19), (0,20), (0,21), (0,22),
        (0,23), (0,24), (0,25), (0,26), (0,27), (0,28)
    ]



    var stepCount = 0
    var playerXP: Int {
        get { UserDefaults.standard.integer(forKey: "playerXP") }
        set { UserDefaults.standard.set(newValue, forKey: "playerXP") }
    }
    var playerLevel: Int {
        get { UserDefaults.standard.integer(forKey: "playerLevel") == 0 ? 1 : UserDefaults.standard.integer(forKey: "playerLevel") }
        set { UserDefaults.standard.set(newValue, forKey: "playerLevel") }
    }
    
    var initialPlayerTile: (column: Int, row: Int)? = nil

    
    func setupTileMapFromImage(named imageName: String) {
        let tileSize = CGSize(width: 64, height: 64)
        let textures = MapSlicer.slice(imageNamed: imageName, tileSize: tileSize)

        if let tileMap = TileMapBuilder.buildTileMap(from: textures, tileSize: tileSize) {
            tileMap.zPosition = -10
            addChild(tileMap)
            self.tileMap = tileMap
            
            // ✅ Set columns and rows dynamically
            self.columns = textures.first?.count ?? 0
            self.rows = textures.count
        }
    }




    let xpMilestones = [1000, 2500, 5000, 10000, 20000]

    func checkLevelUp() {
        let xpNeeded = playerLevel <= xpMilestones.count ? xpMilestones[playerLevel - 1] : xpMilestones.last!
        if playerXP >= xpNeeded {
            playerXP -= xpNeeded
            playerLevel += 1
            print("✨ Level Up! Now Level \(playerLevel)")
        }
    }

    override func didMove(to view: SKView) {
        backgroundColor = .black
        anchorPoint = CGPoint(x: 0.5, y: 0.5)

        for i in 1...4 {
            let textureName = "playerWalk\(i)"
            let texture = SKTexture(imageNamed: textureName)
            texture.filteringMode = .nearest
            walkFrames.append(texture)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(handleMuteSettingChanged), name: .muteSettingChanged, object: nil)

        setupTileMapFromImage(named: "cityMap") // ✅ FIRST load the map
        setupPlayer()  // ✅ THEN spawn player
        setupNPC()     // ✅ THEN spawn NPC
        setupCamera()
        addDpad()
        setupDialogueBox()

        // 🔥 Door lockout after shop exit
        canEnterShop = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.canEnterShop = true
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


    func setupPlayer() {
        let idleTexture = SKTexture(imageNamed: "playerIdle")
        idleTexture.filteringMode = .nearest

        player.texture = idleTexture
        player.size = CGSize(width: tileSize, height: tileSize)

        if let spawnTile = initialPlayerTile {
            // ✅ Custom spawn if coming from shop
            player.position = positionForTile(column: spawnTile.column, row: spawnTile.row)
        } else {
            // ✅ Normal starting spawn
            player.position = positionForTile(column: 13, row: 13)
        }

        addChild(player)
    }



    func setupNPC() {
        npc = SKSpriteNode(imageNamed: "npcFacing1")
        npc.texture?.filteringMode = .nearest
        npc.size = CGSize(width: tileSize * 0.85, height: tileSize * 0.85)
        
        // ✅ Correct spawn position
        npc.position = positionForTile(column: 14, row: 16)
        addChild(npc)

        dialogueLines = [
            "👋 Hello, welcome to Cookie Quest!",
            "🍪 Collect ingredients and bake goodies.",
            "🏠 Visit buildings and explore around!",
            "Good luck, chef!"
        ]
    }




    func setupCamera() {
        camera = cameraNode
        cameraNode.position = player.position
        addChild(cameraNode)
    }

    func addDpad() {
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

        // 🔥 NEW - B Button
        bButtonNode = SKSpriteNode(imageNamed: "XboxSeriesX_B")
        bButtonNode.alpha = 0.8
        bButtonNode.setScale(1.0)
        bButtonNode.zPosition = 10
        bButtonNode.position = CGPoint(x: size.width / 2 - 160, y: -size.height / 2 + 140)
        cameraNode.addChild(bButtonNode)
    }



    func setupDialogueBox() {
        dialogueBox = SKShapeNode(rectOf: CGSize(width: size.width * 0.8, height: 100), cornerRadius: 10)
        dialogueBox.fillColor = .black
        dialogueBox.strokeColor = .white
        dialogueBox.alpha = 0.8
        dialogueBox.zPosition = 99
        dialogueBox.isHidden = true
        dialogueBox.position = CGPoint(x: 0, y: size.height / 2 - 140)
        cameraNode.addChild(dialogueBox)
    }

    func showDialogue(text: String) {
        dialogueBox.removeAllChildren()

        let label = SKLabelNode(text: text)
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 18
        label.fontColor = .white
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = dialogueBox.frame.width - 40
        
        // ✨ CENTER IT
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center

        label.position = .zero

        dialogueBox.addChild(label)

        dialogueBox.isHidden = false
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
                if isInteracting {
                    currentDialogueIndex += 1
                    if currentDialogueIndex < dialogueLines.count {
                        showDialogue(text: dialogueLines[currentDialogueIndex])
                    } else {
                        dialogueBox.isHidden = true
                        isInteracting = false
                        currentDialogueIndex = 0
                    }
                } else {
                    // 🔥 If not currently interacting, check if close to NPC to restart dialogue
                    if player.position.distance(to: npc.position) < tileSize * 1.5 {
                        isInteracting = true
                        currentDialogueIndex = 0
                        showDialogue(text: dialogueLines[currentDialogueIndex])
                    }
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

        let playerHalfWidth = player.size.width / 2
        let playerHalfHeight = player.size.height / 2
        let mapWidth = tileSize * CGFloat(columns)
        let mapHeight = tileSize * CGFloat(rows)

        // 🛡️ Blocked tile checking
        let playerCol = Int((player.position.x + (tileSize * CGFloat(columns)) / 2 - 24) / tileSize)
        let playerRow = Int((player.position.y + (tileSize * CGFloat(rows)) / 2) / tileSize)

        if blockedTiles.contains(where: { $0 == (playerCol, playerRow) }) {
            player.position.x -= moveDirection.dx * 2.0
            player.position.y -= moveDirection.dy * 2.0
        }

        // 🛡️ Clamp player inside actual map
        player.position.x = min(max(player.position.x, -mapWidth/2 + playerHalfWidth), mapWidth/2 - playerHalfWidth)
        player.position.y = min(max(player.position.y, -mapHeight/2 + playerHalfHeight), mapHeight/2 - playerHalfHeight)

        cameraNode.position = player.position

        let cameraHalfWidth = size.width / 2
        let cameraHalfHeight = size.height / 2

        // 🛡️ Clamp camera to world edges
        cameraNode.position.x = min(max(cameraNode.position.x, -mapWidth/2 + cameraHalfWidth), mapWidth/2 - cameraHalfWidth)
        cameraNode.position.y = min(max(cameraNode.position.y, -mapHeight/2 + cameraHalfHeight), mapHeight/2 - cameraHalfHeight)

        // 🎯 Door detection (automatic scene transfer)
        let doorPosition = positionForTile(column: 20, row: 19)
        if player.position.distance(to: doorPosition) < tileSize * 1.0 {
            if canEnterShop {
                enterShop()
            }
        }


        // ✅ Walking animation
        if moveDirection.dx != 0 || moveDirection.dy != 0 {
            stepCount += 1
            if stepCount >= 100 {
                stepCount = 0
                playerXP += 100
                print("🎉 Earned XP! Total XP: \(playerXP)")
                checkLevelUp()
            }

            startWalkingAnimation()

            if moveDirection.dx < 0 {
                player.xScale = -1.0
            } else if moveDirection.dx > 0 {
                player.xScale = 1.0
            }
        } else {
            stopWalkingAnimation()
        }

        // ✅ NPC dialogue pop-up
        if !isInteracting && !hasSeenNPC && player.position.distance(to: npc.position) < tileSize * 1.5 {
            showDialogue(text: dialogueLines[0])
            isInteracting = true
            hasSeenNPC = true
            currentDialogueIndex = 0
        }
    }
    
    

    
    

    @objc func handleMuteSettingChanged() {
        applyMuteSetting()
    }

    func applyMuteSetting() {
        if UserDefaults.standard.bool(forKey: "isMusicMuted") {
            MusicManager.shared.setVolume(0.0)
        } else {
            MusicManager.shared.setVolume(0.5)
        }
    }

    
    
    func enterShop() {
        let shopScene = ShopScene(size: self.size)
        shopScene.scaleMode = .resizeFill

        let transition = SKTransition.fade(withDuration: 1.0)
        self.view?.presentScene(shopScene, transition: transition)
    }
}





extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let dx = x - point.x
        let dy = y - point.y
        return sqrt(dx * dx + dy * dy)
    }
}

// ✅ Separate extension
extension WorldScene {
    func positionForTile(column: Int, row: Int) -> CGPoint {
        guard let tileMap = tileMap else { return .zero }
        return tileMap.centerOfTile(atColumn: column, row: row)
    }
}
