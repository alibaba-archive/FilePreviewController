//
//  FPActionBarItem.swift
//  FilePreviewController
//
//  Created by WangWei on 16/5/21.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import Foundation

import Foundation

public typealias BarActionClosure = (FilePreviewController, FPActionBarItem) -> Void

open class FPActionBarItem: NSObject {
    open var barButtonItem: UIBarButtonItem!
    open var action: BarActionClosure?
    open weak var filePreviewController: FilePreviewController?
    
    public init(title: String?, style: UIBarButtonItem.Style, action: BarActionClosure? = nil) {
        super.init()
        self.action = action
        barButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(FPActionBarItem.triggerAction))
    }
    
    public init(image: UIImage?, style: UIBarButtonItem.Style, action: BarActionClosure? = nil) {
        super.init()
        self.action = action
        barButtonItem = UIBarButtonItem(image: image, style: style, target: self, action: #selector(FPActionBarItem.triggerAction))
    }
    
    public init(barButtonItem: UIBarButtonItem, action: BarActionClosure? = nil) {
        super.init()
        self.barButtonItem = barButtonItem
        self.action = action
    }
    
    @objc func triggerAction() {
        guard let filePreviewController = filePreviewController, let action = action else {
            return
        }
        action(filePreviewController, self)
    }
}

public extension FilePreviewController {
    func addActionBarItem(title: String?, style: UIBarButtonItem.Style, action: BarActionClosure?) {
        let barItem = FPActionBarItem(title: title, style: style, action: action)
        barItem.filePreviewController = self
        actionItems.append(barItem)
    }
    
    func insert(_ actionBarItem: FPActionBarItem, at index: Int) {
        let barItem = actionBarItem
        barItem.filePreviewController = self
        actionItems.insert(barItem, at: index)
    }
    
    func removeAllToolbarItems() {
        actionItems.removeAll()
    }
}
