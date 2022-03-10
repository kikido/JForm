//
//  DateViewController.swift
//  JForm
//
//  Created by dqh on 2021/7/27.
//

import Foundation
import UIKit

class DateViewController: BaseViewController {
    var form: JForm?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Date"
        
        let form = FormDescriptor.init()
        form.addAsteriskToRequiredRow = true
        form.autoAddPlaceholder = true
        
        
        // s 1
        var section = SectionDescriptor.init()
        section.headerAttributeString = appendInterpolation("这是测试号码是测试号码是测试号码是测试号码是测试号码是测试号码ididksjajaididksjajaididksjajaididksjajaididksjaja", style: .color(.green))
        form.add(section)

        var row: RowDescriptor!
        
        row = RowDescriptor.init(withTag: "date", rowType: .date, title: "date")
        let now = Date()
        let min = Date(timeInterval: 3600 * 24, since: now)
        row.configAfterCreate["minimumDate"] = min
        row.value = now
        section.add(row)
        
        row = RowDescriptor.init(withTag: "time", rowType: .time, title: "time")
        row.configAfterCreate["minuteInterval"] = 4
        row.isRequired = true
        section.add(row)
      
        row = RowDescriptor.init(withTag: "dateTime", rowType: .dateTime, title: "dateTime")
        section.add(row)
        
        row = RowDescriptor.init(withTag: "countDownTimer", rowType: .countDownTimer, title: "countDownTimer")
        section.add(row)
        
        // s 2
        section = SectionDescriptor.init()
        form.add(section)

        row = RowDescriptor.init(withTag: "dateInline", rowType: .dateInline, title: "")
        row.value = now
        row.configAfterCreate["minimumDate"] = min
        section.add(row)

        row = RowDescriptor.init(withTag: "timeInline", rowType: .timeInline, title: "timeInline")
        section.add(row)

        row = RowDescriptor.init(withTag: "dateTimeInline", rowType: .dateTimeInline, title: "dateTimeInline")
        section.add(row)

        row = RowDescriptor.init(withTag: "countDownTimerInline", rowType: .countDownTimerInline, title: "countDownTimerInline")
        section.add(row)
        
        self.form = JForm.init(withDecriptor: form)
        self.view.addSubview(self.form!)
    }

    override func viewWillLayoutSubviews() {
        self.form?.frame = self.view.bounds
    }
}
