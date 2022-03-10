//
//  JSelectCellNode.swift
//  JForm
//
//  Created by dqh on 2021/7/20.
//

import Foundation
import AsyncDisplayKit

extension RowDescriptor.RowType {
    
    public static let pushSelect = RowDescriptor.RowType(rawValue: "pushSelect")

    public static let multipleSelect = RowDescriptor.RowType(rawValue: "multipleSelect")

    public static let sheet = RowDescriptor.RowType(rawValue: "sheet")

    public static let alert = RowDescriptor.RowType(rawValue: "alert")
    
    public static let picker = RowDescriptor.RowType(rawValue: "picker")

    public static let pushButton = RowDescriptor.RowType(rawValue: "pushButton")
}

public class JSelectCellNode: JBaseCellNode {

    // 用来触发键盘 
    private let triggerNode: ASEditableTextNode
    private var alertController: UIAlertController?
    
    @objc public let accessoryNode: ASImageNode
    
    @objc public lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView.init()
        pickerView.delegate = self
        pickerView.dataSource = self
        
        if let currentValue = rowDescriptor.value as? OptionItem, let items = rowDescriptor.optionItmes {
            if let index = items.firstIndex(of: currentValue), index != NSNotFound {
                pickerView.selectRow(index, inComponent: 0, animated: false)
            }
        }
        return  pickerView
    }()
    
    required init(with rowDescriptor: RowDescriptor) {
        triggerNode = ASEditableTextNode()
        
        accessoryNode = ASImageNode()
        accessoryNode.image = UIImage(named: "jt_cell_disclosureIndicator")
        
        super.init(with: rowDescriptor)
    }
    
    public override func update() {
        super.update()
        
        if rowDescriptor.type == .picker {
            triggerNode.delegate = self
            triggerNode.scrollEnabled = false
            triggerNode.style.preferredSize = CGSize(width: 0.01, height: 0.01)
            triggerNode.textView.inputView = customInputView()
        }
        triggerNode.isUserInteractionEnabled = rowDescriptor.type == .picker && !rowDescriptor.isDisabled
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.titleNode.style.flexShrink = 2
        
        self.detailNode.style.flexGrow = 1
        self.detailNode.style.flexShrink = 3
        
        self.triggerNode.style.spacingBefore = -10
    
        var stack: ASStackLayoutSpec!

        if laysOutHorizontally {
            // 水平
            self.detailNode.style.spacingBefore = 10

            var children: [ASDisplayNode]
            // 是否添加 image
            if rowDescriptor.imageName != nil {
                children = [self.imageNode, self.titleNode, self.detailNode, self.accessoryNode, self.triggerNode]
            } else {
                children = [self.titleNode, self.detailNode, self.accessoryNode, self.triggerNode]
            }
            
            stack = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .start, alignItems: .center, children: children)
            stack.style.minHeight = ASDimensionMake(30)
        } else {
            // 垂直
            var topStack: ASStackLayoutSpec!
            
            // 是否添加 image
            if rowDescriptor.imageName != nil {
                topStack = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .start, alignItems: .center, children: [self.imageNode, self.titleNode])
            } else {
                topStack = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .start, alignItems: .start, children: [self.titleNode])
            }
            topStack.style.flexGrow = 1
            
            let botStack = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .start, alignItems: .center, children: [self.detailNode, self.accessoryNode, self.triggerNode])
            
            stack = ASStackLayoutSpec(direction: .vertical, spacing: 15, justifyContent: .start, alignItems: .stretch, children: [topStack, botStack])
        }
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15), child: stack)
    }
        
    public override func rowDidSelected() {
        switch rowDescriptor.type {
        case .pushSelect, .multipleSelect:
            let vc = JSelectViewController(row: rowDescriptor, form: self.closeForm)
            self.closestViewController?.navigationController?.pushViewController(vc, animated: true)
        case .sheet, .alert:
            showAlertController()
            becomeHighlight()
        case .picker:
            break
        default:
            rowDescriptor.action?(rowDescriptor)
        }
    }
    
    private func showAlertController() {
        if alertController != nil {
            return
        }
        let vc = UIAlertController(title: rowDescriptor.selectorTitle,
                                   message: nil,
                                   preferredStyle: rowDescriptor.type == .sheet ? .actionSheet : .alert)
        vc.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { [weak self] _ in
            self?.hideAlertController()
            self?.resignHighlight()
        }))
        if let items = rowDescriptor.optionItmes {
            items.forEach { item in
                vc.addAction(UIAlertAction(title: item.title, style: .default, handler: { [weak self] _ in
                    guard let self = self else { return }
                    let row = self.rowDescriptor
                    
                    self.hideAlertController()
                    
                    if let valueTransformer = row.valueTransformer {
                        row.setValueToTriggerKVO(valueTransformer.reverseTransformedValue(item))
                    } else {
                        row.setValueToTriggerKVO(item)
                    }
                }))
            }
            DispatchQueue.main.async {
                self.closestViewController?.present(vc, animated: true, completion: nil)
            }
        }
        alertController = vc
    }
    
    private func hideAlertController() {
        alertController?.dismiss(animated: true, completion: nil)
        alertController = nil
    }
    
    func customInputView() -> UIView? {
        return rowDescriptor.type == .picker ? pickerView : nil
    }
}

