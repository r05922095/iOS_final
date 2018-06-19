/**
 *  Swift Alps Game Jam
 *  Copyright (c) John Sundell 2017
 *  MIT license. See LICENSE file for details.
 */

import UIKit
import SpriteKit
import ARKit

@available(iOS 11.0, *)
final class GameViewController: UIViewController, ARSessionDelegate {
    override var prefersStatusBarHidden: Bool { return true }
    var scene: AsteroidsScene?
    
    let session = ARSession()
    var maskNode: Mask?

    private lazy var gameView = SKView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = ARFaceTrackingConfiguration()
        config.worldAlignment = .gravity
        session.delegate = self
        session.run(config, options: [])
        
        view.addSubview(gameView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gameView.frame = view.bounds

        if gameView.scene == nil {
            gameView.presentScene(scene)
        }
    }
    
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
    var leftExpression: Expression? = EyeBlinkRightExpression()
    var rightExpression: Expression? = EyeBlinkLeftExpression()
    
    func processNewARFrame() {
        // called each time ARKit updates our frame (aka we have new facial recognition data)
        if let faceAnchor = self.currentFaceAnchor {
            if ((leftExpression?.isExpressing(from: faceAnchor))! && !(leftExpression?.isDoingWrongExpression(from: faceAnchor))!) {
                // succeeded! (but only if they're not also doing the wrong expression, like raising both eyebrows)
                scene?.blinkMovedLeft()
            } else if ((rightExpression?.isExpressing(from: faceAnchor))! && !(rightExpression?.isDoingWrongExpression(from: faceAnchor))!) {
                // succeeded! (but only if they're not also doing the wrong expression, like raising both eyebrows)
                scene?.blinkMovedRight()
            }
        } 

    }
}
