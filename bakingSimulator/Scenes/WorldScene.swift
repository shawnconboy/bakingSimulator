import SpriteKit
import AVFoundation

class WorldScene: SKScene {
    var tilemap: SKNode? // Placeholder since SKTiled was removed
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
    var moveDirection: CGVector = .zero

    override func didMove(to view: SKView) {
        backgroundColor = .black

        // Setup tilemap placeholder
        tilemap = SKNode()
        tilemap?.position = CGPoint(x: frame.midX, y: frame.midY)
        if let tilemap = tilemap {
            addChild(tilemap)
        }

        setupPlayer()
        setupNPC()
        loadWalkTextures()
        addDpadAndButtons()

        camera = cameraNode
        addChild(cameraNode)
        cameraNode.position = player.position

        let musicOptions = ["lofi1.mp3", "lofi2.mp3", "lofi3.mp3", "lofi4.mp3"]
        if let randomTrack = musicOptions.randomElement() {
            playBackgroundMusic(filename: randomTrack)
        }
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
        player.position = CGPoint(x: tileSize * 25 + tileSize / 2, y: tileSize * 23 + tileSize / 2)
        addChild(player)
    }

    func setupNPC() {
        npc = SKSpriteNode(imageNamed: "npcFacing1")
        npc.texture?.filteringMode = .nearest
        npc.size = CGSize(width: tileSize, height: tileSize)
        npc.setScale(0.85)
        npc.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        npc.position = CGPoint(x: tileSize * 25 + tileSize / 2, y: tileSize * 25 + tileSize / 2)
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

        player.position.x += dx
        player.position.y += dy

        cameraNode.position = player.position

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
                print("🅰️ A Button Pressed — Toggling pause menu")
                togglePauseMenu()
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
