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
    fileprivate var stateMachine: GKStateMachine?
    fileprivate let socketInternal: Socket
    
    public init(url: String, channelHandlers: [ChannelHandler]) {
        socketInternal = Socket(url: url)
        
        let connectedState = ConnectedState(socketProvider: self, channelHandlers: channelHandlers)
        let disconnectedState = DisconnectedState(channelHandlers: channelHandlers)
        stateMachine = GKStateMachine(states: [disconnectedState, connectedState])
        stateMachine?.enter(DisconnectedState.self)
        
        setupSocket()
    }
    
    fileprivate func setupSocket() {
        socketInternal.onConnect = {
            self.delegate?.connectionEstablished(self)
            self.stateMachine?.enter(ConnectedState.self)
        }
        
        socketInternal.onDisconnect = { (error: NSError?) in
            self.delegate?.connectionDisconnected(self)
            self.stateMachine?.enter(DisconnectedState.self)
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
