//
//  JBaseCell.swift
//  JForm
//
//  Created by dqh on 2021/7/20.
//

import AsyncDisplayKit

open class JBaseCellNode: ASCellNode {

    /// 行描述子，为 cell 提供数据及其它的一些行为
    public let rowDescriptor: RowDescriptor
    
    @objc public var titleNode: ASTextNode
    
    @objc public var detailNode: ASTextNode
    
    @objc public var imageNode: ASImageNode
    
    @objc public let unitNode: ASTextNode
    
    /// 控件布局方向。默认水平布局
    open var laysOutHorizontally: Bool {
        return rowDescriptor.section?.form?.laysOutHorizontally ?? true
    }
    
    required public init(with rowDescriptor: RowDescriptor) {
        self.rowDescriptor = rowDescriptor
        
        titleNode = ASTextNode()
        titleNode.style.maxHeight = ASDimensionMake(cellTitleMaxHeight)

        detailNode = ASTextNode()

        unitNode = ASTextNode()
        unitNode.maximumNumberOfLines = 1

        imageNode = ASImageNode()

        super.init()

        config()
    }

    /**
     初始化设置
     
     子类可以覆写这个方法，在里面创建控件，设置代理等，需要调用父类。只调用一次。
     */
    open func config() {
        self.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        self.selectionStyle = .none
        self.automaticallyManagesSubnodes = true
    }
    
    open override func didLoad() {
        rowDescriptor.update()
    }
    
    /**
     更新 cell
     
     子类需要覆写该方法，该方法可以被多次调用，以便及时更新 UI。
     */
    open func update() {
        updateTtitleAndDetail()
        self.backgroundColor = rowDescriptor.backgroundColor
    }
    
    /// 进入编辑模式
    open func becomeHighlight() {
        updateTtitleAndDetail()
    }
    
    /// 退出编辑模式
    open func resignHighlight() {
        updateTtitleAndDetail()
    }
    
    /// 单元行被选中
    open func rowDidSelected() { }
    
    /// 为单元行设置一个别名，优先级大于 tag
    open func parameterNameForRow() -> String? { nil }

    /// 设置单元行的高度
    open class func customRowHeight() -> CGFloat? { nil }
}

// MARK: - Helper

extension JBaseCellNode {
    
    var closeForm: JForm? {
        get {
            rowDescriptor.section?.form?.delegate as? JForm
        }
    }
    
    /// detail 显示的富文本
    @objc open dynamic var valueDetail: NSAttributedString? {
        var detail: String?
        var isNeedPlaceholder = false
        
        // placeholder
        if let placeholder = placeholder {
            detail = placeholder
            isNeedPlaceholder = true
        }
        
        // 有值(可能为空)
        if !isNeedPlaceholder, let value = rowDescriptor.value {
            if let valueTransformer = rowDescriptor.valueTransformer {
                guard let transformedValue = valueTransformer.transformedValue(value) else { return nil }
                
                // 需要考虑 OptionItem 类型的情况
                if let transformedValue = transformedValue as? OptionItem {
                    detail = transformedValue.title
                } else {
                    detail = String(describing: transformedValue)
                }
            } else {
                if let value = value as? OptionItem {
                    detail = value.title
                }
                else if let value = value as? [OptionItem] {
                    detail = value.map({ itme in
                        itme.title
                    }).joined(separator: ", ")
                }
                else {
                    detail =  String(describing: value)
                }
            }
        }
        return appendInterpolation(detail ?? "", style: .color(isNeedPlaceholder ? self.placeholderColor : self.detailColor), .font(isNeedPlaceholder ? self.placeholderFont : self.detailFont), .alignment(laysOutHorizontally ? .right : .left))
    }
    
    @objc open dynamic var placeholder: String? {
        if rowDescriptor.isValueEmpty() {
            // 单独定义的 placeholder 优先级更高
            if let placeholder = rowDescriptor.placeholder {
                return placeholder
            }
            
            // 模板的 placeholder
            if let addPlaceholder = closeForm?.formDescriptor.autoAddPlaceholder, addPlaceholder {
                switch rowDescriptor.type {
                case .pushSelect, .multipleSelect, .sheet, .alert, .picker, .pushButton, .date, .time, .dateTime, .countDownTimer:
                    return "请选择\(rowDescriptor.title ?? rowDescriptor.tag)"
                default:
                    return "请输入\(rowDescriptor.title ?? rowDescriptor.tag)"
                }
            }
        }
        return nil
    }

