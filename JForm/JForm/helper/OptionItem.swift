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
    
    public init(title: String, value: String) {
       self.title = title
       self.value = value
    }

    public init?(title: String?, value: String?) {
       guard let title = title, let value = value else { return nil }
       self.title = title
       self.value = value
    }
    
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
