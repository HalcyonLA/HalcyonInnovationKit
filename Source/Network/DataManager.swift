//
//  DataManager.swift
//  HalcyonInnovationKit
//
//  Created by Vlad Getman on 24.05.16.
//  Copyright © 2016 Vlad Getman. All rights reserved.
//

import Foundation
import AFNetworking
import AFNetworking_RetryPolicy
import MBProgressHUD
import XCGLogger

public protocol DataManagerErrorDelegate: NSObjectProtocol {
    func handleError(_ error: NSError)
}

open class DataManagerResponse: NSObject {
    open var response: Any? = nil
    open var error: NSError? = nil
    open var isCancelled: Bool = false
    
    fileprivate init(response: Any?, error: NSError?) {
        self.response = response
        self.error = error
        super.init()
    }
    
    fileprivate init(isCancelled: Bool) {
        self.isCancelled = isCancelled
        super.init()
    }
}

public typealias DataManagerCompletion = (_ response: DataManagerResponse) -> Void

open class DataManagerRequest: NSObject {
    
    open var path: String
    open var parameters: [String: Any] = [:]
    open var files: [String : MediaData]? = nil
    open weak var sender: AnyObject? = nil
    open weak var loadingView: UIView? = nil
    open var showActivityIndicator: Bool = true
    open var log: Bool = false
    open var completion: DataManagerCompletion? = nil
    fileprivate weak var task: URLSessionDataTask? = nil
    
    public required init(path: String) {
        self.path = path
        super.init()
    }
    
    @discardableResult
    open func start() -> DataManagerRequest {
        self.task = DataManager.shared.post(self)
        return self
    }
    
    @discardableResult
    open func start(completion: @escaping DataManagerCompletion) -> DataManagerRequest {
        self.task = DataManager.shared.post(self)
        self.completion = completion
        return self
    }
    
    @objc open func cancel() {
        task?.cancel()
    }
}

open class DataManager: NSObject {
    
    public static var BaseURL = ""
    public static var APIVersion = "1"
    public static var globalParameters: [String: Any]?
    
    public static var logEnabled = true
    public static var secured = true
    
    fileprivate let securedKeys = ["password", "token"]
    
    public static let shared = DataManager()
    
    open weak var errorDelegate: DataManagerErrorDelegate?
    open var securityPolicy: AFSecurityPolicy {
        set {
            sessionManager.securityPolicy = newValue
        }
        get {
            return sessionManager.securityPolicy
        }
    }
    
    fileprivate let log = XCGLogger.default
    
    public static var GlobalLoadingView: UIView { return UIApplication.shared.keyWindow! }
    
    fileprivate var networkActivityCount = 0
    private lazy var sessionManager: AFHTTPSessionManager = {
        return AFHTTPSessionManager(baseURL: URL(string: DataManager.BaseURL)!)
    }()
    fileprivate var requests = [DataManagerRequest]()
    
    fileprivate var apiURL: String {
        get {
            return "api/\(DataManager.APIVersion)/"
        }
    }
    
    override init() {
        super.init()
        
        let codes = NSMutableIndexSet()
        codes.add(200)
        codes.add(404)
        
        let serializer = AFJSONResponseSerializer()
        serializer.acceptableStatusCodes = codes as IndexSet
        serializer.acceptableContentTypes = ["text/html", "text/plain", "application/json"]
        sessionManager.responseSerializer = serializer
    }
    
    // MARK: Network Acvitiy Indicator
    
    open func addNetworkActivity() {
        synced(networkActivityCount) {
            if networkActivityCount == 0 {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }
            networkActivityCount += 1
        }
    }
    
