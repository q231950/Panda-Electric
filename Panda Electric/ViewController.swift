//
//  ViewController.swift
//  Panda Electric
//
//  Created by Martin Kim Dung-Pham on 30/07/16.
//  Copyright © 2016 elbedev.com. All rights reserved.
//

import Cocoa
import Birdsong

class ViewController: NSViewController {

    let socket = Socket(url: NSURL(string: "http://localhost:4000/socket/websocket")!)
//    let socket = Socket(url: NSURL(string: "https://tranquil-peak-78260.herokuapp.com/socket/websocket")!)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        socket.onConnect = {
            let channel = self.socket.channel("playground:main", payload: ["user": "spartacus"])
            channel.on("new:msg", callback: { message in
//                self.displayMessage(message)
                print(message)
            })
            
            channel.join().receive("ok", callback: { payload in
                print("Successfully joined: \(channel.topic)")
            })
            
            channel.send("new:msg", payload: ["body": "Hello!"])
                .receive("ok", callback: { response in
                    print("Sent a message!")
                })
                .receive("error", callback: { reason in
                    print("Message didn't send: \(reason)")
                })
            
            // Presence support.
            channel.presence.onStateChange = { newState in
                // newState = dict where key = unique ID, value = array of metas.
                print("New presence state: \(newState)")
            }
            
            channel.presence.onJoin = { id, meta in
                print("Join: user with id \(id) with meta entry: \(meta)")
            }
            
            channel.presence.onLeave = { id, meta in
                print("Leave: user with id \(id) with meta entry: \(meta)")
            }
        }
        socket.connect()
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    

}

