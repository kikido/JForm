//
//  JStepCounterCellNode.swift
//  JForm
//
//  Created by dqh on 2021/7/20.
//

import Foundation
import AsyncDisplayKit

extension RowDescriptor.RowType {
    
    public static let stepCounter = RowDescriptor.RowType(rawValue: "stepCounter")
}

public class JStepCounterCellNode: JBaseCellNode {
    
    public let stepNode: ASDisplayNode
    @objc public var stepper: UIStepper?
    
    @objc public dynamic var minimumValue: Double = 0
    @objc public dynamic var maximumValue: Double = 100
    @objc public dynamic var stepValue: Double = 1
        
    required init(with rowDescriptor: RowDescriptor) {
        stepNode = ASDisplayNode.init { UIStepper() }
        stepNode.style.preferredSize = CGSize(width: 80, height: 40)
        
        super.init(with: rowDescriptor)
    }
    
    public override func update() {
        super.update()
        
        let stepControl = stepNode.view as! UIStepper
        stepControl.backgroundColor = .clear
        stepControl.minimumValue = minimumValue
        stepControl.maximumValue = maximumValue
        stepControl.stepValue = stepValue
        stepControl.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
        stepper = stepControl
        
        if let value = rowDescriptor.value as? Double, value != stepControl.value {
            stepControl.value = value
            stepControl.sendActions(for: .valueChanged)
        }
    }
    
    public override var laysOutHorizontally: Bool {
        return true
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.detailNode.style.flexGrow = 1
        self.detailNode.style.flexShrink = 3
        self.detailNode.style.spacingBefore = 10
        
        self.titleNode.style.flexShrink = 2
        
        // 水平
        var children: [ASDisplayNode]
        
        // 是否添加 image
        if rowDescriptor.imageName != nil {
            children = [self.imageNode, self.titleNode, self.detailNode, self.stepNode]
        } else {
            children = [self.titleNode, self.detailNode, self.stepNode]
        }
        let stack = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .start, alignItems: .center, children: children)
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15), child: stack)
    }
}

extension JStepCounterCellNode {
    
    @objc func valueChanged(_ stepControl: UIStepper) {
        rowDescriptor.setValueToTriggerKVO(stepControl.value)
    }
}
