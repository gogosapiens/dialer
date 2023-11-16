//
//  AddSubscriptionResponse.swift
//  
//
//  Created by Andrei (Work) on 27/07/2023.
//

import Foundation

public struct AddSubscriptionResponse: Decodable {
    let firstSubscriptionId: Int?
    let secondSubscriptionId: Int?
    let subscriptions: [SubscriptionInfo]

    enum CodingKeys: String, CodingKey {
        case firstSubscriptionId = "first_active_subscr_id"
        case secondSubscriptionId = "second_active_subscr_id"
        case subscriptions = "subscriptions"
    }
}

extension AddSubscriptionResponse: CustomStringConvertible {
    public var description: String {

        return jsonFormatDescription( (name: "firstSubscriptionId", value: String(firstSubscriptionId ?? -1)),
                                      (name: "secondSubscriptionId", value: String(secondSubscriptionId ?? -1)))
    }
}
