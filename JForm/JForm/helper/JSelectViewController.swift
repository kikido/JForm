//
//  JSelectViewController.swift
//  JForm
//
//  Created by dqh on 2021/7/26.
//

import Foundation
import AsyncDisplayKit

class JSelectViewController: ASDKViewController<ASDisplayNode> {
    
    let tableNode: ASTableNode
    let row: RowDescriptor
    let form: JForm?
    
    lazy var selectIndexSet = IndexSet()
    
    public init(row: RowDescriptor, form: JForm?) {
        self.row = row
        self.form = form
        
        tableNode = ASTableNode(style: .grouped)
        super.init(node: tableNode)

        tableNode.backgroundColor = UIColor(hexString: "f0f0f0")
        tableNode.delegate = self
        tableNode.dataSource = self
    #if DEBUG
        tableNode.accessibilityIdentifier = "tableview"
        tableNode.accessibilityLabel = "tableview"
        tableNode.view.accessibilityLabel = "tableview"
    #endif
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 计算出哪几行被选中了
        if row.type == .multipleSelect {
            if let selectItems = row.value as? [OptionItem] {
                for item in selectItems {
                    if let index = row.optionItmes?.firstIndex(of: item) {
                        selectIndexSet.insert(index)
                    }
                }
            }
        }
        else if row.type == .pushSelect {
            if let value = row.value as? OptionItem, let index = row.optionItmes?.firstIndex(of: value) {
                selectIndexSet.insert(index)
            }
        }
        tableNode.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = row.selectorTitle
    }
}

extension JSelectViewController: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return row.optionItmes?.count ?? 0
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        if let option = row.optionItmes?[indexPath.row] {
            let cell = ASTextCellNode()
            cell.backgroundColor = UIColor.white
            cell.selectionStyle = .none
            cell.accessoryType = selectIndexSet.contains(indexPath.row) ? .checkmark : .none
            cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
            cell.textInsets = UIEdgeInsets(top: 20, left: 15, bottom: 20, right: 0)
            cell.textNode.attributedText = appendInterpolation(option.title, style: .font(row.detailFont), .color(row.detailColor), .alignment(.left))
            return cell
        }
        return ASCellNode()
    }
}

extension JSelectViewController: ASTableDelegate {
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableNode.cellForRow(at: indexPath) {
            let isContains = selectIndexSet.contains(indexPath.row)
            // filter
            if isContains {
                selectIndexSet.remove(indexPath.row)
                cell.accessoryType = .none
            } else {
                if row.type == .pushSelect {
                    selectIndexSet.removeAll()
                }
                selectIndexSet.insert(indexPath.row)
                cell.accessoryType = .checkmark
            }
            
            // get value
            var value: Any? = nil
            if selectIndexSet.count == 0 { // no select
                value = nil
            }
            else if row.type == .pushSelect { // pop back
                if let valueTransformer = row.valueTransformer {
                    row.setValueToTriggerKVO(valueTransformer.reverseTransformedValue(row.optionItmes![selectIndexSet.first!]))
                }
                else {
                    row.setValueToTriggerKVO(row.optionItmes![selectIndexSet.first!])
                }
                self.navigationController?.popViewController(animated: true)
                return
            }
            else if row.type == .multipleSelect { // multiple select
                value = selectIndexSet.sorted().map { row.optionItmes![$0] }
            }
            
            // set value
            if let valueTransformer = row.valueTransformer {
                row.setValueToTriggerKVO(valueTransformer.reverseTransformedValue(value))
            }
            else {
                row.setValueToTriggerKVO(value)
            }
        }
        tableNode.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
}
