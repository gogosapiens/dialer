

import Foundation
import RealmSwift

public class ActivityRealm: Object {
    @objc dynamic var activityId: Int = -1
    @objc dynamic var type: String = ""
    @objc dynamic var from: String = ""
    @objc dynamic var to: String = ""
    @objc dynamic var numberId: Int = -1
    @objc dynamic var participant: String = ""
    @objc dynamic var status: String = ""
    @objc dynamic var direction: String = ""
    @objc dynamic var read: Bool = false
    @objc dynamic var duration: Int = -1
    @objc dynamic var body: String?
    @objc dynamic var images: String?
    @objc dynamic var startedAt: Date?
    @objc dynamic var endedAt: Date?
    @objc dynamic var sentAt: Date?
    @objc dynamic var insertedAt: Date?
    @objc dynamic var compoundKey: String = ""
    
    public static func create(with activity: Activity) -> ActivityRealm {
        let realmObject = ActivityRealm()
        realmObject.activityId = activity.id
        realmObject.type = activity.type.rawValue
        realmObject.from = activity.from
        realmObject.to = activity.to
        realmObject.numberId = activity.numberId
        realmObject.participant = activity.participant
        realmObject.status = activity.status.rawValue
        realmObject.direction = activity.direction.rawValue
        realmObject.duration = activity.duration ?? 0
        realmObject.body = activity.body
        if let images = activity.images,
            images.count > 0 {
            realmObject.images = images.joined(separator: ",")
        } else {
            realmObject.images = nil
        }
        realmObject.startedAt = activity.startedAt
        realmObject.endedAt = activity.endedAt
        realmObject.sentAt = activity.sentAt
        realmObject.insertedAt = activity.insertedAt
        realmObject.read = activity.read
        realmObject.compoundKey = realmObject.compoundKeyValue()
        return realmObject
    }
    
    private func compoundKeyValue() -> String {
        return "\(numberId)\(participant)"
    }
    
    public override static func primaryKey() -> String? {
        return "compoundKey"
    }
    
}

public class ChatActivityRealm: Object {
    @objc dynamic var activityId: Int = -1
    @objc dynamic var type: String = ""
    @objc dynamic var from: String = ""
    @objc dynamic var to: String = ""
    @objc dynamic var numberId: Int = -1
    @objc dynamic var participant: String = ""
    @objc dynamic var status: String = ""
    @objc dynamic var direction: String = ""
    @objc dynamic var read: Bool = false
    @objc dynamic var duration: Int = -1
    @objc dynamic var body: String?
    @objc dynamic var images: String?
    @objc dynamic var startedAt: Date?
    @objc dynamic var endedAt: Date?
    @objc dynamic var sentAt: Date?
    @objc dynamic var insertedAt: Date?
    
    static func create(with activity: Activity) -> ChatActivityRealm {
        let realmObject = ChatActivityRealm()
        realmObject.activityId = activity.id
        realmObject.type = activity.type.rawValue
        realmObject.from = activity.from
        realmObject.to = activity.to
        realmObject.numberId = activity.numberId
        realmObject.participant = activity.participant
        realmObject.status = activity.status.rawValue
        realmObject.direction = activity.direction.rawValue
        realmObject.duration = activity.duration ?? 0
        realmObject.body = activity.body
        if let images = activity.images,
            images.count > 0 {
            realmObject.images = images.joined(separator: ",")
        } else {
            realmObject.images = nil
        }
        realmObject.startedAt = activity.startedAt
        realmObject.endedAt = activity.endedAt
        realmObject.sentAt = activity.sentAt
        realmObject.insertedAt = activity.insertedAt
        realmObject.read = activity.read
        return realmObject
    }
    
    public override class func primaryKey() -> String? {
        return "activityId"
    }
}
