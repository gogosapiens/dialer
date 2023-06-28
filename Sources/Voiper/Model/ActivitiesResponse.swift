

import Foundation

public struct ActivitiesResponse: Decodable {
    let activities: [Activity]
    let delayed_messages: [DelayedDessages]?
}

extension ActivitiesResponse: CustomStringConvertible {
    public var description: String {
        let delayDesc = delayed_messages?.description ?? ""
        return jsonFormatDescription((name: "activities", value: activities.description + "\n" + delayDesc))
    }
}


public class DelayedDessages:Codable {

    let account_number_id: Int
    let body: String
    let cancel_id: Int
    let to:String
    let type:String
    let will_be_sent_at:Date?
    let inserted_at:Date?
}
