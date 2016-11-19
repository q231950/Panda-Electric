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
    
    init?(dict: [String:Any]) {
        guard let uuid = dict["id"] as? String,
            let name = dict["name"] as? String
        else {
            return nil
        }
        
        self.uuid = uuid
        self.name = name
    }
}
