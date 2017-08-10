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
        
        let mp3 = URL(string: "https://www.teambition.com/api/works/590ae21bc27e18cd1421d405/download/304_best_practices_for_building_apps_used_in_business_and_education.pdf?signature=eyJhbGciOiJIUzI1NiJ9.eyJfd29ya0lkIjoiNTkwYWUyMWJjMjdlMThjZDE0MjFkNDA1IiwiZmlsZUtleSI6IjEwMHM0YzFkM2E5ZWJmYzc1OWUxMzE5NDVhNTA1YzJiZGE0MiIsIl91c2VySWQiOiI1NDI1NDJmZjg4MmE2YzcwMGJiOTMwNmIiLCJleHAiOjE1MDI1MDI5ODUsInN0b3JhZ2UiOiJzdHJpa2VyLWh6In0.Ldh7RycSNg3Uf3xTmiy8K6yxwQgxyuaveJYwvTLGZL0")
        let item = FilePreviewItem(previewItemURL: mp3!, previewItemTitle: "304_best_practices_for_building_apps_used_in_business_and_education.pdf", fileExtension: "pdf")
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

