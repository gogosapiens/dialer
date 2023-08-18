

import Foundation
import RealmSwift

public class PhoneManager: Observable1 {
    public enum Event {
        case changedActiveModel, update
    }
    
    public typealias ObjectEvent = Event
    public var observerTokenGenerator: Int = 0
    public var observers: [Int : (PhoneManager.Event) -> Void] = [:]
    
    private let service: Service
    public var phoneModels: [PhoneModel] = []
    private let realmPhones: Results<PhoneNumberRealm>
    private var token: NotificationToken?
    
    init(service: Service) {
        self.service = service
        let realm = try! Realm()
        self.realmPhones = realm.objects(PhoneNumberRealm.self)
        addObserver()
    }
    
    private func addObserver() {
        if self.token == nil {
            self.token = self.realmPhones.observe { changes in
                switch changes {
                case .initial,
                     .update:
                    let numbers: [PhoneNumber] = self.realmPhones.map { PhoneNumber(realmObject: $0) }
                    self.update(with: numbers)
                case .error:
                    break
                }
            }
        }
    }
    
    deinit {
        token?.invalidate()
    }
    
    func update(with phones: [PhoneNumber]) {
        var models: [PhoneModel] = []
        phones.forEach { phoneNumber in
            if let oldModel = self.phoneModels.first(where: { model in model.phoneNumber.id == phoneNumber.id }) {
                oldModel.phoneNumber = phoneNumber
                models.append(oldModel)
            } else {
                models.append(PhoneModel(phoneNumber: phoneNumber, service: self.service))
            }
        }
        
        notifyObservers(.update)
        phoneModels = models
        
        if let activeID = Storage.defaultNumberId, activeID != 0  {
            phoneModels.forEach { phoneNumber in
                if activeID ==  phoneNumber.phoneNumber.id {
                    self.activePhoneModel = phoneNumber
                }
            }
        }
        if (self.activePhoneModel == nil)  {
            self.activePhoneModel = phoneModels.filter({ $0.phoneNumber.isActive == true }).max(by: { $0.phoneNumber.inserted < $1.phoneNumber.inserted })
        }
        
        if (self.activePhoneModel == nil)  {
            self.activePhoneModel = phoneModels.max(by: { $0.phoneNumber.inserted < $1.phoneNumber.inserted })
        }
    }
    
    func delete(numberId: Int) {
        guard
            let realm = try? Realm(),
            let objectToDelete = realm.object(ofType: PhoneNumberRealm.self, forPrimaryKey: numberId)
        else { return }
        
        try? realm.write {
            realm.delete(objectToDelete)
            phoneModels.removeAll(where: { $0.phoneNumber.id == numberId })
        }
    }
    
    public func setActiveNumber(phoneNumber: PhoneModel) {
        self.activePhoneModel = phoneNumber
        EventManager.shared.sendChangeNumberEvents()
    }
    
    
   public var activePhoneModel: PhoneModel? {
        didSet {
            Storage.defaultNumberId = self.activePhoneModel?.phoneNumber.id
            if oldValue?.phoneNumber.id != activePhoneModel?.phoneNumber.id {
                notifyObservers(.changedActiveModel)
            }
        }
    }
}
