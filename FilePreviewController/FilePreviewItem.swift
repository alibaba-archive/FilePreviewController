//
//  FilePreviewItem.swift
//  FilePreviewController
//
//  Created by Suric on 2020/11/10.
//  Copyright © 2020 Teambition. All rights reserved.
//

import Foundation
import QuickLook

open class FilePreviewItem: NSObject, QLPreviewItem {
    open var previewItemURL: URL?
    open var previewItemTitle: String?
    
    // when fileExtension is nil, will try to get pathExtension from previewItemURL
    open var fileExtension: String?
    
    open var fileKey: String?
    
    public init(previewItemURL: URL?, previewItemTitle: String? = nil, fileExtension: String? = nil, fileKey: String?) {
        self.previewItemURL = previewItemURL
        self.previewItemTitle = previewItemTitle
        self.fileKey = fileKey
        self.fileExtension = fileExtension
        super.init()
    }
    
    public var localURL: URL? {
        guard let previewItemURL = previewItemURL else {
            return nil
        }
        guard let localFilePath = FileDownloadManager.localFilePathFor(previewItemURL, fileName: previewItemTitle, fileExtension: fileExtension, fileKey: fileKey) else {
            return previewItemURL
        }
        return URL(fileURLWithPath: localFilePath)
    }
}

