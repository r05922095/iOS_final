//
//  ViewController.swift
//  VideoPlayer
//
//  Created by 徐銘威 on 2018/6/5.
//  Copyright © 2018年 徐銘威. All rights reserved.
//

import UIKit
import ARKit
import YoutubeKit


class ViewController: UIViewController,UITextFieldDelegate, YTSwiftyPlayerDelegate, ARSessionDelegate {

    

    
   
    var time = 0
    var player: YTSwiftyPlayer!
    let session = ARSession()
    var textfield :UITextField!
    var maskNode: Mask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        let config = ARFaceTrackingConfiguration()
        config.worldAlignment = .gravity
        session.delegate = self
        config.isLightEstimationEnabled = true
        session.run(config, options: [])
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        player = YTSwiftyPlayer(frame: CGRect(x: 0, y: 0, width: screenWidth, height:screenHeight ), playerVars: [.autoplay(true), .videoID("mW6hFttt_KE"), .playsInline(false)])
        
        view.addSubview(player)
        player.delegate = self
        player.loadPlayer()
       /*
        let button = UIButton(frame: CGRect(x: 150, y: 350, width: 100, height: 50))
        button.backgroundColor = .black
        button.setTitle("play", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        let button2 = UIButton(frame: CGRect(x: 150, y: 450, width: 100, height: 50))
        button2.backgroundColor = .black
        button2.setTitle("pause", for: .normal)
        button2.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        let button3 = UIButton(frame: CGRect(x: 150, y: 550, width: 100, height: 50))
        button3.backgroundColor = .black
        button3.setTitle("change", for: .normal)
        button3.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        let button4 = UIButton(frame: CGRect(x: 150, y: 650, width: 100, height: 50))
        button4.backgroundColor = .black
        button4.setTitle("forward", for: .normal)
        button4.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        textfield = UITextField(frame: CGRect(x:150, y:300, width: 200, height: 50))
        textfield.borderStyle = .roundedRect
        textfield.returnKeyType = .done
        textfield.clearButtonMode = .whileEditing
        textfield.keyboardType = .default
        textfield.delegate = self
        
        view.addSubview(button)
        view.addSubview(button2)
        view.addSubview(button3)
        view.addSubview(button4)
        view.addSubview(textfield)*/

    }
    
  var expressionsToUse: [Expression] = [SmileExpression(), EyebrowsRaisedExpression(), EyeBlinkLeftExpression(), EyeBlinkRightExpression(), JawOpenExpression(), LookLeftExpression(), LookRightExpression()] // all the possible expressions shown during a game session
    var currentExpression1: Expression?
    var currentExpression2: Expression?
    var currentExpression3: Expression?
    func facePlayer(){
        
        self.currentExpression1 = SmileExpression()
        self.currentExpression2 = EyebrowsRaisedExpression()
        self.currentExpression3 = JawOpenExpression()
    }
    
    
    func request(queryword: String){
        let request = SearchListRequest(part: [.id, .snippet],searchQuery: queryword, resourceType:[.video] )
        
    
        // Send a request.
        ApiSession.shared.send(request) { result in
            switch result {
            case .success(let response):
                for element in response.items{
                    print(element.id.videoID)
                    print(type(of: element.id.videoID))
                }
              
                var videoid = response.items[0].id.videoID!
                print("getvideo"+videoid)
                DispatchQueue.main.async {
                     self.player.loadVideo(videoID: videoid)
                }
               
               
            case .failed(let error):
                print(error)
            }
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @IBAction func buttonAction(sender: UIButton!){
        print("Button")
        if (sender.currentTitle == "play")
        {
            //player.playVideo()
            currentExpression1 = SmileExpression()
        }
        else if (sender.currentTitle == "pause")
        {
           player.pauseVideo()
//           player.loadVideo(videoID: "gH476CxJxfg")

        }
        else if (sender.currentTitle == "change")
        {
//            player.loadVideo(videoID: "gH476CxJxfg")
            
            print(textfield.text)
            request(queryword: textfield.text!)
//            player.loadVideo(videoID: "mW6hFttt_KE")
            time = 0
        }
        else
        {
            time = time+10
            player.seek(to: time, allowSeekAhead: true)
            request(queryword: "Iphone")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

  
    func player(_ player: YTSwiftyPlayer, didChangeState state: YTSwiftyPlayerState) {
        print("player change to state")
        
    }
    
    func player(_ player: YTSwiftyPlayer, didChangeQuality quality: YTSwiftyVideoQuality) {
        print("change quality")
    }
    
    func player(_ player: YTSwiftyPlayer, didReceiveError error: YTSwiftyPlayerError) {
        print("player receive error")
    }
    
    func player(_ player: YTSwiftyPlayer, didUpdateCurrentTime currentTime: Double) {
        print("update currenttime")
    }
    
    func player(_ player: YTSwiftyPlayer, didChangePlaybackRate playbackRate: Double) {
        print("change playbackrate")
    }
    
    func playerReady(_ player: YTSwiftyPlayer) {
        print("player ready")
        
    }
    
    func apiDidChange(_ player: YTSwiftyPlayer) {
        print("API changed")
    }
    
    func youtubeIframeAPIReady(_ player: YTSwiftyPlayer) {
        print("IFrameAPI Ready")
    }
    
    func youtubeIframeAPIFailedToLoad(_ player: YTSwiftyPlayer) {
        print("IFrameAPI Failed To Load")
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
    
    func processNewARFrame() {

        if let faceAnchor = self.currentFaceAnchor {
            
            self.currentExpression1 = SmileExpression()
            self.currentExpression2 = EyebrowsRaisedExpression()
            self.currentExpression3 = JawOpenExpression()
            if (self.currentExpression1?.isExpressing(from: faceAnchor))! && !(self.currentExpression1?.isDoingWrongExpression(from: faceAnchor))! {
                player.playVideo()
            }
            if (self.currentExpression2?.isExpressing(from: faceAnchor))! && !(self.currentExpression2?.isDoingWrongExpression(from: faceAnchor))! {
                player.pauseVideo()
            }
            if (self.currentExpression3?.isExpressing(from: faceAnchor))! && !(self.currentExpression3?.isDoingWrongExpression(from: faceAnchor))! {
                time = time+10
                player.seek(to: time, allowSeekAhead: true)
                request(queryword: "tt")
            }
            
        }
        
    }
   
}

