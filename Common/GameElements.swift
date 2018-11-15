//
//  GameElements.swift
//  FlappyShip
//
//  Created by Mirko Justiniano on 11/4/18.
//  Copyright © 2018 idevcode. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
import CoreMotion

struct CollisionBitMask {
    static let birdCategory:UInt32 = 0x1 << 0
    static let pillarCategory:UInt32 = 0x1 << 1
    static let flowerCategory:UInt32 = 0x1 << 2
    static let groundCategory:UInt32 = 0x1 << 3
    static let enemyCategory:UInt32 = 0x1 << 4
    static let photonTorpedoCategory:UInt32 = 0x1 << 5
    static let bossCategory:UInt32 = 0x1 << 6
    static let bossFireCategory:UInt32 = 0x1 << 7
}

enum BossMovementDirection {
    case right
    case left
    case none
}

extension GameScene {
    
    func createBird() -> SKSpriteNode {

        let bird = SKSpriteNode(texture: SKTextureAtlas(named:"ship").textureNamed("ship1"))
        bird.size = CGSize(width: 50, height: 50)
        bird.position = CGPoint(x: self.frame.midX / 2, y: self.frame.midY)
        if let particles = SKEmitterNode(fileNamed: "LFire.sks") {
            particles.position = CGPoint(x: -30, y: 0)
            bird.addChild(particles)
        }

        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.width / 2)
        bird.physicsBody?.linearDamping = 1.1
        bird.physicsBody?.restitution = 0

        bird.physicsBody?.categoryBitMask = CollisionBitMask.birdCategory
        bird.physicsBody?.collisionBitMask = CollisionBitMask.pillarCategory | CollisionBitMask.groundCategory
        bird.physicsBody?.contactTestBitMask = CollisionBitMask.pillarCategory | CollisionBitMask.flowerCategory | CollisionBitMask.groundCategory

        bird.physicsBody?.affectedByGravity = false
        bird.physicsBody?.isDynamic = true
        
