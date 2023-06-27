

import Foundation


public struct MessagePricingResponse: Decodable {
    let canSms: Bool
    let canMms: Bool
    let maxSmsCount: Int
    let maxMmsCount: Int
    let smsPricing: Pricing
    let mmsPricing: Pricing
    
    enum CodingKeys: String, CodingKey {
        case canSms =       "can_sms"
        case canMms =       "can_mms"
        case maxSmsCount =  "max_sms"
        case maxMmsCount =  "max_mms"
        case smsPricing =   "sms"
        case mmsPricing =   "mms"
    }
    
}

extension MessagePricingResponse: CustomStringConvertible {
    public var description: String {
        return jsonFormatDescription((name: "canSms", value: String(canSms)),
                                     (name: "canMms", value: String(canMms)),
                                     (name: "maxSmsCount", value: String(maxSmsCount)),
                                     (name: "maxMmsCount", value: String(maxMmsCount)),
                                     (name: "smsPricing", value: smsPricing.description),
                                     (name: "mmsPricing", value: mmsPricing.description))
    }
}
