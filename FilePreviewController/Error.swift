//
//  Error.swift
//  FilePreviewController
//
//  Created by WangWei on 16/3/1.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import Foundation

public struct Error {
    
    public static let Domain = "com.filepreviewcontroller.error"
    public static let RelatedErrorKey = "com.filepreviewcontroller.error.relatederror"
    
    public enum Code: Int {
        case LocalCacheDirectoryCreateFailed    = -7001
        case RemoteFileDownloadFailed           = -7002
    }
    
    public static func errorWithCode(code: Code, failureReason: String, error: NSError? = nil) -> NSError {
        return errorWithCode(code.rawValue, failureReason: failureReason, error: nil)
    }
    
    public static func errorWithCode(code: Int, failureReason: String, error: NSError?) -> NSError {
        var userInfo: [String: AnyObject] = [NSLocalizedDescriptionKey: failureReason]
        if let error = error {
           userInfo[RelatedErrorKey] = error
        }
        return NSError(domain: Domain, code: code, userInfo: userInfo)
    }
}