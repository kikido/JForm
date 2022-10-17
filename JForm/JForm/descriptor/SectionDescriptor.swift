//
//  SectionDescriptor.swift
//  JForm
//
//  Created by dqh on 2021/7/19.
//

import UIKit
import AVFoundation

public struct SectionEditStyle: OptionSet {
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let delete = SectionEditStyle(rawValue: 1 << 0)
}

public class SectionDescriptor: BaseDescriptor {
    
    /**
     所有在表单上显示的行描述子
     
     由于 Array 无法触发 kvo，所以使用 NSMutableArray。在 swift 中，NSMutableArray 无法指定类型，因此使用 formRows 属性来代替
     */
    @objc fileprivate dynamic lazy var sourceFormRows = NSMutableArray()
    
    fileprivate var kvoFormRows: NSMutableArray {
        return self.mutableArrayValue(forKey: "sourceFormRows")
    }

    /** 所有在表单上显示的行描述子 */
    public var formRows: [RowDescriptor] {
        return sourceFormRows as! [RowDescriptor]
    }

    /** 所有的行描述子 */
    public lazy var allRows = [RowDescriptor]()
    
    /** 表描述子 */
    public weak var form: FormDescriptor?
    
    /** 编辑模式，目前仅支持删除 */
    public var editStyle: SectionEditStyle?
    
    fileprivate var _isDisabled: Bool = false
    public override var isDisabled: Bool {
        set {
            if _isDisabled != newValue {
                _isDisabled = newValue
                
                formRows.forEach { row in
                    if row.isCellLoaded && row.cell.isFirstResponder() {
                        _ = row.cell.resignFirstResponder()
                    }
                    row.update()
                }
            }
        }
        get {
            return _isDisabled
        }
    }
    
    ///  默认为 false
    fileprivate var _isHidden: Bool = false
    public override var isHidden: Bool {
        set {
            if _isHidden != newValue {
                _isHidden = newValue
                form?.evaluateSecionIsHidden(self)
            }
        }
        get {
            if form?.isHidden ?? false {
                return true
            }
            return _isHidden
        }
    }
    

    // @Header, @Footer

    /** 头视图 */
    public var headerView: UIView?
    
    /** 尾视图 */
    public var footerView: UIView?
    
    // 高度自适应。若不为空，使用 ASTextNode 表示头视图。优先级低于 headerView
    public var headerAttributeString: NSAttributedString?
    
    // 高度自适应。若不为空，使用 ASTextNode 表示尾视图。优先级低于 footerView
    public var footerAttributeString: NSAttributedString?

    /**  头视图高度 */
    public var headerHeight: CGFloat = 25
    
    /** 尾视图高度 */
    public var footerHeight: CGFloat = 25
        
    public override init(withStyle style: JStyle? = nil) {
        super.init(withStyle: style)
        // kvo
        self.addObserver(self, forKeyPath: "sourceFormRows", options: [.new, .old], context: nil)
    }
    
    public convenience init() {
        self.init(withStyle: nil)
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: "sourceFormRows")
    }
}

// MARK: - KVO

extension SectionDescriptor {
    
    public override func observeValue(forKeyPath keyPath: String?,
                                      of object: Any?,
                                      change: [NSKeyValueChangeKey : Any]?,
                                      context: UnsafeMutableRawPointer?)
    {
        guard let form = self.form?.delegate, let sectionIndex = self.form?.indexOfSection(self) else { return }

        if let kind = change?[.kindKey] as? UInt, kind == NSKeyValueChange.insertion.rawValue { // insert
            if let indexSet = change?[.indexesKey] as? IndexSet {
                var indexPaths = [IndexPath]()
                indexSet.forEach { idx in
                    indexPaths.append(IndexPath(row: idx, section: sectionIndex))
                }
                form.rowsDidAdded(atIndexPaths: indexPaths)
            }
        } else if let kind = change?[.kindKey] as? UInt, kind == NSKeyValueChange.removal.rawValue { // remove
            if let indexSet = change?[.indexesKey] as? IndexSet {
                var indexPaths = [IndexPath]()
                indexSet.forEach { idx in
                    indexPaths.append(IndexPath(row: idx, section: sectionIndex))
                }
                form.rowsDidRemoved(atIndexPaths: indexPaths)
            }
        }
    }
}


