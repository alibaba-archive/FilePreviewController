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

private func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

private func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

private var myContext = 0

open class FilePreviewController: QLPreviewController {
    
    /// if header is not nil, Alamofire will use it for authentication
    open var headers: [String: String]?
    var downloadRequest: DownloadRequest?

    open var isEnableShare = true
    open var isEnableShowMore = true
    open var actionItems = [FPActionBarItem]() {
        willSet {
            for item in newValue {
                item.filePreviewController = self
            }
        }
        didSet {
            toolbarItems = actionItems.map { $0.barButtonItem }
        }
    }
    
    override open var toolbarItems: [UIBarButtonItem]? {
        didSet {
            items = toolbarItems
        }
    }
    open var items: [UIBarButtonItem]?
    
    fileprivate lazy var bottomProgressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 2)
        progressView.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        progressView.tintColor = UIColor.blue
        return progressView
    }()
    
    var shouldDisplayToolbar: Bool {
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
                navigationBar.addObserver(self, forKeyPath: "center", options: [.new, .old], context: &myContext)
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
        bar?.tintColor = UIColor.white
        return bar
    }()
    
    var customNavigationBar: UIView?
    lazy var leftBarButtonItem: UIBarButtonItem = {
        let crossImage = UIImage(named: "icon-cross", in: Bundle.init(for: FilePreviewController.self), compatibleWith: nil)
        return UIBarButtonItem(image: crossImage, style: .plain, target: self, action: #selector(dismissSelf))
    }()
    lazy var shareBarButtonItem: UIBarButtonItem = {
        let shareImage = UIImage(named: "icon-share", in: Bundle.init(for: FilePreviewController.self), compatibleWith: nil)
        let item = UIBarButtonItem(image: shareImage, style: .plain, target: self, action: #selector(showShareActivity))
        item.isEnabled = false
        return item
    }()
    lazy var moreBarButtonItem: UIBarButtonItem = {
        let moreImage = UIImage(named: "moreIcon", in: Bundle.init(for: FilePreviewController.self), compatibleWith: nil)
        let item = UIBarButtonItem(image: moreImage, style: .plain, target: self, action: #selector(showMoreActivity))
        return item
    }()

    var isObserving = false
    var isFullScreen = false
    
    var originalDataSource: QLPreviewControllerDataSource?
    
    var progress: CGFloat = 0
    var progressBar: UIProgressView?
    var toolbar: UIToolbar?
    
    var toolbarBottomConstraint: NSLayoutConstraint?
    
    private let customToolbarHeight: CGFloat = 44
    private var toolbarBackgroundHeight: CGFloat {
        if #available(iOS 11.0, *) {
            let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            return customToolbarHeight + bottomPadding
        } else {
            return customToolbarHeight
        }
    }
    
    open weak var controllerDelegate: FilePreviewControllerDelegate?
    
    var interactionController: UIDocumentInteractionController?

    override open func viewDidLoad() {
        super.viewDidLoad()
        let crossImage = UIImage(named: "icon-cross", in: Bundle.init(for: FilePreviewController.self), compatibleWith: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: crossImage, style: .plain, target: self, action: #selector(dismissSelf))
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutToolbar()
    }
    
    open override var preferredStatusBarStyle : UIStatusBarStyle {
        return .default
    }
    
    override open var prefersStatusBarHidden : Bool {
        return isFullScreen
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default

        if let navigationBar = navigationBar, let container = navigationBar.superview {
            let customHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 64))
            customHeaderView.backgroundColor = UIColor.white
            customHeaderView.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(customHeaderView)
            
            let headerLeftConstriant = NSLayoutConstraint(item: customHeaderView, attribute: .left, relatedBy: .equal, toItem: container, attribute: .left, multiplier: 1.0, constant: 0)
            let headerRightConstriant = NSLayoutConstraint(item: customHeaderView, attribute: .right, relatedBy: .equal, toItem: container, attribute: .right, multiplier: 1.0, constant: 0)
            let headerTopConstriant = NSLayoutConstraint(item: customHeaderView, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0)
            let headerBottomConstriant = NSLayoutConstraint(item: customHeaderView, attribute: .bottom, relatedBy: .equal, toItem: navigationBar, attribute: .bottom, multiplier: 1.0, constant: 0)
            NSLayoutConstraint.activate([headerLeftConstriant, headerRightConstriant, headerTopConstriant, headerBottomConstriant])
            
            let bar = UINavigationBar(frame: CGRect.zero)
            bar.isTranslucent = false
            bar.translatesAutoresizingMaskIntoConstraints = false
            customHeaderView.addSubview(bar)
            
            let leftConstriant = NSLayoutConstraint(item: bar, attribute: .left, relatedBy: .equal, toItem: customHeaderView, attribute: .left, multiplier: 1.0, constant: 0)
            let rightConstriant = NSLayoutConstraint(item: bar, attribute: .right, relatedBy: .equal, toItem: customHeaderView, attribute: .right, multiplier: 1.0, constant: 0)
            let bottomConstriant = NSLayoutConstraint(item: bar, attribute: .bottom, relatedBy: .equal, toItem: customHeaderView, attribute: .bottom, multiplier: 1.0, constant: 0)
            NSLayoutConstraint.activate([leftConstriant, rightConstriant, bottomConstriant])
            
            let item = UINavigationItem(title: navigationItem.title ?? "")
            item.leftBarButtonItem = leftBarButtonItem
            var barButtonItems: [UIBarButtonItem] = []
            if isEnableShare {
                barButtonItems.append(shareBarButtonItem)
                item.rightBarButtonItems = [shareBarButtonItem, moreBarButtonItem]
            }
            if isEnableShowMore {
                barButtonItems.append(moreBarButtonItem)
                item.rightBarButtonItems = [moreBarButtonItem]
            }
            if barButtonItems.count != 0 {
                item.rightBarButtonItems = barButtonItems
            }
            item.hidesBackButton = true
            bar.pushItem(item, animated: true)
            customNavigationBar = customHeaderView
        }
    }

    deinit {
        if let navigationBar = navigationBar {
            navigationBar.removeObserver(self, forKeyPath: "center")
        }
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancelProgress()
        customNavigationBar?.removeFromSuperview()
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (_) -> Void in
            self.layoutProgressBar()
            self.refreshCurrentPreviewItem()
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }, completion: nil)
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &myContext, let keyPath = keyPath , keyPath == "center", let object = object as? UINavigationBar , object == navigationBar {
            if let change = change {
                if let new = change[NSKeyValueChangeKey.newKey] as? NSValue {
                    let point = new.cgPointValue
                    if !self.isFullScreen && point.y < 0 {
                        self.toolbarBottomConstraint?.constant = 0
                        self.isFullScreen = true
                        self.originalToolbar?.isHidden = true
                        UIView.animate(withDuration: 0.2, animations: {
                            self.view.layoutIfNeeded()
                            self.navigationBar?.superview?.layoutIfNeeded()
                            }, completion: { (_) in
                                self.originalToolbar?.isHidden = true
                                self.navigationBar?.superview?.sendSubviewToBack(self.navigationBar!)
                        })
                    } else if self.isFullScreen && point.y > 0 {
                        self.toolbarBottomConstraint?.constant = self.shouldDisplayToolbar ? self.toolbarBackgroundHeight : 0
                        self.isFullScreen = false
                        
                        if object.superview == self.customNavigationBar?.superview {
                            let headerBottomConstriant = NSLayoutConstraint(item: self.customNavigationBar!, attribute: .bottom, relatedBy: .equal, toItem: object, attribute: .bottom, multiplier: 1.0, constant: 0)
                            headerBottomConstriant.isActive = true
                        }
                        
                        DispatchQueue.main.async {
                            self.navigationBar?.superview?.bringSubviewToFront(self.customNavigationBar!)
                        }
                        UIView.animate(withDuration: 0.2, animations: {
                            self.view.layoutIfNeeded()
                            self.navigationBar?.superview?.layoutIfNeeded()
                            self.originalToolbar?.isHidden = true
                        }, completion: { (_) in
                            self.originalToolbar?.isHidden = true
                            DispatchQueue.main.async {
                                self.navigationBar?.superview?.bringSubviewToFront(self.customNavigationBar!)
                            }
                        })
                        
                    }
                    setNeedsStatusBarAppearanceUpdate()
                }
            }
        }
    }
    
    @objc func dismissSelf() {
        presentingViewController?.dismissFilePreviewController()
    }

    func willDismiss() {
        downloadRequest?.cancel()
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
    
    public func showDefaultShareActivity() {
        if let previewItemURL = currentPreviewItem?.previewItemURL {
            interactionController = UIDocumentInteractionController(url: previewItemURL)
            interactionController?.presentOptionsMenu(from: shareBarButtonItem, animated: true)
        }
    }
}

