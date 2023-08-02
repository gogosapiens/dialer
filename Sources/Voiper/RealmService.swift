//
//  RealmService.swift
//  
//
//  Created by Andrei (Work) on 02/08/2023.
//

import Foundation
import RealmSwift

public class RealmService {
    public static func configure() {
        let config = Realm.Configuration(
            schemaVersion: 3,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 3 {
                    migration.enumerateObjects(ofType: SubscriptionInfoRealm.className()) { oldObject, newObject in
                        newObject!["subscriptionGroup"] = -1
                    }
                    migration.enumerateObjects(ofType: AccountRealm.className()) { oldObject, newObject in
                        newObject!["notificationsCheckin"] = true
                    }
                }
            }
        )
        Realm.Configuration.defaultConfiguration = config
    }
}
