//
//  Connection.swift
//  Pods
//
//  Created by Martin Kim Dung-Pham on 17/09/2016.
//
//

import GameplayKit
import RxSwift
import os.log

public protocol SocketProvider {
    func socket() -> RxSocket
}

public class PandaConnection: SocketProvider {
    
    static let socket_log = OSLog(subsystem: "com.elbedev.Panda", category: "Socket")
    
    private let socketWrapper: RxSocket
    
    public init(url: String, channelHandlers: [ChannelHandler]) {
        os_log("Initialised PandaConnection%@", log: PandaConnection.socket_log, ".")
        socketWrapper = RxSocket(url: URL(string: url)!) // TODO remove the force cast
        
        setupSocket()
    }
    
    public func appendChannelHandler(channelHandler: ChannelHandler) {
    }
    
    private func setupSocket() {
        socketWrapper.rx_connectivity.subscribe { (event: Event<SocketConnectivityState>) in
            switch event.element {
            case .Connected?:
                print("🎉")
                os_log("Connected!", log: PandaConnection.socket_log, type: .debug)
            case .Disconnected(_)?:
                print("🍓")
                os_log("Disconnected!", log: PandaConnection.socket_log, type: .debug)
                self.reconnect(self.socketWrapper)
            default: break
            }
        }
        
        socketWrapper.connect()
    }
    
    public func socket() -> RxSocket {
        return socketWrapper
    }
    
    private func reconnect(_ socket: RxSocket) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            socket.connect()
        })
    }
}
