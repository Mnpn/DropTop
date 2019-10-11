//
//  GameViewController.swift
//  DropTop
//
//  Created by Mnpn on 19/05/2018.
//  Copyright © 2018 Mnpn. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    // Create a UIScreenEdgePanGestureRecognizer.
    var screenEdgeRecognizer: UIScreenEdgePanGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        view = self.view
        screenEdgeRecognizer = UIScreenEdgePanGestureRecognizer(target: self,
                                                                action: #selector(GameViewController.settings))
        screenEdgeRecognizer.edges = .left
        view.addGestureRecognizer(screenEdgeRecognizer)
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                // Present the scene
                view.presentScene(scene)
            }
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func settings() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let settings = storyBoard.instantiateViewController(withIdentifier: "Settings")
        self.present(settings, animated: true, completion: nil)
    }
}
