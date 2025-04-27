import SpriteKit

struct ShopItem {
    var name: String
    var price: Int
    var maxQuantity: Int
}

struct InventorySlot {
    var itemName: String
    var quantity: Int
    var maxQuantity: Int
}

class ShopScene: SKScene {
    var tileMap: SKTileMapNode?
    let player = SKSpriteNode(imageNamed: "playerIdle")
    let cameraNode = SKCameraNode()
    
    var shopScrollNode: SKNode!
    var cartScrollNode: SKNode!
    
    var playerReturnTile: (column: Int, row: Int)?



    var walkFrames: [SKTexture] = []

    var dpadNode: SKSpriteNode!
    var aButtonNode: SKSpriteNode!
    var bButtonNode: SKSpriteNode!

    var moveDirection: CGVector = .zero
    let tileSize: CGFloat = 64

    var collisionRects: [CGRect] = []

    var shopkeeper: SKSpriteNode!
    var isInteractingWithShopkeeper = false

    var shopItems: [ShopItem] = []
    var cartItems: [InventorySlot] = []
    var playerInventory: [InventorySlot] = []
    var playerMoney: Int = 20
    var maxInventorySlots: Int = 5

    var shopMenuContainer: SKNode?
    var shopItemButtons: [SKLabelNode] = []
    var cartItemLabels: [SKLabelNode] = []
    var confirmButton: SKLabelNode?
    var closeButton: SKLabelNode?
    var isShopMenuOpen = false

    var moneyLabel: SKLabelNode?
    var shopScrollOffset: CGFloat = 0
    var cartScrollOffset: CGFloat = 0

