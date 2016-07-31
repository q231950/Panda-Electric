//
//  DetailViewController.swift
//  Panda Electric Mobile
//
//  Created by Martin Kim Dung-Pham on 30/07/16.
//  Copyright © 2016 elbedev.com. All rights reserved.
//

import UIKit
import Birdsong

class DetailViewController: UIViewController {

    var socket: Socket? {
        didSet {
            self.configureSocket()
        }
    }
    var channel: Channel?
    var topic: String? {
        didSet {
            self.configureView()
        }
    }

    func configureView() {
        if let topic = self.topic {
            title = topic
        }
    }
    
    private func configureSocket() {
        guard topic != nil else {
            return
        }
        
        if let socket = self.socket {
            let channelIdentifier = "playground:\(topic!)"
            let channel = socket.channel(channelIdentifier, payload: ["user": "phone client"])
            
            channel.on("new:msg", callback: { message in
                print(message)
            })
            
            channel.join().receive("ok", callback: { payload in
                print("Successfully joined: \(channel.topic)")
            })
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }
    
    private func sendMessage(message: String) {
        if let channel = self.channel {
            channel.send("new:msg", payload: ["body": "Hello!"])
                .receive("ok", callback: { response in
                    print("Sent a message!")
                })
                .receive("error", callback: { reason in
                    print("Message didn't send: \(reason)")
                })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

