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
    func setNorify(isOn: Bool, to peripheral: CBPeripheral, for characteristic: CBCharacteristic)
}

//// MARK: - Bluetooth Repository Implementation
//final class BluetoothRepository: NSObject, BluetoothRepositoryProtocol {
//    private var centralManager: CBCentralManager!
//    private let queue = DispatchQueue(label: "bluetooth.repository", qos: .userInitiated)
//    
//    // AsyncStream continuations for handling callbacks
//    private var peripheralDiscoveryContinuation: AsyncStream<Peripheral>.Continuation?
//    private var managerStateContinuation: AsyncStream<CBManagerState>.Continuation?
//    private var connectionContinuation: CheckedContinuation<Peripheral, Error>?
//    private var disconnectionContinuation: CheckedContinuation<Peripheral, Error>?
//    
//    override init() {
//        super.init()
//    }
//    
//    func startManager() async {
//        await withCheckedContinuation { continuation in
//            DispatchQueue.main.async { [weak self] in
//                self?.centralManager = CBCentralManager(delegate: self, queue: self?.queue)
//                continuation.resume()
//            }
//        }
//    }
//    
//    func scanForPeripherals(withServices services: [CBUUID]) -> AsyncStream<Peripheral> {
//        return AsyncStream { continuation in
//            self.peripheralDiscoveryContinuation = continuation
//            
//            continuation.onTermination = { @Sendable _ in
//                Task { [weak self] in
//                    await self?.stopScan()
//                }
//            }
//            
//            guard centralManager?.isScanning == false else {
//                return
//            }
//            
//            centralManager?.scanForPeripherals(withServices: services, options: [:])
//        }
//    }
//    
//    func connect(to peripheral: Peripheral) async throws -> Peripheral {
//        stopScan()
//        
//        guard let cbPeripheral = peripheral.cbPeripheral else {
//            throw BluetoothError.invalidPeripheral
//        }
//        
//        return try await withCheckedThrowingContinuation { continuation in
//            self.connectionContinuation = continuation
//            centralManager?.connect(cbPeripheral)
//        }
//    }
//    
//    func disconnect(from peripheral: Peripheral) async throws -> Peripheral {
//        guard let cbPeripheral = peripheral.cbPeripheral else {
//            throw BluetoothError.invalidPeripheral
//        }
//        
//        return try await withCheckedThrowingContinuation { continuation in
//            self.disconnectionContinuation = continuation
//            centralManager?.cancelPeripheralConnection(cbPeripheral)
//        }
//    }
//    
//    func managerStateUpdates() -> AsyncStream<CBManagerState> {
//        return AsyncStream { continuation in
//            self.managerStateContinuation = continuation
//            
//            // Send current state if available
//            if let currentState = centralManager?.state {
//                continuation.yield(currentState)
//            }
//        }
//    }
//    
//    func stopScan() {
//        centralManager?.stopScan()
//        peripheralDiscoveryContinuation?.finish()
//        peripheralDiscoveryContinuation = nil
//    }
//}
//
//// MARK: - CBCentralManagerDelegate
//extension BluetoothRepository: CBCentralManagerDelegate {
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        managerStateContinuation?.yield(central.state)
//    }
//    
//    func centralManager(_ central: CBCentralManager,
//                       didDiscover peripheral: CBPeripheral,
//                       advertisementData: [String : Any],
//                       rssi RSSI: NSNumber) {
//        let discoveredPeripheral = Peripheral(cbPeripheral: peripheral)
//        peripheralDiscoveryContinuation?.yield(discoveredPeripheral)
//    }
//    
//    func centralManager(_ central: CBCentralManager,
//                       didConnect peripheral: CBPeripheral) {
//        let connectedPeripheral = Peripheral(cbPeripheral: peripheral)
//        connectionContinuation?.resume(returning: connectedPeripheral)
//        connectionContinuation = nil
//    }
//    
//    func centralManager(_ central: CBCentralManager,
//                       didFailToConnect peripheral: CBPeripheral,
//                       error: Error?) {
//        let connectionError = error ?? BluetoothError.connectionFailed
//        connectionContinuation?.resume(throwing: connectionError)
//        connectionContinuation = nil
//    }
//    
//    func centralManager(_ central: CBCentralManager,
//                       didDisconnectPeripheral peripheral: CBPeripheral,
//                       error: Error?) {
//        let disconnectedPeripheral = Peripheral(cbPeripheral: peripheral)
//        
//        if let error = error {
//            disconnectionContinuation?.resume(throwing: error)
//        } else {
//            disconnectionContinuation?.resume(returning: disconnectedPeripheral)
//        }
//        disconnectionContinuation = nil
//    }
//}
