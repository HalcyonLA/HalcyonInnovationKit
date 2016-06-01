//
//  DataManager.swift
//  HalcyonInnovationKit
//
//  Created by Vlad Getman on 24.05.16.
//  Copyright © 2016 Vlad Getman. All rights reserved.
//

import Foundation
import AFNetworking
import MBProgressHUD
import XCGLogger

public class DataManagerResponse: NSObject {
    public var response: AnyObject? = nil
    public var error: NSError? = nil
    
    private init(response: AnyObject?, error: NSError?) {
        self.response = response
        self.error = error
        super.init()
    }
}

public typealias DataManagerCompletion = (response: DataManagerResponse) -> Void

public class DataManagerRequest: NSObject {
    
    public var path: String
    public var parameters: [String : AnyObject] = [:]
    public var files: [String : MediaData]? = nil
    public weak var sender: AnyObject? = nil
    public weak var loadingView: UIView? = nil
    public var showActivityIndicator: Bool = true
    public var log: Bool = false
    public var completion: DataManagerCompletion? = nil
    private weak var task: NSURLSessionDataTask? = nil
    
    public required init(path: String) {
        self.path = path
        super.init()
    }
    
    public func start() -> DataManagerRequest {
        self.task = DataManager.shared.post(self)
        return self
    }
    
    public func start(completion completion: DataManagerCompletion) -> DataManagerRequest {
        self.task = DataManager.shared.post(self)
        self.completion = completion
        return self
    }
    
    public func cancel() {
        task?.cancel()
    }
}

public class DataManager: NSObject {
    
    public static var BaseURL = ""
    public static var APIVersion = "1"
    
    public static var logEnabled = true
    public static var secured = true
    
    private let securedKeys = ["password", "token"]
    
    public static let shared = DataManager()
    
    let log = XCGLogger.defaultInstance()
    
    public static var GlobalLoadingView: UIView { return UIApplication.sharedApplication().keyWindow! }
    
    var networkActivityCount = 0
    let sessionManager = AFHTTPSessionManager()
    
    private var requests = [DataManagerRequest]()
    
    private var apiURL: String {
        get {
            return "\(DataManager.BaseURL)/api/\(DataManager.APIVersion)/"
        }
    }
    
    override init() {
        super.init()
        
        let codes = NSMutableIndexSet.init()
        codes.addIndex(200)
        codes.addIndex(404)
        
        let serializer = AFJSONResponseSerializer()
        serializer.acceptableStatusCodes = codes
        serializer.acceptableContentTypes = ["text/html", "text/plain", "application/json"]
        
        sessionManager.securityPolicy = AFSecurityPolicy.init(pinningMode: .Certificate)
        sessionManager.responseSerializer = serializer
    }
    
    // MARK: Network Acvitiy Indicator
    
    public func addNetworkActivity() {
        if (networkActivityCount == 0) {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        }
        networkActivityCount += 1
    }
    
