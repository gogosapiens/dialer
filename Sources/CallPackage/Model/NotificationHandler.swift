//
//  File 2.swift
//  
//
//  Created by Maxim Okolokulak on 21.06.23.
//

import Foundation

public protocol OnNotification {
    var handler: NotificationHandler { get }
}

extension OnNotification {
    func registerNotificationName(_ name: Notification.Name,
                                  object: Any? = nil,
                                  with handler: @escaping (Notification) -> ()) {
        self.handler.registerNotificationName(name, object: object, with: handler)
    }
}

public class NotificationHandler {
    private var handlers: [Notification.Name: (Notification) -> ()] = [:]
    
    func registerNotificationName(_ name: Notification.Name,
                                  object: Any? = nil,
                                  with handler: @escaping (Notification) -> ()) {
        handlers[name] = handler
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleNotification(_:)),
                                               name: name,
                                               object: nil)
    }
    
    @objc private func handleNotification(_ notification: Notification) {
        handlers[notification.name]?(notification)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
