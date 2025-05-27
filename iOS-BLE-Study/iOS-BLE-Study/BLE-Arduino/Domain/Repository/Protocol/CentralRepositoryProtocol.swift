//
//  CentralRepositoryProtocol.swift
//  iOS-BLE-Study
//
//  Created by SUN on 5/26/25.
//

import CoreBluetooth

public protocol CentralRepositoryProtocol {
    func scanForPeripherals(withServices services: [CBUUID]?) -> AsyncStream<PeripheralEntity>
    func stopScan()
    func connect(to peripheral: CBPeripheral) async throws -> PeripheralEntity
    func disconnect(from peripheral: CBPeripheral) async throws -> UUID
    func writeData(value: Data, to peripheral: CBPeripheral, for characteristic: CBCharacteristic)
    func writeDataWithResponse(value: Data, to peripheral: CBPeripheral, for characteristic: CBCharacteristic) async throws -> [UInt8]
}
