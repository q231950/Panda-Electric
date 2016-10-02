//
//  ChannelHandler.swift
//  Pods
//
//  Created by Martin Kim Dung-Pham on 06/08/16.
//
//

import Foundation

public class ChannelHandler {
    internal var channel: Channel?
    fileprivate let topic: String
    fileprivate let user: String
    fileprivate let channelName: String
    
    public init(user: String, channel: String, topic: String) {
        self.user = user
        self.topic = topic
        self.channelName = channel
    }
    
    public func configureWithSocket(socket: Socket) {
        let channelIdentifier = "\(channelName):\(topic)"
        channel = socket.channel(channelIdentifier, payload: ["user": user as AnyObject])
        registerCallbacks(channel: channel!)
        
        channel?.join().receive("ok", callback: { payload in
            print("Successfully joined: \(self.channel?.topic)")
        })
    }
    
    public func didDisconnect() {
        channel?.leave()
    }
    
    // MARK: Subclass overrides
    
    internal func registerCallbacks(channel: Channel) {
        assertionFailure("This is abstract. Must be overridden by subclass")
    }
}
