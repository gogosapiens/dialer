//
//  File.swift
//  
//
//  Created by Maxim Okolokulak on 12.06.23.
//

import Foundation
import Alamofire

//typealias HTTPHeaders = [String: String]

public final class ServiceConfig {
    
    private(set) var baseURL: URL
    var timeout: TimeInterval = 15.0
    
    
     public init?(base urlString: String) {
        guard let url = URL(string: urlString) else { return nil }
        self.baseURL = url
    }
    
    static func appConfig() -> ServiceConfig {
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let version = dict["callBaseURL"] as? String {
            return ServiceConfig(base:  version)!
        } else {
            fatalError("add callBaseURL -> Info.plist")
        }
    }
}
