
import Foundation


public struct Pricing: Decodable {
    let inbound: [Int]?
    let outbound: [Int]?
}

extension Pricing: CustomStringConvertible {
    public var description: String {
        return jsonFormatDescription((name: "inbound", value: inbound?.description ?? ""),
                                     (name: "outbound", value: outbound?.description ?? ""))
    }
}

public struct PricingResponse: Decodable {
    let voice: Pricing
    let sms: Pricing
    let mms: Pricing
}

extension PricingResponse: CustomStringConvertible {
    public var description: String {
        return jsonFormatDescription((name: "voice", value: voice.description),
                                     (name: "sms", value: sms.description),
                                     (name: "mms", value: mms.description))
    }
}
