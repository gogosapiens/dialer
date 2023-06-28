

import Foundation
import UIKit
import Contacts

public struct Contact {
    public struct Phone {
        public let phone: String
        public let label: String
        
        public init(phone: String, label: String?) {
            self.phone = phone
            self.label = label ?? "phone"
        }
    }
    
    public let id: String
    public let phones: [Phone]
    public let fullName: String?
    public let firstName: String
    public let lastName: String
    public let thumbnail: UIImage?
    public let image: UIImage?
    public let initials: String
    
    public func nameLabel(with phoneNumber: String) -> String {
        var nameLabel = fullName ?? ""
        if let phone = phones.first(where: { $0.phone == phoneNumber }) {
            if nameLabel.count > 0 {
                nameLabel.append(", ")
            }
            nameLabel.append(phone.label)
        }
        return nameLabel
    }
}

extension Contact {
    public init?(cnContact: CNContact) {
        let formatter = CNContactFormatter()
        formatter.style = .fullName
        let fullName = formatter.string(from: cnContact)
        let first = cnContact.givenName
        let second = cnContact.familyName
        
        var phones = [Phone]()
        let id = cnContact.identifier
        var thumbnail: UIImage?
        var image: UIImage?
        if cnContact.imageDataAvailable {
            if let cnThumbnail = cnContact.thumbnailImageData {
                thumbnail = UIImage(data: cnThumbnail)
            }
            if let cnImage = cnContact.imageData {
                image = UIImage(data: cnImage)
            }
        }
        cnContact.phoneNumbers.forEach({ (phone: CNLabeledValue<CNPhoneNumber>) in
            let phoneNumber: CNPhoneNumber = phone.value
            var label: String? = nil
            if let phoneLabel = phone.label {
                label = CNLabeledValue<CNPhoneNumber>.localizedString(forLabel: phoneLabel)
            }
            if let phoneValue = phoneNumber.value(forKey: "digits") as? String {
                phones.append(Phone(phone: phoneValue, label: label))
            }
        })
        var initials: [String] = []
        if let firstLetter = first.first {
            initials.append(String(firstLetter))
        }
        if let firstLetter = second.first {
            initials.append(String(firstLetter))
        }
        if initials.count > 2 {
            switch CNContactFormatter.nameOrder(for: cnContact) {
            case .familyNameFirst:
                initials.reverse()
            default:
                break
            }
        }
        
        if fullName == nil && phones.count == 0 {
            return nil
        }
        
        self.init(id: id,
                  phones: phones,
                  fullName: fullName,
                  firstName: first,
                  lastName: second,
                  thumbnail: thumbnail,
                  image: image,
                  initials: initials.reduce("", { $0 + $1 }))
    }
}
