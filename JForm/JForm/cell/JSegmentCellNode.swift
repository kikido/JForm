//
//  JSegmentCellNode.swift
//  JForm
//
//  Created by dqh on 2021/7/20.
//

import Foundation
import AsyncDisplayKit

extension RowDescriptor.RowType {
    
    public static let segmentedControl = RowDescriptor.RowType(rawValue: "segmentedControl")
}

public class JSegmentCellNode: JBaseCellNode {
    
    public let segmentNode: ASDisplayNode
    @objc public var segmentControl: UISegmentedControl?
    
    required init(with rowDescriptor: RowDescriptor) {
        segmentNode = ASDisplayNode.init { UISegmentedControl() }
        super.init(with: rowDescriptor)
    }
    
    public override func update() {
        super.update()

        let segmentControl = segmentNode.view as! UISegmentedControl
        segmentControl.isEnabled = !rowDescriptor.isDisabled
        segmentControl.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
        do {
            segmentControl.removeAllSegments()

            if let items = rowDescriptor.optionItmes {
                var selectIndex: Int?
                
                for i in 0 ..< items.count {
                    let item = items[i]
                    segmentControl.insertSegment(withTitle: item.title, at: i, animated: false)
                    
                    if selectIndex == nil, let selectItem = rowDescriptor.value as? OptionItem {
                        if selectItem == item {
                            selectIndex = i
                        }
                    }
                }
                
                if let index = selectIndex {
                    segmentControl.selectedSegmentIndex = index
                }
            }
        }
        self.segmentControl = segmentControl
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.titleNode.style.flexGrow = 1
        self.titleNode.style.flexShrink = 1
        
        self.segmentNode.style.preferredSize = CGSize(width: (rowDescriptor.optionItmes?.count ?? 1) * 50, height: 30)
        
        // 水平
        var children: [ASDisplayNode]
        
        // 是否添加 image
        if rowDescriptor.imageName != nil {
            children = [self.imageNode, self.titleNode, self.segmentNode]
        } else {
            children = [self.titleNode, self.segmentNode]
        }
        let stack = ASStackLayoutSpec(direction: .horizontal, spacing: 20, justifyContent: .start, alignItems: .center, children:children)
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15), child: stack)
    }
}

extension JSegmentCellNode {
    
    @objc func valueChanged(_ segmentedControl: UISegmentedControl) {
        rowDescriptor.setValueToTriggerKVO(rowDescriptor.optionItmes?[segmentedControl.selectedSegmentIndex])
    }
}
