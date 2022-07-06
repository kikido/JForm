//
//  JTextViewCellNode.swift
//  JForm
//
//  Created by dqh on 2021/7/20.
//

import Foundation
import AsyncDisplayKit

extension RowDescriptor.RowType {
    
    public static let textView = RowDescriptor.RowType(rawValue: "textView")
}

public class JTextViewCellNode: JBaseCellNode {
    
    @objc public let textViewNode: ASEditableTextNode
    public var textView: UITextView?
        
    public required init(with rowDescriptor: RowDescriptor) {
        textViewNode = ASEditableTextNode()
        super.init(with: rowDescriptor)
    }
    
    public override func config() {
        super.config()
        
        textViewNode.delegate = self
        textViewNode.scrollEnabled = false
        textViewNode.autocorrectionType = .no
    }
    
    public override func update() {
        super.update()

        textViewNode.isUserInteractionEnabled = !rowDescriptor.isDisabled
        textViewNode.attributedText = valueDetail

        let textView = textViewNode.textView
        self.textView = textView
        textView.textColor = detailColor
        textView.font = detailFont
        
        if let placeholder = placeholder {
            textViewNode.attributedPlaceholderText = appendInterpolation(placeholder, style: .font(self.placeholderFont), .color(self.placeholderColor), .alignment(laysOutHorizontally ? .right : .left))
        }
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.titleNode.style.flexShrink = 2
        
        self.textViewNode.style.flexShrink = 3
        self.textViewNode.style.flexGrow = 1
        self.textViewNode.style.height = ASDimensionMake(cellTextViewHeight)
        
        var stack: ASStackLayoutSpec!
        
        if laysOutHorizontally {
            // 水平
            var children: [ASDisplayNode]
            
            // 是否添加 image
            if rowDescriptor.imageName != nil {
                children = [self.imageNode, self.titleNode, self.textViewNode]
            } else {
                children = [self.titleNode, self.textViewNode]
            }
            
            stack = ASStackLayoutSpec(direction: .horizontal, spacing: 20, justifyContent: .start, alignItems: .start, children: children)
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
            
            stack = ASStackLayoutSpec(direction: . vertical, spacing: 15, justifyContent: .start, alignItems: .stretch, children: [topStack, self.textViewNode])
        }
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 12, left: 15, bottom: 12, right: 15), child: stack)
    }
    
    public override func becomeHighlight() {
        super.becomeHighlight()
        textViewNode.scrollEnabled = true
    }
    
    public override func resignHighlight() {
        super.resignHighlight()
        textViewNode.scrollEnabled = false
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
        return appendInterpolation(detail, style: .font(self.detailFont), .color(self.detailColor))
    }
}

// MARK: - First Responder

extension JTextViewCellNode {
    
    public override func becomeFirstResponder() -> Bool {
        return textView?.becomeFirstResponder() ?? false
    }
    
    public override func isFirstResponder() -> Bool {
        return textView?.isFirstResponder ?? false
    }
    
    public override func canResignFirstResponder() -> Bool {
        return textView?.canResignFirstResponder ?? false
    }
    
    public override func resignFirstResponder() -> Bool {
        return textView?.resignFirstResponder() ?? false
    }
}

// MARK: - ASEditableTextNodeDelegate

extension JTextViewCellNode: ASEditableTextNodeDelegate {
    
    public func editableTextNodeShouldBeginEditing(_ editableTextNode: ASEditableTextNode) -> Bool {
        return closeForm?.rowShouldBeginEditing(rowDescriptor, textField: nil, textView: editableTextNode.textView) ?? false
    }
    
    public func editableTextNodeDidBeginEditing(_ editableTextNode: ASEditableTextNode) {
        closeForm?.rowDidBeginEditing(rowDescriptor, textField: nil, textView: editableTextNode.textView)
    }
    
    public func editableTextNode(_ editableTextNode: ASEditableTextNode, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return closeForm?.row(rowDescriptor, textField: nil, textView: editableTextNode.textView, shouldChangeCharactersIn: range, replacementString: text) ?? false
    }
    
    public func editableTextNodeDidFinishEditing(_ editableTextNode: ASEditableTextNode) {
        closeForm?.rowDidEndEditing(rowDescriptor, textField: nil, textView: editableTextNode.textView)
        
        if let valueTransformer = rowDescriptor.valueTransformer {
            rowDescriptor.setValueToTriggerKVO(valueTransformer.reverseTransformedValue(editableTextNode.textView.text))
        } else {
            rowDescriptor.setValueToTriggerKVO(editableTextNode.textView.text)
        }
    }
}

