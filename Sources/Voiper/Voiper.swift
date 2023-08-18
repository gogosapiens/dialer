
import Foundation
import PromiseKit

public class Voiper {
    
    public let nw = NW.shared
    public let accountManager = AccountManager(service: Service.shared)
    public let contactManager = ContactsManager.shared
    public let analyticManager = AnalyticManager.shared
    public let subscriptionManager = EventManager.shared
    public let verificationManager = VerificationUserManager.shared
    
    public init() {
        contactManager.loadContacts(filter: .none)
        analyticManager.setupAnalytic()
    }
}
