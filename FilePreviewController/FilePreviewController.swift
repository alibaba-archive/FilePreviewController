//
//  FilePreviewController.swift
//  FilePreviewController
//
//  Created by WangWei on 16/2/22.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import Foundation
import QuickLook
import Alamofire

public extension String {
    public func MD5() -> String {
        return (self as NSString).MD5() as String
    }
    
    public func stringByAppendingPathComponent(str: String) -> String {
        return (self as NSString).stringByAppendingPathComponent(str)
    }
    
    public func stringByAppendingPathExtension(str: String) -> String? {
        return (self as NSString).stringByAppendingPathExtension(str)
    }
}

func localFilePathFor(URL: NSURL, fileExtension: String? = nil) -> String? {
    
    let fileType = fileExtension ?? URL.pathExtension
    let hashedURL = URL.absoluteString.MD5()
    
    guard var cacheDirectory = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).last else {
        return nil
    }
    cacheDirectory = cacheDirectory.stringByAppendingPathComponent("com.teambition.RemoteQuickLook")
    var isDirectory: ObjCBool = false
    if !NSFileManager.defaultManager().fileExistsAtPath(cacheDirectory, isDirectory: &isDirectory) || !isDirectory {
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch _{
            return nil
        }
    }
    cacheDirectory = cacheDirectory.stringByAppendingPathComponent(hashedURL)
    if let pathExtension = fileType {
        if let temDir = cacheDirectory.stringByAppendingPathExtension(pathExtension) {
            cacheDirectory = temDir
        }
    }
    
    return cacheDirectory
}

public class FilePreviewItem: NSObject, QLPreviewItem {
    public var previewItemURL: NSURL
    public var previewItemTitle: String?
    
    /// when fileExtension is nil, will try to get pathExtension from previewItemURL
    public var fileExtension: String?
    
    public init(previewItemURL: NSURL, previewItemTitle: String? = nil, fileExtension: String? = nil) {
        self.previewItemURL = previewItemURL
        self.previewItemTitle = previewItemTitle
        self.fileExtension = fileExtension
        super.init()
    }
}

public protocol FilePreviewControllerDelegate: NSObjectProtocol {
    func previewController(controller: FilePreviewController, failedToLoadRemotePreviewItem item:QLPreviewItem, error: NSError)
}

public class FilePreviewController: QLPreviewController {
    
    /// if header is not nil, Alamofire will use it for authentication
    public var headers: [String: String]?
    
    var originalDataSource: QLPreviewControllerDataSource?
    
    var progress: CGFloat = 0
    var progressBar: UIProgressView?
    var toolbar: UIToolbar?
    
    var toolbarBottomConstraint: NSLayoutConstraint?
    
    public weak var controllerDelegate: FilePreviewControllerDelegate?
    
    override public weak var dataSource: QLPreviewControllerDataSource? {
        get {
            return originalDataSource
        }
        set {
            super.dataSource = self
            originalDataSource = newValue
        }
    }
    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        cancelProgress()
    }
    
}

extension FilePreviewController {
    func downloadFor(item: FilePreviewItem) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        guard let localFilePath = localFilePathFor(item.previewItemURL, fileExtension: item.fileExtension) else {
            if let controllerDelegate = self.controllerDelegate {
                let error = Error.errorWithCode(.LocalCacheDirectoryCreateFailed, failureReason: "Create cache directory failed")
                controllerDelegate.previewController(self, failedToLoadRemotePreviewItem: item, error: error)
            }
            return
        }
        
        download(.GET, item.previewItemURL.absoluteString, parameters: nil, encoding:.URL, headers: headers) { (temporaryURL, response) -> NSURL in
            
            let localFileURL = NSURL.fileURLWithPath(localFilePath)
            return localFileURL
            }.progress { (bytesReceived, totalBytesReceived, totalBytesExpectedToReceived) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let progress = CGFloat(totalBytesReceived) / CGFloat(totalBytesExpectedToReceived)
                    self.updateProgress(progress)
                })
            }.response {(_, response, _, error) -> Void in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                self.cancelProgress()
                if let error = error {
                    if let controllerDelegate = self.controllerDelegate {
                        let rasieError = Error.errorWithCode(.RemoteFileDownloadFailed, failureReason: "Download remote file failed", error: error)
                        controllerDelegate.previewController(self, failedToLoadRemotePreviewItem: item, error: rasieError)
                    }
                } else {
                    self.refreshCurrentPreviewItem()
                }
        }
    }
    
    func updateProgress(newProgress: CGFloat) {
        if progressBar == nil {
            progressBar = UIProgressView(progressViewStyle: .Bar)
            layoutProgressBar()
        }
        guard let progressBar = progressBar else {
            return
        }
        if progress == 1.0 {
            cancelProgress()
        }
        progress = newProgress
        progressBar.progress = Float(newProgress)
    }
    
    func cancelProgress() {
        guard let progressBar = progressBar else {
            return
        }
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            progressBar.alpha = 0
            }, completion: { (_) -> Void in
                progressBar.removeFromSuperview()
        })
    }
    
    func layoutProgressBar() {
        guard let navigationBar = navigationController?.navigationBar, progressBar = progressBar else {
            return
        }
        if !navigationBar.subviews.contains(progressBar) {
            progressBar.tintColor = navigationBar.tintColor
            navigationBar.addSubview(progressBar)
        }
        let navigationBarHeight = CGRectGetHeight(navigationBar.frame)
        let navigationBarWidth = CGRectGetWidth(navigationBar.frame)
        let progressBarHeight = CGRectGetHeight(progressBar.frame)
        progressBar.frame = CGRectMake(0, navigationBarHeight - progressBarHeight, navigationBarWidth, progressBarHeight)
    }
    
    public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        coordinator.animateAlongsideTransition({ (_) -> Void in
            self.layoutProgressBar()
            }, completion: nil)
    }
}

extension FilePreviewController: QLPreviewControllerDataSource {
    
    //This method is required to expose, don't call it
    public func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
        guard let originalDataSource = originalDataSource else {
            return 0
        }
        return originalDataSource.numberOfPreviewItemsInPreviewController(controller)
    }
    
    //This method is required to expose, don't call it
    public func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
        
        let originalPreviewItem = (originalDataSource!.previewController(controller, previewItemAtIndex: index)) as! FilePreviewItem
        
        if originalPreviewItem.previewItemURL.isFileReferenceURL() {
            return originalPreviewItem
        }
        
        //If it's a remote file, check cache
        
        var copyItem: FilePreviewItem!
        if let itemTitle = originalPreviewItem.previewItemTitle {
            copyItem = FilePreviewItem(previewItemURL: originalPreviewItem.previewItemURL, previewItemTitle: itemTitle)
        } else {
            copyItem = FilePreviewItem(previewItemURL: originalPreviewItem.previewItemURL)
        }
        
        guard let localFilePath = localFilePathFor(originalPreviewItem.previewItemURL, fileExtension: originalPreviewItem.fileExtension) else {
            //failed to get local file path
            if let controllerDelegate = self.controllerDelegate {
                let error = Error.errorWithCode(.LocalCacheDirectoryCreateFailed, failureReason: "Create cache directory failed")
                controllerDelegate.previewController(self, failedToLoadRemotePreviewItem: originalPreviewItem, error: error)
            }
            return originalPreviewItem
        }
        copyItem.previewItemURL = NSURL.fileURLWithPath(localFilePath)
        
        if NSFileManager.defaultManager().fileExistsAtPath(localFilePath) {
            return copyItem
        } else {
            //Download remote file if cache not exist
            downloadFor(originalPreviewItem)
        }
        
        return copyItem
    }
}

















