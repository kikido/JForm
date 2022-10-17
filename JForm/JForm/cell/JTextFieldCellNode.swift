//
//  JTextFieldCellNode.swift
//  JForm
//
//  Created by dqh on 2021/7/20.
//

import Foundation
import AsyncDisplayKit

extension RowDescriptor.RowType {
    
    public static let text = RowDescriptor.RowType(rawValue: "text")
    
    public static let name = RowDescriptor.RowType(rawValue: "name")
    
    public static let email = RowDescriptor.RowType(rawValue: "email")

    public static let decimal = RowDescriptor.RowType(rawValue: "decimal")

    public static let integer = RowDescriptor.RowType(rawValue: "integer")

    public static let password = RowDescriptor.RowType(rawValue: "password")

    public static let phone = RowDescriptor.RowType(rawValue: "phone")

    public static let url = RowDescriptor.RowType(rawValue: "url")

    public static let info = RowDescriptor.RowType(rawValue: "info")
}

public class JTextFieldCellNode: JBaseCellNode {
    
    public let textFieldNode: ASDisplayNode
    @objc public var textField: UITextField?
        
    public required init(with rowDescriptor: RowDescriptor) {
        textFieldNode = ASDisplayNode.init { UITextField() }
        super.init(with: rowDescriptor)
    }
    
    public override func update() {
        super.update()
        
        let textField = textFieldNode.view as! UITextField
        self.textField = textField
        
        textField.delegate = self
        textField.clearButtonMode = .whileEditing
        textField.isEnabled = self.isTextFieldEnabled
        textField.font = rowDescriptor.type == .info ? rowDescriptor.detailDisabledFont : self.detailFont
        textField.textColor = rowDescriptor.type == .info ? rowDescriptor.detailDisabledColor : self.detailColor
        textField.textAlignment = laysOutHorizontally ? .right : .left
        textField.text = valueDetail?.string
        textField.keyboardType = self.keyboardType
        textField.isSecureTextEntry = rowDescriptor.type == .password
        textField.returnKeyType = .done
        
        if let placeholder = placeholder, rowDescriptor.type != .info {
            textField.attributedPlaceholder = appendInterpolation(placeholder, style: .font(self.placeholderFont), .color(self.placeholderColor))
        }
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        var stack: ASStackLayoutSpec!
        
        if laysOutHorizontally {
            // 水平
            self.titleNode.style.flexShrink = 2
            
            self.textFieldNode.style.flexGrow = 1
            self.textFieldNode.style.flexShrink = 3
            self.textFieldNode.style.height = ASDimensionMake(cellTextfieldHeight)

            var children: [ASDisplayNode]!
            
            // 是否添加 image
            if isNeedImageNode {
                children = [self.imageNode, self.titleNode, self.textFieldNode]
            } else {
                children = [self.titleNode, self.textFieldNode]
            }
                
            // 是否添加 unit
            if rowDescriptor.unit != nil {
                self.unitNode.style.spacingBefore = -15
                children.append(self.unitNode)
            }
            stack = ASStackLayoutSpec(direction: .horizontal, spacing: 20, justifyContent: .start, alignItems: .center, children: children)
        }
        else {
            // 垂直
            self.titleNode.style.flexShrink = 1
            self.titleNode.style.flexGrow = 1
            
            self.textFieldNode.style.height = ASDimensionMake(cellTextfieldHeight)

            var topStack: ASStackLayoutSpec!
            
            // 是否添加 image
            if isNeedImageNode {
                topStack = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .start, alignItems: .center, children: [self.imageNode, self.titleNode])
            } else {
                topStack = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .start, alignItems: .start, children: [self.titleNode])
            }
            topStack.style.flexGrow = 1
            
            stack = ASStackLayoutSpec(direction: .vertical, spacing: 15, justifyContent: .start, alignItems: .stretch, children: [topStack, self.textFieldNode])
        }
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15), child: stack)
    }
    
    public override var valueDetail: NSAttributedString? {
        var detail: String?

        if let value = rowDescriptor.value {
            if let valueTransformer = rowDescriptor.valueTransformer {
                guard let transformedValue = valueTransformer.transformedValue(value) else { return nil }
                detail = String(describing: transformedValue)
            } else {
                detail = String(describing: value)
            }
        }
        guard let detail = detail else { return nil }
        // 这里不需要样式
        return NSAttributedString(string: detail)
    }
}

fileprivate extension JTextFieldCellNode {
    
    var isTextFieldEnabled: Bool {
        if rowDescriptor.isDisabled || rowDescriptor.type == .info {
            return false
        }
        return true
    }
    
    var keyboardType: UIKeyboardType {
        switch rowDescriptor.type {
        case .email:
            return .emailAddress
        case .integer:
            return .numberPad
        case .phone:
            return .phonePad
        case .decimal:
            return .decimalPad
        case .url:
            return .URL
        default:
            return .default
        }
    }
}

// MARK: - First Response

extension JTextFieldCellNode {
    
    public override func canBecomeFirstResponder() -> Bool {
        if !isTextFieldEnabled {
            return false
        }
        return super.canBecomeFirstResponder() && (textField?.canBecomeFirstResponder ?? false)
    }

    public override func becomeFirstResponder() -> Bool {
        return textField?.becomeFirstResponder() ?? false
    }
    
    public override func isFirstResponder() -> Bool {
        return textField?.isFirstResponder ?? false
    }
    
    public override func canResignFirstResponder() -> Bool {
        return textField?.canResignFirstResponder ?? false
    }
    
    public override func resignFirstResponder() -> Bool {
        return textField?.resignFirstResponder() ?? false
    }
}

// MARK: - UITextFieldDelegate

extension JTextFieldCellNode: UITextFieldDelegate {
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return closeForm?.rowShouldBeginEditing(rowDescriptor, textField: textField, textView: nil) ?? false
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        closeForm?.rowDidBeginEditing(rowDescriptor, textField: textField, textView: nil)
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return closeForm?.row(rowDescriptor, textField: textField, textView: nil, shouldChangeCharactersIn: range, replacementString: string) ?? false
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        closeForm?.rowDidEndEditing(rowDescriptor, textField: textField, textView: nil)
        
        if let valueTransformer = rowDescriptor.valueTransformer {
            rowDescriptor.setValueToTriggerKVO(valueTransformer.reverseTransformedValue(textField.text))
        }
        else if rowDescriptor.type == .decimal, let text = textField.text { // decimal 时特殊处理
            let decimal = Decimal.init(string: text, locale: Locale.current)
            let value = decimal != nil ? "\(decimal!)" : nil
            rowDescriptor.setValueToTriggerKVO(value)
        }
        else {
            rowDescriptor.setValueToTriggerKVO(textField.text)
        }
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
