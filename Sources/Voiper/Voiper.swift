
import Foundation
import PromiseKit
public class Voiper {
    
    public let nw = NW.shared
    public let accountManager = AccountManager.shared
    public let contactManager = ContactsManager.shared
    public let analyticManager = AnalyticManager.shared
    public let purchaseManager = PurchaseManager.shared
    public let verificationManager = VerificationUserManager.shared
    
    public init() {
        contactManager.loadContacts(filter: .none)
        verificationManager.accountManager = accountManager
        analyticManager.setupAnalytic()
    }
}
