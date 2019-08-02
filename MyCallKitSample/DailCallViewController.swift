//
//  DailCallViewController.swift
//  CallKitSample
//
//  Created by GevinChen on 2019/8/2.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import UIKit
import CallKit
import AVFoundation

class DailCallViewController: UIViewController, CXProviderDelegate {

    var provider: CXProvider!
    var callController : CXCallController?
    var callIdOpt: UUID?
    var isHeldCall: Bool = false
    @IBOutlet weak var phoneTitleLabel: UILabel!
    @IBOutlet weak var endCallButton: UIButton!
    @IBOutlet weak var holdCallButton: UIButton! {
        didSet {
            self.holdCallButton.setTitleColor(UIColor.black, for: UIControl.State.selected)
            self.holdCallButton.setTitle("Resume Call", for: UIControl.State.selected)
            self.holdCallButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
            self.holdCallButton.setTitle("Hold Call", for: UIControl.State.normal)
        }
    }
    @IBOutlet weak var startCallButton: UIButton!
    @IBOutlet weak var phoneNumberTextfield: UITextField! {
        didSet {
            self.phoneNumberTextfield.keyboardType = .numberPad
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.callInit()
        
    }
    
    // 1.
    func callInit() {
        let config = CXProviderConfiguration(localizedName: "My Example")
        config.iconTemplateImageData = UIImage(named: "userPic.png")!.pngData()
        config.ringtoneSound = "ringtone.caf"
        
        //config.includesCallsInRecents = false; // support from ios 11
        config.supportsVideo = true;
        
        provider = CXProvider(configuration: config)
        provider.setDelegate(self, queue: nil)
        callController = CXCallController()
    }
    
    // 2.
    func startCall() {
        callIdOpt = UUID()
        let controller = CXCallController()
        let transaction = CXTransaction(action: CXStartCallAction(call: callIdOpt!, handle: CXHandle(type: .generic, value: "Pete Za")))
        controller.request(transaction, completion: { error in })
    }
    
    // 4.
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
    
    // MARK: - UI
    
    func displayTalkingUI( talking: Bool ) {
        if talking {
            self.endCallButton.isHidden = false
            self.holdCallButton.isHidden = false
            self.holdCallButton.isSelected = false
            self.startCallButton.isHidden = true
            self.phoneTitleLabel.isHidden = true
            self.phoneNumberTextfield.isHidden = true
        } else {
            self.endCallButton.isHidden = true
            self.holdCallButton.isHidden = true
            self.holdCallButton.isSelected = false
            self.startCallButton.isHidden = false
            self.phoneTitleLabel.isHidden = false
            self.phoneNumberTextfield.isHidden = false
        }
    }
    
    // MARK: - Action
    
    @IBAction func startCallClicked(_ sender: Any) {
        
        self.startCall()
        self.phoneNumberTextfield.resignFirstResponder()
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
    
    // If provider:executeTransaction:error: returned NO, each perform*CallAction method is called sequentially for each action in the transaction
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        print("provider Start Call Action");
        // 3.
        provider.reportOutgoingCall(with: action.callUUID, startedConnectingAt: nil)
        provider.reportOutgoingCall(with: action.callUUID, connectedAt: nil)
        self.displayTalkingUI(talking: true)
        // 這裡執行完成後，狀態就會是通話中，app 退到背景也不會 suspend
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        print("provider End Call Action")
        self.displayTalkingUI(talking: false)
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
