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
    
    let mov = "https://striker.teambition.net/storage/100c6c475a9c5e09dc851834c30b77f643bb?download=IMG_0155.MOV&Signature=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJyZXNvdXJjZSI6Ii9zdG9yYWdlLzEwMGM2YzQ3NWE5YzVlMDlkYzg1MTgzNGMzMGI3N2Y2NDNiYiIsImV4cCI6MTQ2NTQ3MzYwMH0.xglyie4hDWE3H8PeGRCm-j-jeEMsC-zdySbev-NQGA0"
    let pdf = "https://striker.teambition.net/storage/100ceccd13eb309f57fb0e01f47f4b0986b0?download=%E6%98%A8%E5%A4%9C%E8%A3%99%E5%B8%A6%E8%A7%A3.pdf&Signature=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJyZXNvdXJjZSI6Ii9zdG9yYWdlLzEwMGNlY2NkMTNlYjMwOWY1N2ZiMGUwMWY0N2Y0YjA5ODZiMCIsImV4cCI6MTQ2NjEyMTYwMH0.V3hsAQw_G8fVfT5-0NgljSAnrWiteKW103bdRM4T9FE"

    var filePreviewController: FilePreviewController?

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func buttonTap(sender: UIButton) {
        let item1 = FPActionBarItem(title: "ONE", style: .Plain) { (controller, _) in
            let viewController = UIViewController()
            viewController.title = "After FilePreviewController"
            viewController.view.backgroundColor = UIColor.whiteColor()
            controller.navigationController?.pushViewController(viewController, animated: true)
        }
        item1.barButtonItem.tintColor = UIColor.blackColor()

        let item2 = FPActionBarItem(title: "TWO", style: .Plain) { (controller, item) in
            controller.beginUpdate()
            controller.update(progress: 0.5)
            print(item)
        }
        item2.barButtonItem.tintColor = UIColor.blackColor()
        
        let url = NSURL(string: pdf)
        let item = FilePreviewItem(previewItemURL: url!, previewItemTitle: "Good Good File/Good File.pdf", fileExtension: "pdf")

        // Show SingleFilePreviewController, you can also push it into navigation controller
        let singleFilePreviewController = SingleFilePreviewController(previewItem: item)
        singleFilePreviewController.enableShare = true
        singleFilePreviewController.actionItems = [item1, item2]
        let navigation = UINavigationController(rootViewController: singleFilePreviewController)
        presentFilePreviewController(viewControllerToPresent: navigation, fromView: sender)
        
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
    
    // MARK: Demo for FilePreviewController
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
//        let str3 = "https://www.google.com/intl/zh-CN/policies/privacy/google_privacy_policy_zh-CN.pdf"
        let str4 = "https://striker.teambition.net/storage/100cfe416a89a6ba84f3aa5820fad968147e?download=Teambition_API%E9%94%99%E8%AF%AF%E7%A0%81%E5%AE%9A%E4%B9%89.csv&Signature=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJyZXNvdXJjZSI6Ii9zdG9yYWdlLzEwMGNmZTQxNmE4OWE2YmE4NGYzYWE1ODIwZmFkOTY4MTQ3ZSIsImV4cCI6MTQ2NDEzNDQwMH0.b4JXuW9tMnYAor4QqDhcmv5bSb6cgRvmbg_nTfcfZ3s"
        let url = NSURL(string: str4)
        let item = FilePreviewItem(previewItemURL: url!, previewItemTitle: "Good File", fileExtension: "csv")
        return item
    }
    
    func previewController(controller: FilePreviewController, failedToLoadRemotePreviewItem item: QLPreviewItem, error: NSError) {
    }

    func createWebView() {
    }

}

