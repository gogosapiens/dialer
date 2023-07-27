
import Foundation
import PromiseKit
import RealmSwift

public class AccountManager: Observable1, OnNotification {
    
    public var handler: NotificationHandler = NotificationHandler()
    public var observerTokenGenerator: Int = 0
    public var observers: [Int : (AccountManager.Event) -> Void] = [:]
    public var initialEvent: AccountManager.Event? = .none
    public var wasFirstLoad: Bool {
        set {
            UserDefaults.standard.set(true, forKey: "firstLoad")
        }
        get {
            return UserDefaults.standard.bool(forKey: "firstLoad")
        }
    }
    
    public enum Event {
        case none
        case local
        case loaded
        case removed
    }
    
    public static let callFlow = CallFlow()
    public var phoneManager: PhoneManager
    let subscriptionModel: SubscriptionModel
    public let voipNotification: VoipNotification
    private var callIntentHandle: String?
    public let service: Service
    
    public var account: Account? {
        guard let result = localAccount,
              result.count > 0,
              let localAccount = result.first else { return nil }
        return Account(realmObject: localAccount)
    }
    private var localAccount: Results<AccountRealm>?
    
    init(service: Service) {
        self.service = service
        phoneManager = PhoneManager(service: service)
        subscriptionModel = SubscriptionModel()
        voipNotification = VoipNotification()
        load()
        
//        handler.registerNotificationName(AppDelegate.startCallIntentNotification) { [unowned self] notification in
//            guard let handle = notification.userInfo?[AppDelegate.intentHandleKey] as? String else {
//                return
//            }
//            self.callIntentHandle = handle
//            if self.initialEvent == .loaded {
//                self.handleCallIntent()
//            }
//        }
//        handler.registerNotificationName(UIApplication.didBecomeActiveNotification) { [unowned self] _ in
//            self.load()
//        }
//
        var lastBalance = account?.balance ?? 0
        handler.registerNotificationName(Account.updateNotification) { [unowned self] _ in
            let currentBalance = self.account?.balance ?? 0
            if currentBalance < lastBalance {
//                trackSpentCredits(lastBalance - currentBalance)
                lastBalance = currentBalance
            }
        }
    }
    
    public func create() -> Promise<Void> {
        let promise: Promise<CreateAccountResponse> = service.execute(.createAccount)
        return promise.then { response -> Promise<Void> in
            Settings.userToken = response.token
            return self.loadAccount()
        }
    }
    
    public func restore(with receipt: String) -> Promise<Void> {
        let promise: Promise<CreateAccountResponse> = service.execute(.restoreAccount(Bundle.main.bundleIdentifier!, receipt))
        return promise.then { response -> Promise<Void> in
            Settings.userToken = response.token
            return self.load()
        }
    }
    
    public func remove() -> Promise<Void> {
        let promise: Promise<EmptyResponse> = service.execute(.deleteAccount)
        return promise.done(on: DispatchQueue.global()) { _ in
            Settings.userToken = nil
            self.notifyObservers(.removed)
            let realm = try! Realm()
            try! realm.write {
                realm.deleteAll()
            }
            DispatchQueue.main.async {
                self.phoneManager = PhoneManager(service: self.service)
            }
        }
    }
    
    @discardableResult
    func load() -> Promise<Void> {
        return loadLocal()
            .then({ _ -> Promise<Void> in
                return self.loadAccount()
            })
            .then { _ -> Promise<Void> in
                return self.loadPhones()
            }
            .then { _ -> Promise<Void> in
                return self.loadSubscriptions()
            }
            .done { _ in
                self.wasFirstLoad = true
                self.updateCallFlow()
                self.initialEvent = .loaded
                self.notifyObservers(.loaded)
                
                if self.callIntentHandle != nil {
                    self.handleCallIntent()
                }
            }
            .recover { error in
                if case ServiceError.notAuthorized = error {
                    Settings.userToken = nil
                    self.initialEvent = .loaded
                    self.notifyObservers(.loaded)
                } else {
                    throw(error)
                }
        }
    }
    
