//
//  JFormDelegate.swift
//  JForm
//
//  Created by dqh on 2021/7/20.
//

import Foundation

public protocol JFormDelegate: AnyObject {
    
    func rowValueDidChanged(_ row: RowDescriptor, oldValue: Any?, newValue: Any?)
    
}
