
import Foundation

public class PhoneModel {
    public var phoneNumber: PhoneNumber
    private let service: Service
    public var callManager: CallManager!
    public var activityModel: ActivityModel!
    
    init(phoneNumber: PhoneNumber, service: Service) {
        self.service = service
        self.phoneNumber = phoneNumber
        callManager = CallManager(phoneModel: self, service: service)
        activityModel = ActivityModel(phoneModel: self, service: service)
    }
}
