//
//  File.swift
//  
//
//  Created by Maxim Okolokulak on 20.06.23.
//


import Foundation

public struct PhoneNumbersResponse: Decodable {
    let numbers: [PhoneNumber]
}

extension PhoneNumbersResponse: CustomStringConvertible {
    public var description: String {
        return jsonFormatDescription((name: "numbers", value: numbers.description))
    }
}

extension PhoneNumber: CustomStringConvertible {
    public var description: String {
        return jsonFormatDescription((name: "id", value: String(id)),
                                     (name: "region", value: region),
                                     (name: "formattedNumber", value: formattedNumber),
                                     (name: "number", value: number),
                                     (name: "inserted", value: inserted.description),
                                     (name: "expired", value: expired?.description ?? ""),
                                     (name: "country", value: country),
                                     (name: "capabilities", value: capabilities.description),
                                     (name: "addressRequired", value: String(addressRequired)),
                                     (name: "label", value: label),
                                     (name: "renewPrice", value: String(renewPrice)),
                                     (name: "billedUntil", value: billedUntil.description),
                                     (name: "status", status?.rawValue ?? "" ) )
    }
}
