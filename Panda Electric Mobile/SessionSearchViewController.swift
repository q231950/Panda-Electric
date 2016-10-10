//
//  SessionSearchViewController.swift
//  Panda Electric Mobile
//
//  Created by Martin Kim Dung-Pham on 09/10/2016.
//  Copyright © 2016 elbedev.com. All rights reserved.
//

import UIKit
import MTBBarcodeScanner

class SessionSearchViewController: UIViewController {
    @IBOutlet weak var previewView: UIView!
    var scanner: MTBBarcodeScanner!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPreviewViewConstraints()
        
        MTBBarcodeScanner.requestCameraPermission { (success: Bool) in
            if success {
                self.setupBarcodeScanner()
            }
        }
    }
    
    private func setupBarcodeScanner() {
        scanner = MTBBarcodeScanner(previewView: previewView)
        var error: NSError?
        scanner.startScanning(resultBlock: { (results: [Any]?) in
            
            }, error: &error)
    }
    
    private func setupPreviewViewConstraints() {
        previewView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            previewView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            previewView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 34),
            previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -34),
            previewView.heightAnchor.constraint(equalTo: previewView.widthAnchor)
            ])
    }
}
