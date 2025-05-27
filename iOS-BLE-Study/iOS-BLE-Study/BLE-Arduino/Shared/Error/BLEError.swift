//
//  BLEError.swift
//  iOS-BLE-Study
//
//  Created by SUN on 5/26/25.
//

import Foundation

enum BLEError: Error {
    case invalidPeripheral
    case connectionFailed
    case disconnectionFailed
    case managerNotReady
    
    var errorDescription: String {
        switch self {
        case .invalidPeripheral:
            return "Invalid peripheral provided"
        case .connectionFailed:
            return "Failed to connect to peripheral"
        case .disconnectionFailed:
            return "Failed to disconnect from peripheral"
        case .managerNotReady:
            return "Central manager is not ready"
        }
    }
}
