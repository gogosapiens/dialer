

import Foundation

public struct VoicePricingResponse: Decodable {
    public let canCall: Bool
    let minutes: Int
    public let voice: [Int]
    
    enum CodingKeys: String, CodingKey {
        case canCall = "can_call"
        case minutes
        case voice
    }
}

extension VoicePricingResponse: CustomStringConvertible {
    public var description: String {
        return jsonFormatDescription((name: "canCall", value: String(canCall)),
                                     (name: "minutes", value: String(minutes)),
                                     (name: "voice", value: voice.description))
    }
}
