//
//  UIView+Dispatcher.swift
//  BetGame
//
//  Created by Alexander Gerasimov on 4/28/17.
//  Copyright © 2017 zfort. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
     // MARK: - ENUM
    enum RecognizerType: String {
        case tap = "UITap​Gesture​Recognizer"
        case swipe = "UISwipe​Gesture​Recognizer"
        case pich = "UIPinch​Gesture​Recognizer"
        case rotation = "UIPinch​UIRotation​Gesture​Recognizer​Recognizer"
        case longPress = "UILong​Press​Gesture​Recognizer"
        case none = "none"
        
    }
    
    // MARK: - Public Type Methods
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
        recognizer.cancelsTouchesInView = false
        recognizers?.append(recognizer)
        
        self.addGestureRecognizer(recognizer)
        
        dispatcher.addEventListener(eventName: recognizerType.rawValue, listeningObject:  listeningObject, onEvent: onEvent)
        
    }
    
    // MARK: - Private Type Methods
    @objc dynamic
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
        
        dispatcher.dispatchEvent(e: Event(name: event.rawValue, sender: self))
    }
}
