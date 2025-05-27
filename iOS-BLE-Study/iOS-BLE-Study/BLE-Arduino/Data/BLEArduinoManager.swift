//
//  BLEArduinoManager.swift
//  iOS-BLE-Study
//
//  Created by SUN on 5/26/25.
//

import CoreBluetooth

final class BLEArduinoManager: NSObject {
    static let shared = BLEArduinoManager()
    private var centralManager: CBCentralManager = CBCentralManager()
    
    private var discoveredPeripheralContinuation: AsyncStream<PeripheralEntity>.Continuation?
    private var managerStateContinuation: AsyncStream<CBManagerState>.Continuation?
    private var connectionContinuation: CheckedContinuation<PeripheralEntity, Error>?
    private var disconnectionContinuation: CheckedContinuation<UUID, Error>?
    private var writeContinuation: CheckedContinuation<[UInt8], Error>?
    private var cachedPeripheral: [UUID: PeripheralEntity] = [:]
    
    override private init() {
        super.init()
        centralManager = CBCentralManager(delegate: self,
                                          queue: nil)
    }
}

extension BLEArduinoManager {
    private func checkAuthorization() {
        switch CBManager.authorization {
        case .denied:
            print("You are not authorized to use Bluetooth")
        case .restricted:
            print("Bluetooth is restricted")
        default:
            print("Unexpected authorization")
        }
    }
}

extension BLEArduinoManager: CentralRepositoryProtocol {
    func scanForPeripherals(withServices services: [CBUUID]?) -> AsyncStream<PeripheralEntity> {
        return AsyncStream { continuation in
            discoveredPeripheralContinuation = continuation
            
            continuation.onTermination = { [weak self] _ in
                self?.stopScan()
            }
            
            guard centralManager.isScanning == false else {
                return
            }
            
            centralManager.scanForPeripherals(withServices: services)
        }
    }
    
    func stopScan() {
        centralManager.stopScan()
        discoveredPeripheralContinuation?.finish()
        discoveredPeripheralContinuation = nil
    }
    
    func connect(to peripheral: CBPeripheral) async throws -> PeripheralEntity {
        return try await withCheckedThrowingContinuation { continuation in
            connectionContinuation = continuation
            centralManager.connect(peripheral)
        }
    }
    
    func disconnect(from peripheral: CBPeripheral) async throws -> UUID {
        return try await withCheckedThrowingContinuation { continuation in
            disconnectionContinuation = continuation
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    func setNorify(isOn: Bool, to peripheral: CBPeripheral, for characteristic: CBCharacteristic) {
        peripheral.setNotifyValue(isOn, for: characteristic)
    }
    
    func writeData(value: Data, to peripheral: CBPeripheral, for characteristic: CBCharacteristic) {
        peripheral.writeValue(value, for: characteristic, type: .withoutResponse)
    }
    
    func writeDataWithResponse(value: Data, to peripheral: CBPeripheral, for characteristic: CBCharacteristic) async throws -> [UInt8] {
        return try await withCheckedThrowingContinuation { continuation in
            writeContinuation = continuation
            peripheral.writeValue(value, for: characteristic, type: .withResponse)
        }
    }
    
    
}

extension BLEArduinoManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("CBManager is powered on")
        case .poweredOff:
            print("CBManager is not powered on")
            return
        case .unauthorized:
            checkAuthorization()
        default:
            print("A previously unknown central manager state occurred")
            return
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                       didDiscover peripheral: CBPeripheral,
                       advertisementData: [String : Any],
                       rssi RSSI: NSNumber) {
        let discoveredPeripheral = PeripheralEntity(id: peripheral.identifier,
                                                    peripheral: peripheral)
        discoveredPeripheralContinuation?.yield(discoveredPeripheral)
    }
    
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        let connectedPeripheral = PeripheralEntity(id: peripheral.identifier,
                                                   peripheral: peripheral)
        cachedPeripheral[peripheral.identifier] = connectedPeripheral
//        connectionContinuation?.resume(returning: connectedPeripheral)
//        connectionContinuation = nil
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager,
                        didFailToConnect peripheral: CBPeripheral,
                        error: (any Error)?) {
        connectionContinuation?.resume(throwing: error ?? BLEError.connectionFailed)
        connectionContinuation = nil
    }
    
    func centralManager(_ central: CBCentralManager,
                       didDisconnectPeripheral peripheral: CBPeripheral,
                       error: Error?) {
        if let error = error {
            disconnectionContinuation?.resume(throwing: error)
        } else {
            disconnectionContinuation?.resume(returning: peripheral.identifier)
        }
        disconnectionContinuation = nil
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: (any Error)?) {
        if let error {
            print("Error discovering characteristics: %s", error.localizedDescription)
            return
        }
        
        
    }
}

extension BLEArduinoManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: %s", error.localizedDescription)
            if let info = cachedPeripheral[peripheral.identifier] {
                connectionContinuation?.resume(returning: info)
            }
            connectionContinuation = nil
            return
        }
        
        let peripheralServices = peripheral.services ?? []
        print("discovered Service: \(peripheralServices)")
        if cachedPeripheral[peripheral.identifier] != nil {
            cachedPeripheral[peripheral.identifier]?.setService(peripheralServices)
        }
        for service in peripheralServices {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics: %s", error.localizedDescription)
        }
        
        let serviceCharacteristics = service.characteristics ?? []
        print("discovered Characteristics: \(serviceCharacteristics)")
        
        if cachedPeripheral[peripheral.identifier] != nil {
            cachedPeripheral[peripheral.identifier]?.setCharacteristics(for: service, characteristics: serviceCharacteristics)
        }
        
        if var info = cachedPeripheral[peripheral.identifier],
           info.isAllValid {
            info.isConnected = true
            connectionContinuation?.resume(returning: info)
            connectionContinuation = nil
            cachedPeripheral[peripheral.identifier] = nil 
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        if let error {
            writeContinuation?.resume(throwing: error)
            writeContinuation = nil
        }
        let dataBytes: [UInt8] = characteristic.value?.map { $0 } ?? []
        writeContinuation?.resume(returning:  dataBytes)
        writeContinuation = nil
    }
}
