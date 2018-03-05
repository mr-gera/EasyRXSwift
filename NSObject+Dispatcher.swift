//
//  NSObject+Dispatcher.swift
//  BetGame
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
    
    // MARK: - Public Properties
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
    
    // MARK: - Public Type Methods
    
    func cleanListeners() {
        dispatcher.cleanListeners()
    }
    
    func leaveDispatcher() {
        dispatcher.removeEventListener(listeningObject: self)
        EventDispatcher.shared.removeEventListener(listeningObject: self)
        cleanListeners()
        
        var view: UIView? = nil
        
        if let controller = self as? UIViewController {
            view = controller.view
        } else {
            if let selfView = self as? UIView {
                view = selfView
            }
        }
        
        guard let parentalView = view else {
            return
        }
        
        parentalView.subviews.forEach {
            view in
            view.leaveDispatcher()
        }
    }
    
    func removeEventListener(listeningObject: AnyObject) {
        dispatcher.removeEventListener(listeningObject: listeningObject)
    }
    
    func removeEventListener(by eventName: String, listeningObject: AnyObject) {
        dispatcher.removeEventListener(by: eventName, listeningObject: listeningObject)
    }
    
    func addClassedEventListener(eventNameObject: Any, listeningObject: AnyObject, onEvent: ((_ event: Event) -> Any?)?) {
        dispatcher.addEventListener(eventName: String(describing:eventNameObject), listeningObject: listeningObject, onEvent: onEvent)
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
    
    func addSegueListener<T: UIViewController>(closure: @escaping (_ obj: T) -> Void) {
        
        addClassedEventListener(eventNameObject: T.classForCoder(), listeningObject: self) {
            event in
            
            let vc = event.dataObject as! T
            closure(vc)
            
            return nil
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

