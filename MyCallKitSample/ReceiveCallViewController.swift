//
//  ReceiveCallViewController.swift
//  CallKitSample
//
//  Created by GevinChen on 2019/8/2.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import UIKit
import CallKit
import AVFoundation

class ReceiveCallViewController: UIViewController, CXProviderDelegate {

    var provider: CXProvider!
    var callController : CXCallController?
    var callIdOpt: UUID?
    var isHeldCall: Bool = false
    
    @IBOutlet weak var endCallButton: UIButton!
    @IBOutlet weak var holdCallButton: UIButton! {
        didSet {
            self.holdCallButton.setTitleColor(UIColor.black, for: UIControl.State.selected)
            self.holdCallButton.setTitle("Resume Call", for: UIControl.State.selected)
            self.holdCallButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
            self.holdCallButton.setTitle("Hold Call", for: UIControl.State.normal)
        }
    }
    @IBOutlet weak var receivePushButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.callInit()
    }
    
    func callInit() {
        let config = CXProviderConfiguration(localizedName: "My Example")
        config.iconTemplateImageData = UIImage(named: "userPic.png")!.pngData()
        //config.ringtoneSound = "ringtone.caf"
        
        //config.includesCallsInRecents = false; // support from ios 11
        config.supportsVideo = true;

        provider = CXProvider(configuration: config)
        provider.setDelegate(self, queue: nil)
        callController = CXCallController()
    }
    
    // 
    func receiveVoipPush() {
        
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: "Friend")
        update.hasVideo = true
        callIdOpt = UUID()
        // #Gevin_Note: 
        //  The native CallKit UI can't keep after press accept button.
        provider.reportNewIncomingCall(with: callIdOpt!, update: update, completion: { error in 
            if error != nil {
                print(error ?? "")
            }
            else {
                self.endCallButton.isHidden = false
                self.holdCallButton.isHidden = false
                self.receivePushButton.isHidden = true
            }
        })
    }
    
    func endCall() {
        guard let callId = callIdOpt else {return}
        let endCallAction = CXEndCallAction.init(call: callId)
        let transaction = CXTransaction.init()
        transaction.addAction(endCallAction)
        callController?.request(transaction, completion: {[weak self] (error : Error?) in
            guard self != nil else {return}
            if error != nil {
                print("\(error?.localizedDescription ?? "")")
            }
        })
    
    }
    
    func holdCall(hold : Bool) {
        guard let callId = callIdOpt else {return}
        let holdCallAction = CXSetHeldCallAction.init(call: callId, onHold: hold)
        let transaction = CXTransaction.init()
        transaction.addAction(holdCallAction)
        callController?.request(transaction, completion: {[weak self] (error : Error?) in
            guard self != nil else {return}
            if error != nil {
                print("\(error?.localizedDescription ?? "")")
            }
        })
    }
    
    // MARK: - Action
    
    @IBAction func receiveVoipPushClicked(_ sender: Any) {
        self.receiveVoipPush()
    }

    @IBAction func endCallClicked(_ sender: Any) {
        self.endCall()
    }
    
    @IBAction func holdCallClicked(_ sender: Any) {
        self.holdCallButton.isSelected = !self.holdCallButton.isSelected 
        self.holdCall(hold: self.holdCallButton.isSelected )
    }
    
    // MARK: - CXProviderDelegate
    
    func providerDidReset(_ provider: CXProvider) {
        print("providerDidReset")
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        print("provider Answer Call Action")
        // TODO: connecting video call
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        print("provider End Call Action")
        self.endCallButton.isHidden = true
        self.holdCallButton.isHidden = true
        self.holdCallButton.isSelected = false
        self.receivePushButton.isHidden = false
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        print("provider Set Held Call Action")
        if action.isOnHold {
            //todo: stop audio
        } else {
            //todo: start audio
        }
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        print("provider Mute Call Action")
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetGroupCallAction) {
        print("provider Group Call Action")
    }
    
    func provider(_ provider: CXProvider, perform action: CXPlayDTMFCallAction) {
        print("provider DTMF Call Action")
    }
    
    // Called when an action was not performed in time and has been inherently failed. Depending on the action, this timeout may also force the call to end. An action that has already timed out should not be fulfilled or failed by the provider delegate
    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
        print("provider time out")
        // React to the action timeout if necessary, such as showing an error UI.
    }
    
    /// Called when the provider's audio session activation state changes.
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        //todo: start audio
        // Start call audio media, now that the audio session has been activated after having its priority boosted.
    }
    
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        /*
         Restart any non-call related audio now that the app's audio session has been
         de-activated after having its priority restored to normal.
         */  
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
