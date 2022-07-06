//
//  JDateCellNode.swift
//  JForm
//
//  Created by dqh on 2021/7/20.
//

import Foundation
import AsyncDisplayKit
import UIKit

extension RowDescriptor.RowType {
    
    public static let date = RowDescriptor.RowType(rawValue: "date")

    public static let time = RowDescriptor.RowType(rawValue: "time")

    public static let dateTime = RowDescriptor.RowType(rawValue: "dateTime")

    public static let countDownTimer = RowDescriptor.RowType(rawValue: "countDownTimer")
}

public class JDateCellNode: JBaseCellNode {
    
    // 用来触发键盘
    private let triggerNode: ASEditableTextNode

    @objc public var minimumDate: Date?
    @objc public var maximumDate: Date?
    @objc public var locale: Locale?
    @objc public dynamic var minuteInterval: Int = 1
    
    @objc public lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        return datePicker
    }()
    
    public required init(with rowDescriptor: RowDescriptor) {
        triggerNode = ASEditableTextNode()
        triggerNode.scrollEnabled = false
        triggerNode.style.preferredSize = CGSize(width: 0.01, height: 0.01)
        
        super.init(with: rowDescriptor)
        triggerNode.delegate = self
    }
    
    public override func update() {
        super.update()
        triggerNode.isUserInteractionEnabled = !rowDescriptor.isDisabled
    }
    
    public override var laysOutHorizontally: Bool {
        return true
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.titleNode.style.flexShrink = 2
        
        self.detailNode.style.flexGrow = 1
        self.detailNode.style.flexShrink = 3
        self.detailNode.style.spacingBefore = 10
    
        self.triggerNode.style.spacingBefore = -10
        
        // 水平
        var children: [ASDisplayNode]
        
        // 是否添加 image
        if rowDescriptor.imageName != nil {
            children = [self.imageNode, self.titleNode, self.detailNode, self.triggerNode]
        } else {
            children = [self.titleNode, self.detailNode, self.triggerNode]
        }

        let stack = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .start, alignItems: .center, children: children)
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 20, left: 15, bottom: 20, right: 15), child: stack)
    }
}

extension JDateCellNode {
    
    public override var valueDetail: NSAttributedString? {
        var detail: String?
        var isNeedPlaceholder = false
        
        // placeholder
        if let placeholder = placeholder {
            detail = placeholder
            isNeedPlaceholder = true
        }
        
        // 有值(可能为空)
        if !isNeedPlaceholder, let value = rowDescriptor.value as? Date {
            if let valueTransformer = rowDescriptor.valueTransformer {
                guard let transformedValue = valueTransformer.transformedValue(value) else { return nil }
                detail = String(describing: transformedValue)
            }
            else if rowDescriptor.type == .countDownTimer {
                let calendar = Calendar.current
                let comps = calendar.dateComponents([.hour, .minute], from: value)
                detail = "\(comps.hour!) \(comps.hour! > 1 ? "hours" : "hour")" + " " + "\(comps.minute!) min"
            }
            else {
                detail =  formatter?.string(from: value)
            }
        }
        return appendInterpolation(detail ?? "", style: .color(isNeedPlaceholder ? self.placeholderColor : self.detailColor), .font(isNeedPlaceholder ? self.placeholderFont : self.detailFont), .alignment(laysOutHorizontally ? .right : .left))
    }
    
    var formatter: DateFormatter? {
        let dateFormatter = DateFormatter()
        
        switch rowDescriptor.type {
        case .date:
            dateFormatter.dateFormat = "yyyy-MM-dd"
        case .time:
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
        case .dateTime:
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
        default:
            break
        }
        return dateFormatter
    }
    
    var datePickerMode: UIDatePicker.Mode {
        switch rowDescriptor.type {
        case .date:
            return .date
        case .time:
            return .time
        case .dateTime:
            return .dateAndTime
        case .countDownTimer:
            return .countDownTimer
        default:
            return .date
        }
    }
    
    @objc func datePickerValueChanged(_ datePicker: UIDatePicker) {
        rowDescriptor.setValueToTriggerKVO(datePicker.date)
    }
}

// MARK: - First Responder

extension JDateCellNode {
    
    public override func becomeFirstResponder() -> Bool {
        return triggerNode.becomeFirstResponder()
    }

    public override func isFirstResponder() -> Bool {
        return triggerNode.isFirstResponder()
    }

    public override func canResignFirstResponder() -> Bool {
        return triggerNode.canResignFirstResponder()
    }

    public override func resignFirstResponder() -> Bool {
        return triggerNode.resignFirstResponder()
    }
}

extension JDateCellNode: ASEditableTextNodeDelegate {
    
    public func editableTextNodeShouldBeginEditing(_ editableTextNode: ASEditableTextNode) -> Bool {
        let status = !rowDescriptor.isDisabled
      
        if status {
            // 设置 inputView
            if editableTextNode.textView.inputView != datePicker {
                // config date picker
                datePicker.datePickerMode = datePickerMode
                datePicker.minimumDate = minimumDate
                datePicker.maximumDate = maximumDate
                datePicker.minuteInterval = minuteInterval
                datePicker.locale = locale
                
                // 将 value 与 UIDatePicker 的 date 同步
                if let value = rowDescriptor.value as? Date {
                    if value.compare(datePicker.date) != .orderedSame {
                        datePicker.date = value
                        datePicker.sendActions(for: .valueChanged)
                    }
                }
                editableTextNode.textView.inputView = datePicker
            }
            // 设置初始值
            if (rowDescriptor.value as? Date) == nil {
                if rowDescriptor.type == .countDownTimer {
                    let calendar = Calendar.current
                    var comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
                    comps.setValue(1, for: .minute)
                    comps.setValue(0, for: .hour)
                    datePicker.date =  calendar.date(from: comps) ?? Date()
                }
                datePicker.sendActions(for: .valueChanged)
            }
        }
        return status
    }

    public func editableTextNodeDidBeginEditing(_ editableTextNode: ASEditableTextNode) {
        closeForm?.rowDidBeginEditing(rowDescriptor, textField: nil, textView: editableTextNode.textView)
    }

    public func editableTextNodeDidFinishEditing(_ editableTextNode: ASEditableTextNode) {
        closeForm?.rowDidEndEditing(rowDescriptor, textField: nil, textView: editableTextNode.textView)
    }
}
