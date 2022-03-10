//
//  JFormDescriptorDelegate.swift
//  JForm
//
//  Created by dqh on 2021/7/20.
//

import Foundation

public protocol JFormDescriptorDelegate: AnyObject {
    
    func sectionsDidRemoved(atIndexes indexes: IndexSet)
    
    func sectionsDidAdded(atIndexes indexes: IndexSet)
    
    func rowsDidAdded(atIndexPaths indexPaths: [IndexPath])
    
    func rowsDidRemoved(atIndexPaths indexPaths: [IndexPath])
    
    func rowValueDidChanged(_ row: RowDescriptor, oldValue: Any?, newValue: Any?)
}
