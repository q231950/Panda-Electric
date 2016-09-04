//
//  FibonacciNumberButton.swift
//  Panda Electric Mobile
//
//  Created by Martin Kim Dung-Pham on 04/09/2016.
//  Copyright © 2016 elbedev.com. All rights reserved.
//

import UIKit

class FibonacciNumberButton: UIButton {
    let fibonacciNumber: FibonacciNumber
    
    init(fibonacciNumber: FibonacciNumber) {
        self.fibonacciNumber = fibonacciNumber
        super.init(frame: CGRectZero)
        self.setTitle("\(fibonacciNumber.value)", forState: .Normal)
        self.backgroundColor = UIColor.cyanColor().colorWithAlphaComponent(0.2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}