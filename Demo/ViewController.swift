//
//  ViewController.swift
//  Demo
//
//  Created by WangWei on 16/2/19.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit
import FilePreviewController
import QuickLook

class ViewController: UIViewController, QLPreviewControllerDataSource, FilePreviewControllerDelegate {

    var filePreviewController: FilePreviewController?
    var singleFilePreviewController: SingleFilePreviewController?
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func buttonTap(sender: UIButton) {
        
        let item1 = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Bookmarks, target: self, action: #selector(pushInNewViewController))
        item1.tintColor = UIColor.blackColor()
        let item2 = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Camera, target: self, action: nil)
        item2.tintColor = UIColor.blackColor()
        let item3 = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: nil)
        item3.tintColor = UIColor.blackColor()
        
        let str3 = "https://www.google.com/intl/zh-CN/policies/privacy/google_privacy_policy_zh-CN.pdf"
        let url = NSURL(string: str3)
        let item = FilePreviewItem(previewItemURL: url!, previewItemTitle: "Good File", fileExtension: "pdf")
        
        // Show SingleFilePreviewController, you can also push it into navigation controller
        singleFilePreviewController = SingleFilePreviewController(previewItem: item)
        if let singleFilePreviewController = singleFilePreviewController {
            singleFilePreviewController.toolbarItems = [item1, item2, item3]
            let navigation = UINavigationController(rootViewController: singleFilePreviewController)
            presentFilePreviewController(viewControllerToPresent: navigation, fromView: sender)
        }
        
        // Show original FilePreviewController
//        filePreviewController = FilePreviewController()
//        if let filePreviewController = filePreviewController {
//            filePreviewController.controllerDelegate = self
//            filePreviewController.dataSource = self
//            filePreviewController.toolbarItems = [item1, item2, item3]
//            navigationController?.pushViewController(filePreviewController, animated: true)
//            let navigation = UINavigationController(rootViewController: filePreviewController)
//            showFilePreviewController(navigation, fromView: sender)
//        }
    }
    
    func pushInNewViewController() {
        let controller = UIViewController()
        controller.title = "After Preview Controller"
        controller.view.backgroundColor = UIColor.whiteColor()
        presentedViewController?.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    // MARK: Demo for FilePreviewController
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
        let str3 = "https://www.google.com/intl/zh-CN/policies/privacy/google_privacy_policy_zh-CN.pdf"
        let url = NSURL(string: str3)
        let item = FilePreviewItem(previewItemURL: url!, previewItemTitle: "Good File", fileExtension: "pdf")
        return item
    }
    
    func previewController(controller: FilePreviewController, failedToLoadRemotePreviewItem item: QLPreviewItem, error: NSError) {
    }


}