    private func loadLocal() -> Promise<Void> {
        return Promise.init { seal in
            guard let token = Settings.userToken else {
            
                let realm = try! Realm()
                try! realm.writeAsync {
                    realm.deleteAll()
                }
                
                seal.reject(ServiceError.notAuthorized)
                
                return
            }
            
            let realm = try! Realm()
            self.localAccount = realm.objects(AccountRealm.self)
                .filter(NSPredicate(format: "token == %@", token))
            self.initialEvent = .local
            self.notifyObservers(.local)
            seal.fulfill(())
        }
    }
    
    private func deleteAll(){
        
    }
 
    func loadAccount() -> Promise<Void> {
        let loadAccount: Promise<AccountResponse> = service.execute(.getAccount)
        return loadAccount.then(on: DispatchQueue.global()) { response -> Promise<Void> in
            let account = response.account
            let realm = try! Realm()
            let objectsToDelete = realm.objects(AccountRealm.self).filter { $0.id != account.id }
            try realm.write {
                realm.delete(objectsToDelete)
                let accountRealm = AccountRealm.create(with: account, token: Settings.userToken!)
                realm.add(accountRealm, update: .all)
            }
            return Promise.value(())
        }.done {
            let realm = try! Realm()
            self.localAccount = realm.objects(AccountRealm.self)
                .filter(NSPredicate(format: "token == %@", Settings.userToken!))
            NotificationCenter.default.post(name: Account.updateNotification, object: nil)
        }
    }
    
    func loadPhones() -> Promise<Void> {
        let promise: Promise<PhoneNumbersResponse> = service.execute(.getNumbers)
        return promise.done(on: DispatchQueue.global()) { response in
            let numbers = response.numbers
            let realm = try! Realm()
            try realm.write {
                let ids = numbers.map { $0.id }
                let objectsToDelete = realm.objects(PhoneNumberRealm.self).filter("NOT id IN %@", ids)
                realm.delete(objectsToDelete)
                numbers.forEach {
                    let number = PhoneNumberRealm.create(with: $0)
                    realm.add(number, update: .all)
                }
            }
        }
    }
    
    private func loadSubscriptions() -> Promise<Void> {
        let promise: Promise<SubscriptionsResponse> = service.execute(.getSubscriptions)

        return promise.done(on: DispatchQueue.global()) { response in
            let subscriptions = response.subscriptions
            let realm = try! Realm()
            try realm.write {
                let ids = subscriptions.map { $0.id }
                let objectsToDelete = realm.objects(SubscriptionInfoRealm.self).filter("NOT id IN %@", ids)
                realm.delete(objectsToDelete)
                subscriptions.forEach {
                    let subscription = SubscriptionInfoRealm.create(with: $0)
                    realm.add(subscription, update: .all)
                }
            }
        }
    }
    
    func updateCallFlow() {
        if let activePhone = self.phoneManager.activePhoneModel
//            ,
//            (Settings.isRestoringPeriod || activePhone.phoneNumber.isActive)
        {
                AccountManager.callFlow.callManager = activePhone.callManager
                activePhone.callManager.voipNotification = self.voipNotification
                self.voipNotification.notificationHandler = AccountManager.callFlow
        } else {
            
            if let active = self.phoneManager.phoneModels.first(where: { phoneModel in
                return phoneModel.phoneNumber.status == .active
            }) {
                AccountManager.callFlow.callManager = active.callManager
                active.callManager.voipNotification = self.voipNotification
                self.voipNotification.notificationHandler = AccountManager.callFlow
            }
        }
    }

