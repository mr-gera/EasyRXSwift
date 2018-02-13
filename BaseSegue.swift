//
//  BaseSegue.swift
//  Segue
//
//  Created by Alexander Gerasimov on 13/2/18.
//  Copyright © 2018 Alexander Gerasimov. All rights reserved.
//

import UIKit

class BaseSegue: UIStoryboardSegue {

    override func perform() {        
        let event = Event(name: String.init(describing: self.destination.classForCoder), sender: self)
        event.dataObject = self.destination
        self.source.dispatchEvent(event)
        super.perform()
    }
}

