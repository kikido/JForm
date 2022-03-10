//
//  JValidateResult.swift
//  JForm
//
//  Created by dqh on 2021/8/3.
//

import Foundation

public enum JValidateResult {
    case ok
    case failure(message: String)
}

extension JValidateResult: Equatable {
    
    var isValid: Bool {
        switch self {
        case .ok:
            return true
        case .failure:
            return false
        }
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.ok, .ok):
            return true
        case (.failure, .failure):
            return true
        default:
            return false
        }
    }
}
