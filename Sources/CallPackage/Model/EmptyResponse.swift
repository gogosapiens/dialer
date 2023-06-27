

import Foundation

public struct IgnreRespone:Decodable {
}

extension IgnreRespone: CustomStringConvertible {
    public var description: String {
        return jsonFormatDescription((name: "none", value: "none"))
    }
}

public struct LockResponse:Decodable {
    let locked_until:String
}

extension LockResponse: CustomStringConvertible {
    public var description: String {
        return jsonFormatDescription((name: "message", value: locked_until))
    }
}

public struct EmptyResponse: Decodable {
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case message = "msg"
    }
}

extension EmptyResponse: CustomStringConvertible {
    public var description: String {
        return jsonFormatDescription((name: "message", value: message))
    }
}

public struct ErrorResponse: Decodable {
    let error: String
}

extension ErrorResponse: CustomStringConvertible {
    public var description: String {
        return jsonFormatDescription((name: "error", value: error))
    }
}
