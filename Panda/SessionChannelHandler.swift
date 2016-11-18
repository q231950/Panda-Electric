//
//  SessionChannelHandler.swift
//  Panda
//
//  Created by Martin Kim Dung-Pham on 03/10/2016.
//  Copyright © 2016 Martin Kim Dung-Pham. All rights reserved.
//

import Foundation
import RxSwift

open class SessionChannelHandler: ChannelHandler {
    open var sessionHandler: ((_ session: PandaSessionModel) -> Void)?
    private let domain = "com.elbedev.sessionChannelHandler"
    
    open func sessions(_ user: String) -> Observable<PandaSessionModel>{
        return Observable.create { observer in
            if let channel = self.channel {
                let _ = channel.send("read:sessions", payload: ["user": user as AnyObject])
                    .receive("ok", callback: { response in
                        if let json = response["response"] as? [String : AnyObject] {
                            if let jsonSessions = json["sessions"] as? [[String : AnyObject]] {
                                let _ = jsonSessions.map {
                                    (jsonSession: [String : AnyObject]) -> Void in
                                    if let session = PandaSessionModel(dict: jsonSession["session"] as! [String : AnyObject]) {
                                        observer.on(.next(session))
                                    }
                                }
                            }
                        }
                        observer.on(.completed)
                    })
                    .receive("error", callback: { reason in
                        print("Error when requesting sessions for user \(user)")
                    })
            }
        
            return Disposables.create()
        }
    }
    
    open func createSession(_ user: String, title: String) -> Observable<PandaSessionModel> {
        return Observable.create { observer in
            if let channel = self.channel {
                let _ = channel.send("new:session", payload: ["user": user as AnyObject, "title": title as AnyObject])
                    .receive("ok", callback: { response in
                        if let json = response["response"] as? [String : AnyObject] {
                            if let jsonSession = json["session"] as? [String : AnyObject] {
                                if let session = PandaSessionModel(dict: jsonSession) {
                                    observer.on(.next(session))
                                }
                            }
                        }
                    })
                    .receive("error", callback: { reason in
                        print("Error when creating a session: \(reason)")
                    })
            }
            
            return Disposables.create()
        }
    }
    
    open func joinSession(_ uuid: String, user: String) -> Observable<PandaSessionModel> {
        return Observable.create { observer in
            if let channel = self.channel {
                let _ = channel.send("join:session", payload: ["user": user as AnyObject, "uuid": uuid as AnyObject])
                    .receive("ok", callback: { response in
                        if let json = response["response"] as? [String : AnyObject] {
                            if let jsonSession = json["session"] as? [String : AnyObject] {
                                if let session = PandaSessionModel(dict: jsonSession) {
                                    observer.on(.next(session))
                                }
                            }
                        }
                    })
                    .receive("error", callback: { reason in
                        print("Error when creating a session: \(reason)")
                    })
            }
            
            return Disposables.create()
        }
    }
    
    open func deleteSession(user: String, uuid: String) -> Observable<String> {
        return Observable.create { observer in
            if let channel = self.channel {
                let _ = channel.send("delete:session", payload: ["user": user as AnyObject, "uuid": uuid as AnyObject])
                    .receive("ok", callback: { response in
                        observer.on(.next(uuid))
                    })
                    .receive("error", callback: { reason in
                        print("Error when creating a session: \(reason)")
                        let error = NSError(domain: self.domain, code: 3, userInfo: [NSLocalizedDescriptionKey : reason])
                        observer.on(.error(error))
                    })
        }
        
        return Disposables.create()
    }
}
}
