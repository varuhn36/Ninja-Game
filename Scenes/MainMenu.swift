//
//  MainMenu.swift
//  Ninja_Sprite_Game
//
//  Created by Varuhn Anandaraj on 2023-11-10.
//

import SpriteKit

class MainMenu: SKScene {
    
    var containerNode: SKSpriteNode!
    
    override func didMove(to view : SKView){
        setupBG()
        setupGrounds()
        setupNodes()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else {return}
        let node = atPoint(touch.location(in: self))
        
        if node.name == "play" {
            print("Play button clicked!")
            let scene = GameScene(size: size)
            scene.scaleMode = scaleMode
            view!.presentScene(scene, transition: .doorsOpenVertical(withDuration: 0.3))
        }
        else if node.name == "highScore" {
            print("Highscore Button Clicked")
            setupPanel()
        }
        else if node.name == "setting"{
            setupSetting()
        }
        else if node.name == "container"{
            containerNode.removeFromParent()
        }
        else if node.name == "music" {
            let node = node as! SKSpriteNode
            SKTAudio.musicEnabled = !SKTAudio.musicEnabled
            node.texture = SKTexture(imageNamed: SKTAudio.musicEnabled ? "musicOn" : "musicOff")
        }
        else if node.name == "effect" {
            let node = node as! SKSpriteNode
            effectEnabled = !effectEnabled
            node.texture = SKTexture(imageNamed: effectEnabled ? "musicOn" : "musicOff")
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        moveGrounds()
    }
    
}

extension MainMenu {
    func setupBG(){
        let bgNode = SKSpriteNode(imageNamed: "background")
        bgNode.zPosition = -1.0
        bgNode.anchorPoint = .zero
        bgNode.position = .zero
        addChild(bgNode)
    }
    
    func setupGrounds() {
        for i in 0...2 {
            let groundNode = SKSpriteNode(imageNamed: "ground")
            groundNode.name = "ground"
            groundNode.anchorPoint = .zero
            groundNode.zPosition = 1.0
            groundNode.position = CGPoint(x: -CGFloat(i)*groundNode.frame.width, y: 0.0)
            addChild(groundNode)
        }
    }
    
    func moveGrounds(){
        enumerateChildNodes(withName: "ground") {(node, _) in
            let node = node as! SKSpriteNode
            node.position.x = -8.0
            
            if node.position.x < -self.frame.width{
                node.position.x += node.frame.width*2.0
            }
        }
    }
    
    func setupNodes(){
        let play = SKSpriteNode(imageNamed: "play")
        play.name = "play"
        play.setScale(0.85)
        play.zPosition = 10.0
        play.position = CGPoint(x: size.width/2.0, y: size.height/2.0 - play.size.height + 400.0)
        addChild(play)
        
        let highScore = SKSpriteNode(imageNamed: "highscore")
        highScore.name = "highScore"
        highScore.setScale(0.85)
        highScore.zPosition = 10.0
        highScore.position = CGPoint(x: size.width/2.0, y: size.height/2.0 - highScore.size.height + 175.0)
        addChild(highScore)
        
        let setting = SKSpriteNode(imageNamed: "setting")
        setting.name = "setting"
        setting.setScale(0.85)
        setting.zPosition = 10.0
        setting.position = CGPoint(x: size.width/2.0, y: size.height/2.0 - setting.size.height - 50.0)
        addChild(setting)
    }
    
    func setupPanel() {
        setupContainer()
        
        let panel = SKSpriteNode(imageNamed: "panel")
        panel.setScale(1.5)
        panel.zPosition = 20.0
        panel.position = CGPoint(x: 0, y: 0)  // Centering the panel in the containerNode
        containerNode.addChild(panel)
        
        let highScoreLabel = SKLabelNode(fontNamed: "Krungthep")
        highScoreLabel.text = "Highscore: \(ScoreGenerator.sharedInstance.getHighScore())"
        highScoreLabel.horizontalAlignmentMode = .center
        highScoreLabel.fontSize = 80.0
        highScoreLabel.zPosition = 25.0
        highScoreLabel.position = CGPoint(x: 0, y: highScoreLabel.frame.height/2)
        panel.addChild(highScoreLabel)
        
        let scoreLabel = SKLabelNode(fontNamed: "Krungthep")
        scoreLabel.text = "Score: \(ScoreGenerator.sharedInstance.getScore())"
        scoreLabel.fontSize = 80.0
        scoreLabel.zPosition = 25.0
        scoreLabel.position = CGPoint(x: 0, y: -scoreLabel.frame.height*1.5)
        panel.addChild(scoreLabel)
    }

    func setupContainer(){
        containerNode = SKSpriteNode()
        containerNode.name = "container"
        containerNode.zPosition = 15.0
        containerNode.color = .clear
        containerNode.size = size
        containerNode.position = CGPoint(x: size.width/2.0, y: size.height/2.0)
        addChild(containerNode)
    }
    
    func setupSetting(){
        setupContainer()
        
        let panel = SKSpriteNode(imageNamed: "panel")
        panel.setScale(1.5)
        panel.zPosition = 20.0
        panel.position = CGPoint(x: 0, y: 0)  // Centering the panel in the containerNode
        containerNode.addChild(panel)
        
        let music = SKSpriteNode(imageNamed: SKTAudio.musicEnabled ? "musicOn" : "musicOff")
        music.name = "music"
        music.setScale(0.7)
        music.zPosition = 25.0
        music.position = CGPoint(x: -music.frame.width - 50.0, y: 0.0)  // Centering the panel in the containerNode
        panel.addChild(music)
        
        let effect = SKSpriteNode(imageNamed: effectEnabled ?  "effectOn" : "effectOff")
        effect.name = "effect"
        effect.setScale(0.7)
        effect.zPosition = 25.0
        effect.position = CGPoint(x: music.frame.width + 50.0, y: 0.0)  // Centering the panel in the containerNode
        panel.addChild(effect)
    }


}
