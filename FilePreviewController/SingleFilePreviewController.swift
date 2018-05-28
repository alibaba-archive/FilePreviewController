//
//  SingleFilePreviewController.swift
//  FilePreviewController
//
//  Created by WangWei on 16/2/25.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import Foundation
import QuickLook

public protocol PreviewItemHandler {
    func previewItemHandler(_ handle: QLPreviewItem) -> QLPreviewItem
}

open class SingleFilePreviewController: FilePreviewController {
    let singleItemDataSource: QLPreviewControllerDataSource
    
    public init(previewItem: FilePreviewItem, previewItemHandler: PreviewItemHandler? = nil) {
        singleItemDataSource = SingleItemDataSource(previewItem: previewItem, handler: previewItemHandler)
        super.init(nibName: nil, bundle: nil)
        self.originalDataSource = singleItemDataSource
        dataSource = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SingleItemDataSource: QLPreviewControllerDataSource {
    let previewItem: QLPreviewItem
    let handler: PreviewItemHandler?
    
    init(previewItem: QLPreviewItem, handler: PreviewItemHandler?) {
        self.previewItem = previewItem
        self.handler = handler
    }

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        guard let handler = handler else {
            return previewItem
        }
        return handler.previewItemHandler(previewItem)
    }
}
