//
//  BLECentralManager.swift
//  iOS-BLE-Study
//
//  Created by SUN on 5/21/25.
//

import CoreBluetooth

struct TransferService {
    static let serviceUUID = CBUUID(string: "E20A39F4-73F5-4BC4-A12F-17D1AD07A965")
    static let characteristicUUID = CBUUID(string: "08590F7E-DB05-467E-8757-72F6FAEB13D8")
}

final class BLECentralManager: NSObject, ObservableObject {
    private var centralManager = CBCentralManager()
    private var data = Data()
    private var connectingPeripheral: CBPeripheral?
    private var transferCharacteristic: CBCharacteristic?
    private var writeIterationsComplete = 0
    private let defaultIterations = 5
    
    @Published var discoveredPeripherals: [PeripheralItem] = []
    @Published var receivedValue: String = ""
    @Published var sendValue: String = ""
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self,
                                        queue: nil,
                                        options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }
    
    deinit {
        centralManager.stopScan()
    }
}

extension BLECentralManager {
    
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
    
    func retrievePeripheral() {
        guard centralManager.state == .poweredOn else { return }
        centralManager.scanForPeripherals(withServices: [TransferService.serviceUUID])
    }
    
    func stopScanning() {
        discoveredPeripherals.removeAll(keepingCapacity: false)
        centralManager.stopScan()
    }
    
    func connect(_ peripheral: CBPeripheral) {
        centralManager.connect(peripheral)
    }
    
    func disconnect(_ peripheral: CBPeripheral) {
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    func writeData() {
        guard let connectingPeripheral = connectingPeripheral,
              let transferCharacteristic = transferCharacteristic,
              let data = sendValue.data(using: .utf8)
        else { return }
        
        while writeIterationsComplete < defaultIterations && connectingPeripheral.canSendWriteWithoutResponse {
            let mtu = connectingPeripheral.maximumWriteValueLength(for: .withoutResponse)
            let bytesToCopy: size_t = min(mtu, data.count)
            
            // UInt8 배열을 올바른 크기로 초기화
            var rawPacket = [UInt8](repeating: 0, count: bytesToCopy)
            
            // Data에서 UInt8 배열로 안전하게 복사
            data.copyBytes(to: &rawPacket, count: bytesToCopy)
            
            // UInt8 배열을 Data로 변환하여 전송
            let packetData = Data(rawPacket)
            
            let stringFromData = String(data: packetData, encoding: .utf8)
            print("Writing \(bytesToCopy) bytes: \(stringFromData ?? "nil")")
            
            connectingPeripheral.writeValue(packetData, for: transferCharacteristic, type: .withoutResponse)
            writeIterationsComplete += 1
        }
    }
}

extension BLECentralManager: CBCentralManagerDelegate {
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
        guard RSSI.intValue >= -50 else { return }
        let item = PeripheralItem(id: peripheral.identifier,
                                  peripheral: peripheral)
        if !discoveredPeripherals.contains(item) {
            let peripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? "Unknown Name"
            print("Discovered %s 주요 이름: %s id: %s at %d", String(describing: peripheral.name), peripheralName, peripheral.identifier.uuidString,  RSSI.intValue)
            discoveredPeripherals.append(item)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to %@. %s", peripheral, String(describing: error))
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Peripheral Connected")
        centralManager.stopScan()
        if let index = discoveredPeripherals.firstIndex(where: { $0.id == peripheral.identifier }) {
            discoveredPeripherals[index].isConnected = true
        }
        connectingPeripheral = peripheral
        writeIterationsComplete = 0
        data.removeAll(keepingCapacity: false)
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: (any Error)?) {
        if let error {
            print("Error discovering characteristics: %s", error.localizedDescription)
            return
        }
        
        guard let characteristicData = characteristic.value,
              let stringFromData = String(data: characteristicData, encoding: .utf8) else { return }
        
        if stringFromData == "EOM" {
            receivedValue = String(data: self.data, encoding: .utf8) ?? ""
        } else {
            data.append(characteristicData)
        }
    }
}

extension BLECentralManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: %s", error.localizedDescription)
            return
        }
        
        guard let peripheralServices = peripheral.services else { return }
        print("discovered Service: \(peripheralServices)")
        if let index = discoveredPeripherals.firstIndex(where: { $0.id == peripheral.identifier }) {
            discoveredPeripherals[index].setService(peripheralServices)
        }
        for service in peripheralServices {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics: %s", error.localizedDescription)
            return
        }
        
        guard let serviceCharacteristics = service.characteristics else { return }
        print("discovered Characteristics: \(serviceCharacteristics)")
        if let index = discoveredPeripherals.firstIndex(where: { $0.id == peripheral.identifier }) {
            discoveredPeripherals[index].setCharacteristics(for: service, characteristics: serviceCharacteristics)
        }
        
        if let characteristic = serviceCharacteristics.first(where: { $0.uuid == TransferService.characteristicUUID }) {
            self.transferCharacteristic = characteristic
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let index = discoveredPeripherals.firstIndex(where: { $0.id == peripheral.identifier }) {
            discoveredPeripherals[index].isConnected = false
        }
        print("Disconnected from peripheral: \(peripheral.name ?? "Unknown")")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error changing notification state: %s", error.localizedDescription)
            return
        }
        
        // Exit if it's not the transfer characteristic
        guard characteristic.uuid == TransferService.characteristicUUID else { return }
        
        if characteristic.isNotifying {
            print("Notification began on %@", characteristic)
        } else {
            print("Notification stopped on %@. Disconnecting", characteristic)
        }
        
    }
    
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        writeData()
    }
    
}