// MARK: - First Responder

extension JSelectCellNode {
    
    public override func canBecomeFirstResponder() -> Bool {
        if rowDescriptor.type == .picker  {
            return super.canBecomeFirstResponder()
        }
        return false
    }
    
    public override func becomeFirstResponder() -> Bool {
        if rowDescriptor.type == .picker {
            return triggerNode.becomeFirstResponder()
        }
        return false
    }
    
    public override func isFirstResponder() -> Bool {
        if rowDescriptor.type == .picker {
            return triggerNode.isFirstResponder()
        } else if rowDescriptor.type == .sheet || rowDescriptor.type == .alert {
            return alertController != nil
        } else {
            return false
        }
    }
    
    public override func canResignFirstResponder() -> Bool {
        if rowDescriptor.type == .picker || rowDescriptor.type == .sheet || rowDescriptor.type == .alert {
            return true
        }
        return false
    }
    
    public override func resignFirstResponder() -> Bool {
        if rowDescriptor.type == .picker {
            return triggerNode.resignFirstResponder()
        } else if rowDescriptor.type == .sheet || rowDescriptor.type == .alert {
            hideAlertController()
            return true
        } else {
            return true
        }
    }
}

// MARK: - UIPickerViewDataSource

extension JSelectCellNode: UIPickerViewDelegate {
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let items = rowDescriptor.optionItmes {
            return items[row].title
        }
        return nil
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let items = rowDescriptor.optionItmes {
            if let valueTransformer = rowDescriptor.valueTransformer {
                rowDescriptor.setValueToTriggerKVO(valueTransformer.reverseTransformedValue(items[row]))
            }
            else {
                rowDescriptor.setValueToTriggerKVO(items[row])
            }
        }
    }
}

// MARK: - UIPickerViewDataSource

extension JSelectCellNode: UIPickerViewDataSource {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return rowDescriptor.optionItmes?.count ?? 0
    }
}

extension JSelectCellNode: ASEditableTextNodeDelegate {
    
    public func editableTextNodeShouldBeginEditing(_ editableTextNode: ASEditableTextNode) -> Bool {
        if rowDescriptor.type == .picker {
            if rowDescriptor.isValueEmpty() && rowDescriptor.optionItmes?.count != 0 {
                rowDescriptor.setValueToTriggerKVO(rowDescriptor.optionItmes?.first)
            }
            return true
        }
        return false
    }
    
    public func editableTextNodeDidBeginEditing(_ editableTextNode: ASEditableTextNode) {
        closeForm?.rowDidBeginEditing(rowDescriptor, textField: nil, textView: editableTextNode.textView)
    }
    
    public func editableTextNodeDidFinishEditing(_ editableTextNode: ASEditableTextNode) {
        closeForm?.rowDidEndEditing(rowDescriptor, textField: nil, textView: editableTextNode.textView)
    }
}
