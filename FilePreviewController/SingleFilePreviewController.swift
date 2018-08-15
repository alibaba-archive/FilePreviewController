//
//  SingleFilePreviewController.swift
//  FilePreviewController
//
//  Created by WangWei on 16/2/25.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import Foundation
import QuickLook
import AVKit

extension QLPreviewController {
    func hideErrorMessage() {
        let errorView = view.subviews.first(where: { String(describing: $0.classForCoder) == "QLErrorView" })
        errorView?.subviews.compactMap { $0 as? UILabel }.forEach { $0.text = nil }
    }
}

extension FilePreviewItem {
    var isVideo: Bool {
        if #available(iOS 10, *) {
            let supportExtensions = [
                "mp4", "mov", "qt", "avi", "3gp", "wmv", "mkv", "rmvb", "rm", "xvid", "mpg"
            ]
            if let fileExtension = fileExtension {
                return supportExtensions.contains(fileExtension.lowercased())
            }
            return false
        } else {
            return false
        }
    }
}

open class SingleFilePreviewController: FilePreviewController {
    private var avPlayerController: TBAVPlayerController?
    
    var previewItem: FilePreviewItem?
    
    public init(previewItem: FilePreviewItem?) {
        self.previewItem = previewItem
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func updateItem(_ previewItem: FilePreviewItem?) {
        guard let previewItem = previewItem, let url = previewItem.previewItemURL else {
            return
        }
        self.previewItem = previewItem
        navigationItem.title = previewItem.previewItemTitle
        let asset = AVAsset(url: url)
        let isPlayable = asset.isPlayable
        if previewItem.isVideo, isPlayable {
            setupAVPlayerViewController(with: url)
        } else {
            if !isPlayable {
                controllerDelegate?.previewController(self as FilePreviewController, failedToLoadRemotePreviewItem: previewItem, error: NSError(domain: "Video can't play", code: 0, userInfo: nil))
            }
            originalDataSource = SingleItemDataSource(previewItem: previewItem)
            dataSource = self
            reloadData()
        }
    }
    
    private func setupAVPlayerViewController(with url: URL) {
        guard self.avPlayerController == nil else {
            return
        }
        hideNavigationBarAndToolbar()
        let avPlayerController = TBAVPlayerController(url: url)
        view.addSubview(avPlayerController.view)
        avPlayerController.view.frame = view.frame
        addChildViewController(avPlayerController)
        self.avPlayerController = avPlayerController
        self.avPlayerController?.touchHandle = { [weak self] avPlayerController in
            guard let strongSelf = self, let navigationController = strongSelf.navigationController else {
                return
            }
            if !navigationController.isNavigationBarHidden || !avPlayerController.isPlaybackControlsHidden {
                strongSelf.updateNavigationBarAndToolbar()
                avPlayerController.showsPlaybackControls = navigationController.isNavigationBarHidden
            }
        }
        avPlayerController.play()
    }
    
    private func updateNavigationBarAndToolbar() {
        if let navigationController = navigationController {
            navigationController.setNavigationBarHidden(!navigationController.isNavigationBarHidden, animated: true)
            if shouldDisplayToolbar {
                navigationController.setToolbarHidden(!navigationController.isNavigationBarHidden, animated: true)
            }
        }
    }
    
    private func hideNavigationBarAndToolbar() {
        if let navigationController = navigationController {
            navigationController.setNavigationBarHidden(true, animated: false)
            navigationController.setToolbarHidden(true, animated: false)
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        updateItem(previewItem)
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if previewItem == nil {
            hideErrorMessage()
        }
        if let avPlayerController = avPlayerController, avPlayerController.isPlaying {
            hideNavigationBarAndToolbar()
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if avPlayerController != nil {
            avPlayerController?.play()
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear (animated)
        if avPlayerController != nil {
            avPlayerController?.pause()
        }
    }
    
    private func releaseAVPlayerViewController() {
        if let avPlayerController = avPlayerController {
            avPlayerController.removeFromParentViewController()
            avPlayerController.view.removeFromSuperview()
            self.avPlayerController = nil
        }
    }
    
   override func willDismiss() {
        super.willDismiss()
        releaseAVPlayerViewController()
    }
}

public extension SingleFilePreviewController {
    @objc override func showMoreActivity() {
        guard let previewItem = previewItem else {
            return
        }
        if let delegate = controllerDelegate {
            delegate.previewController(self, showMoreItems: previewItem)
        }
    }
    
    @objc override func showShareActivity() {
        guard let previewItem = previewItem else {
            return
        }
        if let delegate = controllerDelegate {
            delegate.previewController(self, willShareItem: previewItem)
        } else {
            showDefaultShareActivity()
        }
    }
}

class SingleItemDataSource: NSObject, QLPreviewControllerDataSource {
    let previewItem: QLPreviewItem

    init(previewItem: QLPreviewItem) {
        self.previewItem = previewItem
        super.init()
    }

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return previewItem
    }
}

class TBAVPlayerController: AVPlayerViewController {
    var isPlaying = false
    
    var touchHandle: ((TBAVPlayerController) -> Void)?
    
    var isPlaybackControlsHidden: Bool {
        var playbackControlsIsHidden = false
        if #available(iOS 11.0, *) {
            if let playerViewControllerContentView = view.subviews.filter({ String(describing: $0.classForCoder) == "AVPlayerViewControllerContentView" }).first,
                let playbackControlsView = playerViewControllerContentView.subviews.filter({ String(describing: $0.classForCoder) == "AVPlaybackControlsView" }).first {
                playbackControlsIsHidden = playbackControlsView.subviews.reduce(true, { $0 && $1.isHidden })
            }
        } else {
            if let playbackControlsView = view.subviews.first?.subviews.first(where: { $0.subviews.contains(where: { String(describing: $0.classForCoder) == "AVAlphaUpdatingView" }) }) {
                playbackControlsIsHidden = playbackControlsView.subviews.reduce(true, { $0 && $1.isHidden })
            }
        }
        return playbackControlsIsHidden
    }
    
    init(url: URL) {
        super.init(nibName: nil, bundle: nil)
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: item)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        touchHandle?(self)
    }
    
    deinit {
        pause()
        player?.currentItem?.cancelPendingSeeks()
        player?.currentItem?.asset.cancelLoading()
    }
    
    func play() {
        isPlaying = true
        player?.play()
    }
    
    func pause() {
        isPlaying = false
        player?.pause()
    }
}
