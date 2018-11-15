//
//  ParallaxView.swift
//  FlappyShip
//
//  Created by Mirko Justiniano on 11/4/18.
//  Copyright © 2018 idevcode. All rights reserved.
//

import UIKit
import GameplayKit
import CoreMotion

class ParallaxView: SKScene, SKPhysicsContactDelegate {
    
    // MARK:- VARS
    
    var isGameStarted = Bool(false)
    var isBossOnScene = Bool(false)
    var isDied = Bool(false)
    var taptoplayLbl = SKLabelNode()
    var gameTimer = Timer()
    var restartBtn = SKSpriteNode()
    
    let motionManger = CMMotionManager()
    var xAcceleration:CGFloat = 0
    let minDistance:CGFloat = 25
    let minSpeed:CGFloat = 1000
    let maxSpeed:CGFloat = 6000
    var timeOfLastShot: CFTimeInterval = 0.0
    let timePerShot: CFTimeInterval = 2.0
    
    let kShipName = "ship"
    let kBossName = "boss"
    let kShipFiredBulletName = "shipFiredBullet"
    let kInvaderFiredBulletName = "invaderFiredBullet"
    let kBulletSize = CGSize(width:4, height: 8)
    
    var player: SKSpriteNode!
    var boss: SKSpriteNode!
    var start:(location:CGPoint, time:TimeInterval)?
    var tapQueue = [Int]()
    let shipSound = SKAction.playSoundFileNamed("flypast.mp3", waitForCompletion: false)
    let explosionSound = SKAction.playSoundFileNamed("ShipExplosion.mp3", waitForCompletion: false)
    let laughSound = SKAction.playSoundFileNamed("laugh.mp3", waitForCompletion: false)
    var starfield:SKEmitterNode!
    var possibleAsteroids = ["asteroid1", "asteroid2"]
    var bossMovementDirection: BossMovementDirection = .right
    
    // MARK:- Scene Methods
    