        return bird
    }
    
    func createRestartBtn() {
        restartBtn = SKSpriteNode(imageNamed: "restart")
        restartBtn.size = CGSize(width:100, height:100)
        restartBtn.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        restartBtn.zPosition = 6
        restartBtn.setScale(0)
        self.addChild(restartBtn)
        restartBtn.run(SKAction.scale(to: 1.0, duration: 0.3))
    }

    func createPauseBtn() {
        pauseBtn = SKSpriteNode(imageNamed: "pause")
        pauseBtn.size = CGSize(width:40, height:40)
        pauseBtn.position = CGPoint(x: self.frame.width - 30, y: 30)
        pauseBtn.zPosition = 6
        self.addChild(pauseBtn)
    }

    func createScoreLabel() -> SKLabelNode {
        let scoreLbl = SKLabelNode()
        scoreLbl.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 2.7)
        scoreLbl.text = "\(score)"
        scoreLbl.zPosition = 5
        scoreLbl.fontSize = 50
        scoreLbl.fontName = "Hermes-Regular"
        
        let scoreBg = SKShapeNode()
        scoreBg.position = CGPoint(x: 0, y: 0)
        scoreBg.path = CGPath(roundedRect: CGRect(x: CGFloat(-50), y: CGFloat(-35), width: CGFloat(100), height: CGFloat(100)), cornerWidth: 50, cornerHeight: 50, transform: nil)
        let scoreBgColor = UIColor(red: CGFloat(0.0 / 255.0), green: CGFloat(0.0 / 255.0), blue: CGFloat(0.0 / 255.0), alpha: CGFloat(0.2))
        scoreBg.strokeColor = UIColor.clear
        scoreBg.fillColor = scoreBgColor
        scoreBg.zPosition = -1
        scoreLbl.addChild(scoreBg)
        return scoreLbl
    }

    func createHighscoreLabel() -> SKLabelNode {
        let highscoreLbl = SKLabelNode()
        highscoreLbl.position = CGPoint(x: self.frame.width - 80, y: self.frame.height - 42)
        if let highestScore = UserDefaults.standard.object(forKey: "highestScore"){
            highscoreLbl.text = "Highest Score: \(highestScore)"
        } else {
            highscoreLbl.text = "Highest Score: 0"
        }
        highscoreLbl.zPosition = 5
        highscoreLbl.fontSize = 15
        highscoreLbl.fontName = "Hermes-Regular"
        return highscoreLbl
    }

    func createLogo() {
        logoImg = SKSpriteNode()
        logoImg = SKSpriteNode(imageNamed: "Logo")
        logoImg.size = CGSize(width: 272, height: 65)
        logoImg.position = CGPoint(x:self.frame.midX, y:self.frame.midY + 100)
        logoImg.setScale(0.5)
        self.addChild(logoImg)
        logoImg.run(SKAction.scale(to: 1.0, duration: 0.3))
    }

    func createTaptoplayLabel() -> SKLabelNode {
        let taptoplayLbl = SKLabelNode()
        taptoplayLbl.position = CGPoint(x:self.frame.midX, y:self.frame.midY - 100)
        taptoplayLbl.text = "Tap anywhere to play"
        taptoplayLbl.fontColor = UIColor(red: 63/255, green: 79/255, blue: 145/255, alpha: 1.0)
        taptoplayLbl.zPosition = 5
        taptoplayLbl.fontSize = 24
        taptoplayLbl.fontName = "Hermes-Regular"
        return taptoplayLbl
    }
    
    func createWalls() -> SKNode  {

        let flowerNode = SKSpriteNode(imageNamed: "prize")
        flowerNode.size = CGSize(width: 40, height: 40)
        flowerNode.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2)
        flowerNode.physicsBody = SKPhysicsBody(rectangleOf: flowerNode.size)
        flowerNode.physicsBody?.affectedByGravity = false
        flowerNode.physicsBody?.isDynamic = false
        flowerNode.physicsBody?.categoryBitMask = CollisionBitMask.flowerCategory
        flowerNode.physicsBody?.collisionBitMask = 0
        flowerNode.physicsBody?.contactTestBitMask = CollisionBitMask.birdCategory
        flowerNode.color = SKColor.blue
        
        let oneRevolution = SKAction.rotate(toAngle: CGFloat(Double.pi * 2), duration: 5.0)
        let repeatAction = SKAction.repeatForever(oneRevolution)
        flowerNode.run(repeatAction)

        wallPair = SKNode()
        wallPair.name = "wallPair"
        
        let topWall = SKSpriteNode(imageNamed: "pillar")
        let btmWall = SKSpriteNode(imageNamed: "pillar")
        
        topWall.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 + 420)
        btmWall.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 - 420)
        
        topWall.setScale(0.5)
        btmWall.setScale(0.5)
        
        topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        topWall.physicsBody?.categoryBitMask = CollisionBitMask.pillarCategory
        topWall.physicsBody?.collisionBitMask = CollisionBitMask.birdCategory
        topWall.physicsBody?.contactTestBitMask = CollisionBitMask.birdCategory
        topWall.physicsBody?.isDynamic = false
        topWall.physicsBody?.affectedByGravity = false
        
        btmWall.physicsBody = SKPhysicsBody(rectangleOf: btmWall.size)
        btmWall.physicsBody?.categoryBitMask = CollisionBitMask.pillarCategory
        btmWall.physicsBody?.collisionBitMask = CollisionBitMask.birdCategory
        btmWall.physicsBody?.contactTestBitMask = CollisionBitMask.birdCategory
        btmWall.physicsBody?.isDynamic = false
        btmWall.physicsBody?.affectedByGravity = false
        
        topWall.zRotation = CGFloat(Double.pi)
        
        wallPair.addChild(topWall)
        wallPair.addChild(btmWall)
        
        wallPair.zPosition = 1

        let randomPosition = random(min: -200, max: 200)
        wallPair.position.y = wallPair.position.y +  randomPosition
        wallPair.addChild(flowerNode)
        
        wallPair.run(moveAndRemove)
        
        return wallPair
    }
    
    func createEnemy() -> SKNode  {
        
        enemy = SKEmitterNode(fileNamed: "Enemy.sks")!
        enemy.name = "enemy"
        let min: CGFloat = 25
        let max = self.frame.size.height - min
        let randomNumCGFloat = CGFloat.random(min: min, max: max)
        enemy.position = CGPoint(x: self.frame.width + 25, y: randomNumCGFloat)
        
        enemy.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 10, height: 10))
        enemy.physicsBody?.categoryBitMask = CollisionBitMask.enemyCategory
        enemy.physicsBody?.collisionBitMask = CollisionBitMask.birdCategory
        enemy.physicsBody?.contactTestBitMask = CollisionBitMask.birdCategory
        enemy.physicsBody?.isDynamic = false
        enemy.physicsBody?.affectedByGravity = false
        
        enemy.run(SKAction.playSoundFileNamed("lazer", waitForCompletion: false))
        enemy.run(moveAndRemoveEnemy)
        
        return enemy
    }
    
    func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min : CGFloat, max : CGFloat) -> CGFloat{
        return random() * (max - min) + min
    }
}

