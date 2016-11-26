//
//  RxChannel.swift
//  Panda
//
//  Created by Martin Kim Dung-Pham on 22/11/2016.
//  Copyright © 2016 Martin Kim Dung-Pham. All rights reserved.
//

import Foundation
import RxSwift

public enum ChannelEvent {
    case event(event:String, payload:Socket.Payload)
    case data(NSData)
}

public class RxChannel {
    
    let subject = PublishSubject<ChannelEvent>()
    let channel: Channel
    
    init(_ socket: Socket, topic: String, payload: Socket.Payload) {
        channel = Channel(socket: socket, topic: topic, params: payload)
        channel.on("ok", callback: { response in
            let r:Response = response
            print("asd")
            
            self.subject.on(.next(ChannelEvent.event(event: response.event, payload: response.payload)))
        })
        
        channel.join()
    }
    
    public func send(uuid: String, payload: Socket.Payload) {
        let push = channel.send("read:sessions", payload: payload)
        //push.receive("ok", callback: {(payload: Socket.Payload)  in
         //   self.subject.on(.next(ChannelEvent.event(event:push.event , payload: payload)))
        //})
    }
    
    public func rx_channelEvent() -> Observable<ChannelEvent> {
        return self.subject
    }
}
