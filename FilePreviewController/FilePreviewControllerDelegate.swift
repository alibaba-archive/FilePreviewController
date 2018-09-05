//
//  FilePreviewControllerDelegate.swift
//  FilePreviewController
//
//  Created by WangWei on 16/8/18.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import Foundation

public protocol FilePreviewControllerDelegate: class {
    func previewController(_ controller: FilePreviewController, failedToLoadRemotePreviewItem item:FilePreviewItem, error: NSError)
    func previewController(_ controller: FilePreviewController, willShareItem item: FilePreviewItem)
    func previewController(_ controller: FilePreviewController, showMoreItems item: FilePreviewItem)
    func previewController(_ controller: FilePreviewController, willDownloadItem item: FilePreviewItem)
    func previewController(_ controller: FilePreviewController, downloadedItem item: FilePreviewItem, error: Error?)
}

public extension FilePreviewControllerDelegate {
    func previewController(_ controller: FilePreviewController, failedToLoadRemotePreviewItem item:FilePreviewItem, error: NSError) {
        print("failed to load remote preview item: \(error)")
    }
    
    func previewController(_ controller: FilePreviewController, willShareItem item: FilePreviewItem) {
        controller.showDefaultShareActivity()
    }
    
    func previewController(_ controller: FilePreviewController, showMoreItems item: FilePreviewItem) {
        print("show more items")
    }
}