// MARK: - Share
public extension FilePreviewController {
    @objc func showMoreActivity() {
        guard let previewItem = currentPreviewItem as? FilePreviewItem else {
            return
        }
        if let delegate = controllerDelegate {
            delegate.previewController(self, showMoreItems: previewItem)
        }
    }

    @objc func showShareActivity() {
        guard let previewItem = currentPreviewItem as? FilePreviewItem else {
            return
        }
        if let delegate = controllerDelegate {
            delegate.previewController(self, willShareItem: previewItem)
        } else {
            showDefaultShareActivity()
        }
    }
}

// MARK: - bottomProgressView
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

// MARK: -  Download & progressBar
extension FilePreviewController {
    func downloadFor(_ item: FilePreviewItem, complete: @escaping (Error?) -> Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        downloadRequest = FileDownloadManager.downloadFile(for: item, customReqeustHeaders: headers, downloadProgress: { (progress) in
            self.updateProgress(progress)
        }) { (downloadError) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.cancelProgress()
            if let error = downloadError,let controllerDelegate = self.controllerDelegate {
                controllerDelegate.previewController(self, failedToLoadRemotePreviewItem: item, error: error as NSError)
            }
            complete(downloadError)
        }
    }
    
     private func updateProgress(_ newProgress: CGFloat) {
        if progressBar == nil {
            progressBar = UIProgressView(progressViewStyle: .bar)
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
    
    private func cancelProgress() {
        guard let progressBar = progressBar else {
            return
        }
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            progressBar.alpha = 0
            }, completion: { (_) -> Void in
                progressBar.removeFromSuperview()
        })
    }
    
