//
//  JForm.swift
//  JForm
//
//  Created by dqh on 2021/7/20.
//

import UIKit
import AsyncDisplayKit

public class JForm: UIView {
    
    public let tableNode: ASTableNode
    
    public var tableView: ASTableView {
        return tableNode.view
    }
    
    public weak var delegate: JFormDelegate?
    
    /** 表描述子 */
    public var formDescriptor: FormDescriptor
    
    /// row type -> cell class
    ///
    /// JForm 根据该属性来查找 row 对应的 cell 类别。当你创建新的单元行时，需要将其对应关系添加到该属性中
    public static var cellClassesForRowTypes: [RowDescriptor.RowType: JBaseCellNode.Type] = [
        .text: JTextFieldCellNode.self,
        .name: JTextFieldCellNode.self,
        .email: JTextFieldCellNode.self,
        .decimal: JTextFieldCellNode.self,
        .integer: JTextFieldCellNode.self,
        .password: JTextFieldCellNode.self,
        .phone: JTextFieldCellNode.self,
        .url: JTextFieldCellNode.self,
        .info: JTextFieldCellNode.self,
        .textView: JTextViewCellNode.self,
        .longInfo: JInfoCellNode.self,
        .pushSelect: JSelectCellNode.self,
        .multipleSelect: JSelectCellNode.self,
        .sheet: JSelectCellNode.self,
        .alert: JSelectCellNode.self,
        .picker: JSelectCellNode.self,
        .pushButton: JSelectCellNode.self,
        .date: JDateCellNode.self,
        .time: JDateCellNode.self,
        .dateTime: JDateCellNode.self,
        .countDownTimer: JDateCellNode.self,
        .dateInline: JDateInlineCellNode.self,
        .timeInline: JDateInlineCellNode.self,
        .dateTimeInline: JDateInlineCellNode.self,
        .countDownTimerInline: JDateInlineCellNode.self,
        ._dateInline: _JDateInlineCellNode.self,
        .switch_: JSwitchCellNode.self,
        .check: JCheckCellNode.self,
        .stepCounter: JStepCounterCellNode.self,
        .segmentedControl: JSegmentCellNode.self,
        .slider: JSliderCellNode.self,
    ]
    
    /// row type -> inline row type
    ///
    /// JForm 根据该属性来查找 row 对应的 inline row 类别。当你创建新的 inline row 时，需要将其对应关系添加到该属性中
    public static var inlineRowTypesForRowTypes: [RowDescriptor.RowType: RowDescriptor.RowType] = [
        .dateInline : ._dateInline,
        .timeInline : ._dateInline,
        .dateTimeInline : ._dateInline,
        .countDownTimerInline : ._dateInline
    ]
    
    public static func register(rowType: RowDescriptor.RowType, cellType: JBaseCellNode.Type) {
        cellClassesForRowTypes[rowType] = cellType
    }
    
    public static func register(rowType: RowDescriptor.RowType, inlineRowType: RowDescriptor.RowType) {
        inlineRowTypesForRowTypes[rowType] = inlineRowType
    }
    
    
    convenience init(withDecriptor descriptor: FormDescriptor) {
        self.init(withDecriptor: descriptor, frame: .zero)
    }
    
    required init(withDecriptor descriptor: FormDescriptor, frame: CGRect) {
        formDescriptor = descriptor
        tableNode = ASTableNode(style: .grouped)
        
        super.init(frame: frame)
        
        formDescriptor.delegate = self
        tableNode.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        tableNode.onDidLoad { [weak self] _ in
            self?.addNotification()
        }
        tableNode.delegate = self
        tableNode.dataSource = self
        tableNode.view.estimatedSectionHeaderHeight = UITableView.automaticDimension

        addSubnode(tableNode)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("jFrom dealloc")
        NotificationCenter.default.removeObserver(self)
        formDescriptor.delegate = nil
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if window?.backgroundColor == nil {
            window?.backgroundColor = .white
        }
        tableNode.frame = self.bounds
    }
}

// MARK: - Notification

private extension JForm {
        
    func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(contentSizeCategoryChanged), name: UIContentSizeCategory.didChangeNotification, object: nil)
    }
    
    @objc func contentSizeCategoryChanged() {
        self.update()
    }
}

// MARK: - ASTableDataSource

extension JForm: ASTableDataSource {
        
    public func numberOfSections(in tableNode: ASTableNode) -> Int {
        return formDescriptor.formSections.count
    }
    
    public func  tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return formDescriptor.formSections[section].formRows.count
    }
    
    public func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        return formDescriptor.row(at: indexPath)!.cell
    }
}

// MARK: - ASTableDelegate

