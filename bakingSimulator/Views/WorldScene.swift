import SpriteKit
import AVFoundation

class WorldScene: SKScene {
    var tileMap: SKTileMapNode?
    let player = SKSpriteNode(imageNamed: "playerIdle")
    let cameraNode = SKCameraNode()

    var backgroundMusicPlayer: AVAudioPlayer?
    let backgroundTracks = ["lofi1", "lofi2", "lofi3", "lofi4"]

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
    let columns = 50
    let rows = 50

    var stepCount = 0
    var playerXP: Int {
        get { UserDefaults.standard.integer(forKey: "playerXP") }
        set { UserDefaults.standard.set(newValue, forKey: "playerXP") }
    }
    var playerLevel: Int {
        get { UserDefaults.standard.integer(forKey: "playerLevel") == 0 ? 1 : UserDefaults.standard.integer(forKey: "playerLevel") }
        set { UserDefaults.standard.set(newValue, forKey: "playerLevel") }
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

        playBackgroundMusic()

        NotificationCenter.default.addObserver(self, selector: #selector(handleMuteSettingChanged), name: .muteSettingChanged, object: nil)

        setupTileMap()
        setupPlayer()
        setupNPC()
        setupCamera()
        addDpad()
        setupDialogueBox()
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

    func playBackgroundMusic() {
        if let randomTrack = backgroundTracks.randomElement(),
           let url = Bundle.main.url(forResource: randomTrack, withExtension: "mp3") {
            do {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
                backgroundMusicPlayer?.numberOfLoops = -1
                backgroundMusicPlayer?.prepareToPlay()
                backgroundMusicPlayer?.play()

                applyMuteSetting()
            } catch {
                print("🎵 Error loading background music: \(error)")
            }
        }
    }

    func setupTileMap() {
        let tileSet = SKTileSet()
        let grassTileGroup = SKTileGroup(tileDefinition: SKTileDefinition(texture: SKTexture(imageNamed: "tileGrass")))
        tileSet.tileGroups = [grassTileGroup]

        let map = SKTileMapNode(tileSet: tileSet, columns: columns, rows: rows, tileSize: CGSize(width: tileSize, height: tileSize))
        map.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        map.position = .zero

        for col in 0..<columns {
            for row in 0..<rows {
                map.setTileGroup(grassTileGroup, forColumn: col, row: row)
            }
        }

        addChild(map)
        self.tileMap = map
    }

    func setupPlayer() {
        let idleTexture = SKTexture(imageNamed: "playerIdle")
        idleTexture.filteringMode = .nearest

        player.texture = idleTexture
        player.size = CGSize(width: tileSize, height: tileSize)
        player.position = CGPoint(x: 0, y: 0)
        addChild(player)
    }

    func setupNPC() {
        npc = SKSpriteNode(imageNamed: "npcFacing1")
        npc.texture?.filteringMode = .nearest
        npc.size = CGSize(width: tileSize * 0.85, height: tileSize * 0.85) // 👈 scale down
        npc.position = CGPoint(x: tileSize * 5, y: tileSize * 5)
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

        // 🛡️ Clamp player inside actual map
        player.position.x = min(max(player.position.x, -mapWidth/2 + playerHalfWidth), mapWidth/2 - playerHalfWidth)
        player.position.y = min(max(player.position.y, -mapHeight/2 + playerHalfHeight), mapHeight/2 - playerHalfHeight)

        cameraNode.position = player.position

        let cameraHalfWidth = size.width / 2
        let cameraHalfHeight = size.height / 2

        // 🛡️ Clamp camera to world edges
        cameraNode.position.x = min(max(cameraNode.position.x, -mapWidth/2 + cameraHalfWidth), mapWidth/2 - cameraHalfWidth)
        cameraNode.position.y = min(max(cameraNode.position.y, -mapHeight/2 + cameraHalfHeight), mapHeight/2 - cameraHalfHeight)

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
            backgroundMusicPlayer?.volume = 0
        } else {
            backgroundMusicPlayer?.volume = 0.5
        }
    }
}

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let dx = x - point.x
        let dy = y - point.y
        return sqrt(dx * dx + dy * dy)
    }
}
