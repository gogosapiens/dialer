

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
