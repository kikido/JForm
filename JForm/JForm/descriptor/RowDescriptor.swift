//
//  RowDescriptor.swift
//  JForm
//
//  Created by dqh on 2021/7/19.
//

import UIKit

internal let RowInitialHeight: CGFloat = -2
internal let UnspecifiedRowHeight: CGFloat = -3

public class RowDescriptor: BaseDescriptor {
    
    public typealias RowAction = (_ sender: RowDescriptor) -> Void
    public typealias RowValueChangeAction = (_ oldValue: Any?, _ newValue: Any?, _ sender: RowDescriptor) -> Void
    
    /** 标签 */
    public let tag: String
    
    /** 标题 */
    public let title: String?
    
    /** 图片名称，目前仅支持本地图片 */
    public let imageName: String?
    
    /** 值 */
    @objc public dynamic var value: Any?
    
    /** 样式 */
    public var type: RowDescriptor.RowType
    
    /** 节描述子 */
    public weak var section: SectionDescriptor?
    
    /** 点击事件，等等 */
    public var action: RowAction?
    
    /** value 回调 */
    public var valueChangeAction: RowValueChangeAction?
    
    /** 数据模型 */
    public var model: Any?
    
    private var _isDisabled: Bool = false
    public override var isDisabled: Bool {
        set {
            if _isDisabled != newValue {
                _isDisabled = newValue
                update()
            }
        }
        get {
            if section?.isDisabled == true || section?.form?.isDisabled == true {
                return true
            }
            return _isDisabled
        }
    }
    
    fileprivate var _isHidden: Bool = false
    public override var isHidden: Bool {
        set {
            if _isHidden != newValue {
                _isHidden = newValue
                section?.evaluateRowIsHidden(self)
            }
        }
        get {
            if section?.form?.isHidden ?? false {
                return true
            }
            if section?.isHidden ?? false {
                return true
            }
            return _isHidden
        }
    }
    
    // @Cell
    
    /** 对应的单元行是否已经创建 */
    public var isCellExist: Bool = false
    
    private var _cell: JBaseCellNode?
    private var _height: CGFloat = RowInitialHeight
    
    // @Config
    
    public var configAfterCreate = [String: Any]()
    public var configAfterUpdate = [String: Any]()
    public var configAfterDisabled = [String: Any]()
    public var configReserve = [String: Any]()
    
    // @Text
    
    /** 占位文本 */
    public var placeholder: String?
    
    /** 最大字符数。适用于某些文本输入行 */
    public var maxNumberOfCharacters: Int?
    
    /** 单位。适用于某些文本输入行 */
    public var unit: String?
    
    /**
     值转换器
     
     搭配 unit 使用。例如，表单需要显示单位为 ’万元‘ integer 类型的单元行，而传给服务器的值单位可能是 ’元‘。此时可以选择合适的 valueTransformer，在界面展示时会显示换算后的文本，而传给服务器会是基本单位的值
     */
    public var valueTransformer: ValueTransformer?

    // @Select
    
    /** 选择项 */
    public var optionItmes: [OptionItem]?
    
    /** viewcontroller 的标题 */
    public var selectorTitle: String?

    // @Validate
    
    /** 自定义值为空时的提示语 */
    public var requireMessage: String?
    
    public lazy var validators = [JValidateProtocol]()
    
    public init(withTag tag: String, rowType: RowDescriptor.RowType, title: String?, imageName: String? = nil, style: JStyle? = nil) {
        self.tag = tag
        self.title = title
        self.imageName = imageName
        self.type = rowType
        
        super.init(withStyle: style)
        
        // add kvo
        self.addObserver(self, forKeyPath: "value", options: [.old, .new], context: nil)
    }
    
    public convenience init(withTag tag: String, rowType: RowDescriptor.RowType, title: String?) {
        self.init(withTag: tag, rowType: rowType, title: title, imageName: nil, style: nil)
    }
    
    deinit {
        // remove kvo
        self.removeObserver(self, forKeyPath: "value")
    }
}

