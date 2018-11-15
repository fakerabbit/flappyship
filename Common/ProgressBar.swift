//
//  ProgressBar.swift
//  FlappyShip
//
//  Created by Mirko Justiniano on 11/14/18.
//  Copyright © 2018 idevcode. All rights reserved.
//

import UIKit
import SpriteKit

class ProgressBar: SKSpriteNode {
    
    var progress:Int! {
        didSet {
            pos -= CGFloat(progress) / 2
            full -= progress
            if full > 0 {
                percentage.run(SKAction.moveTo(x: CGFloat(pos), duration: 2.0))
                percentage.run(SKAction.scale(to: CGSize(width: CGFloat(full), height: 10), duration: 2.0))
            }
        }
    }
    
    private var full = Int(100)
    private var pos = CGFloat(0)
    private var percentage: SKSpriteNode!
    
    init() {
        self.init(texture: nil)
        let percent = SKShapeNode(rectOf: CGSize(width: full, height: 10))
        percent.fillColor = SKColor(red: 33/255, green: 230/255, blue: 193/255, alpha: 1.0)
        percent.position = CGPoint(x: 0, y: 0)
        percentage = SKSpriteNode(color: UIColor(white: 1, alpha: 0), size: CGSize(width: full, height: 10))
        percentage.addChild(percent)
        self.addChild(percentage)
        
        let bar = SKShapeNode(rectOf: CGSize(width: 100, height: 10))
        bar.position = CGPoint(x: 0, y: 0)
        //bar.strokeColor = SKColor(red: 31/255, green: 66/255, blue: 135/255, alpha: 1.0)
        bar.strokeColor = SKColor(red: 1, green: 1, blue: 0, alpha: 1.0)
        self.addChild(bar)
        
        self.size = bar.frame.size
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
