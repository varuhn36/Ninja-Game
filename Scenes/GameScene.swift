//
//  GameScene.swift
//  Ninja_Sprite_Game
//
//  Created by Varuhn Anandaraj on 2023-11-09.
//

import SpriteKit
import GameplayKit
class GameScene: SKScene {
    
    var ground: SKSpriteNode!
    var player: SKSpriteNode!
    var cameraNode = SKCameraNode()
    var obstacles: [SKSpriteNode] = []
    var coin : SKSpriteNode!
    
    
    var cameraMovePointPerSecond: CGFloat = 450.0
    
    var lastUpdateTime: TimeInterval = 0.0
    var dt: TimeInterval = 0.0
    
    var isTime: CGFloat = 3.0
    var onGround = true
    var velocityY: CGFloat = 0.0
    var gravity: CGFloat = 0.6
    var playerPosY: CGFloat = 0.0
    
    var numScore: Int = 0
    var gameOver = false
    var numLives: Int = 3
    
    var lifeNodes: [SKSpriteNode] = []
    var scoreLabel = SKLabelNode(fontNamed: "Krungthep")
    var coinIcon: SKSpriteNode!
    
    var pauseNode: SKSpriteNode!
    var containerNode = SKNode()
    
    
    var soundCoin = SKAction.playSoundFileNamed("coin.mp3")
    var soundJump = SKAction.playSoundFileNamed("jump.wav")
    var soundCollision = SKAction.playSoundFileNamed("collision.wav")
    
    var playableRect : CGRect {
        let ratio: CGFloat
        switch UIScreen.main.nativeBounds.height {
        case 2688, 1792, 2436, 2778, 2832: // iPhone XS Max, XR, X/XS/11 Pro, 12 Pro Max, 13 Pro Max
            ratio = 19.5/9
        case 2048, 2160: // iPad Air (3rd, 4th, 5th generation)
            ratio = 4/3
        default:
            ratio = 16/9
        }
        
        let playableHeight = size.width/ratio
        let playableMargin = (size.height - playableHeight) / 2.0
        
        return CGRect(x: 0.0, y: playableMargin, width: size.width, height: playableHeight)
    }
    