    override func didMove(to view: SKView) {
        //createSky()
        run(shipSound)
        
        createScene()
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
        
        if !isBossOnScene {
            
            boss.run(SKAction.moveTo(y: self.frame.size.height - 70, duration: 2.0), completion: {
                self.isBossOnScene = true
                self.gameTimer = Timer.scheduledTimer(timeInterval: 2.75, target: self, selector: #selector(self.addAsteroid), userInfo: nil, repeats: true)
                self.motionManger.accelerometerUpdateInterval = 0.2
            })
        }
        
        if !isGameStarted {
            
            isGameStarted =  true
            taptoplayLbl.removeFromParent()
            motionManger.startAccelerometerUpdates(to: OperationQueue.current!) { (data:CMAccelerometerData?, error:Error?) in
                if let accelerometerData = data {
                    let acceleration = accelerometerData.acceleration
                    self.xAcceleration = CGFloat(acceleration.x) * 0.75 + self.xAcceleration * 0.25
                }
            }
            
        } else {
            if !isDied {
                
                if let touch = touches.first {
                    start = (touch.location(in:self), touch.timestamp)
                }
            }
        }
        
        for touch in touches {
            let location = touch.location(in: self)
            if isDied {
                if restartBtn.contains(location) {
                    restartScene()
                }
                
            }
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
                    impulse = 40
                case (0,-1):
                    impulse = -40
                case (-1,0):
                    impulse = -80
                case (1,0):
                    impulse = 80
                case (1,1):
                    impulse = 40
                case (-1,-1):
                    impulse = -40
                case (-1,1):
                    impulse = -40
                case (1,-1):
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
            if isGameStarted {
                //tapQueue.append(1)
                fireTorpedo();
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if isGameStarted && !isDied {
            if isBossOnScene {
                moveBoss(forUpdate: currentTime)
            }
            processUserTaps(forUpdate: currentTime)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == CollisionBitMask.birdCategory && secondBody.categoryBitMask == CollisionBitMask.enemyCategory
            || firstBody.categoryBitMask == CollisionBitMask.enemyCategory && secondBody.categoryBitMask == CollisionBitMask.birdCategory
            || firstBody.categoryBitMask == CollisionBitMask.birdCategory && secondBody.categoryBitMask == CollisionBitMask.bossFireCategory
            || firstBody.categoryBitMask == CollisionBitMask.bossFireCategory && secondBody.categoryBitMask == CollisionBitMask.birdCategory {
            
            if firstBody.node?.name == kInvaderFiredBulletName {
                firstBody.node?.removeFromParent()
            } else if secondBody.node?.name == kInvaderFiredBulletName {
                secondBody.node?.removeFromParent()
            }
            
            run(explosionSound)
            
            if !isDied {
                isDied = true
                motionManger.stopAccelerometerUpdates()
                gameTimer.invalidate()
                gameTimer = Timer()
                let delay = SKAction.wait(forDuration: 2.0)
                let deathDelay = SKAction.sequence([laughSound, delay])
                run(deathDelay)
                createRestartBtn()
                player.removeAllActions()
                boss.removeAllActions()
                if let particles = SKEmitterNode(fileNamed: "Smoke.sks") {
                    particles.position = CGPoint(x: 0, y: -5)
                    player.addChild(particles)
                }
            }
        }
        else if firstBody.categoryBitMask == CollisionBitMask.photonTorpedoCategory && secondBody.categoryBitMask == CollisionBitMask.enemyCategory
        || firstBody.categoryBitMask == CollisionBitMask.enemyCategory && secondBody.categoryBitMask == CollisionBitMask.photonTorpedoCategory {
            
            let explosion = SKEmitterNode(fileNamed: "Smoke")!
            explosion.position = firstBody.node!.position
            self.addChild(explosion)
            
            self.run(SKAction.playSoundFileNamed("ShipExplosion.mp3", waitForCompletion: false))
            
            firstBody.node?.removeFromParent()
            secondBody.node?.removeFromParent()
            
            self.run(SKAction.wait(forDuration: 1)) {
                explosion.removeFromParent()
            }
        }
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    // MARK:- Private Methods
    
    func createScene() {
        
        starfield = SKEmitterNode(fileNamed: "Starfield")
        starfield.position = CGPoint(x: 0, y: self.frame.size.height)
        starfield.advanceSimulationTime(10)
        self.addChild(starfield)
        
        starfield.zPosition = -1
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        taptoplayLbl = createTaptoplayLabel()
        self.addChild(taptoplayLbl)
        
        self.player = createShip()
        self.addChild(player)
        
        self.boss = createBoss()
        self.addChild(boss)
    }
    
    override func didSimulatePhysics() {
        
        player.position.x += xAcceleration * 50
        
        if player.position.x < -20 {
            player.position = CGPoint(x: self.size.width + 20, y: player.position.y)
        }
        else if player.position.x > self.size.width + 20 {
            player.position = CGPoint(x: -20, y: player.position.y)
        }
        
    }
    
    func restartScene(){
        self.removeAllChildren()
        self.removeAllActions()
        isDied = false
        isGameStarted = false
        isBossOnScene = false
        createScene()
    }
    
    func moveBoss(forUpdate currentTime: CFTimeInterval) {
        
        let dx:CGFloat = 5
        let maxX:CGFloat = 50
        
        if bossMovementDirection == .right {
            
            boss.position = CGPoint(x: boss.position.x + dx, y: self.frame.size.height - 70)
            
            if boss.position.x + maxX > self.frame.size.width {
                bossMovementDirection = .left
            }
            
        } else {
            
            boss.position = CGPoint(x: boss.position.x - dx, y: self.frame.size.height - 70)
            
            if boss.position.x - maxX <= 0 {
                bossMovementDirection = .right
            }
        }
        
        if (currentTime - timeOfLastShot < timePerShot) {
            return
        }
        
        fireBossBullets()
        timeOfLastShot = currentTime
    }
} 
