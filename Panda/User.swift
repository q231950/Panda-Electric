//
//  User.swift
//  Panda
//
//  Created by Martin Kim Dung-Pham on 03/10/2016.
//  Copyright © 2016 Martin Kim Dung-Pham. All rights reserved.
//

import Foundation

public struct User {
    public let uuid: String
    public let name: String
    public var estimate: Estimate?
    
    init?(dict: [String:Any]) {
        guard let uuid = dict["uuid"] as? String,
            let name = dict["name"] as? String
        else {
            return nil
        }
        
        self.uuid = uuid
        self.name = name
        
        if let estimateJson = dict["estimate"] as? [String:AnyObject] {
            estimate = Estimate(dict: estimateJson)
        }
    }
}
