//
//  GameViewController.swift
//  Ninja_Sprite_Game
//
//  Created by Varuhn Anandaraj on 2023-11-09.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = MainMenu(size: CGSize(width: 2048, height: 1536))
        scene.scaleMode = .aspectFill
        
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsPhysics = true
        skView.ignoresSiblingOrder = true
        skView.presentScene(scene)      
    }


    override var prefersStatusBarHidden: Bool {
        return true
    }
}
