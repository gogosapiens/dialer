//
//  File.swift
//  
//
//  Created by Maxim Okolokulak on 12.06.23.
//

import Foundation

public struct NumberType: Decodable {
    public enum TypeId: String, Decodable {
        
        case local = "Local"
        case mobile = "Mobile"
        case tollFree = "TollFree"
        
        var localized: String {
            return rawValue.localized
        }
        
        var iconName: String {
            return "ic_\(rawValue.lowercased())_number_type"
        }
    }
    
    public enum AddressRequiredType: Int, Decodable {
        case none = 0, any = 1, local = 2, foreign = 3
    }
    
    public let type: TypeId
    public let dual: Bool
    public let addressRequired: AddressRequiredType
    public let capabilities: [Capability]
    public let priceGroup: String
    
    enum CodingKeys: String, CodingKey {
        case type
        case dual
        case capabilities
        case addressRequired = "address_required"
        case priceGroup = "price_group"
    }
}

extension NumberType: CustomStringConvertible {
    public var description: String {
        return jsonFormatDescription((name: "type", value: type.rawValue),
                                     (name: "dual", value: String(dual)),
                                     (name: "addressRequired", value: String(addressRequired.rawValue)),
                                     (name: "capabilities", value: capabilities.description),
                                     (name: "priceGroup", value: priceGroup))
    }
}
