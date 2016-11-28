//
//  PandaAPI.swift
//  Pods
//
//  Created by Martin Kim Dung-Pham on 18/09/2016.
//
//

import Foundation
import RxSwift
import os.log

enum BackendURL: String {
    case localhost = "http://192.168.1.14:4000/"
    case heroku = "https://tranquil-peak-78260.herokuapp.com/"
}


open class PandaAPI {

    static let log = OSLog(subsystem: "com.elbedev.Panda", category: "PandaAPI")
    private let baseURL: String
    open var socketUrl: String {
        get {
            return baseURL.appending("socket/websocket/")
        }
    }
    private var ApiUrl: String {
        get {
            return baseURL.appending("api/")
        }
    }
    
    public init() {
        
        let environment = ProcessInfo.processInfo.environment
        if environment["RUN_ON_LOCALHOST"] == "true" {
            baseURL = BackendURL.localhost.rawValue
        } else {
            baseURL = BackendURL.heroku.rawValue
        }
    }
    
    open func userWithName(_ name: String) -> Observable<User> {
        return Observable.create { observer in
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
            if let url = URL(string: self.ApiUrl.appending("users/")) {
                let body = [
                    "user": [
                        "name": name
                    ]
                ]
                let request = NSMutableURLRequest(url: url)
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: [])
                
                let task = session.dataTask(with: request as URLRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                    if (error == nil) {
                        // Success
                        let statusCode = (response as! HTTPURLResponse).statusCode
                        guard statusCode == 200 else {
                            os_log("url session task failed with status code HTTP %i and response %@", log: PandaSessionAPI.log, statusCode, response!)
                            return
                        }
                        
                        os_log("url session task succeeded: HTTP %i", log: PandaSessionAPI.log, statusCode)
                        let json = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String : AnyObject]
                        if let user = User(dict: json) {
                            observer.on(.next(user))
                            observer.on(.completed)
                        }
                    }
                    else {
                        // Failure
                        os_log("url sessio task failed with error %@", log: PandaSessionAPI.log, error!.localizedDescription)
                        observer.on(.error(error!))
                    }
                })
                task.resume()
                session.finishTasksAndInvalidate()
            }
            return Disposables.create()
        }
    }
}


protocol URLQueryParameterStringConvertible {
    var queryParameters: String {get}
}

extension Dictionary : URLQueryParameterStringConvertible {
    /**
     This computed property returns a query parameters string from the given NSDictionary. For
     example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
     string will be @"day=Tuesday&month=January".
     @return The computed parameters string.
     */
    var queryParameters: String {
        var parts: [String] = []
        for (key, value) in self {
            let part = NSString(format: "%@=%@",
                                String(describing: key).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!,
                                String(describing: value).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
            parts.append(part as String)
        }
        return parts.joined(separator: "&")
    }
    
}

extension URL {
    /**
     Creates a new URL by adding the given query parameters.
     @param parametersDictionary The query parameter dictionary to add.
     @return A new NSURL.
     */
    func URLByAppendingQueryParameters(_ parametersDictionary : Dictionary<String, String>) -> URL {
        let URLString : NSString = NSString(format: "%@?%@", self.absoluteString, parametersDictionary.queryParameters)
        return URL(string: URLString as String)!
    }

}
