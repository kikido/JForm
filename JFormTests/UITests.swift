//
//  UITests.swift
//  JFormTests
//
//  Created by dqh on 2021/12/7.
//

//import Foundation
@testable import JForm
import AsyncDisplayKit
//import KIF
import UIKit
import XCTest

class UITests: KIFTestCase {
    
    var _form: JForm?
    var _formDescriptor: FormDescriptor?
    var _section: SectionDescriptor?
    var _row: RowDescriptor?
    
    let kWaitTimeInterval = 3
    
    let responseTags: [RowDescriptor.RowType] = [.text, .name, .email, .integer, .decimal, .password, .phone, .url, .textView,
                                                 .date, .time, .dateTime, .countDownTimer,
                                                 .dateInline, .timeInline, .dateTimeInline, .countDownTimerInline]
    
    override func beforeEach() {
        print(#function)
        tester().waitForView(withAccessibilityLabel: _formCell)
        tester().tapView(withAccessibilityLabel: _formCell)

        _form = tester().waitForView(withAccessibilityLabel: _formForm) as? JForm
        _formDescriptor = _form?.formDescriptor
    }
    
    override func afterEach() {
        print(#function)
        _form = nil
        _formDescriptor = nil
        _section = nil
        _row = nil
//        tester().
        tester().tapView(withAccessibilityLabel: NSLocalizedString("JForm", comment: ""), traits: .button)
//        [tester tapViewWithAccessibilityLabel:NSLocalizedString(@"Back", nil) traits:UIAccessibilityTraitButton];
    }
    
//    override func beforeAll() {
//        print(#function)
//    }
    
    
    
//    override func afterAll() {
//        print(#function)
//    }
    
    
// MARK: - Tester
    
    func testCellBeFirstResponder() {
        for type in responseTags {
            let row: RowDescriptor! = _form?.row(withTag: type.rawValue)
            
            // 文本类型
            for tag in textTags {
                if type == tag {
                    let cell = tester().waitForView(withAccessibilityLabel: tag.rawValue)
                    tester().enterText("1", into: nil, in: cell, expectedResult: nil)
                    XCTAssertTrue(row.cell.isFirstResponder())

                    row.cell.resignFirstResponder()
                    XCTAssertFalse(row.cell.isFirstResponder())
                    continue
                }
            }
            
            // 日期类型
            for tag in dateTags {
                if type == tag {
                    let indexpath = _form?.indexPathForRow(row)
                    tester().tapRow(at: indexpath, in: _form?.tableView)
                    XCTAssertTrue(row.cell.isFirstResponder())

                    row.cell.resignFirstResponder()
                    XCTAssertFalse(row.cell.isFirstResponder())
                    continue
                }
            }
            
            // 内嵌日期类型
            for tag in dateInlineTags {
                if type == tag {
                    let indexpath = _form?.indexPathForRow(row)
                    tester().tapRow(at: indexpath, in: _form?.tableView)
                    XCTAssertTrue(row.cell.isFirstResponder())

                    tester().tapRow(at: indexpath, in: _form?.tableView)
                    XCTAssertFalse(row.cell.isFirstResponder())
                    continue
                }
            }
        }
    }
    
    func testCellAllStatusColorAndFont() {
        let titleCommonColor = UIColor(hexString: "f8e64e")
        let titleDisabledColor = UIColor(hexString: "e6a441")
        let contentCommonColor = UIColor(hexString: "3e332a")
        let contentDisabledColor = UIColor(hexString: "8d553b")
        let titleHighColor = UIColor(hexString: "33e33e");

        let titleCommonFont =  UIFont.systemFont(ofSize: 15)
        let titleDisabledFont = UIFont.systemFont(ofSize: 16)
        let contentCommonFont = UIFont.systemFont(ofSize: 17)
        let contentDisabledFont = UIFont.systemFont(ofSize: 13)
        let titleHighFont = UIFont.systemFont(ofSize: 12)
                
        let style = RowDescriptor.Style()
        
        style.titleColor = titleCommonColor
        style.titleDisabledColor = titleDisabledColor
        style.detailColor = contentCommonColor
        style.detailDisabledColor = contentDisabledColor
        style.titleHighlightColor = titleHighColor
        
        style.titleFont = titleCommonFont
        style.titleDisabledFont = titleDisabledFont
        style.detailFont = contentCommonFont
        style.detailDisabledFont = contentDisabledFont
        style.titleHighlightFont = titleHighFont
        
        
        _form?.formDescriptor.style = style
        _form?.update()
        
        for type in kArrayOfTypes {
            if let row = _form?.row(withTag: type.rawValue), let indexpath = _form?.indexPathForRow(row) {
                tester().waitForCell(at: indexpath, in: _form?.tableView)
                let color = row.cell.titleNode.attributedText?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as! UIColor
                let font = row.cell.titleNode.attributedText?.attribute(.font, at: 0, effectiveRange: nil) as! UIFont

                XCTAssertTrue(titleCommonColor.isEqual(color))
                XCTAssertTrue(font == titleCommonFont)
            }
        }
        
        for type in textTags.filter({ $0 != .textView }) {
            if let row = _form?.row(withTag: type.rawValue) {
                _form?.ensureRowIsVisible(row)
                let cell = tester().waitForView(withAccessibilityLabel: type.rawValue)
                tester().enterText("1", into: nil, in: cell, expectedResult: nil)

                var color = row.cell.titleNode.attributedText?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as! UIColor
                var font = row.cell.titleNode.attributedText?.attribute(.font, at: 0, effectiveRange: nil) as! UIFont
                XCTAssertTrue(compareColor(left: color, right: titleHighColor))
                XCTAssertTrue(font == titleHighFont)

                if let tf = row.cell.value(forKey: "textField") as? UITextField {
                    color = tf.textColor!
                    font = tf.font!
                    XCTAssertTrue(compareColor(left: color, right: contentCommonColor))
                    XCTAssertTrue(font == contentCommonFont)

                    _form?.makeRowsDisabled(true, withTags: [type.rawValue])
                    color = tf.textColor!
                    font = tf.font!
                    XCTAssertTrue(compareColor(left: color, right: contentDisabledColor))
                    XCTAssertTrue(font == contentDisabledFont)
                }
            }
        }

        do {
            // text view
            let tag = "textView"
            if let row = _form?.row(withTag: tag) {
                let cell = tester().waitForView(withAccessibilityLabel: tag)
                tester().enterText("tttt", into: nil, in: cell, expectedResult: nil)

                var color = row.cell.titleNode.attributedText?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as! UIColor
                var font = row.cell.titleNode.attributedText?.attribute(.font, at: 0, effectiveRange: nil) as! UIFont
                XCTAssertTrue(compareColor(left: color, right: titleHighColor))
                XCTAssertTrue(font == titleHighFont)

                if let node = row.cell.value(forKey: "textViewNode") as? ASEditableTextNode {
                    color = node.textView.attributedText.attribute(.foregroundColor, at: 0, effectiveRange: nil) as! UIColor
                    font = node.textView.attributedText.attribute(.font, at: 0, effectiveRange: nil) as! UIFont
                    XCTAssertTrue(compareColor(left: color, right: contentCommonColor))
                    XCTAssertTrue(font == contentCommonFont)

                    row.isDisabled = true
                    color = node.textView.attributedText.attribute(.foregroundColor, at: 0, effectiveRange: nil) as! UIColor
                    font = node.textView.attributedText.attribute(.font, at: 0, effectiveRange: nil) as! UIFont
                    XCTAssertTrue(compareColor(left: color, right: contentDisabledColor))
                    XCTAssertTrue(font == contentDisabledFont)
                }
            }
        }


        for type in dateTags + dateInlineTags {
            let row: RowDescriptor! = _form?.row(withTag: type.rawValue)

            let indexpath = _form?.indexPathForRow(row)
            tester().tapRow(at: indexpath, in: _form?.tableView)

            var color = row.cell.titleNode.attributedText?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as! UIColor
            var font = row.cell.titleNode.attributedText?.attribute(.font, at: 0, effectiveRange: nil) as! UIFont
            XCTAssertTrue(compareColor(left: color, right: titleHighColor))
            XCTAssertTrue(font == titleHighFont)

            color = row.cell.detailNode.attributedText?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as! UIColor
            font = row.cell.detailNode.attributedText?.attribute(.font, at: 0, effectiveRange: nil) as! UIFont
            XCTAssertTrue(compareColor(left: color, right: contentCommonColor))
            XCTAssertTrue(font == contentCommonFont)

            row.isDisabled = true

            color = row.cell.detailNode.attributedText?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as! UIColor
            font = row.cell.detailNode.attributedText?.attribute(.font, at: 0, effectiveRange: nil) as! UIFont
            XCTAssertTrue(compareColor(left: color, right: contentDisabledColor))
            XCTAssertTrue(font == contentDisabledFont)
        }
        
        
        for type in selectTags.filter ({ $0 != .pushButton && $0 != .pushSelect && $0 != .multipleSelect}) {
            let row: RowDescriptor! = _form?.row(withTag: type.rawValue)
            let indexpath = _form?.indexPathForRow(row)
            tester().tapRow(at: indexpath, in: _form?.tableView)

            var color = row.cell.titleNode.attributedText?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as! UIColor
            var font = row.cell.titleNode.attributedText?.attribute(.font, at: 0, effectiveRange: nil) as! UIFont
            XCTAssertTrue(compareColor(left: color, right: titleHighColor))
            XCTAssertTrue(font == titleHighFont)

            tester().waitForView(withAccessibilityLabel: "西瓜")
            tester().tapView(withAccessibilityLabel: "西瓜")
            row.cell.resignFirstResponder()

            color = row.cell.detailNode.attributedText?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as! UIColor
            font = row.cell.detailNode.attributedText?.attribute(.font, at: 0, effectiveRange: nil) as! UIFont
            XCTAssertTrue(compareColor(left: color, right: contentCommonColor))
            XCTAssertTrue(font == contentCommonFont)

            row.isDisabled = true

            color = row.cell.detailNode.attributedText?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as! UIColor
            font = row.cell.detailNode.attributedText?.attribute(.font, at: 0, effectiveRange: nil) as! UIFont
            XCTAssertTrue(compareColor(left: color, right: contentDisabledColor))
            XCTAssertTrue(font == contentDisabledFont)
        }
        
        do {
            var row: RowDescriptor!
            
            // info
            row = _form?.row(withTag: "info")
            row.value = "info"
            row.update()
            let tf = row.cell.value(forKey: "textField") as! UITextField
            XCTAssertTrue(compareColor(left: tf.textColor!, right: contentDisabledColor))
            
            // long info
            row = _form?.row(withTag: "longInfo")
            row.value = "long info"
            row.update()
            XCTAssertTrue(compareColor(left: row.cell.detailNode.attributedText?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as! UIColor,
                                       right: contentDisabledColor))

            // counter
            row = _form?.row(withTag: "stepCounter")
            row.value = "4"
            row.update()
            XCTAssertTrue(compareColor(left: row.cell.detailNode.attributedText?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as! UIColor,
                                       right: contentCommonColor))

            // slider
            row = _form?.row(withTag: "slider")
            row.value = "1"
            row.update()
            XCTAssertTrue(compareColor(left: row.cell.detailNode.attributedText?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as! UIColor,
                                       right: contentCommonColor))
        }
        
        // all
        for type in kArrayOfTypes {
            let row: RowDescriptor! = _form?.row(withTag: type.rawValue)
            row.isDisabled = true
            let indexpath = _form?.indexPathForRow(row)!
            
            tester().waitForCell(at: indexpath, in: _form?.tableView)
            let color = row.cell.titleNode.attributedText?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as! UIColor
            let font = row.cell.titleNode.attributedText?.attribute(.font, at: 0, effectiveRange: nil) as! UIFont
            XCTAssertTrue(compareColor(left: color, right: titleDisabledColor))
            XCTAssertTrue(font == titleDisabledFont)
        }
     }
    
    func testCellTitleNodeArrtibuteString() {
        _form?.formDescriptor.addAsteriskToRequiredRow = true
        
        for type in kArrayOfTypes {
            let row = _form!.row(withTag: type.rawValue)!
            row.isRequired = true
        }
        _form?.update()
        
        for type in kArrayOfTypes {
            let row = _form!.row(withTag: type.rawValue)!
            XCTAssertTrue(row.cell.titleNode.attributedText!.string.contains("*"))
            row.isRequired = false
        }
        _form?.update()
        
        for type in kArrayOfTypes {
            let row = _form!.row(withTag: type.rawValue)!
            XCTAssertFalse(row.cell.titleNode.attributedText!.string.contains("*"))
        }
    }
    
    // MARK: - ADD / REMOVE
    
    func testJustAddSection() {
        let oldRowsAmount = 3*10
        let newRowsAmount = oldRowsAmount / 3
        var section: SectionDescriptor!
        var row: RowDescriptor!
        
        // 0, 3...27
        // 0, 1, 2...29
        for i in 0 ..< oldRowsAmount {
            section =  SectionDescriptor.init()
            row = RowDescriptor.init(withTag: "\(i)", rowType: .info, title: "\(i)")
            row.value = "\(i)"
            // 双数 hidden
            section.isHidden = i % 3 != 0; // 1，2，4，5
            section.add(row)
            _form?.add(section)
        }
        _form?.remove(at: 0) // 1，29
        
        // 0, 3..27, 30, 31...39
        // 0, 1, 2...39
        for i in 0 ..< newRowsAmount {
            let tag = oldRowsAmount + i
            section = SectionDescriptor.init(withStyle: nil)
            row = RowDescriptor.init(withTag: "\(tag)", rowType: .info, title: "\(tag)")
            row.value = "\(tag)"
            section.add(row)
            _form?.add(section)
            let index = _form?.indexOfSection(section)
            XCTAssertTrue(index == (newRowsAmount + i));
        }
        
        for i in 0 ..< oldRowsAmount {
            row = nil
            row = _form?.row(withTag: "\(i)")
            row.section?.isHidden = false
        }

        for i in 0 ..< newRowsAmount {
            row = nil
            row = _form?.row(withTag: "\(i + oldRowsAmount)")
            let index = _form!.indexOfSection(row.section!)!
            XCTAssertTrue(index == (oldRowsAmount + i))
        }
    }
    
    func testAddSectionByAfterSection() {
        let oldRowsAmount = 3*10
        let newRowsAmount = oldRowsAmount / 3
        var section: SectionDescriptor!
        var row: RowDescriptor!
        
        // 0, 3...27
        // 0, 1, 2...29
        for i in 0 ..< oldRowsAmount {
            section = SectionDescriptor.init()
            let tag = "\(i)"
            row = RowDescriptor.init(withTag: "\(i)", rowType: .info, title: "\(i)")
            row.value = tag
            
            // 双数 hidden
            section.isHidden = i % 3 != 0
            section.add(row)
            _form?.add(section)
        }
        _form?.remove(at: 0)

        // 0, 30, 3, 31...27, 39
        // 0, 1, 30, 2, 3, 4, 31, 5...
        for i in 0 ..< newRowsAmount {
            let preSection = _form?.row(withTag: "\(i*3 + 1)")?.section

            section = SectionDescriptor.init()
            let tag = "\(oldRowsAmount + i)"
            row = RowDescriptor.init(withTag: tag, rowType: .info, title: tag)
            row.value = tag
            section.add(row)
            
            _form?.add([section], after: preSection!)
            let index = _form?.indexOfSection(section)
            XCTAssertTrue(index == (i*2 + 1));
        }
        
        
        for i in 0 ..< oldRowsAmount {
            row = nil
            row = _form?.row(withTag: "\(i)")
            row.section?.isHidden = false
        }
        
        for i in 0 ..< newRowsAmount {
            row = nil
            row = _form?.row(withTag: "\(i + oldRowsAmount)")
            let index = _form?.indexOfSection(row.section!)        
            XCTAssertTrue(index! == (i*4+2));
        }
    }
    
    func testAddSectionByBeforeSection() {
        let oldRowsAmount = 3*10
        let newRowsAmount = oldRowsAmount / 3
        var section: SectionDescriptor!
        var row: RowDescriptor!
        
        // 0, 3...27
        // 0, 1, 2...29
        for i in 0 ..< oldRowsAmount {
            section = SectionDescriptor.init()
            let tag = "\(i)"
            row = RowDescriptor.init(withTag: tag, rowType: .info, title: tag)
            row.value = tag
            
            // 双数 hidden
            section.isHidden = i % 3 != 0
            section.add(row)
            _form?.add(section)
        }
        _form?.remove(at: 0)

        // 0, 30, 3, 31...27, 39
        // 0, 1, 30, 2, 3, 4, 31, 5...
        for i in 0 ..< newRowsAmount {
            let tag = "\(oldRowsAmount + i)"
            // 2, 5, 8 .. 29
            let nextSection = _form?.row(withTag: "\(i*3 + 2)")?.section
            
            // 30 .. 39
            section = SectionDescriptor.init()
            row = RowDescriptor.init(withTag: tag, rowType: .info, title: tag)
            row.value = tag
            section.add(row)
            
            _form?.add([section], before: nextSection!)
            let index = _form?.indexOfSection(section)
            XCTAssertTrue(index! == (i*2 + 1))
        }
        
        for i in 0 ..< oldRowsAmount {
            row = nil
            row = _form?.row(withTag: "\(i)")
            row.section?.isHidden = false
        }
        
        for i in 0 ..< newRowsAmount {
            row = nil
            row = _form?.row(withTag: "\(i + oldRowsAmount)")
            let index = _form?.indexOfSection(row.section!)
            XCTAssertTrue(index! == (i*4+2));
        }
    }
    
    func testAddSectionByIndex2() {
        let oldRowsAmount = 3*10
        let newRowsAmount = oldRowsAmount / 3
        var section: SectionDescriptor!
        var row: RowDescriptor!
        
        // 0, 3...27
        // 0, 1, 2...29
        for i in 0 ..< oldRowsAmount {
            let tag = "\(i)"
            
            section = SectionDescriptor.init()
            row = RowDescriptor.init(withTag: tag, rowType: .info, title: tag)
            row.value = tag
            
            section.isHidden = i % 3 != 0
            section.add(row)
            _form?.add(section)
        }
        _form?.remove(at: 0)

        // 30, 0, 31, 3...39, 27
        // 30, 0, 1, 2, 31, 3, 4, 5, 32
        for i in 0 ..< newRowsAmount {
            let tag = "\(oldRowsAmount + i)"
            
            section = SectionDescriptor.init()
            row = RowDescriptor.init(withTag: tag, rowType: .info, title: tag)
            row.value = tag
            
            section.add(row)
            _form?.insert([section], at: i*2)
            
            let index = _form?.indexOfSection(section)
            XCTAssertTrue(index! == i * 2)
        }
        
        for i in 0 ..< oldRowsAmount {
            row = nil
            row = _form?.row(withTag: "\(i)")
            row.section?.isHidden = false
        }
        
        for i in 0 ..< newRowsAmount {
            row = nil
            row = _form?.row(withTag: "\(i + oldRowsAmount)")
            let index = _form?.indexOfSection(row.section!)
            XCTAssertTrue(index! == i*4);
        }
    }
    
    func testAddSectionByIndex() {
        let oldRowsAmount = 40
        let newRowsAmount = oldRowsAmount / 2
        var section: SectionDescriptor!
        var row: RowDescriptor!
        
        // 1, 3, 5, 7
        // 0, 1, 2, 3, 4, 5
        for i in 0 ..< oldRowsAmount {
            let tag = "\(i)"
            section = SectionDescriptor.init()
            row = RowDescriptor.init(withTag: tag, rowType: .info, title: tag)
            row.value = tag
            
            section.isHidden = i % 2 == 0
            section.add(row)
            _form?.add(section)
        }
        _form?.remove(at: 0)

        // 40, 1, 41, 3, 42, 5
        // 40, 0, 1, 41, 2, 3, 42
        for i in 0 ..< newRowsAmount {
            section = SectionDescriptor.init()
            let tag = "\(i + oldRowsAmount)"
            
            row = RowDescriptor.init(withTag: tag, rowType: .info, title: tag)
            row.value = tag
            section.add(row)
            _form?.insert([section], at: i*2)
            let index = _form?.indexOfSection(section)
            XCTAssertTrue(index! == i*2);
        }
        
        for i in 0 ..< oldRowsAmount {
            row = nil
            row = _form?.row(withTag: "\(i)")
            if i % 2 == 0 {
                row.section?.isHidden = false
            }
        }

        for i in 0 ..< newRowsAmount {
            let tag = "\(i + oldRowsAmount)"
            row = nil
            row = _form?.row(withTag: tag)
            let index = _form?.indexOfSection(row.section!)
            XCTAssertTrue(index! == i*3 + 1);
        }
    }
    
    func testJustAddRow() {
        let oldRowsAmount = 3*10
        let newRowsAmount = oldRowsAmount / 3
        var section: SectionDescriptor = SectionDescriptor.init()
        var row: RowDescriptor!
        
        // 0, 3...27
        // 0, 1, 2...29
        for i in 0 ..< oldRowsAmount {
            let tag = "\(i)"
            row = RowDescriptor.init(withTag: tag, rowType: .info, title: tag)
            row.value = tag
            row.isHidden = i % 3 != 0
            section.add(row)
        }
        _form?.add(section)
        
        
        // 0, 3..27, 30, 31...39
        // 0, 1, 2...39
        for i in 0 ..< newRowsAmount {
            let tag = "\(oldRowsAmount + i)"
            row = RowDescriptor.init(withTag: tag, rowType: .info, title: tag)
            row.value = tag
            section.add(row)
            let indexpath = _form?.indexPathForRow(row)
            XCTAssertTrue(indexpath!.row == (newRowsAmount + i));
        }
        
        for i in 0 ..< oldRowsAmount {
            row = nil
            row = _form?.row(withTag: "\(i)")
            row.isHidden = false
        }
        for i in 0 ..< newRowsAmount {
            row = nil
            row = _form?.row(withTag: "\(i + oldRowsAmount)")
            let indexpath = _form?.indexPathForRow(row)
            XCTAssertTrue(indexpath!.row == (oldRowsAmount + i));
        }
    }
    
    func testAddRowByAfterRow() {
        let oldRowsAmount = 3*10
        let newRowsAmount = oldRowsAmount / 3
        let section: SectionDescriptor = SectionDescriptor.init()
        var row: RowDescriptor!
        
        for i in 0 ..< oldRowsAmount {
            let tag = "\(i)"
            row = RowDescriptor.init(withTag: tag, rowType: .info, title: tag)
            row.value = tag
            // not hidden: 0, 3...27
            row.isHidden = i % 3 != 0
            section.add(row)
        }
        _form?.add(section)
        
        for i in 0 ..< newRowsAmount {
            // 1, 4, 7...28
            let preRow = _form?.row(withTag: "\(i*3 + 1)")
            let tag = "\(oldRowsAmount + i)"
            
            row = RowDescriptor.init(withTag: tag, rowType: .info, title: tag)
            row.value = tag
            // 排序应该是：
            // 0, 30, 3, 31...27, 39
            // 0, 1, 30, 2, 3, 4, 31, 5...
            section.add([row], after: preRow!)
            let indexpath = _form?.indexPathForRow(row)
            XCTAssertTrue(indexpath!.row == (i*2 + 1));
        }

        for i in 0 ..< oldRowsAmount {
            row = nil
            row = _form?.row(withTag: "\(i)")
            row.isHidden = false
        }
        
        for i in 0 ..< newRowsAmount {
            row = nil
            row = _form?.row(withTag: "\(i + oldRowsAmount)")
            let indexpath = _form?.indexPathForRow(row!)
            XCTAssertTrue(indexpath!.row == (i*4+2));
        }
    }
    
    func testAddRowByBeforeRow() {
        let oldRowsAmount = 3*10
        let newRowsAmount = oldRowsAmount / 3
        var section: SectionDescriptor = SectionDescriptor.init()
        var row: RowDescriptor!
        
        // 0, 3...27
        // 0, 1, 2...29
        for i in 0 ..< oldRowsAmount {
            let tag = "\(i)"
            row = RowDescriptor.init(withTag: tag, rowType: .info, title: tag)
            row.value = tag
            row.isHidden = i % 3 != 0
            section.add(row)
        }
        _form?.add(section)
        
        
        // 0, 30, 3, 31...27, 39
        // 0, 1, 30, 2, 3, 4, 31, 5...
        for i in 0 ..< newRowsAmount {
            let nextrow = _form?.row(withTag: "\(i*3 + 2)")
            let tag = "\(oldRowsAmount + i)"
            
            row = RowDescriptor.init(withTag: tag, rowType: .info, title: tag)
            row.value = tag
            section.add([row], before: nextrow!)
            let indexpath = _form?.indexPathForRow(row)
            XCTAssertTrue(indexpath!.row == (i*2 + 1));
        }
        
        for i in 0 ..< oldRowsAmount {
            row = nil
            row = _form?.row(withTag: "\(i)")
            row.isHidden = false
        }
        
        for i in 0 ..< newRowsAmount {
            row = nil
            row = _form?.row(withTag: "\(i + oldRowsAmount)")
            let indexpath = _form?.indexPathForRow(row!)
            XCTAssertTrue(indexpath!.row == (i*4+2));
        }
    }
    
    func testAddRowByIndex2() {
        let oldRowsAmount = 3*10
        let newRowsAmount = oldRowsAmount / 3
        var section = SectionDescriptor.init()
        var row: RowDescriptor!
        
        // 0, 3...27
        // 0, 1, 2...29
        // 0, 3...27
        // 0, 1, 2...29
        for i in 0 ..< oldRowsAmount {
            let tag = "\(i)"
            row = RowDescriptor.init(withTag: tag, rowType: .info, title: tag)
            row.value = tag
            row.isHidden = i % 3 != 0
            section.add(row)
        }
        _form?.add(section)
        
        // 30, 0, 31, 3...39, 27
        // 30, 0, 1, 2, 31, 3, 4, 5, 32
        for i in 0 ..< newRowsAmount {
            let tag = "\(oldRowsAmount + i)"
            row = RowDescriptor.init(withTag: tag, rowType: .info, title: tag)
            row.value = tag
            section.insert([row], at: i*2)
            let indexpath = _form?.indexPathForRow(row)
            XCTAssertTrue(indexpath!.row == i*2);
        }

        
        for i in 0 ..< oldRowsAmount {
            row = nil
            row = _form?.row(withTag: "\(i)")
            row.isHidden = false
        }

        for i in 0 ..< newRowsAmount {
            row = nil
            row = _form?.row(withTag: "\(i + oldRowsAmount)")
            let indexpath = _form?.indexPathForRow(row!)
            XCTAssertTrue(indexpath!.row == i*4);
        }
    }
    
    func testAddRowByIndex() {
        let oldRowsAmount = 4*10
        let newRowsAmount = oldRowsAmount / 2
        var section = SectionDescriptor.init()
        var row: RowDescriptor!
        
        // 0, 3...27
        // 0, 1, 2...29
        // 0, 3...27
        // 0, 1, 2...29
        for i in 0 ..< oldRowsAmount {
            let tag = "\(i)"
            row = RowDescriptor.init(withTag: tag, rowType: .info, title: tag)
            row.value = tag
            row.isHidden = i % 2 == 0
            section.add(row)
        }
        _form?.add(section)
        
        // 40, 1, 41, 3, 42, 5
        // 40, 0, 1, 41, 2, 3, 42
        for i in 0 ..< newRowsAmount {
            let tag = "\(i + oldRowsAmount)"
            row = RowDescriptor.init(withTag: tag, rowType: .info, title: tag)
            row.value = tag
            section.insert([row], at: i*2)
            let indexpath = _form?.indexPathForRow(row)
            XCTAssertTrue(indexpath!.row == i*2);
        }
        
        for i in 0 ..< oldRowsAmount {
            row = nil
            row = _form?.row(withTag: "\(i)")
            if i % 2 == 0 {
                row.isHidden = false
            }
        }

        for i in 0 ..< newRowsAmount {
            let tag = "\(i + oldRowsAmount)"
            row = nil
            row = _form?.row(withTag: tag)
            let indexpath = _form?.indexPathForRow(row!)
            XCTAssertTrue(indexpath!.row == i*3 + 1)
        }
    }
    
    // MARK: -  Form
    
    func testRowAndSectionAreRemoved() {
        let section = SectionDescriptor.init()
        _form?.add(section)
        
        let row = RowDescriptor.init(withTag: "\(#function)", rowType: .info, title: nil)
        section.add(row)
        
        XCTAssertNotNil(row.section)
        XCTAssertNotNil(section.form)

        section.remove(row)
        _form?.remove(section)

        XCTAssertNil(row.section)
        XCTAssertNil(section.form)
    }
    
    func testRowsRequired() {
        _form?.formDescriptor.addAsteriskToRequiredRow = true

        let types: [RowDescriptor.RowType] = [.text, .name, .email, .integer]
        _form?.makeRowsRequired(true, withTags: types.map{t in t.rawValue})
                        
        
        for type in types {
            let row = _form?.row(withTag: type.rawValue)
            let result = row!.doValidate()
            XCTAssertFalse(result.isValid)
        }
        RunLoop.current.run(until: Date.init(timeIntervalSinceNow: TimeInterval(kWaitTimeInterval)))
    }
    
    func testRowsDisabled() {
        let types: [RowDescriptor.RowType] = [.text, .name, .email, .integer]
        _form?.makeRowsDisabled(true, withTags: types.map{t in t.rawValue})
        
        for type in types {
            _row = _form?.row(withTag: type.rawValue)
            XCTAssertFalse(_row!.cell.canBecomeFirstResponder())
        }
        RunLoop.current.run(until: Date.init(timeIntervalSinceNow: TimeInterval(kWaitTimeInterval)))
    }
    
    func testSetRowsHidden() {
        let amount = _form?.formDescriptor.formSections.first?.formRows.count
        let types: [RowDescriptor.RowType] = [.text, .name, .email, .integer]
        _form?.makeRowsHidden(true, withTags: types.map{t in t.rawValue})
        
        XCTAssertEqual(_form?.formDescriptor.formSections.first?.formRows.count ?? -1, amount! - 4)
        RunLoop.current.run(until: Date.init(timeIntervalSinceNow: TimeInterval(kWaitTimeInterval)))
    }
    
    func testFormHttpValues() {
        _row = _form?.row(withTag: "text")
        _row?.value = "test"
        _row?.isHidden = true
        
        _row = _form?.row(withTag: "multipleSelect")
        _row?.value = [OptionItem(title: "t1", value: "1"), OptionItem(title: "y2", value: "2")]
        for type in kArrayOfTypes {
            let row = _form?.row(withTag: type.rawValue)
            // 单元行 switch 和 check 在调用 update 后，会设置一个初始值。
            // 当行数量较多时，可能当前页面没有展示到，所以也就不会调用到其 update 方法
            _form?.ensureRowIsVisible(row)
            tester().waitForView(withAccessibilityLabel: type.rawValue)
        }
        
        let values = _form?.formValues
        
        for type in kArrayOfTypes {
            _row = _form?.row(withTag: type.rawValue)
            let tag = _row!.cell.parameterNameForRow() ?? _row?.tag
            let value = values![tag!]
            
            if type == .multipleSelect {
                XCTAssertTrue(value! is Array<OptionItem>)
            } else if type == .text || type == .switch_ || type == .check {
                XCTAssertNotNil(value)
            } else {
                XCTAssertNil(value)
            }
        }
        RunLoop.current.run(until: Date.init(timeIntervalSinceNow: TimeInterval(kWaitTimeInterval)))
    }
    
    // MARK: -  section
    
    func testSectionHeaderView() {
        let headerRect = _form?.tableView.rectForHeader(inSection: 0)
        let footerRect = _form?.tableView.rectForHeader(inSection: 0)
        let section = _form?.formDescriptor.section(at: 0)
        
        XCTAssertTrue(headerRect!.size.height == section!.headerHeight);
        XCTAssertTrue(footerRect!.size.height == section!.footerHeight);
    }
    
    func testSectionOptions() {
        // 在 14.0 系统下该测试无法通过，需要设置 UIApplication.shared.keyWindow?.layer.speed 属性
        // https://github.com/kif-framework/KIF/issues/1221
        let orgin = UIApplication.shared.keyWindow?.layer.speed
        UIApplication.shared.keyWindow?.layer.speed = 100
        
        var row: RowDescriptor!
        let section = SectionDescriptor.init()
        section.editStyle = .delete

        var tag: String!

        for i in 0 ..< 10 {
            tag = "\(#function)-\(i)"
            row = RowDescriptor.init(withTag: tag, rowType: .info, title: tag)
            row.cell.accessibilityLabel = tag
            section.add(row)
        }
        _form?.formDescriptor.insert(section, at: 0)

        tester().swipeView(withAccessibilityLabel: tag, in: .left)
        let cell = _form?.tableNode.cellForRow(at: IndexPath(row: 9, section: 0))
        tester().waitForDeleteState(for: cell!)
        tester().tapView(withAccessibilityLabel: "Delete")
        
        UIApplication.shared.keyWindow?.layer.speed = orgin ?? 1
        XCTAssertTrue(section.formRows.count == 9);
    }
    
    // MARK: -  row
    
    func testCellForRowIsExist() {
        let row = RowDescriptor.init(withTag: "node", rowType: .info, title: nil)
        XCTAssertFalse(row.isCellLoaded);
        
        _form?.add(row)
        XCTAssertTrue(row.isCellLoaded);
    }
    
    func testRowManualSetValue() {
        let orginValue = #function + "d"
        let row = RowDescriptor.init(withTag: #function, rowType: .info, title: #function)
        
        row.valueChangeAction = { _, value, _ in
            XCTAssertTrue(orginValue == (value as! String));
        }
        _form?.add(row)

        row.setValueToTriggerKVO(orginValue)
    }
    
    func testRowRequiredMessage() {
        let row = RowDescriptor.init(withTag: #function, rowType: .info, title: #function)
        row.isRequired = true
        row.requireMessage = "请您输入文字"
        _form?.add(row)
        
        let error = _form?.validateErrors?.first
        switch(error!) {
        case .failure(message: let msg):
            XCTAssertTrue(msg == row.requireMessage!)
        case .ok:
            break
        }
    }
    
    func testRowRequired() {
        _form?.formDescriptor.addAsteriskToRequiredRow = true
        
        let row = RowDescriptor.init(withTag: #function, rowType: .text, title: #function)
        row.isRequired = true
        _form?.add(row)
        row.update()
        
        XCTAssertTrue(row.cell.titleNode.attributedText!.string.contains("*"));
        let result = row.doValidate()
        XCTAssertFalse(result.isValid)
    }
    
    func testRowConfigDict() {
        let row = RowDescriptor.init(withTag: #function, rowType: .text, title: #function)
        let attributeStringAfterUpdate = appendInterpolation("after update", style: .color(UIColor.yellow))
        let attributeStringWhenDisabled = appendInterpolation("when disabled", style: .color(UIColor.yellow))

        row.configAfterCreate["separatorInset"] = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        row.configAfterUpdate["titleNode.attributedText"] = attributeStringAfterUpdate
        row.configAfterDisabled["titleNode.attributedText"] = attributeStringWhenDisabled
        row.cell.accessibilityLabel = #function
        _form?.add(row)
        XCTAssertTrue(row.cell.separatorInset.left == 20);

        tester().waitForView(withAccessibilityLabel: #function)
        XCTAssertTrue(row.cell.titleNode.attributedText!.string == attributeStringAfterUpdate!.string);
        
        row.isDisabled = true;
        XCTAssertTrue(row.cell.titleNode.attributedText!.string == attributeStringWhenDisabled!.string);
    }
    
    func testRowValueValidator() {
        let row = _form?.row(withTag: "email")
        row?.isRequired = true
        row?.value = "kikogamil.com"
        row?.addValidator(JRegexValidator(regex: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,11}", message: "邮箱格式错误"))
        XCTAssertFalse(row!.doValidate().isValid);
        
        row?.value = "kikido1992@gmail.com"
        XCTAssertTrue(row!.doValidate().isValid);
    }
    
    func testTypeRowMaxNumberOfCharacters() {
        let maxNumberOfCharacters = 3;
        
        var row = _form?.row(withTag: "text")
        row?.maxNumberOfCharacters = maxNumberOfCharacters
        var cell = tester().waitForView(withAccessibilityLabel: "text")
        tester().enterText("好好吃😊", into: nil, in: cell, expectedResult: "好好吃")
        tester().enterText("测试测试", into: nil, in: cell, expectedResult: "测试测")
        tester().enterText("去洗澡123", into: nil, in: cell, expectedResult: "去洗澡")

        row = _form?.row(withTag: "email")
        row?.maxNumberOfCharacters = maxNumberOfCharacters
        cell = tester().waitForView(withAccessibilityLabel: "email")
        tester().enterText("111.", into: nil, in: cell, expectedResult: "111")
        tester().enterText("1.11", into: nil, in: cell, expectedResult: "1.11")
    }
    
    func testRowUpdateCell() {
        let row = _form?.row(withTag: "text")
        row?.value = "this is test"
        row?.update()
        
        XCTAssertTrue(row!.cell.detailNode.attributedText!.string == "this is test");
        RunLoop.current.run(until: Date.init(timeIntervalSinceNow: TimeInterval(kWaitTimeInterval)))
    }
    
    func testRowManualSetHeight() {
        let targetHeight = 400.0
        let separatorHeight = 1.0 / 2.0;
        
        let row = _form?.row(withTag: "text")
        row?.height = targetHeight
        _form?.reloadSpecifiedRows([row!])
        
        let indexpath = _form?.indexPathForRow(row!)
        let frame = _form?.tableNode.rectForRow(at: indexpath!)
        XCTAssertTrue(frame!.size.height == targetHeight + separatorHeight);

        RunLoop.current.run(until: Date.init(timeIntervalSinceNow: TimeInterval(kWaitTimeInterval)))
    }
    
    func testValueChangeBlock() {
        var row: RowDescriptor!
        var expectations = [XCTestExpectation]()
        var expectation: XCTestExpectation!
        let options = [OptionItem(title: "西瓜", value: "1"), OptionItem(title: "桃子", value: "2"), OptionItem(title: "香蕉", value: "3")]

        // text
        for type in textTags {
            let tag = type.rawValue
            expectation = XCTestExpectation.init(description: tag)
            expectations.append(expectation)

            row = _form?.row(withTag: tag)
            let cell = tester().waitForView(withAccessibilityLabel: tag)

            if type != .decimal {
                row.valueChangeAction = { [weak expectation] _, newvalue, _ in
                    XCTAssertTrue(tag.lowercased() == (newvalue as! String).lowercased())
                    expectation?.fulfill()
                }
                tester().enterText(tag, into: nil, in: cell, expectedResult: nil)
            } else {
                row.valueChangeAction = { [weak expectation] _, newvalue, _ in
                    XCTAssertTrue("20" == (newvalue as! String))
                    expectation?.fulfill()
                }
                tester().enterText("20.0只能输入小数", into: nil, in: cell, expectedResult: nil)
            }
            row.cell.resignFirstResponder()
        }

        // select type
        for type in selectTags {
            if type == .pushButton { continue }

            let tag = type.rawValue
            row = _form?.row(withTag: tag)
            row.optionItmes = options

            expectation = XCTestExpectation.init(description: tag)
            expectations.append(expectation)
            row.valueChangeAction = { [weak expectation] _, newvalue, _ in
                if let newvalue = newvalue as? OptionItem {
                    XCTAssertTrue(newvalue.title == "西瓜")
                    expectation?.fulfill()
                } else if let newvalue = newvalue as? [OptionItem] {
                    XCTAssertTrue(newvalue.first!.title == "西瓜")
                    expectation?.fulfill()
                } else {
                    XCTExpectFailure()
                }
            }

//            let indexpath = _form?.indexPathForRow(row)
//            tester().tapRow(at: indexpath!, in: _form?.tableView)
            tester().tapView(withAccessibilityLabel: tag)

            if type == .pushSelect || type == .multipleSelect {
                tester().tapRow(at: IndexPath(row: 0, section: 0), inTableViewWithAccessibilityIdentifier: "tableview")
                if type == .multipleSelect {
                    tester().tapView(withAccessibilityLabel: NSLocalizedString("Form", comment: ""), traits: .button)
                }
            } else {
                tester().waitForView(withAccessibilityLabel: "西瓜")
                tester().tapView(withAccessibilityLabel: "西瓜")
                if type == .picker {
                    row.cell.resignFirstResponder()
                }
            }
        }

         // date
        /// 少了 dateInlineTags
        let dateValues = [["October", "10", "2020"], ["10", "10", "AM"], ["October 10", "10", "10", "AM"], ["10", "10"]]
        for i in 0 ..< dateTags.count {
            let type = dateTags[i]
            let tag = type.rawValue
            row = _form?.row(withTag: tag)
            expectation = XCTestExpectation.init(description: tag)
            expectations.append(expectation)
            row.valueChangeAction = { _, newvalue, _ in
                expectation.fulfill()
            }
            tester().waitForView(withAccessibilityLabel: tag)
            tester().tapView(withAccessibilityLabel: tag)
            XCTAssertTrue(row.cell.isFirstResponder())

            tester().selectDatePickerValue(dateValues[i], with: .forwardFromStart)
        }

        let otherTypes: [RowDescriptor.RowType] = [.switch_, .check, .stepCounter, .segmentedControl, .slider]
        for type in otherTypes {
            let tag = type.rawValue
            row = _form?.row(withTag: tag)
            expectation = XCTestExpectation.init(description: tag)
            expectations.append(expectation)
            row.valueChangeAction = { [weak expectation] _, newvalue, _ in
                expectation?.fulfill()
                print("次数 \(expectation?.expectedFulfillmentCount) tag: \(tag)")
            }
        }

        // switch
        var element: UIAccessibilityElement?
        var targetView: UIView?
        row = _form?.row(withTag: "switch_")
        let switchView = tester().waitForView(withAccessibilityLabel: "switch_")
        tester().wait(for: nil, view: &targetView, withLabel: nil, value: nil, traits: .button, fromRootView: switchView, tappable: true)
        tester().setSwitch(targetView as? UISwitch, element: nil, on: true)
        XCTAssertTrue(row.value as! Bool);

        // check
        row = _form?.row(withTag: "check")
        let indexpath = _form?.indexPathForRow(row)
        tester().tapRow(at: indexpath, in: _form?.tableView)
        XCTAssertTrue(row.value as! Bool)

        // step counter
        row = _form?.row(withTag: "stepCounter")
        let stepView = tester().waitForView(withAccessibilityLabel: "stepCounter")
        tester().wait(for: nil, view: &targetView, withLabel: nil, value: nil, traits: .none, fromRootView: stepView, tappable: true)
        tester().tapStepper(with: nil, increment: .increment, in: targetView!)
        XCTAssertTrue(row.value != nil)

        // segment control
        let segmentView = tester().waitForView(withAccessibilityLabel: "segmentedControl")
        tester().wait(for: &element, view: &targetView, withLabel: "西瓜", value: nil, traits: .button, fromRootView: segmentView, tappable: true)
        tester().tap(element, in: targetView!)

        // slider
        row = _form?.row(withTag: "slider")
        let sliderView = tester().waitForView(withAccessibilityLabel: "slider")
        tester().wait(for: &element, view: &targetView, withLabel: nil, value: nil, traits: .none, fromRootView: sliderView, tappable: true)
        (targetView as! UISlider).value = 0.5
        (targetView as! UISlider).sendActions(for: .valueChanged)
        XCTAssertTrue((row.value as! Float) == 0.5)
        
        wait(for: expectations, timeout: 5)
    }
    
    
    // MARK: - TODO
//    func testTextTypeRowFormatter() {
//    }
    
    //    func testRowChangeCellType() {
    //    }
    
    // MARK: -  Helper
    
    func compareColor(left: UIColor, right: UIColor) -> Bool {
        return left.cgColor == right.cgColor
    }
    
}





// MARK: - Extension

extension XCTestCase {
    func tester(file : String = #file, _ line : Int = #line) -> KIFUITestActor {
        return KIFUITestActor(inFile: file, atLine: line, delegate: self)
    }

    func system(file : String = #file, _ line : Int = #line) -> KIFSystemTestActor {
        return KIFSystemTestActor(inFile: file, atLine: line, delegate: self)
    }
}

extension KIFTestActor {
    func tester(file : String = #file, _ line : Int = #line) -> KIFUITestActor {
        return KIFUITestActor(inFile: file, atLine: line, delegate: self)
    }

    func system(file : String = #file, _ line : Int = #line) -> KIFSystemTestActor {
        return KIFSystemTestActor(inFile: file, atLine: line, delegate: self)
    }
}
