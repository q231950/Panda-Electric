//
//  EstimatingState.swift
//  Panda Electric Mobile
//
//  Created by Martin Kim Dung-Pham on 30/10/2016.
//  Copyright © 2016 elbedev.com. All rights reserved.
//

import GameplayKit

class EstimatingState: GKState {
    override func didEnter(from previousState: GKState?) {
        print("Entered \(self)")
    }
}

class EstimatedState: GKState {
    override func didEnter(from previousState: GKState?) {
        print("Entered \(self)")
    }
}
