//
//  UITableView+Dispatcher.swift
//  BetGame
//
//  Created by Alexander Gerasimov on 4/28/17.
//  Copyright © 2017 zfort. All rights reserved.
//

import Foundation
import UIKit

private var delegateKey : UInt8 = 81

final fileprivate class TableViewDispatchedDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Public Properties
    var onNumberOfSections: ((_ tableView: UITableView) -> Int)? = nil
    var onCellAtIndexPath: ((_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell)? = nil
    var onHeightForRowAt: ((_ tableView: UITableView, _ indexPath: IndexPath) -> CGFloat)? = nil
    var onNumberOfRowsInSection: ((_ tableView: UITableView, _ section: Int) -> Int)? = nil
    var onDidSelectRowAt: ((_ tableView: UITableView, _ indexPath: IndexPath) -> Void)? = nil
    
    // MARK: - Public Type Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if let onNumberOfSections = onNumberOfSections {
            return onNumberOfSections(tableView)
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let onNumberOfRowsInSection = onNumberOfRowsInSection {
            return onNumberOfRowsInSection(tableView, section)
        }
        
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let onCellAtIndexPath = onCellAtIndexPath {
            return onCellAtIndexPath(tableView, indexPath)
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let onHeightForRowAt = onHeightForRowAt {
            return onHeightForRowAt(tableView, indexPath)
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let onDidSelectRowAt = onDidSelectRowAt {
            onDidSelectRowAt(tableView, indexPath)
        }
    }
}

extension UITableView {
    
    // MARK: - Private Properties
    private var dispatchedDelegate: TableViewDispatchedDelegate? {
        
        get {
            let defaultDelegate = TableViewDispatchedDelegate()
            
            if let storedDelegate = getAssociatedObject(base: self, key: &delegateKey, defaultValue: defaultDelegate) {
                associate(base: self, key: &delegateKey, value: storedDelegate)
                return storedDelegate
            } else {
                let newDelegate = TableViewDispatchedDelegate()
                associate(base: self, key: &delegateKey, value: newDelegate)
                return newDelegate
            }
        }
    }
    
     // MARK: - Private Type Methods
    
    fileprivate func dispatcherDidSet(){
        
        if let dispatchedDelegate = dispatchedDelegate, self.delegate == nil, self.dataSource == nil {
            self.delegate = dispatchedDelegate
            self.dataSource = dispatchedDelegate
        }
    }
    
    // MARK: - Public Type Methods
    
    func set(onNumberOfSections: ((_ tableView: UITableView) -> Int)? = nil) {
        dispatcherDidSet()
        
        if let dispatchedDelegate = dispatchedDelegate {
            dispatchedDelegate.onNumberOfSections = onNumberOfSections
        }
    }
    
    func set(onCellAtIndexPath: ((_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell)? = nil) {
        
        dispatcherDidSet()
        
        if let dispatchedDelegate = dispatchedDelegate {
            dispatchedDelegate.onCellAtIndexPath = onCellAtIndexPath
        }
    }
    
    func set(onHeightForRowAt: ((_ tableView: UITableView, _ indexPath: IndexPath) -> CGFloat)? = nil) {
        
        dispatcherDidSet()
        
        if let dispatchedDelegate = dispatchedDelegate {
            dispatchedDelegate.onHeightForRowAt = onHeightForRowAt
        }
    }
    
    func set(onNumberOfRowsInSection: ((_ tableView: UITableView, _ section: Int) -> Int)? = nil) {
        
        dispatcherDidSet()
        
        if let dispatchedDelegate = dispatchedDelegate {
            dispatchedDelegate.onNumberOfRowsInSection = onNumberOfRowsInSection
        }
    }
    
    func set(onDidSelectRowAt: ((_ tableView: UITableView, _ indexPath: IndexPath) -> Void)? = nil) {
        
        dispatcherDidSet()
        
        if let dispatchedDelegate = dispatchedDelegate {
            dispatchedDelegate.onDidSelectRowAt = onDidSelectRowAt
        }
    }
}
