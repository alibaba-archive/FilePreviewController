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
    
    @IBAction func buttonTap(_ sender: UIButton) {
        let item1 = FPActionBarItem(title: "ONE", style: .plain) { (controller, _) in
            let viewController = UIViewController()
            viewController.title = "After FilePreviewController"
            viewController.view.backgroundColor = UIColor.white
            controller.navigationController?.pushViewController(viewController, animated: true)
        }
        item1.barButtonItem.tintColor = UIColor.black

        let item2 = FPActionBarItem(title: "TWO", style: .plain) { (controller, item) in
            controller.beginUpdate()
            controller.update(progress: 0.5)
            print(item)
        }
        item2.barButtonItem.tintColor = UIColor.black
        
//        let url = NSURL(string: jpg)
//        let item = FilePreviewItem(previewItemURL: url!, previewItemTitle: "Good Good File/Good File.jpg", fileExtension: "jpg")
        
        let mp3 = URL(string: "https://striker.teambition.net/storage/100kf674d16270578354550f650a5c245ece?download=Agile-Scrum-Lean%20Startup%E5%BD%95%E9%9F%B3-%E5%A7%9C%E7%BF%94-20160908.mp3&Signature=eyJhbGciOiJIUzI1NiJ9.eyJyZXNvdXJjZSI6Ii9zdG9yYWdlLzEwMGtmNjc0ZDE2MjcwNTc4MzU0NTUwZjY1MGE1YzI0NWVjZSIsImV4cCI6MTQ3NDI0MzIwMH0.15JpJhYPh5w332TmLgGYrQzfT0jsDdRCTlHyz6frfsY")
        let item = FilePreviewItem(previewItemURL: mp3!, previewItemTitle: "123.mp3", fileExtension: "mpge")
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
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let url = URL(string: jpg)
        let item = FilePreviewItem(previewItemURL: url!, previewItemTitle: "Good File", fileExtension: "csv")
        return item
    }
    
    func previewController(_ controller: FilePreviewController, failedToLoadRemotePreviewItem item: FilePreviewItem, error: NSError) {
    }

    func previewController(_ controller: FilePreviewController, willShareItem item: FilePreviewItem) {
        print("Custom Share Action")
    }

    func createWebView() {
    }

}

