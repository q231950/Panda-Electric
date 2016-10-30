//
//  SessionSearchViewController.swift
//  Panda Electric Mobile
//
//  Created by Martin Kim Dung-Pham on 09/10/2016.
//  Copyright © 2016 elbedev.com. All rights reserved.
//

import UIKit
import MTBBarcodeScanner

protocol SessionSearchViewControllerDelegate {
    func sessionSearchViewControllerDidFindSession(sessionSearchViewController: SessionSearchViewController, uuid: String)
}

class SessionSearchViewController: UIViewController {
    @IBOutlet weak var previewView: UIView!
    var scanner: MTBBarcodeScanner!
    var delegate: SessionSearchViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(UIViewController.cancel))
        
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
            if let code = self.codeFromResults(results) {
                self.delegate?.sessionSearchViewControllerDidFindSession(sessionSearchViewController: self, uuid: code)
                self.scanner.stopScanning()
            }
        }, error: &error)
    }
    
    private func codeFromResults(_ results: [Any]?) -> String? {
        if let r = results {
            return r.map({ (code: Any) -> String in
                return (code as! AVMetadataMachineReadableCodeObject).stringValue
            }).first
        }
        return nil
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

extension UIViewController {
    func cancel() {
        dismiss(animated: true, completion: nil)
    }
}
