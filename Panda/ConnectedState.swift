//
//  ConnectedState.swift
//  Pods
//
//  Created by Martin Kim Dung-Pham on 17/09/2016.
//
//

import GameplayKit

class ConnectedState: GKState {
    
    fileprivate let socketProvider: SocketProvider
    fileprivate let channelHandlers: [ChannelHandler]!
    
    init(socketProvider: SocketProvider, channelHandlers: [ChannelHandler]) {
        self.socketProvider = socketProvider
        self.channelHandlers = channelHandlers
    }
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        // Unified logging support will come to Swift soon 👏
        // os_log(OS_LOG_DEFAULT, "Socket connection established.")
        print("Socket connection established.")
        
        channelHandlers.forEach { (handler: ChannelHandler) in
            handler.configureWithSocket(self.socketProvider.socket())
        }
    }
}
