//
//  ParallaxView.swift
//  FlappyShip
//
//  Created by Mirko Justiniano on 11/4/18.
//  Copyright © 2018 idevcode. All rights reserved.
//

import UIKit
import GameplayKit

class ParallaxView: SKScene, SKPhysicsContactDelegate {
    
    var xAcceleration:CGFloat = 0
    let minDistance:CGFloat = 25
    let minSpeed:CGFloat = 1000
    let maxSpeed:CGFloat = 6000
    
    let kShipName = "ship"
    let kShipFiredBulletName = "shipFiredBullet"
    let kInvaderFiredBulletName = "invaderFiredBullet"
    let kBulletSize = CGSize(width:4, height: 8)
    
    var player: SKSpriteNode!
    var start:(location:CGPoint, time:TimeInterval)?
    var tapQueue = [Int]()
    
    override func didMove(to view: SKView) {
        //createSky()
        player = SKSpriteNode(imageNamed: "ship")
        player.name = kShipName
        player.size = CGSize(width: 50, height: 50)
        player.position = CGPoint(x: self.frame.size.width / 2, y: player.size.height / 2 + 20)
        if let particles = SKEmitterNode(fileNamed: "Fire.sks") {
            particles.position = CGPoint(x: 0, y: -15)
            player.addChild(particles)
        }
        self.addChild(player)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
        
        if let touch = touches.first {
            start = (touch.location(in:self), touch.timestamp)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
        
        var swiped = false
        if let touch = touches.first,
            let startLocation = self.start?.location {
            let location = touch.location(in:self)
            let dx = location.x - startLocation.x
            let dy = location.y - startLocation.y
            let distance = sqrt(dx*dx+dy*dy)
            
            // Check if the user's finger moved a minimum distance
            if distance > minDistance {
                
                // Determine the direction of the swipe
                let x = abs(dx/distance) > 0.4 ? Int(sign(Float(dx))) : 0
                let y = abs(dy/distance) > 0.4 ? Int(sign(Float(dy))) : 0
                swiped = true
                var impulse: CGFloat = 0
                
                switch (x,y) {
                case (0,1):
                    print("swiped up")
                    impulse = 40
                case (0,-1):
                    print("swiped down")
                    impulse = -40
                case (-1,0):
                    print("swiped left")
                    impulse = -40
                case (1,0):
                    print("swiped right")
                    impulse = 40
                case (1,1):
                    print("swiped diag up-right")
                    impulse = 40
                case (-1,-1):
                    print("swiped diag down-left")
                    impulse = -40
                case (-1,1):
                    print("swiped diag up-left")
                    impulse = -40
                case (1,-1):
                    print("swiped diag down-right")
                    impulse = 40
                default:
                    swiped = false
                    break
                }
                
                player.run(SKAction.move(to: CGPoint(x: player.position.x + impulse, y: player.position.y), duration: 0.5))
            }
        }
        start = nil
        if !swiped {
            // Process non-swipes (taps, etc.)
            print("not a swipe")
            tapQueue.append(1)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        processUserTaps(forUpdate: currentTime)
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func didSimulatePhysics() {
        
        player.position.x += xAcceleration * 50
        
        if player.position.x < -20 {
            player.position = CGPoint(x: self.size.width + 20, y: player.position.y)
        }else if player.position.x > self.size.width + 20 {
            player.position = CGPoint(x: -20, y: player.position.y)
        }
        
    }

}
