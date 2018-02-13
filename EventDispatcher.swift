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
    var data: Any? = nil
    var dataObject: AnyObject? = nil
    
    // MARK: - Public
    public init(name: String, sender: AnyObject? = nil) {
        self.name = name
        self.sender = sender
    }
}

class EventDispatcher {
    
    // MARK: - Alias for OnEvent pattern
    
    public typealias OnEvent =  (_ event: Event) -> Any?
    
    class EventListener {
        var listeningObject: AnyObject? = nil
        var onEvent: OnEvent? = nil
    }
    
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
    
    @discardableResult
    func dispatchEvent(e: Event) -> Any? {

        for (eventName, eventListeners) in eventListenersDictionary {
            
            if e.name == eventName {
                for eventListener in eventListeners {
                    
                    if let onEvent = eventListener.onEvent {
                        _ = onEvent(e)
                    }
                }
            }
        }
        
        return nil
    }
    
    func addEventListener(eventNames: [String], listeningObject: AnyObject, onEvent: ((_ event: Event) -> Any?)?) {
        eventNames.forEach {
            eventName in
            
            addEventListener(eventName: eventName, listeningObject: listeningObject, onEvent: onEvent)
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

    func cleanListeners() {        
        eventListenersDictionary.removeAll()
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
    
    
    func removeEventListener(by eventName: String) {
        
        var index = 0
        
        if var listeners = eventListenersDictionary[eventName] {
            listeners.forEach {
                listener in
                
                listeners.remove(at: index)
                
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
