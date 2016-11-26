//
//  PandaSessionModel.swift
//  Panda
//
//  Created by Martin Kim Dung-Pham on 03/10/2016.
//  Copyright © 2016 Martin Kim Dung-Pham. All rights reserved.
//

import Foundation

public func ==(lhs: PandaSessionModel, rhs: PandaSessionModel) -> Bool {
    return (lhs.identifier == rhs.identifier)
}

public final class PandaSessionModel : Equatable {
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
    
    init(title: String, identifier: String, estimates: [UserEstimation]) {
        self.title = title
        self.identifier = identifier
        self.estimates = estimates
    }
    
    public static func all() -> [PandaSessionModel] {
        return [PandaSessionModel(title: "panda session model", identifier: "123456", estimates: []),
                PandaSessionModel(title: "2nd panda session model", identifier: "234567", estimates: [])]
    }
}

extension PandaSessionModel: Hashable {
    public var hashValue: Int {
        return self.identifier.hashValue
    }
}
