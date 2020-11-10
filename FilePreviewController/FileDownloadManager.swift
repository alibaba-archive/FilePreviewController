//
//  FilePreviewDownloadManager.swift
//  FilePreviewController
//
//  Created by Suric on 2020/11/10.
//  Copyright © 2020 Teambition. All rights reserved.
//

import Foundation
import Alamofire

public struct FilePreviewControllerConstants {
   public static let filePathComponent = "com.teambition.RemoteQuickLook"
}

public extension String {
    func MD5() -> String {
        return (self as NSString).md5() as String
    }
    
    func stringByAppendingPathComponent(_ str: String) -> String {
        return (self as NSString).appendingPathComponent(str)
    }
    
    func stringByAppendingPathExtension(_ str: String) -> String? {
        return (self as NSString).appendingPathExtension(str)
    }
}

class FileDownloadManager {
    public static func localFilePathFor(_ item: FilePreviewItem) -> String? {
        guard let previewItemUrl = item.previewItemURL else {
            return nil
        }
        return FileDownloadManager.localFilePathFor(previewItemUrl, fileName: item.previewItemTitle, fileExtension: item.fileExtension, fileKey: item.fileKey)
    }

    
    public static func localFilePathFor(_ URL: Foundation.URL, fileName: String? = nil, fileExtension: String? = nil, fileKey: String?) -> String? {
        var url = URL
        if let fileExtension = fileExtension, url.pathExtension.count == 0 {
            url = url.appendingPathExtension(fileExtension)
        }
        var saveName: String?
        if let fileName = fileName?.replacingOccurrences(of: "/", with: ":"), let fileExtension = fileExtension {
            saveName = fileName
            if fileName.components(separatedBy: ".").count == 1 {
                saveName = "\(fileName).\(fileExtension)"
            }
        }
        
        let hashedURL: String
        if let fileKey = fileKey {
            hashedURL = fileKey
        } else {
            hashedURL = URL.absoluteString.MD5()
        }

        guard var cacheDirectory = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last else {
            return nil
        }
        cacheDirectory = cacheDirectory.stringByAppendingPathComponent(FilePreviewControllerConstants.filePathComponent)
        cacheDirectory = cacheDirectory.stringByAppendingPathComponent(hashedURL)
        var isDirectory: ObjCBool = false
        if !FileManager.default.fileExists(atPath: cacheDirectory, isDirectory: &isDirectory) || !isDirectory.boolValue {
            do {
                try FileManager.default.createDirectory(atPath: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch _{
                return nil
            }
        }
        let lastPathComponent = saveName ?? url.lastPathComponent
        if lastPathComponent.count > 0 {
            // add extra directory to keep original file name when share
            cacheDirectory = cacheDirectory.stringByAppendingPathComponent(lastPathComponent)
        }

        return cacheDirectory
    }
    
    static func downloadFile(for item: FilePreviewItem, customReqeustHeaders: [String: String]? = nil, downloadProgress: @escaping (CGFloat) -> Void, complete: @escaping (Error?) -> Void) -> DownloadRequest? {
        guard let previewItemUrl = item.previewItemURL,
            let localFilePath = FileDownloadManager.localFilePathFor(previewItemUrl, fileName: item.previewItemTitle, fileExtension: item.fileExtension, fileKey: item.fileKey) else {
                let error = FPError.errorWithCode(.localCacheDirectoryCreateFailed, failureReason: "Create cache directory failed")
                complete(error)
                return nil
        }
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (URL(fileURLWithPath: localFilePath), [.createIntermediateDirectories, .removePreviousFile])
        }
        let downloadRequest = download(previewItemUrl.absoluteString,
                                       method: .get,
                                       parameters: nil,
                                       encoding: JSONEncoding.default,
                                       headers: customReqeustHeaders,
                                       to: destination)
        .downloadProgress(queue: DispatchQueue.main) { (progress) in
                var progress = CGFloat(progress.completedUnitCount) / CGFloat(progress.totalUnitCount)
                if progress < 0 {
                    progress = 0.1
                }
                downloadProgress(progress)
        }
        .response { response in
            if let error = response.error {
                let rasieError = FPError.errorWithCode(.remoteFileDownloadFailed, failureReason: "Download remote file failed", error: error)
                complete(rasieError)
            } else {
                complete(nil)
            }
        }
        return downloadRequest
    }
}
