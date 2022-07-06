//
//  FormDescriptor.swift
//  JForm
//
//  Created by dqh on 2021/7/19.
//

import Foundation

public class FormDescriptor: BaseDescriptor {
    
    /** 是否在必录的单元行的标题前面添加红色的星号 * */
    public var addAsteriskToRequiredRow: Bool = false
    
    /**
     是否自动添加 Placeholder
     
     文本格式为 "请输入\(title)", 选择(Date， select)格式为 "请选择\(title)"
     */
    public var autoAddPlaceholder: Bool = false

    /**
     是否水平布局，true 表示为水平布局。

     目前仅支持 text ，info，select 样式的
     @note: 垂直模式不显示 unit 单位
     */
    public var laysOutHorizontally: Bool = true

    /** tag -> 行描述子 集合 */
    public lazy var allRowsByTag = Dictionary<String, RowDescriptor>()
    
    /** 表单视图 */
    public weak var delegate: JFormDescriptorDelegate?
    
    /**
     所有在表单上可见的节描述子
     
     由于使用 Array 无法触发 kvo，所以使用 NSMutableArray。因为在 swift 中，NSMutableArray 无法指定类型，所以增加了 formSections 属性
     */
    @objc dynamic private lazy var sourceFormSections = NSMutableArray()
    
    private var kvoFormSections: NSMutableArray {
        return self.mutableArrayValue(forKey: "sourceFormSections")
    }
    
    /** 所有在表单上可见的节描述子 */
    public var formSections: [SectionDescriptor] {
        return sourceFormSections as! [SectionDescriptor]
    }
    
    /** 所有的节描述子 */
    public lazy var allSections = [SectionDescriptor]()
    
    fileprivate var _isDisabled: Bool = false
    public override var isDisabled: Bool {
        set {
            if _isDisabled != newValue {
                _isDisabled = newValue
                if delegate == nil { return }
                
                formSections.forEach { section in
                    section.formRows.forEach { row in
                        if row.isCellExist && row.cell.isFirstResponder() {
                            row.cell.resignFirstResponder()
                        }
                        row.update()
                    }
                }
            }
        }
        get {
            return _isDisabled
        }
    }
    
    fileprivate var _isHidden: Bool = false
    public override var isHidden: Bool {
        set {
            if _isHidden != newValue {
                _isHidden = newValue
                if let view = delegate as? JForm {
                    view.isHidden = newValue
                }
            }
        }
        get {
            return _isHidden
        }
    }

    public override init(withStyle style: JStyle? = nil) {
        super.init(withStyle: style)
        // kvo
        self.addObserver(self, forKeyPath: "sourceFormSections", options: [.new, .old], context: nil)
    }
    
    public convenience init() {
        self.init(withStyle: nil)
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: "sourceFormSections")
    }
}

// MARK: - KVO

extension FormDescriptor {
        
    public override func observeValue(forKeyPath keyPath: String?,
                                      of object: Any?,
                                      change: [NSKeyValueChangeKey : Any]?,
                                      context: UnsafeMutableRawPointer?)
    {
        guard let form = self.delegate else { return }

        // insert
        if let kind = change?[.kindKey] as? UInt, kind == NSKeyValueChange.insertion.rawValue {
            if let indexes = change?[.indexesKey] as? IndexSet {
                form.sectionsDidAdded(atIndexes: indexes)
            }
        }
        // remove
        if let kind = change?[.kindKey] as? UInt, kind == NSKeyValueChange.removal.rawValue {
            if let indexes = change?[.indexesKey] as? IndexSet {
//                var indexSet = IndexSet()
//                indexes.forEach { idx in
//                    indexSet.insert(idx)
//                }
                form.sectionsDidRemoved(atIndexes: indexes)
            }
        }
    }
}

// MARK: - Section

extension FormDescriptor {
        
    public func add(_ section: SectionDescriptor) {
        add([section])
    }
    
    public func add(_ sections: [SectionDescriptor]) {
        insert(sections, startIndexAtAllSections: allSections.count, startIndexAtFormSections: sourceFormSections.count)
    }
    
