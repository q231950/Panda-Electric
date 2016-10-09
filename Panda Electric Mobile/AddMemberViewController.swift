//
//  AddMemberViewController.swift
//  Panda Electric Mobile
//
//  Created by Martin Kim Dung-Pham on 09/10/2016.
//  Copyright © 2016 elbedev.com. All rights reserved.
//

import UIKit

class AddMemberViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "asd"
        
        setupImageViewConstraints()
        
        let qrCode = QRCode("http://elbedev.com")
        imageView.image = qrCode?.image
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
