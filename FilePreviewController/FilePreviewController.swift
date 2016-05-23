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
import UIKit

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
    var url = URL
    if let fileExtension = fileExtension where url.pathExtension == nil || url.pathExtension?.characters.count == 0 {
        url = url.URLByAppendingPathExtension(fileExtension)
    }
    let hashedURL = URL.absoluteString.MD5()
    
    guard var cacheDirectory = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).last else {
        return nil
    }
    cacheDirectory = cacheDirectory.stringByAppendingPathComponent("com.teambition.RemoteQuickLook")
    cacheDirectory = cacheDirectory.stringByAppendingPathComponent(hashedURL)
    var isDirectory: ObjCBool = false
    if !NSFileManager.defaultManager().fileExistsAtPath(cacheDirectory, isDirectory: &isDirectory) || !isDirectory {
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch _{
            return nil
        }
    }
    if let lastPathComponent = url.lastPathComponent {
        // add extra directory to keep original file name when share
        cacheDirectory = cacheDirectory.stringByAppendingPathComponent(lastPathComponent)
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

private var myContext = 0

public class FilePreviewController: QLPreviewController {
    
    /// if header is not nil, Alamofire will use it for authentication
    public var headers: [String: String]?
    public var actionItems = [FPActionBarItem]() {
        willSet {
            for item in newValue {
                item.filePreviewController = self
            }
        }
        didSet {
            toolbarItems = actionItems.map { $0.barButtonItem }
        }
    }

    var navigationBar: UINavigationBar?
    var isObserving = false
    var isFullScreen = false
    
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
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        if let rootViewController = navigationController?.viewControllers[0] {
            if rootViewController == self {
                let crossImage = UIImage(named: "icon-cross", inBundle: NSBundle.init(forClass: FilePreviewController.self), compatibleWithTraitCollection: nil)
                navigationItem.leftBarButtonItem = UIBarButtonItem(image: crossImage, style: .Plain, target: self, action: #selector(dismissSelf))
            }
        }
    }
    
    override public func viewDidLayoutSubviews() {
        layoutToolbar()
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let navigationBar = navigationController?.navigationBar {
            self.navigationBar = navigationBar
        } else {
            let subviews = view.subviews[0].subviews
            for view in subviews {
                if let navigationBar = view as? UINavigationBar {
                    self.navigationBar = navigationBar
                    break
                }
            }
        }
        
        if let navigationBar = navigationBar {
            if !isObserving {
                navigationBar.addObserver(self, forKeyPath: "center", options: [.New, .Old], context: &myContext)
                isObserving = true
            }
        }
    }
    
    deinit {
        if let navigationBar = navigationBar {
            navigationBar.removeObserver(self, forKeyPath: "center")
        }
    }
    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        cancelProgress()
    }
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == &myContext, let keyPath = keyPath where keyPath == "center", let object = object as? UINavigationBar where object == navigationBar {
            if let change = change {
                if let new = change[NSKeyValueChangeNewKey] as? NSValue {
                    let point = new.CGPointValue()
                    if toolbarBottomConstraint?.constant >= 0 && point.y < 0 {
                        toolbarBottomConstraint?.constant = -44
                        isFullScreen = true
                        UIView.animateWithDuration(0.2, animations: {
                            self.view.layoutIfNeeded()
                        })
                    } else if toolbarBottomConstraint?.constant < 0 && point.y > 0 {
                        toolbarBottomConstraint?.constant = 0
                        isFullScreen = false
                        UIView.animateWithDuration(0.2, animations: {
                            self.view.layoutIfNeeded()
                        })
                    }
                    setNeedsStatusBarAppearanceUpdate()
                }
            }
        }
    }

    override public func prefersStatusBarHidden() -> Bool {
        return isFullScreen
    }
    
    func dismissSelf() {
        presentingViewController?.dismissFilePreviewController()
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
                    var progress = CGFloat(totalBytesReceived) / CGFloat(totalBytesExpectedToReceived)
                    if progress < 0 {
                        progress = 0.5
                    }
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
            progressBar?.progress = 0.1
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

            guard let toolbar = toolbar else {
                return
            }
            let flexSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
            let fixedSpace = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: self, action: nil)
            fixedSpace.width = 72
            
            var itemsArray = [UIBarButtonItem]()
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                itemsArray.append(flexSpace)
                for item in items {
                    itemsArray.append(item)
                    itemsArray.append(fixedSpace)
                }
                itemsArray.removeLast()
                itemsArray.append(flexSpace)
            } else {
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
            }
            
            toolbar.setItems(itemsArray, animated: false)
            toolbar.tintColor = UIColor.whiteColor()
        }
        if let toolbar = toolbar {
            if view.subviews.indexOf(toolbar) < view.subviews.count-1 {
                view.bringSubviewToFront(toolbar)
            }
        }
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
        
        if originalPreviewItem.previewItemURL.fileURL {
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
