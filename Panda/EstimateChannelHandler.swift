//
//  EstimateChannelHandler.swift
//  Pods
//
//  Created by Martin Kim Dung-Pham on 29/09/2016.
//
//

import Birdsong

public class EstimateChannelHandler: ChannelHandler {
    public var estimateHandler: ((_ estimate: Estimate) -> Void)?
    
    override func registerCallbacks(channel: Channel) {
        channel.on("new:fibonacci_result", callback: { message in
            if let result = message.payload["fibonacci"] as? NSNumber {
                self.estimateHandler?(Estimate.fibonacci(result.intValue))
            }
        })
        channel.on("new:tshirt_result", callback: { message in
            if let size = TShirtSize(rawValue: message.payload["size"] as! String) {
                self.estimateHandler?(Estimate.tshirt(size: size))
            } else {
                print("unhandled tshirt result \(message)")
            }
        })
    }
    
    public func sendEstimate(estimate: Estimate) {
        if let channel = self.channel {
            channel.send("new:estimate", payload: [estimate.kind: estimate.value as AnyObject])
                .receive("ok", callback: { response in
                    print("Sent a message!")
                })
                .receive("error", callback: { reason in
                    print("Message didn't send: \(reason)")
                })
        }
    }
}
