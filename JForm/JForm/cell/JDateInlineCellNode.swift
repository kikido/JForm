//
//  JDateInlineCellNode.swift
//  JForm
//
//  Created by dqh on 2021/7/20.
//

import Foundation
import AsyncDisplayKit

extension RowDescriptor.RowType {
    
    public static let dateInline = RowDescriptor.RowType(rawValue: "dateInline")

    public static let timeInline = RowDescriptor.RowType(rawValue: "timeInline")

    public static let dateTimeInline = RowDescriptor.RowType(rawValue: "dateTimeInline")

    public static let countDownTimerInline = RowDescriptor.RowType(rawValue: "countDownTimerInline")
    
    internal static let _dateInline = RowDescriptor.RowType(rawValue: "_dateInline")
}

public class JDateInlineCellNode: JBaseCellNode {
    
    @objc public var minimumDate: Date?
    @objc public var maximumDate: Date?
    @objc public var locale: Locale?
    @objc public dynamic var minuteInterval: Int = 1

    private var toRow: RowDescriptor?
    
    public override var laysOutHorizontally: Bool {
        return true
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.titleNode.style.flexShrink = 2
        
        self.detailNode.style.flexGrow = 1
        self.detailNode.style.flexShrink = 3
        self.detailNode.style.spacingBefore = 10
        
        // 水平
        var children: [ASDisplayNode]
        
        // 是否添加 image
        if isNeedImageNode {
            children = [self.imageNode, self.titleNode, self.detailNode]
        } else {
            children = [self.titleNode, self.detailNode]
        }
    
        let stack = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .start, alignItems: .center, children: children)
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 20, left: 15, bottom: 20, right: 15), child: stack)
    }
    
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
            } else if rowDescriptor.type == .countDownTimerInline {
                let calendar = Calendar.current
                let comps = calendar.dateComponents([.hour, .minute], from: value)
                detail = "\(comps.hour!) \(comps.hour! > 1 ? "hours" : "hour")" + " " + "\(comps.minute!) min"
            } else {
                detail =  formatter?.string(from: value)
            }
        }
        return appendInterpolation(detail ?? "", style: .color(isNeedPlaceholder ? self.placeholderColor : self.detailColor), .font(isNeedPlaceholder ? self.placeholderFont : self.detailFont), .alignment(laysOutHorizontally ? .right : .left))
    }
}

extension JDateInlineCellNode {
    
    func showInlineCell() {
        if toRow != nil {
            return
        }
        let inlineRow = RowDescriptor.init(withTag: "\(Date.init())", rowType: JForm.inlineRowTypesForRowTypes[rowDescriptor.type]!, title: nil)
        toRow = inlineRow
        
        if let inlineCell = inlineRow.cell as? _JDateInlineCellNode {
            inlineCell.fromRow = rowDescriptor
            inlineCell.update()

            self.closeForm?.add([inlineRow], after: rowDescriptor)
            becomeHighlight()
        }
    }
    
    func hideInlineCell() {
        if let toRow = toRow {
            DispatchQueue.main.async {
                self.closeForm?.remove(toRow)
                self.toRow = nil
            }
        }
        resignHighlight()
    }
    
    var formatter: DateFormatter? {
        let dateFormatter = DateFormatter()
        
        switch rowDescriptor.type {
        case .dateInline:
            dateFormatter.dateFormat = "yyyy-MM-dd"
        case .timeInline:
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
        case .dateTimeInline:
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
        default:
            break
        }
        return dateFormatter
    }
}

// MARK: - Responder

extension JDateInlineCellNode {
        
    public override func canBecomeFirstResponder() -> Bool {
        let status = super.canBecomeFirstResponder() && !isFirstResponder()
        if !status {
            _ = resignFirstResponder()
        }
        return status
    }
    
    public override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        showInlineCell()
        
        return true
    }
    
    public override func isFirstResponder() -> Bool {
        return self.view.isFirstResponder
    }
    
    public override func canResignFirstResponder() -> Bool {
        return true
    }
    
    public override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        hideInlineCell()

        return true
    }
}

// MARK: - Inline cell

class _JDateInlineCellNode: JBaseCellNode {
    
    let datePickerNode: ASDisplayNode
    fileprivate var fromRow: RowDescriptor?
    
    public required init(with rowDescriptor: RowDescriptor) {
        datePickerNode = ASDisplayNode.init { UIDatePicker() }
        datePickerNode.style.height = ASDimensionMake(216)
        
        super.init(with: rowDescriptor)
    }
    
    override func update() {
        super.update()
        
        // config date picker
        let datePicker = datePickerNode.view as! UIDatePicker
        datePicker.backgroundColor = UIColor.white
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        datePicker.datePickerMode = datePickerMode
        
        if let fromCell = fromRow?.cell as? JDateInlineCellNode {
            datePicker.minimumDate = fromCell.minimumDate
            datePicker.maximumDate = fromCell.maximumDate
            datePicker.locale = fromCell.locale
            datePicker.minuteInterval = fromCell.minuteInterval
        }
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }

        // set value
        if let date = rowDescriptor.value as? Date {
            if date.compare(datePicker.date) != .orderedSame {
                datePicker.setDate(date, animated: false)
                datePicker.sendActions(for: .valueChanged)
            }
        } else {
            if fromRow?.type == .countDownTimerInline {
                let calendar = Calendar.current
                var comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
                comps.setValue(1, for: .minute)
                comps.setValue(0, for: .hour)
                datePicker.date =  calendar.date(from: comps) ?? Date()
            }
            datePicker.sendActions(for: .valueChanged)
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 12, left: 15, bottom: 12, right: 15), child: self.datePickerNode)
    }
    
    
    @objc func datePickerValueChanged(_ datePicker: UIDatePicker) {
        fromRow?.setValueToTriggerKVO(datePicker.date)
    }
}

extension _JDateInlineCellNode {
    
    var datePickerMode: UIDatePicker.Mode {
        guard let row = fromRow else { return .date }
        
        switch row.type {
        case .dateInline:
            return .date
        case .timeInline:
            return .time
        case .dateTimeInline:
            return .dateAndTime
        case .countDownTimerInline:
            return .countDownTimer
        default:
            return .date
        }
    }
}

