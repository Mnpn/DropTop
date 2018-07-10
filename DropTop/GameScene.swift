//
//  GameScene.swift
//  DropTop
//
//  Created by Mnpn on 19/05/2018.
//  Copyright © 2018 Mnpn. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    private var label: SKLabelNode?
    private var removed: SKLabelNode?
    private var spinnyNode: SKShapeNode?
    var arrayOfPlayers = [AVAudioPlayer]()
    
    var lastUpdateTime: TimeInterval = 0
    var timesLagged = 0
    var FPS = 0.0
    var started = 0
    var nodeLimit = UserDefaults.standard.float(forKey: "getnl")
    var aclb = UserDefaults.standard.bool(forKey: "aclb")
    
    var firstPoint: CGPoint = CGPoint(x: 0.0, y: 0.0)
    var veryFirstPoint: CGPoint = CGPoint(x: 0.0, y: 0.0)
    var shapeNodes: [SKShapeNode] = []
    var nodesToCheck = [SKShapeNode]()
    let tTap = UITapGestureRecognizer()
    
    override func sceneDidLoad() {
        
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -2)
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.005
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 1.0),
                                               SKAction.fadeOut(withDuration: 0.5),
                                               SKAction.removeFromParent()]))
        }
        
        self.removed = self.childNode(withName: "//Removed") as? SKLabelNode
        if let removed = self.removed {
            removed.alpha = 0
        }
        
        tTap.addTarget(self, action:#selector(GameScene.tripleTapped(_:) ))
        tTap.numberOfTapsRequired = 3
        self.view!.addGestureRecognizer(tTap)
    }
    
    func touchDown(atPoint pos : CGPoint) {
        firstPoint = pos
        veryFirstPoint = pos
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
        self.label = self.childNode(withName: "//Title") as? SKLabelNode
        if let label = self.label {
            if label.alpha != 0.0 { // Don't waste resources on scaling and fading if the object is hidden and nonexistent.
                label.run(SKAction.fadeOut(withDuration: 0.7))
                label.run(SKAction.scale(by: 0.6, duration: 1.0))
                SKAction.removeFromParent()
            }
        }
        if removed?.alpha != 0.0 {
            removed?.run(SKAction.fadeOut(withDuration: 1))
        }
        
        if started != 1 {
            // Start spawning circles, but only when the user has started.
            let sq = SKAction.sequence([
                SKAction.wait(forDuration: 1.0),
                SKAction.run({
                    self.createCircle(pos: CGPoint(x: -UIScreen.main.bounds.width/4, y: UIScreen.main.bounds.height/4)
                    )})])
            self.run(SKAction.repeatForever(sq))
        }
        started = 1
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "circle" && contact.bodyB.node?.name == "line" {
            collisionBetween(circle: contact.bodyA.node!, line: contact.bodyB.node!)
        } else if contact.bodyB.node?.name == "circle" && contact.bodyA.node?.name == "line" {
            collisionBetween(circle: contact.bodyB.node!, line: contact.bodyA.node!)
        }
    }
    
    func collisionBetween(circle: SKNode, line: SKNode) {
        if (circle.physicsBody?.velocity.dy)! > CGFloat(20) || (circle.physicsBody?.velocity.dy)! < CGFloat(-20) &&
            (circle.physicsBody?.velocity.dx)! > CGFloat(100) || (circle.physicsBody?.velocity.dx)! < CGFloat(-100) {
            /*let sound = SKAction.playSoundFileNamed("marimba.m4a", waitForCompletion: false)
            let volume = SKAction.changeVolume(to: Float(0.0), duration: 0)
            let pitch = SKAction.changeObstruction(to: Float(circle.position.y), duration: 1)
            let group = SKAction.group([sound, volume, pitch])
            note.run(group)*/
            DispatchQueue.global().async {
                self.playNote(name: "marimba", type: "m4a", volume: Float(0.0), pitch: Float(circle.position.y))
            }
        }
    }
    
    func playNote(name: String, type: String, volume: Float, pitch: Float) {
        let path = Bundle.main.path(forResource: name, ofType: type)!
        let url = URL(fileURLWithPath: path)
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
            let note = try AVAudioPlayer(contentsOf: url)
            arrayOfPlayers.append(note)
            arrayOfPlayers.last?.prepareToPlay()
            arrayOfPlayers.last?.play()
        } catch {
            // We couldn't play the sound :^(
            print("Failed to play the sound!")
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        let positionInScene = pos
        let lineNode = SKShapeNode()
        let pathToDraw = CGMutablePath()
        
        pathToDraw.move(to: CGPoint(x: firstPoint.x, y: firstPoint.y))
        pathToDraw.addLine(to: CGPoint(x: positionInScene.x, y: positionInScene.y))
        //if (veryFirstPoint.x != positionInScene.x && veryFirstPoint.y != positionInScene.y) {
            // Don't bother drawing invisible lines that shit can get stuck on.
            lineNode.path = pathToDraw // Draw the path
        //}
        lineNode.lineWidth = 3.0
        lineNode.strokeColor = UIColor.white
        lineNode.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: firstPoint.x, y: firstPoint.y),
                                             to: CGPoint(x: positionInScene.x, y: positionInScene.y))
        lineNode.physicsBody?.isDynamic = false
        lineNode.physicsBody?.friction = 0
        lineNode.name = "line"
        shapeNodes.append(lineNode)
        
        self.addChild(lineNode)
        firstPoint = positionInScene
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    @objc func tripleTapped(_ sender: UITapGestureRecognizer) {
        for node in shapeNodes {
            node.removeFromParent()
        }
        shapeNodes.removeAll(keepingCapacity: false)
    }
    
    func createCircle(pos: CGPoint){
        let circle = SKShapeNode(circleOfRadius: 4)
        circle.position = pos
        circle.strokeColor = UIColor.black
        circle.fillColor = UIColor.white
        circle.physicsBody = SKPhysicsBody(circleOfRadius: 4)
        circle.physicsBody!.contactTestBitMask = circle.physicsBody!.collisionBitMask
        circle.physicsBody?.restitution = 1
        circle.name = "circle"
        nodesToCheck.append(circle)
        self.addChild(circle)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
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
    
    func clean() {
        // Uh oh, our FPS seems very low. Automatically removing all nodes and letting the user know!
        for node in shapeNodes {
            node.removeFromParent()
        }
        shapeNodes.removeAll(keepingCapacity: false)
        removed?.position = CGPoint(x: 0, y: UIScreen.main.bounds.height/4)
        removed?.alpha = 1
        timesLagged = 0
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        // Clean all the trash, please!
        for node in nodesToCheck {
            if nodeLimit == Float(0.0) { nodeLimit = Float(15.0) }
            if nodesToCheck.count > Int(nodeLimit) {
                //
                nodeLimit = UserDefaults.standard.float(forKey: "getnl")
                // No more than so many circles, please!
                nodesToCheck.first!.removeFromParent()
                nodesToCheck.removeFirst()
            }
            if node.position.y < -UIScreen.main.bounds.height {
                node.removeFromParent()
            }
        }
        let deltaTime = currentTime - lastUpdateTime
        FPS = 1 / deltaTime
        // Make sure we're not lagging.
        if FPS < 10 {
            aclb = UserDefaults.standard.bool(forKey: "aclb")
            if aclb { // Don't do stuff unless the user wants us to.
                if timesLagged > 50 {
                    clean()
                } else {
                    timesLagged += 1
                }
            } else {
                timesLagged = 0 // Quick thing to make it update the variables less often.
            }
        }
        lastUpdateTime = currentTime
    }
}
