//
//  ChannelHandler.swift
//  Pods
//
//  Created by Martin Kim Dung-Pham on 06/08/16.
//
//

import Foundation
import RxSwift

open class ChannelHandler {
    internal var channel: RxChannel?
    public let topic: String
    public let channelIdentifier: String
    private let user: String
    
    public init(user: String, channel: String, topic: String) {
        self.user = user
        self.topic = topic
        self.channelIdentifier = channel
    }
    
    open func configureWithSocket(_ socket: RxSocket) {
        
        let channelIdentifier = "\(self.channelIdentifier):\(topic)"
        print("connecting to channel: \(channelIdentifier)")
        channel = socket.channel(channelIdentifier, payload: ["user": user as AnyObject])
        
        /*
        let _ = channel?.join().receive("ok", callback: { payload in
            print("Successfully joined: \(self.channel?.topic)")
        })
         */
    }
    
    open func didDisconnect() {
        //let _ = channel?.leave()
    }
    
    // MARK: Subclass overrides
    
    internal func registerCallbacks(_ channel: Observable<ChannelEvent>) {
//        assertionFailure("This is abstract. Must be overridden by subclass")
    }
}