    public func removeNetworkActivity() {
        networkActivityCount -= 1
        if (networkActivityCount == 0) {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }
    
    // MARK: Loading Indicator
    
    public static func showLoading(show: Bool, inView: UIView) -> MBProgressHUD? {
        if (show) {
            let hud = MBProgressHUD.showHUDAddedTo(inView, animated: true)
            hud.mode = .Indeterminate
            hud.labelText = "Loading"
            hud.removeFromSuperViewOnHide = true
            return hud
        } else {
            MBProgressHUD.hideAllHUDsForView(inView, animated: true)
            return nil
        }
    }
    
    // MARK: Error check
    
    public static func isErrorFromAPI(error: NSError?) -> Bool {
        if (error == nil) {
            return false
        }
        return error?.domain == DataManager.shared.apiURL
    }
    
    // MARK: Log
    
    private func logString(log: String, function: String, error: Bool = false) {
        if (DataManager.logEnabled) {
            var logString = "\n---------------------------------------------------------------------------\n"
            logString += log
            logString += "\n---------------------------------------------------------------------------"
            
            let log = "DataManager - \(function)\(logString)"
            if (error) {
                self.log.error(log)
            } else {
                self.log.debug(log)
            }
        }
        
    }
    
    // MARK: Public
    
    public func post(request: DataManagerRequest) -> NSURLSessionDataTask? {
        
        var params = request.parameters
        
        if (request.showActivityIndicator) {
            self.addNetworkActivity()
        }
        
        if (request.loadingView != nil) {
            DataManager.showLoading(true, inView: request.loadingView!)
        }
        
        let path = request.path
        let urlString = apiURL.stringByAppendingString(path)
        var json = "{}"
        
        var urlLogString = ""
        do {
            json = params.jsonString
            
            var debugJSON = ""
            #if DEBUG
                debugJSON = json
            #else
                debugJSON = securedParametersForLog(params).jsonString
            #endif
            
            urlLogString = "\(path) : \(debugJSON)"
        } catch {
            urlLogString = path
        }
        
        if (!request.log) {
            log.severe(urlLogString)
        }
        
        let bodyBlock = { (formData: AFMultipartFormData) -> Void in
            if (request.files?.count > 0) {
                for (key, value) in request.files! {
                    formData.appendPartWithFileData(value.data!, name: key, fileName: value.name!, mimeType: value.contentType!)
                }
            }
        }
        
        func completionBlock() {
            if (request.showActivityIndicator) {
                self.removeNetworkActivity()
            }
            if (request.loadingView != nil) {
                DataManager.showLoading(false, inView: request.loadingView!)
            }
        }
        
        func cleanFinishedRequests(task: NSURLSessionDataTask?) {
            for var i in 0..<requests.count {
                if (requests[i].task == nil || requests[i].task! == task) {
                    requests.removeAtIndex(i)
                    i -= 1
                }
            }
        }
        
        let successBlock = { (task: NSURLSessionDataTask, responseObject: AnyObject?) -> Void in
            completionBlock()
            if (responseObject != nil && responseObject is Dictionary<String, AnyObject>) {
                    let json = responseObject?["data"]
                    var error: NSError? = nil
                    var statusFailed = true
                    if let status = responseObject!["status"] as? String {
                        statusFailed = status != "ok"
                    }
                    
                    if statusFailed {
                        var errorDescription = ""
                        if let message = responseObject!["message"] as? String {
                            errorDescription = message
                        } else {
                            errorDescription = "Unkwnown error"
                        }
                        let userInfo = [NSLocalizedDescriptionKey:errorDescription]
                        error = NSError.init(domain: self.apiURL, code: -10000, userInfo: userInfo)
                    }
                    if (request.log || (!request.log && error != nil)) {
                        if (error != nil) {
                            self.logString("error: \(error!.localizedDescription)", function: urlLogString)
                        } else {
                            self.logString("response: \(json)", function: urlLogString)
                        }
                    }
                if (request.completion != nil) {
                    request.completion!(response: DataManagerResponse.init(response: json?!, error: error))
                }
            } else {
                let userInfo = [NSLocalizedDescriptionKey:"Responce has inccorect data type"]
                let error = NSError.init(domain: self.apiURL, code: -2, userInfo: userInfo)
                self.logString("error: \(error.localizedDescription) - \(responseObject)", function: urlLogString)
                if (request.completion != nil) {
                    request.completion!(response: DataManagerResponse.init(response: nil, error: error))
                }
            }
            cleanFinishedRequests(task)
        }
        
        let failureBlock = { (task: NSURLSessionDataTask?, error: NSError) -> Void in
            completionBlock()
            
            if (error.code == NSURLErrorCancelled) {
                request.completion!(response: DataManagerResponse.init(response: nil, error: nil))
            } else {
                self.logString("error: \(error.localizedDescription)", function: urlLogString, error: true)
                
                var data = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] as? NSData
                if (data == nil) {
                    if let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? NSError {
                        data = underlyingError.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] as? NSData
                    }
                }
                if (data != nil) {
                    let errorString = NSString.init(data: data!, encoding: NSUTF8StringEncoding)
                    self.log.error("INVALID JSON ERROR : \(errorString)")
                }
                
                if (request.completion != nil) {
                    request.completion!(response: DataManagerResponse.init(response: nil, error: error))
                }
            }
            cleanFinishedRequests(task)
        }
        
        let task = sessionManager.POST(urlString, parameters: ["json":json], constructingBodyWithBlock: bodyBlock, progress: nil, success: successBlock, failure: failureBlock)
        if (task != nil) {
            requests.append(request)
        }
        return task
    }
    
    public func cancelAllRequets() {
        for i in 0..<requests.count {
            if (requests[i].task != nil) {
                requests[i].task!.cancel()
            }
        }
        requests.removeAll()
    }
    
    public func cancelRequests(sender sender: AnyObject) {
        for var i in 0..<requests.count {
            let request = requests[i]
            if (request.sender != nil && request.sender! === sender && request.task != nil) {
                request.task!.cancel()
                requests.removeAtIndex(i)
                i -= 1
            }
        }
    }
    
    // MARK: Helpers
    
    private func securedParametersForLog(parameters: [String : AnyObject]) -> [String : AnyObject] {
        if (!DataManager.secured) {
            return parameters
        }
        var logParameters = parameters
        for (key, value) in logParameters {
            if value is String {
                var secured = false
                for (_, securedKey) in securedKeys.enumerate() {
                    if key.lowercaseString.containsString(securedKey) {
                        secured = true
                        break
                    }
                }
                if (secured) {
                    logParameters[key] = "<secured>"
                }
            }
        }
        return logParameters
    }
}