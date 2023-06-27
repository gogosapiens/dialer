//
//  File.swift
//  
//
//  Created by Maxim Okolokulak on 22.06.23.
//

import Foundation
import RealmSwift

public class SubscriptionModel {
    
    var subscriptions: [SubscriptionInfo] = []
    private let realmSubscriptions: Results<SubscriptionInfoRealm>
    private var token: NotificationToken?
    
    init() {
        let realm = try! Realm()
        self.realmSubscriptions = realm.objects(SubscriptionInfoRealm.self)
        addObserver()
    }
    
    private func addObserver() {
        if self.token == nil {
            self.token = self.realmSubscriptions.observe { changes in
                switch changes {
                case .initial,
                     .update:
                    self.subscriptions = self.realmSubscriptions.map { SubscriptionInfo(realmObject: $0) }
                case .error:
                    break
                }
            }
        }
    }
    
    deinit {
        token?.invalidate()
    }
    
    var activeSubscription: [SubscriptionInfo]? {
        return subscriptions.filter({
            $0.expiredAt == nil
        })
    }
    
}
