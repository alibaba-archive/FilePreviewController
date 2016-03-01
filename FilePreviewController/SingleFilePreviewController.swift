//
//  SingleFilePreviewController.swift
//  FilePreviewController
//
//  Created by WangWei on 16/2/25.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import Foundation
import QuickLook

/// Conventine class for single file with toolbar, you may lost full screen mode when use this class
/// This class can only be push in navigation controller, otherwise it will crash
public class SingleFilePreviewController: UIViewController {
    
    public var previewItem: FilePreviewItem?
    
    var toolbar: UIToolbar?
    var toolbarBottomConstraint: NSLayoutConstraint?
    var previewControllerBottomConstraint: NSLayoutConstraint?
    var previewController: FilePreviewController = FilePreviewController()
    
    public init(previewItem: FilePreviewItem) {
        super.init(nibName: nil, bundle: nil)
        self.previewItem = previewItem
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        title = previewItem?.previewItemTitle
        view.backgroundColor = UIColor.whiteColor()
        navigationController?.navigationBar.translucent = false
        layoutPreviewController()
        layoutToolbar()
    }
}

extension SingleFilePreviewController {
    
    func layoutPreviewController() {
        previewController.dataSource = self
        previewController.controllerDelegate = self
        
        view.addSubview(previewController.view)
        addChildViewController(previewController)
        previewController.didMoveToParentViewController(self)
        
        previewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[preview]-0-|", options: [], metrics: nil, views: ["preview":previewController.view]))
        view.addConstraint(NSLayoutConstraint(item: topLayoutGuide, attribute: .Bottom, relatedBy: .Equal, toItem: previewController.view, attribute: .Top, multiplier: 1.0, constant: 0))
        previewControllerBottomConstraint = NSLayoutConstraint(item: bottomLayoutGuide, attribute: .Top, relatedBy: .Equal, toItem: previewController.view, attribute: .Bottom, multiplier: 1.0, constant: 0)
        if toolbarItems?.count > 0 {
            previewControllerBottomConstraint?.constant = 44
        } else {
            previewControllerBottomConstraint?.constant = 0
        }
        view.addConstraint(previewControllerBottomConstraint!)
    }
    
    func layoutToolbar() {
        guard let items = toolbarItems where items.count > 0 else {
            return
        }
        if toolbar == nil {
            toolbar = UIToolbar()
            if let toolbar = toolbar {
                view.addSubview(toolbar)
                toolbar.translatesAutoresizingMaskIntoConstraints = false
                view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[toolbar]-0-|", options: [], metrics: nil , views: ["toolbar":toolbar]))
                toolbar.addConstraint(NSLayoutConstraint(item: toolbar, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 44))
                toolbarBottomConstraint = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: toolbar, attribute: .Bottom, multiplier: 1.0, constant: 0)
                view.addConstraint(toolbarBottomConstraint!)
            }
        }
        
        guard let toolbar = toolbar else {
            return
        }
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        var itemsArray = [UIBarButtonItem]()
        if items.count == 1, let first = items.first {
            itemsArray = [flexSpace, first, flexSpace]
        } else if items.count == 2, let first = items.first, let last = items.last {
            itemsArray = [flexSpace, first, flexSpace, flexSpace, last, flexSpace]
        } else {
            for item in items {
                itemsArray.append(item)
                itemsArray.append(flexSpace)
            }
            if itemsArray.count > 0 {
                itemsArray.removeLast()
            }
        }
        toolbar.setItems(itemsArray, animated: false)
        toolbar.tintColor = UIColor.whiteColor()
    }
}

extension SingleFilePreviewController: QLPreviewControllerDataSource, FilePreviewControllerDelegate {
    
    //This method is required to expose, don't call it
    public func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
        return 1
    }
    
    //This method is required to expose, don't call it
    public func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
        return previewItem!
    }
    
    //This method is required to expose, don't call it
    public func previewController(controller: FilePreviewController, failedToLoadRemotePreviewItem item: QLPreviewItem, error: NSError) {
        let alertController = UIAlertController(title: "Failed To Open File", message: error.localizedDescription, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        presentViewController(alertController, animated: true) { () -> Void in
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
}
