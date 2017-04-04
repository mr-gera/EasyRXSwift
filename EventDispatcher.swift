//
//  EventDispatcher.swift
//  BetGame
//
//  Created by Alexander Gerasimov on 3/30/17.
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

class Event {
    
    var name = ""
    var sender: AnyObject? = nil
    
    // MARK: - Public
    public init(name: String, sender: AnyObject? = nil) {
        self.name = name
        self.sender = sender
    }
}

extension Event {
    struct EventName {
        static let onClick = "onClick"
        static let onGesture = "onGesture"
    }
}


class EventDispatcher {

    class EventListener {
        var listeningObject: AnyObject? = nil
        var onEvent: OnEvent? = nil
    }

    
    // MARK: - Alias for OnEvent pattern
    public typealias OnEvent = (_ event: Event) -> Void
    
    
    // MARK: - Private Properties
    static let shared = EventDispatcher()
    
    fileprivate static let nulleReference: EventDispatcher? = nil
    
    fileprivate var eventListenersDictionary = [String:[EventListener]]()
    
    fileprivate var dispatchersOwners = [AnyObject]()
    fileprivate var dispatchers = [EventDispatcher]()
    
    
    // MARK: - Public Properties
    
    /// Use data to store any objects or data
    var data: Any? = nil
    
    // MARK: - Public Type Methods
    
    public init(defaultData: Bool = false) {
        
        if defaultData {
            data = 1
        }
    }
    
    func dispatchEvent(e: Event) {

        eventListenersDictionary.forEach {
            eventName, eventListeners in
            
            if e.name == eventName {
                eventListeners.forEach {
                    eventListener in
                    
                    if let onEvent = eventListener.onEvent {
                        onEvent(e)
                    }
                }
            }
        }
    }
    
    func addEventListener(eventName: String, listeningObject: AnyObject, onEvent: OnEvent?) {
        
        removeEventListener(by: eventName, listeningObject: listeningObject)
        
        var listener = eventListener(by: eventName, listeningObject: listeningObject)
        
        var listenerFound = false
        
        if listener == nil {
            listener = EventListener()
        } else {
            listenerFound = true
        }
        
        if let listener = listener {
            listener.onEvent = onEvent
            listener.listeningObject = listeningObject
        }
        
        if !listenerFound, let listener = listener {
            if eventListenersDictionary[eventName] == nil {
                eventListenersDictionary[eventName] = [listener]
            } else {
                eventListenersDictionary[eventName]?.append(listener)
            }
        }
        
    }

    func removeEventListener(listeningObject: AnyObject) {
        
        eventListenersDictionary.forEach {
            eventName, listeners in
            
            removeEventListener(by: eventName, listeningObject: listeningObject)
        }
    }
    
    func removeEventListener(by eventName: String, listeningObject: AnyObject) {
        
        var index = 0
        
        if var listeners = eventListenersDictionary[eventName] {
            listeners.forEach {
                listener in
                
                if listener.listeningObject === listeningObject {
                    listeners.remove(at: index)
                }
                
                index += 1
            }
            
            eventListenersDictionary[eventName] = listeners
        }
        
    }

    
    // MARK: - Private Properties
    
    fileprivate func eventListener(by eventName: String, listeningObject: AnyObject?) -> EventListener? {
        
        if let listeners = eventListenersDictionary[eventName] {
            
            for listener in listeners {
                
                if listener.listeningObject === listeningObject {
                    return listener
                }
            }
        }
        
        return nil
    }
    
    fileprivate func registerNewDispatcher(_ owner: AnyObject) -> EventDispatcher {
        if let dispatcher = getRegisteredDispatcher(owner: owner) {
            return dispatcher
        } else {
            let dispatcher = EventDispatcher()
            dispatchersOwners.append(owner)
            dispatchers.append(dispatcher)
            return dispatcher
        }
    }
    
    fileprivate func getRegisteredDispatcher(owner: AnyObject) -> EventDispatcher?{
        
        for index in 0..<dispatchersOwners.count {
            if dispatchersOwners[index] === owner {
                return dispatchers[index]
            }
        }
        
        return nil
    }
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
    
    func addEventListener(eventName: String, listeningObject: AnyObject, onEvent: ((_ event: Event) -> Void)?) {
        dispatcher.addEventListener(eventName: eventName, listeningObject: listeningObject, onEvent: onEvent)
    }

    
    func addEventListener(eventNames: [String], listeningObject: AnyObject, onEvent: ((_ event: Event) -> Void)?) {
        eventNames.forEach {
            eventName in
            
            dispatcher.addEventListener(eventName: eventName, listeningObject: listeningObject, onEvent: onEvent)
        }
    }
    
    func dispatchEvent(e: Event) {
        dispatcher.dispatchEvent(e: e)
    }
    
    dynamic
    fileprivate func touchGesture(e: UITapGestureRecognizer) {
        dispatcher.dispatchEvent(e: Event(name: Event.EventName.onClick))
    }
}

extension UIView {
    
    enum RecognizerType: String {
        case tap = "UITap​Gesture​Recognizer"
        case swipe = "UISwipe​Gesture​Recognizer"
        case pich = "UIPinch​Gesture​Recognizer"
        case rotation = "UIPinch​UIRotation​Gesture​Recognizer​Recognizer"
        case longPress = "UILong​Press​Gesture​Recognizer"
        case none = "none"
        
    }
    
    func addGestureListener(recognizerType: RecognizerType, listeningObject: AnyObject, onEvent: ((_ event: Event) -> Void)?) {
        
        var recognizers = dispatcher.data as? [UIGestureRecognizer]
        
        if recognizers == nil {
            recognizers = [UIGestureRecognizer]()
        }
        
        var recognizer = UIGestureRecognizer()
        
        switch recognizerType {
        case .tap:
            recognizer = UITapGestureRecognizer()
        case .longPress:
            recognizer = UILongPressGestureRecognizer()
        case .swipe:
            recognizer = UISwipeGestureRecognizer()
        default:
            recognizer = UIGestureRecognizer()
        }
        
        recognizer.addTarget(self, action:  #selector(self.anyGesture))
        
        recognizers?.append(recognizer)
        
        self.addGestureRecognizer(recognizer)
        
        dispatcher.addEventListener(eventName: recognizerType.rawValue, listeningObject:  listeningObject, onEvent: onEvent)

    }
    
    dynamic
    fileprivate func anyGesture(e: UIGestureRecognizer) {
        
        var event = RecognizerType.none
        
        switch e {
        case is UITapGestureRecognizer:
            event = .tap
        case is UILongPressGestureRecognizer:
            event = .longPress
        case is UISwipeGestureRecognizer:
            event = .swipe
        default:
            event = .none
        }
        
        dispatcher.dispatchEvent(e: Event(name: event.rawValue, sender: e))
    }
}
