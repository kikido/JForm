//
//  JSwitchCellNode.swift
//  JForm
//
//  Created by dqh on 2021/7/20.
//

import Foundation
import AsyncDisplayKit

extension RowDescriptor.RowType {
    
    public static let switch_ = RowDescriptor.RowType(rawValue: "switch_")
}

public class JSwitchCellNode: JBaseCellNode {
    
    public let switchNode: ASDisplayNode
    @objc public var switchControl: UISwitch?
    
    public required init(with rowDescriptor: RowDescriptor) {
        switchNode = ASDisplayNode.init { UISwitch() }
        switchNode.style.preferredSize = CGSize(width: 51, height: 31)
        
        super.init(with: rowDescriptor)
    }
    
    public override func update() {
        super.update()
        
        let switchControl = switchNode.view as! UISwitch
        switchControl.backgroundColor = .white
        switchControl.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
        switchControl.isEnabled = !rowDescriptor.isDisabled
        self.switchControl = switchControl
        
        if let value = rowDescriptor.value as? Bool {
            switchControl.isOn = value
        } else {
            // set default value
            switchControl.isOn = false
            rowDescriptor.value = false
        }
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.titleNode.style.flexShrink = 1
        self.titleNode.style.flexGrow = 1

        // 水平
        var children: [ASDisplayNode]
        
        // 是否添加 image
        if rowDescriptor.imageName != nil {
            children = [self.imageNode, self.titleNode, self.switchNode]
        } else {
            children = [self.titleNode, self.switchNode]
        }
        let stack = ASStackLayoutSpec(direction: .horizontal, spacing: 20, justifyContent: .spaceBetween, alignItems: .center, children: children)
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15), child: stack)
    }
}

extension JSwitchCellNode {
    
    @objc func valueChanged(_ switchControl: UISwitch) {
        rowDescriptor.setValueToTriggerKVO(switchControl.isOn)
    }
}
