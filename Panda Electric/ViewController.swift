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

class ViewController: NSViewController {

    @IBOutlet var inputField: NSTextField!
    @IBOutlet var messageLabel: NSTextField!
    let socket = Socket(url: NSURL(string: "http://localhost:4000/socket/websocket")!)
//    let socket = Socket(url: NSURL(string: "https://tranquil-peak-78260.herokuapp.com/socket/websocket")!)
    var socketHandler: SocketHandler? {
        didSet {
            socketHandler?.messageHandler = { (message: String, position: Int) -> Void in
                self.handleMessage(message, atPosition: position)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        socket.onConnect = {
            print("Socket connected")
            let topic = "main"
            self.socketHandler = SocketHandler(user: "mac", topic:topic, socket: self.socket)
        }
        socket.connect()
    }
    
    private func handleMessage(message: String, atPosition position: Int) {
        if let messageLabel = self.messageLabel {
            messageLabel.stringValue = message + " \(position)"
        }
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    

}

