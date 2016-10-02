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
    
    var value: String {
        get {
            switch self {
            case .fibonacci(let value):
                return "\(value)"
            case .tshirt(size: let size):
                return size.rawValue
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
            }
        }
    }
}
