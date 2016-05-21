//
//  ActionBarItem.swift
//  FilePreviewController
//
//  Created by WangWei on 16/5/21.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import Foundation

import Foundation

public typealias BarActionClosure = (FilePreviewController, ActionBarItem) -> Void

public class ActionBarItem: NSObject {
    public var barButtonItem: UIBarButtonItem!
    public var action: BarActionClosure?
    public weak var filePreviewController: FilePreviewController?
    
    public init(title: String?, style: UIBarButtonItemStyle, action: BarActionClosure? = nil) {
        super.init()
        self.action = action
        barButtonItem = UIBarButtonItem(title: title, style: .Plain, target: self, action: #selector(ActionBarItem.triggerAction))
    }
    
    public init(image: UIImage?, style: UIBarButtonItemStyle, action: BarActionClosure? = nil) {
        super.init()
        self.action = action
        barButtonItem = UIBarButtonItem(image: image, style: style, target: self, action: #selector(ActionBarItem.triggerAction))
    }
    
    public init(barButtonItem: UIBarButtonItem, action: BarActionClosure? = nil) {
        super.init()
        self.barButtonItem = barButtonItem
        self.action = action
    }
    
    func triggerAction() {
        guard let filePreviewController = filePreviewController, action = action else {
            return
        }
        action(filePreviewController, self)
    }
}

public extension FilePreviewController {
    func addActionBarItem(title title: String?, style: UIBarButtonItemStyle, action: BarActionClosure?) {
        let barItem = ActionBarItem(title: title, style: style, action: action)
        barItem.filePreviewController = self
        actionItems.append(barItem)
    }
    
    func insert(actionBarItem: ActionBarItem, at index: Int) {
        let barItem = actionBarItem
        barItem.filePreviewController = self
        actionItems.insert(barItem, atIndex: index)
    }
    
    func removeAllToolbarItems() {
        actionItems.removeAll()
    }
}