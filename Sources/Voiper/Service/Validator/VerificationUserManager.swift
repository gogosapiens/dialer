import Foundation

public class VerificationUserManager {
    
    static var shared = VerificationUserManager()
    var accountManager: AccountManager?
    let nw = NW.shared
    
    private init() {}
    
    public enum Action {
        case call
        case sms
        case mms
    }

    public func canAction(phoneNumber: String, action: Action, completion: @escaping (Result<Void, Error>) -> Void) {
        
        if !isValidPhoneNumber(phoneNumber) {
            completion(.failure(LocalError.noInternationalFormat))
            return
        }

        guard let activeNumber = accountManager?.phoneManager.activePhoneModel?.phoneNumber else {
            //TODO: Add error handling limited to cases
            return completion(.failure(LocalError.noActiveNumber))
        }
        let balance = self.accountManager?.account?.balance ?? 0
        switch action {
        case .call:
            nw.getVoicePricing(from: activeNumber.id, to: phoneNumber) { result in
                switch result {
                case .success(let result):
                    //TODO: This needs to be corrected later.
                    if result.canCall && result.minutes < balance {
                        completion(.success(()))
                    } else {
                        completion(.failure(LocalError.notEnoughFundsCall))
                    }
                case .failure(let failure):
                     completion(.failure(failure))
                }
            }
        case .sms:
            nw.getMessagePricing(with: activeNumber.id, to: phoneNumber) { result in
                switch result {
                case .success(let result):
                    //TODO: This needs to be corrected later.
                    if result.canSms && result.smsPricing.outbound?.first ?? 1 < balance {
                        completion(.success(()))
                    } else {
                        completion(.failure(LocalError.notEnoughFundsSMS))
                    }
                case .failure(let failure):
                    completion(.failure(failure))
                }
            }
        case .mms:
            nw.getMessagePricing(with: activeNumber.id, to: phoneNumber) { result in
                switch result {
                case .success(let result):
                    //TODO: This needs to be corrected later.
                    if result.canMms && result.mmsPricing.outbound?.first ?? 1 < balance {
                        completion(.success(()))
                    } else {
                        completion(.failure(LocalError.notEnoughFundsMMS))
                    }
                case .failure(let failure):
                    completion(.failure(failure))
                }
            }
        }
    }
    
    private func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        let regex = try? NSRegularExpression(pattern: "^\\+[1-9][0-9]{1,14}$", options: .caseInsensitive)
        let range = NSRange(location: 0, length: phoneNumber.count)
        return regex?.firstMatch(in: phoneNumber, options: [], range: range) != nil
    }
}
