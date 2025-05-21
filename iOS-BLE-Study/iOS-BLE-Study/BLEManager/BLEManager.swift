//
//  BLEManager.swift
//  iOS-BLE-Study
//
//  Created by SUN on 5/21/25.
//

import CoreBluetooth

final class BLEManager: NSObject, ObservableObject {
    private var centralManager = CBCentralManager()
    
    @Published var discoveredPeripherals: [CBPeripheral] = []
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self,
                                        queue: nil,
                                        options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }
}

extension BLEManager {
    
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
        centralManager.scanForPeripherals(withServices: nil)
    }
    
    func stopScanning() {
        centralManager.stopScan()
    }
}

extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("CBManager is powered on")
            retrievePeripheral()
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
        if !discoveredPeripherals.contains(peripheral) {
            if let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data {
                    // 제조사 데이터 출력
                    print("Manufacturer Data: \(manufacturerData)")
                    
                    // 제조사 데이터에서 원하는 정보 추출 (예: Apple 장치인지 확인)
                    if manufacturerData.count > 0 {
                        // 예시: 특정 바이트를 기준으로 Apple 장치인지 확인할 수 있음 (Apple의 제조사 데이터는 고유한 시그니처를 가짐)
                        let manufacturerDataArray = [UInt8](manufacturerData)
                        if manufacturerDataArray[0] == 0x4C { // Apple 제조사 시그니처 (0x4C는 Apple을 나타내는 값)
                            print("This is an Apple device!")
                        }
                    }
                } else {
                    print("No manufacturer data available")
                }
//            if let serviceUUIDs = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] {
//                   print("Discovered peripheral with services: \(serviceUUIDs)")
//               }
//               
//               // 광고 패킷에서 제조사 데이터 확인
//               if let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data {
//                   print("Manufacturer Data: \(manufacturerData)")
//               }
            let peripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? "Unknown Name"
            print("Discovered %s 주요 이름: %s id: %s at %d", String(describing: peripheral.name), peripheralName, peripheral.identifier.uuidString,  RSSI.intValue)
            discoveredPeripherals.append(peripheral)
        }
    }
}
