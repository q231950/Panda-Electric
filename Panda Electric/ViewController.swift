//
//  ViewController.swift
//  Panda Electric
//
//  Created by Martin Kim Dung-Pham on 30/07/16.
//  Copyright © 2016 elbedev.com. All rights reserved.
//

import Cocoa
import Birdsong
import Panda

class ViewController: NSViewController, NSTextFieldDelegate {

    @IBOutlet var inputField: NSTextField!
    @IBOutlet var messageLabel: NSTextField!
    //    let socket = Socket(url: "https://tranquil-peak-78260.herokuapp.com/socket/websocket")

    var pandaConnection: PandaConnection!
    var playgroundChannelHandler: PlaygroundChannelHandler! {
        didSet {
            playgroundChannelHandler?.messageHandler = { (message: String, position: Int) -> Void in
                self.handleMessage(message, atPosition: position)
            }
        }
    }
    var estimateChannelHandler: EstimateChannelHandler! {
        didSet {
            estimateChannelHandler?.estimateHandler = { (estimate: Estimate) -> Void in
                print("handle estimation result \(estimate)")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputField.delegate = self

        let topic = "main"
        let user = "mac"
        playgroundChannelHandler = PlaygroundChannelHandler(user: user,
                                                            channel:"playground",
                                                            topic:topic)
        
        estimateChannelHandler = EstimateChannelHandler(user: user,
                                                        channel:"session",
                                                        topic:topic)
        
        pandaConnection = PandaConnection(url: "http://localhost:4000/socket/websocket", channelHandlers: [playgroundChannelHandler, estimateChannelHandler])
    }
    
    fileprivate func handleMessage(_ message: String, atPosition position: Int) {
        if let messageLabel = self.messageLabel {
            messageLabel.stringValue = message + " \(position)"
        }
    }

    // MARK: NSTextFieldDelegate
    override func controlTextDidEndEditing(_ obj: Notification) {
        guard inputField.stringValue.lengthOfBytes(using: .utf8) > 0 else {
            return
        }
        
        if let socketHandler = playgroundChannelHandler {
            socketHandler.sendMessage(message: inputField.stringValue)
        }
        if let estimateChannelHandler = estimateChannelHandler {
            estimateChannelHandler.sendEstimate(estimate: .tshirt(size: .S)) // //.fibonacci(8)
        }
    }
}

