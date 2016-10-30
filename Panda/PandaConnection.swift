//
//  Connection.swift
//  Pods
//
//  Created by Martin Kim Dung-Pham on 17/09/2016.
//
//

import GameplayKit

public protocol PandaConnectionDelegate {
    func connectionEstablished(_ connection: PandaConnection)
    func connectionDisconnected(_ connection: PandaConnection)
}

protocol SocketProvider {
    func socket() -> Socket
}

open class PandaConnection: SocketProvider {
    
    open var delegate: PandaConnectionDelegate?
    private var stateMachine: GKStateMachine?
    private let socketInternal: Socket
    private var connectedState: ConnectedState!
    private var disconnectedState: DisconnectedState!
    
    public init(url: String, channelHandlers: [ChannelHandler]) {
        socketInternal = Socket(url: url)
        
        connectedState = ConnectedState(socketProvider: self, channelHandlers: channelHandlers)
        disconnectedState = DisconnectedState(channelHandlers: channelHandlers)
        stateMachine = GKStateMachine(states: [disconnectedState, connectedState])
        stateMachine?.enter(DisconnectedState.self)
        
        setupSocket()
    }
    
    public func appendChannelHandler(channelHandler: ChannelHandler) {
        connectedState.appendChannelHandler(channelHandler)
        disconnectedState.appendChannelHandler(channelHandler)
    }
    
    private func setupSocket() {
        socketInternal.onConnect = {
            self.stateMachine?.enter(ConnectedState.self)
            self.delegate?.connectionEstablished(self)
        }
        
        socketInternal.onDisconnect = { (error: NSError?) in
            self.stateMachine?.enter(DisconnectedState.self)
            self.delegate?.connectionDisconnected(self)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.socketInternal.connect()
            })
        }
        
        socketInternal.connect()
    }
    
    func socket() -> Socket {
        return socketInternal
    }
}
