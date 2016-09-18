//
//  Error.swift
//  FilePreviewController
//
//  Created by WangWei on 16/3/1.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import Foundation

public struct FPError {
    
    public static let Domain = "com.filepreviewcontroller.error"
    public static let RelatedErrorKey = "com.filepreviewcontroller.error.relatederror"
    
    public enum Code: Int {
        case localCacheDirectoryCreateFailed    = -7001
        case remoteFileDownloadFailed           = -7002
    }
    
    public static func errorWithCode(_ code: Code, failureReason: String, error: Error? = nil) -> NSError {
        return errorWithCode(code.rawValue, failureReason: failureReason, error: nil)
    }
    
    public static func errorWithCode(_ code: Int, failureReason: String, error: Error?) -> NSError {
        var userInfo: [String: AnyObject] = [NSLocalizedDescriptionKey: failureReason as AnyObject]
        if let error = error {
           userInfo[RelatedErrorKey] = error as AnyObject?
        }
        return NSError(domain: Domain, code: code, userInfo: userInfo)
    }
}
