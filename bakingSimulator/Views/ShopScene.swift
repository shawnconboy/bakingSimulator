import SpriteKit
import AVFoundation

class ShopScene: SKScene {
    var tileMap: SKTileMapNode?
    let player = SKSpriteNode(imageNamed: "playerIdle")
    let cameraNode = SKCameraNode()
    
    var backgroundMusicPlayer: AVAudioPlayer?
    let backgroundTracks = ["lofi1", "lofi2", "lofi3", "lofi4"]
    
    var walkFrames: [SKTexture] = []
    
    var dpadNode: SKSpriteNode!
    var aButtonNode: SKSpriteNode!
    var bButtonNode: SKSpriteNode!
    
    var moveDirection: CGVector = .zero // ✅ Declare only once (if you don't have it already)
    
    override func didMove(to view: SKView) {
        backgroundColor = .white
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        // Setup player
        let idleTexture = SKTexture(imageNamed: "playerIdle")
        idleTexture.filteringMode = .nearest
        player.texture = idleTexture
        player.size = CGSize(width: 64, height: 64)
        player.position = CGPoint(x: 0, y: 0)
        addChild(player)
        
        // Setup walk frames
        for i in 1...4 {
            let textureName = "playerWalk\(i)"
            let texture = SKTexture(imageNamed: textureName)
            texture.filteringMode = .nearest
            walkFrames.append(texture)
        }
        
        // Setup camera
        camera = cameraNode
        cameraNode.position = player.position
        addChild(cameraNode)
        
        // Setup D-pad and buttons
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
            
            if bButtonNode.contains(location) {
                print("🚪 Leave Shop (not built yet)")
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
        
        cameraNode.position = player.position
        
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
}
