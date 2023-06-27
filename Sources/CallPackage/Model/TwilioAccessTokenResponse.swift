//
//  File.swift
//  
//
//  Created by Maxim Okolokulak on 21.06.23.
//

import Foundation

public struct TwilioAccessTokenResponse: Decodable {
    let token: String
    let identity: String
}

extension TwilioAccessTokenResponse: CustomStringConvertible {
    public var description: String {
        return jsonFormatDescription((name: "token", value: token),
                                     (name: "identity", value: identity))
    }
}
