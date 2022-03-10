//
//  JRegexValidator.swift
//  JForm
//
//  Created by dqh on 2021/8/3.
//

import Foundation

public class JRegexValidator: JValidateProtocol {

    let regex: String
    let message: String
    
    init(regex: String, message: String) {
        self.regex = regex
        self.message = message
    }
    
    public func evaluate(_ rowDescriptor: RowDescriptor) -> JValidateResult {
        let predicate = NSPredicate.init(format: "SELF MATCHES %@", regex)
        let isValid = predicate.evaluate(with: rowDescriptor.value)
        
        if isValid {
            return .ok
        } else {
            return .failure(message: message)
        }
    }
}
