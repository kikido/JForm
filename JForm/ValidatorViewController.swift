//
//  ValidatorViewController.swift
//  JForm
//
//  Created by dqh on 2021/7/27.
//

import Foundation
import UIKit

class ValidatorViewController: BaseViewController {
    var form: JForm?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Validate"
        
        let form = FormDescriptor.init()
        form.addAsteriskToRequiredRow = true
        form.autoAddPlaceholder = true
        
        let section = SectionDescriptor.init()
        form.add(section)

        var row: RowDescriptor!
        
        row = RowDescriptor.init(withTag: "name", rowType: .name, title: "姓名")
        row.isRequired = true
        section.add(row)
        
        row = RowDescriptor.init(withTag: "email", rowType: .email, title: "邮箱")
        row.addValidator(JRegexValidator.init(regex: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,11}", message: "邮箱格式错误"))
        section.add(row)
        
        row = RowDescriptor.init(withTag: "password", rowType: . password, title: "密码")
        row.addValidator(JRegexValidator.init(regex: "(?=.*\\d)(?=.*[A-Za-z])^.{6,32}$", message: "密码长度应在6~32位之间,且至少包含一个数字和字母"))
        section.add(row)
        
        row = RowDescriptor.init(withTag: "integer", rowType: .integer, title: "数字")
        row.addValidator(JRegexValidator.init(regex: "^([5-9][0-9]|100)$", message: "数字应大于等于50或者小于等于100"))
        section.add(row)
        
        
        self.form = JForm.init(withDecriptor: form)
        self.view.addSubview(self.form!)
        
        // button
        
        let button = UIButton.init(type: .custom)
        button.setTitle("提交表单", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        let buttonItem = UIBarButtonItem.init(customView: button)
        self.navigationItem.rightBarButtonItem = buttonItem
    }
    
    @objc func buttonAction() {
        if let form = self.form, let errors = form.validateErrors, !errors.isEmpty {
            form.showValidateError(errors.first!)
            return
        }
        
    }

    override func viewWillLayoutSubviews() {
        self.form?.frame = self.view.bounds
    }
}
