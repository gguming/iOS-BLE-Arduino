//
//  LEDData.swift
//  iOS-BLE-Study
//
//  Created by SUN on 5/27/25.
//

import Foundation

struct LEDData: BLEDataConvertible {
    private let isOn: Bool
    
    init(isOn: Bool) {
        self.isOn = isOn
    }
    
    func toBLEData() throws -> Data {
        return Data([isOn ? 1 : 0])
    }
    
}