    open func removeNetworkActivity() {
        synced(networkActivityCount) {
            networkActivityCount -= 1
            if (networkActivityCount == 0) {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    // MARK: Loading Indicator
    
    @discardableResult
    @objc public static func showLoading(_ show: Bool, inView: UIView) -> MBProgressHUD? {
        return inView.showLoadingHUD(show)
    }
    
    // MARK: Error check
    
    public static func isErrorFromAPI(_ error: NSError?) -> Bool {
        if (error == nil) {
            return false
        }
        return error?.domain == DataManager.shared.apiURL
    }
    
    // MARK: Log
    
    fileprivate func logString(_ log: String, function: String, error: Bool = false) {
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
    @discardableResult
    open func post(_ request: DataManagerRequest) -> URLSessionDataTask? {
        
        var params = request.parameters
        
        if request.showActivityIndicator {
            self.addNetworkActivity()
        }
        
        if let loadingView = request.loadingView {
            DataManager.showLoading(true, inView: loadingView)
        }
        
        let path = request.path
        let urlString = apiURL + path
        var json = "{}"
        
        var urlLogString = path
        if params.count > 0 {
            json = params.jsonString
            
            var debugJSON = ""
            #if DEBUG
                debugJSON = json
            #else
                debugJSON = securedParametersForLog(params).jsonString
            #endif
            if debugJSON.count > 0 {
                urlLogString = "\(path) : \(debugJSON)"
            }
        }
        
        if let globalParameters = DataManager.globalParameters {
            params += globalParameters
            json = params.jsonString
        }
        
        if !request.log {
            log.severe(urlLogString)
        }
        
        let bodyBlock = { (formData: AFMultipartFormData) -> Void in
            if let files = request.files {
                for (key, value) in files {
                    formData.appendPart(withFileData: value.data, name: key, fileName: value.name, mimeType: value.contentType)
                }
            }
        }
        
        func completionBlock() {
            if request.showActivityIndicator {
                self.removeNetworkActivity()
            }
            if let loadingView = request.loadingView {
                DataManager.showLoading(false, inView: loadingView)
            }
        }
        
        func cleanFinishedRequests(_ task: URLSessionDataTask?) {
            synced(self) {
                var nullTasks = self.requests.filter({ $0.task == nil })
                if task != nil {
                    nullTasks += self.requests.filter({ $0.task === task })
                }
                for (_, request) in nullTasks.enumerated() {
                    if let index = self.requests.index(of: request) {
                        self.requests.remove(at: index)
                    }
                }
            }
        }
        
        let successBlock = { (task: URLSessionDataTask, responseObject: Any?) -> Void in
            completionBlock()
            if let response = responseObject as? [String: Any] {
                let json = response["data"]
                var error: NSError? = nil
                var statusFailed = true
                if let status = response["status"] as? String {
                    statusFailed = status != "ok"
                }
                
                if statusFailed {
                    var errorDescription = ""
                    if let message = response["message"] as? String {
                        errorDescription = message
                    } else {
                        errorDescription = "Unkwnown error"
                    }
                    let userInfo = [NSLocalizedDescriptionKey: errorDescription]
                    let code = response["code"] as? Int ?? -10000
                    error = NSError(domain: self.apiURL, code: code, userInfo: userInfo)
                    self.errorDelegate?.handleError(error!)
                }
                if request.log || (!request.log && error != nil) {
                    if (error != nil) {
                        self.logString("error: \(error!.localizedDescription)", function: urlLogString)
                    } else {
                        self.logString("response: \(String(describing: json))", function: urlLogString)
                    }
                }
                request.completion?(DataManagerResponse(response: json as Any?, error: error))
            } else {
                let userInfo = [NSLocalizedDescriptionKey:"Responce has inccorect data type"]
                let error = NSError(domain: self.apiURL, code: -2, userInfo: userInfo)
                self.logString("error: \(error.localizedDescription) - \(String(describing: responseObject))", function: urlLogString)
                request.completion?(DataManagerResponse(response: nil, error: error))
            }
            cleanFinishedRequests(task)
        }
        
        let failureBlock = { (task: URLSessionDataTask?, err: Error) -> Void in
            completionBlock()
            let error = err as NSError
            if error.code == NSURLErrorCancelled {
                request.completion?(DataManagerResponse(isCancelled: true))
            } else {
                self.logString("error: \(error.localizedDescription)", function: urlLogString, error: true)
                
                var data = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] as? Data
                if data == nil {
                    if let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? NSError {
                        data = underlyingError.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] as? Data
                    }
                }
                if data != nil {
                    let errorString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    self.log.error("INVALID JSON ERROR : \(String(describing: errorString))")
                }
                
                request.completion?(DataManagerResponse(response: nil, error: error))
            }
            cleanFinishedRequests(task)
        }
        
        let task = sessionManager.post(urlString, parameters: ["json":json], constructingBodyWith: { (formData) in
            if let data = formData {
                bodyBlock(data)
            }
        }, progress: nil, success: { (task, responseObject) in
            successBlock(task!, responseObject)
        }, failure: { (taks, error) in
            failureBlock(taks, error!)
        }, retryCount: 2,
           retryInterval: 2,
           progressive: true,
           fatalStatusCodes: [NSNumber(value: 404), NSNumber(value: 500)])
        if task != nil {
            requests.append(request)
        }
        return task
    }
    
    open func cancelAllRequets() {
        for i in 0..<requests.count {
            if requests[i].task != nil {
                requests[i].task!.cancel()
            }
        }
        requests.removeAll()
    }
    
    open func cancelRequests(sender: AnyObject) {
        for var i in 0..<requests.count {
            let request = requests[i]
            if request.sender != nil && request.sender! === sender && request.task != nil {
                request.task!.cancel()
                requests.remove(at: i)
                i -= 1
            }
        }
    }
    
    // MARK: Helpers
    
    fileprivate func securedParametersForLog(_ parameters: [String: Any]) -> [String: Any] {
        if !DataManager.secured {
            return parameters
        }
        var logParameters = parameters
        for (key, value) in logParameters {
            if value is String {
                var secured = false
                for (_, securedKey) in securedKeys.enumerated() {
                    if key.lowercased().contains(securedKey) {
                        secured = true
                        break
                    }
                }
                if secured {
                    logParameters[key] = "<secured>" as Any?
                }
            }
        }
        return logParameters
    }
}
