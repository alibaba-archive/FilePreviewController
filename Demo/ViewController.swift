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
    let jpg = "https://pic4.zhimg.com/b06cb1c48ef44b75911c6f11fc8b68b7_b.jpg"
    var filePreviewController: FilePreviewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        print("filePathComponent: \(FilePreviewControllerConstants.filePathComponent)")
    }
    
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
        
        let url = NSURL(string: jpg)
        let item = FilePreviewItem(previewItemURL: url!, previewItemTitle: "Good Good File/Good File.jpg", fileExtension: "jpg")

        // Show SingleFilePreviewController, you can also push it into navigation controller
        let singleFilePreviewController = SingleFilePreviewController(previewItem: item)
        singleFilePreviewController.enableShare = true
        singleFilePreviewController.actionItems = [item1, item2]
        singleFilePreviewController.controllerDelegate = self
        let navigation = UINavigationController(rootViewController: singleFilePreviewController)
        presentFilePreviewController(viewControllerToPresent: navigation, fromView: sender)
        
        /*
         // Show original FilePreviewController
        filePreviewController = FilePreviewController()
        if let filePreviewController = filePreviewController {
            filePreviewController.controllerDelegate = self
            filePreviewController.dataSource = self
            filePreviewController.toolbarItems = [item1, item2, item3]
            navigationController?.pushViewController(filePreviewController, animated: true)
            let navigation = UINavigationController(rootViewController: filePreviewController)
            showFilePreviewController(navigation, fromView: sender)
        }
         */
    }
    
    // MARK: Demo for FilePreviewController
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
        let url = NSURL(string: jpg)
        let item = FilePreviewItem(previewItemURL: url!, previewItemTitle: "Good File", fileExtension: "csv")
        return item
    }
    
    func previewController(controller: FilePreviewController, failedToLoadRemotePreviewItem item: FilePreviewItem, error: NSError) {
    }

    func previewController(controller: FilePreviewController, willShareItem item: FilePreviewItem) {
        print("Custom Share Action")
    }

    func createWebView() {
    }

}

