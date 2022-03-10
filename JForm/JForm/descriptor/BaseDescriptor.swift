//
//  BaseDescriptor.swift
//  JForm
//
//  Created by dqh on 2021/7/19.
//

import UIKit
import Foundation

public typealias JStyle = BaseDescriptor.Style

public class BaseDescriptor: NSObject {
    
    /** 是否隐藏，默认为 false：不隐藏 */
    public var isHidden: Bool = false
    
    /** 是否只读，默认为 false */
    public var isDisabled: Bool = false
    
    /** 是否必录，默认为 false */
    public var isRequired: Bool = false
    
    public var style: JStyle?
    
    init(withStyle style: JStyle? = nil) {
        self.style = style
    }
}

// MARK: STYLE

extension BaseDescriptor {
    
    public class Style {

        /** 详情占位文本颜色 */
        var placeholderColor: UIColor?
        /** 标题颜色 */
        var titleColor: UIColor?
        /** 高亮时标题颜色 */
        var titleHighlightColor: UIColor?
        /** 只读时标题颜色 */
        var titleDisabledColor: UIColor?
        /** 详情颜色 */
        var detailColor: UIColor?
        /** 只读时详情颜色 */
        var detailDisabledColor: UIColor?
        /** 控件背景颜色 */
        var backgroundColor: UIColor?
        
        /** 标题字体 */
        var titleFont: UIFont?
        /** 高亮时标题字体 */
        var titleHighlightFont: UIFont?
        /** 只读时标题字体 */
        var titleDisabledFont: UIFont?
        /** 详情字体 */
        var detailFont: UIFont?
        /** 只读时详情字体 */
        var detailDisabledFont: UIFont?
        /** 详情占位文本字体 */
        var placeholderFont: UIFont?
        
        // MARK: - ROW UI
        
        var height: CGFloat?
        
        public typealias StyleInitHandler = ((JStyle) -> (Void))

        public init(_ handler: StyleInitHandler? = nil) {
            handler?(self)
        }
    }
}
