//
//  BLEDataConvertible.swift
//  iOS-BLE-Study
//
//  Created by SUN on 5/27/25.
//

import CoreBluetooth

public protocol BLEDataConvertible {
    func toBLEData() throws -> Data
}
