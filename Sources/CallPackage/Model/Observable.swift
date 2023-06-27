//
//  File.swift
//  
//
//  Created by Maxim Okolokulak on 21.06.23.
//

import Foundation

public protocol Observable1: AnyObject {
    associatedtype ObjectEvent
    
    var observerTokenGenerator: Int { set get }
    var observers: [Int: (ObjectEvent) -> Void] { set get }
    var initialEvent: ObjectEvent? { get }
    func notifyObservers(_ event: ObjectEvent)
    func observe(_ block: @escaping (ObjectEvent) -> Void) -> Int
    func removeObserver(_ token: Int)
}

extension Observable1 {
    public func notifyObservers(_ event: ObjectEvent) {
        DispatchQueue.main.async {
            for observer in self.observers.values {
                observer(event)
            }
        }
    }
    
    public func observe(_ block: @escaping (ObjectEvent) -> Void) -> Int {
        observerTokenGenerator += 1
        observers[observerTokenGenerator] = block
        if let initialEvent = initialEvent {
            DispatchQueue.main.async {
                block(initialEvent)
            }
        }
        return observerTokenGenerator
    }
    
    public func removeObserver(_ token: Int) {
        observers[token] = nil
    }
    
    public var initialEvent: ObjectEvent? {
        return nil
    }
}
