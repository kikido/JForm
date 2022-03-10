//
//  SelectViewController.swift
//  JForm
//
//  Created by dqh on 2021/7/27.
//

import Foundation
import UIKit

class SelectViewController: BaseViewController {
    
    var form: JForm?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Select"
        
        let form = FormDescriptor.init()
        form.addAsteriskToRequiredRow = true
        form.laysOutHorizontally = false
        
        let section = SectionDescriptor.init()
        form.add(section)

        var row: RowDescriptor!
        
        let items = [
            OptionItem(title: "早饭", value: "1"),
            OptionItem(title: "午饭", value: "2"),
            OptionItem(title: "晚饭", value: "3"),
        ]
        
        row = RowDescriptor.init(withTag: "pushSelect", rowType: .pushSelect, title: "pushSelect")
        row.selectorTitle = "单选"
        row.optionItmes = items
        row.isRequired = true
        section.add(row)
        
        row = RowDescriptor.init(withTag: "multipleSelect", rowType: .multipleSelect, title: "multipleSelect")
        row.optionItmes = items
        row.selectorTitle = "多选"
        row.value = [
            OptionItem(title: "早饭", value: "1"),
            OptionItem(title: "午饭", value: "2")
        ]
        section.add(row)
      
        row = RowDescriptor.init(withTag: "sheet", rowType: .sheet, title: "sheet")
        row.optionItmes = items
        section.add(row)
        
        row = RowDescriptor.init(withTag: "alert", rowType: .alert, title: "alert")
        row.optionItmes = items
        section.add(row)
        
        row = RowDescriptor.init(withTag: "picker", rowType: .picker, title: "picker")
        row.optionItmes = items
        section.add(row)
        
        row = RowDescriptor.init(withTag: "pushButton", rowType: .pushButton, title: "pushButton")
        row.action = { _ in
            let vc = UIViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        row.optionItmes = items

        section.add(row)
        
        self.form = JForm.init(withDecriptor: form)
        self.view.addSubview(self.form!)
    }

    override func viewWillLayoutSubviews() {
        self.form?.frame = self.view.bounds
    }
}
