
import Foundation

public protocol SubscriptionDelegate: AnyObject {
    func didChangeActivePhoneNumber()
    func didDeletePhoneNumber()
    func didAddPhoneNumber()
}

public class EventManager {
    
    static let shared = EventManager()
    private init() {}
    
    private var delegates: [SubscriptionDelegate] = []
    
    
    public func subscribe(_ delegate: SubscriptionDelegate) {
        delegates.append(delegate)
    }
    
    public func unSubscribe(for delegate: SubscriptionDelegate) {
        if let delegateIndex = delegates.firstIndex(where: { $0 === delegate }) {
            delegates.remove(at: delegateIndex)
        }
    }

    func sendChangeNumberEvents() {
        delegates.forEach({$0.didChangeActiveNumber()})
    }
    
    func sendDeleteNumberEvent() {
        delegates?.forEach({$0.didDeleteNumber()})
    }
    
    func sendAddNumberEvent() {
        delegates?.forEach({$0.didAddPhoneNumber()})
    }
}
