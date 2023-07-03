

import Foundation

class VerificationUserManager {
    
    static var shared = VerificationUserManager()
    let accountManager = AccountManager(service: Service.shared)
    let nw = NW.shared
    
    private init() {}
    
    public enum Action {
        case call
        case sms
        case mms
    }

    func canAction(phoneNumber: String, action: Action, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let activeNumber = accountManager.phoneManager.activePhoneModel?.phoneNumber else {
            //TODO: Add error handling limited to cases
            return completion(.failure(NSError(domain: "no Active phone", code: 123)))
        }
        let balance = self.accountManager.account?.balance ?? 0
        switch action {
        case .call:
            nw.getVoicePricing(from: activeNumber.id, to: phoneNumber) { result in
                switch result {
                case .success(let result):
                    //TODO: This needs to be corrected later.
                    if result.canCall && result.minutes < balance {
                        completion(.success(()))
                    } else {
                        completion(.failure(NSError(domain: "", code: 124)))
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
                    if result.canSms && result.smsPricing.outbound?.first ?? 1 < balance {
                        completion(.success(()))
                    } else {
                        completion(.failure(NSError(domain: "", code: 124)))
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
                    if result.canMms && result.mmsPricing.outbound?.first ?? 1 < balance {
                        completion(.success(()))
                    } else {
                        completion(.failure(NSError(domain: "", code: 124)))
                    }
                case .failure(let failure):
                    completion(.failure(failure))
                }
            }
        }
    }
}
