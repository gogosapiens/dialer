//
//  File.swift
//  
//
//  Created by Maxim Okolokulak on 20.06.23.
//

import Foundation

public struct AccountResponse: Decodable {
    let account: Account
    
    enum CodingKeys: String, CodingKey {
        case account
    }
}

extension AccountResponse: CustomStringConvertible {
    public var description: String {
        return jsonFormatDescription((name: "account", value: account.description))
    }
}