    public func add(_ sections: [SectionDescriptor], before currentSection: SectionDescriptor) {
        // 从 currentSection 开始在 allsections 逆序遍历，找到第一个在 formsection 中的 section 的 index
        // 1. 如果找不到，则插入到最前面的位置，即 0
        // 2. 如果找到，且是 currentSection 在 formsection 中的 index，则插入到 index
        // 3. 其它情况，插入到 index + 1
        let currentIndex = sourceFormSections.index(of: currentSection)
        let index = firstIndexAtFormSectionsOrderedDescending(beginWithSectionAtAllSections: currentSection)
        let indexOfForm = index == NSNotFound ? 0 : (currentIndex == NSNotFound ? index + 1 : index)
        let indexOfAll = allSections.firstIndex(of: currentSection)!
        
        insert(sections, startIndexAtAllSections: indexOfAll, startIndexAtFormSections: indexOfForm)
    }
    
    public func add(_ sections: [SectionDescriptor], after currentSection: SectionDescriptor) {
        // 从 currentSection 开始在 allsections 正序遍历，找到第一个在 formsection 中的 section 的 index
        // 1. 如果找不到，则插入到最后面的位置，即 sourceFormRows.count
        // 2. 如果找到，且是 currentSection 在 formsection 中的 index，则插入到 index + 1
        // 3. 其它情况，插入到 index
        let currentIndex = sourceFormSections.index(of: currentSection)
        let index = firstIndexAtFormOrderedAscending(beginWithSectionAtAllSections: currentSection)
        let indexOfForm = index == NSNotFound ? sourceFormSections.count : (currentIndex == NSNotFound ? index : index + 1)
        let indexOfAll = allSections.firstIndex(of: currentSection)! + 1
        
        insert(sections, startIndexAtAllSections: indexOfAll, startIndexAtFormSections: indexOfForm)
    }
    
    public func insert(_ section: SectionDescriptor, at index: Int) {
        insert([section], at: index)
    }
    
    public func insert(_ sections: [SectionDescriptor], at targetIndex: Int) {
        if targetIndex == sourceFormSections.count {
            insert(sections, startIndexAtAllSections: targetIndex, startIndexAtFormSections: allSections.count)
        } else {
            let nextRow = sourceFormSections.object(at: targetIndex) as! SectionDescriptor
            insert(sections, startIndexAtAllSections: allSections.firstIndex(of: nextRow)!, startIndexAtFormSections: targetIndex)
        }
    }

    /**
     将 sections 插入到 allSections 和 formSecions 两个数组中
     
     插入逻辑：
     1. 找到在 allSections 中的插入位置，插入 sections
     2. 过滤掉 sections 中 isHidden 设置为 true 的元素
     3. 找到在 formSecions 中的插入位置，插入过滤后的元素
     */
    fileprivate func insert(_ sections: [SectionDescriptor], startIndexAtAllSections indexOfAll: Int, startIndexAtFormSections indexOfForm: Int) {
        let filterSections = sections.filter { section in
            return !section.isHidden
        }
        insertSectionsIntoAll(sections, atIndex: indexOfAll)
        insertSectionsIntoForm(filterSections, atIndex: indexOfForm)
    }
        
    public func remove(_ section: SectionDescriptor) {
        remove([section])
    }
    
    public func remove(_ sections: [SectionDescriptor]) {
        removeSectionsFromAll(sections)
        removeSectionsFromForm(sections)
    }
    
    public func remove(at index: Int) {
        remove([sourceFormSections[index] as! SectionDescriptor])
    }
    
    public func section(at index: Int) -> SectionDescriptor? {
        if index >= 0 && index < sourceFormSections.count {
            return (sourceFormSections[index] as! SectionDescriptor)
        }
        return nil
    }
    
    public func sections(at indexes: IndexSet) -> [SectionDescriptor]? {
        var res = [SectionDescriptor]()
        indexes.forEach { idx in
            if idx >= 0 && idx < sourceFormSections.count {
                res.append(sourceFormSections[idx] as! SectionDescriptor)
            }
        }
        return res.isEmpty ? nil : res
    }
    
    public func indexOfSection(_ section: SectionDescriptor) -> Int? {
        let index = sourceFormSections.index(of: section)
        return index == NSNotFound ? nil : index
    }
}

// MARK: - Row

extension FormDescriptor {
    
    public func indexPathForRow(_ row: RowDescriptor) -> IndexPath? {
        if let section = row.section, let rowIndex = section.index(of: row), let sectionIndex = indexOfSection(section) {
            return IndexPath(row: rowIndex, section: sectionIndex)
        }
        return nil
    }
    