    var cameraRect: CGRect {
        let width = playableRect.width
        let height = playableRect.height
        let x = cameraNode.position.x - size.width/2.0 + (size.width - width)/2.0
        let y = cameraNode.position.y - size.width/2.0 + (size.height - height)/2.0
        
        return CGRect(x: x, y: y, width: width, height: height)

    }
    
    
    override func didMove(to view: SKView) {
        setupNodes()
        
        SKTAudio.sharedInstance().playBGMusic("backgroundMusic.mp3")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let  touch = touches.first else {return}
        let node  = atPoint(touch.location(in: self))
        
        if node.name == "pause"  {
            if isPaused {return}
            createPanel()
            lastUpdateTime = 0.0
            dt = 0.0
            isPaused = true
        }
        else if node.name == "resume"{
            containerNode.removeFromParent()
            isPaused = false
        }
        else if node.name == "quit"{
            let scene = MainMenu(size: size)
            scene.scaleMode = scaleMode
            view!.presentScene(scene, transition: .doorsCloseVertical(withDuration: 0.8))
            
        } else {
            if !isPaused {
                if onGround {
                    onGround = false
                    velocityY = -25.0
                    run(soundJump)
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if velocityY < -12.5 {
            velocityY = -12.5
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0{
            dt = currentTime - lastUpdateTime
        }
        else{
            dt = 0
        }
            
        lastUpdateTime = currentTime
        moveCamera()
        movePlayer()
        
        velocityY += gravity
        player.position.y -= velocityY
        
        if player.position.y < playerPosY {
            player.position.y = playerPosY
            velocityY = 0.0
            onGround = true
        }
        
        if gameOver {
            let scene = GameOver(size: size)
            scene.scaleMode = scaleMode
            view!.presentScene(scene, transition: .doorsCloseVertical(withDuration: 0.8))
        }
        
        boundCheckPlayer()
    }
}


extension GameScene{
    
    func setupNodes(){
        createBG()
        createGround()
        createPlayer()
        setupCamera()
        setupObstacles()
        spawnBlock()
        createCoin()
        setupPhysics()
        spawnCoin()
        setupLife()
        setupScore()
        setupPause()
        
    }
    
    func setupPhysics() {
        physicsWorld.contactDelegate = self
    }
    
    func createBG(){
        for i in 0...2 {
            let bg = SKSpriteNode(imageNamed: "background")
            bg.name = "BG"
            bg.anchorPoint = .zero
            bg.position = CGPoint(x: CGFloat(i)*bg.frame.width, y: 0.0)
            bg.zPosition = -1.0
            addChild(bg)
        }
    }
    
    func createGround(){
        for i in 0...2{
            ground = SKSpriteNode(imageNamed: "ground")
            ground.name = "Ground"
            ground.anchorPoint = .zero
            ground.zPosition = 1.0
            ground.position = CGPoint(x: CGFloat(i) * ground.frame.width, y: 0.0)
            ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
            ground.physicsBody!.isDynamic = false
            ground.physicsBody!.affectedByGravity = false
            ground.physicsBody!.categoryBitMask = PhysicsCategory.Ground
            addChild(ground)
        }
    }
    
    func createPlayer(){
        player = SKSpriteNode(imageNamed: "ninja")
        player.name = "Player"
        player.zPosition = 5.0
        player.setScale(0.85)
        player.position = CGPoint(x: frame.width/2.0 - 100.0, y: ground.frame.height + player.frame.height/2.0)
        
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2.0)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.restitution = 0.0
        player.physicsBody!.categoryBitMask = PhysicsCategory.Player
        player.physicsBody!.contactTestBitMask = PhysicsCategory.Block | PhysicsCategory.Obstacle | PhysicsCategory.Coin
        playerPosY = player.position.y
        addChild(player)
    }
    
    func setupCamera(){
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
    }
    
    func moveCamera(){
        let amountToMove = CGPoint(x: cameraMovePointPerSecond * CGFloat(dt), y: 0.0)
        cameraNode.position += amountToMove
        
        
        enumerateChildNodes(withName: "BG") { (node, _) in
            let node = node as! SKSpriteNode
            
            if node.position.x + node.frame.width < self.cameraRect.origin.x {
                node.position = CGPoint(x: node.position.x + node.frame.width*2.0, y: node.position.y )
            }
        }
        
        
        enumerateChildNodes(withName: "Ground") { (node, _) in
            let node = node as! SKSpriteNode
            
            if node.position.x + node.frame.width < self.cameraRect.origin.x {
                node.position = CGPoint(x: node.position.x + node.frame.width*2.0, y: node.position.y )
            }
        }
    }
    
    func movePlayer() {
        let amountToMove = cameraMovePointPerSecond * CGFloat(dt)
        let rotate = CGFloat(1).degreesToRadians() * amountToMove/2.5
        player.zRotation -= rotate
        player.position.x += amountToMove
    }
    
    func setupObstacles(){
        for i in 1...3 {
            let sprite = SKSpriteNode(imageNamed:  "block-\(i)")
            sprite.name = "Block"
            obstacles.append(sprite)
        }
        
        for i in 1...2{
            let sprite = SKSpriteNode(imageNamed:  "obstacle-\(i)")
            sprite.name = "Obstacle"
            obstacles.append(sprite)
            
        }
        
        let index = Int(arc4random_uniform(UInt32(obstacles.count-1)))
        let sprite = obstacles[index].copy() as! SKSpriteNode
        sprite.zPosition = 5.0
        sprite.setScale(0.85)
        sprite.position = CGPoint(x: cameraRect.maxX + sprite.frame.width/2.0, y: ground.frame.height+sprite.frame.height/2.0)
        
        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        sprite.physicsBody!.affectedByGravity = false
        sprite.physicsBody!.isDynamic = false
        if sprite.name == "Block" {
            sprite.physicsBody!.categoryBitMask = PhysicsCategory.Block
        }
        else {
            sprite.physicsBody!.categoryBitMask = PhysicsCategory.Obstacle
        }
        
        sprite.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        addChild(sprite)
        sprite.run(.sequence([.wait(forDuration: 10.0), .removeFromParent()]))
        
    }
    
    func spawnBlock(){
        let random = Double(CGFloat.random(min: 1.5, max: isTime))
        run(.repeatForever(.sequence([.wait(forDuration: random), .run {
            [weak self] in self?.setupObstacles()
        }])))
        
        run(.repeatForever((.sequence([.wait(forDuration: 5.0), .run{
            self.isTime -= 0.01
            
            if self.isTime <= 1.5 {
                self.isTime = 1.5
            }
        }]))))
    }
    
    func createCoin() {
        coin = SKSpriteNode(imageNamed: "coin-1")
        coin.name = "Coin"
        coin.zPosition = 20.0
        coin.setScale(0.85)
        let coinHeight = coin.frame.height
        let random = CGFloat.random(min: -coinHeight, max: coinHeight*2.0)
        coin.position = CGPoint(x: cameraRect.maxX + coin.frame.width, y: size.height/2.0 + random)
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width/2.0)
        coin.physicsBody!.affectedByGravity = false
        coin.physicsBody!.isDynamic = false
        coin.physicsBody!.categoryBitMask = PhysicsCategory.Coin
        coin.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        addChild(coin)
        coin.run(.sequence([.wait(forDuration: 15.0), .removeFromParent()]))
        
        var textures : [SKTexture] = []
        for i in 1...6 {
            textures.append(SKTexture(imageNamed: "coin-\(i)"))
        }
        coin.run(.repeatForever(.animate(with: textures, timePerFrame: 0.083)))
    }
    
    func spawnCoin(){
        let random = CGFloat.random(min: 2.5, max: 6.0)
        run(.repeatForever(.sequence([.wait(forDuration: TimeInterval(random)), .run{[weak self] in
            self?.createCoin()
        }])))
    }
    
    func setupLife(){
        let node1 = SKSpriteNode(imageNamed: "life-on")
        let node2 = SKSpriteNode(imageNamed: "life-on")
        let node3 = SKSpriteNode(imageNamed: "life-on")
        setupLifePos(node1, i: 0.5, j: 50.0)
        setupLifePos(node2, i: 1.0, j: 100.0)
        setupLifePos(node3, i: 1.5, j: 150.0)
        lifeNodes.append(node1)
        lifeNodes.append(node2)
        lifeNodes.append(node3)
    }
    
    
    func setupLifePos(_ node: SKSpriteNode, i: CGFloat, j: CGFloat){
        let width =  UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        
        node.setScale(0.5)
        node.zPosition = 50.0
        node.position = CGPoint(x: -width/2.0 + node.frame.width * i + j , y: height/2.0 - node.frame.height/2.0 + 50.0)
        cameraNode.addChild(node)
    }
    
    func setupScore(){
        
        let width =  UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        
        coinIcon = SKSpriteNode(imageNamed: "coin-1")
        coinIcon.setScale(0.5)
        coinIcon.zPosition = 50.0
        coinIcon.position = CGPoint(x: -width/2.0 + coinIcon.frame.width, y: height/2.0 - lifeNodes[0].frame.height - coinIcon.frame.height/2.0)
        cameraNode.addChild(coinIcon)
        
        scoreLabel.fontSize = 60.0
        scoreLabel.horizontalAlignmentMode = .left
        coinIcon.zPosition = 50.0
        scoreLabel.position = CGPoint(x: coinIcon.position.x + coinIcon.frame.width + 10.0, y: coinIcon.position.y - 20.0)
        cameraNode.addChild(scoreLabel)
        
    }
    
    func boundCheckPlayer(){
        let bottomLeft = CGPoint(x: cameraRect.minX, y: cameraRect.minY)
        if player.position.x <= bottomLeft.x {
            player.position.x = bottomLeft.x
            lifeNodes.forEach({$0.texture = SKTexture(imageNamed: "life-off")})
            numScore = 0
            scoreLabel.text = "\(numScore)"
            gameOver = true
        }
    }
    
    func setupGameOver(){
        
        
        numLives -= 1
        if numLives <= 0 {numLives = 0}
        lifeNodes[numLives].texture = SKTexture(imageNamed: "life-off")
        
        if numLives <= 0 && !gameOver{
            gameOver = true
        }
    }
    
    func setupPause(){
        let width =  UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        
        pauseNode = SKSpriteNode(imageNamed: "pause")
        pauseNode.setScale(0.5)
        pauseNode.zPosition = 50.0
        pauseNode.name = "pause"
        pauseNode.position = CGPoint(x: width/2.0 - pauseNode.frame.width/2.0 - 10.0, y: height/2.0 - pauseNode.frame.height/2.0 - 10.0) // Adjusted x and y positions
        cameraNode.addChild(pauseNode)
    }
    
    func createPanel(){
        
        cameraNode.addChild(containerNode)
        
        let panel = SKSpriteNode(imageNamed: "panel")
        panel.zPosition = 60.0
        panel.position = .zero
        containerNode.addChild(panel)
        
        let resume = SKSpriteNode(imageNamed: "resume")
        resume.zPosition = 70.0
        resume.setScale(0.7)
        resume.name = "resume"
        resume.position = CGPoint(x:-panel.frame.width/2.0 + resume.frame.width*1.5, y: 0.0)
        panel.addChild(resume)
        
        let quit = SKSpriteNode(imageNamed: "back")
        quit.zPosition = 70.0
        quit.setScale(0.7)
        quit.name = "quit"
        quit.position = CGPoint(x: panel.frame.width/2.0 - quit.frame.width*1.5, y: 0.0)
        panel.addChild(quit)
        
        
    }
    
}

extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact){
        let other = contact.bodyA.categoryBitMask == PhysicsCategory.Player ? contact.bodyB : contact.bodyA
        
        switch other.categoryBitMask {
        case PhysicsCategory.Block:
            cameraMovePointPerSecond += 150
            numScore -= 1
            if numScore <= 0 {numScore = 0}
            scoreLabel.text = "\(numScore)"
            run(soundCollision)

        case PhysicsCategory.Obstacle:
            setupGameOver()
        case PhysicsCategory.Coin:
            if let node = other.node {
                node.removeFromParent()
                numScore += 1
                scoreLabel.text = "\(numScore)"
                if numScore % 5 == 0{
                    cameraMovePointPerSecond += 100.0
                }
                
                let highScore = ScoreGenerator.sharedInstance.getHighScore()
                if numScore > highScore{
                    ScoreGenerator.sharedInstance.setHighScore(numScore)
                    ScoreGenerator.sharedInstance.setScore(highScore)
                }
                
                run(soundCoin)
        }
        default: break
        }
    }
}
