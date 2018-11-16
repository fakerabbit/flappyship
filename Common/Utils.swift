//
//  Utils.swift
//  FlappyShip
//
//  Created by Mirko Justiniano on 11/15/18.
//  Copyright © 2018 idevcode. All rights reserved.
//

import Foundation
import UIKit

struct Utils {
    
    static func randomFloat() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return Utils.randomFloat() * (max - min) + min
    }
}
