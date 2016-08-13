//
//  DetailViewController.swift
//  Panda Electric Mobile
//
//  Created by Martin Kim Dung-Pham on 30/07/16.
//  Copyright © 2016 elbedev.com. All rights reserved.
//

import UIKit
import Panda

class DetailViewController: UIViewController, UITextFieldDelegate {
    
    var socketHandler: SocketHandler? {
        didSet {
            socketHandler?.messageHandler = { (message: String, position: Int) -> Void in
                self.handleMessage(message, atPosition: position)
            }
        }
    }
    
    @IBOutlet var receivedMessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = socketHandler?.topic as String?
    }
    
    private func handleMessage(message: String, atPosition position: Int) {
        if let receivedMessageLabel = self.receivedMessageLabel {
            receivedMessageLabel.text = message + " \(position)"
        }
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        textField.text = string
        if let socketHandler = self.socketHandler {
            socketHandler.sendMessage(string)
        }
        return false
    }
    
    
}

