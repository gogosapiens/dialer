//
//  File 2.swift
//  
//
//  Created by Maxim Okolokulak on 26.06.23.
//

import ContactsUI
import Foundation

public protocol ContactCreatorDelegate: AnyObject {
    func display(_ controller: UIViewController)
    func showError(_ error: Error)
    func show(_ contact: Contact)
    func hide(_ animated: Bool)
}

public class ContactCreator: NSObject {
    public weak var delegate: ContactCreatorDelegate?
    public func createContact(with phone: String? = nil) {
        if Settings.hasAccessContact {
            let contact = ContactsManager.shared.createContact(with: phone)
            let controller = CNContactViewController(forNewContact: contact)
            let navVC = UINavigationController.customNavigaiton(with: controller)
            controller.delegate = self
            delegate?.display(navVC)
        } else {
            delegate?.showError(ContactStoreError.noAccess)
        }
    }
}

extension ContactCreator: CNContactViewControllerDelegate {
    public func contactViewController(_ viewController: CNContactViewController, shouldPerformDefaultActionFor property: CNContactProperty) -> Bool {
        false
    }

    public func contactViewController(_ viewController: CNContactViewController, didCompleteWith cnContact: CNContact?) {
        if let cnContact = cnContact,
           let contact = Contact(cnContact: cnContact) {
            delegate?.hide(false)
            delegate?.show(contact)
        } else {
            delegate?.hide(true)
        }
    }
}

extension ContactCreatorDelegate where Self: UIViewController {
    public func showError(_ error: Error) {
        print("We need access to contacts for create new contact".localized)
    }

    public func display(_ controller: UIViewController) {
        present(controller, animated: true, completion: nil)
    }

    public func hide(_ animated: Bool) {
        dismiss(animated: animated, completion: nil)
    }
}
