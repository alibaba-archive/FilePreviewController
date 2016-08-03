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

public func localFilePathFor(URL: NSURL, fileName: String? = nil, fileExtension: String? = nil) -> String? {
    var url = URL
    if let fileExtension = fileExtension where url.pathExtension == nil || url.pathExtension?.characters.count == 0 {
        url = url.URLByAppendingPathExtension(fileExtension)
    }
    var saveName: String?
    if let fileName = fileName?.stringByReplacingOccurrencesOfString("/", withString: ":"), fileExtension = fileExtension {
        saveName = fileName
        if !fileName.hasSuffix(".\(fileExtension)") {
            saveName = "\(fileName).\(fileExtension)"
        }
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
    if let lastPathComponent = saveName ?? url.lastPathComponent {
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
    public var enableShare = true
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
    override public var toolbarItems: [UIBarButtonItem]? {
        didSet {
            items = toolbarItems
        }
    }
    public var items: [UIBarButtonItem]?
    public lazy var bottomProgressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .Bar)
        progressView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 2)
        progressView.autoresizingMask = [.FlexibleWidth, .FlexibleBottomMargin]
        progressView.tintColor = UIColor.blueColor()
        return progressView
    }()
    private var shouldDisplayToolbar: Bool {
        get {
            return items?.count > 0
        }
    }

    lazy var navigationBar: UINavigationBar? = {
        var bar: UINavigationBar?
        if let navigationBar = self.navigationController?.navigationBar {
            bar = navigationBar
        } else {
            let nBar = self.getNavigationBar(fromView: self.view)
            bar = nBar
        }

        if let navigationBar = bar {
            if !self.isObserving {
                navigationBar.addObserver(self, forKeyPath: "center", options: [.New, .Old], context: &myContext)
                self.isObserving = true
            }
        }
        return bar
    }()

    lazy var originalToolbar: UIToolbar? = {
        var bar: UIToolbar?
        if let subviews = self.navigationBar?.superview?.subviews {
            for view in subviews {
                if let toolbar = view as? UIToolbar {
                    bar = toolbar
                    break
                }
            }
        }
        bar?.tintColor = UIColor.whiteColor()
        return bar
    }()
    var customNavigationBar: UINavigationBar?
    lazy var leftBarButtonItem: UIBarButtonItem = {
        let crossImage = UIImage(named: "icon-cross", inBundle: NSBundle.init(forClass: FilePreviewController.self), compatibleWithTraitCollection: nil)
        return UIBarButtonItem(image: crossImage, style: .Plain, target: self, action: #selector(dismissSelf))
    }()
    lazy var rightBarButtonItem: UIBarButtonItem = {
        let shareImage = UIImage(named: "icon-share", inBundle: NSBundle.init(forClass: FilePreviewController.self), compatibleWithTraitCollection: nil)
        return UIBarButtonItem(image: shareImage, style: .Plain, target: self, action: #selector(showShareActivity))
    }()
    var isObserving = false
    var isFullScreen = false
    
    var originalDataSource: QLPreviewControllerDataSource?
    
    var progress: CGFloat = 0
    var progressBar: UIProgressView?
    var toolbar: UIToolbar?
    
    var toolbarBottomConstraint: NSLayoutConstraint?
    
    public weak var controllerDelegate: FilePreviewControllerDelegate?
    
//    override public weak var dataSource: QLPreviewControllerDataSource? {
//        get {
//            return originalDataSource
//        }
//        set {
//            super.dataSource = self
//            originalDataSource = newValue
//        }
//    }
    var interactionController: UIDocumentInteractionController?

    override public func viewDidLoad() {
        super.viewDidLoad()
        let crossImage = UIImage(named: "icon-cross", inBundle: NSBundle.init(forClass: FilePreviewController.self), compatibleWithTraitCollection: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: crossImage, style: .Plain, target: self, action: #selector(dismissSelf))
    }
    
    override public func viewDidLayoutSubviews() {
        layoutToolbar()
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let navigationBar = navigationBar, container = navigationBar.superview {
            let bar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 64))
            bar.autoresizingMask = [.FlexibleWidth]
            container.addSubview(bar)
            let item = UINavigationItem(title: navigationItem.title ?? "")
            item.leftBarButtonItem = leftBarButtonItem
            if enableShare {
                item.rightBarButtonItem = rightBarButtonItem
            }
            item.hidesBackButton = true
            bar.pushNavigationItem(item, animated: true)
            customNavigationBar = bar
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
        customNavigationBar?.removeFromSuperview()
    }
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == &myContext, let keyPath = keyPath where keyPath == "center", let object = object as? UINavigationBar where object == navigationBar {
            if let change = change {
                if let new = change[NSKeyValueChangeNewKey] as? NSValue {
                    let point = new.CGPointValue()
                    if !isFullScreen && point.y < 0 {
                        toolbarBottomConstraint?.constant = -44
                        isFullScreen = true
                        UIView.animateWithDuration(0.2, animations: {
                            self.view.layoutIfNeeded()
                            self.customNavigationBar?.frame.origin.y = -64
                            self.navigationBar?.superview?.layoutIfNeeded()
                            }, completion: { (_) in
                                self.originalToolbar?.hidden = true
                                self.navigationBar?.superview?.sendSubviewToBack(self.navigationBar!)
                        })
                    } else if isFullScreen && point.y > 0 {
                        toolbarBottomConstraint?.constant = shouldDisplayToolbar ? 0 : -45
                        isFullScreen = false
                        UIView.animateWithDuration(0.2, animations: {
                            self.view.layoutIfNeeded()
                            self.customNavigationBar?.frame.origin.y = 0
                            self.navigationBar?.superview?.layoutIfNeeded()
                            self.originalToolbar?.hidden = true
                            self.navigationBar?.superview?.bringSubviewToFront(self.customNavigationBar!)
                            }, completion: { (_) in
                                self.navigationBar?.superview?.bringSubviewToFront(self.customNavigationBar!)
                                self.originalToolbar?.hidden = true
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

    func showShareActivity() {
        if let previewItemURL = currentPreviewItem?.previewItemURL {
            interactionController = UIDocumentInteractionController(URL: previewItemURL)
            interactionController?.presentOptionsMenuFromBarButtonItem(rightBarButtonItem, animated: true)
        }
    }

    func getNavigationBar(fromView view: UIView) -> UINavigationBar? {
        for v in view.subviews {
            if v is UINavigationBar {
                return v as? UINavigationBar
            } else {
                if let bar = getNavigationBar(fromView: v) {
                    return bar
                }
            }
        }
        return nil
    }
}

public extension FilePreviewController {
    func beginUpdate() {
        if bottomProgressView.superview == nil {
            toolbar?.addSubview(bottomProgressView)
        }
    }
    func endUpdate() {
        bottomProgressView.removeFromSuperview()
    }
    func update(progress value: Float) {
        bottomProgressView.progress = value
    }
}

extension FilePreviewController {
    func downloadFor(item: FilePreviewItem) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        guard let localFilePath = localFilePathFor(item.previewItemURL, fileName: item.previewItemTitle, fileExtension: item.fileExtension) else {
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
        guard let navigationBar = customNavigationBar, progressBar = progressBar else {
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
        originalToolbar?.hidden = true
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

            guard let toolbar = toolbar, items = items where items.count > 0 else {
                toolbarBottomConstraint?.constant = -44
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
            view.bringSubviewToFront(toolbar)
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
        
        guard let localFilePath = localFilePathFor(originalPreviewItem.previewItemURL, fileName: originalPreviewItem.previewItemTitle, fileExtension: originalPreviewItem.fileExtension) else {
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
