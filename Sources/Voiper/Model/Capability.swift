

import Foundation

public enum Capability: String, Decodable {
    case sms, voice, mms, fax
    
    public var label: String? {
        switch self {
        case .voice:
            return .voice
        case .sms:
            return .sms
        case .mms:
            return .mms
        default:
            return nil
        }
    }
}

extension Capability: CustomStringConvertible {
    public var description: String {
        return self.rawValue
    }
}


extension Capability {
    public init?(rawValue: String) {
        switch rawValue {
        case "sms":
            self = .sms
        case "voice":
            self = .voice
        case "mms":
            self = .mms
        case "fax":
            self = .fax
        default:
            return nil
        }
    }
}

fileprivate extension String {
    static var sms: String { "SMS".localized }
    static var mms: String { "MMS".localized }
    static var voice: String { "Voice".localized }
}
