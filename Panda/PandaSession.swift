//
//  PandaSession.swift
//  Panda
//
//  Created by Martin Kim Dung-Pham on 03/10/2016.
//  Copyright © 2016 Martin Kim Dung-Pham. All rights reserved.
//

import Foundation

open class PandaSession {
    open let title: String
    open let identifier: String

    init(dict: [String : AnyObject]) {
        title = dict["title"] as! String
        identifier = dict["uuid"] as! String
    }
}
