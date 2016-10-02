//
//  ViewController.swift
//  Panda Electric
//
//  Created by Martin Kim Dung-Pham on 30/07/16.
//  Copyright © 2016 elbedev.com. All rights reserved.
//

import Cocoa
import Panda

class ViewController: NSViewController, NSTextFieldDelegate {

    @IBOutlet var inputField: NSTextField!
    @IBOutlet var messageLabel: NSTextField!

    fileprivate var pandaConnection: PandaConnection!
    fileprivate var playgroundChannelHandler: PlaygroundChannelHandler! {
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
        
//        let url = "https://tranquil-peak-78260.herokuapp.com/socket/websocket"
        let url = "http://localhost:4000/socket/websocket"
        pandaConnection = PandaConnection(url: url, channelHandlers: [playgroundChannelHandler, estimateChannelHandler])
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
            estimateChannelHandler.sendEstimate(estimate: .fibonacci(8)) // .tshirt(size: .S)
        }
    }
}