extension JForm: ASTableDelegate {
        
    public func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        let row = formDescriptor.row(at: indexPath)!
        if row.isDisabled { return }
        
        let cell = row.cell
        if cell.canBecomeFirstResponder() && cell.becomeFirstResponder() { }
        cell.rowDidSelected()
    }
    
    public func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        let row = self.formDescriptor.row(at: indexPath)!
        return row.height < 0 ? ASSizeRangeUnconstrained : ASSizeRangeMake(CGSize(width: 0, height: row.height))
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionDescriptor = formDescriptor.section(at: section)!
        
        if let attrStr = sectionDescriptor.headerAttributeString {
            // 计算高度
            let textNode = ASTextNode()
            textNode.attributedText = attrStr
            let screenWidth = UIScreen.main.bounds.size.width
            let layout = textNode.layoutThatFits(ASSizeRange(min: CGSize.zero, max: CGSize(width: screenWidth - 30, height: 10000)))
            let verticalMargin = 12.0
            sectionDescriptor.headerHeight = layout.size.height + verticalMargin
        }
        return sectionDescriptor.headerHeight
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let sectionDescriptor = formDescriptor.section(at: section)!
        
        if let attrStr = sectionDescriptor.footerAttributeString {
            let textNode = ASTextNode()
            textNode.attributedText = attrStr
            let screenWidth = UIScreen.main.bounds.size.width
            let layout = textNode.layoutThatFits(ASSizeRange(min: CGSize.zero, max: CGSize(width: screenWidth - 30, height: 10000)))
            let verticalMargin = 12.0
            sectionDescriptor.footerHeight = layout.size.height + verticalMargin
        }
        return sectionDescriptor.footerHeight
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionDescriptor = formDescriptor.section(at: section)!
        // custom headerView
        if let customHeaderView = sectionDescriptor.headerView {
            return customHeaderView
        }

        let header = UIView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: sectionDescriptor.headerHeight))
        header.backgroundColor = .clear

        if let attrStr = sectionDescriptor.headerAttributeString {
            let textNode = ASTextNode()
            textNode.attributedText = attrStr

            let contentNode = ASDisplayNode()
            contentNode.frame = header.bounds
            header.addSubnode(contentNode)
            contentNode.addSubnode(textNode)

            contentNode.layoutSpecBlock = { _, _ in
                let verticalMargin = 12.0

                textNode.style.flexShrink = 1
                textNode.style.flexGrow = 1
                return ASInsetLayoutSpec(insets: UIEdgeInsets(top:6, left: 15, bottom: verticalMargin - 6, right: 15), child: textNode)
            }
        }
        return header
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let sectionDescriptor = formDescriptor.section(at: section)!
        // custom footerView
        if let customFooterView = sectionDescriptor.footerView {
            return customFooterView
        }

        let footer = UIView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: sectionDescriptor.footerHeight))
        footer.backgroundColor = .clear

        if let attrStr = sectionDescriptor.footerAttributeString {
            let textNode = ASTextNode()
            textNode.attributedText = attrStr

            let contentNode = ASDisplayNode()
            contentNode.frame = footer.bounds
            footer.addSubnode(contentNode)
            contentNode.addSubnode(textNode)

            contentNode.layoutSpecBlock = { _, _ in
                let verticalMargin = 12.0

                textNode.style.flexShrink = 1
                textNode.style.flexGrow = 1
                return ASInsetLayoutSpec(insets: UIEdgeInsets(top:6, left: 15, bottom: verticalMargin - 6, right: 15), child: textNode)
            }
        }
        return footer
    }
    
    
    // MARK: Editing style
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        let row = formDescriptor.row(at: indexPath)!
        if let section = row.section, section.editStyle == .delete, !row.isDisabled {
            return .delete
        }
        return .none
    }
    
    public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return self.tableView(tableView, editingStyleForRowAt: indexPath) == .delete ? true : false
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle != .delete { return }
        
        DispatchQueue.main.async {
            tableView.endEditing(true)
            self.remove(at: indexPath)
        }
    }
}

// MARK: - JFormDescriptorDelegate

extension JForm: JFormDescriptorDelegate {
        
    public func sectionsDidRemoved(atIndexes indexes: IndexSet) {
        tableNode.deleteSections(indexes, with: .fade)
    }
    
    public func sectionsDidAdded(atIndexes indexes: IndexSet) {
        tableNode.insertSections(indexes, with: .fade)
    }
    
    public func rowsDidAdded(atIndexPaths indexPaths: [IndexPath]) {
        tableNode.insertRows(at: indexPaths, with: .fade)
    }
    
