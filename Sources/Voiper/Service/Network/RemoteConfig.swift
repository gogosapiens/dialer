//
//  RemoteConfig.swift
//
//
//  Created by Andrei (Work) on 17/01/2024.
//

import Foundation
import Firebase
import FirebaseRemoteConfig

public protocol RemoteConfigDelegate: AnyObject {
    func configHasBeenUpdated()
}

public class RemoteConfig {
    public static let shared = RemoteConfig()

    static var hasGoogleServicePlist: Bool {
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           FileManager.default.fileExists(atPath: path) {
            return true
        } else {
            return false
        }
    }
    
    public weak var delegate: RemoteConfigDelegate? {
        didSet {
            delegate?.configHasBeenUpdated()
        }
    }

    init() {

    }

    func fetchConfig() {
        guard RemoteConfig.hasGoogleServicePlist else { return }
        FirebaseRemoteConfig.RemoteConfig.remoteConfig().fetch(withExpirationDuration: 10) { [delegate] (status, error) in
            FirebaseRemoteConfig.RemoteConfig.remoteConfig().activate(completion: nil)
            delegate?.configHasBeenUpdated()
        }
    }

    private func getNumberValue(forKey key: String) -> Int? {
        guard RemoteConfig.hasGoogleServicePlist else { return nil }
        return FirebaseRemoteConfig.RemoteConfig.remoteConfig().configValue(forKey: key).numberValue.intValue
    }

    private func getStringValue(forKey key: String) -> String? {
        guard RemoteConfig.hasGoogleServicePlist else { return nil }
        return FirebaseRemoteConfig.RemoteConfig.remoteConfig().configValue(forKey: key).stringValue
    }

    private func getBoolValue(forKey key: String) -> Bool? {
        guard RemoteConfig.hasGoogleServicePlist else { return nil }
        return FirebaseRemoteConfig.RemoteConfig.remoteConfig().configValue(forKey: key).boolValue
    }

    var shortCallRestriction: Bool {
        #if DEBUG
        true
        #else
        return getBoolValue(forKey: "short_call_restriction") ?? false
        #endif
    }
    
    var shortCallDuration: Int {
        #if DEBUG
        7
        #else
        return getNumberValue(forKey: "short_call_duration") ?? 0
        #endif
    }
}
