//
//  EstimationChannelHandler.swift
//  Pods
//
//  Created by Martin Kim Dung-Pham on 29/09/2016.
//
//

import Foundation

open class EstimationChannelHandler: ChannelHandler {
    open var estimateHandler: ((_ estimate: Estimate) -> Void)?
    open var title: String?
    
    open func sendEstimate(_ estimate: Estimate, userIdentifier: String) {
        if let channel = self.channel {
            /*
             let _ = channel.send("new:estimate", payload: [estimate.kind: estimate.value as AnyObject,
             "user": userIdentifier as AnyObject])
             .receive("ok", callback: { response in
             print("Sent a message!")
             })
             .receive("error", callback: { reason in
             print("Message didn't send: \(reason)")
             })
             */
        }
    }
}
