//
//  PandaAPI.swift
//  Pods
//
//  Created by Martin Kim Dung-Pham on 18/09/2016.
//
//

import Foundation

public class PandaSession {
    open let title: String
//    open let identifier: String
    init(dict: [String : AnyObject]) {
        title = dict["title"] as! String
//        identifier = dict["id"] as! Number
    }
}

public class PandaAPI {
    public static func createSession(title: String, user: String, completion: @escaping (_ session: PandaSession?, _ error: Error?) -> Swift.Void) {
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
        
        guard var URL = NSURL(string: "http://localhost:4000/api/sessions") else {return}
        let URLParams = [
            "user": user,
            ]
        URL = URL.URLByAppendingQueryParameters(parametersDictionary: URLParams)
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
    
    public static func sessions(user: String, completion: @escaping (_ sessions: [PandaSession]?, _ error: Error?) -> Swift.Void) {
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
        
        guard var URL = NSURL(string: "http://localhost:4000/api/sessions") else {return}
        let URLParams = [
            "user": user,
            ]
        URL = URL.URLByAppendingQueryParameters(parametersDictionary: URLParams)
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

extension NSURL {
    /**
     Creates a new URL by adding the given query parameters.
     @param parametersDictionary The query parameter dictionary to add.
     @return A new NSURL.
     */
    func URLByAppendingQueryParameters(parametersDictionary : Dictionary<String, String>) -> NSURL {
        let URLString : NSString = NSString(format: "%@?%@", self.absoluteString!, parametersDictionary.queryParameters)
        return NSURL(string: URLString as String)!
    }

}
