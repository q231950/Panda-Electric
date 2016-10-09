//
//  ChannelHandler.swift
//  Pods
//
//  Created by Martin Kim Dung-Pham on 06/08/16.
//
//

import Foundation

open class ChannelHandler {
    internal var channel: Channel?
    public let topic: String
    public let channelIdentifier: String
    fileprivate let user: String
    
    public init(user: String, channel: String, topic: String) {
        self.user = user
        self.topic = topic
        self.channelIdentifier = channel
    }
    
    open func configureWithSocket(_ socket: Socket) {
        let channelIdentifier = "\(self.channelIdentifier):\(topic)"
        channel = socket.channel(channelIdentifier, payload: ["user": user as AnyObject])
        registerCallbacks(channel!)
        
        channel?.join().receive("ok", callback: { payload in
            print("Successfully joined: \(self.channel?.topic)")
        })
    }
    
    open func didDisconnect() {
        channel?.leave()
    }
    
    // MARK: Subclass overrides
    
    internal func registerCallbacks(_ channel: Channel) {
        assertionFailure("This is abstract. Must be overridden by subclass")
    }
}
