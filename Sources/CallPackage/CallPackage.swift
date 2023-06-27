
import Foundation
import PromiseKit

public class CallPackage {
    
    public let nw = NW.shared
    public let accountManager = AccountManager(service: Service.shared)
    public let contactManager = ContactsManager.shared

    public init() {
        contactManager.loadContacts(filter: .none)
    }
    
}
