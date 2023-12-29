//
//  CGFloat_Ext.swift
//  Ninja_Sprite_Game
//
//  Created by Varuhn Anandaraj on 2023-11-09.
//

import CoreGraphics

public let pie = CGFloat.pi

extension CGFloat {
    func radiansToDegress() -> CGFloat {
        return self * 180.0 / pie
    }
    
    func degreesToRadians() -> CGFloat {
        return self * pie / 180.0
    }
    
    static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(0xFFFFFFFF))
    }
    
    static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        assert(min < max)
        return CGFloat.random() * (max-min) + min
    }
}