// MARK: - Cell

extension RowDescriptor {
    
    public var cell: JBaseCellNode {
        if _cell == nil {
            // lock
            objc_sync_enter(self)
            if _cell != nil { return _cell! }
            
            // create cell
            let cellType = self.cellType
            let cell = cellType.init(with: self)
            _cell = cell
            isCellExist = true
            
            // set config
            for (k, v) in configAfterCreate {
                cell.setValue(v, forKeyPath: k)
            }
            // unlock
            objc_sync_exit(self)
        }
        return _cell!
    }
    
    public var cellType: JBaseCellNode.Type {
        guard let cellType = JForm.cellClassesForRowTypes[self.type] else {
            fatalError("no defined cell class for row type named \(self.type)")
        }
        return cellType
    }
    
    public var height: CGFloat {
        get {
            if _height == RowInitialHeight {
                if let customHeight = self.cellType.customRowHeight() {
                    _height = customHeight
                } else {
                    _height = UnspecifiedRowHeight
                }
            }
            return _height
        }
        set {
            _height = newValue
        }
    }
    
    public func update() {
        if isCellExist && section?.form?.delegate != nil {
            self.cell.update()
            
            for (k, v) in configAfterUpdate {
                cell.setValue(v, forKeyPath: k)
            }
            if self.isDisabled {
                for (k, v) in configAfterDisabled {
                    cell.setValue(v, forKeyPath: k)
                }
            }
        }
    }
}

// MARK: - Validate

extension RowDescriptor {
    
    public func addValidator(_ validator: JValidateProtocol) {
        validators.append(validator)
    }
    
    public func removeValidator(_ validator: JValidateProtocol) {
        if let index = validators.firstIndex(where: { v in validator === v }) {
            validators.remove(at: index)
        }
    }
    
    public func removeAllValidators() {
        validators.removeAll()
    }
    
    public func doValidate() -> JValidateResult {
        if isRequired {
            // 验证是否有值
            if isValueEmpty() {
                var errorMessage: String!
                if let msg = requireMessage {
                    errorMessage = msg
                } else {
                    if let title = self.title {
                        errorMessage = "\(title) 不能为空"
                    } else {
                        errorMessage = "\(self.tag) 不能为空"
                    }
                }
                return JValidateResult.failure(message: errorMessage)
            }
        }
        for validator in validators {
            let result = validator.evaluate(self)
            if result == .failure(message: "") {
                return result
            }
        }
        return .ok
    }
    
    public func isValueEmpty() -> Bool {
        if let value = self.value {
            // string, array, dictionary, optionItem
            if let value = value as? String {
                return value.isEmpty
            }
            if let value = value as? Array<Any> {
                return value.isEmpty
            }
            if let value = value as? Dictionary<AnyHashable, AnyHashable> {
                return value.isEmpty
            }
            if let value = value as? OptionItem {
                return value.isEmpty
            }
            return false
        }
        return true
    }
}

// MARK: - KVO

extension RowDescriptor {
    
    public static override func automaticallyNotifiesObservers(forKey key: String) -> Bool {
        if key == "value" {
            // 避免自动触发 kvo
            return false
        }
        return true
    }
    
    /** 设置 value，会触发 kvo */
    public func setValueToTriggerKVO(_ value: Any?) {
        self.willChangeValue(forKey: "value")
        self.value = value
        self.didChangeValue(forKey: "value")
            
        update()
    }
    
    public override func observeValue(forKeyPath keyPath: String?,
                                      of object: Any?,
                                      change: [NSKeyValueChangeKey : Any]?,
                                      context: UnsafeMutableRawPointer?) {
        if keyPath == "value" {
            let newValue = change?[.newKey]
            let oldValue = change?[.oldKey]
            
            DispatchQueue.main.async {
                // block
                self.valueChangeAction?(oldValue, newValue, self)
                // delegate
                self.section?.form?.delegate?.rowValueDidChanged(self, oldValue: oldValue, newValue: newValue)
            }
        }
    }
}


