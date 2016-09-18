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
}

public extension FilePreviewControllerDelegate {
    func previewController(_ controller: FilePreviewController, failedToLoadRemotePreviewItem item:FilePreviewItem, error: NSError) {
        print("failed to load remote preview item: \(error)")
    }
    
    func previewController(_ controller: FilePreviewController, willShareItem item: FilePreviewItem) {
        controller.showDefautlShareActivity()
    }
}