    override func didMove(to view: SKView) {
        backgroundColor = .black
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        setupTileMapFromImage(named: "shopMap")

        let idleTexture = SKTexture(imageNamed: "playerIdle")
        idleTexture.filteringMode = .nearest
        player.texture = idleTexture
        player.size = CGSize(width: tileSize, height: tileSize)
        player.position = CGPoint(x: 0, y: 0)
        addChild(player)

        for i in 1...4 {
            let textureName = "playerWalk\(i)"
            let texture = SKTexture(imageNamed: textureName)
            texture.filteringMode = .nearest
            walkFrames.append(texture)
        }

        setupShopItems()
        setupPlayerInventory()
        setupShopkeeper()

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

    func setupShopItems() {
        shopItems = [
            ShopItem(name: "Flour", price: 2, maxQuantity: 10),
            ShopItem(name: "Sugar", price: 2, maxQuantity: 8),
            ShopItem(name: "Chocolate Chips", price: 3, maxQuantity: 6),
            ShopItem(name: "Baking Powder", price: 1, maxQuantity: 5),
            ShopItem(name: "Butter", price: 2, maxQuantity: 6)
        ]
    }
    
    func createCartItemButton(item: InventorySlot) -> SKShapeNode {
        let button = SKShapeNode(rectOf: CGSize(width: size.width * 0.7, height: 40), cornerRadius: 10)
        button.fillColor = .lightGray
        button.strokeColor = .black
        button.lineWidth = 2

        let nameLabel = SKLabelNode(text: "\(item.itemName) x\(item.quantity)")
        nameLabel.fontName = "AvenirNext-Regular"
        nameLabel.fontSize = 20
        nameLabel.fontColor = .black
        nameLabel.position = CGPoint(x: 0, y: -10)
        nameLabel.zPosition = 1003
        button.addChild(nameLabel)

        return button
    }


    func setupPlayerInventory() {
        playerInventory = []
    }

    func setupShopkeeper() {
        shopkeeper = SKSpriteNode(imageNamed: "npcFacing1")
        shopkeeper.texture?.filteringMode = .nearest
        shopkeeper.size = CGSize(width: tileSize, height: tileSize)

        if let tileMap = tileMap {
            let middleRow = tileMap.numberOfRows / 2
            let shopkeeperPosition = CGPoint(
                x: (-tileMap.mapSize.width / 2) + (tileSize * 1),
                y: (-tileMap.mapSize.height / 2) + (tileSize * CGFloat(middleRow))
            )
            shopkeeper.position = shopkeeperPosition
        } else {
            shopkeeper.position = CGPoint(x: 0, y: 0)
        }

        addChild(shopkeeper)
    }

    func setupTileMapFromImage(named imageName: String) {
        let textures = MapSlicer.slice(imageNamed: imageName, tileSize: CGSize(width: 64, height: 64))
        if let tileMap = TileMapBuilder.buildTileMap(from: textures, tileSize: CGSize(width: 64, height: 64)) {
            tileMap.zPosition = -10
            addChild(tileMap)
            self.tileMap = tileMap
        }
    }

    func addToCart(item: ShopItem) {
        if let index = cartItems.firstIndex(where: { $0.itemName == item.name }) {
            if cartItems[index].quantity < item.maxQuantity {
                cartItems[index].quantity += 1
            }
        } else {
            cartItems.append(InventorySlot(itemName: item.name, quantity: 1, maxQuantity: item.maxQuantity))
        }
        updateShopAndCartDisplay()
    }

    func showThankYouPopup() {
        let thankYouBox = SKShapeNode(rectOf: CGSize(width: size.width * 0.6, height: 100), cornerRadius: 20)
        thankYouBox.fillColor = .white
        thankYouBox.strokeColor = .black
        thankYouBox.zPosition = 500
        thankYouBox.position = CGPoint(x: 0, y: 0)

        let thankYouLabel = SKLabelNode(text: "\u{1F6D2} Thank you for your purchase!")
        thankYouLabel.fontName = "AvenirNext-Bold"
        thankYouLabel.fontSize = 24
        thankYouLabel.fontColor = .black
        thankYouLabel.zPosition = 510

        thankYouBox.addChild(thankYouLabel)
        addChild(thankYouBox)

        thankYouBox.run(SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.removeFromParent()
        ]))
    }

    func openShopMenu() {
        guard !isShopMenuOpen else { return }
        isShopMenuOpen = true
        moveDirection = .zero

        shopMenuContainer = SKNode()
        shopMenuContainer?.zPosition = 1000
        cameraNode.addChild(shopMenuContainer!)

        let menuWidth = size.width * 0.9
        let menuHeight = size.height * 0.8

        // Background
        let background = SKShapeNode(rectOf: CGSize(width: menuWidth, height: menuHeight), cornerRadius: 30)
        background.fillColor = .white
        background.strokeColor = .black
        background.lineWidth = 4
        background.position = CGPoint(x: 0, y: size.height * 0.05 / 2)
        background.zPosition = 1001
        shopMenuContainer?.addChild(background)

        // Title
        let titleLabel = SKLabelNode(text: "🛒 Shop")
        titleLabel.fontName = "AvenirNext-Bold"
        titleLabel.fontSize = 30
        titleLabel.fontColor = .black
        titleLabel.position = CGPoint(x: 0, y: background.frame.height / 2 - 60)
        titleLabel.zPosition = 1002
        background.addChild(titleLabel)

        // Money label
        moneyLabel = SKLabelNode(text: "💵 $\(playerMoney)")
        moneyLabel?.fontName = "AvenirNext-Bold"
        moneyLabel?.fontSize = 24
        moneyLabel?.fontColor = .systemGreen
        moneyLabel?.position = CGPoint(x: 0, y: background.frame.height / 2 - 100)
        moneyLabel?.zPosition = 1002
        background.addChild(moneyLabel!)

        // Shop Scroll Node (top half)
        shopScrollNode = SKNode()
        shopScrollNode.position = CGPoint(x: 0, y: background.frame.height / 2 - 160)
        shopScrollNode.zPosition = 1002
        background.addChild(shopScrollNode)

        // Divider
        let divider = SKShapeNode(rectOf: CGSize(width: menuWidth * 0.8, height: 2))
        divider.fillColor = .lightGray
        divider.strokeColor = .clear
        divider.position = CGPoint(x: 0, y: 0)
        divider.zPosition = 1002
        background.addChild(divider)

        // Cart Scroll Node (bottom half)
        cartScrollNode = SKNode()
        cartScrollNode.position = CGPoint(x: 0, y: -40)
        cartScrollNode.zPosition = 1002
        background.addChild(cartScrollNode)

        // Confirm and Close buttons
        confirmButton = SKLabelNode(text: "✅ Confirm Purchase")
        confirmButton?.fontName = "AvenirNext-Bold"
        confirmButton?.fontSize = 26
        confirmButton?.fontColor = .systemBlue
        confirmButton?.position = CGPoint(x: 0, y: -background.frame.height / 2 + 80)
        confirmButton?.zPosition = 1002
        confirmButton?.name = "confirmButton"
        background.addChild(confirmButton!)

        closeButton = SKLabelNode(text: "❌ Close")
        closeButton?.fontName = "AvenirNext-Bold"
        closeButton?.fontSize = 24
        closeButton?.fontColor = .red
        closeButton?.position = CGPoint(x: 0, y: -background.frame.height / 2 + 30)
        closeButton?.zPosition = 1002
        closeButton?.name = "closeButton"
        background.addChild(closeButton!)

        updateShopAndCartDisplay()
    }


    

        func confirmPurchase() {
            let totalCost = cartItems.reduce(0) { partialResult, cartItem in
                let matchingShopItem = shopItems.first(where: { shopItem in
                    shopItem.name == cartItem.itemName
                })
                return partialResult + (matchingShopItem?.price ?? 0) * cartItem.quantity
            }

            guard totalCost <= playerMoney else {
                showNotEnoughMoneyPopup()
                return
            }

            for cartItem in cartItems {
                if let index = playerInventory.firstIndex(where: { $0.itemName == cartItem.itemName }) {
                    playerInventory[index].quantity += cartItem.quantity
                } else {
                    playerInventory.append(cartItem)
                }
            }

            playerMoney -= totalCost
            cartItems.removeAll()
            moneyLabel?.text = "💵 Money: $\(playerMoney)"

            showThankYouPopup()
            closeShopMenu()
        }

        func showNotEnoughMoneyPopup() {
            let popup = SKShapeNode(rectOf: CGSize(width: size.width * 0.7, height: 100), cornerRadius: 20)
            popup.fillColor = .white
            popup.strokeColor = .red
            popup.lineWidth = 4
            popup.zPosition = 2000
            popup.position = .zero

            let label = SKLabelNode(text: "Not enough money!")
            label.fontName = "AvenirNext-Bold"
            label.fontSize = 26
            label.fontColor = .red
            label.zPosition = 2001

            popup.addChild(label)
            addChild(popup)

            popup.run(SKAction.sequence([
                SKAction.wait(forDuration: 2.0),
                SKAction.removeFromParent()
            ]))
        }


    func updateShopAndCartDisplay() {
        shopScrollNode.removeAllChildren()
        cartScrollNode.removeAllChildren()

        // 🛒 Shop Items (scroll separately)
        for (index, item) in shopItems.enumerated() {
            let button = createShopItemButton(item: item, index: index)
            button.position = CGPoint(x: 0, y: -CGFloat(index) * 50)
            button.name = "shopItemButton_\(index)"
            shopScrollNode.addChild(button)
        }

        // 🛍️ Cart Items (scroll separately)
        for (index, cartItem) in cartItems.enumerated() {
            let button = createCartItemButton(item: cartItem)
            button.position = CGPoint(x: 0, y: -CGFloat(index) * 50)
            button.name = "cartItemButton_\(index)"
            cartScrollNode.addChild(button)
        }
    }


    


    func closeShopMenu() {
        shopMenuContainer?.removeFromParent()
        shopItemButtons.removeAll()
        cartItemLabels.removeAll()
        isShopMenuOpen = false
    }
    
    func createShopItemButton(item: ShopItem, index: Int) -> SKShapeNode {
        let button = SKShapeNode(rectOf: CGSize(width: size.width * 0.7, height: 40), cornerRadius: 10)
        button.fillColor = .lightGray
        button.strokeColor = .black
        button.lineWidth = 2
        button.zPosition = 1002
        button.name = "shopItemButton_\(index)" // 👈 Use index instead of name

        let nameLabel = SKLabelNode(text: item.name)
        nameLabel.fontName = "AvenirNext-Bold"
        nameLabel.fontSize = 20
        nameLabel.fontColor = .black
        nameLabel.horizontalAlignmentMode = .left
        nameLabel.verticalAlignmentMode = .center // ✅ Center vertically
        nameLabel.position = CGPoint(x: -button.frame.width / 2 + 20, y: 0) // ✅ center Y
        nameLabel.zPosition = 1003
        button.addChild(nameLabel)

        let priceLabel = SKLabelNode(text: "$\(item.price)")
        priceLabel.fontName = "AvenirNext-Regular"
        priceLabel.fontSize = 18
        priceLabel.fontColor = .darkGray
        priceLabel.horizontalAlignmentMode = .right
        priceLabel.verticalAlignmentMode = .center // ✅ Center vertically
        priceLabel.position = CGPoint(x: button.frame.width / 2 - 20, y: 0) // ✅ center Y
        priceLabel.zPosition = 1003
        button.addChild(priceLabel)


        return button
    }


    func highlightButton(_ node: SKNode) {
        if let button = node as? SKShapeNode {
            button.fillColor = .darkGray
        }
    }

    func unhighlightButton(_ node: SKNode) {
        if let button = node as? SKShapeNode {
            button.fillColor = .lightGray
        }
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: isShopMenuOpen ? shopMenuContainer! : cameraNode)

            if isShopMenuOpen {
                for node in shopMenuContainer!.nodes(at: location) {
                    if let buttonName = node.name {
                        if buttonName.starts(with: "shopItemButton_") {
                            if let indexString = buttonName.split(separator: "_").last,
                               let index = Int(indexString),
                               index < shopItems.count {

                                let button = node as? SKShapeNode
                                button?.fillColor = .darkGray
                                button?.run(SKAction.sequence([
                                    SKAction.wait(forDuration: 0.15),
                                    SKAction.run {
                                        button?.fillColor = .lightGray
                                        self.addToCart(item: self.shopItems[index])
                                        self.updateShopAndCartDisplay()
                                    }
                                ]))
                                return
                            }
                        }

                        if buttonName.starts(with: "cartItemButton_") {
                            if let indexString = buttonName.split(separator: "_").last,
                               let index = Int(indexString),
                               index < cartItems.count {

                                if cartItems[index].quantity > 1 {
                                    cartItems[index].quantity -= 1
                                } else {
                                    cartItems.remove(at: index)
                                }
                                updateShopAndCartDisplay()
                                return
                            }
                        }

                        if node == confirmButton {
                            confirmPurchase()
                            closeShopMenu()
                            return
                        }

                        if node == closeButton {
                            closeShopMenu()
                            return
                        }
                    }
                }
                return
            }

            // 🎮 D-Pad movement if shop menu closed
            let locationInCamera = touch.location(in: cameraNode)

            if dpadNode.contains(locationInCamera) {
                let center = dpadNode.position
                let dx = locationInCamera.x - center.x
                let dy = locationInCamera.y - center.y

                if abs(dx) > abs(dy) {
                    moveDirection = dx > 0 ? CGVector(dx: 1, dy: 0) : CGVector(dx: -1, dy: 0)
                } else {
                    moveDirection = dy > 0 ? CGVector(dx: 0, dy: 1) : CGVector(dx: 0, dy: -1)
                }
            }

            if aButtonNode.contains(locationInCamera) {
                if player.position.distance(to: shopkeeper.position) < tileSize * 2.5 {
                    openShopMenu()
                }
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        moveDirection = .zero

        if isShopMenuOpen {
            self.view?.gestureRecognizers?.forEach { $0.isEnabled = false; $0.isEnabled = true }
        }
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

        // 🚪 Door detection
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

        if let returnTile = playerReturnTile {
            worldScene.lastPlayerTileBeforeShop = returnTile // ✅ restore player tile
        }

        let transition = SKTransition.fade(withDuration: 1.0)
        self.view?.presentScene(worldScene, transition: transition)
    }


}
