//
//  AddMemberViewController.swift
//  Panda Electric Mobile
//
//  Created by Martin Kim Dung-Pham on 09/10/2016.
//  Copyright © 2016 elbedev.com. All rights reserved.
//

import UIKit
import Panda

class AddMemberViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    var channelHandler: EstimationChannelHandler? {
        didSet {
            title = channelHandler?.topic
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupImageViewConstraints()
        
        if let qrCode = QRCode((channelHandler?.channelIdentifier)!) {
            imageView.image = qrCode.image
        }
    }
    
    private func setupImageViewConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 34),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -34),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
            ])
    }
    
    @IBAction func dismiss(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
