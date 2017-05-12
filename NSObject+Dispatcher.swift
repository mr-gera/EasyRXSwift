//
//  NSObject+Dispatcher.swift
//  EasyRXSwift
//
//  Created by Alexander Gerasimov on 4/28/17.
//  Copyright © 2017 zfort. All rights reserved.
//
import UIKit

private var dispatcherKey : UInt8 = 8

func getAssociatedObject<ValueType: AnyObject>(
    base: AnyObject,
    key: UnsafePointer<UInt8>,
    defaultValue : ValueType)
    -> ValueType? {
        if let associated = objc_getAssociatedObject(base, key)
            as? ValueType { return associated }
        return defaultValue
}
func associate<ValueType: AnyObject>(
    base: AnyObject,
    key: UnsafePointer<UInt8>,
    value: ValueType) {
    objc_setAssociatedObject(base, key, value,
                             .OBJC_ASSOCIATION_RETAIN)
}

extension NSObject {
    
    var dispatcher: EventDispatcher {
        
        get {
            let defaultDispatcher = EventDispatcher(defaultData: true)
            
            if let storedDispatcher = getAssociatedObject(base: self, key: &dispatcherKey, defaultValue: defaultDispatcher) {
                
                associate(base: self, key: &dispatcherKey, value: storedDispatcher)
                
                if defaultDispatcher === storedDispatcher {
                    print("used default")
                }
                
                return storedDispatcher
                
            } else {
                let newDispatcher = EventDispatcher()
                associate(base: self, key: &dispatcherKey, value: newDispatcher)
                
                return newDispatcher
            }
            
        }
    }
    
    
    func removeEventListener(listeningObject: AnyObject) {
        dispatcher.removeEventListener(listeningObject: listeningObject)
    }
    
    func removeEventListener(by eventName: String, listeningObject: AnyObject) {
        dispatcher.removeEventListener(by: eventName, listeningObject: listeningObject)
    }
    
    func addEventListener(eventName: String, listeningObject: AnyObject, onEvent: ((_ event: Event) -> Any?)?) {
        dispatcher.addEventListener(eventName: eventName, listeningObject: listeningObject, onEvent: onEvent)
    }
    
    
    func addEventListener(eventNames: [String], listeningObject: AnyObject, onEvent: ((_ event: Event) -> Any?)?) {
        eventNames.forEach {
            eventName in
            
            dispatcher.addEventListener(eventName: eventName, listeningObject: listeningObject, onEvent: onEvent)
        }
    }
    
    @discardableResult
    func dispatchEvent(_ e: Event) -> Any? {
        return dispatcher.dispatchEvent(e: e)
    }
    
    @discardableResult
    func dispatchEvent(with name: String) -> Any? {
        return dispatcher.dispatchEvent(e: Event(name: name))
    }
}

