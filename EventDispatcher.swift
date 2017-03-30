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
    }
}

class EventDispatcher {
    
    // MARK: - Alias for OnEvent pattern
    typealias OnEvent = (_ event: Event) -> Void
    
    
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
            
            if let view = self as? UIView {
                
                if dispatcher.data as? UITapGestureRecognizer != nil{
                    return dispatcher
                }
                
                if let recoOld = dispatcher.data as? UITapGestureRecognizer {
                    view.removeGestureRecognizer(recoOld)
                }
                
                let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.touchGesture))
                
                dispatcher.data = recognizer
                
                view.addGestureRecognizer(recognizer)
            }
            
           return dispatcher
        }
    }
    
    dynamic
    fileprivate func touchGesture(e: UITapGestureRecognizer) {
        dispatcher.dispatchEvent(e: Event(name: Event.EventName.onClick))
    }
}
