//
//  Estimate.swift
//  Pods
//
//  Created by Martin Kim Dung-Pham on 29/09/2016.
//
//

import Foundation

public enum TShirtSize: String {
    case S = "S"
    case M = "M"
    case L = "L"
    case XL = "XL"
    case XXL = "XXL"
}

public enum Estimate {
    case tshirt(size: TShirtSize)
    case fibonacci(Int)
    case none
    
    var value: String {
        get {
            switch self {
            case .fibonacci(let value):
                return "\(value)"
            case .tshirt(size: let size):
                return size.rawValue
            case .none:
                return "none"
            }
        }
    }
    
    var kind: String {
        get {
            switch self {
            case .fibonacci(_):
                return "fibonacci"
            case .tshirt(size: _):
                return "tshirt"
            case .none:
                return "none"
            }
        }
    }
    
    init(dict: [String:AnyObject]?) {
        if let kind = dict?["kind"] as? String, kind == "fibonacci", let value = dict?["value"] as? Int {
            self = .fibonacci(value)
        } else if let kind = dict?["kind"] as? String, kind == "tshirt", let value = dict?["value"] as? String {
            if let size = TShirtSize(rawValue: value) {
                self = .tshirt(size: size)
            } else {
                self = .none
            }
        } else {
            self = .none
        }
    }
}