    public func rowsDidRemoved(atIndexPaths indexPaths: [IndexPath]) {
        tableNode.deleteRows(at: indexPaths, with: .fade)
    }
    
    public func rowValueDidChanged(_ row: RowDescriptor, oldValue: Any?, newValue: Any?) {
        self.delegate?.rowValueDidChanged(row, oldValue: oldValue, newValue: newValue)
    }
}

// MARK: - Output

extension JForm {
        
    /**
     表单值。key 为行描述子的 tag， value 为行描述子的值
     
     @Note: 隐藏的单元行的值也会被添加进去
     */
    public var formValues: [String: Any] {
        var allValues = [String: Any]()
        for section in formDescriptor.allSections {
            for row in section.allRows {
                var curValue: Any!
                // 别名或者 tag
                if let optionItem = row.value as? OptionItem {
                    curValue = optionItem.value
                } else if let value = row.value {
                    curValue = value
                }
                allValues[row.cell.parameterNameForRow() ?? row.tag] = curValue
            }
        }
        return allValues
    }
    
    /** 验证错误集合 */
    public var validateErrors: [JValidateResult]? {
        var formResults = [JValidateResult]()
        for section in formDescriptor.formSections {
            for row in section.formRows {
                let result = row.doValidate()
                if !result.isValid {
                    formResults.append(result)
                }
            }
        }
        return formResults.isEmpty ? nil : formResults
    }
    
    /** 展示验证错误 */
    public func showValidateError(_ error: JValidateResult, withTitle title: String? = nil) {
        if error == .ok || tableNode.closestViewController == nil { return }
        
        switch error {
        case .failure(message: let message):
            let alertController = UIAlertController.init(title: "错误", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "确认", style: .default, handler: nil))
            DispatchQueue.main.async {
                self.tableNode.closestViewController?.present(alertController, animated: true, completion: nil)
            }
        default:
            break
        }
    }
}

// MARK: - Row

extension JForm {
        
    public func add(_ row: RowDescriptor) {
        formDescriptor.formSections.last?.add(row)
    }
    
    public func add(_ rows: [RowDescriptor]) {
        formDescriptor.formSections.last?.add(rows)
    }
    
    public func insert(_ rows: [RowDescriptor], at indexPath: IndexPath) {
        formDescriptor.formSections[indexPath.section].insert(rows, at: indexPath.row)
    }
    
    public func add(_ rows: [RowDescriptor], before currentRow: RowDescriptor) {
        currentRow.section?.add(rows, before: currentRow)
    }
    
    public func add(_ rows: [RowDescriptor], after currentRow: RowDescriptor) {
        currentRow.section?.add(rows, after: currentRow)
    }
    
    public func add(_ rows: [RowDescriptor], beforeRowWithTag tag: String) {
        if let currentRow = row(withTag: tag) {
            currentRow.section?.add(rows, before: currentRow)
        }
    }

    public func add(_ rows: [RowDescriptor], afterRowWithTag tag: String) {
        if let currentRow = row(withTag: tag) {
            currentRow.section?.add(rows, after: currentRow)
        }
    }
    
    public func remove(_ row: RowDescriptor) {
        row.section?.remove(row)
    }
    
    public func remove(_ rows: [RowDescriptor]) {
        rows.forEach { row in
            row.section?.remove(row)
        }
    }
    
    public func remove(at indexPath: IndexPath) {
        formDescriptor.formSections[indexPath.section].remove(at: indexPath.row)
    }
    
    public func remove(withTag tag: String) {
        if let row = row(withTag: tag) {
            remove(row)
        }
    }
    
    public func row(at indexPath: IndexPath) -> RowDescriptor? {
        return formDescriptor.row(at: indexPath)
    }
    
    public func row(withTag tag: String) -> RowDescriptor? {
        return formDescriptor.row(withTag: tag)
    }
    
    public func indexPathForRow(_ row: RowDescriptor) -> IndexPath? {
        return formDescriptor.indexPathForRow(row)
    }
    
    public func ensureRowIsVisible(_ row: RowDescriptor?) {
        if let row = row, !row.cell.isVisible, let indexPath = formDescriptor.indexPathForRow(row) {
            tableNode.scrollToRow(at: indexPath, at: .none, animated: true)
        }
    }
}

// MARK: - Section

extension JForm {
        
    /** 添加节描述子 */
    public func add(_ section: SectionDescriptor) {
        formDescriptor.add(section)
    }
    
    /** 添加一些节描述子 */
    public func add(_ sections: [SectionDescriptor]) {
        formDescriptor.add(sections)
    }
    
