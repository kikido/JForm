//
//  TextViewController.swift
//  JForm
//
//  Created by dqh on 2021/7/27.
//

import Foundation
import UIKit

class TextViewController: BaseViewController {
    var form: JForm?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Text"
        
        let form = FormDescriptor.init()
        form.addAsteriskToRequiredRow = true
        form.autoAddPlaceholder = true
        form.laysOutHorizontally = false
        
        var section = SectionDescriptor.init()
        section.editStyle = .delete
        form.add(section)

        var row: RowDescriptor!
        
        row = RowDescriptor.init(withTag: "text", rowType: .text, title: "text")
        section.add(row)
        
        row = RowDescriptor.init(withTag: "name", rowType: .name, title: "name")
        row.placeholder = "请输入姓名..."
        row.isRequired = true
        section.add(row)
      
        row = RowDescriptor.init(withTag: "email", rowType: .email, title: "email")
        row.isRequired = true
        section.add(row)
        
        row = RowDescriptor.init(withTag: "integer", rowType: .integer, title: "integer")
        row.value = "1234"
        row.unit = "个"
        section.add(row)
        
        row = RowDescriptor.init(withTag: "decimal", rowType: .decimal, title: "decimal")
        section.add(row)
        
        row = RowDescriptor.init(withTag: "phone", rowType: .phone, title: "phone")
        section.add(row)
        
        row = RowDescriptor.init(withTag: "password", rowType: .password, title: "password")
        section.add(row)
        
        row = RowDescriptor.init(withTag: "url", rowType: .url, title: "url")
        section.add(row)
        
        // section 2
        
        section = SectionDescriptor.init()
        form.add(section)
        
        row = RowDescriptor.init(withTag: "info", rowType: .info, title: "info")
        row.value = "this is info this is info this is info this is info this is info this is info this is info this is info this is info this is info this is info this is info "
        section.add(row)
        
        row = RowDescriptor.init(withTag: "info1", rowType: .info, title: "标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长")
        row.value = "info"
        section.add(row)
        
        row = RowDescriptor.init(withTag: "info2", rowType: .info, title: "标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长")
        row.value = "this is info this is info this is info this is info this is info this is info this is info this is info this is info this is info this is info this is info "
        section.add(row)
        
        row = RowDescriptor.init(withTag: "longInfo", rowType: .longInfo, title: "longInfo")
        row.value = "this is longInfo this is longInfo this is longInfo this is longInfo this is longInfo this is longInfo this is longInfo this is longInfo this is longInfo this is longInfo this is longInfo this is longInfo "
        section.add(row)
        
        row = RowDescriptor.init(withTag: "longInfo1", rowType: .longInfo, title: "标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长")
        row.value = "longInfo "
        section.add(row)
        
        row = RowDescriptor.init(withTag: "longInfo2", rowType: .longInfo, title: "标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长")
        row.value = "this is longInfo this is longInfo this is longInfo this is longInfo this is longInfo this is longInfo this is longInfo this is longInfo this is longInfo this is longInfo this is longInfo this is longInfo "
        section.add(row)
        
        let style = RowDescriptor.Style()
        style.detailColor = .red
        row = RowDescriptor.init(withTag: "textView", rowType: .textView, title: "textView", style: style)
        row.placeholder = "请写点什么吧"
        section.add(row)
        
        // setion 3
        
        section = SectionDescriptor.init()
        form.add(section)
        
        row = RowDescriptor.init(withTag: "30", rowType: .name, title: "标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长")
        section.add(row)
        
        row = RowDescriptor.init(withTag: "31", rowType: .name, title: "name")
        row.value = "内容很长内容很长内容很长内容很长内容很长内容很长内容很长内容很长内容很长内容很长内容很长内容很长内容很长内容很长内容很长内容很长内容很长内容很长内容很长内容很长内容很长内容很长内容很长内容很长"
        section.add(row)
        
        row = RowDescriptor.init(withTag: "32", rowType: .name, title: "标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长标题很长")
        row.value = "内容很长内容很长内容很长内容很长内容很长内容很长内容很长内容很长内容很长内容很长内容很长内容很长内容很长内容很长内容很长内容很长内容很长内容很长内容很长内容很长内容很长内容很长内容很长内容很长"
        section.add(row)
        
        row = RowDescriptor.init(withTag: "33", rowType: .name, title: "disabled", style: JStyle {
            $0.detailDisabledColor = UIColor.yellow
        })
        row.value = "disabled"
        row.isDisabled = true
        section.add(row)
        
        
        self.form = JForm.init(withDecriptor: form)
        self.view.addSubview(self.form!)
        
        let button = UIButton.init(type: .custom)
        button.setTitle("edit", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)
        let buttonItem = UIBarButtonItem.init(customView: button)
        self.navigationItem.rightBarButtonItem = buttonItem
    }
    
    let count = 0
    @objc func buttonAction() {
        let row = RowDescriptor.init(withTag: "\(count)", rowType: .text, title: "测试\(count)")
        self.form?.add([row], beforeRowWithTag: "text")
    }

    override func viewWillLayoutSubviews() {
        self.form?.frame = self.view.bounds
    }
    
    @objc func buttonAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        sender.setTitle(sender.isSelected ? "editing" : "edit", for: .normal)
        form?.tableView.isEditing = sender.isSelected
    }
}