// MARK: - Row

extension SectionDescriptor {
    
    public func add(_ row: RowDescriptor) {
        add([row])
    }
    
    public func add(_ rows: [RowDescriptor]) {
        insert(rows, startIndexAtAllRows: allRows.count, startIndexAtFormRows: sourceFormRows.count)
    }
    
    public func add(_ rows: [RowDescriptor], before currentRow: RowDescriptor) {
        // 从 currentRow 开始在 allrows 逆序遍历，找到第一个在 formrows 中的 row 的 index
        // 1. 如果找不到，则插入到最前面的位置，即 0
        // 2. 如果找到，且是 currentRow 在 formrows 中的 index，则插入到 index
        // 3. 其它情况，插入到 index + 1
        let currentIndex = sourceFormRows.index(of: currentRow)
        let index = firstIndexAtFormRowsOrderedDescending(beginWithRowAtAllRows: currentRow)
        let indexOfForm = index == NSNotFound ? 0 : (currentIndex == NSNotFound ? index + 1 : index)
        let indexOfAll = allRows.firstIndex(of: currentRow)!
        
        insert(rows, startIndexAtAllRows: indexOfAll, startIndexAtFormRows: indexOfForm)
    }
    
    func add(_ rows: [RowDescriptor], after currentRow: RowDescriptor) {
        // 从 currentRow 开始在 allrows 正序遍历，找到第一个在 formrows 中的 row 的 index
        // 1. 如果找不到，则插入到最后面的位置，即 sourceFormRows.count
        // 2. 如果找到，且是 currentRow 在 formrows 中的 index，则插入到 index + 1
        // 3. 其它情况，插入到 index
        let currentIndex = sourceFormRows.index(of: currentRow)
        let index = firstIndexAtFormOrderedAscending(beginWithRowAtAllRows: currentRow)
        let indexOfForm = index == NSNotFound ? sourceFormRows.count : (currentIndex == NSNotFound ? index : index + 1)
        let indexOfAll = allRows.firstIndex(of: currentRow)! + 1
        
        insert(rows, startIndexAtAllRows: indexOfAll, startIndexAtFormRows: indexOfForm)
    }
    
    func insert(_ row: RowDescriptor, at index: Int) {
        insert([row], at: index)
    }
    
    func insert(_ rows: [RowDescriptor], at targetIndex: Int) {
        if targetIndex == sourceFormRows.count {
            insert(rows, startIndexAtAllRows: targetIndex, startIndexAtFormRows: allRows.count)
        } else {
            let nextRow = sourceFormRows.object(at: targetIndex) as! RowDescriptor
            insert(rows, startIndexAtAllRows: allRows.firstIndex(of: nextRow)!, startIndexAtFormRows: targetIndex)
        }
    }

    /**
     将 rows 插入到 allrows 和 formrows 两个数组中
     
     插入逻辑：
     1. 找到在 allrows 中的插入位置，插入 rows
     2. 过滤掉 rows 中 isHidden 设置为 true 的元素
     3. 找到在 formrows 中的插入位置，插入过滤后的元素
     */
    fileprivate func insert(_ rows: [RowDescriptor], startIndexAtAllRows indexAtAll: Int, startIndexAtFormRows indexAtForm: Int) {
        let filterRows = rows.filter { row in
            return !row.isHidden
        }
        insertRowsIntoAll(rows, atIndex: indexAtAll)
        insertRowsIntoForm(filterRows, atIndex: indexAtForm)
    }
        
    func remove(_ row: RowDescriptor) {
        remove([row])
    }
    
    func remove(_ rows: [RowDescriptor]) {
        removeRowsFromAll(rows)
        
        rows.forEach { row in
            if row.isCellLoaded && row.cell.isFirstResponder() {
                row.cell.resignFirstResponder()
            }
        }
        removeRowsFromForm(rows)
    }
    
