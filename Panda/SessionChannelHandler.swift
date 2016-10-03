//
//  SessionChannelHandler.swift
//  Panda
//
//  Created by Martin Kim Dung-Pham on 03/10/2016.
//  Copyright © 2016 Martin Kim Dung-Pham. All rights reserved.
//

import Foundation

open class SessionChannelHandler: ChannelHandler {
    open var sessionHandler: ((_ session: PandaSession) -> Void)?
    
    override func registerCallbacks(_ channel: Channel) {
        let _ = channel.on("new:session", callback: { message in
            if let json = message.payload["session"] as? [String : AnyObject] {
                print("Received \(json)")
                self.sessionHandler?(PandaSession(dict: json))
            }
        })
    }
    
    open func requestSessions(_ user: String) {
        print("requestSessions")
        if let channel = self.channel {
            let _ = channel.send("read:sessions", payload: ["user": user as AnyObject])
                .receive("ok", callback: { response in
                    print("Requested sessions for user \(user).")
                })
                .receive("error", callback: { reason in
                    print("Error when requesting sessions for user \(user)")
                })
        }
    }
    
    open func createSession(_ user: String, title: String) {
        if let channel = self.channel {
            let _ = channel.send("new:session", payload: ["user": user as AnyObject, "title": title as AnyObject])
                .receive("ok", callback: { response in
                    print("Requested creation of a new session.")
                })
                .receive("error", callback: { reason in
                    print("Error when creating a session: \(reason)")
                })
        }
    }
}
