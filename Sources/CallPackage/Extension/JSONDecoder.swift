

import Foundation

extension JSONDecoder {
    static var serviceDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom({ (coder: Decoder) -> Date in
            let container = try coder.singleValueContainer()
            let stringDate = try container.decode(String.self)
            if let date = DateFormatter.serverDateTime.date(from: stringDate) {
                return date
            } else if let date = DateFormatter.serverDateTimeWithZeroHourOffset.date(from: stringDate) {
                return date
            } else if let date = DateFormatter.serverDateTimeWithoutSubseconds.date(from: stringDate) {
                return date
            } else if let date = DateFormatter.serverDateTimeWithoutSubsecondsWithZeroHourOffset.date(from: stringDate) {
                return date
            }
            throw ServiceError.undecodable
        })
        return decoder
    }
}



