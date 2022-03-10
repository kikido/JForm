//
//  OptionItem.swift
//  JForm
//
//  Created by dqh on 2021/8/4.
//

import Foundation

public struct OptionItem {
    
    public var title: String
    public var value: String
    
    public var isEmpty: Bool {
        return value.isEmpty
    }
}

extension OptionItem: Equatable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.value == rhs.value
    }
}

extension OptionItem: CustomStringConvertible {

    public var description: String {
        return "(title: \(title), value: \(value))"
    }
}
