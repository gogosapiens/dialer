

import Foundation
import UIKit

public struct CountryResponse: Decodable {
    public let countries: [Country]
}

extension CountryResponse: CustomStringConvertible {
    public var description: String {
        return jsonFormatDescription((name: "countries", value: countries.description))
    }
}

public struct Country: Decodable {
    public let flagURL: String
    public let prefix: String
    public let hasRegions: Bool
    public let isPopular: Bool
    public let name: String
    public let iso: String
    public let types: [NumberType]
    
    public var capabilityLabels: String {
        return Array(Set(types.flatMap { $0.capabilities.compactMap { $0.label } })).sorted().joined(separator: ", ")
    }
    
    enum CodingKeys: String, CodingKey {
        case flagURL = "flag_url"
        case prefix
        case hasRegions = "has_regions"
        case isPopular = "popular"
        case name
        case iso
        case types
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.flagURL = try container.decode(String.self, forKey: .flagURL)
        self.prefix = try container.decodeIfPresent(String.self, forKey: .prefix) ?? ""
        self.hasRegions = try container.decode(Bool.self, forKey: .hasRegions)
        self.isPopular = try container.decode(Bool.self, forKey: .isPopular)
        self.name = try container.decode(String.self, forKey: .name)
        self.iso = try container.decode(String.self, forKey: .iso)
        self.types = try container.decode([NumberType].self, forKey: .types).filter { $0.type == .local }
    }
}

extension Country: CustomStringConvertible {
    public var description: String {
        return jsonFormatDescription((name: "flagURL", value: flagURL),
                                     (name: "prefix", value: prefix.description),
                                     (name: "hasRegions", value: hasRegions.description),
                                     (name: "isPopular", value: isPopular.description),
                                     (name: "name", value: name),
                                     (name: "iso", value: iso),
                                     (name: "types", value: types.description))
    }
}

public struct CountryCode: Decodable {
    public let iso: String
    public let prefix: String
    public let isHighPriority: Bool
    
    static var allCodes: [CountryCode] = {
        if let data = try? Data(contentsOf: Bundle.main.url(forResource: "country_codes", withExtension: ".json")!) {
            return (try? JSONDecoder().decode([CountryCode].self, from: data)) ?? []
        }
        return []
    }()
}

extension Country {
    public static func getFlag(ISO: String) -> UIImage? {
        return UIImage(named: ISO.uppercased())
    }
    
    public static func getISO(prefix: String) -> String? {
        return (CountryCode.allCodes.first(where: { $0.prefix == prefix && $0.isHighPriority }) ??
                
                CountryCode.allCodes.first(where: {
                    $0.prefix.hasPrefixCheck(prefix: prefix, isCaseSensitive: false)
                }))?.iso
    }
}