    /** 更新 title 和 detail */
    open func updateTtitleAndDetail() {
        if let form = rowDescriptor.section?.form, let _ = form.delegate {
            // title
            let required = rowDescriptor.isRequired && form.addAsteriskToRequiredRow
            
            self.titleNode.attributedText =
                appendInterpolation(required ? "*" : "", style: .color(jFormRed), .font(self.titleFont))! +
                appendInterpolation(rowDescriptor.title ?? "", style: .color(self.titleColor), .font(self.titleFont))!
            
            // unit
            self.unitNode.attributedText =
                appendInterpolation(rowDescriptor.unit ?? "", style: .color(self.detailColor), .font(self.detailFont))

            // detail
            self.detailNode.attributedText = valueDetail
            
            // image
            if let imageName = rowDescriptor.imageName {
                imageNode.image = UIImage(named: imageName)
            }
        } else {
            self.titleNode.attributedText = nil
            self.detailNode.attributedText = nil
        }
    }
}

// MARK: - Response

extension JBaseCellNode {    
    
    open override func canBecomeFirstResponder() -> Bool {
        return !rowDescriptor.isDisabled
    }
    
    open override func isFirstResponder() -> Bool {
        return false
    }
}

// MARK: - UI

extension JBaseCellNode {
    
    public var titleColor: UIColor {
        if rowDescriptor.isDisabled {
            return rowDescriptor.titleDisabledColor
        }
        else if self.isFirstResponder() {
            return rowDescriptor.titleHighlightColor
        } else {
            return rowDescriptor.titleColor
        }
    }
    
    public var detailColor: UIColor {
        if rowDescriptor.isDisabled {
            return rowDescriptor.detailDisabledColor
        } else {
            return rowDescriptor.detailColor
        }
    }
    
    public var placeholderColor: UIColor {
        return rowDescriptor.placeholderColor
    }
    
    public var titleFont: UIFont {
        if rowDescriptor.isDisabled {
            return rowDescriptor.titleDisabledFont
        }
        else if self.isFirstResponder() {
            return rowDescriptor.titleHighlightFont
        } else {
            return rowDescriptor.titleFont
        }
    }
    
    public var detailFont: UIFont {
        if rowDescriptor.isDisabled {
            return rowDescriptor.detailDisabledFont
        }
        else {
            return rowDescriptor.detailFont
        }
    }
    
    public var placeholderFont: UIFont {
        return rowDescriptor.placeholderFont
    }
}

// MARK: - UIImage Ex

extension UIImage {
    
    static func imageInBundle(named name: String) -> UIImage? {
        struct Helper {
            static var scale: CGFloat?
            static var bundle: Bundle?
        }
        
        var image = UIImage.init(named: name)
        if image == nil {
            if let url = Bundle.main.url(forResource: "JForm", withExtension: "bundle"), Helper.scale == nil {
                objc_sync_enter(name)

                if Helper.scale == nil {
                    Helper.scale = UIScreen.main.scale
                    Helper.bundle = Bundle.init(url: url)
                }
                
                objc_sync_exit(name)
            }
            
            let imageName = name + (Helper.scale == 3 ? "@3x" : "@2x")
            if let path = Helper.bundle?.path(forResource: imageName, ofType: "png") {
                image = UIImage.init(contentsOfFile: path)
            }
        }
        return image
    }
}

// MARK: - Attribute String

struct RichTextStyle {
    
    let attributes: [NSAttributedString.Key: Any]
    
    static func font(_ font: UIFont) -> RichTextStyle {
        return RichTextStyle(attributes: [.font: font])
    }
    
    static func color(_ color: UIColor) -> RichTextStyle {
        return RichTextStyle(attributes: [.foregroundColor: color])
    }
    
    static func bgColor(_ color: UIColor) -> RichTextStyle {
        return RichTextStyle(attributes: [.backgroundColor: color])
    }
    
    static func link(_ link: String) -> RichTextStyle {
        return .link(URL(string: link)!)
    }
    
    static func link(_ link: URL) -> RichTextStyle {
        return RichTextStyle(attributes: [.link: link])
    }
    
    static let oblique = RichTextStyle(attributes: [.obliqueness: 0.1])
    
    static func underline(_ color: UIColor, _ style: NSUnderlineStyle) -> RichTextStyle {
        return RichTextStyle(attributes: [
            .underlineColor: color,
            .underlineStyle: style.rawValue
        ])
    }
    
    static func alignment(_ alignment: NSTextAlignment) -> RichTextStyle {
        let ps = NSMutableParagraphStyle()
        ps.alignment = alignment
        return RichTextStyle(attributes: [.paragraphStyle: ps])
    }
}

func appendInterpolation(_ string: String?, style: RichTextStyle...) -> NSAttributedString? {
    guard let string = string else { return nil }
    
    var attrs: [NSAttributedString.Key: Any] = [:]

    style.forEach {
        attrs.merge($0.attributes, uniquingKeysWith: {$1})
    }
    
    return NSAttributedString(string: string, attributes: attrs)
}

func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString
{
    let result = NSMutableAttributedString()
    result.append(left)
    result.append(right)
    return result
}
