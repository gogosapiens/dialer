

import Foundation

public struct RegionNumbersResponse: Decodable {
    public let numbers: [RegionNumber]
}

extension RegionNumbersResponse: CustomStringConvertible {
    public var description: String {
        return jsonFormatDescription((name: "numbers", value: numbers.description))
    }
}

public struct RegionNumber: Decodable {
    public let region: String?
    public let formattedNumber: String
    public let number: String
    public let country: String
    public let capabilities: [Capability]
    public let addressRequired: Int
    public let renewPrice: Int
    public let source: Source?
    public let note: String?
    
    public var isAddressRequired: Bool {
         return addressRequired > 0
    }
    
    public enum AddressRequiredType: Int {
        case none
        case any
        case local
        case foreign
    }
    
    public enum Source: String, Decodable {
        case pool
        case twilio
    }
    
    public enum CodingKeys: String, CodingKey {
        case region
        case formattedNumber =  "number_friendly"
        case number
        case country
        case capabilities
        case addressRequired =  "address_required"
        case renewPrice =       "renew_price_cr"
        case source
        case note
    }
}

extension RegionNumber: CustomStringConvertible {
    public var description: String {
        return jsonFormatDescription((name: "region", value: region ?? ""),
                                     (name: "number", value: number),
                                     (name: "formattedNumber", value: formattedNumber),
                                     (name: "country", value: country),
                                     (name: "capabilities", value: capabilities.description),
                                     (name: "addressRequired", value: String(addressRequired)),
                                     (name: "renewPrice", value: String(renewPrice)))
    }
}
