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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func buttonTap(sender: AnyObject) {
        
        let str3 = "https://www.google.com/intl/zh-CN/policies/privacy/google_privacy_policy_zh-CN.pdf"
        let url = NSURL(string: str3)
        let item = FilePreviewItem(previewItemURL: url!, previewItemTitle: "Good File", fileExtension: "pdf")
        
        let item1 = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Bookmarks, target: self, action: nil)
        item1.tintColor = UIColor.blackColor()
        let item2 = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Camera, target: self, action: nil)
        item2.tintColor = UIColor.blackColor()
        let item3 = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: nil)
        item3.tintColor = UIColor.blackColor()
        
        let singleFilePreviewController = SingleFilePreviewController(previewItem: item)
        singleFilePreviewController.toolbarItems = [item1, item2, item3]
        
        navigationController?.pushViewController(singleFilePreviewController, animated: true)
    }
    
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

