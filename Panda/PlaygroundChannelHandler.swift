//
//  PlaygroundChannelHandler.swift
//  Pods
//
//  Created by Martin Kim Dung-Pham on 29/09/2016.
//
//

import Foundation

public class PlaygroundChannelHandler: ChannelHandler {
    public var messageHandler: ((_ message: String, _ position: Int) -> Void)?
    
    override func registerCallbacks(channel: Channel) {
        channel.on("new:msg", callback: { message in
            if let messageHandler = self.messageHandler {
                let body = message.payload["body"] as! String
                let position = message.payload["position"] as! NSNumber
                self.messageHandler!(body, position.intValue)
            }
        })
    }
    
    public func sendMessage(message: String) {
        if let channel = self.channel {
            channel.send("new:msg", payload: ["body": message as AnyObject])
                .receive("ok", callback: { response in
                    print("Sent a message!")
                })
                .receive("error", callback: { reason in
                    print("Message didn't send: \(reason)")
                })
        }
    }
    
}
