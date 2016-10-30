//
//  DisconnectedState.swift
//  Panda Electric Mobile
//
//  Created by Martin Kim Dung-Pham on 16/09/2016.
//  Copyright © 2016 elbedev.com. All rights reserved.
//

import GameplayKit

class DisconnectedState: GKState {

    private var channelHandlers = [ChannelHandler]()
    
    init(channelHandlers: [ChannelHandler]) {
        self.channelHandlers.append(contentsOf: channelHandlers)
    }
    
    public func appendChannelHandler(_ channelHandler: ChannelHandler) {
        channelHandlers.append(channelHandler)
    }
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        // os_log(OS_LOG_DEFAULT, "Socket connection disconnected with error:\(error).")
        print("socket.onDisconnect")
        
        channelHandlers.forEach { (handler: ChannelHandler) in
            handler.didDisconnect()
        }
    }
}
