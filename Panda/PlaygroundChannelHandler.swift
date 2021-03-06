//
//  PlaygroundChannelHandler.swift
//  Pods
//
//  Created by Martin Kim Dung-Pham on 29/09/2016.
//
//

import Foundation
import RxSwift

open class PlaygroundChannelHandler: ChannelHandler {
    open var messageHandler: ((_ message: String, _ position: Int) -> Void)?
    
    override func registerCallbacks(_ channel: Observable<ChannelEvent>) {
        channel.subscribe { (event: Event<ChannelEvent>) in
            //switch event.element {
            //case ChannelEvent.event(_):
                //let body = payload.payload["body"] as! String
                //let position = payload.payload["position"] as! NSNumber
                //messageHandler(body, position.intValue)
              //  break
           // }
        }
        /*
        let _ = channel.on("new:msg", callback: { message in
            if let messageHandler = self.messageHandler {
                let body = message.payload["body"] as! String
                let position = message.payload["position"] as! NSNumber
                messageHandler(body, position.intValue)
            }
        })
 */
    }
    
    open func sendMessage(_ message: String) {
        /*
        if let channel = self.channel {
            let _ = channel.send("new:msg", payload: ["body": message as AnyObject])
                .receive("ok", callback: { response in
                    print("Sent a message!")
                })
                .receive("error", callback: { reason in
                    print("Message didn't send: \(reason)")
                })
        }
         */
    }
    
}
