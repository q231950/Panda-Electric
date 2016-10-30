//
//  DetailViewController.swift
//  Panda Electric Mobile
//
//  Created by Martin Kim Dung-Pham on 30/07/16.
//  Copyright © 2016 elbedev.com. All rights reserved.
//

import UIKit
import Panda
import GameplayKit

class DetailViewController: UIViewController, UITextFieldDelegate {
    
    var stateMachine: GKStateMachine!
    var fibonacciPickerView: FibonacciPickerView!
    var selectedNumber: FibonacciNumber?
    var user: String?
    var channelHandler: EstimationChannelHandler? {
        didSet {
            channelHandler?.estimateHandler = { (estimate: Estimate) -> Void in
                // handle estimate
            }
        }
    }
    
    @IBOutlet weak var doneBarButtonItem: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let estimatingState = EstimatingState()
        let estimatedState = EstimatedState()
        stateMachine = GKStateMachine(states: [estimatingState, estimatedState])
        stateMachine.enter(EstimatingState.self)
        
        view.backgroundColor = UIColor.darkGray
        setupPickerView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        fibonacciPickerView.selectFibonacciNumber(FibonacciNumber(index: 7, value: 34))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationController = segue.destination as? UINavigationController {
            if let viewController = navigationController.topViewController as? AddMemberViewController {
                viewController.channelHandler = channelHandler
            }
        }
    }
    
    fileprivate func handleMessage(_ message: String, atPosition position: Int) {
        print("message: \(message)")
    }

    @IBAction func doneAction(_ sender: Any) {
        if let number = selectedNumber, let user = self.user {
            channelHandler?.sendEstimate(.fibonacci(number.value), userIdentifier: user)
        }
    }
    
    
    // MARK: Setup
    
    func setupPickerView() {
        fibonacciPickerView = FibonacciPickerView(sequence: FibonacciSequence(numbers:[ FibonacciNumber(index:1, value:1),
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
        fibonacciPickerView.translatesAutoresizingMaskIntoConstraints = false
        fibonacciPickerView.delegate = self
        view.insertSubview(fibonacciPickerView, at: 0)
        NSLayoutConstraint.activate([
            fibonacciPickerView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            fibonacciPickerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            fibonacciPickerView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor),
            fibonacciPickerView.rightAnchor.constraint(equalTo: view.rightAnchor)])
    }
}

extension DetailViewController: FibonacciPickerViewDelegate {
    func pickerViewDidSelectFibonacciNumber(pickerView: FibonacciPickerView, number: FibonacciNumber) {
        selectedNumber = number
    }
}

