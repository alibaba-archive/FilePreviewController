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

class ViewController: UIViewController {
    let jpg = "https://pic4.zhimg.com/b06cb1c48ef44b75911c6f11fc8b68b7_b.jpg"
    var filePreviewController: FilePreviewController?
    var fileItems: [FilePreviewItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        print("filePathComponent: \(FilePreviewControllerConstants.filePathComponent)")
        
        generateFileItems()
    }
    
    @IBAction func automaticPresent(_ sender: Any) {
        if self.presentingViewController != nil {
            self.dismiss(animated: true, completion: nil)
        } else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController")
            present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
        }
        
    }
    
    
    private func generateFileItems() {
        //jpg
        let url = URL(string: jpg)
        let jpgItem = FilePreviewItem(previewItemURL: url!, previewItemTitle: "Good Good File/Good File.jpg", fileExtension: "jpg", fileKey: "0013b1f8a28f28755112197a1f57a2fc89ba")
        
        // pdf
        let mp3 = URL(string: "https://devstreaming-cdn.apple.com/videos/wwdc/2017/102xyar2647hak3e/102/102_platforms_state_of_the_union.pdf")
        let pdfItem = FilePreviewItem(previewItemURL: mp3!, previewItemTitle: "Platforms State of the Union ehfejrfbrefjhebfh.pdf", fileExtension: "pdf", fileKey: "130tb7d3d6f287ae7ef1d40eec2f68175d89")
        
        // video
        let mov = URL(string: "https://www.teambition.com/api/works/59ba602a4b84a74b543216bd/download/bug-%E5%8E%86%E5%8F%B2%E7%89%88%E6%9C%AC%E6%9B%B4%E5%A4%9A%E6%8C%89%E9%92%AE%E7%82%B9%E5%87%BB%E4%B8%A4%E6%AC%A1.mov?signature=eyJhbGciOiJIUzI1NiJ9.eyJfd29ya0lkIjoiNTliYTYwMmE0Yjg0YTc0YjU0MzIxNmJkIiwiZmlsZUtleSI6IjEzMHczYjQwZTQ4ZTVhOTk2Y2M0Njg2Y2ViZTVlMTMzNjA5MSIsIl91c2VySWQiOiI1NDI1NDJmZjg4MmE2YzcwMGJiOTMwNmIiLCJleHAiOjE1MjE2OTk1ODksInN0b3JhZ2UiOiJzdHJpa2VyLWh6In0.WFlO0NaiutXir52iZV8O5FJHeHhXrLVXsJ26SX4lDxI")!
        let vedioItem = FilePreviewItem(previewItemURL: mov, previewItemTitle: "bug-历史版本更多按钮点击jkehfejrfhrjfr两次.mov", fileExtension: "mov", fileKey: "130w3b40e48e5a996cc4686cebe5e1336091")
        
        // mp4
        
        let mp4 = URL(string: "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8")!
        let mp4Item = FilePreviewItem(previewItemURL: mp4, previewItemTitle: "49DCA8D7-ADD7-487D-83E2-C414D6F9AE23.mp4", fileExtension: "mp4", fileKey: "1013eff73697f68b5e981613debcdcf9673b")
        
        // .key
        let key = URL(string: "https://www.teambition.com/api/works/5982eb8b3538227e6a1f74f5/download/JS%E4%B8%8E%E5%8E%9F%E7%94%9F%E7%9A%84%E9%80%9A%E4%BF%A1.key?signature=eyJhbGciOiJIUzI1NiJ9.eyJfd29ya0lkIjoiNTk4MmViOGIzNTM4MjI3ZTZhMWY3NGY1IiwiZmlsZUtleSI6IjEwMHZhYTBjN2UxOWRhYzUwYTRiOGI5ZjY3MDllNzkxMjBkZiIsIl91c2VySWQiOiI1NDI1NDJmZjg4MmE2YzcwMGJiOTMwNmIiLCJleHAiOjE1MjE3MDkyNjksInN0b3JhZ2UiOiJzdHJpa2VyLWh6In0.eUotHEYA9vh2P7zQyLun6j16TPWA9BLp3u5jHEWt-S0")!
        let keyItem = FilePreviewItem(previewItemURL: key, previewItemTitle: "JS与原生的通信.key", fileExtension: "key", fileKey: "100vaa0c7e19dac50a4b8b9f6709e79120df")
        
        // .xlsx
        let excel = URL(string: "https://www.teambition.com/api/works/5ab0ce87f294720012bf4937/download/xlsx%20Document.xlsx?signature=eyJhbGciOiJIUzI1NiJ9.eyJfd29ya0lkIjoiNWFiMGNlODdmMjk0NzIwMDEyYmY0OTM3IiwiZmlsZUtleSI6IjEyMTMwNmEyMTZhZGRhODEwZWZkNTYyMjFmNDVmMWU1OGY2MCIsIl91c2VySWQiOiI1NDI1NDJmZjg4MmE2YzcwMGJiOTMwNmIiLCJleHAiOjE1MjE3MDk0NjIsInN0b3JhZ2UiOiJzdHJpa2VyLWh6In0._cfy94lfOm6FK5eqAGtxB9AQpDuTGUB3Bz57FEuD-BA")!
        let excelItem = FilePreviewItem(previewItemURL: excel, previewItemTitle: "xlsx Document.xlsx", fileExtension: "xlsx", fileKey: "121306a216adda810efd56221f45f1e58f60")
        
        // zip
        let zip = URL(string: "https://www.teambition.com/api/works/5a98ff5eab009e03ff272e3a/download/%E6%96%B0%E5%9E%8B%E6%8A%A5%E5%91%8A.zip?signature=eyJhbGciOiJIUzI1NiJ9.eyJfd29ya0lkIjoiNWE5OGZmNWVhYjAwOWUwM2ZmMjcyZTNhIiwiZmlsZUtleSI6IjEwMTJjMmRmYjhmNmNjNWUwYjI0OWU4NjUyZjAwNThkNDdkNiIsIl91c2VySWQiOiI1NDI1NDJmZjg4MmE2YzcwMGJiOTMwNmIiLCJleHAiOjE1MjE2ODc3ODIsInN0b3JhZ2UiOiJzdHJpa2VyLWh6In0.eTy6-UQ-Mi4nnuXbwCGEkdsju12fEPuQzBB28KTghn0")
        let zipItem = FilePreviewItem(previewItemURL: zip!, previewItemTitle: "新型报告.zip", fileExtension: "zip", fileKey: "0013b1f8a28f28755112197a1f57a2fca89b")
        
        fileItems = [jpgItem, pdfItem, keyItem, excelItem, vedioItem, mp4Item, zipItem]
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let fileItem = fileItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "fileCell", for: indexPath)
        cell.imageView?.image = #imageLiteral(resourceName: "fileIcon")
        cell.textLabel?.text = fileItem.previewItemTitle
        cell.textLabel?.lineBreakMode = .byTruncatingMiddle
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        let fileItem = fileItems[indexPath.row]
        openItem(fileItem, fromCell: cell)
    }
    
    private func openItem(_ item: FilePreviewItem, fromCell cell: UITableViewCell) {
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
        
        // Show SingleFilePreviewController, you can also push it into navigation controller
        let singleFilePreviewController = SingleFilePreviewController(previewItem: item)
        singleFilePreviewController.isEnableShare = true
        singleFilePreviewController.actionItems = [item1, item2]
        singleFilePreviewController.controllerDelegate = self
        let navigation = UINavigationController(rootViewController: singleFilePreviewController)
        presentFilePreviewController(viewControllerToPresent: navigation, fromView: cell.imageView)
        
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
}

// MARK: - FilePreviewControllerDelegate
extension ViewController: FilePreviewControllerDelegate {
    func previewController(_ controller: FilePreviewController, failedToLoadRemotePreviewItem item: FilePreviewItem, error: NSError) {
    }
    
    func previewController(_ controller: FilePreviewController, willShareItem item: FilePreviewItem) {
        print("Custom Share Action")
    }
    
    func previewController(_ controller: FilePreviewController, showMoreItems item: FilePreviewItem) {
        print("Custom show more item")
    }
    
    func previewController(_ controller: FilePreviewController, willDownloadItem item: FilePreviewItem) {
        print("Start download")
    }
    
    func previewController(_ controller: FilePreviewController, downloadedItem item: FilePreviewItem, error: Error?) {
        print("Downloaded: \(error.debugDescription)")
    }
}

