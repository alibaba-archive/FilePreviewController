//
//  SingleFilePreviewController.swift
//  FilePreviewController
//
//  Created by WangWei on 16/2/25.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import Foundation
import QuickLook

open class SingleFilePreviewController: FilePreviewController {
    var singleItemDataSource: SingleItemDataSource!
 
    public init(previewItem: FilePreviewItem?) {
        super.init(nibName: nil, bundle: nil)
        singleItemDataSource = SingleItemDataSource(previewItem: previewItem)
        originalDataSource = singleItemDataSource
        dataSource = self
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public func updateItem(_ previewItem: FilePreviewItem?) {
        singleItemDataSource.previewItem = previewItem
        reloadData()
    }
}

class SingleItemDataSource: NSObject, QLPreviewControllerDataSource {
    var previewItem: QLPreviewItem?

    init(previewItem: QLPreviewItem?) {
        super.init()
        self.previewItem = previewItem
    }

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return (previewItem != nil) ? 1 : 0
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return previewItem!
    }
}
