//
//  JInfoCellNode.swift
//  JForm
//
//  Created by dqh on 2021/7/22.
//

import Foundation
import AsyncDisplayKit

extension RowDescriptor.RowType {
    
    public static let longInfo = RowDescriptor.RowType(rawValue: "longInfo")
}

public class JInfoCellNode: JBaseCellNode {
    
    @objc public var maximumNumberOfLines: UInt = 0
    
    public override func update() {
        super.update()
        
        detailNode.attributedText = valueDetail
        detailNode.maximumNumberOfLines = maximumNumberOfLines
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.titleNode.style.flexShrink = 2
        
        self.detailNode.style.flexShrink = 3
        self.detailNode.style.flexGrow = 1
        self.detailNode.style.minHeight = ASDimensionMake(cellLongInfoMinHeight)
        
        var stack: ASStackLayoutSpec!
        
        if laysOutHorizontally {
            // 水平
            var children: [ASDisplayNode]
            
            // 是否添加 image
            if isNeedImageNode {
                children = [self.imageNode, self.titleNode, self.detailNode]
            } else {
                children = [self.titleNode, self.detailNode]
            }
            stack = ASStackLayoutSpec(direction: .horizontal, spacing: 20, justifyContent: .start, alignItems: .baselineFirst, children: children)
        } else {
            // 垂直
            var topStack: ASStackLayoutSpec
            
            // 是否添加 image
            if isNeedImageNode {
                topStack = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .start, alignItems: .center, children: [self.imageNode, self.titleNode])
            } else {
                topStack = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .start, alignItems: .start, children: [self.titleNode])
            }
            topStack.style.flexGrow = 1
            
            stack = ASStackLayoutSpec(direction: . vertical, spacing: 20, justifyContent: .start, alignItems: .stretch, children: [topStack, self.detailNode])
        }
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 12, left: 15, bottom: 12, right: 15), child: stack)
    }
    
    public override var valueDetail: NSAttributedString? {
        var detail: String?

        if let value = rowDescriptor.value {
            if let valueTransformer = rowDescriptor.valueTransformer {
                guard let transformedValue = valueTransformer.transformedValue(value) else { return nil }
                detail = String(describing: transformedValue)
            } else {
                detail =  String(describing: value)
            }
        }
        return appendInterpolation(detail ?? "", style: .font(rowDescriptor.detailDisabledFont), .color(rowDescriptor.detailDisabledColor), .alignment(laysOutHorizontally ? .right : .left))
    }
}

extension JInfoCellNode {

    public override func canBecomeFirstResponder() -> Bool {
        return false
    }
}
