//
//  RxChannel.swift
//  Panda
//
//  Created by Martin Kim Dung-Pham on 22/11/2016.
//  Copyright © 2016 Martin Kim Dung-Pham. All rights reserved.
//

import Foundation
import RxSwift
import os.log

public enum ChannelEvent {
    case event(event:String, payload:Socket.Payload)
    case data(NSData)
    case joined
}

public class RxChannel {
    
    private let subject = PublishSubject<ChannelEvent>()
    private let channel: Channel
    static let channelLog = OSLog(subsystem: "com.elbedev.Panda", category: "Channel")
    
    init(_ socket: Socket, 👨‍🚀: Observable<SocketConnectivityState>, topic: String, payload: Socket.Payload) {
        channel = Channel(socket: socket, topic: topic, params: payload)
        
        os_log("joining %@", log: RxChannel.channelLog, type: .info, topic)
        let _ = channel.join().receive("ok", callback: { (payload: Socket.Payload) in
            os_log("joined", log: RxChannel.channelLog, type: .info)
            self.subject.on(.next(ChannelEvent.joined))
        })
        
        let _ = 👨‍🚀.subscribe { (event: Event<SocketConnectivityState>) in
            switch event.element {
            case .Connected?:
                os_log("connected", log: RxChannel.channelLog, type: .info)
            case .Disconnected(_)?:
                os_log("disconnected", log: RxChannel.channelLog, type: .error)
                self.subject.on(.error(NSError()))
            default: break
            }
        }
    }
    
    public func send(topic: String, payload: Socket.Payload) -> Observable<ChannelEvent> {
        let push = channel.send(topic, payload: payload)
        let _ = push.receive("ok", callback: {(payload: Socket.Payload)  in
            os_log("%@ received ok", log:RxChannel.channelLog, type: .debug, topic)
            self.subject.on(.next(ChannelEvent.event(event:push.event , payload: payload)))
        })
        let _ = push.receive("error", callback: {(payload: Socket.Payload)  in
            os_log("%@ received error %@", log:RxChannel.channelLog, type: .error, topic, payload)
            //self.subject.on(.next(ChannelEvent.event(event:push.event , payload: payload)))
            self.subject.on(.error(NSError()))
        })
        
        return self.subject
    }
    
    public func rx_channelEvent() -> Observable<ChannelEvent> {
        return self.subject
    }
}
