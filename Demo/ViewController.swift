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
        
        let mp3 = URL(string: "https://www.teambition.com/api/works/5853a4fc2ed98806395f58b3/download/%25E6%259C%25AA%25E5%2591%25BD%25E5%2590%258D.txt.txt?signature=eyJhbGciOiJIUzI1NiJ9.eyJfd29ya0lkIjoiNTg1M2E0ZmMyZWQ5ODgwNjM5NWY1OGIzIiwiZmlsZUtleSI6IjEwMG4wNzBmMWYwYjc1YjRlZjMyOTQ3MmU1YTJmMmY1ZWY2MyIsIl91c2VySWQiOiI1MmE2Y2MyZGVmNjZiYzk4MGMwMDAzMTIiLCJleHAiOjE0ODIwNTE4NDksInN0b3JhZ2UiOiJzdHJpa2VyLWh6In0.EWuP56TtVpUtBIUZnj-3ZcB5M8YOSRY-2uHRpglcXiQ")
        let item = FilePreviewItem(previewItemURL: mp3!, previewItemTitle: "123.text", fileExtension: "text")
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

