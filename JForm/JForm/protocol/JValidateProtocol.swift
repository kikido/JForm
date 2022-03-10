//
//  JFormValidateProtocol.swift
//  JForm
//
//  Created by dqh on 2021/7/19.
//

import Foundation

public protocol JValidateProtocol: AnyObject {
    
    func evaluate(_ rowDescriptor: RowDescriptor) -> JValidateResult
}


