//
//  PandaAPI.swift
//  Pods
//
//  Created by Martin Kim Dung-Pham on 18/09/2016.
//
//

import Foundation

enum BackendURL: String {
    case localhost = "http://localhost:4000/socket/websocket"
    case heroku = "https://tranquil-peak-78260.herokuapp.com/socket/websocket"
}


open class PandaAPI {

    open let baseURL: String
    
    public init() {
        
        let environment = ProcessInfo.processInfo.environment
        if environment["RUN_ON_LOCALHOST"] == "true" {
            baseURL = BackendURL.localhost.rawValue
        } else {
            baseURL = BackendURL.heroku.rawValue
        }
    }
    
    open func createUser(_ name: String, completion: @escaping (_ user: User?, _ error: Error?) -> Swift.Void) {
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
        if let url = URL(string: baseURL.appending("users/")) {
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
                    print("URL Session Task Succeeded: HTTP \(statusCode)")
                    let json = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String : AnyObject]
                    let user = User(uuid: json["uuid"] as! String, name: json["name"] as! String)
                    completion(user, nil)
                }
                else {
                    // Failure
                    print("URL Session Task Failed: %@", error!.localizedDescription);
                    completion(nil, error)
                }
            })
            task.resume()
            session.finishTasksAndInvalidate()
        }
    }
    
    open func createSession(_ title: String, user: String, completion: @escaping (_ session: PandaSession?, _ error: Error?) -> Swift.Void) {
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
        
        guard var URL = URL(string: baseURL.appending("sessions")) else {return}
        let URLParams = [
            "user": user,
            ]
        URL = URL.URLByAppendingQueryParameters(URLParams)
        let request = NSMutableURLRequest(url: URL as URL)
        request.httpMethod = "POST"
        
        // Headers
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        // JSON Body
        let bodyObject = [
            "session": [
                "title": title
            ],
            "user": [
                "id": user
            ]
        ]
        request.httpBody = try! JSONSerialization.data(withJSONObject: bodyObject, options: [])
        
        /* Start a new Task */
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error == nil) {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("URL Session Task Succeeded: HTTP \(statusCode)")
                let json = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                let pandaSession = PandaSession(dict: json as! [String : AnyObject])
                completion(pandaSession, nil)
            }
            else {
                // Failure
                print("URL Session Task Failed: %@", error!.localizedDescription);
                completion(nil, error)
            }
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    open func sessions(_ user: String, completion: @escaping (_ sessions: [PandaSession]?, _ error: Error?) -> Swift.Void) {
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
        
        guard var URL = URL(string: baseURL.appending("sessions")) else {return}
        let URLParams = [
            "user": user,
            ]
        URL = URL.URLByAppendingQueryParameters(URLParams)
        let request = NSMutableURLRequest(url: URL as URL)
        request.httpMethod = "GET"
        
        // Headers
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        // JSON Body
        let bodyObject = [
            "user": [
                "id": user
            ]
        ]
        request.httpBody = try! JSONSerialization.data(withJSONObject: bodyObject, options: [])
        
        /* Start a new Task */
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error == nil) {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("URL Session Task Succeeded: HTTP \(statusCode)")
                if let json = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [AnyObject] {
                    var sessions = [PandaSession]()
                    json.forEach({ (dict: AnyObject) in
                        let pandaSession = PandaSession(dict: dict as! [String : AnyObject])
                        sessions.append(pandaSession)
                    })
                    
                    completion(sessions, nil)
                } else {
                    print("Failed to parse Sessions: %@", error!.localizedDescription);
                    completion(nil, error)
                }
            }
            else {
                // Failure
                print("URL Session Task Failed: %@", error!.localizedDescription);
                completion(nil, error)
            }
        })
        task.resume()
        session.finishTasksAndInvalidate()
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
