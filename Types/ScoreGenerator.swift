//
//  ScoreGenerator.swift
//  Ninja_Sprite_Game
//
//  Created by Varuhn Anandaraj on 2023-11-10.
//

import Foundation


class ScoreGenerator {
    
    static let sharedInstance = ScoreGenerator()
    private init() {}
    
    static let keyHighScore = "keyHighScore"
    static let keyScore = "keyScore"
    
    func setScore (_ score: Int){
        UserDefaults.standard.set(score, forKey: ScoreGenerator.keyScore)
    }
    
    func getScore() -> Int {
        return UserDefaults.standard.integer(forKey: ScoreGenerator.keyScore)
    }
    
    func setHighScore (_ highScore: Int){
        UserDefaults.standard.set(highScore, forKey: ScoreGenerator.keyHighScore)
    }
    
    func getHighScore() -> Int {
       return UserDefaults.standard.integer(forKey: ScoreGenerator.keyHighScore)
    }
}
