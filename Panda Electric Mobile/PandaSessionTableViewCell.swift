//
//  PandaSessionTableViewCell.swift
//  Panda Electric Mobile
//
//  Created by Martin Kim Dung-Pham on 26/11/2016.
//  Copyright © 2016 elbedev.com. All rights reserved.
//

import UIKit
import Panda

class PandaSessionTableViewCell: UITableViewCell {
    
    static let Identifier = "PandaSessionTableViewCell"
    
    @IBOutlet private var nameLabel: UILabel!
    
    func configureWithSession(session: PandaSessionModel) {
        nameLabel.text = session.title
    }
}

