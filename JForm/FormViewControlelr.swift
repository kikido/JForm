//
//  FormViewControlelr.swift
//  JForm
//
//  Created by dqh on 2021/8/4.
//

import Foundation
import UIKit

class FormViewController: BaseViewController {
    var form: JForm?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "表单"
        
        let form = FormDescriptor.init()
        form.addAsteriskToRequiredRow = true
        form.autoAddPlaceholder = true
        
        
        // s 1
        let section = SectionDescriptor.init()
        form.add(section)

        var row: RowDescriptor!
        
        row = RowDescriptor.init(withTag: "公司名称", rowType: .text, title: "公司名称")
        row.isRequired = true
        row.value = "测试"
        section.add(row)
        
        row = RowDescriptor.init(withTag: "法人代表", rowType: . name, title: "法人代表")
        row.isRequired = true
        section.add(row)
              
        row = RowDescriptor.init(withTag: "经营年限", rowType: .integer, title: "经营年限")
        row.unit = "年"
        row.addValidator(JRegexValidator.init(regex: "^([5-9][0-9]|100)$", message: "经营年限应大50"))
        section.add(row)

        row = RowDescriptor.init(withTag: "注册资金", rowType: .decimal, title: "注册资金")
        row.unit = "万元"
        section.add(row)
        
        row = RowDescriptor.init(withTag: "公司简介", rowType: .textView, title: "公司简介")
        row.placeholder = "输入字数不能超过 120"
        row.height = 120
        row.maxNumberOfCharacters = 120
        section.add(row)
        
        self.form = JForm.init(withDecriptor: form)
        self.form!.accessibilityLabel = _formForm
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
        
        if let values = self.form?.formValues {
            let parameter: [String: Any?] = [
                "aKey": values["公司名称"]!,
                "bKey": values["法人代表"]!,
                "cKey": values["经营年限"],
                "dKey": values["注册资金"],
                "eKey": values["公司简介"],
            ]
            // upload form data...
            print("开始上传数据...")
        }
    }

    override func viewWillLayoutSubviews() {
        self.form?.frame = self.view.bounds
    }
}
