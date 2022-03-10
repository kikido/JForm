//
//  CommonAttributes.swift
//  JForm
//
//  Created by dqh on 2021/7/19.
//

import Foundation
import UIKit
import CoreGraphics


/** 表单主题红色 */
let jFormRed = UIColor(hexString: "ff3131")

// MARK: - Cell UI

let jCellBackgroundColor = UIColor.white
/** 标题颜色 */
let jCellTitleDefaultColor = UIColor(hexString: "333333")
/** 标题高亮颜色 */
let jCellTitleHighlightColor = UIColor(hexString: "407eea")
/** 标题只读时颜色 */
let jCellTitleDisabledColor = UIColor(hexString: "aaaaaa")
/** 详情颜色 */
let jCellDetailDefaultColor = UIColor(hexString: "333333")
/** 详情只读时颜色 */
let jCellDetailDisabledColor = UIColor(hexString: "d7d7d7")
/** 占位文本颜色 */
let jCellPlaceholderColor = UIColor(hexString: "dbdbdb")

/** 标题字体 */
let jCellTitleDefaultFont = UIFont.systemFont(ofSize: 16)
/** 标题高亮字体 */
let jCellTitleHighlightFont = UIFont.systemFont(ofSize: 16)
/** 标题只读时字体 */
let jCellTitleDisabledFont = UIFont.systemFont(ofSize: 16)
/** 详情字体 */
let jCellDetailDefaultFont = UIFont.systemFont(ofSize: 15)
/** 详情只读时字体 */
let jCellDetailDisabledFont = UIFont.systemFont(ofSize: 15)
/** 占位文本字体 */
let jCellPlaceholderCFont = UIFont.systemFont(ofSize: 15)


// MARK: - Cell

// @textField
let cellTitleMaxHeight: CGFloat = 100
let cellTitleMinHeight: CGFloat = 30
let cellTextfieldHeight: CGFloat = 30

// @textView
let cellTextViewHeight: CGFloat = 100

// @info
let cellLongInfoMinHeight: CGFloat = 20