extension RowDescriptor {
    
    public struct RowType: Hashable, Equatable, RawRepresentable {
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public var rawValue: String
    }
}

// MARK: - UI

extension RowDescriptor {
    
    public var backgroundColor: UIColor {
        if let color = style?.backgroundColor {
            return color
        }
        if let color = section?.style?.backgroundColor {
            return color
        }
        if let color = section?.form?.style?.backgroundColor {
            return color
        }
        return jCellBackgroundColor
    }
    
    public var titleColor: UIColor {
        if let color = style?.titleColor {
            return color
        }
        if let color = section?.style?.titleColor {
            return color
        }
        if let color = section?.form?.style?.titleColor {
            return color
        }
        return jCellTitleDefaultColor
    }
    
    public var titleHighlightColor: UIColor {
        if let color = style?.titleHighlightColor {
            return color
        }
        if let color = section?.style?.titleHighlightColor {
            return color
        }
        if let color = section?.form?.style?.titleHighlightColor {
            return color
        }
        return jCellTitleHighlightColor
    }
    
    public var titleDisabledColor: UIColor {
        if let color = style?.titleDisabledColor {
            return color
        }
        if let color = section?.style?.titleDisabledColor {
            return color
        }
        if let color = section?.form?.style?.titleDisabledColor {
            return color
        }
        return jCellTitleDisabledColor
    }
    
    public var detailColor: UIColor {
        if let color = style?.detailColor {
            return color
        }
        if let color = section?.style?.detailColor {
            return color
        }
        if let color = section?.form?.style?.detailColor {
            return color
        }
        return jCellDetailDefaultColor
    }
    
    public var detailDisabledColor: UIColor {
        if let color = style?.detailDisabledColor {
            return color
        }
        if let color = section?.style?.detailDisabledColor {
            return color
        }
        if let color = section?.form?.style?.detailDisabledColor {
            return color
        }
        return jCellDetailDisabledColor
    }
    
    public var placeholderColor: UIColor {
        if let color = style?.placeholderColor {
            return color
        }
        if let color = section?.style?.placeholderColor {
            return color
        }
        if let color = section?.form?.style?.placeholderColor {
            return color
        }
        return jCellPlaceholderColor
    }
    
    public var titleFont: UIFont {
        if let font = style?.titleFont {
            return font
        }
        if let font = section?.style?.titleFont {
            return font
        }
        if let font = section?.form?.style?.titleFont {
            return font
        }
        return jCellTitleDefaultFont
    }
    
    public var titleHighlightFont: UIFont {
        if let font = style?.titleHighlightFont {
            return font
        }
        if let font = section?.style?.titleHighlightFont {
            return font
        }
        if let font = section?.form?.style?.titleHighlightFont {
            return font
        }
        return jCellTitleHighlightFont
    }
    
    public var titleDisabledFont: UIFont {
        if let font = style?.titleDisabledFont {
            return font
        }
        if let font = section?.style?.titleDisabledFont {
            return font
        }
        if let font = section?.form?.style?.titleDisabledFont {
            return font
        }
        return jCellTitleDisabledFont
    }
    
    public var detailFont: UIFont {
        if let font = style?.detailFont {
            return font
        }
        if let font = section?.style?.detailFont {
            return font
        }
        if let font = section?.form?.style?.detailFont {
            return font
        }
        return jCellDetailDefaultFont
    }
    
    public var detailDisabledFont: UIFont {
        if let font = style?.titleHighlightFont {
            return font
        }
        if let font = section?.style?.detailDisabledFont {
            return font
        }
        if let font = section?.form?.style?.detailDisabledFont {
            return font
        }
        return jCellDetailDisabledFont
    }
    
    public var placeholderFont: UIFont {
        if let font = style?.placeholderFont {
            return font
        }
        if let font = section?.style?.placeholderFont {
            return font
        }
        if let font = section?.form?.style?.placeholderFont {
            return font
        }
        return jCellPlaceholderCFont
    }
}

