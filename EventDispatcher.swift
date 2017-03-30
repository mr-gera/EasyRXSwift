//
//  EventDispatcher.swift
//  BetGame
//
//  Created by Alexander Gerasimov on 3/30/17.
//  Copyright © 2017 zfort. All rights reserved.
//

import UIKit

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
    
    // MARK: - Alias for OnEvent pattern
    public typealias OnEvent = (_ event: Event) -> Void
    
    
    // MARK: - Private Properties
    fileprivate static let sharedPrivate = EventDispatcher()
    fileprivate var eventListeners = [String:[OnEvent?]]()
    fileprivate var dispatchersOwners = [AnyObject]()
    fileprivate var dispatchers = [EventDispatcher]()
    
    // MARK: - Public Properties
    
    /// Use data to store any objects or data
    var data: Any? = nil
    
    // MARK: - Public Type Methods
    
    func dispatchEvent(e: Event) {
        
        eventListeners.forEach {
            eventName, onEvents in
            
            if e.name == eventName {
                onEvents.forEach {
                    onEvent in
                    
                    if let onEvent = onEvent {
                        onEvent(e)
                    }
                }
            }
        }
    }
    
    func addEventListener(eventName: String, listener: OnEvent?) {
        
        if var listenersArray = eventListeners[eventName] {
            listenersArray.append(listener)
            eventListeners[eventName] = listenersArray
        } else {
            eventListeners[eventName] = [listener]
        }
    }
    
    
    // MARK: - Private Properties
    
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
            
           let dispatcher = EventDispatcher.sharedPrivate.registerNewDispatcher(self)
            
           return dispatcher
        }
    }
    
    func addEventListener(eventName: String, listener: ((_ event: Event) -> Void)?) {
        dispatcher.addEventListener(eventName: eventName, listener: listener)
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
    
    func addGestureListener(recognizerType: RecognizerType, listener: ((_ event: Event) -> Void)?) {
        
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
        
        dispatcher.addEventListener(eventName: recognizerType.rawValue, listener: listener)
    }
    
    dynamic
    fileprivate func anyGesture(e: UIGestureRecognizer) {
        
        var event = RecognizerType.tap
        
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
