//
//  ConnectUseCaseProtocol.swift
//  iOS-BLE-Study
//
//  Created by SUN on 5/26/25.
//

import CoreBluetooth

public protocol ConnectUseCaseProtocol {
    func connect(to peripheral: CBPeripheral) async throws -> PeripheralEntity
    func disconnect(from peripheral: CBPeripheral) async throws -> UUID
}
