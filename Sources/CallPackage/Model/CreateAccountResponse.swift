//
//  File.swift
//  
//
//  Created by Maxim Okolokulak on 20.06.23.
//

import Foundation


public struct CreateAccountResponse: Decodable {
    let token: String
    let id: Int
}

extension CreateAccountResponse: CustomStringConvertible {
    public var description: String {
        return jsonFormatDescription((name: "id", value: String(id)),
                                     (name: "token", value: token))
    }
}
