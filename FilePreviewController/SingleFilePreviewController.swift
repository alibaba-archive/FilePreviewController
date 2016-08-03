//
//  SingleFilePreviewController.swift
//  FilePreviewController
//
//  Created by WangWei on 16/2/25.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import Foundation
import QuickLook

public class SingleFilePreviewController: FilePreviewController {
    var singleItemDataSource: SingleItemDataSource!
 
    public init(previewItem: FilePreviewItem) {
        super.init(nibName: nil, bundle: nil)
        singleItemDataSource = SingleItemDataSource(previewItem: previewItem)
        originalDataSource = singleItemDataSource
        dataSource = self
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
    }
}

class SingleItemDataSource: NSObject, QLPreviewControllerDataSource {
    var previewItem: QLPreviewItem!

    init(previewItem: QLPreviewItem) {
        super.init()
        self.previewItem = previewItem
    }

    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
        return 1
    }

    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
        return previewItem!
    }
}