    /** 添加节描述子到指定位置 */
    public func insert(_ sections: [SectionDescriptor], at index: Int) {
        formDescriptor.insert(sections, at: index)
    }
    
    /** 在指定的节描述子前面添加一些节描述子 */
    public func add(_ sections: [SectionDescriptor] , before section: SectionDescriptor) {
        formDescriptor.add(sections, before: section)
    }
    
    /** 在指定的节描述子后面添加一些节描述子 */
    public func add(_ sections: [SectionDescriptor], after section: SectionDescriptor) {
        formDescriptor.add(sections, after: section)
    }
    
    /** 删除节描述子 */
    public func remove(_ section: SectionDescriptor) {
        formDescriptor.remove(section)
    }
    
    /** 删除一些节描述子 */
    public func remove(_ sections: [SectionDescriptor]) {
        formDescriptor.remove(sections)
    }
    
    /** 删除指定位置的节描述子 */
    public func remove(at index: Int) {
        formDescriptor.remove(at: index)
    }
    
    /** 指定位置的节描述子 */
    public func section(at index: Int) -> SectionDescriptor? {
        return formDescriptor.section(at: index)
    }
    
    public func sections(at indexSet: IndexSet) -> [SectionDescriptor]? {
        return formDescriptor.sections(at: indexSet)
    }
    
    public func indexOfSection(_ section: SectionDescriptor) -> Int? {
        return formDescriptor.indexOfSection(section)
    }
}

// MARK: - Edit Text

extension JForm {
    
    public func rowShouldBeginEditing(_ row: RowDescriptor, textField: UITextField?, textView: UITextView?) -> Bool {
        return !row.isDisabled
    }
    
    public func rowDidBeginEditing(_ row: RowDescriptor, textField: UITextField?, textView: UITextView?) {
        row.cell.becomeHighlight()
    }
    
    public func row(_ row: RowDescriptor,
             textField: UITextField?,
             textView: UITextView?,
             shouldChangeCharactersIn range: NSRange,
             replacementString string: String) -> Bool
    {
        if let maxLength = row.maxNumberOfCharacters {
            let currentString: NSString = ((textField != nil ? textField?.text : textView!.text) ?? "") as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        return true
    }
    
    public func rowDidEndEditing(_ row: RowDescriptor, textField: UITextField?, textView: UITextView?) {
        row.cell.resignHighlight()
    }
}

// MARK: -

extension JForm {
        
    public func makeRowsHidden(_ hidden: Bool, withTags tags: [String]) {
        tags.forEach { tag in
            if let row = row(withTag: tag) {
                row.isHidden = hidden
            }
        }
    }
    
    public func makeRowsDisabled(_ disabled: Bool, withTags tags: [String]) {
        tags.forEach { tag in
            if let row = row(withTag: tag) {
                row.isDisabled = disabled
            }
        }
    }
    
    public func makeRowsRequired(_ required: Bool, withTags tags: [String]) {
        tags.forEach { tag in
            if let row = row(withTag: tag) {
                row.isRequired = required
                row.update()
            }
        }
    }
    
    public func setRowValueToTriggerKVO(_ value: Any?, tag: String) {
        if let row = row(withTag: tag) {
            row.setValueToTriggerKVO(value)
        }
    }
    
    // 会触发 row.update
    public func setRowValue(_ value: Any?, tag: String) {
        row(withTag: tag)?.setValueToTriggerKVO(value)
    }
    
    public func update() {
        formDescriptor.formSections.forEach { section in
            section.formRows.forEach { row in
                if row.isCellExist {
                    row.update()
                }
            }
        }
    }
    
    public func updateSpecifiedRows(withTags tags: [String]) {
        tags.forEach { tag in
            if let row = row(withTag: tag) {
                row.update()
            }
        }
    }
    
    public func updateSpecifiedRow(withTag tag: String) {
        row(withTag: tag)?.update()
    }
    
    public func updateSpecifiedRow(_ rows: [RowDescriptor]) {
        rows.forEach { row in
            row.update()
        }
    }
    
    public func reload() {
        tableNode.reloadData()
    }
    
    public func reloadSpecifiedRows(withTags tags: [String]) {
        var rows = [RowDescriptor]()
        tags.forEach { tag in
            if let row = row(withTag: tag) {
                rows.append(row)
            }
        }
        reloadSpecifiedRows(rows)
    }

    public func reloadSpecifiedRows(_ rows: [RowDescriptor]) {
        var indexPaths = [IndexPath]()
        rows.forEach { row in
            if let indexpath = indexPathForRow(row) {
                indexPaths.append(indexpath)
            }
        }
        tableNode.reloadRows(at: indexPaths, with: .none)
    }
}


