

import Foundation
import UIKit
import TwilioVoice
import PromiseKit
import CallKit

protocol CallIntentHandler {
    func handleStartCallIntent(_ handle: String)
}

protocol VoipNotificationHandler: AnyObject {
    func handleVoipNotification(_ payload: [AnyHashable: Any])
}

public class CallFlow: NSObject, OnNotification {
    public var handler = NotificationHandler()
    
    static let windowLevel = UIWindow.Level.alert + 2
    private var callModel: CallModel?
    weak var callManager: CallManager?
    
    private let provider: CallProvider = {
        if let provider = CallMagic.provider {
            return provider
        } else {
            CallMagic.provider = CallProvider()
            return CallMagic.provider!
        }
    }()
    
    private let window: UIWindow = {
        let rect = UIScreen.main.bounds
        let window = UIWindow(frame: rect)
        window.windowLevel = CallFlow.windowLevel
        return window
    }()
    
    override init() {
        super.init()
        
//        provider = CallProvider()
        handler.registerNotificationName(UIApplication.willEnterForegroundNotification) { [unowned self] _ in
            if self.callModel != nil {
                self.showCall()
            }
        }
        
        handler.registerNotificationName(Notification.Name(rawValue: "ShowCall")) { [unowned self] _ in
            if self.callModel != nil {
                self.showCall()
            }
        }
    }
    
    func start(_ call: SPCall, service: Service) -> Promise<Void> {
        if call.isOutgoing {
//            trackEvent("CallOrMessage")
        }
        return Promise { seal in
          
            guard callModel == nil,
                let callManager = callManager else {
                    seal.resolve(ServiceError.innactiveNumber)
                    return
            }
            
            guard call.handle.count > 5 else {
                    seal.resolve(nil)
                    return
            }
            
//            guard AppDelegate.shared.accountManager.account?.paused == false else {
//                seal.reject(ServiceError.accountPaused)
//                return
//            }
            
//            guard callManager.phoneNumber.isActive else {
//                if Settings.isRestoringPeriod {
//                    seal.reject(ServiceError.phoneRestoring(callManager.phoneNumber.number))
//                } else {
//                    seal.resolve(nil)
//                }
//                return
//            }
             
            self.callModel = CallModel(call: call, callFlow: self, callProvider: self.provider, callManager: callManager)
            
            self.provider.delegate = self.callModel
            
            if self.callModel?.call.isOutgoing == true {
                self.showCall()
            }
            
            seal.fulfill(())
        }
    }
    
    func endCall() {
//        hideCall().done { _ in
//            self.callModel = nil
//            self.hideWindow()
//            self.callManager?.phoneModel.activityModel.update()
//        }
    }
    
//    func hideCall() -> Guarantee<Void> {
//        return UIView.animate(.promise, duration: 0.25) {
//                self.window.alpha = 0
//            }.done { _ in
//                self.window.isHidden = true
//                self.window.alpha = 1
//        }
//    }
    
    func showCall() {
        guard let callModel = callModel else { return }
        
        DispatchQueue.main.async {
//            if callModel.callVC == nil {
//                let controller = CallVC(callModel: callModel)
//                self.window.rootViewController = controller
//                self.window.makeKeyAndVisible()
//                callModel.callVC = controller
//            }
            
//            self.window.isHidden = false
//            self.window.alpha = 0
//            UIView.animate(.promise, duration: 0.25) {
//                self.window.alpha = 1
//            }
        }
    }
    
    private func hideWindow() {
        window.isHidden = true
        window.rootViewController = nil
    }
}

extension CallFlow: VoipNotificationHandler {
    func handleVoipNotification(_ payload: [AnyHashable: Any]) {
        print("TWILIO HANDLE VOIP")
        TwilioVoiceSDK.handleNotification(payload, delegate: self, delegateQueue: nil)
    }
}

extension CallFlow: CallIntentHandler {
    
    func handleStartCallIntent(_ handle: String) {
        let set = CharacterSet(charactersIn: "+1234567890")
        let cleanHandle = handle.replacingOccurrences(of: " ", with: "")
        .replacingOccurrences(of: "-", with: "")
        .replacingOccurrences(of: "(", with: "")
        .replacingOccurrences(of: ")", with: "")
        .trimmingCharacters(in: set.inverted)
        
        if let uid = CallMagic.UID {
            let call = SPCall(source:"Intent" ,uuid: uid, handle: cleanHandle, isOutgoing: true)
            _ = start(call, service: Service.shared)
        } else {
            print("TWILIO INVITE NO UID")
        }
    
    }
}

extension CallFlow: NotificationDelegate {
    public func cancelledCallInviteReceived(cancelledCallInvite: CancelledCallInvite, error: Error) {
        callModel?.handleNotifiactionCancel(cancelledCallInvite)
    }
    
    public func callInviteReceived(callInvite: CallInvite) {
        
        //if self.callModel?.call.state == .pending {
            if let uid = CallMagic.UID {
                let call = SPCall(source:"Notification", uuid: uid , handle: callInvite.from ?? "")
                call.twilioCallInvite = callInvite
                _ = start(call, service: Service.shared)
            }
        //}
        
        //migrate
        /*
        
        if callInvite.state == .pending {
            print("TWILIO INVITE RECIEVED \(callInvite.uuid)")
            if let uid = CallMagic.UID {
                
                let call = SPCall(source:"Notification", uuid: uid , handle: callInvite.from)
                call.twilioCallInvite = callInvite
                _ = start(call)
                
                print("TWILIO INVITE RECIEVED \(callInvite.uuid) read UID uid")
            } else {
                print("TWILIO INVITE NO UID")
            }
        } else if callInvite.state == .canceled {
            print("TWILIO INVITE CANCELLED")
            callModel?.handleNotifiactionCancel(callInvite)
        }*/
    }
    
    func notificationError(_ error: Error) {
        print("Twilio notification error: \(error.localizedDescription)")
    }
}
