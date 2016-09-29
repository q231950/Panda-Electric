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

    var socketHandler: PlaygroundChannelHandler? {
        didSet {
            socketHandler?.messageHandler = { (message: String, position: Int) -> Void in
                self.handleMessage(message, atPosition: position)
            }
        }
    }
    var fibonacciChannelHandler: FibonacciChannelHandler? {
        didSet {
            fibonacciChannelHandler?.fibonacciHandler = { (result: Int) -> Void in
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
            self.socketHandler = PlaygroundChannelHandler(user: "mac", socket: self.socket, channel:"playground", topic:topic)
            self.fibonacciChannelHandler = FibonacciChannelHandler(user: "mac", socket: self.socket, channel:"session", topic:topic)
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
        
        if let socketHandler = socketHandler {
            socketHandler.sendMessage(message: inputField.stringValue)
        }
        if let fibonacciChannelHandler = fibonacciChannelHandler {
            fibonacciChannelHandler.sendFibonacciNumber(number: 8)
        }
    }
}

