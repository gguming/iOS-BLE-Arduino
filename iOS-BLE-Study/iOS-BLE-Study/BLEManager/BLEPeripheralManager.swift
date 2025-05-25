//
//  BLEPeripheralManager.swift
//  iOS-BLE-Study
//
//  Created by SUN on 5/23/25.
//

import CoreBluetooth

final class BLEPeripheralManager: NSObject, ObservableObject {
    private var peripheralManager: CBPeripheralManager = CBPeripheralManager()
    private var transferCharacteristic: CBMutableCharacteristic?
    private var sendingEOM: Bool = false
    private var dataToSend = Data()
    private var sendDataIndex: Int = 0
    private var connectedCentral: CBCentral?
    @Published var isOn: Bool = false
    @Published var textInput: String = "안녕하세요? 테스트 중입니다."
    @Published var receivedValue: String = ""
    
    override init() {
        super.init()
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
}

extension BLEPeripheralManager {
    func startAdvertising() {
        peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [TransferService.serviceUUID]])
    }
    
    func stopAdvertising() {
        guard peripheralManager.isAdvertising else { return }
        peripheralManager.stopAdvertising()
    }
    
    private func setupPeripheral() {
        let transferCharacteristic = CBMutableCharacteristic(type: TransferService.characteristicUUID,
                                                             properties: [.notify, .writeWithoutResponse],
                                                             value: nil,
                                                             permissions: [.readable, .writeable])
        
        let transferService = CBMutableService(type: TransferService.serviceUUID, primary: true)
        transferService.characteristics = [transferCharacteristic]
        
        peripheralManager.add(transferService)
        self.transferCharacteristic = transferCharacteristic
        
    }
    
    func sendData() {
        guard let transferCharacteristic else { return }
    
        guard !isSendEOM(transferCharacteristic) else { return }
        
        guard sendDataIndex < dataToSend.count else {
            return
        }
        
        var didSend: Bool = true
        
        while didSend {
            var amountToSend = dataToSend.count - sendDataIndex
            if let mtu = connectedCentral?.maximumUpdateValueLength {
                amountToSend = min(amountToSend, mtu)
            }
            
            let chunk = dataToSend.subdata(in: sendDataIndex..<(sendDataIndex + amountToSend))
            didSend = peripheralManager.updateValue(chunk,
                                                    for: transferCharacteristic,
                                                    onSubscribedCentrals: nil)
            
            if !didSend {
                return
            }
            
            sendDataIndex += amountToSend
            
            if sendDataIndex >= dataToSend.count {
                sendingEOM = true
                let eomSent = peripheralManager.updateValue("EOM".data(using: .utf8)!,
                                                            for: transferCharacteristic,
                                                            onSubscribedCentrals: nil)
                if eomSent {
                    sendingEOM = false
                }
                return
            }
        }
    }
    
    private func isSendEOM(_ transferCharacteristic: CBMutableCharacteristic) -> Bool {
        if sendingEOM {
            let didSend = peripheralManager.updateValue("EOM".data(using: .utf8)!,
                                                        for: transferCharacteristic,
                                                        onSubscribedCentrals: nil)
            if didSend {
                sendingEOM = false
            }
            return true
        }
        
        return false
    }
}

extension BLEPeripheralManager: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            print("CBManager is powered on")
            setupPeripheral()
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
    
    func peripheralManager(_ peripheral: CBPeripheralManager,
                           central: CBCentral,
                           didSubscribeTo characteristic: CBCharacteristic) {
        guard let data = textInput.data(using: .utf8) else { return }
        dataToSend = data
        sendDataIndex = 0
        connectedCentral = central
        sendData()
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager,
                           central: CBCentral,
                           didUnsubscribeFrom characteristic: CBCharacteristic) {
        print("Central unsubscribed from characteristic")
        connectedCentral = nil
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        sendData()
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for aRequest in requests {
            guard let requestValue = aRequest.value,
                let stringFromData = String(data: requestValue, encoding: .utf8) else {
                    continue
            }
            
            print("Received write request of %d bytes: %s", requestValue.count, stringFromData)
            Task{ @MainActor in
                receivedValue = stringFromData
            }
        }
    }
}
