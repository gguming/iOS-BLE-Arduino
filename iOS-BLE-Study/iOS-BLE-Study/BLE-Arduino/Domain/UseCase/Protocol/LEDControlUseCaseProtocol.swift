//
//  WriteValueUseCaseProtocol.swift
//  iOS-BLE-Study
//
//  Created by SUN on 5/27/25.
//

import CoreBluetooth

public protocol LEDControlUseCaseProtocol {
    func control(to peripheral: CBPeripheral, isOn: Bool)
}
