//
//  Connection.swift
//  Pods
//
//  Created by Martin Kim Dung-Pham on 17/09/2016.
//
//

import GameplayKit
import RxSwift

public protocol SocketProvider {
    func socket() -> RxSocket
}

public class PandaConnection: SocketProvider {
    
    //open var delegate: PandaConnectionDelegate?
    private var stateMachine: GKStateMachine?
    private let socketInternal: RxSocket
    private var connectedState: ConnectedState!
    private var disconnectedState: DisconnectedState!
    
    public init(url: String, channelHandlers: [ChannelHandler]) {
        socketInternal = RxSocket(url: URL(string: url)!) // TODO remove the force cast
        
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
        socketInternal.rx_connectivity.subscribe { (event: Event<SocketConnectivityState>) in
            switch event.element {
            case .Connected?:
                print("🎉")
                self.stateMachine?.enter(ConnectedState.self)
            case .Disconnected(_)?:
                print("🍓")
                self.stateMachine?.enter(DisconnectedState.self)
                self.reconnect(self.socketInternal)
            default: break
            }
        }
        
        socketInternal.connect()
    }
    
    public func socket() -> RxSocket {
        return socketInternal
    }
    
    private func reconnect(_ socket: RxSocket) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            socket.connect()
        })
    }
}