    private func layoutProgressBar() {
        guard let navigationBar = customNavigationBar, let progressBar = progressBar else {
            return
        }
        if !navigationBar.subviews.contains(progressBar) {
            progressBar.tintColor = navigationBar.tintColor
            navigationBar.addSubview(progressBar)
        }
        let navigationBarHeight = navigationBar.frame.height
        let navigationBarWidth = navigationBar.frame.width
        let progressBarHeight = progressBar.frame.height
        progressBar.frame = CGRect(x: 0, y: navigationBarHeight - progressBarHeight, width: navigationBarWidth, height: progressBarHeight)
    }
    
    private func layoutToolbar() {
        originalToolbar?.isHidden = true
        if toolbar == nil {
            toolbar = UIToolbar()
            if let toolbar = toolbar {
                view.addSubview(toolbar)
                toolbar.translatesAutoresizingMaskIntoConstraints = false
                view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[toolbar]-0-|", options: [], metrics: nil , views: ["toolbar":toolbar]))
                toolbar.addConstraint(NSLayoutConstraint(item: toolbar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: customToolbarHeight))
                toolbarBottomConstraint = NSLayoutConstraint(item: view!, attribute: .bottom, relatedBy: .equal, toItem: toolbar, attribute: .top, multiplier: 1.0, constant: toolbarBackgroundHeight)
                view.addConstraint(toolbarBottomConstraint!)
            }
            
            guard let toolbar = toolbar, let items = items , items.count > 0 else {
                toolbarBottomConstraint?.constant = 0
                return
            }
            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
            let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
            fixedSpace.width = 72
            
            var itemsArray = [UIBarButtonItem]()
            if UIDevice.current.userInterfaceIdiom == .pad {
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
            toolbar.tintColor = UIColor.white
        }
        if let toolbar = toolbar {
            view.bringSubviewToFront(toolbar)
        }
    }
}

// MARK: - QLPreviewControllerDataSource
extension FilePreviewController: QLPreviewControllerDataSource {
    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        guard let originalDataSource = originalDataSource else {
            return 0
        }
        return originalDataSource.numberOfPreviewItems(in: controller)
    }
    
    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let originalPreviewItem = (originalDataSource!.previewController(controller, previewItemAt: index)) as! FilePreviewItem
        
        guard let previewItemURL = originalPreviewItem.previewItemURL else {
            return originalPreviewItem
        }
        if previewItemURL.isFileURL {
            shareBarButtonItem.isEnabled = true
            return originalPreviewItem
        }
        
        //If it's a remote file, check cache
        var copyItem: FilePreviewItem!
        if let itemTitle = originalPreviewItem.previewItemTitle {
            copyItem = FilePreviewItem(previewItemURL: originalPreviewItem.previewItemURL, previewItemTitle: itemTitle, fileKey: originalPreviewItem.fileKey)
        } else {
            copyItem = FilePreviewItem(previewItemURL: originalPreviewItem.previewItemURL, fileKey: originalPreviewItem.fileKey)
        }
        
        guard let localFilePath = FileDownloadManager.localFilePathFor(previewItemURL, fileName: originalPreviewItem.previewItemTitle, fileExtension: originalPreviewItem.fileExtension, fileKey: originalPreviewItem.fileKey) else {
            //failed to get local file path
            if let controllerDelegate = self.controllerDelegate {
                let error = FPError.errorWithCode(.localCacheDirectoryCreateFailed, failureReason: "Create cache directory failed")
                controllerDelegate.previewController(self, failedToLoadRemotePreviewItem: originalPreviewItem, error: error)
            }
            return originalPreviewItem
        }
        copyItem.previewItemURL = URL(fileURLWithPath: localFilePath)
        
        if FileManager.default.fileExists(atPath: localFilePath) {
            shareBarButtonItem.isEnabled = true
            return copyItem
        } else {
            //Download remote file if cache not exist
            downloadFor(originalPreviewItem, complete: { [weak self] error in
                guard let strongSelf = self else {
                    return
                }
                if error == nil {
                    strongSelf.refreshCurrentPreviewItem()
                }
            })
        }
        copyItem.previewItemURL = nil
        return copyItem
    }
}
