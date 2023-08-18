
import Foundation

public protocol EventManagerDelegate: AnyObject {
    func didChangeActivePhoneNumber()
    func didDeletePhoneNumber()
    func didAddPhoneNumber()
}

public class EventManager {
    
    static let shared = EventManager()
    private init() {}
    
    private var delegates: [EventManagerDelegate] = []
    
    
    public func subscribe(_ delegate: EventManagerDelegate) {
        delegates.append(delegate)
    }
    
    public func unSubscribe(for delegate: EventManagerDelegate) {
        if let delegateIndex = delegates.firstIndex(where: { $0 === delegate }) {
            delegates.remove(at: delegateIndex)
        }
    }

    func sendChangeNumberEvents() {
        delegates.forEach({$0.didChangeActivePhoneNumber()})
    }
    
    func sendDeleteNumberEvent() {
        delegates.forEach({$0.didDeletePhoneNumber()})
    }
    
    func sendAddNumberEvent() {
        delegates.forEach({$0.didAddPhoneNumber()})
    }
}
