

import Foundation
import TwilioVoice
import PromiseKit
import CallKit


public class SPCall: NSObject {
    enum State:Equatable {
        
        static func == (lhs: SPCall.State, rhs: SPCall.State) -> Bool {
            switch (lhs, rhs ) {
                case (.none, .none):
                    return true
                case (.pending, .pending):
                    return true
                case (.start, .start):
                    return true
                case (.connecting, .connecting):
                    return true
                case (.connected, .connected):
                    return true
                case (.ending, .ending):
                    return true
                case (.ended, .ended):
                    return true
                case (.failed(_), .failed(_)):
                    return true
                default:
                    return false
            }
        }
        
        case none, pending, start, connecting, connected, ending, ended
        case failed(Error?)
    }
    
    let uuid: UUID
    let isOutgoing: Bool
    var handle: String
    var state: State = .none
    
    var source:String = "Keypad"
    
    var twilioCallInvite: CallInvite?
    var twilioCall: Call?
    
    var connectingDate: Date?
    var connectDate: Date?
    var endDate: Date?
    var isOnHold: Bool {
        set {
            twilioCall?.isOnHold = newValue
        }
        get {
            return twilioCall?.isOnHold ?? false
        }
    }
    var isMuted: Bool {
        set {
            twilioCall?.isMuted = newValue
        }
        get {
            return twilioCall?.isMuted ?? false
        }
    }
    
    var callConnectBlock: (() -> ())?
    var callDisconnectBlock: ((Error?) -> ())?
    
    var duration: TimeInterval {
        guard let connectDate = connectDate else {
            return 0
        }
        
        return Date().timeIntervalSince(connectDate)
    }
    
    public init(source:String, uuid: UUID, handle: String, isOutgoing: Bool = false) {
        self.source = source
        self.uuid = uuid
        self.isOutgoing = isOutgoing
        self.handle = handle
    }
    
    func connect(with token: String) {
        state = .connecting
        connectingDate = Date()
       
        let option = ConnectOptions(accessToken: token) { [handle] builder in
            builder.params = ["To": handle]
        }
       
        twilioCall = TwilioVoiceSDK.connect(options: option, delegate: self)
    }
    
    func answer() -> Bool {
        guard let invite = twilioCallInvite else {
            return false
        }
        connectingDate = Date()
        state = .connecting
        
        //migrate
        
        self.twilioCall = invite.accept(with: self)
       
        twilioCallInvite = nil
        return true
    }
    
    func sendDigits(_ digits: String) {
        twilioCall?.sendDigits(digits)
    }
    
    func disconnect() {
        //migrate
        if let invite = twilioCallInvite {
            invite.reject()
            twilioCallInvite = nil
            state = .ended
        } else if let twCall = twilioCall {
            twCall.disconnect()
            twilioCall = nil
            state = .ending
        }
    }
}

extension SPCall: CallDelegate {
    public func callDidDisconnect(call: Call, error: Error?) {
        if let error = error {
            state = .failed(error)
            print("Call failed: \(error.localizedDescription)")
        } else {
            state = .ended
            print("Call disconnected")
        }
        
        callDisconnectBlock?(error)
    }
    
    
    public func callDidFailToConnect(call: Call, error: Error) {
        print("Call failed to connect: \(error.localizedDescription)")
        state = .failed(error)
        callDisconnectBlock?(error)
    }
  
    public func callDidConnect(call twilioCall: Call) {
        print("callDidConnect:")
        
        //self.twilioCall = twilioCall
        state = .connected
        connectDate = Date()
        callConnectBlock?()
    }

}
