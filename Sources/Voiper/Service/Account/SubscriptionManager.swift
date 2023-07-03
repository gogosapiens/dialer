
import Foundation

public protocol SubscriptionDelegate: AnyObject {
    func didChangeActiveNumber()
}


public class SubscriptionManager {
    
    static let shared = SubscriptionManager()
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
    
}
