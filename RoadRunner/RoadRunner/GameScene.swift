//
//  GameScene.swift
//  RoadRunner
//
//  Created by Gerardo Mares on 3/10/17.
//  Copyright © 2017 Gerardo Mares. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    var road:SKEmitterNode!
    
    var player = SKSpriteNode()
    var car = SKSpriteNode()
    var coin = SKSpriteNode()
    
    let PlayerCategory  : UInt32 = 0x1 << 0
    let CarCategory: UInt32 = 0x1 << 1
    let CoinCategory : UInt32 = 0x1 << 2
    
    var scoreLabel:SKLabelNode!
    var score:Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
            scoreLabel.zPosition = 1
        }
    }
    
    var gameTimer:Timer!
    var coinTimer:Timer!
    
    var possibleCars = ["Ambulance", "Car", "Audi", "Black_viper", "Mini_van", "Police", "taxi", "truck"]
    
    
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        
        //middle road
        road = SKEmitterNode(fileNamed: "road")
        road.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height)
        road.advanceSimulationTime(10)
        road.zPosition = -1
        self.addChild(road)
        
        //score label
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: 50, y: self.frame.size.height - 50)
        scoreLabel.fontName = "AmericanTypewriter"
        scoreLabel.fontSize = 20
        scoreLabel.zPosition = 2
        score = 0
        self.addChild(scoreLabel)
        
        //car
        player = SKSpriteNode(imageNamed: "Man")
        player.name = "Man"
        player.position.x =  self.frame.size.width/2
        player.position.y =  player.size.height/10 - 15
        player.zPosition = 0
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2)
        player.physicsBody?.isDynamic = false
        player.physicsBody?.categoryBitMask = PlayerCategory
        player.physicsBody?.contactTestBitMask = CarCategory | CoinCategory
        player.physicsBody?.collisionBitMask = 0
        player.physicsBody?.usesPreciseCollisionDetection = true
        player.setScale(0.20)
        self.addChild(player)

        gameTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(addCars), userInfo: nil, repeats: true)
        coinTimer = Timer.scheduledTimer(timeInterval: 2.5 , target: self, selector: #selector(addCoins), userInfo: nil, repeats: true)
   
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody();
        var secondBody = SKPhysicsBody();
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA;
            secondBody = contact.bodyB;
            
        } else {
            firstBody = contact.bodyB;
            secondBody = contact.bodyA;
        }
        
        if (firstBody.node?.name == "Man" && secondBody.node?.name == "Car"){
            firstBody.node?.removeFromParent()
            secondBody.node?.removeFromParent()
            
            let transition = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOver = SKScene(fileNamed: "GameOverScene") as! GameOverScene
            gameOver.score = self.score
            
            self.view?.presentScene(gameOver, transition: transition)
        }
        
        if (firstBody.node?.name == "Man" && secondBody.node?.name == "Coin"){
            secondBody.node?.removeFromParent()
            
            score += 5
        }
    }
    
    func addCars () {
        possibleCars = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleCars) as! [String]
        
        let car = SKSpriteNode(imageNamed: possibleCars[0])
        car.name = "Car"
        
        let randomCarPosition = GKRandomDistribution(lowestValue: 0, highestValue: Int(self.frame.size.width))
        let position = CGFloat(randomCarPosition.nextInt())
        
        car.position = CGPoint(x: position, y: self.frame.size.height / 2 + (car.size.height * 2))
        car.zPosition = 0
        car.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: car.size.width / 2, height: car.size.height))
        car.physicsBody?.allowsRotation = false
        car.physicsBody?.isDynamic = true
        car.physicsBody?.categoryBitMask = CarCategory
        car.physicsBody?.usesPreciseCollisionDetection = true
        car.setScale(0.75)
        
        self.addChild(car)
        
        let animationDuration:TimeInterval = 1.25
        
        var actionArray = [SKAction]()
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -self.frame.size.height / 2), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        car.run(SKAction.sequence(actionArray))
    }
    
    func addCoins () {
        
        let coin = SKSpriteNode(imageNamed:  "Coins")
        coin.name = "Coin"
        
        let randomCoinPosition = GKRandomDistribution(lowestValue: 0, highestValue: Int(self.frame.size.width))
        let position = CGFloat(randomCoinPosition.nextInt())
        
        coin.position = CGPoint(x: position, y: self.frame.size.height / 2 + (coin.size.height * 2))
        coin.zPosition = 0
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width / 2)
        coin.physicsBody?.isDynamic = true
        coin.physicsBody?.categoryBitMask = CoinCategory
        coin.physicsBody?.usesPreciseCollisionDetection = true
        coin.setScale(0.175)
        
        self.addChild(coin)
        
        let animationDuration:TimeInterval = 2
        var actionArray = [SKAction]()
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -self.frame.size.height / 2), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        coin.run(SKAction.sequence(actionArray))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let location = touch.location(in: self)
            player.run(SKAction.moveTo(x: location.x, duration: 0.1))
            
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let location = touch.location(in: self)
            player.run(SKAction.moveTo(x: location.x, duration: 0.1))
            
        }
    }

}
