//
//  JCheckCellNode.swift
//  JForm
//
//  Created by dqh on 2021/7/20.
//

import Foundation
import AsyncDisplayKit

extension RowDescriptor.RowType {
    
    public static let check = RowDescriptor.RowType(rawValue: "check")
}

public class JCheckCellNode: JBaseCellNode {
    
    @objc public let checkNode: ASImageNode
    
    required init(with rowDescriptor: RowDescriptor) {
        checkNode = ASImageNode()
        checkNode.image = UIImage.imageInBundle(named: "jt_mark")
        super.init(with: rowDescriptor)
    }
    
    public override func update() {
        super.update()
        
        if let value = rowDescriptor.value as? Bool {
            if value {
                checkNode.isHidden = false
            } else {
                checkNode.isHidden = true
            }
        } else {
            // set default value
            checkNode.isHidden = false
            rowDescriptor.value = false
        }
    }
    
    public override func rowDidSelected() {
        if let value = rowDescriptor.value as? Bool, !rowDescriptor.isDisabled {
            if value {
                rowDescriptor.setValueToTriggerKVO(false)
            } else {
                rowDescriptor.setValueToTriggerKVO(true)
            }
        }
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.titleNode.style.flexShrink = 1
        self.titleNode.style.flexGrow = 1
        
        // 水平
        var children: [ASDisplayNode]
        
        // 是否添加 image
        if rowDescriptor.imageName != nil {
            children = [self.imageNode, self.titleNode, self.checkNode]
        } else {
            children = [self.titleNode, self.checkNode]
        }
        let stack = ASStackLayoutSpec(direction: .horizontal, spacing: 20, justifyContent: .spaceBetween, alignItems: .center, children: children)
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15), child: stack)
    }
}
