//
//  PandaSessionModel.swift
//  Panda
//
//  Created by Martin Kim Dung-Pham on 03/10/2016.
//  Copyright © 2016 Martin Kim Dung-Pham. All rights reserved.
//

import Foundation

open class PandaSessionModel {
    open let title: String
    open let identifier: String
    open let estimates: [UserEstimation]

    init?(dict: [String:AnyObject]) {
        guard let title = dict["title"] as? String,
            let identifier = dict["id"] as? String,
            let estimatesJson = dict["estimates"] as? [[String:Any]]
        else {
            return nil
        }
        
        self.title = title
        self.identifier = identifier
        estimates = estimatesJson.map { (json:[String : Any]) -> UserEstimation in
            return UserEstimation(dict: json)
        }
        
        
    }
}
