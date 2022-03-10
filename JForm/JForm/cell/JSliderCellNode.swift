//
//  JSliderCellNode.swift
//  JForm
//
//  Created by dqh on 2021/7/20.
//

import Foundation
import AsyncDisplayKit

extension RowDescriptor.RowType {
    
    public static let slider = RowDescriptor.RowType(rawValue: "slider")
}

public class JSliderCellNode: JBaseCellNode {
    
    /// 将整个 slider 分为几步
    @objc public dynamic var steps: uint = 0 // 默认值为 0，即不进行划分
    @objc public dynamic var minimumValue: Float = 0
    @objc public dynamic var maximumValue: Float = 1
    
    public let sliderNode: ASDisplayNode
    @objc public var slider: UISlider?
    
    required init(with rowDescriptor: RowDescriptor) {
        sliderNode = ASDisplayNode.init { UISlider() }
        sliderNode.style.height = ASDimensionMake(30)

        super.init(with: rowDescriptor)
    }
    
    public override func update() {
        super.update()
        
        let sliderControl = sliderNode.view as! UISlider
        sliderControl.isEnabled = !rowDescriptor.isDisabled
        sliderControl.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
        sliderControl.maximumValue = maximumValue
        sliderControl.minimumValue = minimumValue
        self.slider = sliderControl
        
        if let value = rowDescriptor.value as? Float, value != sliderControl.value {
            if steps > 0 {
                sliderControl.value = roundf((value - sliderControl.minimumValue) / (sliderControl.maximumValue - sliderControl.minimumValue) * Float(steps)) * (sliderControl.maximumValue - sliderControl.minimumValue) / Float(steps) + sliderControl.minimumValue
            } else {
                sliderControl.value = value
            }
            sliderControl.sendActions(for: .valueChanged)
        }
    }
    
    public override class func customRowHeight() -> CGFloat? {
        return 100
    }
    
    public override var laysOutHorizontally: Bool {
        true
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.titleNode.style.flexGrow = 1
        self.titleNode.style.flexShrink = 1
        
        // 水平
        var topChildren: [ASDisplayNode]
        
        // 是否添加 image
        if rowDescriptor.imageName != nil {
            topChildren = [self.imageNode, self.titleNode, self.detailNode]
        } else {
            topChildren = [self.titleNode, self.detailNode]
        }
        
        let topH = ASStackLayoutSpec(direction: .horizontal, spacing: 20, justifyContent: .start, alignItems: .center, children: topChildren)
        let stack = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .spaceBetween, alignItems: .stretch, children: [topH, self.sliderNode])
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15), child: stack)
    }
}

extension JSliderCellNode {
    
    @objc func valueChanged(_ sliderControl: UISlider) {
        rowDescriptor.setValueToTriggerKVO(sliderControl.value)
    }
}
