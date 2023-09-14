import Foundation
import PromiseKit
import RealmSwift

public class ActivityModel: Observable1 {
    public enum Event {
        case initial, update([Int], [Int], [Int])
    }
    public var observerTokenGenerator: Int = 0
    public var observers: [Int : (ActivityModel.Event) -> Void] = [:]
    public var initialEvent: ActivityModel.Event? = .initial
    
    private var chats: [String: ChatModel] = [:]
    private var service: Service
    public unowned var phoneModel: PhoneModel
    public let phoneNumber: PhoneNumber
    private var updateTimer: Timer?
    private let localActivities: Results<ActivityRealm>
    private var token: NotificationToken?
    public var lastActivities: [Activity] = []
    private var handler = NotificationHandler()
    
    init(phoneModel: PhoneModel, service: Service) {
        self.service = service
        self.phoneModel = phoneModel
        phoneNumber = phoneModel.phoneNumber
        let realm = try! Realm()
        localActivities = realm.objects(ActivityRealm.self)
            .filter(NSPredicate(format: "numberId == \(phoneModel.phoneNumber.id)"))
            .sorted(byKeyPath: "activityId", ascending: false)
        _ = initialLoad()
    }
    
    deinit {
        token?.invalidate()
    }
    
    func initialLoad() -> Promise<Void> {
        handler.registerNotificationName(Constant.newPushNotification) { [unowned self] notification in
            self.update()
        }
        
        token = localActivities.observe { [unowned self] changes in
            switch changes {
            case .initial:
                self.lastActivities = self.localActivities.map { Activity(activity: $0) }
                self.notifyObservers(.initial)
            case .update(_, let deletions, let insertions, let modifications):
                self.lastActivities = self.localActivities.map { Activity(activity: $0) }
                self.notifyObservers(.update(deletions, insertions, modifications))
            case .error:
                break
            }
        }
        
        return update()
    }
    
    public func checkAccessNotification() {
        _ = PushNotification.checkAccess()
            .done { success in
                if !success {
                    self.updateTimer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(self.timerUpdate), userInfo: nil, repeats: true)
                } else {
                    self.updateTimer?.invalidate()
                    self.updateTimer = nil
                }
            }
    }
    
    @discardableResult
    public func update() -> Promise<Void> {
        return remoteActivities()
            .done { activities in
                activities.activity.forEach {
                    if let chat = self.chats[$0.participant] {
                        chat.update(with: $0)
                    } else {
                        let chat = ChatModel(service: self.service, activityModel: self, numberId: self.phoneNumber.id, participant: $0.participant)
                        self.chats[$0.participant] = chat
                        chat.update(with: $0)
                    }
                }
                var messageCount = 0
                var callsCount = 0
                
                activities.activity.forEach { activity in
                    if  activity.type == .message && activity.isRead == false {
                        messageCount +=  1
                    }
                    if  activity.type == .call && activity.isRead == false {
                        callsCount +=  1
                    }
                }
                NotificationCenter.default.post(name: Constant.reloadBadges , object: nil, userInfo: ["message":"\(messageCount)","call":"\(callsCount)", "phoneNumberID": activities.phoneNumberID])
        }
    }
    
    public func chat(for participant: String) -> ChatModel {
        guard let chat = chats[participant] else {
            let chat = ChatModel(service: service, activityModel: self, numberId: phoneNumber.id, participant: participant)
            chats[participant] = chat
            return chat
        }
        return chat
    }
    
    public func readChat(for participant: String, numberId:Int){
        let promise: Promise<EmptyResponse> = service.execute(.readChat(numberId, participant))
        let _ = promise.done { _ in
            self.update()
        }
    }
    
    @objc private func timerUpdate() {
        update()
    }
    
    private func remoteActivities() -> Promise<(activity: [Activity], phoneNumberID: Int)> {
        let promise: Promise<ActivitiesResponse> = service.execute(.getActivities(phoneNumber.id))
        return promise.then(on: DispatchQueue.global()) { response -> Promise<(activity: [Activity], phoneNumberID: Int)> in
            let activities = response.activities
            let realm = try! Realm()
            try! realm.write {
                activities.forEach({
                    realm.add(ActivityRealm.create(with: $0), update: .all)
                })
            }
            
            return Promise.value((activities, self.phoneNumber.id))
        }
    }
}
