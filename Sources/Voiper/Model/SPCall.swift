import Foundation
import TwilioVoice
import PromiseKit
import CallKit


public class SPCall: NSObject {
    public enum State:Equatable {
        
        public static func == (lhs: SPCall.State, rhs: SPCall.State) -> Bool {
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
    
    public let uuid: UUID
    public let isOutgoing: Bool
    public var handle: String
    public var state: State = .none
    
    public var twilioCallInvite: CallInvite?
    public var twilioCall: Call?
    
    public var connectingDate: Date?
    public var connectDate: Date?
    public var endDate: Date?
    var isOnHold: Bool {
        set {
            twilioCall?.isOnHold = newValue
        }
        get {
            return twilioCall?.isOnHold ?? false
        }
    }
    public var isMuted: Bool {
        set {
            twilioCall?.isMuted = newValue
        }
        get {
            return twilioCall?.isMuted ?? false
        }
    }
    
    var callConnectBlock: (() -> ())?
    var callDisconnectBlock: ((Error?) -> ())?
    
    public var duration: TimeInterval {
        guard let connectDate = connectDate else {
            return 0
        }
        
        return Date().timeIntervalSince(connectDate)
    }
    
    public init(uuid: UUID, handle: String, isOutgoing: Bool = false) {
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
    
    public func sendDigits(_ digits: String) {
        twilioCall?.sendDigits(digits)
    }
    
    func disconnect() {
        //migrate
        if let invite = twilioCallInvite {
            invite.reject()
            twilioCallInvite = nil
            state = .ended
            endDate = Date()
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
            endDate = Date()
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
        state = .connected
        connectDate = Date()
        callConnectBlock?()
    }
}
