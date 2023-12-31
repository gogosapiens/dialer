import Foundation

public struct SubscriptionsResponse: Decodable {
    public let first_number_subscr_id : Int?
    public let second_number_subscr_id : Int?
    public let subscriptions: [SubscriptionInfo]
}

extension SubscriptionsResponse: CustomStringConvertible {
    public var description: String {
        return jsonFormatDescription((name: "subscriptions", value: subscriptions.description))
    }
}

extension SubscriptionInfo: CustomStringConvertible {
    public var description: String {
        return jsonFormatDescription((name: "id", value: String(id)),
                                     (name: "productId", value: String(productId)),
                                     (name: "refunded", value: String(refunded)),
                                     (name: "cancelled", value: String(cancelled)),
                                     (name: "purchaseDate", value: purchaseDate.description),
                                     (name: "expiresDate", value: expiresDate.description),
                                     (name: "expiredAt", value: expiredAt?.description ?? "nil"),
                                     (name: "bundle", value: bundle))
    }
}
