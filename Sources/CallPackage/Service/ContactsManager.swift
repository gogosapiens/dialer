//
//  File.swift
//  
//
//  Created by Maxim Okolokulak on 26.06.23.
//

import CallKit
import Contacts
import ContactsUI
import Foundation
import PromiseKit
import KeychainAccess

public class ContactsManager {
    
    public static let contactsUpdateNotification = Notification.Name("contactsUpdateNotification")
    var store = CNContactStore()
    public static let shared = ContactsManager()
    private init() {
    }
    public var contacts: [Contact] = []
    public var cnContacts: [CNContact] = []
    
    public func requestAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            Settings.hasAccessContact = true
            completionHandler(true)
        case .denied:
            Settings.hasAccessContact = false
            completionHandler(false)
        case .restricted, .notDetermined:
            store.requestAccess(for: .contacts) { granted, error in
                if granted {
                    Settings.hasAccessContact = true
                    completionHandler(true)
                } else {
                    Settings.hasAccessContact = false
                }
            }
        @unknown default:
            break
        }
    }

    
    public func createContact(with phone: String?) -> CNContact {
        let contact = CNMutableContact()
        if let phone = phone {
            contact.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberMobile, value: CNPhoneNumber(stringValue: phone))]
        }
        return contact
    }
    

    class func getContacts(filter: ContactsFilter = .none) -> [CNContact] {
            let contactStore = CNContactStore()
            let keysToFetch = [
                CNContactPhoneNumbersKey as CNKeyDescriptor,
                CNContactIdentifierKey as CNKeyDescriptor,
                CNContactImageDataKey as CNKeyDescriptor,
                CNContactThumbnailImageDataKey as CNKeyDescriptor,
                CNContactImageDataAvailableKey as CNKeyDescriptor,
                CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                CNContactPhoneNumbersKey as CNKeyDescriptor,
                CNContactViewController.descriptorForRequiredKeys() as CNKeyDescriptor,
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor] as [Any]
            
            var allContainers: [CNContainer] = []
            do {
                allContainers = try contactStore.containers(matching: nil)
            } catch {
                print("Error fetching containers")
            }
            var results: [CNContact] = []
            
            for container in allContainers {
                let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
                
                do {
                    let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                    results.append(contentsOf: containerResults)
                } catch {
                    print("Error fetching containers")
                }
            }
            return results
    }

    public enum ContactsFilter {
        case none
        case mail
        case message
    }


    public func contactBy(id: String) -> Contact? {
        contacts.first(where: { $0.id == id })
    }
    
    public func contacts(filterNumber: String) -> [Contact] {
        return contacts.filter { contact in
            contact.phones.contains { $0.phone.contains(filterNumber) }
        }
    }
    
    public func contactBy(phone: String) -> Contact? {
        let phone = phone.replacingOccurrences(of: "+", with: "")
        return contacts.first { contact in
            contact.phones.contains { $0.phone == phone }
        }
    }
    
    public func cnContact(by id: String) -> CNContact? {
        return cnContacts.first(where:  {$0.identifier == id})
    }

    public func loadContacts(filter: ContactsFilter, completion: (() -> Void)? = nil) {
        requestAccess { accessGranted in
            var allContacts = [Contact]()
            let cnContacts = ContactsManager.getContacts(filter: filter)
            
            for contact in cnContacts {
                allContacts.append(Contact(cnContact: contact)!)
            }
            
            self.cnContacts = cnContacts
            self.contacts = allContacts.filter({!$0.phones.isEmpty && !$0.firstName.isEmpty && $0.firstName != ""})
            completion?()
        }
    }
}

enum ContactStoreError: Error {
    case noAccess
}
