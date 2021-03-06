//
//  GameScene.swift
//  FlappyShip
//
//  Created by Mirko Justiniano on 11/4/18.
//  Copyright © 2018 idevcode. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK:- VARS
    
    var isGameStarted = Bool(false)
    var isDied = Bool(false)
    let shipSound = SKAction.playSoundFileNamed("flypast.mp3", waitForCompletion: false)
    let coinSound = SKAction.playSoundFileNamed("coin.mp3", waitForCompletion: false)
    let laughSound = SKAction.playSoundFileNamed("laugh.mp3", waitForCompletion: false)
    let explosionSound = SKAction.playSoundFileNamed("ShipExplosion.mp3", waitForCompletion: false)
    
    var bgNumber = 0
    var score = Int(0)
    var scoreThreshold = 2
    var threshold = 0
    var pillarVel: CGFloat = 0.008
    
    var scoreLbl = SKLabelNode()
    var highscoreLbl = SKLabelNode()
    var taptoplayLbl = SKLabelNode()
    var restartBtn = SKSpriteNode()
    var pauseBtn = SKSpriteNode()
    var logoImg = SKSpriteNode()
    var wallPair = SKNode()
    var enemy = SKNode()
    var moveAndRemove = SKAction()
    var moveAndRemoveEnemy = SKAction()
    
    //CREATE THE BIRD ATLAS FOR ANIMATION
    let birdAtlas = SKTextureAtlas(named:"ship")
    var birdSprites = Array<SKTexture>()
    var bird = SKSpriteNode()
    var repeatActionBird = SKAction()
    
    // MARK:- SKScene Methods
    
    override func didMove(to view: SKView) {
        bgNumber = Int.random(in: 1 ... 8)
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
        
        if isGameStarted == false{

            isGameStarted =  true
            bird.physicsBody?.affectedByGravity = true
            createPauseBtn()

            logoImg.run(SKAction.scale(to: 0.5, duration: 0.3), completion: {
                self.logoImg.removeFromParent()
            })
            taptoplayLbl.removeFromParent()

            self.bird.run(repeatActionBird)
            
            // walls
            let spawn = SKAction.run({ () in
                self.wallPair = self.createWalls()
                self.addChild(self.wallPair)
            })

            let delay = SKAction.wait(forDuration: 3.0)
            let SpawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatForever(SpawnDelay)
            run(spawnDelayForever)

            let distance = CGFloat(self.frame.width + wallPair.frame.width)
            let movePillars = SKAction.moveBy(x: -distance - 50, y: 0, duration: TimeInterval(0.008 * distance))
            let removePillars = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePillars, removePillars])
            
            //enemies
            let enemySpawn = SKAction.run({ () in
                self.enemy = self.createEnemy()
                self.addChild(self.enemy)
            })
            
            let enemyDelay = SKAction.wait(forDuration: 5.0)
            let enemySpawnDelay = SKAction.sequence([enemySpawn, enemyDelay])
            let enemyspawnDelayForever = SKAction.repeatForever(enemySpawnDelay)
            run(enemyspawnDelayForever)
            
            let enemyDistance = CGFloat(self.frame.width + self.enemy.frame.width)
            let moveEnemy = SKAction.moveBy(x: -enemyDistance - 50, y: 0, duration: TimeInterval(0.002 * enemyDistance))
            let removeEnemy = SKAction.removeFromParent()
            moveAndRemoveEnemy = SKAction.sequence([moveEnemy, removeEnemy])
            
            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 40))
            
        } else {

            if isDied == false {
                bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 40))
            }
        }
        
        for touch in touches{
            let location = touch.location(in: self)

            if isDied == true{
                if restartBtn.contains(location){
                    if UserDefaults.standard.object(forKey: "highestScore") != nil {
                        let hscore = UserDefaults.standard.integer(forKey: "highestScore")
                        if hscore < Int(scoreLbl.text!)!{
                            UserDefaults.standard.set(scoreLbl.text, forKey: "highestScore")
                        }
                    } else {
                        UserDefaults.standard.set(0, forKey: "highestScore")
                    }
                    restartScene()
                }
                
            } else {

                if pauseBtn.contains(location){
                    if self.isPaused == false{
                        self.isPaused = true
                        pauseBtn.texture = SKTexture(imageNamed: "play")
                        
                    } else {
                        
                        self.isPaused = false
                        pauseBtn.texture = SKTexture(imageNamed: "pause")
                    }
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if isGameStarted == true {
            if isDied == false {
                enumerateChildNodes(withName: "background", using: ({
                    (node, error) in
                    let bg = node as! SKSpriteNode
                    bg.position = CGPoint(x: bg.position.x - 2, y: bg.position.y)
                    if bg.position.x <= -bg.size.width {
                        bg.position = CGPoint(x:bg.position.x + bg.size.width * 2, y:bg.position.y)
                    }
                }))
                
                if threshold == scoreThreshold {
                    debugPrint("threshold: \(threshold)")
                    debugPrint("scoreThreshold: \(scoreThreshold)")
                    debugPrint("threshold == scoreThreshold")
                    scoreThreshold += 2
                    pillarVel -= 0.001
                    debugPrint("pillarVel: \(pillarVel)")
                    
                    let distance = CGFloat(self.frame.width + wallPair.frame.width)
                    let movePillars = SKAction.moveBy(x: -distance - 50, y: 0, duration: TimeInterval(pillarVel * distance))
                    let removePillars = SKAction.removeFromParent()
                    moveAndRemove = SKAction.sequence([movePillars, removePillars])
                }
            }
        }
    }
    
    // MARK:- Private Methods
    
    func createScene(){
        threshold = 0
        scoreThreshold = 2
        pillarVel = 0.008
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.categoryBitMask = CollisionBitMask.groundCategory
        self.physicsBody?.collisionBitMask = CollisionBitMask.birdCategory
        self.physicsBody?.contactTestBitMask = CollisionBitMask.birdCategory
        self.physicsBody?.isDynamic = false
        self.physicsBody?.affectedByGravity = false
        
        self.physicsWorld.contactDelegate = self
        self.backgroundColor = SKColor(red: 80.0/255.0, green: 192.0/255.0, blue: 203.0/255.0, alpha: 1.0)
        
        for i in 0..<2 {
            let background = SKSpriteNode(imageNamed: "bg\(bgNumber)")
            background.anchorPoint = CGPoint.init(x: 0, y: 0)
            background.position = CGPoint(x:CGFloat(i) * self.frame.width, y:0)
            background.name = "background"
            background.size = (self.view?.bounds.size)!
            self.addChild(background)
        }
        
        //SET UP THE BIRD SPRITES FOR ANIMATION
        birdSprites.append(birdAtlas.textureNamed("ship1"))
        /*birdSprites.append(birdAtlas.textureNamed("bird1"))
        birdSprites.append(birdAtlas.textureNamed("bird2"))
        birdSprites.append(birdAtlas.textureNamed("bird3"))
        birdSprites.append(birdAtlas.textureNamed("bird4"))*/
        
        self.bird = createBird()
        self.addChild(bird)
        
        //PREPARE TO ANIMATE THE BIRD AND REPEAT THE ANIMATION FOREVER
        let animateBird = SKAction.animate(with: self.birdSprites, timePerFrame: 0.1)
        self.repeatActionBird = SKAction.repeatForever(animateBird)
        
        scoreLbl = createScoreLabel()
        self.addChild(scoreLbl)
        
        highscoreLbl = createHighscoreLabel()
        self.addChild(highscoreLbl)
        
        createLogo()
        
        taptoplayLbl = createTaptoplayLabel()
        self.addChild(taptoplayLbl)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == CollisionBitMask.birdCategory && secondBody.categoryBitMask == CollisionBitMask.pillarCategory || firstBody.categoryBitMask == CollisionBitMask.pillarCategory && secondBody.categoryBitMask == CollisionBitMask.birdCategory || firstBody.categoryBitMask == CollisionBitMask.birdCategory && secondBody.categoryBitMask == CollisionBitMask.groundCategory || firstBody.categoryBitMask == CollisionBitMask.groundCategory && secondBody.categoryBitMask == CollisionBitMask.birdCategory ||
            firstBody.categoryBitMask == CollisionBitMask.birdCategory && secondBody.categoryBitMask == CollisionBitMask.enemyCategory ||
            firstBody.categoryBitMask == CollisionBitMask.enemyCategory && secondBody.categoryBitMask == CollisionBitMask.birdCategory {
            
            enumerateChildNodes(withName: "wallPair", using: ({
                (node, error) in
                node.speed = 0
                self.removeAllActions()
            }))
            
            if firstBody.node?.name == "enemy" {
                firstBody.node?.removeFromParent()
            } else if secondBody.node?.name == "enemy" {
                secondBody.node?.removeFromParent()
            }
            
            if isDied == false{
                isDied = true
                run(explosionSound)
                let delay = SKAction.wait(forDuration: 2.0)
                let deathDelay = SKAction.sequence([laughSound, delay])
                run(deathDelay)
                createRestartBtn()
                pauseBtn.removeFromParent()
                self.bird.removeAllActions()
                self.enemy.removeAllActions()
                if let particles = SKEmitterNode(fileNamed: "Smoke.sks") {
                    particles.position = CGPoint(x: 0, y: -5)
                    bird.addChild(particles)
                }
            }
            
        } else if firstBody.categoryBitMask == CollisionBitMask.birdCategory && secondBody.categoryBitMask == CollisionBitMask.flowerCategory {
            
            run(coinSound)
            score += 1
            threshold += 1
            scoreLbl.text = "\(score)"
            secondBody.node?.removeFromParent()
            
        } else if firstBody.categoryBitMask == CollisionBitMask.flowerCategory && secondBody.categoryBitMask == CollisionBitMask.birdCategory {
            
            run(coinSound)
            score += 1
            threshold += 1
            scoreLbl.text = "\(score)"
            firstBody.node?.removeFromParent()
            
        }
    }
    
    func restartScene(){
        
        self.removeAllChildren()
        self.removeAllActions()
        isDied = false
        isGameStarted = false
        score = 0
        createScene()
    }
}
