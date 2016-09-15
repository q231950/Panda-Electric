//
//  SocketHandler.swift
//  Pods
//
//  Created by Martin Kim Dung-Pham on 06/08/16.
//
//

import Foundation
import Birdsong

public class SocketHandler {
    public var topic: String!
    public var user: String!
    public var messageHandler: ((message: String, position: Int) -> Void)?
    var socket: Socket!
    var channel: Channel?
    
    public init(user: String, topic: String, socket: Socket) {
        self.user = user
        self.topic = topic
        self.socket = socket
        self.configureSocket()
    }
    
    private func configureSocket() {
        if let socket = self.socket {
            let channelIdentifier = "playground:\(topic!)"
            let channel = socket.channel(channelIdentifier, payload: ["user": user])
            
            channel.on("new:msg", callback: { message in
                if let messageHandler = self.messageHandler {
                    let body = message.payload["body"] as! String
                    let position = message.payload["position"] as! NSNumber
                    self.messageHandler!(message: body, position: position.integerValue)
                }
            })
            
            channel.join().receive("ok", callback: { payload in
                self.channel = channel
                print("Successfully joined: \(channel.topic)")
            })
        }
    }
    
    public func sendMessage(message: String) {
        if let channel = self.channel {
            channel.send("new:msg", payload: ["body": message])
                .receive("ok", callback: { response in
                    print("Sent a message!")
                })
                .receive("error", callback: { reason in
                    print("Message didn't send: \(reason)")
                })
        }
    }
}