    public func addProduct(_ product: TheProduct, with result: PurchaseManager.PurchaseResult, and number: RegionNumber) -> Promise<Void> {
        firstly {
            if Settings.isUserAuthorized {
                return Promise.value(())
            } else {
                return create()
            }
        }.then { [service] _ -> Promise<AddSubscriptionResponse> in
            service.execute(
                .addSubscription(Bundle.main.bundleIdentifier!,
                                 result.reciept,
                                 result.price,
                                 result.currency)
            ).then { response -> Promise<AddSubscriptionResponse> in
                self.loadSubscriptions()
                    .then { _ -> Promise<AddSubscriptionResponse> in
                        self.updateCallFlow()
                        return Promise.value(response)
                    }
            }
        }.then { response -> Promise<Void> in
            let backendID: Int
            if product.type.isFirstNumber, let firstSubscriptionId = response.firstSubscriptionId {
                backendID = firstSubscriptionId
            } else if product.type.isSecondNumber, let secondSubscriptionId = response.secondSubscriptionId {
                backendID = secondSubscriptionId
            } else {
                return Promise(error: ServiceError.purchaseError("Wrong subscription, please try again later!"))
            }
            return self.addLocalNumber(number, subscriptionId: backendID)
        }
    }
    
    func addLocalNumber(_ number: RegionNumber, subscriptionId: Int) -> Promise<Void> {
        let promise: Promise<EmptyResponse> = service.execute(.addLocalNumber(number: number, subscriptionId: subscriptionId))
        return promise.then { _ -> Promise<Void> in
                return self.loadPhones()
            }.then { _ -> Promise<Void> in
                return self.loadAccount()
            }.then { _ -> Promise<Void> in
                return self.loadSubscriptions()
            }.done {
                self.updateCallFlow()
        }
    }

    func add(number: RegionNumber, type: NumberType, addressId: Int?, subscriptionId: Int?) -> Promise<Void> {
        let promise: Promise<EmptyResponse> = service.execute(.addNumber(number: number, type: type, addressId: addressId, subscriptionId: subscriptionId))
        return promise.then { _ -> Promise<Void> in
                return self.loadPhones()
            }.then { _ -> Promise<Void> in
                return self.loadAccount()
            }.then { _ -> Promise<Void> in
                return self.loadSubscriptions()
            }.done {
                self.updateCallFlow()
        }
    }
    
//    func addInAppPurchase(with result: Purchases.PurchaseResult) -> Promise<Void> {
//        let addInAppPurchase: Promise<EmptyResponse> = service.execute(.addInAppPurchase(bundle: Bundle.main.bundleIdentifier!, receipt: result.reciept, price: result.price, currency: result.currency))
//        return addInAppPurchase.then { _ -> Promise<Void> in
//            return self.loadAccount()
//        }.done {
//            self.updateCallFlow()
//        }
//    }
    
    func updateLocale(_ locale: String) {
        account?.locale = locale
        let _: Promise<EmptyResponse> = service.execute(.updateLocale(locale))
    }
    
    func updateMute(_ date: Date) -> Promise<EmptyResponse> {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let str = dateFormatter.string(from: date)
        let promise: Promise<EmptyResponse> = service.execute(.updateMute(str))
        return promise
    }
    
    func updateBalance(_ balance: Int) throws {
        guard let account = self.account else { return }
        let realm = try Realm()
        account.balance = balance
        try realm.write {
            let accountRealm = AccountRealm.create(with: account, token: Settings.userToken!)
            realm.add(accountRealm, update: .all)
            NotificationCenter.default.post(name: Account.updateNotification, object: nil)
        }
    }
    
    
    func updateRing(_ sound: String?) -> Promise<EmptyResponse> {
        let promise: Promise<EmptyResponse> = service.execute(.updateRing(sound))
        return promise
    }
    
    func updateNotif(_ sound: String?) -> Promise<EmptyResponse> {
        let promise: Promise<EmptyResponse> = service.execute(.updateNotif(sound))
        return promise
    }
}

extension AccountManager {
    private func handleCallIntent() {
        guard let handle = callIntentHandle else {
            return
        }
        
        if account?.paused == false,
            phoneManager.activePhoneModel?.phoneNumber.isActive == true {
            AccountManager.callFlow.handleStartCallIntent(handle)
        }
        callIntentHandle = nil
    }
}
