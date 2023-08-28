import Foundation
import PromiseKit
import AVFoundation
import TwilioVoice

public class CallManager: NSObject {
    
    private var observerToken = 0
    weak var voipNotification: VoipNotification! {
        didSet {
            if let oldModel = oldValue {
                oldModel.removeObserver(self.observerToken)
            }
            if let model = voipNotification {
                self.observerToken = model.observe { event in
                    switch event {
                    case .register(let token):
                        self.registerForPush(with: token)
                    case .unregister(let token):
                        self.unregisterForPush(with: token)
                    }
                }
            }
        }
    }
    
    unowned var phoneModel: PhoneModel
    let phoneNumber: PhoneNumber
    private let service: Service
    private let accountManager: AccountManager?
    
    init(phoneModel: PhoneModel, service: Service, accountManager: AccountManager? = nil) {
        self.service = service
        self.phoneModel = phoneModel
        self.phoneNumber = phoneModel.phoneNumber
        self.accountManager = accountManager
        
        super.init()
    }

    static func getAccess() -> Guarantee<Bool> {
        return Guarantee { seal in
            AVAudioSession.sharedInstance().requestRecordPermission { success in
                seal(success)
            }
        }
    }
    
    func fetchAccessToken() -> Promise<String> {
        let promise: Promise<TwilioAccessTokenResponse> = service.execute(.getCallAccessToken(phoneNumber.id))
        return promise.map { response -> String in
            return response.token
        }
    }
    
    private func registerForPush(with deviceToken: Data) {
        _ = fetchAccessToken()
            .then { token -> Promise<Void> in
                return Promise { seal in
                    TwilioVoiceSDK.register(accessToken: token, deviceToken: deviceToken, completion: { error in
                        if let error = error {
                            seal.reject(error)
                        } else {
                            print("Registred for ring with \(token) for device \(deviceToken)")
                            seal.fulfill(())
                        }
                    })
                }
            }
    }
    
    private func unregisterForPush(with deviceToken: Data) {
        _ = fetchAccessToken()
            .then { token -> Promise<Void> in
                return Promise { seal in
                    
                    
                    TwilioVoiceSDK.unregister(accessToken: token, deviceToken: deviceToken, completion: { error in
                        if let error = error {
                            seal.reject(error)
                        } else {
                            seal.fulfill(())
                        }
                    })
                }
            }
    }
    
    
    public func call(for number: String, completion: @escaping (Swift.Result<Void, Error>) -> Void) {
        self.accountManager?.updateCallFlow()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            AccountManager.callFlow.start(SPCall(uuid: UUID(), handle: number, isOutgoing: true)).done { _ in
            }.catch { error in
                completion(.failure(error))
            }
        })
    }
}


