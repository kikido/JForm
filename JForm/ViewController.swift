//
//  ViewController.swift
//  JForm
//
//  Created by dqh on 2021/7/19.
//

import UIKit


///| --- For Test --- |///
public let _textCell = "_textCell"
public let _selectCell = "_selectCell"
public let _dateCell = "_dateCell"
public let _otherCell = "_otherCell"
public let _validateCell = "_validateCell"
public let _formCell = "_formCell"

public let _formForm = "_formForm"


let textTags: [RowDescriptor.RowType] = [.text, .name, .email, .decimal, .integer, .password, .phone, .url, .textView]
let dateTags: [RowDescriptor.RowType] = [.date, .time, .dateTime, .countDownTimer]
let dateInlineTags: [RowDescriptor.RowType] = [.dateInline, .timeInline, .dateTimeInline, .countDownTimerInline]
let selectTags: [RowDescriptor.RowType] = [.pushSelect, .multipleSelect, .sheet, .alert, .picker]
let kArrayOfTypes: [RowDescriptor.RowType] = [.text, .name, .email, .integer, .decimal, .password, .phone, .url, .info,
                                              .textView, .longInfo,
                                              .pushSelect, .multipleSelect, .pushButton, .sheet, .alert, .picker,
                                              .date, .time, .dateTime, .countDownTimer,
                                              .dateInline, .timeInline, .dateTimeInline, .countDownTimerInline,
                                              .switch_, .check, .stepCounter, .segmentedControl, .slider]

class ViewController: UIViewController {
    
    var form: JForm!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "JForm"
        
        let form = FormDescriptor.init()
        let section = SectionDescriptor.init()
        section.headerHeight = 100
        section.footerAttributeString = appendInterpolation("合适测试 kdkdd", style: .color(.red), .font(.systemFont(ofSize: 18)))
        section.headerAttributeString = appendInterpolation("合适测试 kdkddkdkdkdkdkdkdkdkdd", style: .color(.red))
        var row: RowDescriptor!
        
        form.add(section)
        
        row = RowDescriptor.init(withTag: "text", rowType: .pushButton, title: "text")
        row.action = { _ in
            let vc = TextViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        row.cell.accessibilityLabel = _textCell;
        section.add(row)
        
        row = RowDescriptor.init(withTag: "select", rowType: .pushButton, title: "select")
        row.action = { _ in
            let vc = SelectViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        section.add(row)
        
        row = RowDescriptor.init(withTag: "date", rowType: .pushButton, title: "date")
        row.action = { _ in
            let vc = DateViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        section.add(row)
        
        row = RowDescriptor.init(withTag: "other", rowType: .pushButton, title: "other")
        row.action = { _ in
            let vc = OtherViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        section.add(row)
        
        row = RowDescriptor.init(withTag: "validator", rowType: .pushButton, title: "validator")
        row.action = { _ in
            let vc = ValidatorViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        section.add(row)
        
        row = RowDescriptor.init(withTag: "form", rowType: .pushButton, title: "form1")
        row.action = { _ in
            let vc = FormViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        section.add(row)
        
        row = RowDescriptor.init(withTag: "formform", rowType: .pushButton, title: "form2")
        row.action = { _ in
            let vc = FormFormViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        row.cell.accessibilityLabel = _formCell
        section.add(row)
        
        row = RowDescriptor.init(withTag: "test", rowType: .pushButton, title: "test")
        row.action = { _ in
            let vc = TestViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        row.cell.accessibilityLabel = _formCell
        section.add(row)
        
        self.form = JForm.init(withDecriptor: form)
        self.view.addSubview(self.form)
    }

    override func viewWillLayoutSubviews() {
        self.form.frame = self.view.bounds
    }

}


class BaseViewController: UIViewController {
    deinit {
//        timer.invalidate()
        print("\(self) dealloc")
    }
}

