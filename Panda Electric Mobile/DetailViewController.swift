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
    
    let fibonacciPickerView = FibonacciPickerView(sequence: FibonacciSequence(numbers:[ FibonacciNumber(index:1, value:1),
                                                                                        FibonacciNumber(index:2, value:2),
                                                                                        FibonacciNumber(index:3, value:3),
                                                                                        FibonacciNumber(index:4, value:5),
                                                                                        FibonacciNumber(index:5, value:8),
                                                                                        FibonacciNumber(index:6, value:13),
                                                                                        FibonacciNumber(index:7, value:21),
                                                                                        FibonacciNumber(index:8, value:34),
                                                                                        FibonacciNumber(index:9, value:55),
                                                                                        FibonacciNumber(index:10, value:89),
                                                                                        FibonacciNumber(index:11, value:144),
                                                                                        FibonacciNumber(index:12, value:233),
                                                                                        FibonacciNumber(index:13, value:377),
                                                                                        FibonacciNumber(index:14, value:610),].reversed()))
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
        view.backgroundColor = UIColor.darkGray
        setupPickerView()
    }
    
    fileprivate func handleMessage(_ message: String, atPosition position: Int) {
        print("message: \(message)")
        if let receivedMessageLabel = self.receivedMessageLabel {
            receivedMessageLabel.text = message + " \(position)"
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.text = string
        if let socketHandler = self.socketHandler {
            socketHandler.sendMessage(message: string)
        }
        return false
    }
    
    // MARK: Setup
    
    func setupPickerView() {
        fibonacciPickerView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(fibonacciPickerView, at: 0)
        NSLayoutConstraint.activate([
            fibonacciPickerView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            fibonacciPickerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            fibonacciPickerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            fibonacciPickerView.rightAnchor.constraint(equalTo: view.rightAnchor)])
    }
    
    
}

