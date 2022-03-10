//
//  TestViewController.swift
//  JForm
//
//  Created by dqh on 2022/1/19.
//

import Foundation
import AsyncDisplayKit

class TestViewController: UIViewController {
    
    var tablenode: ASTableNode!
    
//    required init() {
//c
//        super.init()
//
//        tablenode.dataSource = self
//        tablenode.delegate = self
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func viewDidLoad() {
        tablenode = ASTableNode(style: .plain)
        tablenode.dataSource = self
        tablenode.delegate = self
        tablenode.frame = self.view.bounds
        self.view.addSubnode(tablenode)
    
        let button = UIButton.init(type: .custom)
        button.setTitle("测试", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        let buttonItem = UIBarButtonItem.init(customView: button)
        self.navigationItem.rightBarButtonItem = buttonItem
        
        self.modalPresentationStyle = .formSheet
    }
    
    @objc func buttonAction() {
        self.view.endEditing(true)
    }
}

extension TestViewController: ASTableDataSource, ASTableDelegate {
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return 60
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        let row = indexPath.row
        
        if row < 20 {
            return OneCellNode(title: "row \(row)")
        } else if row < 40 {
            return TwoCellNode(title: "two \(row)")
        } else {
            return ThreeCellNode(title: "two \(row)")
        }
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        let cell = tableNode.nodeForRow(at: indexPath)
        cell?.becomeFirstResponder()
    }
}


class OneCellNode: ASCellNode {
    let textFieldNode: ASDisplayNode
    var textField: UITextField?
    let titleNode: ASTextNode
    
    init(title withTitlte: String) {
        textFieldNode = ASDisplayNode.init { UITextField() }
        textFieldNode.backgroundColor = UIColor.lightGray
        titleNode = ASTextNode()
        titleNode.attributedText = appendInterpolation(withTitlte, style: .color(UIColor.blue))
        
        super.init()
        
        self.automaticallyManagesSubnodes = true
    }
    
    override func didLoad() {
        textField = textFieldNode.view as? UITextField
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        titleNode.style.width = ASDimensionMake(150)
        textFieldNode.style.flexGrow = 1
        textFieldNode.style.height = ASDimensionMake(30)
        let h = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .spaceBetween, alignItems: .center, children: [titleNode, textFieldNode])
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 20, left: 12, bottom: 20, right: 12), child: h)
    }
    
    //
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    override func becomeFirstResponder() -> Bool {
        return textField?.becomeFirstResponder() ?? false
    }
    
    override func isFirstResponder() -> Bool {
//        return textField?.isFirstResponder ?? false
        let ans = textField?.isFirstResponder ?? false
        return ans
    }
    
    override func canResignFirstResponder() -> Bool {
        return true
    }
    
    override func resignFirstResponder() -> Bool {
        return textField?.resignFirstResponder() ?? false
    }
    
    
}

class TwoCellNode: ASCellNode {
    let triggerNode: ASEditableTextNode
    let titleNode: ASTextNode
    
    init(title withTitlte: String) {
        triggerNode = ASEditableTextNode()
        triggerNode.backgroundColor = .lightGray
        
        titleNode = ASTextNode()
        titleNode.attributedText = appendInterpolation(withTitlte, style: .color(UIColor.blue))
        
        super.init()
        
        self.automaticallyManagesSubnodes = true
    }
    
    override func didLoad() {
        let picker = UIDatePicker()
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        }
        picker.addTarget(self, action:#selector(valuechanged) , for: .valueChanged)
        
        triggerNode.textView.inputView = picker
    }
    
    @objc func valuechanged() {
        let a = 1;
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        titleNode.style.width = ASDimensionMake(150)
        triggerNode.style.flexGrow = 1
        let h = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .spaceBetween, alignItems: .center, children: [titleNode, triggerNode])
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12), child: h)
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    override func becomeFirstResponder() -> Bool {
        return triggerNode.becomeFirstResponder()
    }
    
    override func isFirstResponder() -> Bool {
        return triggerNode.isFirstResponder()
    }
    
    override func canResignFirstResponder() -> Bool {
        return true
    }
    
    override func resignFirstResponder() -> Bool {
        return triggerNode.resignFirstResponder()
    }
}

class ThreeCellNode: ASCellNode {
    let titleNode: ASTextNode
    var flag = false
    
    init(title withTitlte: String) {
        titleNode = ASTextNode()
        titleNode.attributedText = appendInterpolation(withTitlte, style: .color(UIColor.blue))

        super.init()
        
        self.automaticallyManagesSubnodes = true
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        titleNode.style.width = ASDimensionMake(150)
        let h = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .spaceBetween, alignItems: .center, children: [titleNode])
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 20, left: 12, bottom: 20, right: 12), child: h)
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    override func becomeFirstResponder() -> Bool {
//        super.becomeFirstResponder()
        
        flag = true
        UIApplication.shared.keyWindow?.endEditing(true)
        return titleNode.becomeFirstResponder()
    }
    
    override func isFirstResponder() -> Bool {
        return flag
    }
    
    override func canResignFirstResponder() -> Bool {
        return true
    }
    
    override func resignFirstResponder() -> Bool {
        flag = false
        return true
    }

}
