//
//  OtherViewController.swift
//  JForm
//
//  Created by dqh on 2021/7/27.
//

import Foundation
import UIKit

class OtherViewController: BaseViewController {
    var form: JForm?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Other"
        
        let form = FormDescriptor.init()
        form.addAsteriskToRequiredRow = true
        
        
        // s 1
        var section = SectionDescriptor.init()
        form.add(section)

        var row: RowDescriptor!
        
        row = RowDescriptor.init(withTag: "switch", rowType: .switch_, title: "switch")
        section.add(row)
        
        row = RowDescriptor.init(withTag: "check", rowType: .check, title: "check")
        row.isRequired = true
        section.add(row)
      
        row = RowDescriptor.init(withTag: "stepCounter", rowType: .stepCounter, title: "stepCounter")
        row.configAfterCreate["maximumValue"] = 10
        section.add(row)
        
        row = RowDescriptor.init(withTag: "segmentedControl", rowType: .segmentedControl, title: "segmentedControl")
        row.optionItmes = [
            OptionItem(title: "早饭", value: "0"),
            OptionItem(title: "中饭", value: "1"),
            OptionItem(title: "晚饭", value: "2")
        ]
        section.add(row)
        
        
        row = RowDescriptor.init(withTag: "slider", rowType: .slider, title: "slider")
        section.add(row)
        
        self.form = JForm.init(withDecriptor: form)
        self.view.addSubview(self.form!)
    }

    override func viewWillLayoutSubviews() {
        self.form?.frame = self.view.bounds
    }
}
