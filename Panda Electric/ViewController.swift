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
    let socket = Socket(url: "http://localhost:4000/socket/websocket")
    //    let socket = Socket(url: "https://tranquil-peak-78260.herokuapp.com/socket/websocket")

    var playgroundChannelHandler: PlaygroundChannelHandler? {
        didSet {
            playgroundChannelHandler?.messageHandler = { (message: String, position: Int) -> Void in
                self.handleMessage(message, atPosition: position)
            }
        }
    }
    var estimateChannelHandler: EstimateChannelHandler? {
        didSet {
            estimateChannelHandler?.fibonacciHandler = { (result: Int) -> Void in
                print("handle estimation result")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputField.delegate = self

        socket.onConnect = {
            print("Socket connected")
            let topic = "main"
            let user = "mac"
            self.playgroundChannelHandler = PlaygroundChannelHandler(user: user,
                                                                     socket: self.socket,
                                                                     channel:"playground",
                                                                     topic:topic)
            
            self.estimateChannelHandler = EstimateChannelHandler(user: user,
                                                                 socket: self.socket,
                                                                 channel:"session",
                                                                 topic:topic)
        }
        socket.connect()
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
            estimateChannelHandler.sendEstimate(estimate: .fibonacci(8)) // .tshirt(.S)
        }
    }
}