enum BulletType {
    case shipFired
    case invaderFired
}

extension ParallaxView {
    
    func createShip() -> SKSpriteNode {
        
        let ship = SKSpriteNode(imageNamed: "ship")
        ship.name = kShipName
        ship.size = CGSize(width: 50, height: 50)
        ship.position = CGPoint(x: self.frame.size.width / 2, y: ship.size.height / 2 + 45)
        if let particles = SKEmitterNode(fileNamed: "Fire.sks") {
            particles.position = CGPoint(x: 0, y: -25)
            ship.addChild(particles)
        }
        
        ship.physicsBody = SKPhysicsBody(circleOfRadius: ship.size.width / 2)
        ship.physicsBody?.categoryBitMask = CollisionBitMask.birdCategory
        ship.physicsBody?.collisionBitMask = CollisionBitMask.photonTorpedoCategory | CollisionBitMask.enemyCategory
        ship.physicsBody?.contactTestBitMask = CollisionBitMask.photonTorpedoCategory | CollisionBitMask.enemyCategory
        
        return ship
    }
    
    func createBoss() -> SKSpriteNode {
        
        let ship = SKSpriteNode(imageNamed: "boss")
        ship.name = kBossName
        ship.size = CGSize(width: 100, height: 100)
        ship.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height + 70)
        if let particles = SKEmitterNode(fileNamed: "Magic.sks") {
            particles.position = CGPoint(x: 0, y: 25)
            particles.zPosition = -1
            ship.addChild(particles)
        }
        
        ship.physicsBody = SKPhysicsBody(circleOfRadius: ship.size.width / 2)
        ship.physicsBody?.categoryBitMask = CollisionBitMask.bossCategory
        ship.physicsBody?.collisionBitMask = CollisionBitMask.photonTorpedoCategory | CollisionBitMask.birdCategory
        ship.physicsBody?.contactTestBitMask = CollisionBitMask.photonTorpedoCategory | CollisionBitMask.birdCategory
        
