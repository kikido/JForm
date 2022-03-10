//
//  FormFormViewController.swift
//  JForm
//
//  Created by dqh on 2021/12/14.
//

import UIKit


class FormFormViewController: BaseViewController {
    
    var form: JForm?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Form"
        
        let form = FormDescriptor.init()
        form.addAsteriskToRequiredRow = true
        form.autoAddPlaceholder = true
        
        let section = SectionDescriptor.init()
        form.add(section)
        
        var row: RowDescriptor!
        
        let options = [OptionItem(title: "西瓜", value: "1"), OptionItem(title: "桃子", value: "2"), OptionItem(title: "香蕉", value: "3"), OptionItem(title: "橘子", value: "4")];

        for type in kArrayOfTypes {
            row = RowDescriptor(withTag: type.rawValue, rowType: type, title: type.rawValue)
            row.cell.accessibilityLabel = type.rawValue
            row.cell.accessibilityIdentifier = type.rawValue
            row.optionItmes = options
            section.add(row)
        }
        
        self.form = JForm.init(withDecriptor: form, frame: self.view.bounds)
        self.form?.accessibilityLabel = _formForm
        self.view.addSubview(self.form!)
        
        let button = UIButton.init(type: .custom)
        button.setTitle("测试", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        let buttonItem = UIBarButtonItem.init(customView: button)
        self.navigationItem.rightBarButtonItem = buttonItem
        
        self.modalPresentationStyle = .formSheet
    }
    
    @objc func buttonAction() {
        form?.tableNode.view.endEditing(true)
    }

    override func viewWillLayoutSubviews() {
        form?.frame = self.view.bounds
    }
}