    func remove(at index: Int) {
        remove([sourceFormRows[index] as! RowDescriptor])
    }
    
    func row(at index: Int) -> RowDescriptor? {
        if index >= 0 && index < sourceFormRows.count {
            return (sourceFormRows.object(at: index) as! RowDescriptor)
        }
        return nil
    }
    
    func rows(at indexes: IndexSet) -> [RowDescriptor]? {
        var res = [RowDescriptor]()
        indexes.forEach { idx in
            if idx >= 0 && idx < sourceFormRows.count {
                res.append(sourceFormRows.object(at: idx) as! RowDescriptor)
            }
        }
        return res.isEmpty ? nil : res
    }
    
    func index(of row: RowDescriptor) -> Int? {
        let index = sourceFormRows.index(of: row)
        return index == NSNotFound ? nil : index
    }
}

// MARK: - Evaludate Row Hidden

extension SectionDescriptor {
    
    func evaluateRowIsHidden(_ row: RowDescriptor) {
        if row.isHidden {
            hideRow(row)
        } else {
            showRow(row)
        }
    }
    
    fileprivate func hideRow(_ row: RowDescriptor) {
        if row.isCellLoaded && row.cell.isFirstResponder() {
            row.cell.resignFirstResponder()
        }
        removeRowsFromForm([row])
    }
    
    fileprivate func showRow(_ row: RowDescriptor) {
        let index = firstIndexAtFormOrderedAscending(beginWithRowAtAllRows: row)
        let indexOfForm = index == NSNotFound ? sourceFormRows.count : index
        insertRowsIntoForm([row], atIndex: indexOfForm)
    }
}

// MARK: - Private

fileprivate extension SectionDescriptor {
    
    func insertRowsIntoAll(_ rows: [RowDescriptor], atIndex index: Int) {
        rows.forEach { row in
            assert(!allRows.contains(row), "row: \(row) already in all rows")
            row.section = self
            
            form?.addRowToTagCollection(row)
        }
        allRows.insert(contentsOf: rows, at: index)
    }
    
    func removeRowsFromAll(_ rows: [RowDescriptor]) {
        rows.forEach { row in
            row.section = nil
            form?.removeRowFromTagCollection(row)
            
            allRows.remove(at: allRows.firstIndex(of: row)!)
        }
    }
    
    func insertRowsIntoForm(_ rows: [RowDescriptor], atIndex index: Int) {
        kvoFormRows.insert(rows, at: IndexSet.init(integersIn: index ..< index + rows.count))
    }
    
    func removeRowsFromForm(_ rows: [RowDescriptor]) {
        kvoFormRows.removeObjects(in: rows)
    }
    
    /// 在 allrows 中，从 currentRow 开始，逆序遍历单元行，找到第一个在 sourceFormRows 存在的单元行的位置
    func firstIndexAtFormRowsOrderedDescending(beginWithRowAtAllRows currentRow: RowDescriptor) -> Int {
        var indexOfAll = allRows.firstIndex(of: currentRow) ?? 0
        var indexOfForm = sourceFormRows.index(of: currentRow)
        
        while indexOfForm == NSNotFound && indexOfAll > 0 {
            indexOfAll -= 1
            let previousRow = allRows[indexOfAll]
            indexOfForm = sourceFormRows.index(of: previousRow)
        }
        return indexOfForm
    }
    
    /// 在 allrows 中，从 currentRow 开始，升序遍历单元行，找到第一个在 sourceFormRows 存在的单元行的位置
    func firstIndexAtFormOrderedAscending(beginWithRowAtAllRows currentRow: RowDescriptor) -> Int {
        guard var indexOfAll = allRows.firstIndex(of: currentRow) else { return sourceFormRows.count }
        
        let countOfAll = allRows.count
        var indexOfForm = sourceFormRows.index(of: currentRow)
        
        while indexOfForm == NSNotFound && indexOfAll < (countOfAll - 1) {
            indexOfAll += 1
            let nextRow = allRows[indexOfAll]
            indexOfForm = sourceFormRows.index(of: nextRow)
        }
        return indexOfForm
    }
}
