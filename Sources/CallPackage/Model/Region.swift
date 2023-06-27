//
//  File.swift
//  
//
//  Created by Maxim Okolokulak on 12.06.23.
//

import Foundation

public struct RegionsResponse: Decodable {
    public let regions: [Region]
}

extension RegionsResponse: CustomStringConvertible {
    public var description: String {
        return jsonFormatDescription((name: "regions", value: regions.description))
    }
}

public struct Region: Hashable, Equatable, Decodable, Comparable {
    public let title: String?
    public let region: String
    public let code: Int
    
    public var name: String { title ?? region }

    public static func == (lhs: Region, rhs: Region) -> Bool {
        lhs.code == rhs.code && lhs.region == rhs.region
    }
    
    public static func < (lhs: Region, rhs: Region) -> Bool {
        if let lhsTitle = lhs.title, let rhsTitle = rhs.title {
            if lhsTitle == rhsTitle {
                return lhs.code < rhs.code
            } else {
                return lhsTitle < rhsTitle
            }
        } else {
            if lhs.region == rhs.region {
                return lhs.code < rhs.code
            } else {
                return lhs.region < rhs.region
            }
        }
    }
}

extension Region: CustomStringConvertible {
    public var description: String {
        return jsonFormatDescription((name: "title", value: title ?? ""),
                                     (name: "region", value: region),
                                     (name: "code", value: String(code)))
    }
}
