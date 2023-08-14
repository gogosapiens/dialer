import Foundation

public enum LocalError: Error {
    case noInternationalFormat
    case notEnoughFundsCall
    case notEnoughFundsMMS
    case notEnoughFundsSMS
    case noActiveNumber
}
