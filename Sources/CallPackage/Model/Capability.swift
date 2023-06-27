//
//  File.swift
//  
//
//  Created by Maxim Okolokulak on 12.06.23.
//

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

fileprivate extension String {
    static var sms: String { "SMS".localized }
    static var mms: String { "MMS".localized }
    static var voice: String { "Voice".localized }
}