    public func row(withTag tag: String) -> RowDescriptor? {
        return allRowsByTag[tag]
    }
    
    public func row(at indexPath: IndexPath) -> RowDescriptor? {
        return section(at: indexPath.section)?.row(at: indexPath.row)
    }
}

// MARK: - Tag Collection

extension FormDescriptor {
        
    /** 添加行描述子到 tag 集合中 */
    func addRowToTagCollection(_ row: RowDescriptor) {
        allRowsByTag[row.tag] = row
    }
    
    func removeRowFromTagCollection(_ row: RowDescriptor) {
        allRowsByTag.removeValue(forKey: row.tag)
    }
}

// MARK: - Evaludate Section Hidden

extension FormDescriptor {
        
    func evaluateSecionIsHidden(_ section: SectionDescriptor) {
        if section.isHidden {
            hideSection(section)
        } else {
            showSection(section)
        }
    }
    
    private func hideSection(_ section: SectionDescriptor) {
        for row in section.formRows {
            if row.isCellExist && row.cell.isFirstResponder() {
                row.cell.resignFirstResponder()
                break;
            }
        }
        removeSectionsFromForm([section])
    }
    
    private func showSection(_ section: SectionDescriptor) {
        let index = firstIndexAtFormOrderedAscending(beginWithSectionAtAllSections: section)
        let indexOfForm = index == NSNotFound ? sourceFormSections.count : index
        insertSectionsIntoForm([section], atIndex: indexOfForm)
    }
}

// MARK: - Private

private extension FormDescriptor {
        
    func insertSectionsIntoAll(_ sections: [SectionDescriptor], atIndex index: Int) {
        sections.forEach { section in
            assert(!allSections.contains(section), "section: \(section) already in all sections")
            section.form = self
            
            section.allRows.forEach { row in
                addRowToTagCollection(row)
            }
        }
        allSections.insert(contentsOf: sections, at: index)
    }
    
    func removeSectionsFromAll(_ sections: [SectionDescriptor]) {
        sections.forEach { section in
            section.form = nil
            section.allRows.forEach { row in
                removeRowFromTagCollection(row)
            }
            allSections.remove(at: allSections.firstIndex(of: section)!)
        }
    }
    
    func insertSectionsIntoForm(_ sections: [SectionDescriptor], atIndex index: Int) {
        kvoFormSections.insert(sections, at: IndexSet.init(integersIn: index ..< index + sections.count))
    }
    
    func removeSectionsFromForm(_ sections: [SectionDescriptor]) {
        kvoFormSections.removeObjects(in: sections)
    }
    
    
    // 在 allSections 中，从 currentSecion 开始，逆序遍历 section，找到第一个在 sourceFormSections 存在的 section 的位置
    func firstIndexAtFormSectionsOrderedDescending(beginWithSectionAtAllSections currentSecion: SectionDescriptor) -> Int {
        var indexOfAll = allSections.firstIndex(of: currentSecion) ?? 0
        var indexOfForm = sourceFormSections.index(of: currentSecion)
        
        while indexOfForm == NSNotFound && indexOfAll > 0 {
            indexOfAll -= 1
            let previousSection = allSections[indexOfAll]
            indexOfForm = sourceFormSections.index(of: previousSection)
        }
        return indexOfForm
    }
    
    /**
     * 在 allSections 中，从 currentSecion 开始，升序遍历 section，找到第一个在 sourceFormSections 存在的 section 的位置
     *
     * 当我们要将某些隐藏状态的 section 显示出来的时候，需要调用此方法找到其原本的 index
     */
    func firstIndexAtFormOrderedAscending(beginWithSectionAtAllSections currentSecion: SectionDescriptor) -> Int {
        guard var indexOfAll = allSections.firstIndex(of: currentSecion) else { return sourceFormSections.count }
        
        let countOfAll = allSections.count
        var indexOfForm = sourceFormSections.index(of: currentSecion)
        
        while indexOfForm == NSNotFound && indexOfAll < (countOfAll - 1) {
            indexOfAll += 1
            let nextSection = allSections[indexOfAll]
            indexOfForm = sourceFormSections.index(of: nextSection)
        }
        return indexOfForm
    }
}
