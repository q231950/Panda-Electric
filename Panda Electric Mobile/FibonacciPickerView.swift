//
//  SequenceView.swift
//  Panda Electric Mobile
//
//  Created by Martin Kim Dung-Pham on 03/09/16.
//  Copyright © 2016 elbedev.com. All rights reserved.
//

import UIKit

class FibonacciPickerView: UIView {
    let backgroundImageView = UIImageView(image: UIImage(named: "Background")!)
    
    init () {
        super.init(frame: CGRectZero)
        addSubview(backgroundImageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}