        return ship
    }
    
    func createSky() {
        let topSky = SKSpriteNode(color: UIColor(hue: 0.55, saturation: 0.14, brightness: 0.97, alpha: 1), size: CGSize(width: frame.width, height: frame.height * 0.67))
        topSky.anchorPoint = CGPoint(x: 0.5, y: 1)
        
        let bottomSky = SKSpriteNode(color: UIColor(hue: 0.55, saturation: 0.16, brightness: 0.96, alpha: 1), size: CGSize(width: frame.width, height: frame.height * 0.33))
        bottomSky.anchorPoint = CGPoint(x: 0.5, y: 1)
        
        topSky.position = CGPoint(x: frame.midX, y: frame.height)
        bottomSky.position = CGPoint(x: frame.midX, y: bottomSky.frame.height)
        
        addChild(topSky)
        addChild(bottomSky)
        
        bottomSky.zPosition = -40
        topSky.zPosition = -40
    }
    
    func createTaptoplayLabel() -> SKLabelNode {
        let taptoplayLbl = SKLabelNode()
        taptoplayLbl.position = CGPoint(x:self.frame.midX, y:self.frame.midY - 100)
        taptoplayLbl.text = "Tilt device to move\nTap to shoot"
        taptoplayLbl.numberOfLines = 2
        taptoplayLbl.horizontalAlignmentMode = .center
        taptoplayLbl.fontColor = UIColor(red: 63/255, green: 79/255, blue: 145/255, alpha: 1.0)
        taptoplayLbl.zPosition = 5
        taptoplayLbl.fontSize = 24
        taptoplayLbl.fontName = "Hermes-Regular"
        return taptoplayLbl
    }
    
    func createRestartBtn() {
        restartBtn = SKSpriteNode(imageNamed: "restart")
        restartBtn.size = CGSize(width:100, height:100)
        restartBtn.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        restartBtn.zPosition = 6
        restartBtn.setScale(0)
        self.addChild(restartBtn)
        restartBtn.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    
    func createScoreLabel() -> SKLabelNode {
        let scoreLbl = SKLabelNode()
        scoreLbl.position = CGPoint(x: 27, y: self.frame.height - 32)
        scoreLbl.text = "\(score)"
        scoreLbl.zPosition = 5
        scoreLbl.fontSize = 30
        scoreLbl.fontName = "Hermes-Regular"
        
        let scoreBg = SKShapeNode()
        scoreBg.position = CGPoint(x: 5, y: 6)
        scoreBg.path = CGPath(roundedRect: CGRect(x: CGFloat(-30), y: CGFloat(-25), width: CGFloat(50), height: CGFloat(50)), cornerWidth: 30, cornerHeight: 30, transform: nil)
        let scoreBgColor = UIColor(red: CGFloat(0.0 / 255.0), green: CGFloat(0.0 / 255.0), blue: CGFloat(0.0 / 255.0), alpha: CGFloat(0.2))
        scoreBg.strokeColor = UIColor.clear
        scoreBg.fillColor = scoreBgColor
        scoreBg.zPosition = -1
        scoreLbl.addChild(scoreBg)
        return scoreLbl
    }
    
    func makeBullet(ofType bulletType: BulletType) -> SKNode {
        //let bullet: SKNode = SKSpriteNode(color: SKColor.magenta, size: kBulletSize)
        switch bulletType {
        case .shipFired:
            let particles = SKEmitterNode(fileNamed: "Bullet.sks")
            particles?.name = kShipFiredBulletName
            return particles!
        case .invaderFired:
            let particles = SKEmitterNode(fileNamed: "Boss.sks")
            particles?.name = kShipFiredBulletName
            return particles!
        }
    }
    
    func fireBullet(bullet: SKNode, toDestination destination: CGPoint, withDuration duration: CFTimeInterval, andSoundFileName soundName: String) {
        let bulletAction = SKAction.sequence([
            SKAction.move(to: destination, duration: duration),
            SKAction.removeFromParent()
            ])
        
        let soundAction = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        
        bullet.run(SKAction.group([bulletAction, soundAction]))
        
        addChild(bullet)
    }
    
    func fireShipBullets() {
        //let existingBullet = childNode(withName: kShipFiredBulletName)
        
        if let ship = childNode(withName: kShipName) {
            let bullet = makeBullet(ofType: .shipFired)
            bullet.position = CGPoint(
                x: ship.position.x,
                y: ship.position.y + 40
            )
            
            let bulletDestination = CGPoint(
                x: ship.position.x,
                y: frame.size.height + bullet.frame.size.height
            )
            
            bullet.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 25, height: 25))
            bullet.physicsBody?.categoryBitMask = CollisionBitMask.photonTorpedoCategory
            bullet.physicsBody?.contactTestBitMask = CollisionBitMask.enemyCategory
            bullet.physicsBody?.collisionBitMask = 0
            bullet.physicsBody?.usesPreciseCollisionDetection = true
            
            fireBullet(
                bullet: bullet,
                toDestination: bulletDestination,
                withDuration: 0.3,
                andSoundFileName: "shoot.mp3"
            )
        }
    }
    
    func fireBossBullets() {
        
        if let ship = childNode(withName: kBossName) {
            let bullet = makeBullet(ofType: .invaderFired)
            bullet.position = CGPoint(
                x: ship.position.x,
                y: ship.position.y - 40
            )
            
            let bulletDestination = CGPoint(
                x: ship.position.x,
                y: -100
            )
            
            bullet.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 15, height: 15))
            bullet.physicsBody?.categoryBitMask = CollisionBitMask.bossFireCategory
            bullet.physicsBody?.contactTestBitMask = CollisionBitMask.birdCategory
            bullet.physicsBody?.collisionBitMask = 0
            bullet.physicsBody?.usesPreciseCollisionDetection = true
            
            fireBullet(
                bullet: bullet,
                toDestination: bulletDestination,
                withDuration: 0.3,
                andSoundFileName: "lazer.mp3"
            )
        }
    }
    
    func fireTorpedo() {
        
        run(SKAction.playSoundFileNamed("shoot.mp3", waitForCompletion: false))
        
        if let torpedoNode = SKEmitterNode(fileNamed: "Bullet.sks") {
            
            torpedoNode.name = kShipFiredBulletName
            //let torpedoNode = SKSpriteNode(imageNamed: "torpedo")
            torpedoNode.position = CGPoint(
                x: player.position.x,
                y: player.position.y + 40
            )
            
            torpedoNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 25, height: 25))
            torpedoNode.physicsBody?.isDynamic = true
            
            torpedoNode.physicsBody?.categoryBitMask = CollisionBitMask.photonTorpedoCategory
            torpedoNode.physicsBody?.contactTestBitMask = CollisionBitMask.enemyCategory
            torpedoNode.physicsBody?.collisionBitMask = 0
            torpedoNode.physicsBody?.usesPreciseCollisionDetection = true
            
            addChild(torpedoNode)
            
            var actionArray = [SKAction]()
            actionArray.append(SKAction.moveTo(y: self.frame.size.height + 70, duration: 0.3))
            actionArray.append(SKAction.removeFromParent())
            
            torpedoNode.run(SKAction.sequence(actionArray))
        }
    }
    
    func processUserTaps(forUpdate currentTime: CFTimeInterval) {

        for tapCount in tapQueue {
            if tapCount == 1 {
                fireShipBullets()
            }
            tapQueue.remove(at: 0)
        }
    }
    
    @objc func addAsteroid () {
        possibleAsteroids = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleAsteroids) as! [String]
        
        let alien = SKSpriteNode(imageNamed: possibleAsteroids[0])
        alien.name = kInvaderFiredBulletName
        
        let randomAlienPosition = GKRandomDistribution(lowestValue: 0, highestValue: 414)
        let position = CGFloat(randomAlienPosition.nextInt())
        
        alien.position = CGPoint(x: position, y: self.frame.size.height + alien.size.height)
        
        alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
        alien.physicsBody?.isDynamic = true
        
        alien.physicsBody?.categoryBitMask = CollisionBitMask.enemyCategory
        alien.physicsBody?.contactTestBitMask = CollisionBitMask.photonTorpedoCategory
        alien.physicsBody?.collisionBitMask = 0
        
        self.addChild(alien)
        
        let animationDuration:TimeInterval = 6
        
        var actionArray = [SKAction]()
        
        
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -alien.size.height), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        alien.run(SKAction.sequence(actionArray))
        
        
    }
}

public extension Float {
    
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    public static var random: Float {
        return Float(arc4random()) / 0xFFFFFFFF
    }
    
    /// Random float between 0 and n-1.
    ///
    /// - Parameter n:  Interval max
    /// - Returns:      Returns a random float point number between 0 and n max
    public static func random(min: Float, max: Float) -> Float {
        return Float.random * (max - min) + min
    }
}

public extension CGFloat {
    
    /// Randomly returns either 1.0 or -1.0.
    public static var randomSign: CGFloat {
        return (arc4random_uniform(2) == 0) ? 1.0 : -1.0
    }
    
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    public static var random: CGFloat {
        return CGFloat(Float.random)
    }
    
    /// Random CGFloat between 0 and n-1.
    ///
    /// - Parameter n:  Interval max
    /// - Returns:      Returns a random CGFloat point number between 0 and n max
    public static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat.random * (max - min) + min
    }
}
