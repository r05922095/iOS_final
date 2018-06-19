//
//  GameViewController.swift
//  FlappyBird
//
//  Created by Nate Murray on 6/2/14.
//  Copyright (c) 2014 Fullstack.io. All rights reserved.
//

import UIKit
import ARKit
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(_ file : String) -> SKNode? {
        
        let path = Bundle.main.path(forResource: file, ofType: "sks")
        
        let sceneData: Data?
        do {
            sceneData = try Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe)
        } catch _ {
            sceneData = nil
        }
        let archiver = NSKeyedUnarchiver(forReadingWith: sceneData!)
        
        archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
        let scene = archiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as! GameScene
        archiver.finishDecoding()
        return scene
    }
}

@available(iOS 11.0, *)
class GameViewController: UIViewController, ARSessionDelegate {

    let session = ARSession()
    var maskNode: Mask?
    
    var gameScene: GameScene?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = ARFaceTrackingConfiguration()
        config.worldAlignment = .gravity
        session.delegate = self
        session.run(config, options: [])
        
        gameScene = GameScene.unarchiveFromFile("GameScene") as? GameScene
        
        if let scene = gameScene {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFill
            
            skView.presentScene(scene)
        }
    }
    
    // MARK: - AR Session
    
    var currentFaceAnchor: ARFaceAnchor?
    var currentFrame: ARFrame?
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        self.currentFrame = frame
        DispatchQueue.main.async {
            // need to call heart beat on main thread
            self.processNewARFrame()
        }
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let faceAnchor = anchors.first as? ARFaceAnchor else { return }
        self.currentFaceAnchor = faceAnchor
        self.maskNode?.update(withFaceAnchor: faceAnchor)
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        
    }
    var expressionsToUse: [Expression] = [SmileExpression(), EyebrowsRaisedExpression(), EyeBlinkLeftExpression(), EyeBlinkRightExpression(), JawOpenExpression(), LookLeftExpression(), LookRightExpression()]
    var currentExpression: Expression? = EyeBlinkRightExpression()
    
    func processNewARFrame() {
        // called each time ARKit updates our frame (aka we have new facial recognition data)
        if let currentExpression = self.currentExpression, let faceAnchor = self.currentFaceAnchor {
            if currentExpression.isExpressing(from: faceAnchor) {
                // succeeded! (but only if they're not also doing the wrong expression, like raising both eyebrows)
                gameScene?.didExpress()
            }
        }
    }
    override var shouldAutorotate : Bool {
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return UIInterfaceOrientationMask.allButUpsideDown
        } else {
            return UIInterfaceOrientationMask.all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
}
