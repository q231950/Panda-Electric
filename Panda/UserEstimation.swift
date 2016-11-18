//
//  UserEstimation.swift
//  Panda
//
//  Created by Martin Kim Dung-Pham on 18/11/2016.
//  Copyright © 2016 Martin Kim Dung-Pham. All rights reserved.
//

import Foundation

public class UserEstimation {
    var user: User?
    var estimate: Estimate
    
    public init(dict: [String:Any]) {
        if let userJson = dict["user"] as? [String:Any] {
            user = User(dict: userJson)
        }
        estimate = Estimate(dict: dict["estimate"] as? [String:AnyObject])
    }
}
